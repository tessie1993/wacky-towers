"""build_env_kit.py - Wacky Towers environment kit (technical art, 2026-10-13).

Headless Blender 5.2 script. Builds every environment GLB procedurally (no .blend is saved)
and exports them to assets/models/env/:

  env_island_underside  sculpted floating-island rock mass, unit footprint (half extents 1),
                        top at y=0, tip at y=-1. Scaled per board in Godot.
  env_lip_grass / env_lip_snow / env_lip_rock
                        1.1 m lip ring segments laid along the island outline. Local +Z (Godot)
                        points outward. Grass has hanging roots and vines, snow has icicles,
                        rock is chunky obsidian slabs.
  env_roots             dangling root/vine cluster hung under the lip.
  env_tile              bevelled stone grid tile (0.94 x 0.94 x 0.14).
  env_fall_ribbon       waterfall/lavafall ribbon, UV.y down the flow, alpha = edge fade.
  prop_*                dressing props (bush, flowers, pine_snow, tree, crystal, coral, kelp, shell,
                        mushroom, rock, gear, lollipop, pillar, star, palm, pot, balloon).

Vertex colour contract (read by src/view/shaders/spatial_env_*.gdshader):
  env_island_underside, env_lip_*, env_roots:
      R = ambient occlusion (ray-cast), G = rock detail (Poly Haven cliff_side luminance),
      B = cover mask (1 = grass/snow/moss lip colour, 0 = soil/rock), A = 1.
  env_tile: R = AO/bevel shade, G = stone detail, B = 1 on the top face, A = 1.
  prop_*:   RGB = albedo with AO baked in, A = tint mask (1 = multiplied by the biome tint
            Godot passes per instance, 0 = fixed colour).
  env_fall_ribbon: RGB = 1, A = edge/end fade.

Run:
  blender -b --factory-startup -P assets/source/blender/env/build_env_kit.py -- [--out DIR] [--render DIR]
Poly Haven textures (CC0) are read from assets/third_party/polyhaven/ (see assets/third_party/CREDITS.md).
"""
import bpy, bmesh, math, os, sys, random
from mathutils import Vector, Matrix, noise
from mathutils.bvhtree import BVHTree

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
ARGS = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
OUT = os.path.join(ROOT, "assets", "models", "env")
RENDER = None
if "--out" in ARGS: OUT = os.path.abspath(ARGS[ARGS.index("--out") + 1])
if "--render" in ARGS: RENDER = os.path.abspath(ARGS[ARGS.index("--render") + 1])
ONLY = ARGS[ARGS.index("--only") + 1].split(",") if "--only" in ARGS else None
PH = os.path.join(ROOT, "assets", "third_party", "polyhaven")
os.makedirs(OUT, exist_ok=True)


# ---------------------------------------------------------------- texture sampling (Poly Haven)
class Lum:
    """Luminance lookup of a tileable Poly Haven texture, downsampled to 128 px for speed."""
    def __init__(self, path, size=128):
        self.ok = os.path.exists(path)
        self.size = size
        self.px = []
        if not self.ok: return
        img = bpy.data.images.load(path)
        img.scale(size, size)
        p = list(img.pixels)
        self.px = [0.2126 * p[i] + 0.7152 * p[i + 1] + 0.0722 * p[i + 2] for i in range(0, len(p), 4)]
        lo, hi = min(self.px), max(self.px)
        self.px = [(v - lo) / max(hi - lo, 1e-4) for v in self.px]
        bpy.data.images.remove(img)

    def at(self, u, v):
        if not self.ok: return 0.5 + 0.5 * noise.noise(Vector((u * 7, v * 7, 0.3)))
        n = self.size
        x = int((u % 1.0) * n) % n; y = int((v % 1.0) * n) % n
        return self.px[y * n + x]


CLIFF = Lum(os.path.join(PH, "cliff_side", "cliff_side_diff_1k.jpg"))
STONE = Lum(os.path.join(PH, "rock_face", "rock_face_diff_1k.jpg"))


# ---------------------------------------------------------------- mesh helpers
def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def srgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


class Kit:
    """Accumulates parts (bmesh) with a per-vertex RGBA colour layer, then builds one object."""
    def __init__(self, name):
        self.name = name
        self.bm = bmesh.new()
        self.col = self.bm.verts.layers.float_color.new("Col")

    def add(self, other_bm, rgba, transform=None, colour_fn=None):
        """Merges `other_bm` (consumed) with a flat colour or a per-vertex colour_fn(v)->rgba."""
        if transform is not None:
            bmesh.ops.transform(other_bm, matrix=transform, verts=other_bm.verts)
        mapping = {}
        for v in other_bm.verts:
            nv = self.bm.verts.new(v.co)
            c = colour_fn(nv.co) if colour_fn else rgba
            nv[self.col] = (c[0], c[1], c[2], c[3] if len(c) > 3 else 1.0)
            mapping[v] = nv
        for f in other_bm.faces:
            try:
                self.bm.faces.new([mapping[v] for v in f.verts])
            except ValueError:
                pass
        other_bm.free()

    def finish(self, sharp_deg=40.0, ao=True, ao_dist=0.6, ao_strength=0.8, ao_bake_rgb=False, merge=True):
        bm = self.bm
        if merge:
            bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        bm.normal_update()
        if ao:
            occl = ray_ao(bm, ao_dist)
            for v in bm.verts:
                c = list(v[self.col])
                a = 1.0 - ao_strength * occl[v.index]
                if ao_bake_rgb:
                    c[0] *= a; c[1] *= a; c[2] *= a
                else:
                    c[0] = a
                v[self.col] = c
        me = bpy.data.meshes.new(self.name)
        bm.to_mesh(me)
        bm.free()
        for p in me.polygons: p.use_smooth = True
        me.set_sharp_from_angle(angle=math.radians(sharp_deg))
        ob = bpy.data.objects.new(self.name, me)
        bpy.context.scene.collection.objects.link(ob)
        set_active_colour(me)
        return ob


def set_active_colour(me):
    """Marks "Col" as the active and render colour attribute (the glTF exporter reads ACTIVE)."""
    idx = [a.name for a in me.color_attributes].index("Col")
    me.color_attributes.active_color_index = idx
    me.color_attributes.render_color_index = idx
    me.color_attributes.active_color = me.color_attributes["Col"]


