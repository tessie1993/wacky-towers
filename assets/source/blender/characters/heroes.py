"""Wacky Towers -- the three playable heroes: Knight, Dwarf and Elf ("Sif") (Blender 5.2.2, headless, Cycles CPU).

They reskin heroes C2, C3 and C4 (design/decisions/2026-10-14-story-cast-decisions.md); cast looks
from design/art/art-bible.md section 5 and design/gdd/narrative/story-v2.md section 2.1.

Recipe: design/art/style-techniques.md section 6, the same as the wizard. Helpers, materials, the
light rig and the render setup are imported from wizard.py (one source of truth), so every
character is lit, shaded and framed the same way.
  - metaballs for the soft masses (head, torso, hair, beard, plume), skin-modifier limbs,
    voxel remesh + smooth, CLOUDS displacement folds
  - small glossy black oval eyes with two catch-lights, round pink nose, vertex-paint blush,
    closed-eye smile for "cheer"
  - game mesh: decimate to TRI_BUDGET_BODY, one shared 1024 px albedo bake (AO multiplied in)
    plus a 1024 px glTF metallic-roughness map so the knight's silver stays metal in Godot

Usage (from the repo root):
  blender -b -P assets/source/blender/characters/heroes.py -- [--stage ui,portrait,lineup,glb,turn]
          [--heroes knight,dwarf,elf] [--samples 32] [--root /path/to/repo]

Outputs (relative to the repo root):
  assets/models/characters/{knight,dwarf,elf}.glb     nodes: <hero> (+ child <hero>_prop); origin at the feet
  assets/art/ui/<hero>_{idle,cheer}.png                1024 px transparent 3/4 renders
  assets/art/ui/portraits/<hero>.png                   256 px head-and-shoulders portraits
  production/qa/evidence/heroes-v2/*.png               lineup with the wizard, turnarounds, bake previews

Coordinates while modelling: Z up, the hero faces -Y (glTF +Z), feet at z = 0. Parts are authored in
nominal metres and every hero is scaled by the same HERO_SCALE, so heads, hands and eyes match
across the cast; feet are then moved to z = 0.
"""
import argparse
import math
import os
import sys

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wizard as wz  # noqa: E402  (shared helpers, materials, render rig)
from wizard import B, E, add_mods, ellipsoid, join, link, mesh_obj, metaball, realize, sweep  # noqa: E402

HEROES = ("knight", "dwarf", "elf")
HERO_SCALE = 1.12      # nominal -> metres; one scale for all so heads match (knight ~1.3 m with plume, elf ~1.2, dwarf ~1.1)
TRI_BUDGET_BODY = 7000
TRI_BUDGET_PROP = 1200
BAKE_SIZE = 1024
HAND_K = 1.3            # mitten size relative to the wizard's (big hands are part of the look)
Z = Vector((0, 0, 1))

HPAL = {
    # shared face
    "skin": "f7c9a8", "nose": "f5ae98", "eye": "1c1222", "mouth": "7a2f3c", "tongue": "e0707a",
    # knight: silver + red
    "silver": "d5dbe6", "steel": "a7b0bf", "dark_steel": "6c7486", "red": "c8352e", "plume": "dc3b33",
    "hair_k": "a2532c", "hair_k_shade": "6a2a44",
    # dwarf: ginger + steel
    "ginger": "e47a2c", "ginger_shade": "9c3d44", "shirt": "4e6a8f", "breeches": "6b4a3a",
    "brass": "c99a3a", "lens": "fff0a0",
    # elf: green + tan
    "tunic": "4fa13c", "hood": "3d8c33", "hood_rim": "2c6a2a", "tan": "d9b07a",
    "blond": "f4d36e", "blond_shade": "c07a52",
    # shared props
    "leather": "8a5a34", "leather_dark": "5a3a2a", "boot": "5a3a2a", "gold": "f8c840", "wood": "a0683a",
    "blade": "e4e9f0", "band": "c8352e",
}


def hx(k):
    return HPAL.get(k, k)


# ---------------------------------------------------------------------------------- materials
def materials():
    p, f, pl = wz.principled, wz.felt, wz.plush
    return {
        "skin": wz.skin_mat(),
        "nose": p("h_nose", hx("nose"), rough=0.4, Subsurface_Weight=0.15, Coat_Weight=0.15),
        "eye": p("h_eye", hx("eye"), rough=0.08, Coat_Weight=0.6),
        "glint": p("h_glint", "ffffff", rough=0.2, Emission_Color=wz.lin("ffffff"), Emission_Strength=3.0),
        "mouth": p("h_mouth", hx("mouth"), rough=0.5),
        "tongue": p("h_tongue", hx("tongue"), rough=0.5),
        "silver": p("silver", hx("silver"), rough=0.3, metal=0.75, Coat_Weight=0.2),
        "steel": p("steel", hx("steel"), rough=0.36, metal=0.7),
        "dark_steel": p("dark_steel", hx("dark_steel"), rough=0.45, metal=0.6),
        "blade": p("blade", hx("blade"), rough=0.22, metal=0.8, Coat_Weight=0.3),
        "red": f("red", hx("red"), rough=0.85, sheen=0.4, bump=0.03),
        "plume": f("plume", hx("plume"), rough=0.9, sheen=0.6, bump=0.06),
        "hair_k": pl("hair_k", hx("hair_k"), hx("hair_k_shade"), 0.06),
        "ginger": pl("ginger", hx("ginger"), hx("ginger_shade"), 0.1),
        "blond": pl("blond", hx("blond"), hx("blond_shade"), 0.06),
        "shirt": f("shirt", hx("shirt"), rough=0.85, sheen=0.4, bump=0.03),
        "breeches": f("breeches", hx("breeches"), rough=0.85, sheen=0.3, bump=0.03),
        "tunic": f("tunic", hx("tunic"), rough=0.85, sheen=0.45, bump=0.03),
        "hood": f("hood", hx("hood"), rough=0.9, sheen=0.5, bump=0.04),
        "hood_rim": f("hood_rim", hx("hood_rim"), rough=0.9, sheen=0.4, bump=0.03),
        "tan": f("tan", hx("tan"), rough=0.85, sheen=0.3, bump=0.03),
        "leather": f("leather", hx("leather"), rough=0.6, sheen=0.1, bump=0.02),
        "leather_dark": f("leather_dark", hx("leather_dark"), rough=0.65, sheen=0.1, bump=0.02),
        "boot": p("h_boot", hx("boot"), rough=0.7),
        "gold": p("h_gold", hx("gold"), rough=0.25, metal=0.8, Emission_Color=wz.lin(hx("gold")), Emission_Strength=0.25),
        "brass": p("brass", hx("brass"), rough=0.35, metal=0.8),
        "lens": p("lens", hx("lens"), rough=0.2, Emission_Color=wz.lin("ffe48a"), Emission_Strength=2.0),
        "wood": f("h_wood", hx("wood"), rough=0.6, sheen=0.0, bump=0.02),
        "band": p("band", hx("band"), rough=0.5),
    }


