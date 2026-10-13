"""Wacky Towers UI kit v2: builds and renders every storybook nine-patch piece in one run.

Run headless (Cycles CPU):
  blender -b -P assets/source/blender/ui/build_ui_kit.py -- <repo_root> [piece ...]

Every piece is procedural (curves + painted node materials). No third-party textures.
Renders RGBA PNGs at 2x into assets/art/ui/kit/x2/ and writes margins_x2.json beside them.
Units: 1 Blender unit = 100 px at 2x. Camera is orthographic, looking straight down (-Z);
image right = +X, image up = +Y. Light comes from the top-left, like the references.
Art bible: design/art/art-bible.md sections 2 and 4. Style notes: production/qa/evidence/ui-kit-v2/.
"""
import bpy, math, sys, os, json, random
from mathutils import Vector

ARGV = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
ROOT = ARGV[0] if ARGV else os.getcwd()
ONLY = set(ARGV[1:])
OUT = os.path.join(ROOT, "assets/art/ui/kit/x2")
SAMPLES = 24

# Art-bible tokens (section 2).
HEX = {
    "wood_purple": "6b4a8a", "wood_purple_dark": "3f2a55", "wood_purple_light": "9a78b8",
    "wood_brown": "8a5a34", "wood_brown_dark": "4e2f1a", "wood_brown_light": "c08a55",
    "parchment": "f6e7c4", "parchment_shade": "e2c995", "burn": "9a6a3a",
    "gold": "f8c840", "gold_deep": "c98418", "gold_glint": "fff3b0",
    "vine": "4f9a3a", "leaf_light": "8fd05a", "blossom": "fff6f0", "blossom_c": "ffd34d",
    "red": "e0483c", "red_dark": "8e1f22", "green": "4cc04a", "green_dark": "2c7a2e",
    "cream": "fff4dc", "steel": "6d6585", "steel_dark": "3b3550",
    "ice": "8cc3ea", "ice_dark": "3f78ad", "snow": "f4fbff",
    "cel": "4a3a8e", "cel_dark": "231a52",
}


def col(name_or_hex, a=1.0):
    h = HEX.get(name_or_hex, name_or_hex)
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4) for x in c) + (a,)


# ---------------------------------------------------------------- scene
def reset(w_px, h_px):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = SAMPLES
    sc.cycles.use_denoising = True
    sc.cycles.max_bounces = 4
    sc.render.film_transparent = True
    sc.render.resolution_x, sc.render.resolution_y = w_px, h_px
    sc.render.resolution_percentage = 100
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"
    sc.view_settings.view_transform = "Standard"
    sc.view_settings.look = "None"
    sc.view_settings.exposure = 0.0
    world = bpy.data.worlds.new("w")
    sc.world = world
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = col("e8dcf4")
    world.node_tree.nodes["Background"].inputs[1].default_value = 0.55
    cam_d = bpy.data.cameras.new("cam")
    cam_d.type = "ORTHO"
    cam_d.ortho_scale = max(w_px, h_px) / 100.0
    cam = bpy.data.objects.new("cam", cam_d)
    cam.location = (0, 0, 20)
    sc.collection.objects.link(cam)
    sc.camera = cam
    sun_d = bpy.data.lights.new("sun", "SUN")
    sun_d.energy = 3.2
    sun_d.angle = math.radians(14)
    sun_d.color = col("fff1dc")[:3]
    sun = bpy.data.objects.new("sun", sun_d)
    sun.rotation_euler = (math.radians(-32), math.radians(-14), 0)  # from top-left, shadow falls down
    sc.collection.objects.link(sun)
    # Shadow catcher gives each piece a soft plum drop shadow in the alpha.
    bpy.ops.mesh.primitive_plane_add(size=60, location=(0, 0, -0.02))
    bpy.context.active_object.is_shadow_catcher = True
    return sc


def link(o):
    bpy.context.scene.collection.objects.link(o)
    return o


# ---------------------------------------------------------------- geometry
def rr_pts(w, h, r, seg=10, cx=0.0, cy=0.0):
    r = min(r, w / 2 - 1e-4, h / 2 - 1e-4)
    pts = []
    for (ox, oy, a0) in ((w / 2 - r, h / 2 - r, 0), (-w / 2 + r, h / 2 - r, 90),
                         (-w / 2 + r, -h / 2 + r, 180), (w / 2 - r, -h / 2 + r, 270)):
        for i in range(seg + 1):
            a = math.radians(a0 + 90 * i / seg)
            pts.append((cx + ox + r * math.cos(a), cy + oy + r * math.sin(a)))
    return pts


def star_pts(ro, ri, n=5, rot=90.0, cx=0.0, cy=0.0):
    pts = []
    for i in range(n * 2):
        a = math.radians(rot + i * 180.0 / n)
        rr = ro if i % 2 == 0 else ri
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    return pts


def slab(name, loops, depth, bevel, z=0.0, mat=None, bev_res=5):
    """Filled 2D curve (outer loop + optional hole loops) extruded with a rounded bevel.
    Loops are pre-shrunk by `bevel` so the outer silhouette matches the given points."""
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "2D"
    cu.fill_mode = "BOTH"
    cu.extrude = max(depth / 2 - bevel, 0.0)
    cu.bevel_depth = bevel
    cu.bevel_resolution = bev_res
    cu.offset = 0.0
    for pts in loops:
        sp = cu.splines.new("POLY")
        sp.points.add(len(pts) - 1)
        for p, (x, y) in zip(sp.points, pts):
            p.co = (x, y, 0, 1)
        sp.use_cyclic_u = True
        sp.use_smooth = True
    o = link(bpy.data.objects.new(name, cu))
    o.location.z = z + depth / 2
    if mat: cu.materials.append(mat)
    return o