def ray_ao(bm, dist, rays=14):
    """Hemisphere ray-cast ambient occlusion per vertex (fraction of rays hitting within dist)."""
    bm.verts.ensure_lookup_table()
    tree = BVHTree.FromBMesh(bm)
    rnd = random.Random(7)
    dirs = []
    for i in range(rays):
        z = rnd.random(); a = rnd.random() * math.tau; r = math.sqrt(1 - z * z)
        dirs.append(Vector((r * math.cos(a), r * math.sin(a), z)))
    out = []
    for v in bm.verts:
        n = v.normal if v.normal.length > 0.1 else Vector((0, 0, 1))
        basis = n.to_track_quat("Z", "Y").to_matrix()
        hit = 0
        for d in dirs:
            w = basis @ d
            loc, _, _, _ = tree.ray_cast(v.co + n * 0.004, w, dist)
            if loc is not None: hit += 1
        out.append(hit / rays)
    return out


def ico(r=1.0, sub=1):
    bm = bmesh.new(); bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=r); return bm


def uvs(r=1.0, seg=8, rings=5):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=rings, radius=r); return bm


def cone(r1, r2, h, seg=8, cap=True):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=cap, cap_tris=False, segments=seg, radius1=r1, radius2=r2, depth=h)
    bmesh.ops.translate(bm, vec=Vector((0, 0, h * 0.5)), verts=bm.verts)  # base at z=0
    return bm


def box(sx, sy, sz):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.scale(bm, vec=Vector((sx, sy, sz)), verts=bm.verts); return bm


def displace(bm, amp, scale, seed=0.0, axis_mask=(1, 1, 1)):
    off = Vector((seed * 13.1, seed * 7.7, seed * 3.3))
    for v in bm.verts:
        n = noise.noise_vector(v.co * scale + off)
        v.co += Vector((n.x * axis_mask[0], n.y * axis_mask[1], n.z * axis_mask[2])) * amp


def tube(points, radii, seg=5):
    """Tapered tube along a polyline (closed tip). Returns bmesh."""
    bm = bmesh.new()
    rings = []
    for i, p in enumerate(points):
        t = (points[min(i + 1, len(points) - 1)] - points[max(i - 1, 0)]).normalized()
        q = t.to_track_quat("Z", "Y").to_matrix()
        ring = []
        for s in range(seg):
            a = math.tau * s / seg
            ring.append(bm.verts.new(p + q @ Vector((math.cos(a), math.sin(a), 0)) * radii[i]))
        rings.append(ring)
    for i in range(len(rings) - 1):
        for s in range(seg):
            a, b = rings[i][s], rings[i][(s + 1) % seg]
            c, d = rings[i + 1][(s + 1) % seg], rings[i + 1][s]
            bm.faces.new([a, b, c, d])
    bm.faces.new(list(reversed(rings[0])))
    bm.faces.new(rings[-1])
    return bm


def T(x=0, y=0, z=0, rx=0, ry=0, rz=0, s=1.0):
    sc = Matrix.Diagonal((s, s, s, 1)) if not isinstance(s, (tuple, list)) else Matrix.Diagonal((s[0], s[1], s[2], 1))
    rot = (Matrix.Rotation(rz, 4, "Z") @ Matrix.Rotation(ry, 4, "Y") @ Matrix.Rotation(rx, 4, "X"))
    return Matrix.Translation((x, y, z)) @ rot @ sc


def shade_up(base, lift=0.18):
    """Colour fn: lighter on top (fake sky light), keeps tint mask in alpha."""
    def fn(co, base=base):
        return base
    return fn


def export(ob, name):
    if ONLY and name not in ONLY: return
    for o in bpy.context.scene.objects: o.select_set(False)
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    ob.name = name
    path = os.path.join(OUT, name + ".glb")
    bpy.ops.export_scene.gltf(
        filepath=path, export_format="GLB", use_selection=True, export_yup=True, export_apply=True,
        export_normals=True, export_tangents=False, export_texcoords=True,
        export_vertex_color="ACTIVE", export_all_vertex_colors=False, export_active_vertex_color_when_no_material=True, export_materials="NONE",
        export_extras=False, export_cameras=False, export_lights=False, export_animations=False,
        export_skins=False, export_morph=False, export_draco_mesh_compression_enable=False)
    tris = sum(len(p.vertices) - 2 for p in ob.data.polygons)
    print("EXPORT %-24s tris=%5d verts=%5d" % (name, tris, len(ob.data.vertices)))
    REPORT.append((name, tris))


REPORT = []


# ---------------------------------------------------------------- island underside
SQ = 5.0  # superellipse exponent, matches WtIslandBuilder.SQUARENESS


def superellipse(a):
    c, s = math.cos(a), math.sin(a)
    return (math.copysign(abs(c) ** (2.0 / SQ), c), math.copysign(abs(s) ** (2.0 / SQ), s))


def underside_profile(t):
    """Radius scale at depth fraction t (0 top .. 1 tip): tapering mass with 4 overhanging strata."""
    strata = 4.0
    k = t * strata
    saw = 1.0 - (k - math.floor(k))          # 1 at the top of each stratum, 0 at its bottom
    taper = (1.0 - t) ** 0.85
    return max(taper * (0.9 + 0.1 * saw ** 2), 0.0)


def build_underside():
    n, rings = 56, 22
    kit = Kit("env_island_underside")
    bm = bmesh.new()
    grid = []
    for r in range(rings + 1):
        t = r / rings
        t2 = t ** 1.15
        z = -t2
        row = []
        for i in range(n):
            a = math.tau * i / n
            x, y = superellipse(a)
            s = underside_profile(t2) if r > 0 else 1.0
            p = Vector((x * s, y * s, z))
            if 0 < r < rings:
                nn = noise.fractal(Vector((x * 2.2, y * 2.2, z * 3.0)), 0.6, 2.0, 3)
                chunk = noise.noise(Vector((math.floor(a * 9.0) * 1.7, math.floor(t * 12.0) * 2.3, 0.4)))
                rad = 1.0 + 0.07 * nn + 0.05 * chunk
                p.x *= rad; p.y *= rad
                p.z += 0.025 * noise.noise(Vector((x * 5.0, y * 5.0, 1.3)))
            row.append(bm.verts.new(p))
        grid.append(row)
    for r in range(rings):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new([grid[r][i], grid[r + 1][i], grid[r + 1][j], grid[r][j]])
    tip = bm.verts.new(Vector((0.03, -0.02, -1.08)))
    for i in range(n):
        bm.faces.new([grid[rings][i], tip, grid[rings][(i + 1) % n]])
    # Stalactite chunks hanging from the lower strata.
    rnd = random.Random(11)
    extra = []
    for k in range(9):
        a = rnd.random() * math.tau
        t = 0.55 + rnd.random() * 0.3
        s = underside_profile(t) * 0.8
        x, y = superellipse(a)
        c = cone(0.07 + rnd.random() * 0.05, 0.0, 0.18 + rnd.random() * 0.16, seg=5)
        bmesh.ops.transform(c, matrix=T(x * s, y * s, -t, rx=math.pi), verts=c.verts)
        extra.append(c)

    def colour(co):
        a = math.atan2(co.y, co.x)
        g = CLIFF.at(a / math.tau * 3.0, -co.z * 1.4)
        moss = 0.0
        if co.z > -0.16:
            moss = 1.0 if co.z > -0.05 - 0.09 * (0.5 + 0.5 * noise.noise(Vector((a * 4.0, 0.3, 0.7)))) else 0.0
        return (1.0, g, moss, 1.0)
    kit.add(bm, None, colour_fn=colour)
    for c in extra:
        kit.add(c, None, colour_fn=lambda co: (1.0, CLIFF.at(co.x * 2, co.z * 2), 0.0, 1.0))
    # Upward-facing ledge tops get a dusting of cover (moss / snow) in the shader.
    ob = kit.finish(sharp_deg=38.0, ao_dist=0.25, ao_strength=0.9)
    me = ob.data
    col = me.color_attributes["Col"]
    for v in me.vertices:
        if v.normal.z > 0.55 and v.co.z < -0.1:
            c = list(col.data[v.index].color); c[2] = max(c[2], 0.6); col.data[v.index].color = c
    return ob