# --------------------------------------------------------------------------------------- poses
# Arm offsets (elbow, wrist) from the shoulder. R is the hero's right (-X), the prop hand.
ARMS = {
    "idle": {"R": ((-0.07, -0.03, -0.11), (-0.09, -0.11, -0.20)), "R_hand": "fist",
             "L": ((0.07, -0.02, -0.11), (0.08, -0.08, -0.21)), "L_hand": "fist"},
    "cheer": {"R": ((-0.13, -0.03, 0.11), (-0.19, -0.06, 0.25)), "R_hand": "fist",
              "L": ((0.13, -0.03, 0.11), (0.2, -0.07, 0.24)), "L_hand": "open"},
}
PROP_DIR = {   # direction the prop points out of the right fist
    "knight": {"idle": (-0.45, -0.25, 1.0), "cheer": (-0.25, -0.1, 1.0)},
    "dwarf": {"idle": (0.05, 0.45, 1.0), "cheer": (-0.2, -0.05, 1.0)},
    "elf": {"idle": (-0.6, -0.45, 0.75), "cheer": (-0.2, -0.1, 1.0)},
}


# ------------------------------------------------------------------------------- shared parts
def boundary_loops(bm):
    """Ordered coordinate loops along the open edges of a mesh."""
    adj = {}
    for e in bm.edges:
        if e.is_boundary:
            a, b = e.verts
            adj.setdefault(a, []).append(b)
            adj.setdefault(b, []).append(a)
    seen, loops = set(), []
    for start in adj:
        if start in seen:
            continue
        loop, prev, cur = [start], None, start
        seen.add(start)
        while True:
            nxt = [n for n in adj[cur] if n is not prev and n not in seen]
            if not nxt:
                break
            prev, cur = cur, nxt[0]
            seen.add(cur)
            loop.append(cur)
        if len(loop) > 12:
            loops.append([v.co.copy() for v in loop])
    return loops


def shell(name, c, semi, keep, mat, thick=0.018, rim=0.016, rim_mat=None, seg=96):
    """Open ellipsoid shell (helmet, hood): unit-sphere verts failing keep(p) are cut away,
    the cut edge gets a smoothed rolled-lip tube like the wizard's hat brim."""
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=seg // 2, radius=1.0)
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if not keep(v.co)], context="VERTS")
    bm.transform(Matrix.Translation(c) @ Matrix.Diagonal((*semi, 1.0)))
    loops = boundary_loops(bm)
    o = mesh_obj(name, bm, mat)
    so = o.modifiers.new("solid", "SOLIDIFY")
    so.thickness = thick
    so.offset = -1.0
    out = [realize(o)]
    for k, L in enumerate(loops):
        n = len(L)
        for _ in range(8):
            L = [(L[i - 1] + L[i] * 2 + L[(i + 1) % n]) / 4 for i in range(n)]
        out.append(sweep(f"{name}_rim{k}", L[::2], [rim] * len(L[::2]), ring=12, mat=rim_mat or mat, closed=True))
    return out


def slab(name, outline, depth, mat, origin, xdir, ydir, bevel=0.45):
    """Extruded, bevelled 2D outline placed with local x/y axes (sword blade)."""
    bm = bmesh.new()
    vs = [bm.verts.new((x, y, -depth / 2)) for x, y in outline]
    f = bm.faces.new(vs)
    ext = bmesh.ops.extrude_face_region(bm, geom=[f])
    for v in [e for e in ext["geom"] if isinstance(e, bmesh.types.BMVert)]:
        v.co.z += depth
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    o = mesh_obj(name, bm, mat, smooth=False)
    bv = o.modifiers.new("bevel", "BEVEL")
    bv.width = depth * bevel
    bv.segments = 3
    bv.limit_method = "NONE"
    x, y = Vector(xdir).normalized(), Vector(ydir).normalized()
    zz = x.cross(y).normalized()
    R = Matrix((x, y, zz)).transposed().to_4x4()
    o.matrix_world = Matrix.Translation(origin) @ R
    return realize(o)


def head(P, c, semi, M, blush_dx, blush_dz=-0.035):
    h = realize(metaball(P + "mb_head", [E(tuple(c), semi)], res=0.01), P + "head", M["skin"])
    centres = []
    for sx in (-1, 1):
        x, z = sx * blush_dx, c.z + blush_dz
        y = wz.front_y(h, x, z) or (c.y - semi[1])
        centres.append(Vector((x, y, z)))
    attr = h.data.color_attributes.new("blush", "FLOAT_COLOR", "POINT")
    for v in h.data.vertices:
        w = max(max(0.0, 1.0 - (v.co - q).length / 0.068) for q in centres)
        w = w * w * (3 - 2 * w)
        attr.data[v.index].color = (w, w, w, 1.0)
    return h


