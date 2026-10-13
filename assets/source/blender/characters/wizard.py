"""Wacky Towers -- the wizard mascot on his cloud (Blender 5.2.2, headless, Cycles CPU).

Recipe: design/art/style-techniques.md section 6 (metaballs for soft masses, skin-modifier
limbs, voxel remesh + smooth, displacement folds, decimate to 4-8k tris, one 1024 bake) and
the Blender render rig of section 2.3 (warm key upper-left, cool fill, warm rim, Standard view).

Usage (from the repo root):
  blender -b -P assets/source/blender/characters/wizard.py -- [--stage all|ui|turn|glb]
          [--samples 32] [--root /path/to/repo] [--poses cheer,idle,point]

Outputs (relative to the repo root):
  assets/models/characters/wizard_cloud.glb      nodes: wizard (+ child wand_star), cloud
  assets/art/ui/wizard_{cheer,idle,point}.png    1024 px transparent 3/4 portraits
  production/qa/evidence/wizard-v2/*.png         turnaround, poses, bake preview, albedo

Coordinates while modelling: Z up, the wizard faces -Y (glTF +Z), the cloud base is at z = 0.
All parts are authored at "nominal" scale and then normalised so the whole piece is HEIGHT m tall.
"""
import argparse
import math
import os
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector

HEIGHT = 1.6           # final height of wizard + cloud, metres
MB_SURFACE = 0.575     # an isolated metaball's surface radius / element radius (measured, 5.2.2)
WIZ_SCALE = 1.18     # wizard size relative to the cloud
TRI_BUDGET_WIZARD = 7000
TRI_BUDGET_CLOUD = 2500
BAKE_SIZE = 1024

PAL = {
    "skin": "f7c9a8", "blush": "f29a9a", "nose": "f5ae98",
    "beard": "fff6f0", "lilac": "9d8cc8", "cloud_line": "d9ccef",
    "robe": "7a52b0", "hat": "4a2270", "trim": "f2cf6a",
    "gold": "f8c840", "glint": "fff3b0", "wood": "8a5a34", "boot": "5a3a2a",
    "eye": "1c1222", "mouth": "7a2f3c", "tongue": "e0707a",
}


# ------------------------------------------------------------------------------------- utils
def lin(h, a=1.0):
    """Hex sRGB -> linear RGBA (colour sockets are linear)."""
    h = PAL.get(h, h).lstrip("#")
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple((x / 12.92) if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in c) + (a,)


def link(o):
    bpy.context.scene.collection.objects.link(o)
    return o


def realize(o, name=None, mat=None, smooth=True):
    """Evaluate modifiers / metaball / curve into a plain mesh object (identity transform)."""
    bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
    me.transform(o.matrix_world)
    nm = name or o.name
    bpy.data.objects.remove(o)
    n = link(bpy.data.objects.new(nm, me))
    if mat is not None:
        me.materials.clear()
        me.materials.append(mat)
    if smooth:
        me.shade_smooth()
    return n


def mesh_obj(name, bm, mat=None, smooth=True):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    o = link(bpy.data.objects.new(name, me))
    if mat is not None:
        me.materials.append(mat)
    if smooth:
        me.shade_smooth()
    return o


def B(co, r):
    """Ball whose isolated surface radius is r."""
    return ("BALL", co, r)


def E(co, semi):
    """Ellipsoid whose isolated surface semi-axes are semi."""
    return ("ELLIPSOID", co, semi)


def metaball(name, elems, res=0.012):
    mb = bpy.data.metaballs.new(name)
    mb.resolution = res
    mb.render_resolution = res
    mb.threshold = 0.6
    o = link(bpy.data.objects.new(name, mb))
    for kind, co, size in elems:
        el = mb.elements.new(type=kind)
        el.co = co
        el.stiffness = 2.0
        if kind == "BALL":
            el.radius = size / MB_SURFACE
        else:
            m = max(size)
            el.radius = m / MB_SURFACE
            el.size_x, el.size_y, el.size_z = (s / m for s in size)
    return o


def add_mods(o, remesh=None, smooth=(0.5, 10), displace=None):
    """Recipe step 3/4: voxel remesh, smooth, CLOUDS displacement folds."""
    if remesh:
        m = o.modifiers.new("remesh", "REMESH")
        m.mode = "VOXEL"
        m.voxel_size = remesh
    if smooth:
        m = o.modifiers.new("smooth", "SMOOTH")
        m.factor, m.iterations = smooth
    if displace:
        size, strength = displace
        tex = bpy.data.textures.new(o.name + "_folds", "CLOUDS")
        tex.noise_scale = size
        tex.noise_depth = 1
        m = o.modifiers.new("folds", "DISPLACE")
        m.texture = tex
        m.strength = strength
        m.mid_level = 0.5
        m.texture_coords = "GLOBAL"
    return o


def join(objs, name):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    o = bpy.context.view_layer.objects.active
    o.name = name
    o.data.name = name
    return o


def cast(o, origin, direction):
    hit, loc, nrm, _ = o.ray_cast(Vector(origin), Vector(direction).normalized())
    return (Vector(loc), Vector(nrm)) if hit else (None, None)


def front_y(o, x, z, from_y=-2.0):
    loc, _ = cast(o, (x, from_y, z), (0, 1, 0))
    return loc.y if loc is not None else None


def catmull(pts, radii, n):
    """Resample a polyline with Catmull-Rom; radii interpolate linearly."""
    P = [Vector(p) for p in pts]
    P = [P[0] * 2 - P[1]] + P + [P[-1] * 2 - P[-2]]
    out, rad = [], []
    segs = len(pts) - 1
    for i in range(n):
        t = i / (n - 1) * segs
        k = min(int(t), segs - 1)
        u = t - k
        p0, p1, p2, p3 = P[k], P[k + 1], P[k + 2], P[k + 3]
        out.append(0.5 * ((2 * p1) + (-p0 + p2) * u + (2 * p0 - 5 * p1 + 4 * p2 - p3) * u * u
                          + (-p0 + 3 * p1 - 3 * p2 + p3) * u * u * u))
        rt = i / (n - 1) * (len(radii) - 1)       # radii are sampled along the spine independently
        rk = min(int(rt), len(radii) - 2)
        rad.append(radii[rk] + (radii[rk + 1] - radii[rk]) * (rt - rk))
    return out, rad