# ---------------------------------------------------------------- lip segments
LIP_LEN = 1.1


def lip_profile(kind):
    """Closed cross-section (y = inward, z = up) for a lip segment. Outward is -Y in Blender."""
    if kind == "snow":
        return [(0.45, 0.02), (0.05, 0.07), (-0.14, 0.05), (-0.26, -0.03), (-0.3, -0.14), (-0.25, -0.25),
                (-0.12, -0.32), (0.1, -0.34), (0.45, -0.3)]
    return [(0.45, 0.0), (0.0, 0.03), (-0.16, 0.02), (-0.25, -0.05), (-0.28, -0.16), (-0.24, -0.28),
            (-0.1, -0.38), (0.12, -0.4), (0.45, -0.32)]


def drip(x, seed):
    """Sum of rounded drips hanging off the lip edge (0..1)."""
    d = 0.0
    rnd = random.Random(seed)
    for _ in range(5):
        c = rnd.uniform(-LIP_LEN * 0.5, LIP_LEN * 0.5); w = rnd.uniform(0.06, 0.13); h = rnd.uniform(0.4, 1.0)
        d = max(d, h * max(0.0, 1.0 - ((x - c) / w) ** 2))
    return d


def build_lip(kind):
    name = "env_lip_" + kind
    kit = Kit(name)
    if kind == "rock":
        rnd = random.Random(5)
        x = -LIP_LEN * 0.5
        while x < LIP_LEN * 0.5:
            w = rnd.uniform(0.22, 0.34)
            h = rnd.uniform(0.32, 0.5)
            b = box(w, 0.6, h)
            bmesh.ops.bevel(b, geom=list(b.edges), offset=0.035, segments=1, affect="EDGES")
            displace(b, 0.03, 4.0, seed=x * 10)
            top = rnd.uniform(-0.02, 0.05)
            m = T(x + w * 0.5, 0.08 + rnd.uniform(-0.06, 0.04), top - h * 0.5, rz=rnd.uniform(-0.15, 0.15),
                  rx=rnd.uniform(-0.08, 0.08))
            kit.add(b, None, transform=m, colour_fn=lambda co, top=top: (1.0, STONE.at(co.x * 1.3, co.z * 1.3),
                                                                          1.0 if co.z > top - 0.03 else 0.0, 1.0))
            x += w * 0.9
        for k in range(3):  # hanging obsidian shards
            c = cone(0.06, 0.0, rnd.uniform(0.2, 0.4), seg=4)
            kit.add(c, None, transform=T(rnd.uniform(-0.45, 0.45), rnd.uniform(-0.05, 0.15), -0.3, rx=math.pi),
                    colour_fn=lambda co: (1.0, 0.3, 0.0, 1.0))
        return kit.finish(sharp_deg=30.0, ao_dist=0.2)
    prof = lip_profile(kind)
    nx = 14
    bm = bmesh.new()
    rows = []
    seed = 3 if kind == "grass" else 9
    for i in range(nx + 1):
        x = -LIP_LEN * 0.5 + LIP_LEN * i / nx
        dr = drip(x, seed)
        row = []
        for (y, z) in prof:
            p = Vector((x, y, z))
            outer = y < -0.1
            if outer and z < -0.02:
                p.z -= dr * (0.16 if kind == "grass" else 0.12) * (1.0 if z < -0.1 else 0.5)
                p.y -= dr * 0.03
            p += noise.noise_vector(Vector((x * 4.0, y * 4.0, z * 4.0 + seed))) * 0.025
            row.append(bm.verts.new(p))
        rows.append(row)
    m = len(prof)
    for i in range(nx):
        for k in range(m):
            k2 = (k + 1) % m
            bm.faces.new([rows[i][k], rows[i][k2], rows[i + 1][k2], rows[i + 1][k]])
    bm.faces.new(list(reversed(rows[0])))
    bm.faces.new(rows[-1])

    def colour(co):
        dr = drip(co.x, seed)
        edge = (-0.2 if kind == "grass" else -0.24) - dr * 0.13
        cover = 1.0 if co.z > edge else 0.0
        return (1.0, CLIFF.at(co.x * 1.5 + 0.3, co.z * 1.5), cover, 1.0)
    kit.add(bm, None, colour_fn=colour)
    rnd = random.Random(seed + 1)
    if kind == "grass":
        for k in range(3):  # roots
            x0 = rnd.uniform(-0.45, 0.45); y0 = rnd.uniform(-0.12, 0.08)
            L = rnd.uniform(0.35, 0.75); curl = rnd.uniform(-0.15, 0.15)
            pts = [Vector((x0 + curl * math.sin(t * 2.5) * t, y0 - 0.04 * t, -0.3 - L * t)) for t in [i / 6 for i in range(7)]]
            kit.add(tube(pts, [0.035 * (1 - t / 7.5) for t in range(7)], seg=5), None,
                    colour_fn=lambda co: (0.55, 0.25, 0.0, 1.0))
        for k in range(2):  # vines with leaves
            x0 = rnd.uniform(-0.45, 0.45)
            L = rnd.uniform(0.4, 0.8)
            pts = [Vector((x0 + 0.05 * math.sin(t * 5.0), -0.24, -0.15 - L * t)) for t in [i / 6 for i in range(7)]]
            kit.add(tube(pts, [0.014] * 7, seg=4), None, colour_fn=lambda co: (0.85, 0.5, 1.0, 1.0))
            for t in range(1, 7):
                leaf = uvs(0.045, seg=6, rings=3)
                bmesh.ops.scale(leaf, vec=Vector((1.0, 0.35, 1.5)), verts=leaf.verts)
                p = pts[t]
                kit.add(leaf, None, transform=T(p.x + (0.04 if t % 2 else -0.04), p.y - 0.01, p.z, ry=(0.6 if t % 2 else -0.6)),
                        colour_fn=lambda co: (0.95, 0.7, 1.0, 1.0))
    else:  # snow: icicles hanging from the drips
        for k in range(6):
            x0 = rnd.uniform(-0.5, 0.5)
            L = rnd.uniform(0.12, 0.32)
            c = cone(0.035, 0.0, L, seg=5)
            kit.add(c, None, transform=T(x0, -0.22, -0.28 - drip(x0, seed) * 0.1, rx=math.pi),
                    colour_fn=lambda co: (1.0, 0.85, 1.0, 1.0))
    return kit.finish(sharp_deg=55.0 if kind == "snow" else 45.0, ao_dist=0.18, ao_strength=0.75)