def face(P, h, c, M, pose, eye_dx, eye_dz=0.02, eye_k=1.15, nose=(0.042, 0.038, 0.038), nose_dz=-0.03,
         nose_push=0.024, mouth_dz=-0.088, smile=True, brows=None, mouth_surface=None, lashes=False):
    """Eyes (open, or happy closed arcs for cheer), nose, brows and mouth, fitted to the head surface."""
    out = []
    k = eye_k
    fy = lambda x, z: wz.front_y(h, x, z)  # noqa: E731
    cheer = pose == "cheer"
    for sx in (-1, 1):
        ex, ez = sx * eye_dx, c.z + eye_dz
        ey = fy(ex, ez)
        if not cheer:
            out.append(ellipsoid(f"{P}eye{sx}", (ex, ey + 0.005 * k, ez), (0.024 * k, 0.014 * k, 0.034 * k), M["eye"]))
            out.append(ellipsoid(f"{P}glint{sx}a", (ex - 0.007 * k, ey - 0.008 * k, ez + 0.012 * k), (0.008 * k,) * 3, M["glint"], seg=12))
            out.append(ellipsoid(f"{P}glint{sx}b", (ex + 0.007 * k, ey - 0.007 * k, ez - 0.012 * k), (0.0042 * k,) * 3, M["glint"], seg=10))
        if lashes:
            x0, z0 = ex + sx * 0.02 * k, ez + 0.022 * k
            pts = [(x0 + sx * 0.012 * t, (fy(x0 + sx * 0.012 * t, z0 + 0.012 * t * t) or ey) - 0.004, z0 + 0.012 * t * t)
                   for t in (0.0, 0.5, 1.0)]
            out.append(sweep(f"{P}lash{sx}", pts, [0.0055, 0.0045, 0.002], ring=8, n=8, mat=M["eye"]))
        else:
            pts = []
            for i in range(9):
                t = -1 + 2 * i / 8
                x, z = ex + 0.026 * k * t, ez - 0.004 + 0.016 * k * (1 - t * t)
                pts.append((x, fy(x, z) - 0.002, z))
            out.append(sweep(f"{P}eye{sx}", pts, [0.0045 * k, 0.0065 * k, 0.0065 * k, 0.0045 * k], ring=10, n=24, mat=M["eye"]))
        if brows:
            kind, bmat = brows
            bz = ez + 0.058 * k
            if kind == "tube":
                pts = []
                for i in range(7):
                    t = -1 + 2 * i / 6
                    x, z = ex + 0.03 * k * t, bz + 0.008 * (1 - t * t) - 0.004 * t * sx
                    pts.append((x, fy(x, z) - 0.003, z))
                out.append(sweep(f"{P}brow{sx}", pts, [0.006, 0.009, 0.009, 0.006], ring=10, n=16, mat=M[bmat]))
            else:   # bushy (dwarf): a row of soft lumps, like the wizard's brows
                els = []
                for i in range(6):
                    t = i / 5
                    x = sx * (eye_dx - 0.035 + 0.085 * t)
                    z = bz + 0.01 * math.sin(math.pi * t) - 0.012 * t * t
                    els.append(B((x, fy(x, z) - 0.006, z), 0.03 - 0.008 * t))
                out.append(realize(metaball(f"{P}mb_brow{sx}", els, res=0.006), f"{P}brow{sx}", M[bmat]))
    nz = c.z + nose_dz
    ny = fy(0, nz)
    out.append(ellipsoid(P + "nose", (0, ny - nose_push, nz), nose, M["nose"]))
    surf = mouth_surface or h
    mz = c.z + mouth_dz
    my = wz.front_y(surf, 0, mz) or (ny + 0.02)
    if cheer:
        out.append(ellipsoid(P + "mouth", (0, my + 0.012, mz), (0.046, 0.02, 0.03), M["mouth"]))
        out.append(ellipsoid(P + "tongue", (0, my + 0.006, mz - 0.013), (0.026, 0.012, 0.012), M["tongue"], seg=16))
    elif smile:
        pts = []
        for i in range(9):
            t = -1 + 2 * i / 8
            x, z = 0.042 * t, mz + 0.016 * t * t
            pts.append((x, (wz.front_y(surf, x, z) or my) - 0.001, z))
        out.append(sweep(P + "smile", pts, [0.004, 0.0065, 0.0065, 0.004], ring=10, n=24, mat=M["mouth"]))
    return out


def body(P, M, elems, mat, pose, shoulder, arm_r, res=0.014, remesh=0.009, folds=(0.07, 0.008), belts=()):
    """Torso metaballs + skin-modifier arms -> join -> voxel remesh -> smooth -> folds.
    Belts are fitted on an arm-free copy of the torso so they never bulge over the sleeves."""
    torso = realize(metaball(P + "mb_torso", elems, res=res), P + "torso")
    extra = []
    if belts:
        cp = link(torso.copy())
        cp.data = torso.data.copy()
        add_mods(cp, remesh=remesh, smooth=(0.5, 10))
        cp = realize(cp, P + "torso_probe")
        for nm, z, tube, bmat, buckle in belts:
            r = wz.trim_ring(P + nm, cp, (0, 0, z), (0, 0, 1), tube, M[bmat], n=48, slab=0.008, push=0.003)
            if r:
                extra.append(r)
            if buckle:
                by = wz.front_y(cp, 0, z)
                if by is not None:
                    extra.append(ellipsoid(P + nm + "_buckle", (0, by - tube - 0.004, z), (0.034, 0.012, 0.03), M[buckle]))
        bpy.data.objects.remove(cp)
    sleeves, dirs = [], {}
    sx, sz = shoulder
    for side, sgn in (("R", -1), ("L", 1)):
        S = Vector((sgn * sx, 0.0, sz))
        El, Wr = S + Vector(ARMS[pose][side][0]), S + Vector(ARMS[pose][side][1])
        d = (Wr - El).normalized()
        dirs[side] = (Wr, d)
        sleeves.append(wz.skin_limb(f"{P}arm{side}", [S, El, Wr, Wr + d * 0.03], list(arm_r)))
    o = join([torso] + sleeves, P + "body")
    o.data.materials.clear()
    o.data.materials.append(M[mat])
    add_mods(o, remesh=remesh, smooth=(0.5, 10), displace=folds)
    return realize(o), dirs, extra