def shrink(pts, d):
    """Offset a convex-ish loop toward its centroid by d (good enough for rounded rects)."""
    cx = sum(p[0] for p in pts) / len(pts)
    cy = sum(p[1] for p in pts) / len(pts)
    out = []
    n = len(pts)
    for i in range(n):
        x0, y0 = pts[i - 1]; x1, y1 = pts[i]; x2, y2 = pts[(i + 1) % n]
        nx, ny = (y2 - y0), -(x2 - x0)
        l = math.hypot(nx, ny) or 1
        nx, ny = nx / l, ny / l
        if (x1 - cx) * nx + (y1 - cy) * ny < 0: nx, ny = -nx, -ny
        out.append((x1 - nx * d, y1 - ny * d))
    return out


def rslab(name, w, h, r, depth, bevel, z=0.0, mat=None, cx=0.0, cy=0.0):
    return slab(name, [rr_pts(w - 2 * bevel, h - 2 * bevel, max(r - bevel, 0.01), cx=cx, cy=cy)], depth, bevel, z, mat)


def tube(name, pts3, radius, mat=None, cyclic=False, tilt_step=0.0, bevel_obj=None, taper=None):
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_mode = "OBJECT" if bevel_obj else "ROUND"
    if bevel_obj: cu.bevel_object = bevel_obj
    else: cu.bevel_depth = radius
    cu.bevel_resolution = 4
    cu.use_fill_caps = True
    sp = cu.splines.new("POLY")
    sp.points.add(len(pts3) - 1)
    for i, (p, c) in enumerate(zip(sp.points, pts3)):
        p.co = (c[0], c[1], c[2], 1)
        p.tilt = i * tilt_step
        if taper: p.radius = taper(i / max(len(pts3) - 1, 1))
    sp.use_cyclic_u = cyclic
    sp.use_smooth = True
    o = link(bpy.data.objects.new(name, cu))
    if mat: cu.materials.append(mat)
    return o