def build_roots():
    kit = Kit("env_roots")
    rnd = random.Random(21)
    for k in range(5):
        x0 = rnd.uniform(-0.3, 0.3); y0 = rnd.uniform(-0.3, 0.3)
        L = rnd.uniform(0.5, 1.2); ph = rnd.uniform(0, 6)
        pts = [Vector((x0 + 0.12 * math.sin(ph + t * 3.0) * t, y0 + 0.1 * math.cos(ph + t * 2.0) * t, -L * t))
               for t in [i / 7 for i in range(8)]]
        kit.add(tube(pts, [0.05 * (1 - t / 8.5) for t in range(8)], seg=5), None,
                colour_fn=lambda co: (0.55, 0.25, 0.0, 1.0))
    for k in range(3):
        x0 = rnd.uniform(-0.3, 0.3); L = rnd.uniform(0.6, 1.0)
        pts = [Vector((x0, 0.05 * math.sin(t * 6.0), -L * t)) for t in [i / 7 for i in range(8)]]
        kit.add(tube(pts, [0.016] * 8, seg=4), None, colour_fn=lambda co: (0.85, 0.5, 1.0, 1.0))
        for t in range(2, 8):
            leaf = uvs(0.05, seg=6, rings=3)
            bmesh.ops.scale(leaf, vec=Vector((1.0, 0.35, 1.6)), verts=leaf.verts)
            kit.add(leaf, None, transform=T(pts[t].x + (0.045 if t % 2 else -0.045), pts[t].y, pts[t].z),
                    colour_fn=lambda co: (0.95, 0.7, 1.0, 1.0))
    return kit.finish(ao_dist=0.15, ao_strength=0.6)


# ---------------------------------------------------------------- tile and fall
def build_tile():
    kit = Kit("env_tile")
    b = box(0.94, 0.94, 0.14)
    bmesh.ops.bevel(b, geom=list(b.edges), offset=0.045, segments=2, affect="EDGES", profile=0.6)
    bmesh.ops.subdivide_edges(b, edges=[e for e in b.edges if all(v.co.z > 0.06 for v in e.verts)], cuts=2)
    for v in b.verts:
        if v.co.z > 0.06:
            v.co.z += 0.008 * noise.noise(Vector((v.co.x * 6.0, v.co.y * 6.0, 2.0)))
    bmesh.ops.translate(b, vec=Vector((0, 0, -0.07)), verts=b.verts)  # top at z=0
    kit.add(b, None, colour_fn=lambda co: (1.0, STONE.at(co.x * 0.7 + 0.5, co.y * 0.7 + 0.5), 1.0 if co.z > -0.012 else 0.0, 1.0))
    ob = kit.finish(sharp_deg=50.0, ao=False)
    col = ob.data.color_attributes["Col"]
    for v in ob.data.vertices:
        c = list(col.data[v.index].color)
        # Bevel shade: top face full, chamfer slightly lit, sides darker toward the bottom.
        c[0] = 1.0 if v.co.z > -0.012 else (0.92 if v.co.z > -0.05 else 0.7)
        col.data[v.index].color = c
    return ob


def build_fall():
    me = bpy.data.meshes.new("env_fall_ribbon")
    bm = bmesh.new()
    ncols, nrows = 5, 22
    uv_layer = bm.loops.layers.uv.new("UVMap")
    colr = bm.verts.layers.float_color.new("Col")
    grid = []
    for r in range(nrows + 1):
        v = r / nrows
        # Path: a short run over the lip (outward = -Y) then a curved drop of 1 unit (scaled in Godot).
        if v < 0.12:
            k = v / 0.12
            cy, cz = -0.35 * k, 0.03 - 0.03 * k * k
        else:
            k = (v - 0.12) / 0.88
            cy = -0.35 - 0.35 * math.sin(k * math.pi * 0.5) ** 0.7
            cz = -1.0 * k ** 1.3
        width = 0.5 + 0.35 * v
        row = []
        for c in range(ncols + 1):
            u = c / ncols
            x = (u - 0.5) * width
            bulge = -0.05 * math.sin(u * math.pi)
            vert = bm.verts.new(Vector((x, cy + bulge, cz)))
            edge = math.sin(u * math.pi) ** 0.5
            end = min(1.0, (1.0 - v) / 0.25)
            vert[colr] = (1.0, 1.0, 1.0, edge * end)
            row.append((vert, u, v))
        grid.append(row)
    for r in range(nrows):
        for c in range(ncols):
            quad = [grid[r][c], grid[r][c + 1], grid[r + 1][c + 1], grid[r + 1][c]]
            f = bm.faces.new([q[0] for q in quad])
            for loop, q in zip(f.loops, quad):
                loop[uv_layer].uv = (q[1], q[2])
    bm.to_mesh(me); bm.free()
    for p in me.polygons: p.use_smooth = True
    ob = bpy.data.objects.new("env_fall_ribbon", me)
    bpy.context.scene.collection.objects.link(ob)
    set_active_colour(me)
    return ob


# ---------------------------------------------------------------- props
def P(name):
    return Kit(name)


def rgba(h, mask=0.0):
    c = srgb(h); return (c[0], c[1], c[2], mask)