def legs(P, M, hip_x, hip_z, mat, boot_mat, r=(0.075, 0.068, 0.062), boot=(0.075, 0.105, 0.055)):
    out = []
    for sx in (-1, 1):
        lg = wz.skin_limb(f"{P}leg{sx}", [(sx * hip_x, 0, hip_z), (sx * (hip_x + 0.006), -0.01, (hip_z + 0.075) / 2),
                                         (sx * (hip_x + 0.01), -0.01, 0.075)], list(r))
        lg.data.materials.append(M[mat])
        out.append(lg)
        rot = Matrix.Rotation(math.radians(sx * -12), 4, "Z")
        out.append(ellipsoid(f"{P}boot{sx}", (sx * (hip_x + 0.012), -0.035, boot[2]), boot, M[boot_mat], rot=rot))
    return out


def mitten(name, Wr, d, kind, mat, k=HAND_K):
    """The wizard's mitten hands, scaled up. Returns (object, palm centre)."""
    side_v = d.cross(Z)
    if side_v.length < 0.1:
        side_v = Vector((1, 0, 0))
    side_v.normalize()
    up = side_v.cross(d).normalized()
    pc = Wr + d * 0.055 * k
    if kind == "fist":
        els = [B(pc, 0.046 * k), B(pc + d * 0.022 * k - up * 0.008 * k, 0.042 * k), B(pc + up * 0.036 * k - side_v * 0.016 * k, 0.021 * k)]
    else:
        els = [E(pc + d * 0.01 * k, (0.05 * k, 0.05 * k, 0.035 * k)), B(pc + d * 0.05 * k, 0.036 * k),
               B(pc + d * 0.02 * k + up * 0.045 * k, 0.021 * k)]
    return realize(metaball("mb_" + name, els, res=0.008), name, mat), pc


def hands(P, M, dirs, pose, mat):
    out, pcs = [], {}
    for side in ("R", "L"):
        Wr, d = dirs[side]
        o, pc = mitten(f"{P}hand{side}", Wr, d, ARMS[pose][side + "_hand"], M[mat])
        out.append(o)
        pcs[side] = pc
    return out, pcs


def pauldrons(P, M, shoulder, mat, semi=(0.095, 0.095, 0.06)):
    sx, sz = shoulder
    return [ellipsoid(f"{P}pauldron{sgn}", (sgn * (sx + 0.015), 0.0, sz + 0.01), semi, M[mat],
                      rot=Matrix.Rotation(math.radians(sgn * 28), 4, "Y")) for sgn in (-1, 1)]


def side_axes(u):
    u = Vector(u).normalized()
    s = u.cross(Vector((0, 1, 0)))
    if s.length < 0.2:
        s = Vector((1, 0, 0))
    s.normalize()
    return u, s, s.cross(u).normalized()


# ------------------------------------------------------------------------------------- props
def sword(P, pc, u, M):
    u, s, n = side_axes(u)
    return [sweep(P + "grip", [pc - u * 0.06, pc, pc + u * 0.06], [0.017] * 3, ring=12, n=8, mat=M["leather"]),
            ellipsoid(P + "pommel", pc - u * 0.078, (0.026,) * 3, M["gold"], seg=16),
            sweep(P + "guard", [pc + u * 0.062 - s * 0.1, pc + u * 0.07, pc + u * 0.062 + s * 0.1],
                  [0.016, 0.02, 0.016], ring=12, n=12, mat=M["gold"]),
            slab(P + "blade", [(-0.04, 0), (0.04, 0), (0.04, 0.34), (0, 0.42), (-0.04, 0.34)], 0.02,
                 M["blade"], pc + u * 0.075, s, u)]


def pickaxe(P, pc, u, M):
    u, s, n = side_axes(u)
    h = pc + u * 0.30
    return [sweep(P + "handle", [pc - u * 0.13, pc + u * 0.08, h + u * 0.02], [0.02, 0.019, 0.018], ring=12, n=12, mat=M["wood"]),
            sweep(P + "head", [h - s * 0.19 - u * 0.07, h - s * 0.1 - u * 0.005, h + u * 0.015, h + s * 0.1 - u * 0.005,
                               h + s * 0.19 - u * 0.07], [0.004, 0.026, 0.04, 0.026, 0.004], ring=16, n=40, mat=M["steel"]),
            sweep(P + "collar", [h - u * 0.05, h - u * 0.02], [0.03, 0.03], ring=16, n=4, mat=M["brass"]),
            ellipsoid(P + "knob", pc - u * 0.135, (0.026,) * 3, M["wood"], seg=16)]


def slingshot(P, pc, u, M, k=1.45):
    u, s, n = side_axes(u)
    t = pc + u * 0.07 * k
    out = [sweep(P + "grip", [pc - u * 0.065 * k, pc, t], [0.019 * k, 0.017 * k, 0.017 * k], ring=12, n=10, mat=M["wood"])]
    tips = []
    for sg in (-1, 1):
        a, b = t + (u * 0.04 + s * sg * 0.03) * k, t + (u * 0.1 + s * sg * 0.055) * k
        out.append(sweep(f"{P}prong{sg}", [t, a, b], [0.016 * k, 0.014 * k, 0.012 * k], ring=12, n=12, mat=M["wood"]))
        out.append(ellipsoid(f"{P}tip{sg}", b, (0.016 * k,) * 3, M["wood"], seg=12))
        tips.append(b)
    mid = (tips[0] + tips[1]) / 2 + (n * 0.05 - u * 0.02) * k
    out.append(sweep(P + "band", [tips[0], (tips[0] + mid) / 2 + n * 0.005, mid, (tips[1] + mid) / 2 + n * 0.005, tips[1]],
                     [0.007] * 5, ring=8, n=24, mat=M["band"]))
    out.append(ellipsoid(P + "pouch", mid, (0.03 * k, 0.02 * k, 0.022 * k), M["leather"], seg=16))
    return out