def sweep(name, pts, radii, ring=24, n=40, mat=None, closed=False, cap=True, wobble=0.0):
    """Tube along a spine with parallel-transport frames (hat cone, wand, trims, swirls)."""
    if closed:
        P = [Vector(p) for p in pts]
        R = list(radii)
    else:
        P, R = catmull(pts, radii, n)
    bm = bmesh.new()
    rings = []
    T0 = (P[1] - P[0]).normalized()
    N = T0.orthogonal().normalized()
    cnt = len(P)
    for i, p in enumerate(P):
        if closed:
            T = (P[(i + 1) % cnt] - P[i - 1]).normalized()
        else:
            T = (P[min(i + 1, cnt - 1)] - P[max(i - 1, 0)]).normalized()
        N = (N - T * N.dot(T)).normalized()
        Bv = T.cross(N)
        verts = []
        for j in range(ring):
            a = 2 * math.pi * j / ring
            r = R[i] * (1.0 + wobble * math.sin(3 * a + i * 0.7))
            verts.append(bm.verts.new(p + r * (math.cos(a) * N + math.sin(a) * Bv)))
        rings.append(verts)
    pairs = [(i, i + 1) for i in range(cnt - 1)] + ([(cnt - 1, 0)] if closed else [])
    for a, b in pairs:
        for j in range(ring):
            bm.faces.new((rings[a][j], rings[a][(j + 1) % ring], rings[b][(j + 1) % ring], rings[b][j]))
    if cap and not closed:
        tip = bm.verts.new(P[-1] + (P[-1] - P[-2]).normalized() * R[-1] * 0.8)
        for j in range(ring):
            bm.faces.new((rings[-1][j], rings[-1][(j + 1) % ring], tip))
        base = bm.verts.new(P[0] - (P[1] - P[0]).normalized() * R[0] * 0.3)
        for j in range(ring):
            bm.faces.new((rings[0][(j + 1) % ring], rings[0][j], base))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return mesh_obj(name, bm, mat)


def ellipsoid(name, co, semi, mat, rot=None, seg=24):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=seg // 2, radius=1.0)
    M = Matrix.Translation(co) @ (rot or Matrix.Identity(4)) @ Matrix.Diagonal((*semi, 1.0))
    bm.transform(M)
    return mesh_obj(name, bm, mat)


def star_outline(ro, ri, n=5, rot=90.0):
    pts = []
    for i in range(n * 2):
        a = math.radians(rot + i * 180.0 / n)
        r = ro if i % 2 == 0 else ri
        pts.append((r * math.cos(a), r * math.sin(a)))
    return pts


def puffy_star(name, ro, ri, depth, mat, location, facing):
    """Extruded, bevelled 5-point star (wand tip)."""
    bm = bmesh.new()
    vs = [bm.verts.new((x, y, -depth / 2)) for x, y in star_outline(ro, ri)]
    f = bm.faces.new(vs)
    ext = bmesh.ops.extrude_face_region(bm, geom=[f])
    for v in [e for e in ext["geom"] if isinstance(e, bmesh.types.BMVert)]:
        v.co.z += depth
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    o = mesh_obj(name, bm, mat, smooth=False)
    bv = o.modifiers.new("bevel", "BEVEL")
    bv.width = depth * 0.45
    bv.segments = 4
    bv.limit_method = "NONE"
    o.modifiers.new("sub", "SUBSURF").levels = 1
    o.matrix_world = Matrix.Translation(location) @ Vector(facing).normalized().to_track_quat("Z", "Y").to_matrix().to_4x4()
    return realize(o)


def decal_star(name, target, origin, direction, size, thick, mat, offset=0.003):
    """Flat star shrink-wrapped onto a surface then solidified (robe/hat appliques)."""
    loc, nrm = cast(target, origin, direction)
    if loc is None:
        return None
    bm = bmesh.new()
    c = bm.verts.new((0, 0, 0))
    outline = star_outline(size, size * 0.45)
    rings = []
    for t in (0.34, 0.67, 1.0):
        rings.append([bm.verts.new((x * t, y * t, 0)) for x, y in outline])
    m = len(outline)
    for j in range(m):
        bm.faces.new((c, rings[0][j], rings[0][(j + 1) % m]))
    for a, b in ((0, 1), (1, 2)):
        for j in range(m):
            bm.faces.new((rings[a][j], rings[b][j], rings[b][(j + 1) % m], rings[a][(j + 1) % m]))
    o = mesh_obj(name, bm, mat, smooth=False)
    o.matrix_world = Matrix.Translation(loc) @ nrm.to_track_quat("Z", "Y").to_matrix().to_4x4()
    sw = o.modifiers.new("wrap", "SHRINKWRAP")
    sw.target = target
    sw.wrap_method = "NEAREST_SURFACEPOINT"
    sw.offset = offset
    so = o.modifiers.new("solid", "SOLIDIFY")
    so.thickness = thick
    so.offset = 1.0
    return realize(o)


def ring_on_surface(name, target, center, axis, tube, mat, n=36, push=0.003, from_inside=True, maxd=9.0, fallback=None):
    """Closed trim tube that hugs a surface around an axis (cuffs, hem)."""
    axis = Vector(axis).normalized()
    u = axis.orthogonal().normalized()
    v = axis.cross(u)
    pts = []
    for i in range(n):
        a = 2 * math.pi * i / n
        d = math.cos(a) * u + math.sin(a) * v
        if from_inside:
            loc, nrm = cast(target, Vector(center), d)
        else:
            loc, nrm = cast(target, Vector(center) + d * 1.5, -d)
        if loc is None or (loc - Vector(center)).length > maxd:
            if fallback is None:
                continue
            loc = Vector(center) + d * fallback
        pts.append(loc + d * push)
    if len(pts) < 8:
        return None
    return sweep(name, pts, [tube] * len(pts), ring=12, mat=mat, closed=True)