def lit(base_hex, mask, top_lift=0.25, z0=0.0, z1=1.0):
    """Albedo with a soft top-light gradient baked in (stylised painted look)."""
    b = srgb(base_hex)
    def fn(co):
        t = min(max((co.z - z0) / max(z1 - z0, 1e-3), 0.0), 1.0)
        k = 0.82 + top_lift * t
        return (min(b[0] * k, 1), min(b[1] * k, 1), min(b[2] * k, 1), mask)
    return fn


def prop_bush():
    k = P("prop_bush"); rnd = random.Random(1)
    for i in range(5):
        a = i * 1.3; r = 0.17 + rnd.random() * 0.08
        b = ico(r, 2); displace(b, 0.03, 6.0, seed=i)
        bmesh.ops.scale(b, vec=Vector((1, 1, 0.85)), verts=b.verts)
        k.add(b, None, transform=T(math.cos(a) * 0.15 * (i > 0), math.sin(a) * 0.15 * (i > 0), r * 0.8 + (0.08 if i == 0 else 0)),
              colour_fn=lit("#5E9E3A", 1.0, 0.45, 0.0, 0.5))
    for i in range(7):
        a = i * 0.9; f = ico(0.028, 0)
        k.add(f, rgba("#FFF7EC" if i % 2 else "#F6A8C8"), transform=T(math.cos(a) * 0.24, math.sin(a) * 0.24, 0.2 + 0.1 * (i % 3)))
    return k.finish(ao_dist=0.25, ao_bake_rgb=True, sharp_deg=70)


def prop_flowers():
    k = P("prop_flowers"); rnd = random.Random(2)
    for i in range(9):  # grass blades
        c = cone(0.025, 0.0, rnd.uniform(0.12, 0.22), seg=3)
        k.add(c, None, transform=T(rnd.uniform(-0.18, 0.18), rnd.uniform(-0.18, 0.18), 0, rx=rnd.uniform(-0.3, 0.3), ry=rnd.uniform(-0.3, 0.3)),
              colour_fn=lit("#5E9E3A", 1.0, 0.4, 0, 0.2))
    for i in range(3):  # daisies
        x, y = rnd.uniform(-0.15, 0.15), rnd.uniform(-0.15, 0.15); h = rnd.uniform(0.12, 0.2)
        k.add(cone(0.008, 0.008, h, seg=4), rgba("#4E8A30", 1.0), transform=T(x, y, 0))
        for p in range(8):
            a = math.tau * p / 8
            pet = uvs(0.03, seg=6, rings=3); bmesh.ops.scale(pet, vec=Vector((1.0, 0.45, 0.25)), verts=pet.verts)
            k.add(pet, rgba("#FFFDF4"), transform=T(x + math.cos(a) * 0.035, y + math.sin(a) * 0.035, h, rz=a))
        k.add(uvs(0.018, 6, 4), rgba("#F2C14E"), transform=T(x, y, h + 0.008))
    for i in range(2):  # clovers
        x, y = rnd.uniform(-0.15, 0.15), rnd.uniform(-0.15, 0.15)
        for p in range(3):
            a = math.tau * p / 3 + i
            lf = uvs(0.04, 6, 3); bmesh.ops.scale(lf, vec=Vector((1.0, 1.0, 0.3)), verts=lf.verts)
            k.add(lf, None, transform=T(x + math.cos(a) * 0.035, y + math.sin(a) * 0.035, 0.09), colour_fn=lit("#3F8A2E", 1.0))
        k.add(cone(0.006, 0.006, 0.09, seg=3), rgba("#3F7A2A", 1.0), transform=T(x, y, 0))
    return k.finish(ao_dist=0.12, ao_strength=0.5, ao_bake_rgb=True, sharp_deg=80)


def prop_pine_snow():
    k = P("prop_pine_snow")
    k.add(cone(0.06, 0.05, 0.3, seg=6), rgba("#7A5A40"))
    for i in range(3):
        r = 0.42 - i * 0.11; z = 0.2 + i * 0.27; h = 0.42
        c = cone(r, 0.0, h, seg=8); displace(c, 0.015, 8.0, seed=i)
        k.add(c, None, transform=T(0, 0, z, rz=i * 0.4), colour_fn=lit("#2F6B4A", 1.0, 0.2, z, z + h))
        s = cone(r * 0.82, 0.0, h * 0.7, seg=8)
        for v in s.verts:
            if v.co.z < 0.01: v.co.z += 0.035 * math.sin(math.atan2(v.co.y, v.co.x) * 4.0)
        k.add(s, rgba("#F4F8FD"), transform=T(0, 0, z + h * 0.34, rz=i * 0.4 + 0.2))
    return k.finish(ao_dist=0.25, ao_strength=0.5, ao_bake_rgb=True, sharp_deg=50)


def prop_tree():
    k = P("prop_tree"); rnd = random.Random(4)
    k.add(cone(0.09, 0.06, 0.6, seg=7), None, colour_fn=lit("#8B6A48", 0.0, 0.2, 0, 0.6))
    k.add(tube([Vector((0, 0, 0.35)), Vector((0.12, 0, 0.5)), Vector((0.22, 0.02, 0.62))], [0.04, 0.03, 0.02], seg=5), rgba("#8B6A48"))
    for i, (x, y, z, r) in enumerate([(0, 0, 0.9, 0.36), (0.22, 0.05, 0.75, 0.25), (-0.2, 0.08, 0.78, 0.26), (0.02, -0.18, 0.78, 0.25), (0.05, 0.1, 1.12, 0.24)]):
        b = ico(r, 2); displace(b, 0.04, 5.0, seed=i)
        k.add(b, None, transform=T(x, y, z), colour_fn=lit("#4F9A3C", 1.0, 0.4, 0.5, 1.35))
    return k.finish(ao_dist=0.3, ao_bake_rgb=True, sharp_deg=70)


def crystal_shard(r, h):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=6, radius1=r, radius2=r * 0.9, depth=h)
    bmesh.ops.translate(bm, vec=Vector((0, 0, h * 0.5)), verts=bm.verts)
    top = [v for v in bm.verts if v.co.z > h * 0.9]
    tipv = bm.verts.new(Vector((0, 0, h + r * 1.6)))
    topf = [f for f in bm.faces if all(v in top for v in f.verts)]
    bmesh.ops.delete(bm, geom=topf, context="FACES_ONLY")
    ring = sorted(top, key=lambda v: math.atan2(v.co.y, v.co.x))
    for i in range(len(ring)):
        bm.faces.new([ring[i], ring[(i + 1) % len(ring)], tipv])
    return bm