# ------------------------------------------------------------------------------------- heroes
def build_knight(pose, M, P="K_"):
    """Young knight: silver plate, red plume and skirt, auburn fringe, round friendly face, sword."""
    c, semi = Vector((0, -0.01, 0.80)), (0.205, 0.19, 0.195)
    sh = (0.17, 0.53)
    parts, lights = [], []
    h = head(P, c, semi, M, blush_dx=0.112)
    parts.append(h)
    parts += face(P, h, c, M, pose, eye_dx=0.072, eye_dz=0.0, mouth_dz=-0.098, brows=None, lashes=True)
    # auburn fringe peeking under the helmet, short bob under the cheek guards
    els = []
    for i in range(9):
        t = -1 + 2 * i / 8
        x, z = 0.15 * t, c.z + 0.078 - 0.022 * t * t
        els.append(B((x, (wz.front_y(h, x, z) or -0.2) + 0.012, z), 0.033))
    for sx in (-1, 1):
        els += [B((sx * 0.16, c.y - 0.03, c.z - 0.085), 0.05), B((sx * 0.12, c.y + 0.03, c.z - 0.11), 0.05)]
    els.append(E((0, c.y + 0.1, c.z - 0.08), (0.15, 0.08, 0.07)))
    parts.append(realize(metaball(P + "mb_hair", els, res=0.008), P + "hair", M["hair_k"]))
    # open-faced helmet with cheek guards, rolled rim
    hc = c + Vector((0, 0.005, 0.015))
    hsemi = (semi[0] * 1.12, semi[1] * 1.13, semi[2] * 1.12)
    parts += shell(P + "helmet", hc, hsemi, lambda p: p.z > -0.45 and not (p.y < -0.1 and p.z < 0.3),
                   M["silver"], rim=0.017)
    top = hc.z + hsemi[2]
    # red plume: chain of soft lobes arcing front-to-back over the crest
    els = []
    for dy, dz, r in ((-0.06, 0.02, 0.05), (-0.01, 0.075, 0.068), (0.07, 0.105, 0.078), (0.16, 0.095, 0.078),
                      (0.24, 0.05, 0.07), (0.3, -0.02, 0.062), (0.33, -0.1, 0.052), (0.33, -0.17, 0.04)):
        p = (0, c.y + dy, top + dz)
        els.append(B(p, r))
        for sx in (-1, 1):
            els.append(B((sx * 0.042, c.y + dy + 0.01, top + dz - 0.012), r * 0.75))
    plume = realize(metaball(P + "mb_plume", els, res=0.009), P + "plume", M["plume"])
    add_mods(plume, remesh=0.008, smooth=(0.6, 12), displace=(0.05, 0.01))
    parts.append(realize(plume))
    parts.append(sweep(P + "plume_socket", [(0, c.y - 0.06, top - 0.03), (0, c.y - 0.05, top + 0.02)], [0.028, 0.026],
                       ring=16, n=4, mat=M["gold"]))
    # chest + arms in silver plate, red skirt below, leather belt with gold buckle
    b, dirs, extra = body(P, M, [E((0, 0.0, 0.47), (0.185, 0.155, 0.13)), E((0, 0, 0.41), (0.195, 0.165, 0.1))],
                          "silver", pose, sh, (0.062, 0.058, 0.066, 0.07), folds=(0.07, 0.003),
                          belts=[("belt", 0.355, 0.02, "leather_dark", "gold")])
    parts += [b] + extra
    skirt = realize(metaball(P + "mb_skirt", [E((0, 0, 0.31), (0.2, 0.17, 0.09)), E((0, -0.005, 0.255), (0.215, 0.18, 0.06))],
                             res=0.012), P + "skirt", M["red"])
    add_mods(skirt, remesh=0.009, smooth=(0.5, 10), displace=(0.06, 0.01))
    parts.append(realize(skirt))
    parts += pauldrons(P, M, sh, "silver")
    parts += legs(P, M, 0.085, 0.26, "steel", "dark_steel")
    hs, pcs = hands(P, M, dirs, pose, "steel")
    parts += hs
    prop = sword(P, pcs["R"], Vector(PROP_DIR["knight"][pose]), M)
    return parts, prop, lights, sh