def ellipsoid(name, loc, scale, mat, rot_z=0.0, seg=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=seg, ring_count=seg // 2, location=loc)
    o = bpy.context.active_object
    o.name = name
    o.scale = scale
    o.rotation_euler.z = rot_z
    bpy.ops.object.shade_smooth()
    o.data.materials.append(mat)
    return o


# ---------------------------------------------------------------- painted materials
class NT:
    def __init__(self, name):
        self.m = bpy.data.materials.new(name)
        self.m.use_nodes = True
        self.t = self.m.node_tree
        self.t.nodes.clear()
        self.out = self.n("ShaderNodeOutputMaterial")
        self.bsdf = self.n("ShaderNodeBsdfPrincipled")
        self.l(self.bsdf, 0, self.out, 0)

    def n(self, kind, **kw):
        node = self.t.nodes.new(kind)
        for k, v in kw.items():
            if k.startswith("in_"):
                node.inputs[int(k[3:]) if k[3:].isdigit() else k[3:]].default_value = v
            else:
                setattr(node, k, v)
        return node

    def l(self, a, ao, b, bi):
        self.t.links.new(a.outputs[ao], b.inputs[bi])

    def math(self, op, a, b=None, clamp=False):
        node = self.n("ShaderNodeMath", operation=op, use_clamp=clamp)
        for i, v in enumerate((a, b)):
            if v is None: continue
            if isinstance(v, (int, float)): node.inputs[i].default_value = v
            else: self.l(v[0], v[1], node, i)
        return (node, 0)

    def ramp(self, fac, stops):
        r = self.n("ShaderNodeValToRGB")
        cr = r.color_ramp
        cr.elements[0].position, cr.elements[0].color = stops[0][0], col(stops[0][1])
        cr.elements[1].position, cr.elements[1].color = stops[-1][0], col(stops[-1][1])
        for p, c in stops[1:-1]:
            e = cr.elements.new(p)
            e.color = col(c)
        self.l(fac[0], fac[1], r, 0)
        return (r, 0)

    def mix(self, fac, a, b):
        m = self.n("ShaderNodeMix", data_type="RGBA")
        for idx, v in ((0, fac), (6, a), (7, b)):
            if isinstance(v, tuple) and len(v) == 2 and not isinstance(v[0], float):
                self.l(v[0], v[1], m, idx)
            elif isinstance(v, (int, float)): m.inputs[idx].default_value = v
            else: m.inputs[idx].default_value = v
        return (m, 2)

    def painted_edges(self, base, light, dark, strength=1.0):
        """Toon-like lit top edge / shaded bottom edge from the normal (the 'painted' bevel)."""
        geo = self.n("ShaderNodeNewGeometry")
        sep = self.n("ShaderNodeSeparateXYZ")
        self.l(geo, "Normal", sep, 0)
        up = self.math("MULTIPLY", (sep, 1), 1.0)
        lit = self.math("MULTIPLY", self.math("ADD", up, self.math("MULTIPLY", (sep, 0), -0.4)), 1.6 * strength, clamp=True)
        shade = self.math("MULTIPLY", self.math("ADD", self.math("MULTIPLY", (sep, 1), -1.0), self.math("MULTIPLY", (sep, 0), 0.4)), 1.4 * strength, clamp=True)
        c = self.mix(lit, base, col(light))
        return self.mix(shade, c, col(dark))

    def obj_coords(self, scale=(1, 1, 1)):
        tc = self.n("ShaderNodeTexCoord")
        mp = self.n("ShaderNodeMapping")
        mp.inputs["Scale"].default_value = scale
        self.l(tc, "Object", mp, 0)
        return (mp, 0)

    def finish(self, color, rough=0.55, coat=0.0, bump=None, bump_strength=0.25, spec=0.35):
        self.l(color[0], color[1], self.bsdf, "Base Color")
        self.bsdf.inputs["Roughness"].default_value = rough
        self.bsdf.inputs["Specular IOR Level"].default_value = spec
        if coat:
            self.bsdf.inputs["Coat Weight"].default_value = coat
            self.bsdf.inputs["Coat Roughness"].default_value = 0.12
        if bump is not None:
            b = self.n("ShaderNodeBump", in_Strength=bump_strength, in_Distance=0.02)
            self.l(bump[0], bump[1], b, "Height")
            self.l(b, "Normal", self.bsdf, "Normal")
        return self.m


def mat_wood(name, palette=("wood_purple_dark", "wood_purple", "wood_purple_light"), grain="X", seed=0.0, grain_scale=1.0):
    t = NT(name)
    sc = (0.35 * grain_scale, 4.0 * grain_scale, 1) if grain == "X" else (4.0 * grain_scale, 0.35 * grain_scale, 1)
    co = t.obj_coords(sc)
    noise = t.n("ShaderNodeTexNoise", in_Scale=1.6, in_Detail=3.0, in_Roughness=0.5)
    noise.noise_dimensions = "4D"
    noise.inputs["W"].default_value = seed
    t.l(co[0], 0, noise, "Vector")
    wave = t.n("ShaderNodeTexWave", wave_type="BANDS", bands_direction="Y" if grain == "X" else "X",
               in_Scale=1.3, in_Distortion=7.0, in_Detail=2.0)
    t.l(co[0], 0, wave, "Vector")
    g = t.math("MULTIPLY", (wave, "Fac"), (noise, "Fac"))
    g = t.math("ADD", g, 0.25)
    base = t.ramp(g, [(0.15, palette[0]), (0.42, palette[1]), (0.7, palette[1]), (0.95, palette[2])])
    colr = t.painted_edges(base, palette[2], palette[0])
    return t.finish(colr, rough=0.6, bump=(wave, "Fac"), bump_strength=0.35)


def mat_gold(name="gold", face="gold", deep="gold_deep", glint="gold_glint", coat=0.7):
    t = NT(name)
    co = t.obj_coords((1.5, 1.5, 1.5))
    noise = t.n("ShaderNodeTexNoise", in_Scale=2.0, in_Detail=2.0)
    t.l(co[0], 0, noise, "Vector")
    base = t.ramp((noise, "Fac"), [(0.3, deep), (0.55, face), (0.75, face)])
    colr = t.painted_edges(base, glint, deep, strength=1.2)
    return t.finish(colr, rough=0.32, coat=coat, spec=0.6)


def mat_plain(name, c_mid, c_light, c_dark, rough=0.5, coat=0.0, noise_amt=0.0, edge=1.0):
    t = NT(name)
    base = col(c_mid)
    if noise_amt:
        co = t.obj_coords((2.5, 2.5, 2.5))
        noise = t.n("ShaderNodeTexNoise", in_Scale=1.5, in_Detail=3.0)
        t.l(co[0], 0, noise, "Vector")
        f = t.math("MULTIPLY", (noise, "Fac"), noise_amt)
        base = t.mix(f, col(c_mid), col(c_dark))
    colr = t.painted_edges(base, c_light, c_dark, strength=edge)
    return t.finish(colr, rough=rough, coat=coat)


def mat_parchment(name, hw, hh, r, burn_w=0.10):
    """Cream with mottling, warm shaded border and a thin burnt rim, from a rounded-rect SDF
    in object space (hw/hh = half size in Blender units)."""
    t = NT(name)
    tc = t.n("ShaderNodeTexCoord")
    ab = t.n("ShaderNodeVectorMath", operation="ABSOLUTE")
    t.l(tc, "Object", ab, 0)
    sub = t.n("ShaderNodeVectorMath", operation="SUBTRACT")
    sub.inputs[1].default_value = (hw - r, hh - r, 0)
    t.l(ab, 0, sub, 0)
    mx = t.n("ShaderNodeVectorMath", operation="MAXIMUM")
    mx.inputs[1].default_value = (0, 0, 0)
    t.l(sub, 0, mx, 0)
    ln = t.n("ShaderNodeVectorMath", operation="LENGTH")
    t.l(mx, 0, ln, 0)
    d = t.math("SUBTRACT", (ln, "Value"), r)       # <0 inside, 0 at edge
    inside = t.math("MULTIPLY", d, -1.0)              # distance from edge (units)
    co = t.obj_coords((1.2, 1.2, 1.2))
    noise = t.n("ShaderNodeTexNoise", in_Scale=2.2, in_Detail=6.0, in_Roughness=0.6)
    t.l(co[0], 0, noise, "Vector")
    nf = t.math("MULTIPLY", t.math("SUBTRACT", (noise, "Fac"), 0.5), 0.18)
    shade_f = t.math("SUBTRACT", 1.0, t.math("DIVIDE", t.math("ADD", inside, nf), burn_w * 3.2), clamp=True)
    burn_f = t.math("SUBTRACT", 1.0, t.math("DIVIDE", t.math("ADD", inside, t.math("MULTIPLY", nf, 0.4)), burn_w * 0.55), clamp=True)
    mott = t.mix(t.math("MULTIPLY", (noise, "Fac"), 0.35), col("parchment"), col("f1dcb0"))
    c = t.mix(t.math("POWER", shade_f, 1.6), mott, col("parchment_shade"))
    c = t.mix(t.math("POWER", burn_f, 1.3), c, col("burn"))
    c = t.painted_edges(c, "fff8e6", "b88a52", strength=0.6)
    return t.finish(c, rough=0.85, spec=0.15, bump=(noise, "Fac"), bump_strength=0.08)


def mat_streak():
    """White specular streak: emission mixed with transparency, soft at the ends."""
    m = bpy.data.materials.new("streak")
    m.use_nodes = True
    t = m.node_tree
    t.nodes.clear()
    out = t.nodes.new("ShaderNodeOutputMaterial")
    em = t.nodes.new("ShaderNodeEmission")
    em.inputs[0].default_value = col("fffdf2")
    em.inputs[1].default_value = 1.15
    tr = t.nodes.new("ShaderNodeBsdfTransparent")
    mixn = t.nodes.new("ShaderNodeMixShader")
    mixn.inputs[0].default_value = 0.72
    t.links.new(tr.outputs[0], mixn.inputs[1])
    t.links.new(em.outputs[0], mixn.inputs[2])
    t.links.new(mixn.outputs[0], out.inputs[0])
    return m


# ---------------------------------------------------------------- ornaments
def leaf(loc, ang, size, mats):
    x, y, z = loc
    o = ellipsoid("leaf", (x, y, z), (size, size * 0.5, size * 0.28), random.choice(mats), rot_z=ang)
    return o


def blossom(loc, size, mats):
    x, y, z = loc
    for i in range(5):
        a = math.radians(90 + i * 72)
        ellipsoid("petal", (x + math.cos(a) * size * 0.55, y + math.sin(a) * size * 0.55, z),
                  (size * 0.52, size * 0.38, size * 0.2), mats["blossom"], rot_z=a, seg=12)
    ellipsoid("bcen", (x, y, z + size * 0.12), (size * 0.3, size * 0.3, size * 0.22), mats["blossom_c"], seg=12)


def vine(pts2, z, mats, radius=0.035, leaves=6, flowers=(), leaf_size=0.11, seed=1):
    """Curly vine: a tapered tube along pts2 with leaves on alternate sides and blossoms."""
    random.seed(seed)
    pts3 = [(x, y, z + 0.02 * math.sin(i)) for i, (x, y) in enumerate(pts2)]
    tube("vine", pts3, radius, mats["vine"], taper=lambda f: 1.0 - 0.55 * f)
    n = len(pts2)
    for k in range(leaves):
        i = int((k + 0.5) / leaves * (n - 1))
        x0, y0 = pts2[max(i - 1, 0)]; x1, y1 = pts2[min(i + 1, n - 1)]
        ang = math.atan2(y1 - y0, x1 - x0) + (1 if k % 2 else -1) * math.radians(55)
        px, py = pts2[i]
        s = leaf_size * random.uniform(0.8, 1.15)
        leaf((px + math.cos(ang) * s * 0.9, py + math.sin(ang) * s * 0.9, z + 0.03), ang, s, [mats["leaf"], mats["leaf2"]])
    for (fx, fy, fs) in flowers:
        blossom((fx, fy, z + 0.06), fs, mats)


def arc_path(cx, cy, r0, r1, a0, a1, n=24, wobble=0.0):
    pts = []
    for i in range(n):
        f = i / (n - 1)
        a = math.radians(a0 + (a1 - a0) * f)
        r = r0 + (r1 - r0) * f
        pts.append((cx + math.cos(a) * r + wobble * math.sin(f * 9), cy + math.sin(a) * r))
    return pts


def lerp_path(points, n=30, wobble=0.04, freq=3.0):
    out = []
    segs = len(points) - 1
    for i in range(n):
        f = i / (n - 1) * segs
        k = min(int(f), segs - 1)
        u = f - k
        (x0, y0), (x1, y1) = points[k], points[k + 1]
        dx, dy = x1 - x0, y1 - y0
        l = math.hypot(dx, dy) or 1
        w = wobble * math.sin(i / (n - 1) * math.pi * 2 * freq)
        out.append((x0 + dx * u - dy / l * w, y0 + dy * u + dx / l * w))
    return out


def gold_star(cx, cy, z, ro, mat, depth=0.08, rot=90.0):
    return slab("star", [star_pts(ro, ro * 0.48, rot=rot, cx=cx, cy=cy)], depth, min(0.03, ro * 0.18), z, mat, bev_res=3)


def rivet(cx, cy, z, r, mat):
    return ellipsoid("rivet", (cx, cy, z), (r, r, r * 0.6), mat, seg=12)


def common_mats():
    return {
        "vine": mat_plain("vine", "vine", "leaf_light", "2f6a24", rough=0.5),
        "leaf": mat_plain("leaf", "4f9a3a", "a6e06c", "2c6a22", rough=0.45, coat=0.2),
        "leaf2": mat_plain("leaf2", "62ae40", "b5e87a", "33702a", rough=0.45, coat=0.2),
        "blossom": mat_plain("blossom", "blossom", "ffffff", "d8c8d8", rough=0.5),
        "blossom_c": mat_plain("blossom_c", "blossom_c", "fff0a0", "d89a20", rough=0.4),
        "gold": mat_gold(),
        "steel": mat_plain("steel", "steel", "a9a0c4", "steel_dark", rough=0.35, coat=0.3),
    }


def render(name, margins):
    sc = bpy.context.scene
    path = os.path.join(OUT, name + ".png")
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("RENDERED", path)
    return {"left": margins[0], "top": margins[1], "right": margins[2], "bottom": margins[3],
            "w": sc.render.resolution_x, "h": sc.render.resolution_y}


# ---------------------------------------------------------------- pieces
def build_frame_purple(open_center=False):
    reset(512, 512)
    M = common_mats()
    S = 4.8   # frame outer size (units), canvas 5.12
    T = 0.66  # plank thickness in the image (66 px at 2x, 33 px at 1x)
    z = 0.0
    if not open_center:
        hw = S / 2 - T + 0.12
        rslab("parch", hw * 2, hw * 2, 0.18, 0.06, 0.03, z, mat_parchment("parch_in", hw, hw, 0.18, 0.12))
    # Dark inner bevel ring under the planks (frame reads raised over the content).
    inner = rr_pts(S - 2 * T + 0.04, S - 2 * T + 0.04, 0.1)
    outer = rr_pts(S - 2 * T + 0.32, S - 2 * T + 0.32, 0.2)
    slab("bevel", [outer, inner], 0.16, 0.05, z, mat_plain("bev", "wood_purple_dark", "6b4a8a", "1f1430", rough=0.7))
    # Four planks: top/bottom rails overhang the side posts with rounded ends.
    wh = mat_wood("wood_h", grain="X", seed=1.3)
    wv = mat_wood("wood_v", grain="Y", seed=4.1)
    rail_w = S
    for sy in (1, -1):
        cy = sy * (S / 2 - T / 2)
        rslab("rail", rail_w, T, 0.2, 0.34, 0.09, z + 0.06, wh, cy=cy)
        # plank seam
        rslab("seam", rail_w - 0.5, 0.025, 0.012, 0.02, 0.008, z + 0.39, mat_plain("seam", "3f2a55", "3f2a55", "2a1b3a"), cy=cy + sy * 0.05)
    for sx in (1, -1):
        cx = sx * (S / 2 - T / 2 - 0.04)
        rslab("post", T - 0.06, S - 2 * T + 0.2, 0.12, 0.3, 0.08, z + 0.04, wv, cx=cx)
    # Corner caps: steel bracket + gold star + rivets.
    for sx in (1, -1):
        for sy in (1, -1):
            cx, cy = sx * (S / 2 - T / 2 - 0.02), sy * (S / 2 - T / 2)
            rslab("cap", T + 0.18, T + 0.18, 0.16, 0.12, 0.05, z + 0.4, M["steel"], cx=cx, cy=cy)
            gold_star(cx, cy, z + 0.52, 0.27, M["gold"], depth=0.1)
            for (rx, ry) in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
                rivet(cx + rx * (T / 2 + 0.0), cy + ry * (T / 2 + 0.0), z + 0.54, 0.045, M["gold"])
    # Vines from the top-left and bottom-right corners, blossoms near the corners only.
    e = S / 2
    vz = z + 0.62
    vine(lerp_path([(-e + 0.75, e - 0.15), (-e + 1.2, e - 0.35), (-e + 1.65, e - 0.12)], 26, 0.05, 1.5), vz, M,
         leaves=5, flowers=[(-e + 1.05, e - 0.12, 0.1), (-e + 1.5, e - 0.4, 0.085)], seed=3)
    vine(lerp_path([(-e + 0.15, e - 0.75), (-e + 0.35, e - 1.2), (-e + 0.12, e - 1.65)], 26, 0.05, 1.5), vz, M,
         leaves=5, flowers=[(-e + 0.4, e - 1.05, 0.09)], seed=4)
    vine(lerp_path([(e - 0.75, -e + 0.15), (e - 1.2, -e + 0.35), (e - 1.65, -e + 0.12)], 26, 0.05, 1.5), vz, M,
         leaves=5, flowers=[(e - 1.1, -e + 0.12, 0.1), (e - 1.45, -e + 0.42, 0.08)], seed=5)
    vine(lerp_path([(e - 0.15, -e + 0.75), (e - 0.35, -e + 1.2), (e - 0.12, -e + 1.65)], 26, 0.05, 1.5), vz, M,
         leaves=5, flowers=[(e - 0.4, -e + 1.1, 0.09)], seed=6)
    vine(lerp_path([(e - 0.75, e - 0.15), (e - 1.2, e - 0.3), (e - 1.5, e - 0.12)], 22, 0.04, 1.2), vz, M,
         leaves=4, flowers=[(e - 1.1, e - 0.1, 0.09)], seed=7)
    vine(lerp_path([(-e + 0.75, -e + 0.15), (-e + 1.2, -e + 0.3), (-e + 1.5, -e + 0.12)], 22, 0.04, 1.2), vz, M,
         leaves=4, flowers=[(-e + 1.1, -e + 0.1, 0.09)], seed=8)
    m = 186  # 2x px: plank + caps + vines stay in the fixed corners
    return render("frame_purple_open" if open_center else "frame_purple", (m, m, m, m))


def build_panel_parchment():
    reset(256, 256)
    W = 2.36
    rslab("p", W, W, 0.34, 0.12, 0.05, 0.0, mat_parchment("parch", W / 2, W / 2, 0.34, 0.11))
    return render("panel_parchment", (60, 60, 60, 64))


def rope_bevel():
    cu = bpy.data.curves.new("rope_prof", "CURVE")
    cu.dimensions = "2D"
    sp = cu.splines.new("POLY")
    pts = []
    for i in range(36):
        a = 2 * math.pi * i / 36
        r = 0.045 + 0.012 * math.cos(3 * a)
        pts.append((r * math.cos(a), r * math.sin(a)))
    sp.points.add(len(pts) - 1)
    for p, (x, y) in zip(sp.points, pts): p.co = (x, y, 0, 1)
    sp.use_cyclic_u = True
    return link(bpy.data.objects.new("rope_prof", cu))


def build_panel_wood():
    reset(384, 384)
    M = common_mats()
    W = 3.6
    pal = ("wood_brown_dark", "wood_brown", "wood_brown_light")
    back = rslab("back", W, W, 0.3, 0.1, 0.04, 0.0, mat_plain("woodback", "4e2f1a", "6a4024", "2e1a0c"))
    ph = (W - 0.16) / 3
    for i in range(3):
        cy = -W / 2 + 0.08 + ph * (i + 0.5)
        rslab("plank", W - 0.12, ph - 0.035, 0.12, 0.2, 0.05, 0.08, mat_wood("pl%d" % i, pal, "X", seed=i * 2.7), cy=cy)
    prof = rope_bevel()
    path = rr_pts(W - 0.5, W - 0.5, 0.26, seg=14)
    dense = []
    for i in range(len(path)):
        a, b = path[i], path[(i + 1) % len(path)]
        k = max(1, int(math.hypot(b[0] - a[0], b[1] - a[1]) / 0.03))
        for j in range(k):
            dense.append((a[0] + (b[0] - a[0]) * j / k, a[1] + (b[1] - a[1]) * j / k, 0.36))
    tube("rope", dense, 0.05, mat_plain("rope", "d9b27a", "f6deaa", "8a6234", rough=0.8, noise_amt=0.3),
         cyclic=True, tilt_step=0.55, bevel_obj=prof)
    for sx in (1, -1):
        for sy in (1, -1):
            rivet(sx * (W / 2 - 0.13), sy * (W / 2 - 0.13), 0.3, 0.05, M["steel"])
    return render("panel_wood", (72, 72, 72, 76))


def build_plaque_title():
    reset(640, 200)
    M = common_mats()
    W, H = 4.9, 1.24
    rslab("trim", W + 0.16, H + 0.16, H / 2 + 0.08, 0.26, 0.07, 0.0, M["gold"])
    rslab("plaque", W - 0.06, H - 0.1, H / 2 - 0.05, 0.36, 0.1, 0.05, mat_wood("pw", grain="X", seed=2.0, grain_scale=1.4))
    rslab("inset", W - 0.5, H - 0.42, (H - 0.42) / 2, 0.06, 0.03, 0.4, mat_plain("inset", "5a3d77", "7a5a9c", "3f2a55"))
    # gold curls at both ends
    for sx in (1, -1):
        pts = []
        for i in range(40):
            f = i / 39
            a = math.radians(-90 + f * 400) * sx
            r = 0.30 * (1 - 0.7 * f)
            pts.append((sx * (W / 2 + 0.05) + math.cos(a) * r * sx, 0.0 + math.sin(a) * r, 0.42))
        tube("curl", pts, 0.05, M["gold"], taper=lambda f: 1.0 - 0.5 * f)
        tube("curl2", [(sx * (W / 2 - 0.55 + 0.4 * f), 0.5 - 0.08 * math.sin(f * 3.1), 0.43) for f in [i / 15 for i in range(16)]], 0.035, M["gold"])
        tube("curl3", [(sx * (W / 2 - 0.55 + 0.4 * f), -0.5 + 0.08 * math.sin(f * 3.1), 0.43) for f in [i / 15 for i in range(16)]], 0.035, M["gold"])
    # crest
    rslab("crest", 0.7, 0.34, 0.12, 0.16, 0.05, 0.36, M["gold"], cy=H / 2 + 0.02)
    gold_star(0, H / 2 + 0.03, 0.5, 0.15, M["gold"], depth=0.08)
    return render("plaque_title", (150, 64, 150, 64))


def build_pill(name, face, lip, rim, w_px=320, h_px=128, star=False):
    reset(w_px, h_px)
    face, lip, rim = face(), lip(), rim()  # factories: materials must be made after reset()
    W, H = (w_px - 20) / 100, (h_px - 22) / 100
    lip_h = 0.11
    rslab("rim", W, H, H / 2, 0.16, 0.05, 0.0, rim)
    rslab("lip", W - 0.08, H - 0.08, (H - 0.08) / 2, 0.26, 0.07, 0.03, lip)
    fh = H - 0.1 - lip_h
    rslab("face", W - 0.12, fh, fh / 2, 0.24, 0.09, 0.14, face, cy=lip_h / 2 + 0.01)
    sw, sh = W - fh * 0.9, fh * 0.2
    rslab("streak", sw, sh, sh / 2, 0.01, 0.004, 0.39, mat_streak(), cy=lip_h / 2 + fh * 0.24)
    lr = int(round(H * 100 / 2 + 12))
    return render(name, (lr, 44, lr, 54))


def build_btn_close():
    reset(144, 144)
    M = common_mats()
    rslab("rim", 1.26, 1.26, 0.34, 0.2, 0.06, 0.0, M["gold"])
    gem = NT("gem")
    co = gem.obj_coords()
    sep = gem.n("ShaderNodeSeparateXYZ")
    gem.l(co[0], 0, sep, 0)
    f = gem.math("ADD", gem.math("MULTIPLY", (sep, 1), -0.9), 0.5, clamp=True)
    base = gem.mix(f, col("f2665a"), col("b52a2a"))
    c = gem.painted_edges(base, "ff9a88", "6e1418", strength=1.2)
    rslab("gem", 1.04, 1.04, 0.26, 0.3, 0.1, 0.05, gem.finish(c, rough=0.18, coat=1.0, spec=0.7))
    white = mat_plain("x", "ffffff", "ffffff", "d8cdd8", rough=0.4)
    for a in (45, -45):
        o = rslab("xbar", 0.62, 0.15, 0.075, 0.1, 0.04, 0.36, white)
        o.rotation_euler.z = math.radians(a)
    rslab("glint", 0.6, 0.12, 0.06, 0.01, 0.004, 0.48, mat_streak(), cy=0.33)
    return render("btn_close", (48, 48, 48, 48))


BIOME_CHIP = {
    "meadow": dict(pal=("4e2f1a", "8a5a34", "c08a55"), deco="vines"),
    "ice": dict(pal=("ice_dark", "ice", "dff1ff"), deco="frost"),
    "celestial": dict(pal=("cel_dark", "cel", "8a74d8"), deco="stars"),
}


def build_chip(biome, name, size=256, margin=74, slot=False):
    reset(size, size)
    M = common_mats()
    cfg = BIOME_CHIP[biome]
    S = (size - 18) / 100
    T = 0.3 if not slot else 0.24
    frame_m = mat_wood("chipwood_" + biome, cfg["pal"], "X", seed=len(biome), grain_scale=1.6) if biome != "ice" else \
        mat_plain("frost", cfg["pal"][1], cfg["pal"][2], cfg["pal"][0], rough=0.25, coat=0.6, noise_amt=0.35)
    outer = rr_pts(S, S, 0.32)
    inner = rr_pts(S - 2 * T, S - 2 * T, 0.18)
    slab("frame", [shrink(outer, 0.06), shrink(inner, -0.06)], 0.34, 0.06, 0.0, frame_m)
    pw = S - 2 * T + 0.14
    rslab("parch", pw, pw, 0.2, 0.08, 0.03, 0.0, mat_parchment("chip_p_" + biome, pw / 2, pw / 2, 0.2, 0.07))
    e = S / 2
    if biome == "celestial":
        trim = rr_pts(S - T + 0.02, S - T + 0.02, 0.24)
        slab("trim", [shrink(trim, 0.0), shrink(trim, 0.05)], 0.06, 0.02, 0.33, M["gold"])
        for sx in (1, -1):
            for sy in (1, -1):
                gold_star(sx * (e - T / 2), sy * (e - T / 2), 0.36, 0.13, M["gold"], depth=0.07)
    elif biome == "ice":
        snow = mat_plain("snow", "snow", "ffffff", "b9d6ee", rough=0.6)
        for i in range(9):
            x = -e + 0.3 + i * (2 * e - 0.6) / 8
            if abs(x) < e - 0.75 and i not in (0, 8): continue  # keep stretchable middle clean
            ellipsoid("snow", (x, e - 0.08, 0.34), (0.2, 0.11, 0.07), snow)
        for sx in (1, -1):
            for k in range(3):
                ellipsoid("icicle", (sx * (e - 0.32 - k * 0.14), e - T - 0.02, 0.33), (0.035, 0.1 - k * 0.02, 0.03),
                          mat_plain("icl", "dff1ff", "ffffff", "8cc3ea", rough=0.15, coat=0.8))
    else:
        vine(lerp_path([(-e + 0.08, e - 0.62), (-e + 0.22, e - 0.22), (-e + 0.62, e - 0.08)], 18, 0.03, 1.0), 0.36, M,
             radius=0.028, leaves=4, leaf_size=0.09, flowers=[(-e + 0.2, e - 0.2, 0.07)], seed=11)
        vine(lerp_path([(e - 0.08, -e + 0.62), (e - 0.22, -e + 0.22), (e - 0.62, -e + 0.08)], 18, 0.03, 1.0), 0.36, M,
             radius=0.028, leaves=4, leaf_size=0.09, seed=12)
        leaf((e - 0.2, e - 0.14, 0.38), math.radians(30), 0.1, [M["leaf"]])
        leaf((e - 0.34, e - 0.1, 0.38), math.radians(160), 0.09, [M["leaf2"]])
    return render(name, (margin, margin, margin, margin))


def build_toggle(on):
    reset(192, 96)
    M = common_mats()
    W, H = 1.74, 0.74
    rslab("rim", W, H, H / 2, 0.14, 0.04, 0.0, mat_plain("trim", "6a4024", "8a5a34", "3a2010"))
    track = mat_plain("tr_on", "green", "8ee07a", "green_dark", rough=0.35, coat=0.5) if on else \
        mat_plain("tr_off", "e9dcc0", "fff6e2", "b8a37e", rough=0.5)
    rslab("track", W - 0.12, H - 0.12, (H - 0.12) / 2, 0.2, 0.06, 0.03, track)
    kx = (W / 2 - H / 2) * (1 if on else -1)
    knob = mat_plain("knob", "fff4dc", "ffffff", "c9b48a", rough=0.4, coat=0.3)
    rslab("knob", H - 0.06, H - 0.06, (H - 0.06) / 2, 0.36, 0.12, 0.08, knob, cx=kx)
    gold_star(kx, 0.0, 0.42, 0.21, M["gold"] if on else mat_plain("st_off", "b9a88a", "e2d4b4", "7f6c50"), depth=0.09)
    return render("toggle_on" if on else "toggle_off", (44, 30, 44, 30))


def build_slider_track():
    reset(384, 72)
    W, H = 3.64, 0.42
    pal = ("4e2f1a", "8a5a34", "c08a55")
    rslab("stick", W, H, H / 2, 0.24, 0.08, 0.0, mat_wood("stick", pal, "X", seed=3.3, grain_scale=1.6))
    rslab("groove", W - 0.3, H * 0.42, H * 0.21, 0.03, 0.012, 0.22, mat_plain("groove", "3a2212", "5b3920", "24140a", rough=0.8))
    for k, x in enumerate((-1.1, 0.4, 1.3)):  # little knots near the ends only would stretch; keep tiny
        pass
    return render("slider_track", (40, 30, 40, 30))


def build_star_thumb():
    reset(112, 112)
    M = common_mats()
    gold_star(0, -0.02, 0.0, 0.48, M["gold"], depth=0.24)
    return render("slider_star_thumb", (0, 0, 0, 0))


def build_sign_heading():
    reset(320, 96)
    M = common_mats()
    W, H = 3.0, 0.72
    pal = ("4e2f1a", "8a5a34", "c08a55")
    rslab("back", W, H, 0.2, 0.12, 0.04, 0.0, mat_plain("sb", "4e2f1a", "6a4024", "2a160a"))
    rslab("board", W - 0.1, H - 0.1, 0.17, 0.28, 0.08, 0.04, mat_wood("sign", pal, "X", seed=5.5, grain_scale=1.4))
    for sx in (1, -1):
        rivet(sx * (W / 2 - 0.2), 0.0, 0.33, 0.05, M["steel"])
    return render("sign_heading", (48, 34, 48, 36))


def build_tray_slot():
    return build_chip("meadow", "tray_slot", size=192, margin=56, slot=True)


PIECES = {
    "frame_purple": lambda: build_frame_purple(False),
    "frame_purple_open": lambda: build_frame_purple(True),
    "panel_parchment": build_panel_parchment,
    "panel_wood": build_panel_wood,
    "plaque_title": build_plaque_title,
    "btn_gold": lambda: build_pill("btn_gold", lambda: mat_gold("btn_gold_face"), lambda: mat_plain("glip", "gold_deep", "e0a030", "8a5410", rough=0.4, coat=0.4),
                                   lambda: mat_plain("grim", "6a3a14", "8a5a34", "3a1e0a")),
    "btn_cream": lambda: build_pill("btn_cream", lambda: mat_plain("cface", "cream", "ffffff", "e2c995", rough=0.4, coat=0.4, edge=0.8),
                                    lambda: mat_plain("clip", "8a5a34", "b07a48", "4e2f1a", rough=0.5), lambda: mat_plain("crim", "4e2f1a", "6a4024", "2a160a")),
    "btn_close": build_btn_close,
    "chip_hud": lambda: build_chip("meadow", "chip_hud"),
    "chip_hud_ice": lambda: build_chip("ice", "chip_hud_ice"),
    "chip_hud_celestial": lambda: build_chip("celestial", "chip_hud_celestial"),
    "tray_slot": build_tray_slot,
    "toggle_on": lambda: build_toggle(True),
    "toggle_off": lambda: build_toggle(False),
    "slider_track": build_slider_track,
    "slider_star_thumb": build_star_thumb,
    "sign_heading": build_sign_heading,
}

if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    meta_path = os.path.join(ROOT, "assets/source/blender/ui/margins_x2.json")
    meta = json.load(open(meta_path)) if os.path.exists(meta_path) else {}
    for name, fn in PIECES.items():
        if ONLY and name not in ONLY: continue
        meta[name] = fn()
        json.dump(meta, open(meta_path, "w"), indent=1)
    print("KIT_DONE", len(meta))