def prop_crystal():
    k = P("prop_crystal"); rnd = random.Random(5)
    spec = [(0, 0, 0.13, 0.55, 0, 0), (0.14, 0.04, 0.08, 0.32, 0.45, 0.2), (-0.13, 0.05, 0.09, 0.38, -0.4, 0.1),
            (0.03, -0.14, 0.07, 0.28, 0.1, -0.5), (-0.05, 0.15, 0.06, 0.22, -0.2, 0.55)]
    for (x, y, r, h, ry, rx) in spec:
        def fn(co, h=h):
            t = max(min(co.z / (h + 0.2), 1.0), 0.0)
            c = (0.72 + 0.28 * t, 0.72 + 0.28 * t, 0.8 + 0.2 * t)
            return (c[0], c[1], c[2], 1.0)
        k.add(crystal_shard(r, h), None, transform=T(x, y, -0.02, rx=rx, ry=ry, rz=rnd.uniform(0, 1)), colour_fn=fn)
    for i in range(4):
        b = ico(0.07, 1); displace(b, 0.02, 8, seed=i)
        k.add(b, None, transform=T(math.cos(i * 1.6) * 0.17, math.sin(i * 1.6) * 0.17, 0.02, s=(1, 1, 0.6)), colour_fn=lit("#6E6878", 0.0))
    return k.finish(sharp_deg=20, ao_dist=0.15, ao_strength=0.5, ao_bake_rgb=True)


def prop_coral():
    k = P("prop_coral"); rnd = random.Random(6)
    def branch(p, d, L, r, depth):
        pts = [p + d * L * t + Vector((0, 0, 0.04 * math.sin(t * 3))) for t in (0, 0.33, 0.66, 1.0)]
        k.add(tube(pts, [r, r * 0.92, r * 0.85, r * 0.75], seg=6), None, colour_fn=lit("#C46FB8", 1.0, 0.35, 0, 0.7))
        end = pts[-1]
        k.add(uvs(r * 0.8, 6, 4), None, transform=T(end.x, end.y, end.z), colour_fn=lit("#E39BD6", 1.0))
        if depth > 0:
            for s in (-1, 1):
                nd = (d + Vector((s * 0.55, rnd.uniform(-0.3, 0.3), 0.2))).normalized()
                branch(pts[2], nd, L * 0.7, r * 0.75, depth - 1)
    branch(Vector((0, 0, 0)), Vector((0, 0, 1)), 0.3, 0.05, 2)
    for i in range(5):
        b = ico(0.05, 1); displace(b, 0.015, 9, seed=i)
        k.add(b, None, transform=T(math.cos(i * 1.3) * 0.16, math.sin(i * 1.3) * 0.16, 0.02, s=(1, 1, 0.7)),
              colour_fn=lit(["#7A7A9A", "#8FA97A", "#B9A6D8"][i % 3], 0.0))
    return k.finish(ao_dist=0.2, ao_strength=0.5, ao_bake_rgb=True, sharp_deg=70)


def prop_kelp():
    k = P("prop_kelp"); rnd = random.Random(7)
    for i in range(5):
        bm = bmesh.new(); rows = []
        x0, y0 = rnd.uniform(-0.12, 0.12), rnd.uniform(-0.12, 0.12)
        H = rnd.uniform(0.6, 1.0); ph = rnd.uniform(0, 6); tw = rnd.uniform(-1, 1)
        for s in range(9):
            t = s / 8; w = 0.06 * math.sin(math.pi * min(t * 1.2 + 0.1, 1.0)) + 0.01
            c = Vector((x0 + 0.08 * math.sin(ph + t * 5.0), y0, H * t)); a = tw * t * 2.0 + i
            dvec = Vector((math.cos(a), math.sin(a), 0)) * w
            rows.append((bm.verts.new(c - dvec), bm.verts.new(c + dvec), bm.verts.new(c - dvec), bm.verts.new(c + dvec)))
        for s in range(8):
            bm.faces.new([rows[s][0], rows[s][1], rows[s + 1][1], rows[s + 1][0]])
            bm.faces.new([rows[s][3], rows[s][2], rows[s + 1][2], rows[s + 1][3]])  # back side, own verts
        k.add(bm, None, colour_fn=lit("#5E8F4A", 1.0, 0.45, 0, 1.0))
    for i in range(4):
        b = ico(0.05, 1)
        k.add(b, None, transform=T(math.cos(i * 1.7) * 0.13, math.sin(i * 1.7) * 0.13, 0.02, s=(1, 1, 0.6)), colour_fn=lit("#8A86A8", 0.0))
    return k.finish(ao=False, sharp_deg=80, merge=False)


def prop_shell():
    k = P("prop_shell")
    bm = bmesh.new(); n, m = 13, 6; grid = []
    for i in range(m + 1):
        r = 0.04 + 0.22 * i / m; row = []
        for j in range(n + 1):
            a = math.pi * (0.08 + 0.84 * j / n)
            rib = 0.012 * math.cos(j * math.pi) * (i / m)
            row.append(bm.verts.new(Vector((math.cos(a) * r, -0.05 + math.sin(a) * r * 0.9, 0.02 + (r + rib) * 0.55 * math.sin(a) ** 0.5))))
        grid.append(row)
    for i in range(m):
        for j in range(n):
            bm.faces.new([grid[i][j], grid[i][j + 1], grid[i + 1][j + 1], grid[i + 1][j]])
    k.add(bm, None, colour_fn=lambda co: (0.95, 0.82 - co.y * 0.3, 0.88, 0.0))
    k.add(uvs(0.05, 8, 6), rgba("#F4EEF8"), transform=T(0.12, -0.12, 0.05))
    for i in range(3):
        k.add(ico(0.045, 1), None, transform=T(-0.15 + i * 0.1, -0.16, 0.02, s=(1, 1, 0.6)), colour_fn=lit("#9A92B8", 0.0))
    return k.finish(ao_dist=0.12, ao_strength=0.4, ao_bake_rgb=True, sharp_deg=80)


def prop_mushroom():
    k = P("prop_mushroom")
    for i, (x, y, s) in enumerate([(0, 0, 1.0), (0.16, 0.06, 0.65), (-0.12, 0.1, 0.5)]):
        k.add(cone(0.05 * s, 0.04 * s, 0.26 * s, seg=7), rgba("#F4EAD8"), transform=T(x, y, 0))
        cap = uvs(0.17 * s, 10, 6)
        for v in cap.verts:
            if v.co.z < 0: v.co.z *= 0.2
        bmesh.ops.scale(cap, vec=Vector((1, 1, 0.75)), verts=cap.verts)
        k.add(cap, None, transform=T(x, y, 0.25 * s), colour_fn=lit("#D9534F", 1.0, 0.3, 0.2 * s, 0.4 * s))
        for d in range(5):
            a = d * 1.25 + i
            k.add(uvs(0.022 * s, 6, 3), rgba("#FFF7EC"), transform=T(x + math.cos(a) * 0.09 * s, y + math.sin(a) * 0.09 * s, 0.25 * s + 0.1 * s, s=(1, 1, 0.5)))
    return k.finish(ao_dist=0.15, ao_strength=0.5, ao_bake_rgb=True, sharp_deg=70)