def trim_ring(name, target, center, axis, tube, mat, n=36, slab=0.012, push=0.002):
    """Closed trim tube hugging a surface: per angular bin, the outermost vertex of `target`
    inside a thin slab across `axis` (raycasts hit the torso from inside the sleeves)."""
    axis = Vector(axis).normalized()
    u = axis.orthogonal().normalized()
    v = axis.cross(u)
    nv = len(target.data.vertices)
    co = np.empty(nv * 3, dtype=np.float32)
    target.data.vertices.foreach_get("co", co)
    Q = co.reshape(-1, 3) - np.array(center)
    h = Q @ np.array(axis)
    Q = Q[np.abs(h) < slab]
    if len(Q) < 16:
        return None
    x, y = Q @ np.array(u), Q @ np.array(v)
    ang = np.arctan2(y, x)
    rad = np.hypot(x, y)
    bins = ((ang + math.pi) / (2 * math.pi) * n).astype(int) % n
    pts = []
    for i in range(n):
        sel = rad[bins == i]
        if len(sel) == 0:
            continue
        a = (i + 0.5) / n * 2 * math.pi - math.pi
        r = float(sel.max()) + push
        pts.append(Vector(center) + r * (math.cos(a) * u + math.sin(a) * v))
    if len(pts) < 8:
        return None
    return sweep(name, pts, [tube] * len(pts), ring=12, mat=mat, closed=True)


def skin_limb(name, pts, radii):
    """Recipe step 2: polyline skeleton + Skin modifier + Subdivision 2."""
    me = bpy.data.meshes.new(name)
    me.from_pydata([Vector(p) for p in pts], [(i, i + 1) for i in range(len(pts) - 1)], [])
    o = link(bpy.data.objects.new(name, me))
    bpy.ops.object.select_all(action="DESELECT")
    o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.modifier_add(type="SKIN")
    for i, r in enumerate(radii):
        me.skin_vertices[0].data[i].radius = (r, r)
    o.modifiers.new("sub", "SUBSURF").levels = 2
    return realize(o)