def build_dwarf(pose, M, P="D_"):
    """Stocky dwarf: ginger braided beard, steel helmet with a miner's lamp, leather apron, pickaxe."""
    c, semi = Vector((0, -0.015, 0.72)), (0.215, 0.2, 0.19)
    sh = (0.2, 0.47)
    parts, lights = [], []
    h = head(P, c, semi, M, blush_dx=0.12, blush_dz=-0.02)
    parts.append(h)
    # beard + back hair: one soft ginger mass, two braids with gold bands below
    cz = c.z
    els = [E((0, -0.14, cz - 0.11), (0.2, 0.11, 0.1)), E((0, -0.17, cz - 0.22), (0.18, 0.1, 0.12)),
           B((0, -0.24, cz - 0.32), 0.075), E((0, 0.07, cz + 0.0), (0.2, 0.15, 0.13))]
    for sx in (-1, 1):
        els += [B((sx * 0.16, -0.1, cz - 0.05), 0.075), B((sx * 0.195, -0.02, cz + 0.02), 0.06),
                B((sx * 0.11, -0.23, cz - 0.29), 0.075), B((sx * 0.07, -0.25, cz - 0.36), 0.06)]
    beard = realize(metaball(P + "mb_beard", els, res=0.011), P + "beard", M["ginger"])
    add_mods(beard, remesh=0.008, smooth=(0.6, 14), displace=(0.05, 0.008))
    beard = realize(beard)
    parts.append(beard)
    for sx in (-1, 1):
        x = sx * 0.08
        els = []
        for i in range(5):
            r = 0.036 - 0.003 * i
            els.append(E((x, -0.262 - 0.004 * i, cz - 0.37 - 0.045 * i), (r, r * 0.9, r * 0.85)))
        parts.append(realize(metaball(f"{P}mb_braid{sx}", els, res=0.007), f"{P}braid{sx}", M["ginger"]))
        zb = cz - 0.37 - 0.045 * 4 - 0.035
        ring = [(x + 0.024 * math.cos(2 * math.pi * i / 16), -0.278 + 0.022 * math.sin(2 * math.pi * i / 16), zb)
                for i in range(16)]
        parts.append(sweep(f"{P}braidband{sx}", ring, [0.009] * 16, ring=10, mat=M["gold"], closed=True))
        parts.append(ellipsoid(f"{P}tuft{sx}", (x, -0.278, zb - 0.032), (0.028, 0.025, 0.034), M["ginger"], seg=16))
    # moustache: two lobes over the beard
    els = []
    for sx in (-1, 1):
        for i in range(9):
            t = i / 8
            x = sx * (0.02 + 0.13 * t)
            z = cz - 0.065 - 0.02 * math.sin(math.pi * t) + 0.03 * t ** 3
            y0 = wz.front_y(beard, x, z) or -0.25
            els.append(B((x, y0 + 0.016 - 0.008 * t, z), 0.046 - 0.017 * t))
    parts.append(realize(metaball(P + "mb_stache", els, res=0.008), P + "stache", M["ginger"]))
    parts += face(P, h, c, M, pose, eye_dx=0.075, eye_dz=0.015, nose=(0.06, 0.05, 0.052), nose_dz=-0.035,
                  nose_push=0.032, mouth_dz=-0.135, smile=False, brows=("bushy", "ginger"), mouth_surface=beard)
    # steel dome helmet, rolled rim, brass miner's lamp
    hc = c + Vector((0, 0.0, 0.06))
    hsemi = (semi[0] * 1.12, semi[1] * 1.13, semi[2] * 1.12)
    helm = shell(P + "helmet", hc, hsemi, lambda p: p.z > 0.12, M["steel"], rim=0.02, rim_mat=M["dark_steel"])
    parts += helm
    loc, nrm = wz.cast(helm[0], (0, -2, hc.z + 0.12), (0, 1, 0))
    if loc is not None:
        q = nrm.to_track_quat("Z", "Y").to_matrix().to_4x4()
        parts.append(sweep(P + "lamp", [loc - nrm * 0.01, loc + nrm * 0.03], [0.04, 0.04], ring=20, n=4, mat=M["brass"]))
        parts.append(ellipsoid(P + "lens", loc + nrm * 0.035, (0.032, 0.032, 0.01), M["lens"], rot=q))
        ld = bpy.data.lights.new(P + "lamp_glow", "POINT")      # render-only warm glow, not exported
        ld.color, ld.energy, ld.shadow_soft_size = wz.lin("ffd76a")[:3], 4.0, 0.04
        lo = link(bpy.data.objects.new(P + "lamp_glow", ld))
        lo.location = loc + nrm * 0.09
        lights.append(lo)
    # shirt + arms, steel pauldrons, leather apron, belt
    b, dirs, extra = body(P, M, [E((0, 0, 0.40), (0.235, 0.2, 0.16)), E((0, -0.01, 0.29), (0.25, 0.21, 0.11))],
                          "shirt", pose, sh, (0.07, 0.065, 0.072, 0.078),
                          belts=[("belt", 0.27, 0.022, "leather_dark", "brass")])
    parts += [b] + extra
    parts.append(apron(P + "apron", b, 0.115, 0.0, 0.40, 0.13, 0.16, M["leather"]))
    parts += pauldrons(P, M, sh, "steel", semi=(0.09, 0.09, 0.055))
    parts += legs(P, M, 0.1, 0.21, "breeches", "boot", r=(0.08, 0.074, 0.068), boot=(0.085, 0.115, 0.06))
    hs, pcs = hands(P, M, dirs, pose, "skin")
    parts += hs
    prop = pickaxe(P, pcs["R"], Vector(PROP_DIR["dwarf"][pose]), M)
    return parts, prop, lights, sh


def apron(name, target, z0, _unused, z1, w_top, w_bot, mat):
    """Leather apron: a trapezoid grid ray-projected onto the front of the torso, then solidified."""
    bm = bmesh.new()
    nu, nv = 14, 16
    V = []
    for j in range(nv + 1):
        t = j / nv
        z = z0 + (z1 - z0) * t
        w = w_bot + (w_top - w_bot) * t
        row = []
        for i in range(nu + 1):
            s = -1 + 2 * i / nu
            zz = z - (0.025 * (1 - s * s) if j == 0 else 0.0)     # rounded hem
            row.append([s * w, zz])
        V.append(row)
    # front-project every vertex onto the torso; below the belly the apron hangs straight down
    for i in range(nu + 1):
        last = None
        for j in range(nv, -1, -1):
            x, z = V[j][i]
            y = wz.front_y(target, x, z)
            if y is not None and y < -0.05:
                last = y if last is None else min(y, last + 0.004)
            V[j][i] = bm.verts.new((x, (last if last is not None else -0.2) - 0.006, z))
    for j in range(nv):
        for i in range(nu):
            bm.faces.new((V[j][i], V[j][i + 1], V[j + 1][i + 1], V[j + 1][i]))
    o = mesh_obj(name, bm, mat)
    so = o.modifiers.new("solid", "SOLIDIFY")
    so.thickness = 0.012
    so.offset = 1.0
    o.modifiers.new("sub", "SUBSURF").levels = 1
    return realize(o)