def prop_rock():
    k = P("prop_rock")
    for i, (x, y, r, sz) in enumerate([(0, 0, 0.24, 0.65), (0.22, 0.08, 0.13, 0.7), (-0.18, 0.12, 0.1, 0.8)]):
        b = ico(r, 2); displace(b, r * 0.25, 3.0 / r * 0.25, seed=i + 3)
        bmesh.ops.scale(b, vec=Vector((1.15, 1.0, sz)), verts=b.verts)
        k.add(b, None, transform=T(x, y, r * sz * 0.7, rz=i), colour_fn=lambda co: (0.85 + 0.15 * STONE.at(co.x * 2, co.y * 2),) * 3 + (1.0,))
    return k.finish(sharp_deg=28, ao_dist=0.2, ao_strength=0.6, ao_bake_rgb=True)


def prop_gear():
    k = P("prop_gear")
    teeth, r0, r1, th = 12, 0.32, 0.4, 0.09
    bm = bmesh.new(); outer = []; inner = []
    steps = teeth * 4
    for i in range(steps):
        a = math.tau * i / steps
        r = r1 if (i % 4) in (1, 2) else r0
        outer.append((math.cos(a) * r, math.sin(a) * r)); inner.append((math.cos(a) * 0.22, math.sin(a) * 0.22))
    def ringify(pts_a, pts_b, z0, z1):
        A0 = [bm.verts.new((x, y, z0)) for x, y in pts_a]; A1 = [bm.verts.new((x, y, z1)) for x, y in pts_a]
        B0 = [bm.verts.new((x, y, z0)) for x, y in pts_b]; B1 = [bm.verts.new((x, y, z1)) for x, y in pts_b]
        n = len(pts_a)
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new([A0[i], A0[j], A1[j], A1[i]])
            bm.faces.new([B1[i], B1[j], B0[j], B0[i]])
            bm.faces.new([A1[i], A1[j], B1[j], B1[i]])
            bm.faces.new([B0[i], B0[j], A0[j], A0[i]])
    ringify(outer, inner, -th * 0.5, th * 0.5)
    k.add(bm, None, colour_fn=lambda co: (0.86, 0.66, 0.3, 0.0) if abs(co.z) < th * 0.49 else (0.95, 0.76, 0.38, 0.0))
    for s in range(4):
        k.add(box(0.36, 0.06, 0.06), rgba("#C08A3C"), transform=T(math.cos(s * math.pi / 4) * 0.08 * 0, 0, 0, rz=s * math.pi / 4))
    hub = cone(0.08, 0.08, 0.14, seg=10)
    k.add(hub, rgba("#8A6A3A"), transform=T(0, 0, -0.07))
    return k.finish(sharp_deg=35, ao_dist=0.1, ao_strength=0.4, ao_bake_rgb=True)


def prop_lollipop():
    k = P("prop_lollipop")
    k.add(cone(0.02, 0.02, 0.7, seg=6), rgba("#FFF7EC"))
    bm = bmesh.new(); bmesh.ops.create_circle(bm, cap_ends=True, segments=20, radius=0.25)
    bmesh.ops.triangulate(bm, faces=bm.faces)
    ext = bmesh.ops.extrude_face_region(bm, geom=list(bm.faces))
    bmesh.ops.translate(bm, vec=Vector((0, 0, 0.09)), verts=[v for v in ext["geom"] if isinstance(v, bmesh.types.BMVert)])
    def swirl(co):
        a = math.atan2(co.y, co.x); r = math.hypot(co.x, co.y)
        s = 0.5 + 0.5 * math.sin(a * 2.0 + r * 30.0)
        return (1.0, 0.55 + 0.45 * s, 0.7 + 0.3 * s, 1.0 - s)
    k.add(bm, None, transform=T(0, 0.045, 0.85, rx=math.pi / 2), colour_fn=swirl)
    return k.finish(sharp_deg=50, ao=False)


def prop_pillar():
    k = P("prop_pillar")
    k.add(box(0.36, 0.36, 0.08), rgba("#E2C26A"), transform=T(0, 0, 0.04))
    col = cone(0.13, 0.12, 0.85, seg=12)
    for v in col.verts:
        a = math.atan2(v.co.y, v.co.x)
        f = 1.0 - 0.06 * (1 if int(round(a / (math.tau / 12))) % 2 else 0)
        v.co.x *= f; v.co.y *= f
        if v.co.z > 0.8: v.co.z -= 0.12 * (0.5 + 0.5 * math.sin(a * 2.0))  # broken top
    k.add(col, None, transform=T(0, 0, 0.08), colour_fn=lit("#EFE9DC", 1.0, 0.2, 0, 1))
    k.add(box(0.3, 0.3, 0.06), rgba("#E2C26A"), transform=T(0, 0, 0.16))
    return k.finish(sharp_deg=35, ao_dist=0.15, ao_strength=0.4, ao_bake_rgb=True)


def prop_star():
    k = P("prop_star")
    bm = bmesh.new(); pts = []
    for i in range(10):
        a = math.tau * i / 10 + math.pi / 2; r = 0.3 if i % 2 == 0 else 0.13
        pts.append((math.cos(a) * r, math.sin(a) * r))
    c0 = bm.verts.new((0, 0, 0.06)); c1 = bm.verts.new((0, 0, -0.06))
    ring = [bm.verts.new((x, y, 0)) for x, y in pts]
    for i in range(10):
        j = (i + 1) % 10
        bm.faces.new([c0, ring[i], ring[j]]); bm.faces.new([c1, ring[j], ring[i]])
    k.add(bm, None, transform=T(0, 0, 0.42, rx=math.pi / 2), colour_fn=lambda co: (1.0, 0.86, 0.45, 1.0))
    k.add(cone(0.015, 0.015, 0.16, seg=4), rgba("#E2C26A"))
    k.add(ico(0.06, 1), rgba("#B9A6E0"), transform=T(0, 0, 0.02, s=(1.4, 1.4, 0.5)))
    return k.finish(sharp_deg=20, ao=False)