# ---------------------------------------------------------------------------------- materials
def _bsdf(m):
    nt = m.node_tree
    b = next((n for n in nt.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if b is None:
        b = nt.nodes.new("ShaderNodeBsdfPrincipled")
        out = next((n for n in nt.nodes if n.type == "OUTPUT_MATERIAL"), None) or nt.nodes.new("ShaderNodeOutputMaterial")
        nt.links.new(b.outputs[0], out.inputs[0])
    return nt, b


def principled(name, base, rough=0.6, metal=0.0, **inputs):
    m = bpy.data.materials.new(name)
    try:
        m.use_nodes = True
    except (AttributeError, TypeError):
        pass
    nt, b = _bsdf(m)
    b.inputs["Base Color"].default_value = lin(base)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    for k, v in inputs.items():
        b.inputs[k.replace("_", " ")].default_value = v
    return m


def mix_rgb(nt, fac_socket, a, b):
    mx = nt.nodes.new("ShaderNodeMix")
    mx.data_type = "RGBA"
    nt.links.new(fac_socket, mx.inputs[0])
    mx.inputs[6].default_value = a
    mx.inputs[7].default_value = b
    return mx.outputs[2]


def plush(name, base, shade, dist):
    """White beard/cloud: AO-driven lilac shade so creases read violet, never grey."""
    m = principled(name, base, rough=0.78, Sheen_Weight=0.35, Subsurface_Weight=0.08)
    nt, b = _bsdf(m)
    b.inputs["Sheen Tint"].default_value = lin("e9e0ff")
    b.inputs["Subsurface Radius"].default_value = (1.0, 0.8, 0.9)
    b.inputs["Subsurface Scale"].default_value = 0.03
    ao = nt.nodes.new("ShaderNodeAmbientOcclusion")
    ao.inputs["Distance"].default_value = dist
    ao.samples = 8
    ramp = nt.nodes.new("ShaderNodeMapRange")
    ramp.inputs["From Min"].default_value = 0.68
    ramp.inputs["From Max"].default_value = 1.0
    nt.links.new(ao.outputs["AO"], ramp.inputs["Value"])
    nt.links.new(mix_rgb(nt, ramp.outputs[0], lin(shade), lin(base)), b.inputs["Base Color"])
    return m


def felt(name, base, rough=0.9, sheen=0.5, bump=0.05):
    m = principled(name, base, rough=rough, Sheen_Weight=sheen)
    nt, b = _bsdf(m)
    b.inputs["Sheen Tint"].default_value = lin("c9b2ff")
    b.inputs["Sheen Roughness"].default_value = 0.45
    nz = nt.nodes.new("ShaderNodeTexNoise")
    nz.inputs["Scale"].default_value = 30.0
    bp = nt.nodes.new("ShaderNodeBump")
    bp.inputs["Strength"].default_value = bump
    nt.links.new(nz.outputs["Fac"], bp.inputs["Height"])
    nt.links.new(bp.outputs["Normal"], b.inputs["Normal"])
    # broad low-frequency value variation = hand-painted look
    nz2 = nt.nodes.new("ShaderNodeTexNoise")
    nz2.inputs["Scale"].default_value = 3.0
    base_c = lin(base)
    dark = tuple(c * 0.78 for c in base_c[:3]) + (1.0,)
    nt.links.new(mix_rgb(nt, nz2.outputs["Fac"], dark, base_c), b.inputs["Base Color"])
    return m


def skin_mat():
    m = principled("skin", "skin", rough=0.55, Subsurface_Weight=0.15)
    nt, b = _bsdf(m)
    b.inputs["Subsurface Radius"].default_value = (1.0, 0.4, 0.25)
    b.inputs["Subsurface Scale"].default_value = 0.05
    ca = nt.nodes.new("ShaderNodeVertexColor")
    ca.layer_name = "blush"
    nt.links.new(mix_rgb(nt, ca.outputs["Color"], lin("skin"), lin("blush")), b.inputs["Base Color"])
    return m


def materials():
    M = {
        "skin": skin_mat(),
        "nose": principled("nose", "nose", rough=0.4, Subsurface_Weight=0.15, Coat_Weight=0.15),
        "beard": plush("beard", "beard", "lilac", 0.12),
        "cloud": plush("cloud", "beard", "lilac", 0.35),
        "cloud_line": plush("cloud_line", "cloud_line", "lilac", 0.2),
        "robe": felt("robe", "robe", rough=0.85, sheen=0.55, bump=0.03),
        "hat": felt("hat", "hat", rough=0.9, sheen=0.25, bump=0.05),
        "trim": principled("trim", "trim", rough=0.38, metal=0.55),
        "gold": principled("gold", "gold", rough=0.25, metal=0.8,
                           Emission_Color=lin("gold"), Emission_Strength=0.25),
        "wood": felt("wood", "wood", rough=0.6, sheen=0.0, bump=0.02),
        "boot": principled("boot", "boot", rough=0.7),
        "eye": principled("eye", "eye", rough=0.08, Coat_Weight=0.6),
        "glint": principled("glint", "ffffff", rough=0.2, Emission_Color=lin("ffffff"), Emission_Strength=3.0),
        "mouth": principled("mouth", "mouth", rough=0.5),
        "tongue": principled("tongue", "tongue", rough=0.5),
        "star": principled("wand_star", "gold", rough=0.25, metal=0.2,
                           Emission_Color=lin("gold"), Emission_Strength=1.2),
    }
    return M


# --------------------------------------------------------------------------------------- poses
POSES = {
    # arm = shoulder, elbow, wrist; hand kind; wand direction for the right hand.
    "idle": {
        "R": [(-0.19, 0.02, 0.79), (-0.30, -0.04, 0.67), (-0.31, -0.18, 0.66)], "R_hand": "fist",
        "L": [(0.19, 0.02, 0.79), (0.30, -0.04, 0.65), (0.27, -0.18, 0.58)], "L_hand": "rest",
        "wand": (-0.6, -0.12, 1.0), "eyes": "closed", "mouth": False,
    },
    "cheer": {
        "R": [(-0.19, 0.02, 0.81), (-0.33, -0.03, 0.95), (-0.40, -0.07, 1.11)], "R_hand": "fist",
        "L": [(0.19, 0.02, 0.81), (0.35, -0.06, 0.86), (0.49, -0.12, 0.94)], "L_hand": "open",
        "wand": (-0.18, -0.08, 1.0), "eyes": "closed", "mouth": True,
    },
    "point": {
        "R": [(-0.19, 0.02, 0.80), (-0.31, -0.10, 0.74), (-0.40, -0.27, 0.80)], "R_hand": "fist",
        "L": [(0.19, 0.02, 0.79), (0.30, -0.04, 0.65), (0.27, -0.18, 0.58)], "L_hand": "rest",
        "wand": (-0.55, -0.80, 0.35), "eyes": "open", "mouth": False,
    },
}


# ---------------------------------------------------------------------------------------- build
def build(pose_name, M):
    """Build the full high-res wizard + cloud. Returns {'wizard': [...], 'cloud': [...], 'star': obj}."""
    pose = POSES[pose_name]
    W, C = [], []

    # ---- cloud: distinct puff spheres -> voxel remesh -> smooth (metaballs merged into one blob)
    bm = bmesh.new()
    puffs = [((0, 0.02, 0.27), (0.55, 0.40, 0.15)), ((0, 0.10, 0.12), (0.30, 0.25, 0.12))]
    sizes = [0.19, 0.21, 0.18, 0.20, 0.22, 0.18, 0.21, 0.19, 0.18, 0.20]
    for i in range(10):
        a = 2 * math.pi * i / 10 + 0.3
        r = sizes[i]
        puffs.append(((0.60 * math.cos(a), 0.43 * math.sin(a) + 0.02, 0.24 + 0.035 * math.sin(3 * a)), (r, r, r * 0.92)))
    for co, r in [((-0.34, 0.10, 0.36), 0.17), ((0.35, 0.08, 0.35), 0.16), ((0.0, 0.22, 0.39), 0.18),
                  ((-0.14, -0.27, 0.32), 0.15), ((0.16, -0.29, 0.31), 0.15), ((-0.27, -0.26, 0.13), 0.16),
                  ((0.27, -0.23, 0.12), 0.15), ((0.0, -0.37, 0.19), 0.15)]:
        puffs.append((co, (r, r, r * 0.92)))
    for co, semi in puffs:
        g = bmesh.ops.create_uvsphere(bm, u_segments=32, v_segments=16, radius=1.0)
        bmesh.ops.transform(bm, matrix=Matrix.Translation(co) @ Matrix.Diagonal((*semi, 1.0)), verts=g["verts"])
    bm.transform(Matrix.Diagonal((1.12, 1.05, 1.0, 1.0)))
    cloud = mesh_obj("C_cloud", bm, M["cloud"])
    add_mods(cloud, remesh=0.012, smooth=(0.6, 14))
    cloud = realize(cloud)
    C.append(cloud)
    # spiral swirls on the front puffs
    for k, (x, z, r0, turn) in enumerate([(-0.45, 0.24, 0.11, 1), (0.02, 0.2, 0.10, -1), (0.55, 0.26, 0.10, -1)]):
        loc, nrm = cast(cloud, (x, -2, z), (0, 1, 0))
        if loc is None:
            continue
        u = nrm.cross(Vector((0, 0, 1))).normalized()
        v = nrm.cross(u).normalized()
        pts, rad = [], []
        for i in range(34):
            t = i / 33
            ang = turn * (t * 2.2 * math.pi)
            rr = r0 * (1 - t * 0.85)
            q = loc + rr * (math.cos(ang) * u + math.sin(ang) * v)
            h, _ = cast(cloud, q + nrm * 0.15, -nrm)
            pts.append((h if h is not None else q) + nrm * 0.002)
            rad.append(0.012 * (1 - 0.6 * t))
        C.append(sweep(f"C_swirl{k}", pts, rad, ring=8, n=60, mat=M["cloud_line"]))

    # ---- head (skin metaball) + blush vertex colours
    head = realize(metaball("mb_head", [E((0, -0.02, 0.985), (0.182, 0.165, 0.178))], res=0.01), "W_head", M["skin"])
    me = head.data
    attr = me.color_attributes.new("blush", "FLOAT_COLOR", "POINT")
    for v in me.vertices:
        w = 0.0
        for sx in (-1, 1):
            d = (v.co - Vector((sx * 0.105, -0.17, 0.945))).length
            w = max(w, max(0.0, 1.0 - d / 0.065))
        w = w * w * (3 - 2 * w)
        attr.data[v.index].color = (w, w, w, 1.0)
    W.append(head)

    fy = lambda x, z: front_y(head, x, z)

    # nose
    ny = fy(0, 0.965)
    W.append(ellipsoid("W_nose", (0, ny - 0.028, 0.962), (0.056, 0.05, 0.05), M["nose"]))

    # eyes
    for sx in (-1, 1):
        ex, ez = sx * 0.064, 1.008
        ey = fy(ex, ez)
        if pose["eyes"] == "open":
            W.append(ellipsoid(f"W_eye{sx}", (ex, ey + 0.004, ez), (0.019, 0.012, 0.027), M["eye"]))
            W.append(ellipsoid(f"W_glint{sx}a", (ex - 0.006, ey - 0.006, ez + 0.010), (0.0065,) * 3, M["glint"], seg=12))
            W.append(ellipsoid(f"W_glint{sx}b", (ex + 0.006, ey - 0.005, ez - 0.010), (0.0035,) * 3, M["glint"], seg=10))
        else:
            pts = []
            for i in range(9):
                t = -1 + 2 * i / 8
                x, z = ex + 0.026 * t, ez - 0.004 + 0.016 * (1 - t * t)
                pts.append((x, fy(x, z) - 0.002, z))
            W.append(sweep(f"W_eye{sx}", pts, [0.0045, 0.0065, 0.0065, 0.0045], ring=10, n=24, mat=M["eye"]))

    # beard + hair (one soft white mass, recipe 4: curl metaballs at the tip)
    els = [E((0, -0.12, 0.87), (0.20, 0.11, 0.13)), E((0, -0.18, 0.74), (0.18, 0.10, 0.14)),
           B((-0.145, -0.15, 0.80), 0.095), B((0.145, -0.15, 0.80), 0.095),
           B((-0.10, -0.21, 0.655), 0.085), B((0.10, -0.21, 0.655), 0.085), B((0, -0.225, 0.60), 0.08),
           B((-0.165, -0.09, 0.925), 0.08), B((0.165, -0.09, 0.925), 0.08),
           B((-0.18, 0.03, 1.0), 0.078), B((0.18, 0.03, 1.0), 0.078),
           B((-0.16, 0.10, 0.92), 0.085), B((0.16, 0.10, 0.92), 0.085), E((0, 0.13, 0.96), (0.17, 0.075, 0.11))]
    cx, cz = 0.06, 0.52
    for i in range(16):
        t = i / 15
        phi = math.pi + t * 1.7 * math.pi
        rr = 0.065 * (1 - 0.75 * t)
        els.append(B((cx + rr * math.cos(phi), -0.235 + 0.01 * t, cz + rr * math.sin(phi)), 0.064 - 0.036 * t))
    beard = realize(metaball("mb_beard", els, res=0.011), "W_beard", M["beard"])
    add_mods(beard, remesh=0.008, smooth=(0.6, 14))
    beard = realize(beard)
    W.append(beard)

    # moustache (own family so it reads as two lobes)
    els = []
    for sx in (-1, 1):
        for i in range(9):
            t = i / 8
            x = sx * (0.02 + 0.14 * t)
            z = 0.928 - 0.022 * math.sin(math.pi * t) + 0.05 * t ** 3
            y0 = front_y(beard, x, z) or -0.2
            els.append(B((x, y0 + 0.014 - 0.01 * t, z), 0.045 - 0.019 * t))
    stache = realize(metaball("mb_stache", els, res=0.008), "W_stache", M["beard"])
    W.append(stache)

    # brows
    els = []
    for sx in (-1, 1):
        for i in range(6):
            t = i / 5
            x = sx * (0.035 + 0.085 * t)
            z = 1.052 + 0.01 * math.sin(math.pi * t) - 0.022 * t ** 2
            els.append(B((x, fy(x, z) - 0.006, z), 0.026 - 0.008 * t))
    W.append(realize(metaball("mb_brows", els, res=0.006), "W_brows", M["beard"]))

    # mouth (cheer): open smile under the moustache
    if pose["mouth"]:
        my = front_y(beard, 0, 0.885) or -0.22
        W.append(ellipsoid("W_mouth", (0, my + 0.012, 0.888), (0.042, 0.02, 0.026), M["mouth"]))
        W.append(ellipsoid("W_tongue", (0, my + 0.006, 0.875), (0.024, 0.012, 0.012), M["tongue"], seg=16))

    # ---- robe: torso metaballs + skin-modifier sleeves -> join -> voxel remesh -> smooth -> folds
    torso = realize(metaball("mb_torso", [
        E((0, 0.03, 0.66), (0.20, 0.17, 0.19)), E((0, -0.06, 0.53), (0.29, 0.27, 0.1)),
        E((0, 0.02, 0.80), (0.19, 0.15, 0.08)), B((-0.15, -0.2, 0.52), 0.11), B((0.15, -0.2, 0.52), 0.11)],
        res=0.014), "W_robe")
    sleeves = []
    sleeve_only = {}
    arm_dirs = {}
    for side in ("R", "L"):
        S, El, Wr = (Vector(p) for p in pose[side])
        d = (Wr - El).normalized()
        arm_dirs[side] = (Wr, d)
        sl = skin_limb(f"W_sleeve{side}", [S, El, Wr, Wr + d * 0.035], [0.085, 0.095, 0.12, 0.135])
        sleeve_only[side] = sl.copy()
        sleeve_only[side].data = sl.data.copy()
        sleeves.append(sl)
    robe = join([torso] + sleeves, "W_robe")
    robe.data.materials.clear()
    robe.data.materials.append(M["robe"])
    add_mods(robe, remesh=0.009, smooth=(0.5, 10), displace=(0.07, 0.012))
    robe = realize(robe)
    W.append(robe)

    # gold trim: cuffs and hem
    for side in ("R", "L"):
        Wr, d = arm_dirs[side]
        cuff = trim_ring(f"W_cuff{side}", robe.copy(), Wr + d * 0.02, d, 0.016, M["trim"], n=28, slab=0.01) if False else \
            trim_ring(f"W_cuff{side}", sleeve_only[side], Wr + d * 0.02, d, 0.016, M["trim"], n=28, slab=0.01)
        if cuff:
            W.append(cuff)
    for sl in sleeve_only.values():
        bpy.data.meshes.remove(sl.data)
    hem = trim_ring("W_hem", robe, (0, -0.05, 0.49), (0, 0, 1), 0.016, M["trim"], n=56, slab=0.008)
    if hem:
        W.append(hem)

    # robe stars
    for k, (az, el) in enumerate([(-35, 10), (30, -5), (-70, -20), (75, 15), (150, 5), (-150, -10), (180, 25),
                                  (110, -25), (-110, 20), (5, -35)]):
        a, e = math.radians(az - 90), math.radians(el)
        d = Vector((math.cos(a) * math.cos(e), math.sin(a) * math.cos(e), math.sin(e)))
        c = Vector((0, 0.0, 0.64))
        s = decal_star(f"W_rstar{k}", robe, c + d * 1.2, -d, 0.032, 0.004, M["gold"])
        if s:
            W.append(s)

    # hands
    for side in ("R", "L"):
        Wr, d = arm_dirs[side]
        kind = pose[side + "_hand"]
        side_v = d.cross(Vector((0, 0, 1)))
        if side_v.length < 0.1:
            side_v = Vector((1, 0, 0))
        side_v.normalize()
        up = side_v.cross(d).normalized()
        pc = Wr + d * 0.055
        if kind == "fist":
            els = [B(pc, 0.046), B(pc + d * 0.022 - up * 0.008, 0.042), B(pc + up * 0.036 - side_v * 0.016, 0.021)]
        elif kind == "open":
            els = [E(pc + d * 0.01, (0.05, 0.05, 0.035)), B(pc + d * 0.05, 0.036),
                   B(pc + d * 0.02 + up * 0.045, 0.021)]
        else:  # rest: mitten resting on the lap
            els = [B(pc, 0.046), B(pc + d * 0.028, 0.038), B(pc - side_v * 0.045 * (1 if side == "L" else -1) + up * 0.02, 0.026)]
        W.append(realize(metaball(f"mb_hand{side}", els, res=0.008), f"W_hand{side}", M["skin"]))
        if side == "R":
            wd = Vector(pose["wand"]).normalized()
            a, b = pc - wd * 0.07, pc + wd * 0.32
            W.append(sweep("W_wand", [a, (a + b) / 2, b], [0.014, 0.012, 0.009], ring=12, n=12, mat=M["wood"]))
            W.append(ellipsoid("W_wandknob", a, (0.017,) * 3, M["wood"], seg=16))
            star = puffy_star("wand_star", 0.075, 0.034, 0.03, M["star"], b + wd * 0.06, (-0.45, -1.0, 0.15))

    # boots
    for sx in (-1, 1):
        rot = Matrix.Rotation(math.radians(sx * -14), 4, "Z")
        W.append(ellipsoid(f"W_boot{sx}", (sx * 0.12, -0.33, 0.5), (0.058, 0.08, 0.05), M["boot"], rot=rot))

    # ---- hat: bent swept cone + floppy brim with a rolled lip + big gold star; tilted back
    hat_parts = []
    spine = [(0, 0.02, 1.06), (0, 0.03, 1.22), (0.01, 0.06, 1.36), (0.05, 0.10, 1.47),
             (0.13, 0.14, 1.53), (0.21, 0.16, 1.50), (0.26, 0.16, 1.42)]
    radii = [0.22, 0.18, 0.13, 0.092, 0.064, 0.042, 0.02]
    cone = sweep("W_hat", spine, radii, ring=36, n=70, mat=M["hat"], wobble=0.03)
    add_mods(cone, smooth=None, displace=(0.06, 0.01))
    hat_parts.append(realize(cone))

    def brim_z(a, r):
        return (0.016 * math.sin(3 * a + 0.4) - 0.035 * math.cos(a) ** 2 + 0.012 * max(0.0, -math.sin(a))) * r

    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=64, v_segments=16, radius=1.0)
    for v in bm.verts:
        a = math.atan2(v.co.y, v.co.x)
        r = math.hypot(v.co.x, v.co.y)
        v.co = Vector((v.co.x * 0.38, v.co.y * 0.36 + 0.02, v.co.z * 0.022 + 1.095 + brim_z(a, r)))
    hat_parts.append(mesh_obj("W_brim", bm, M["hat"]))
    lip = []
    for i in range(72):
        a = 2 * math.pi * i / 72
        lip.append((0.38 * math.cos(a), 0.36 * math.sin(a) + 0.02, 1.095 + brim_z(a, 1.0)))
    hat_parts.append(sweep("W_brimlip", lip, [0.026] * 72, ring=14, mat=M["hat"], closed=True))
    hs = decal_star("W_hatstar", hat_parts[0], (0, -2, 1.24), (0, 1, 0), 0.06, 0.012, M["trim"], offset=0.004)
    if hs:
        hat_parts.append(hs)
    for k, (x, z) in enumerate([(0.1, 1.33), (-0.09, 1.18)]):
        s = decal_star(f"W_hatstar{k}", hat_parts[0], (x * 3, -2, z), (-x * 3, 2, 0), 0.026, 0.004, M["gold"])
        if s:
            hat_parts.append(s)
    tilt = Matrix.Translation((0, 0.02, 1.115)) @ Matrix.Rotation(math.radians(-14), 4, "X") @ \
        Matrix.Rotation(math.radians(6), 4, "Y") @ Matrix.Translation((0, -0.02, -1.08))
    for o in hat_parts:
        o.data.transform(tilt)
    W += hat_parts

    # ---- the wizard is chunky relative to his cloud: scale him about his seat and sink him in
    S = Matrix.Translation((0, -0.05, 0.43)) @ Matrix.Scale(WIZ_SCALE, 4) @ Matrix.Translation((0, 0.05, -0.47))
    for o in W + [star]:
        o.data.transform(S)

    # ---- normalise: base at z = 0, total height HEIGHT
    allo = W + C + [star]
    zs = []
    for o in allo:
        n = len(o.data.vertices)
        co = np.empty(n * 3, dtype=np.float32)
        o.data.vertices.foreach_get("co", co)
        zs.append(co.reshape(-1, 3)[:, 2])
    zs = np.concatenate(zs)
    s = HEIGHT / float(zs.max() - zs.min())
    N = Matrix.Translation((0, 0, -float(zs.min()) * s)) @ Matrix.Scale(s, 4)
    for o in allo:
        o.data.transform(N)
        o.data.update()
    return {"wizard": W, "cloud": C, "star": star}


# --------------------------------------------------------------------------------- render setup
def reset(samples):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = samples
    sc.cycles.use_denoising = True
    sc.cycles.max_bounces = 6
    sc.render.film_transparent = True
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"
    sc.view_settings.view_transform = "Standard"
    sc.view_settings.look = "None"
    sc.view_settings.exposure = -0.2
    world = bpy.data.worlds.new("w")
    sc.world = world
    try:
        world.use_nodes = True
    except (AttributeError, TypeError):
        pass
    bg = world.node_tree.nodes["Background"]
    bg.inputs[0].default_value = lin("e8dcff")
    bg.inputs[1].default_value = 0.3
    cam = link(bpy.data.objects.new("cam", bpy.data.cameras.new("cam")))
    cam.data.lens = 35
    cam.data.sensor_width = 36
    sc.camera = cam
    for nm, col, energy, size in (("key", "fff0d6", 480, 3.0), ("fill", "b8c4ff", 150, 4.0), ("rim", "ffe0a8", 600, 1.6)):
        ld = bpy.data.lights.new(nm, "AREA")
        ld.color = lin(col)[:3]
        ld.energy = energy
        ld.size = size
        link(bpy.data.objects.new(nm, ld))
    return sc


def sample_points(objs, cap=40000):
    arr = []
    for o in objs:
        n = len(o.data.vertices)
        co = np.empty(n * 3, dtype=np.float32)
        o.data.vertices.foreach_get("co", co)
        arr.append(co.reshape(-1, 3))
    P = np.concatenate(arr)
    step = max(1, len(P) // cap)
    return P[::step]


def place_view(sc, P, yaw_deg, elev_deg, margin, w, h):
    """Aim the camera from yaw/elev at the bbox centre and fit all points with the given margin.
    yaw 0 = front (camera on -Y); negative yaw = camera toward the wizard's right (-X).
    Lights follow the camera so the key always comes from the upper-left of the frame."""
    cam = sc.camera
    lo, hi = P.min(0), P.max(0)
    T = Vector(((lo + hi) / 2).tolist())
    yaw, el = math.radians(yaw_deg), math.radians(elev_deg)
    toward = Vector((math.sin(yaw) * math.cos(el), -math.cos(yaw) * math.cos(el), math.sin(el)))
    f = -toward
    right = f.cross(Vector((0, 0, 1))).normalized()
    up = right.cross(f)
    tanh = (cam.data.sensor_width / 2) / cam.data.lens
    aspect = w / h
    dist = 5.0
    for _ in range(40):
        L = T + toward * dist
        Q = P - np.array(L)
        x, y, z = Q @ np.array(right), Q @ np.array(up), Q @ np.array(f)
        u = x / z / (2 * tanh)          # in units of the larger dimension
        v = y / z / (2 * tanh)
        half_w = 0.5 if aspect >= 1 else 0.5 * aspect
        half_h = 0.5 / aspect if aspect >= 1 else 0.5
        need = max((u.max() - u.min()) / (2 * half_w), (v.max() - v.min()) / (2 * half_h)) / (1 - 2 * margin)
        dist *= need ** 0.9
    cam.location = T + toward * dist
    cam.rotation_euler = f.to_track_quat("-Z", "Y").to_euler()
    cam.data.shift_x = float((u.max() + u.min()) / 2)
    cam.data.shift_y = float((v.max() + v.min()) / 2)
    sc.render.resolution_x, sc.render.resolution_y = w, h
    rig = {"key": (-0.62, 0.55, 0.62, 5.5), "fill": (0.85, -0.05, 0.5, 5.5), "rim": (0.55, 0.65, -0.9, 4.5)}
    for nm, (r, u_, t, d) in rig.items():
        o = bpy.data.objects[nm]
        p = T + (right * r + Vector((0, 0, 1)) * u_ + toward * t).normalized() * d
        o.location = p
        o.rotation_euler = (T - p).to_track_quat("-Z", "Y").to_euler()


def render(sc, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    sc.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("WROTE", path)


# -------------------------------------------------------------------------------------- glb bake
def tri_count(o):
    return sum(len(p.vertices) - 2 for p in o.data.polygons)


def decimate(objs, budget, floor=60):
    total = sum(tri_count(o) for o in objs)
    ratio = min(1.0, budget / max(total, 1))
    out = []
    for o in objs:
        t = tri_count(o)
        r = min(1.0, max(ratio, floor / max(t, 1)))
        if r < 1.0:
            m = o.modifiers.new("dec", "DECIMATE")
            m.ratio = r
            o = realize(o)
        out.append(o)
    return out


def bake_and_export(parts, M, root, samples):
    sc = bpy.context.scene
    wiz = decimate(parts["wizard"], TRI_BUDGET_WIZARD - tri_count(parts["star"]))
    cld = decimate(parts["cloud"], TRI_BUDGET_CLOUD)
    wizard = join(wiz, "wizard")
    cloud = join(cld, "cloud")
    objs = [wizard, cloud]
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = wizard
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(60), island_margin=0.004)
    bpy.ops.object.mode_set(mode="OBJECT")

    alb = bpy.data.images.new("wt_wizard_albedo", BAKE_SIZE, BAKE_SIZE, alpha=False)
    ao = bpy.data.images.new("wt_wizard_ao", BAKE_SIZE, BAKE_SIZE, alpha=False)
    ao.colorspace_settings.name = "Non-Color"
    mats = {m for o in objs for m in o.data.materials if m}

    def target(img):
        for m in mats:
            nt = m.node_tree
            n = nt.nodes.get("BAKE") or nt.nodes.new("ShaderNodeTexImage")
            n.name = "BAKE"
            n.image = img
            for x in nt.nodes:
                x.select = False
            n.select = True
            nt.nodes.active = n

    sc.cycles.samples = samples
    sc.render.bake.margin = 8
    target(alb)
    bpy.ops.object.bake(type="DIFFUSE", pass_filter={"COLOR"}, margin=8, use_clear=True)
    target(ao)
    bpy.ops.object.bake(type="AO", margin=8, use_clear=True)
    a = np.array(alb.pixels[:]).reshape(-1, 4)
    o_ = np.array(ao.pixels[:]).reshape(-1, 4)[:, :1]
    a[:, :3] *= 0.62 + 0.38 * o_
    alb.pixels = a.ravel().tolist()
    tex_path = os.path.join(root, "production/qa/evidence/wizard-v2/wizard_albedo_1024.png")
    os.makedirs(os.path.dirname(tex_path), exist_ok=True)
    alb.filepath_raw = tex_path
    alb.file_format = "PNG"
    alb.save()

    baked = bpy.data.materials.new("wt_wizard_baked")
    try:
        baked.use_nodes = True
    except (AttributeError, TypeError):
        pass
    nt, b = _bsdf(baked)
    tn = nt.nodes.new("ShaderNodeTexImage")
    tn.image = bpy.data.images.load(tex_path)
    tn.image.name = "wizard_albedo"
    nt.links.new(tn.outputs["Color"], b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = 0.75
    for o in objs:
        o.data.materials.clear()
        o.data.materials.append(baked)
        for p in o.data.polygons:
            p.material_index = 0
    star = parts["star"]
    star.parent = wizard
    star.matrix_parent_inverse = Matrix.Identity(4)

    glb = os.path.join(root, "assets/models/characters/wizard_cloud.glb")
    os.makedirs(os.path.dirname(glb), exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for o in (wizard, cloud, star):
        o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB", use_selection=True,
                              export_apply=True, export_yup=True)
    print("WROTE", glb, "tris wizard", tri_count(wizard), "star", tri_count(star), "cloud", tri_count(cloud))
    return wizard, cloud, star


# ------------------------------------------------------------------------------------------ main
def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", default="all")
    ap.add_argument("--samples", type=int, default=32)
    ap.add_argument("--root", default=os.getcwd())
    ap.add_argument("--poses", default="cheer,idle,point")
    a = ap.parse_args(argv)
    ev = os.path.join(a.root, "production/qa/evidence/wizard-v2")
    stages = {"ui", "turn", "glb"} if a.stage == "all" else set(a.stage.split(","))

    if "ui" in stages:
        for pose in a.poses.split(","):
            sc = reset(a.samples)
            parts = build(pose, materials())
            P = sample_points(parts["wizard"] + parts["cloud"] + [parts["star"]])
            place_view(sc, P, -32, 12, 0.03, 1024, 1024)
            render(sc, os.path.join(a.root, f"assets/art/ui/wizard_{pose}.png"))

    if "turn" in stages:
        sc = reset(max(12, a.samples // 2))
        parts = build("idle", materials())
        P = sample_points(parts["wizard"] + parts["cloud"] + [parts["star"]])
        for nm, yaw in (("front", 0), ("three_quarter", -40), ("side", -90), ("back", 180)):
            place_view(sc, P, yaw, 8, 0.05, 560, 560)
            render(sc, os.path.join(ev, f"tile_{nm}.png"))

    if "glb" in stages:
        sc = reset(16)
        parts = build("idle", materials())
        bake_and_export(parts, None, a.root, 16)
        sc.cycles.samples = max(12, a.samples // 2)
        P = sample_points(parts["cloud"][:1] if False else [o for o in bpy.data.objects if o.type == "MESH"])
        place_view(sc, P, -32, 12, 0.04, 640, 640)
        render(sc, os.path.join(ev, "glb_lowpoly_preview.png"))


if __name__ == "__main__":
    main()