def build_elf(pose, M, P="E_"):
    """Elf "Sif": green tunic and pointed hood, blond fringe, pointed ears, tan breeches, slingshot."""
    c, semi = Vector((0, -0.01, 0.80)), (0.203, 0.188, 0.197)
    sh = (0.158, 0.535)
    parts, lights = [], []
    h = head(P, c, semi, M, blush_dx=0.108)
    parts.append(h)
    parts += face(P, h, c, M, pose, eye_dx=0.07, eye_dz=0.012, brows=("tube", "blond"))
    # pointed ears out through the hood opening (flattened swept cones)
    for sx in (-1, 1):
        base = Vector((sx * 0.17, c.y + 0.0, c.z - 0.01))
        ear = sweep(f"{P}ear{sx}", [base, base + Vector((sx * 0.07, 0.02, 0.03)), base + Vector((sx * 0.15, 0.04, 0.085))],
                    [0.042, 0.03, 0.006], ring=16, n=16, mat=M["skin"])
        ear.data.transform(Matrix.Translation(base) @ Matrix.Diagonal((1, 0.5, 1, 1)) @ Matrix.Translation(-base))
        parts.append(ear)
    # swoopy blond fringe + side locks
    els = []
    for i in range(9):
        t = -1 + 2 * i / 8
        x, z = 0.15 * t, c.z + 0.105 - 0.04 * t * t + 0.015 * t
        els.append(B((x, (wz.front_y(h, x, z) or -0.19) + 0.012, z), 0.046))
    for sx in (-1, 1):
        els += [B((sx * 0.165, c.y - 0.06, c.z - 0.03), 0.048), B((sx * 0.15, c.y - 0.07, c.z - 0.085), 0.04)]
    hair = realize(metaball(P + "mb_hair", els, res=0.008), P + "hair", M["blond"])
    add_mods(hair, remesh=0.007, smooth=(0.5, 8))
    parts.append(realize(hair))
    # pointed hood: open shell (front and ear gap cut away), drooping tip, collar
    hc = c + Vector((0, 0.012, 0.02))
    hsemi = (semi[0] * 1.15, semi[1] * 1.17, semi[2] * 1.15)
    parts += shell(P + "hood", hc, hsemi, lambda p: p.z > -0.6 and not (p.y < 0.06 and p.z < 0.42), M["hood"],
                   thick=0.02, rim=0.02, rim_mat=M["hood_rim"])
    p0 = hc + Vector((0, 0.62 * hsemi[1], 0.6 * hsemi[2]))
    tip = sweep(P + "hood_tip", [p0, p0 + Vector((0, 0.11, -0.01)), p0 + Vector((-0.05, 0.2, -0.06)), p0 + Vector((-0.15, 0.22, -0.17))],
                [0.1, 0.07, 0.04, 0.01], ring=24, n=30, mat=M["hood"])
    add_mods(tip, smooth=None, displace=(0.06, 0.006))
    parts.append(realize(tip))
    collar = [(0.17 * math.cos(2 * math.pi * i / 32), 0.15 * math.sin(2 * math.pi * i / 32) + 0.005,
               0.585 - 0.015 * max(0.0, -math.sin(2 * math.pi * i / 32))) for i in range(32)]
    parts.append(sweep(P + "collar", collar, [0.04] * 32, ring=16, mat=M["hood"], closed=True, wobble=0.08))
    # tunic + arms (flares into a short skirt), belt with buckle, tan hem trim
    b, dirs, extra = body(P, M, [E((0, 0, 0.45), (0.17, 0.142, 0.145)), E((0, 0, 0.33), (0.192, 0.16, 0.1)),
                                 E((0, 0, 0.27), (0.212, 0.176, 0.06))],
                          "tunic", pose, sh, (0.056, 0.052, 0.06, 0.066),
                          belts=[("belt", 0.37, 0.018, "leather", "gold"), ("hem", 0.245, 0.014, "tan", None)])
    parts += [b] + extra
    parts += legs(P, M, 0.075, 0.26, "tan", "boot", r=(0.066, 0.06, 0.056), boot=(0.068, 0.1, 0.052))
    hs, pcs = hands(P, M, dirs, pose, "skin")
    parts += hs
    prop = slingshot(P, pcs["R"], Vector(PROP_DIR["elf"][pose]), M)
    return parts, prop, lights, sh


BUILDERS = {"knight": build_knight, "dwarf": build_dwarf, "elf": build_elf}


def zrange(objs):
    zs = np.concatenate([wz.sample_points([o], cap=10 ** 9)[:, 2] for o in objs])
    return float(zs.min()), float(zs.max())


def build(hero, pose, M):
    """Build the high-res hero, scaled by HERO_SCALE with the feet at z = 0."""
    parts, prop, lights, sh = BUILDERS[hero](pose, M)
    lo, hi = zrange(parts)
    s = HERO_SCALE
    N = Matrix.Translation((0, 0, -lo * s)) @ Matrix.Scale(s, 4)
    for o in parts + prop:
        o.data.transform(N)
        o.data.update()
    for lo_ in lights:
        lo_.location = N @ lo_.location
    return {"body": parts, "prop": prop, "lights": lights, "scale": s, "neck_z": (sh[1] - 0.06) * s - lo * s}