def prop_palm():
    k = P("prop_palm")
    pts = [Vector((0.1 * math.sin(t * 1.4), 0, 1.0 * t)) for t in [i / 6 for i in range(7)]]
    for i in range(6):
        k.add(cone(0.07 - i * 0.006, 0.055 - i * 0.006, 0.17, seg=6), None,
              transform=T(pts[i].x, 0, pts[i].z), colour_fn=lit("#A57A50", 0.0))
    top = pts[-1]
    for i in range(6):
        a = math.tau * i / 6
        leaf = bmesh.new(); rows = []
        for s in range(6):
            t = s / 5; w = 0.09 * math.sin(math.pi * min(t + 0.15, 1))
            c = Vector((math.cos(a) * 0.5 * t, math.sin(a) * 0.5 * t, -0.25 * t * t + 0.06 * t))
            side = Vector((-math.sin(a), math.cos(a), 0)) * w
            rows.append((leaf.verts.new(c - side), leaf.verts.new(c + side), leaf.verts.new(c - side), leaf.verts.new(c + side)))
        for s in range(5):
            leaf.faces.new([rows[s][0], rows[s][1], rows[s + 1][1], rows[s + 1][0]])
            leaf.faces.new([rows[s][3], rows[s][2], rows[s + 1][2], rows[s + 1][3]])
        k.add(leaf, None, transform=T(top.x, top.y, top.z), colour_fn=lit("#5E9A3E", 1.0))
    return k.finish(ao=False, sharp_deg=70, merge=False)


def prop_pot():
    k = P("prop_pot")
    bm = bmesh.new(); prof = [(0.06, 0), (0.17, 0.05), (0.21, 0.17), (0.17, 0.3), (0.09, 0.36), (0.11, 0.42)]
    n = 12; rings = []
    for r, z in prof:
        rings.append([bm.verts.new((math.cos(math.tau * i / n) * r, math.sin(math.tau * i / n) * r, z)) for i in range(n)])
    for a in range(len(rings) - 1):
        for i in range(n):
            j = (i + 1) % n
            bm.faces.new([rings[a][i], rings[a][j], rings[a + 1][j], rings[a + 1][i]])
    bm.faces.new(list(reversed(rings[0])))
    k.add(bm, None, colour_fn=lambda co: (0.78, 0.45, 0.18, 1.0) if not (0.15 < co.z < 0.2) else (0.95, 0.85, 0.6, 0.0))
    return k.finish(sharp_deg=50, ao=False)


def prop_balloon():
    k = P("prop_balloon")
    for i, (x, y, h, c) in enumerate([(0, 0, 0.95, "#E98AA6"), (0.14, 0.05, 0.8, "#9CC3DE"), (-0.12, 0.06, 0.85, "#EDC873")]):
        b = uvs(0.12, 10, 7); bmesh.ops.scale(b, vec=Vector((1, 1, 1.2)), verts=b.verts)
        k.add(b, None, transform=T(x, y, h), colour_fn=lit(c, 1.0 if i == 0 else 0.0, 0.3, h - 0.15, h + 0.15))
        k.add(tube([Vector((0, 0, 0.0)), Vector((x * 0.5, y * 0.5, h * 0.5)), Vector((x, y, h - 0.14))], [0.006] * 3, seg=3), rgba("#FFF7EC"))
    k.add(ico(0.08, 1), rgba("#B9937A"), transform=T(0, 0, 0.03, s=(1, 1, 0.5)))
    return k.finish(ao=False, sharp_deg=70)


# ---------------------------------------------------------------- render (contact sheet for review)
def render_sheet(objs, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    scn = bpy.context.scene
    scn.render.engine = "CYCLES"; scn.cycles.device = "CPU"; scn.cycles.samples = 24
    scn.render.resolution_x = 320; scn.render.resolution_y = 320; scn.render.film_transparent = True
    scn.view_settings.view_transform = "Standard"
    world = bpy.data.worlds.new("w"); scn.world = world; world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[1].default_value = 0.8
    sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN")); sun.data.energy = 3.0
    sun.rotation_euler = (math.radians(50), 0, math.radians(30)); scn.collection.objects.link(sun)
    mat = bpy.data.materials.new("vc"); mat.use_nodes = True
    nt = mat.node_tree; attr = nt.nodes.new("ShaderNodeVertexColor"); attr.layer_name = "Col"
    nt.links.new(attr.outputs["Color"], nt.nodes["Principled BSDF"].inputs["Base Color"])
    cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); scn.collection.objects.link(cam); scn.camera = cam
    cam.data.type = "ORTHO"
    for ob in objs: ob.hide_render = True
    for ob in objs:
        ob.hide_render = False
        ob.data.materials.clear(); ob.data.materials.append(mat)
        bb = [ob.matrix_world @ Vector(c) for c in ob.bound_box]
        lo = Vector((min(v.x for v in bb), min(v.y for v in bb), min(v.z for v in bb)))
        hi = Vector((max(v.x for v in bb), max(v.y for v in bb), max(v.z for v in bb)))
        c = (lo + hi) * 0.5; size = max((hi - lo).length, 0.1)
        cam.data.ortho_scale = size * 1.05
        d = Vector((1.0, -1.3, 0.8)).normalized()
        cam.location = c + d * size * 3
        cam.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()
        scn.render.filepath = os.path.join(out_dir, ob.name + ".png")
        bpy.ops.render.render(write_still=True)
        ob.hide_render = True


# ---------------------------------------------------------------- main
def main():
    reset()
    builders = [
        ("env_island_underside", build_underside), ("env_lip_grass", lambda: build_lip("grass")),
        ("env_lip_snow", lambda: build_lip("snow")), ("env_lip_rock", lambda: build_lip("rock")),
        ("env_roots", build_roots), ("env_tile", build_tile), ("env_fall_ribbon", build_fall),
        ("prop_bush", prop_bush), ("prop_flowers", prop_flowers), ("prop_pine_snow", prop_pine_snow),
        ("prop_tree", prop_tree), ("prop_crystal", prop_crystal), ("prop_coral", prop_coral),
        ("prop_kelp", prop_kelp), ("prop_shell", prop_shell), ("prop_mushroom", prop_mushroom),
        ("prop_rock", prop_rock), ("prop_gear", prop_gear), ("prop_lollipop", prop_lollipop),
        ("prop_pillar", prop_pillar), ("prop_star", prop_star), ("prop_palm", prop_palm),
        ("prop_pot", prop_pot), ("prop_balloon", prop_balloon),
    ]
    objs = []
    for name, fn in builders:
        if ONLY and name not in ONLY: continue
        ob = fn(); export(ob, name); objs.append(ob)
    print("KIT", len(REPORT), "assets, total tris", sum(t for _, t in REPORT))
    if RENDER:
        render_sheet(objs, RENDER)


main()