# --------------------------------------------------------------------------------- bake + glb
def bake_and_export(hero, parts, root, ev, samples):
    sc = bpy.context.scene
    body = wz.decimate(parts["body"], TRI_BUDGET_BODY)
    prop = wz.decimate(parts["prop"], TRI_BUDGET_PROP)
    b = join(body, hero)
    p = join(prop, hero + "_prop")
    objs = [b, p]
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = b
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(60), island_margin=0.004)
    bpy.ops.object.mode_set(mode="OBJECT")

    alb = bpy.data.images.new(f"wt_{hero}_albedo", BAKE_SIZE, BAKE_SIZE, alpha=False)
    ao = bpy.data.images.new(f"wt_{hero}_ao", BAKE_SIZE, BAKE_SIZE, alpha=False)
    orm = bpy.data.images.new(f"wt_{hero}_mr", BAKE_SIZE, BAKE_SIZE, alpha=False)
    for im in (ao, orm):
        im.colorspace_settings.name = "Non-Color"
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
    # 1) glTF metallic-roughness (G = roughness, B = metallic) via an emission bake
    for m in mats:
        nt, bs = wz._bsdf(m)
        rough, metal = bs.inputs["Roughness"].default_value, bs.inputs["Metallic"].default_value
        for ln in list(nt.links):
            if ln.to_socket in (bs.inputs["Emission Color"], bs.inputs["Emission Strength"]):
                nt.links.remove(ln)
        bs.inputs["Emission Color"].default_value = (0.0, rough, metal, 1.0)
        bs.inputs["Emission Strength"].default_value = 1.0
        bs.inputs["Metallic"].default_value = 0.0      # 2) metals bake their tint into the albedo
    target(orm)
    bpy.ops.object.bake(type="EMIT", margin=8, use_clear=True)
    target(alb)
    bpy.ops.object.bake(type="DIFFUSE", pass_filter={"COLOR"}, margin=8, use_clear=True)
    target(ao)
    bpy.ops.object.bake(type="AO", margin=8, use_clear=True)
    a = np.array(alb.pixels[:]).reshape(-1, 4)
    o_ = np.array(ao.pixels[:]).reshape(-1, 4)[:, :1]
    a[:, :3] *= 0.62 + 0.38 * o_
    alb.pixels = a.ravel().tolist()
    os.makedirs(ev, exist_ok=True)
    paths = {}
    for im, nm in ((alb, "albedo"), (orm, "metal_rough")):
        paths[nm] = os.path.join(ev, f"{hero}_{nm}_1024.png")
        im.filepath_raw = paths[nm]
        im.file_format = "PNG"
        im.save()

    baked = bpy.data.materials.new(f"wt_{hero}_baked")
    try:
        baked.use_nodes = True
    except (AttributeError, TypeError):
        pass
    nt, bs = wz._bsdf(baked)
    tn = nt.nodes.new("ShaderNodeTexImage")
    tn.image = bpy.data.images.load(paths["albedo"])
    tn.image.name = f"{hero}_albedo"
    nt.links.new(tn.outputs["Color"], bs.inputs["Base Color"])
    tm = nt.nodes.new("ShaderNodeTexImage")
    tm.image = bpy.data.images.load(paths["metal_rough"])
    tm.image.name = f"{hero}_metal_rough"
    tm.image.colorspace_settings.name = "Non-Color"
    sep = nt.nodes.new("ShaderNodeSeparateColor")
    nt.links.new(tm.outputs["Color"], sep.inputs[0])
    nt.links.new(sep.outputs[1], bs.inputs["Roughness"])
    nt.links.new(sep.outputs[2], bs.inputs["Metallic"])
    for o in objs:
        o.data.materials.clear()
        o.data.materials.append(baked)
        for poly in o.data.polygons:
            poly.material_index = 0
    p.parent = b
    p.matrix_parent_inverse = Matrix.Identity(4)

    glb = os.path.join(root, f"assets/models/characters/{hero}.glb")
    os.makedirs(os.path.dirname(glb), exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB", use_selection=True,
                              export_apply=True, export_yup=True)
    lo, hi = zrange([b])
    print("WROTE", glb, "tris body", wz.tri_count(b), "prop", wz.tri_count(p), f"height {hi - lo:.3f} m zmin {lo:.4f}")
    return objs


# ------------------------------------------------------------------------------------------ main
def offset_group(objs, lights, dx):
    T = Matrix.Translation((dx, 0, 0))
    for o in objs:
        o.data.transform(T)
        o.data.update()
    for lo in lights:
        lo.location.x += dx


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", default="ui,portrait,lineup,glb")
    ap.add_argument("--heroes", default=",".join(HEROES))
    ap.add_argument("--samples", type=int, default=32)
    ap.add_argument("--res", type=int, default=1024)
    ap.add_argument("--root", default=os.getcwd())
    a = ap.parse_args(argv)
    ev = os.path.join(a.root, "production/qa/evidence/heroes-v2")
    stages = set(a.stage.split(","))
    heroes = [h for h in a.heroes.split(",") if h]

    for hero in heroes:
        if "ui" in stages or "portrait" in stages:
            for pose in (("idle", "cheer") if "ui" in stages else ("idle",)):
                sc = wz.reset(a.samples)
                parts = build(hero, pose, materials())
                P = wz.sample_points(parts["body"] + parts["prop"])
                if "ui" in stages:
                    wz.place_view(sc, P, -32, 12, 0.03, a.res, a.res)
                    wz.render(sc, os.path.join(a.root, f"assets/art/ui/{hero}_{pose}.png"))
                if "portrait" in stages and pose == "idle":
                    Q = wz.sample_points(parts["body"])
                    Q = Q[Q[:, 2] > parts["neck_z"] - 0.1]
                    sc.cycles.samples = max(48, a.samples)
                    wz.place_view(sc, Q, -26, 6, 0.05, 256, 256)
                    wz.render(sc, os.path.join(a.root, f"assets/art/ui/portraits/{hero}.png"))
        if "turn" in stages:
            sc = wz.reset(max(12, a.samples // 2))
            parts = build(hero, "idle", materials())
            P = wz.sample_points(parts["body"] + parts["prop"])
            for nm, yaw in (("front", 0), ("three_quarter", -40), ("side", -90), ("back", 180)):
                wz.place_view(sc, P, yaw, 8, 0.05, 420, 420)
                wz.render(sc, os.path.join(ev, f"{hero}_tile_{nm}.png"))
        if "glb" in stages:
            sc = wz.reset(16)
            parts = build(hero, "idle", materials())
            bake_and_export(hero, parts, a.root, ev, 16)
            sc.cycles.samples = max(16, a.samples // 2)
            P = wz.sample_points([o for o in bpy.data.objects if o.type == "MESH"])
            wz.place_view(sc, P, -32, 12, 0.04, 560, 560)
            wz.render(sc, os.path.join(ev, f"{hero}_glb_preview.png"))

    if "lineup" in stages:
        sc = wz.reset(a.samples)
        wp = wz.build("idle", wz.materials())
        groups = [(wp["wizard"] + wp["cloud"] + [wp["star"]], [bpy.data.objects["star_glow"]])]
        M = materials()
        for hero in HEROES:
            parts = build(hero, "idle", M)
            groups.append((parts["body"] + parts["prop"], parts["lights"]))
        x = 0.0
        for objs, lights in groups:
            pts = wz.sample_points(objs)
            lo, hi = float(pts[:, 0].min()), float(pts[:, 0].max())
            offset_group(objs, lights, x - lo)
            x += (hi - lo) + 0.12
        P = wz.sample_points([o for g in groups for o in g[0]])
        wz.place_view(sc, P, -14, 8, 0.03, 1800, 760)
        wz.render(sc, os.path.join(ev, "lineup.png"))


if __name__ == "__main__":
    main()
