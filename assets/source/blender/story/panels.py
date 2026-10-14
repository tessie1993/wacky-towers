"""Wacky Towers -- painted story panels S01-S11 as small 3D dioramas (Blender 5.2.2, headless, Cycles CPU).

Spec: design/gdd/narrative/story-v2.md section 7 (panel list + template), design/art/art-bible.md 5e
(story-beat composition), design/art/style-techniques.md 2.2/2.3 (light rig) and 6 (character recipe).

The cast is NOT remodelled: wizard.build() and heroes.build() from ../characters are imported and
placed, so every panel shows the same wizard, knight, dwarf and elf as the game. Props (books,
shelves, potions, globe, islands, blocks, cart, volcano...) are built here from shared helpers.

Template rules baked into every composition:
  - 4:3, 1600 x 1200 (the spec's 2048 x 1536 export is a --scale away; see --res)
  - the bottom 18 percent is kept calm (no faces, no focal object) for the live ribbon title
  - no text in the image; plaque, ribbon and caption are live UI (src/ui/story/story_panel.gd)

Usage (from the repo root):
  blender -b -P assets/source/blender/story/panels.py -- --panel S01[,S02,...|tierA|all]
          [--samples 32] [--preview] [--root /path/to/repo]
  blender -b -P assets/source/blender/story/panels.py -- --sheet      # contact sheet + board compare

Outputs (relative to the repo root):
  assets/art/story/sXX_<slug>.png          1600 x 1200 panel
  assets/art/story/sXX_<slug>_thumb.png    400 x 300 thumbnail
  production/qa/evidence/story-v2/contact_sheet.png, compare_s01_s04_vs_board01.png
"""
import argparse
import math
import os
import random
import sys
import tempfile

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "characters"))
import wizard as wz  # noqa: E402  (cast builders, materials, reset/render)
import heroes as hz  # noqa: E402

W, H = 1600, 1200
Z = Vector((0, 0, 1))
TOY = {"red": "e0483c", "orange": "f08a2c", "yellow": "f8c840", "green": "6cc04a", "blue": "4aa8e8",
       "pink": "ee6aa0", "purple": "b48ad8", "cyan": "4ad8d8"}
TOY_ORDER = ["blue", "pink", "yellow", "green", "red", "purple", "orange", "cyan"]
_MATS = {}


# ------------------------------------------------------------------------------------ materials
def lin(h, a=1.0):
    return wz.lin(h, a)


def _nodes(m):
    return wz._bsdf(m)


def paint(name, base, shade="4a2a6a", rough=0.75, noise=3.0, var=0.18, ao=0.5, emit=0.0, bands=None,
          sheen=0.15, metal=0.0, coat=0.0, emit_col=None):
    """Hand-painted surface: low-frequency value noise, optional wave bands (planks, strata),
    AO-driven purple shade (shadows are tinted, never grey), optional self-glow."""
    key = ("paint", name)
    if key in _MATS:
        return _MATS[key]
    m = wz.principled(name, base, rough=rough, metal=metal, Sheen_Weight=sheen, Coat_Weight=coat)
    nt, b = _nodes(m)
    bc = lin(base)
    dark = tuple(c * (1 - var) for c in bc[:3]) + (1.0,)
    nz = nt.nodes.new("ShaderNodeTexNoise")
    nz.inputs["Scale"].default_value = noise
    nz.inputs["Detail"].default_value = 2.0
    c = wz.mix_rgb(nt, nz.outputs["Fac"], dark, bc)
    if bands:
        scale, depth, axis = bands
        wv = nt.nodes.new("ShaderNodeTexWave")
        wv.bands_direction = axis
        wv.inputs["Scale"].default_value = scale
        wv.inputs["Distortion"].default_value = 2.0
        mx = nt.nodes.new("ShaderNodeMix")
        mx.data_type = "RGBA"
        nt.links.new(wv.outputs["Fac"], mx.inputs[0])
        nt.links.new(c, mx.inputs[6])
        mx.inputs[7].default_value = tuple(x * (1 - depth) for x in bc[:3]) + (1.0,)
        c = mx.outputs[2]
    if ao:
        aon = nt.nodes.new("ShaderNodeAmbientOcclusion")
        aon.inputs["Distance"].default_value = ao
        aon.samples = 8
        mr = nt.nodes.new("ShaderNodeMapRange")
        mr.inputs["From Min"].default_value = 0.5
        mr.inputs["From Max"].default_value = 1.0
        nt.links.new(aon.outputs["AO"], mr.inputs["Value"])
        sh = lin(shade)
        tint = tuple(0.55 * x * 0.6 + 0.45 * s * 0.6 for x, s in zip(bc[:3], sh[:3])) + (1.0,)
        mx = nt.nodes.new("ShaderNodeMix")
        mx.data_type = "RGBA"
        nt.links.new(mr.outputs[0], mx.inputs[0])
        mx.inputs[6].default_value = tint
        nt.links.new(c, mx.inputs[7])
        c = mx.outputs[2]
    nt.links.new(c, b.inputs["Base Color"])
    if emit:
        b.inputs["Emission Color"].default_value = lin(emit_col or base)
        b.inputs["Emission Strength"].default_value = emit
    _MATS[key] = m
    return m


def emit_mat(name, col, strength=6.0):
    key = ("emit", name)
    if key not in _MATS:
        m = bpy.data.materials.new(name)
        try:
            m.use_nodes = True
        except (AttributeError, TypeError):
            pass
        nt = m.node_tree
        nt.nodes.clear()
        e = nt.nodes.new("ShaderNodeEmission")
        e.inputs["Color"].default_value = lin(col)
        e.inputs["Strength"].default_value = strength
        out = nt.nodes.new("ShaderNodeOutputMaterial")
        nt.links.new(e.outputs[0], out.inputs[0])
        _MATS[key] = m
    return _MATS[key]


def _edge(nt, radius=0.04, gain=7.0):
    """Painted lit edge factor: 1 - dot(bevel normal, true normal), amplified (cookbook 3.4)."""
    bv = nt.nodes.new("ShaderNodeBevel")
    bv.inputs["Radius"].default_value = radius
    geo = nt.nodes.new("ShaderNodeNewGeometry")
    dp = nt.nodes.new("ShaderNodeVectorMath")
    dp.operation = "DOT_PRODUCT"
    nt.links.new(bv.outputs["Normal"], dp.inputs[0])
    nt.links.new(geo.outputs["Normal"], dp.inputs[1])
    inv = nt.nodes.new("ShaderNodeMath")
    inv.operation = "SUBTRACT"
    inv.inputs[0].default_value = 1.0
    nt.links.new(dp.outputs["Value"], inv.inputs[1])
    mul = nt.nodes.new("ShaderNodeMath")
    mul.operation = "MULTIPLY"
    mul.use_clamp = True
    mul.inputs[1].default_value = gain
    nt.links.new(inv.outputs[0], mul.inputs[0])
    return mul.outputs[0]


def blockmat(kind, base=None):
    """Block skins matching production/qa/evidence/blocks-v2/gallery.png (toy jelly, lava, neon,
    ice, celestial, gold, ghost). Toy = the board's saturated glossy cubes."""
    key = ("block", kind, base)
    if key in _MATS:
        return _MATS[key]
    base = base or {"lava": "4a3436", "neon": "26206e", "ice": "bfe6ff", "celestial": "6a3fb8",
                    "gold": "f8c840", "ghost": "bff4ff", "dirt": "b4713f", "grass": "6cc04a",
                    "snow": "fbfdff", "candy": "f7a3c6"}.get(kind, TOY["blue"])
    rough = {"ice": 0.15, "gold": 0.25, "ghost": 0.05, "dirt": 0.85, "grass": 0.8, "snow": 0.7}.get(kind, 0.32)
    m = wz.principled(f"blk_{kind}_{base}", base, rough=rough, metal=0.8 if kind == "gold" else 0.0,
                      Coat_Weight=0.0 if kind in ("dirt", "grass", "snow") else 0.5)
    nt, b = _nodes(m)
    bc = lin(base)
    nz = nt.nodes.new("ShaderNodeTexNoise")
    nz.inputs["Scale"].default_value = 4.0
    c = wz.mix_rgb(nt, nz.outputs["Fac"], tuple(x * 0.82 for x in bc[:3]) + (1,), bc)
    if kind == "celestial":
        nz.inputs["Scale"].default_value = 2.5
        c = wz.mix_rgb(nt, nz.outputs["Fac"], lin("3d2a8a"), lin("a77ae8"))
    edge = _edge(nt)
    light = tuple(min(1.0, x * 1.5 + 0.06) for x in bc[:3]) + (1,)
    mx = nt.nodes.new("ShaderNodeMix")
    mx.data_type = "RGBA"
    nt.links.new(edge, mx.inputs[0])
    nt.links.new(c, mx.inputs[6])
    mx.inputs[7].default_value = light
    nt.links.new(mx.outputs[2], b.inputs["Base Color"])
    b.inputs["Emission Color"].default_value = bc
    b.inputs["Emission Strength"].default_value = {"gold": 0.3, "dirt": 0.0, "grass": 0.0, "snow": 0.05}.get(kind, 0.12)
    if kind in ("lava", "neon", "celestial"):
        # crack / edge / sparkle emission mask
        if kind == "lava":
            vo = nt.nodes.new("ShaderNodeTexVoronoi")
            vo.feature = "DISTANCE_TO_EDGE"
            vo.inputs["Scale"].default_value = 3.2
            mr = nt.nodes.new("ShaderNodeMapRange")
            mr.inputs["From Min"].default_value = 0.0
            mr.inputs["From Max"].default_value = 0.05
            mr.inputs["To Min"].default_value = 1.0
            mr.inputs["To Max"].default_value = 0.0
            nt.links.new(vo.outputs["Distance"], mr.inputs["Value"])
            mask, ecol, k = mr.outputs[0], "ffa020", 5.0
        elif kind == "neon":
            mask, ecol, k = edge, "4ad8ff", 5.0
        else:
            vo = nt.nodes.new("ShaderNodeTexVoronoi")
            vo.inputs["Scale"].default_value = 9.0
            mr = nt.nodes.new("ShaderNodeMapRange")
            mr.inputs["From Min"].default_value = 0.0
            mr.inputs["From Max"].default_value = 0.08
            mr.inputs["To Min"].default_value = 1.0
            mr.inputs["To Max"].default_value = 0.0
            nt.links.new(vo.outputs["Distance"], mr.inputs["Value"])
            mask, ecol, k = mr.outputs[0], "ffffff", 6.0
        mul = nt.nodes.new("ShaderNodeMath")
        mul.operation = "MULTIPLY"
        mul.inputs[1].default_value = k
        nt.links.new(mask, mul.inputs[0])
        b.inputs["Emission Color"].default_value = lin(ecol)
        nt.links.new(mul.outputs[0], b.inputs["Emission Strength"])
    if kind == "ice":
        b.inputs["Transmission Weight"].default_value = 0.25
    if kind == "ghost":
        b.inputs["Transmission Weight"].default_value = 0.9
        b.inputs["Emission Strength"].default_value = 0.6
    _MATS[key] = m
    return m


def glassy(name, col, emit=0.6, trans=0.55, flat=False):
    key = ("glassy", name)
    if key not in _MATS:
        _MATS[key] = wz.principled(name, col, rough=0.08, Transmission_Weight=trans, Coat_Weight=1.0,
                                   Emission_Color=lin(col), Emission_Strength=emit)
    return _MATS[key]


def M(name):
    """Named prop materials shared by every panel."""
    table = {
        "wood": lambda: paint("p_wood", "9a6438", noise=5.0, bands=(3.0, 0.25, "X"), ao=0.4),
        "wood_dark": lambda: paint("p_wood_dark", "6a3f24", noise=4.0, bands=(2.5, 0.2, "Z"), ao=0.5),
        "planks": lambda: paint("p_planks", "a86a3c", noise=2.0, bands=(1.6, 0.3, "X"), ao=0.8, rough=0.55),
        "wall": lambda: paint("p_wall", "7b4a35", noise=1.5, bands=(0.8, 0.12, "Z"), ao=1.0),
        "wall_panel": lambda: paint("p_wall_panel", "5a3424", noise=2.0, bands=(2.0, 0.2, "X"), ao=0.6),
        "plum_wood": lambda: paint("p_plum_wood", "6b4a8a", noise=3.0, ao=0.4, coat=0.2),
        "grass": lambda: paint("p_grass", "6cc04a", shade="2f6a3a", noise=2.5, var=0.25, ao=0.6, rough=0.85, sheen=0.4),
        "grass_dark": lambda: paint("p_grass_dark", "4f9a3a", shade="2a5a3a", noise=3.0, ao=0.4, sheen=0.4),
        "dirt": lambda: paint("p_dirt", "b4713f", shade="5a2a4a", noise=2.0, var=0.25, bands=(1.2, 0.25, "Z"), ao=0.8),
        "rock": lambda: paint("p_rock", "8a7f8f", shade="3b2346", noise=3.0, var=0.3, ao=0.6),
        "dark_rock": lambda: paint("p_dark_rock", "4e3b46", shade="2a1630", noise=2.5, var=0.3, bands=(1.5, 0.2, "Z"), ao=0.8),
        "snow": lambda: paint("p_snow", "fbfdff", shade="8fa6e8", noise=2.0, var=0.06, ao=0.6, rough=0.6, sheen=0.4),
        "ice_rock": lambda: paint("p_ice_rock", "9fb6dc", shade="4a4a9a", noise=2.0, var=0.2, bands=(1.2, 0.15, "Z"), ao=0.7),
        "ice_wall": lambda: paint("p_ice_wall", "d8e8fa", shade="6a7ac8", noise=4.0, var=0.12, ao=0.4, coat=0.4),
        "ice_roof": lambda: paint("p_ice_roof", "5a8ae0", shade="3a3a8a", noise=3.0, ao=0.3, coat=0.5),
        "neon_ground": lambda: paint("p_neon_ground", "2d2b5a", shade="140f30", noise=3.0, ao=0.6),
        "foliage": lambda: paint("p_foliage", "5fb048", shade="2a5a3a", noise=3.5, var=0.3, ao=0.5, sheen=0.5),
        "pine": lambda: paint("p_pine", "3f8a50", shade="1f4a3a", noise=3.0, var=0.25, ao=0.4, sheen=0.4),
        "trunk": lambda: paint("p_trunk", "7a4a2a", noise=6.0, bands=(4.0, 0.25, "Z"), ao=0.3),
        "page": lambda: paint("p_page", "fff1cf", noise=2.0, var=0.08, ao=0.2, emit=2.2, emit_col="ffe2a0"),
        "page_dim": lambda: paint("p_page_dim", "f6e7c4", noise=2.0, var=0.08, ao=0.2, emit=0.25),
        "tome": lambda: paint("p_tome", "6b3fa0", shade="2a1640", noise=4.0, var=0.2, ao=0.3, coat=0.3, sheen=0.3),
        "gold": lambda: wz.principled("p_gold", "f8c840", rough=0.25, metal=0.85,
                                      Emission_Color=lin("f8c840"), Emission_Strength=0.35),
        "star": lambda: wz.principled("p_star", "ffd860", rough=0.3, Emission_Color=lin("ffd060"), Emission_Strength=3.0),
        "steel": lambda: paint("p_steel", "6c7486", noise=4.0, ao=0.2, metal=0.6, rough=0.4),
        "cloud": lambda: wz.plush("p_cloud", "fffaf4", "b6a4e2", 0.6),
        "glass": lambda: wz.principled("p_glass", "eef6ff", rough=0.03, Transmission_Weight=1.0, Coat_Weight=0.5),
        "cork": lambda: paint("p_cork", "b98a5a", noise=8.0, ao=0.1),
        "candle": lambda: paint("p_candle", "fff0d8", noise=3.0, var=0.05, ao=0.1, emit=0.3, emit_col="ffd890"),
        "flame": lambda: emit_mat("p_flame", "ffb040", 18.0),
        "mote_gold": lambda: emit_mat("p_mote_gold", "ffd870", 10.0),
        "mote_white": lambda: emit_mat("p_mote_white", "fff6e0", 12.0),
        "mote_pink": lambda: emit_mat("p_mote_pink", "ff9ad8", 9.0),
        "mote_cyan": lambda: emit_mat("p_mote_cyan", "8ef0ff", 9.0),
        "window": lambda: emit_mat("p_window", "cdd8ff", 1.6),
        "lava": lambda: emit_mat("p_lava", "ff7a1a", 7.0),
        "smoke": lambda: wz.plush("p_smoke", "b9a8c8", "5a4a6a", 0.6),
        "ocean": lambda: globe_mat(),
        "red_cloth": lambda: paint("p_red_cloth", "c8352e", noise=4.0, ao=0.2, sheen=0.4),
        "path": lambda: paint("p_path", "e2c48a", shade="8a5a4a", noise=3.0, var=0.2, ao=0.4, rough=0.9),
        "fence": lambda: paint("p_fence", "8a5a34", noise=6.0, bands=(5.0, 0.25, "Z"), ao=0.3),
        "flower_w": lambda: paint("p_flower_w", "ffffff", noise=2.0, var=0.05, ao=0.1, emit=0.15),
        "flower_p": lambda: paint("p_flower_p", "ff8ac8", noise=2.0, var=0.05, ao=0.1, emit=0.15),
        "flower_y": lambda: paint("p_flower_y", "ffe060", noise=2.0, var=0.05, ao=0.1, emit=0.15),
    }
    key = ("named", name)
    if key not in _MATS:
        _MATS[key] = table[name]()
    return _MATS[key]


def globe_mat():
    m = wz.principled("p_globe", "3d8fd8", rough=0.35, Coat_Weight=0.6)
    nt, b = _nodes(m)
    nz = nt.nodes.new("ShaderNodeTexNoise")
    nz.inputs["Scale"].default_value = 2.2
    nz.inputs["Detail"].default_value = 3.0
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    ramp.color_ramp.interpolation = "CONSTANT"
    ramp.color_ramp.elements[0].color = lin("3d8fd8")
    ramp.color_ramp.elements[1].position = 0.55
    ramp.color_ramp.elements[1].color = lin("7cc04a")
    nt.links.new(nz.outputs["Fac"], ramp.inputs[0])
    nt.links.new(ramp.outputs[0], b.inputs["Base Color"])
    return m


# ------------------------------------------------------------------------------------ geometry
def link(o):
    return wz.link(o)


def rbox(name, size, loc=(0, 0, 0), mat=None, bevel=0.12, rot=(0, 0, 0), seg=3):
    """Rounded box (toy block, plank, book...) with smooth bevelled corners."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bm.transform(Matrix.Diagonal((*size, 1.0)))
    o = wz.mesh_obj(name, bm, mat, smooth=False)
    if bevel > 0:
        m = o.modifiers.new("bv", "BEVEL")
        m.width = bevel * min(size)
        m.segments = seg
        m.limit_method = "NONE"
        try:
            m.harden_normals = True
        except (AttributeError, TypeError):
            pass
        o.data.shade_smooth()
    o.location = loc
    o.rotation_euler = [math.radians(a) for a in rot]
    return o


def lathe(name, prof, mat, seg=32, jit=0.0, seed=0, loc=(0, 0, 0), subsurf=0, caps=(True, True), squash=(1, 1)):
    """Surface of revolution from a (radius, z) profile, bottom to top, with radial wobble."""
    rnd = random.Random(seed)
    ph = [rnd.uniform(0, 6.283) for _ in range(4)]
    bm = bmesh.new()
    rings = []
    for i, (r, z) in enumerate(prof):
        ring = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            n = 1 + jit * (0.45 * math.sin(3 * a + ph[0] + i * 0.9) + 0.3 * math.sin(5 * a + ph[1] - i * 1.3)
                           + 0.25 * math.sin(9 * a + ph[2] + i * 2.1))
            ring.append(bm.verts.new((r * n * math.cos(a) * squash[0], r * n * math.sin(a) * squash[1], z)))
        rings.append(ring)
    for i in range(len(rings) - 1):
        for j in range(seg):
            bm.faces.new((rings[i][j], rings[i][(j + 1) % seg], rings[i + 1][(j + 1) % seg], rings[i + 1][j]))
    for ci, (on, ring, z) in enumerate(((caps[0], rings[0], prof[0][1]), (caps[1], rings[-1], prof[-1][1]))):
        if on:
            c = bm.verts.new((0, 0, z))
            for j in range(seg):
                bm.faces.new((ring[(j + 1) % seg], ring[j], c) if ci == 0 else (ring[j], ring[(j + 1) % seg], c))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    o = wz.mesh_obj(name, bm, mat)
    if subsurf:
        s = o.modifiers.new("ss", "SUBSURF")
        s.levels = s.render_levels = subsurf
    o.location = loc
    return o


def ico(bm, p, r, sub=1, scale=(1, 1, 1)):
    bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=r,
                               matrix=Matrix.Translation(p) @ Matrix.Diagonal((*scale, 1.0)))


def motes(name, pts, radii, mat, sub=1):
    bm = bmesh.new()
    for p, r in zip(pts, radii):
        ico(bm, p, r, sub)
    return wz.mesh_obj(name, bm, mat)


def group(name, objs, loc=(0, 0, 0), yaw=0.0, s=1.0, mirror=False, rot=None):
    """Parent objects built around the origin to one empty, then place it."""
    e = link(bpy.data.objects.new(name, None))
    for o in objs:
        o.parent = e
    e.location = loc
    e.rotation_euler = [math.radians(a) for a in rot] if rot else (0, 0, math.radians(yaw))
    e.scale = (-s if mirror else s, s, s)
    return e


def cloud(name, loc, s=1.0, seed=0, n=7, stretch=1.0):
    rnd = random.Random(seed)
    el = [wz.E((0, 0, 0), (1.05 * s * stretch, 0.45 * s, 0.22 * s))]
    for i in range(n):
        x = (i / max(n - 1, 1) * 2 - 1) * 0.85 * s * stretch + rnd.uniform(-0.1, 0.1) * s
        r = (0.55 - 0.3 * abs(x) / (s * stretch)) * s * rnd.uniform(0.8, 1.15)
        el.append(wz.B((x, rnd.uniform(-0.2, 0.2) * s, r * 0.35), r))
    o = wz.metaball(name, el, res=0.05 * s)
    o.location = loc
    return wz.realize(o, mat=M("cloud"))


def top_z(r):
    """Height of an island's walkable top above its origin (cap profile below)."""
    return 0.1 * r


def island(name, loc, r, depth, top="grass", under="dirt", seed=0, dress=True, flowers=True):
    """Floating island: grass (or snow/rock) cap with an overhanging lip, chunky rock cone below."""
    t = 0.2 * r
    rnd = random.Random(seed)
    objs = [lathe(name + "_cap", [(0.96 * r, -t * 0.7), (1.05 * r, -t * 0.3), (1.05 * r, 0.0), (0.93 * r, t * 0.42),
                                  (0.6 * r, t * 0.5), (0.2 * r, t * 0.5)], M(top), seg=40, jit=0.05, seed=seed, subsurf=1),
            lathe(name + "_under", [(0.06 * r, -depth), (0.3 * r, -0.82 * depth), (0.58 * r, -0.58 * depth),
                                    (0.82 * r, -0.33 * depth), (0.97 * r, -0.12 * depth), (0.99 * r, -t * 0.3)],
                  M(under), seg=28, jit=0.14, seed=seed + 7, subsurf=1)]
    if dress:
        bm = bmesh.new()
        for i in range(int(16 * r)):
            a = rnd.uniform(0, 6.283)
            rr = r * rnd.uniform(0.82, 0.98)
            ico(bm, (rr * math.cos(a), rr * math.sin(a), t * 0.3), rnd.uniform(0.08, 0.16) * min(r, 1.6) ** 0.5, 2,
                (1, 1, 0.7))
        objs.append(wz.mesh_obj(name + "_tufts", bm, M("grass_dark") if top == "grass" else M(top)))
        if flowers and top == "grass":
            for fm in ("flower_w", "flower_p", "flower_y"):
                bm = bmesh.new()
                for i in range(int(6 * r)):
                    a = rnd.uniform(0, 6.283)
                    rr = r * rnd.uniform(0.55, 0.95)
                    ico(bm, (rr * math.cos(a), rr * math.sin(a), t * 0.42 + 0.03), 0.045, 1)
                objs.append(wz.mesh_obj(f"{name}_{fm}", bm, M(fm)))
    return group(name, objs, loc)


def block(name, loc, kind="toy", col="blue", s=0.4, rot=(0, 0, 0)):
    """One game block. Meadow = dirt cube with a grass cap; ice/candy get a snow/icing cap."""
    objs = []
    if kind == "meadow":
        objs.append(rbox(name, (s, s, s * 0.82), (0, 0, -s * 0.09), blockmat("dirt"), 0.14))
        objs.append(rbox(name + "_cap", (s * 1.04, s * 1.04, s * 0.26), (0, 0, s * 0.39), blockmat("grass"), 0.3))
    elif kind in ("ice", "candy"):
        objs.append(rbox(name, (s, s, s), (0, 0, 0), blockmat(kind), 0.14))
        objs.append(rbox(name + "_cap", (s * 1.04, s * 1.04, s * 0.2), (0, 0, s * 0.43), blockmat("snow"), 0.35))
    else:
        objs.append(rbox(name, (s, s, s), (0, 0, 0), blockmat(kind, TOY.get(col, col) if kind == "toy" else None), 0.14))
    return group(name + "_g", objs, loc, rot=rot)


def star(name, loc, size, facing=(0, -1, 0), mat=None):
    return wz.puffy_star(name, size, size * 0.48, size * 0.35, mat or M("star"), Vector(loc), Vector(facing))


def tome(name, size=0.5, open_deg=110, star_on=True):
    """Violet leather tome with a gold star, hinged at the spine along local Y."""
    w, d, th = size * 0.5, size * 0.72, size * 0.035
    halves = []
    for side in (-1, 1):
        parts = [rbox(f"{name}_cov{side}", (w, d, th), (side * w / 2, 0, 0), M("tome"), 0.3),
                 rbox(f"{name}_pg{side}", (w * 0.92, d * 0.92, th * 2.2), (side * w * 0.48, 0, th * 1.5), M("page_dim"), 0.15)]
        if star_on and side == 1:
            parts.append(star(f"{name}_star", (w / 2, 0, -th * 0.7), w * 0.28, (0, 0, -1), M("gold")))
        hinge = group(f"{name}_h{side}", parts, (0, 0, 0), rot=(0, side * -(180 - open_deg) / 2, 0))
        halves.append(hinge)
    halves.append(rbox(f"{name}_spine", (th * 2, d, th * 2), (0, 0, -th * 0.3), M("tome"), 0.4))
    return halves


def open_book(name, size=0.7):
    """The glowing open storybook: violet cover, two curved page blocks."""
    w, d = size, size * 0.7
    objs = [rbox(name + "_cover", (w * 1.06, d * 1.08, 0.035), (0, 0, 0), M("tome"), 0.3)]
    for side in (-1, 1):
        bm = bmesh.new()
        nx = 16
        rows = []
        for i in range(nx + 1):
            u = i / nx
            x = side * u * w * 0.49
            z = 0.02 + 0.07 * size * (math.sin(math.pi * min(1.0, u * 1.6) * 0.5) ** 0.6) * (1 - 0.35 * u)
            rows.append([bm.verts.new((x, y, z)) for y in (-d / 2, d / 2)])
        for i in range(nx):
            a, b = rows[i], rows[i + 1]
            bm.faces.new((a[0], b[0], b[1], a[1]))
        o = wz.mesh_obj(f"{name}_pages{side}", bm, M("page"))
        so = o.modifiers.new("so", "SOLIDIFY")
        so.thickness = 0.05 * size
        so.offset = -1
        objs.append(o)
    return objs


def bottle(name, h, liquid, loc):
    r = h * 0.32
    objs = [lathe(name + "_b", [(r * 0.7, 0), (r, h * 0.12), (r * 1.02, h * 0.42), (r * 0.6, h * 0.6), (r * 0.3, h * 0.68)],
                  glassy("liq_" + liquid, liquid, 0.9), seg=24),
            lathe(name + "_n", [(r * 0.3, h * 0.66), (r * 0.28, h * 0.86), (r * 0.36, h * 0.9)], M("glass"), seg=16),
            rbox(name + "_c", (r * 0.5, r * 0.5, h * 0.12), (0, 0, h * 0.95), M("cork"), 0.3)]
    return group(name, objs, loc)


def candle(name, loc, h=0.22):
    objs = [lathe(name + "_w", [(0.05, 0), (0.05, h), (0.045, h + 0.01)], M("candle"), seg=16)]
    bm = bmesh.new()
    ico(bm, (0, 0, h + 0.05), 0.03, 2, (1, 1, 1.8))
    objs.append(wz.mesh_obj(name + "_f", bm, M("flame")))
    lt = bpy.data.lights.new(name + "_l", "POINT")
    lt.color = lin("ffb860")[:3]
    lt.energy = 12
    lt.shadow_soft_size = 0.05
    lo = link(bpy.data.objects.new(name + "_l", lt))
    lo.location = (0, 0, h + 0.12)
    objs.append(lo)
    return group(name, objs, loc)


def point_light(name, loc, col, energy, radius=0.2):
    lt = bpy.data.lights.new(name, "POINT")
    lt.color = lin(col)[:3]
    lt.energy = energy
    lt.shadow_soft_size = radius
    o = link(bpy.data.objects.new(name, lt))
    o.location = loc
    return o


def shelf(name, loc, yaw, w=2.0, h=3.4, d=0.45, rows=4, seed=0, extras=()):
    """Bookshelf with random coloured books; extras = [(row, x, kind)] for potions, stars, globes."""
    rnd = random.Random(seed)
    objs = [rbox(name + "_back", (w, 0.06, h), (0, d / 2, h / 2), M("wood_dark"), 0.05)]
    for sx in (-1, 1):
        objs.append(rbox(f"{name}_side{sx}", (0.1, d, h), (sx * w / 2, 0, h / 2), M("wood"), 0.15))
    rh = h / rows
    cols = ["c8352e", "4a6fb0", "4f9a3a", "7a52b0", "d9a040", "3a9a9a", "a8442e", "e2c995"]
    for r in range(rows + 1):
        objs.append(rbox(f"{name}_sh{r}", (w + 0.06, d + 0.04, 0.08), (0, 0, r * rh + 0.04), M("wood"), 0.2))
    taken = {(e[0]) for e in extras}
    for r in range(rows):
        x = -w / 2 + 0.1
        lim = w / 2 - 0.1
        if r in taken:
            lim = -0.05
        while x < lim:
            bw = rnd.uniform(0.06, 0.13)
            bh = rh * rnd.uniform(0.55, 0.82)
            lean = rnd.choice([0, 0, 0, 0, 8, -10])
            c = rnd.choice(cols)
            objs.append(rbox(f"{name}_bk{r}_{len(objs)}", (bw, d * 0.75, bh),
                             (x + bw / 2, -0.02, r * rh + 0.08 + bh / 2), paint("book_" + c, c, noise=6, ao=0.2, coat=0.2), 0.12,
                             rot=(0, lean, 0)))
            x += bw + 0.008
    for r, x, kind in extras:
        z = r * rh + 0.08
        if kind.startswith("potion"):
            objs.append(bottle(f"{name}_pot{r}{x}", rh * 0.5, kind.split(":")[1], (x, -0.02, z)))
        elif kind == "star":
            objs.append(star(f"{name}_star{r}", (x, -0.05, z + 0.22), 0.16))
        elif kind == "plant":
            objs.append(lathe(f"{name}_pot{r}", [(0.1, 0), (0.14, 0.16), (0.15, 0.18)], paint("p_pot", "c86a4a", ao=0.2),
                              seg=16, loc=(x, 0, z)))
            bm = bmesh.new()
            for i in range(6):
                a = i * 1.05
                ico(bm, (x + 0.12 * math.cos(a), 0.1 * math.sin(a), z + 0.3 + 0.06 * (i % 2)), 0.13, 2)
            objs.append(wz.mesh_obj(f"{name}_leaf{r}", bm, M("foliage")))
        elif kind == "candle":
            objs.append(candle(f"{name}_cd{r}", (x, 0, z)))
    return group(name, objs, loc, yaw)


def globe(name, loc, r=0.3):
    objs = [wz.ellipsoid(name + "_s", (0, 0, r * 1.6), (r, r, r), M("ocean"), seg=32),
            wz.sweep(name + "_ring", [(r * 1.12 * math.cos(a), 0, r * 1.6 + r * 1.12 * math.sin(a))
                                       for a in np.linspace(0, 2 * math.pi, 40, endpoint=False)],
                     [0.018] * 40, ring=10, mat=M("gold"), closed=True),
            lathe(name + "_base", [(r * 0.6, 0), (r * 0.55, r * 0.1), (r * 0.12, r * 0.2), (r * 0.08, r * 0.5)], M("wood"), seg=20)]
    g = group(name, objs, loc)
    objs[0].rotation_euler = (0.3, 0.2, 0.0)
    return g


def tree(name, loc, s=1.0, seed=0):
    rnd = random.Random(seed)
    objs = [lathe(name + "_t", [(0.12 * s, 0), (0.08 * s, 0.5 * s), (0.07 * s, 0.8 * s)], M("trunk"), seg=12)]
    el = [wz.B((rnd.uniform(-0.25, 0.25) * s, rnd.uniform(-0.2, 0.2) * s, (0.95 + rnd.uniform(0, 0.4)) * s),
               rnd.uniform(0.3, 0.42) * s) for _ in range(5)]
    mb = wz.metaball(name + "_fol", el, res=0.04 * s)
    objs.append(wz.realize(mb, mat=M("foliage")))
    return group(name, objs, loc)


def pine(name, loc, s=1.0, snow=False):
    objs = [lathe(name + "_t", [(0.07 * s, 0), (0.06 * s, 0.3 * s)], M("trunk"), seg=10)]
    for i, (r, z0, z1) in enumerate(((0.45, 0.2, 0.8), (0.35, 0.6, 1.15), (0.24, 0.95, 1.45))):
        objs.append(lathe(f"{name}_c{i}", [(r * s, z0 * s), (r * 0.5 * s, (z0 + z1) / 2 * s), (0.02 * s, z1 * s)],
                          M("snow") if snow and i == 2 else M("pine"), seg=14, jit=0.08, seed=i, subsurf=1))
    return group(name, objs, loc)


def ribbon(name, pts, width, mat, n=80, lift=0.03):
    P, _ = wz.catmull(pts, [width] * len(pts), n)
    bm = bmesh.new()
    rows = []
    for i, p in enumerate(P):
        t = (P[min(i + 1, len(P) - 1)] - P[max(i - 1, 0)]).normalized()
        side = t.cross(Z).normalized()
        rows.append([bm.verts.new(p + side * (k * width / 2) + Z * (lift + (0.02 if k == 0 else 0))) for k in (-1, 0, 1)])
    for i in range(len(rows) - 1):
        for k in range(2):
            bm.faces.new((rows[i][k], rows[i][k + 1], rows[i + 1][k + 1], rows[i + 1][k]))
    o = wz.mesh_obj(name, bm, mat)
    so = o.modifiers.new("so", "SOLIDIFY")
    so.thickness = 0.06
    return o


def tower_stack(name, base, kinds, s=0.42, lean=0.0, drift=(0, 0), spin=0.0, seed=0):
    """Stack of blocks; lean (deg) accumulates upward, drift (m) pushes upper blocks sideways."""
    rnd = random.Random(seed)
    gs = []
    for i, (kind, col) in enumerate(kinds):
        f = i / max(len(kinds) - 1, 1)
        p = (base[0] + drift[0] * f * f, base[1] + drift[1] * f * f, base[2] + s * 0.5 + i * s * 1.01)
        gs.append(block(f"{name}{i}", p, kind, col, s, rot=(rnd.uniform(-2, 2), lean * f, spin * f + rnd.uniform(-5, 5))))
    return gs


# --------------------------------------------------------------------------------------- cast
_CAST_M = {}


def cast_member(kind, pose, loc, yaw=0.0, s=1.0, mirror=False):
    """Build one cast member with the game's own builder and place it."""
    before = {o.name for o in bpy.data.objects}
    if kind == "wizard":
        if "w" not in _CAST_M:
            _CAST_M["w"] = wz.materials()
        wz.build(pose, _CAST_M["w"])
    else:
        if "h" not in _CAST_M:
            _CAST_M["h"] = hz.materials()
        hz.build(kind, pose, _CAST_M["h"])
    new = [o for o in bpy.data.objects if o.name not in before]
    return group(f"cast_{kind}_{len(before)}", new, loc, yaw, s, mirror)


# ---------------------------------------------------------------------------------- scene setup
def scene(samples, sky_stops, amb="e8dcff", amb_str=0.6, exposure=-0.2):
    _MATS.clear()
    _CAST_M.clear()
    sc = wz.reset(samples)
    for nm in ("key", "fill", "rim"):
        bpy.data.objects.remove(bpy.data.objects[nm])
    sc.render.film_transparent = False
    sc.view_settings.exposure = exposure
    sc.cycles.diffuse_bounces = 3
    sc.cycles.glossy_bounces = 3
    sc.cycles.transmission_bounces = 6
    sc.cycles.caustics_reflective = False
    sc.cycles.caustics_refractive = False
    sc.cycles.blur_glossy = 1.0
    # painted sky: screen-space gradient for camera rays, flat lavender ambient for lighting
    nt = sc.world.node_tree
    nt.nodes.clear()
    tc = nt.nodes.new("ShaderNodeTexCoord")
    sep = nt.nodes.new("ShaderNodeSeparateXYZ")
    nt.links.new(tc.outputs["Window"], sep.inputs[0])
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    els = ramp.color_ramp.elements
    els[0].position, els[0].color = sky_stops[0][0], lin(sky_stops[0][1])
    els[1].position, els[1].color = sky_stops[-1][0], lin(sky_stops[-1][1])
    for pos, c in sky_stops[1:-1]:
        e = els.new(pos)
        e.color = lin(c)
    nt.links.new(sep.outputs["Y"], ramp.inputs[0])
    bg_cam = nt.nodes.new("ShaderNodeBackground")
    nt.links.new(ramp.outputs[0], bg_cam.inputs[0])
    bg_amb = nt.nodes.new("ShaderNodeBackground")
    bg_amb.inputs[0].default_value = lin(amb)
    bg_amb.inputs[1].default_value = amb_str
    lp = nt.nodes.new("ShaderNodeLightPath")
    mix = nt.nodes.new("ShaderNodeMixShader")
    nt.links.new(lp.outputs["Is Camera Ray"], mix.inputs[0])
    nt.links.new(bg_amb.outputs[0], mix.inputs[1])
    nt.links.new(bg_cam.outputs[0], mix.inputs[2])
    out = nt.nodes.new("ShaderNodeOutputWorld")
    nt.links.new(mix.outputs[0], out.inputs[0])
    return sc


def camera(sc, loc, target, lens):
    cam = sc.camera
    cam.location = loc
    f = (Vector(target) - Vector(loc)).normalized()
    cam.rotation_euler = f.to_track_quat("-Z", "Y").to_euler()
    cam.data.lens = lens
    cam.data.shift_x = cam.data.shift_y = 0.0
    right = f.cross(Z).normalized()
    return f, right


def sun(name, from_dir, col, strength, angle=6.0, shadow=True):
    lt = bpy.data.lights.new(name, "SUN")
    lt.color = lin(col)[:3]
    lt.energy = strength
    lt.angle = math.radians(angle)
    lt.use_shadow = shadow
    o = link(bpy.data.objects.new(name, lt))
    o.rotation_euler = (-Vector(from_dir).normalized()).to_track_quat("-Z", "Y").to_euler()
    return o


def rig(f, right, key=("fff0d6", 3.2), fill=("b8c4ff", 0.7), rim=("ffe0a8", 2.2), key_dir=(-0.62, 0.75, 0.55)):
    """Cookbook 2.2 rig, camera-relative: warm key upper-left front, cool fill right, warm rim behind."""
    toward = -f
    flat = Vector((toward.x, toward.y, 0)).normalized()
    kd = right * key_dir[0] + Z * key_dir[1] + flat * key_dir[2]
    sun("key", kd, key[0], key[1], 8.0)
    sun("fill", right * 0.85 + Z * 0.35 + flat * 0.4, fill[0], fill[1], 20.0, shadow=False)
    sun("rim", right * 0.45 + Z * 0.55 - flat * 0.9, rim[0], rim[1], 6.0)


def sky_clouds(specs):
    for i, (loc, s, seed) in enumerate(specs):
        cloud(f"skycloud{i}", loc, s, seed, n=6 + seed % 3, stretch=1.3)


def sparkle_field(name, center, size, n, seed, mats=("mote_gold", "mote_white")):
    rnd = random.Random(seed)
    for k, mn in enumerate(mats):
        pts = [Vector(center) + Vector((rnd.uniform(-1, 1) * size[0], rnd.uniform(-1, 1) * size[1], rnd.uniform(-1, 1) * size[2]))
               for _ in range(n)]
        motes(f"{name}{k}", pts, [rnd.uniform(0.012, 0.035) for _ in pts], M(mn))


def spiral(center, r0, r1, height, turns, n, phase=0.0):
    out = []
    for i in range(n):
        t = i / (n - 1)
        a = phase + t * turns * 2 * math.pi
        r = r0 + (r1 - r0) * t
        out.append(Vector(center) + Vector((r * math.cos(a), r * math.sin(a) * 0.6, t * height)))
    return out


def arc(p0, p1, lift, n):
    p0, p1 = Vector(p0), Vector(p1)
    return [p0.lerp(p1, t) + Z * (4 * lift * t * (1 - t)) for t in np.linspace(0, 1, n)]


# ------------------------------------------------------------------------------- big set pieces
def ice_castle(name, loc, s=1.0):
    objs = [rbox(name + "_keep", (1.0 * s, 0.8 * s, 1.1 * s), (0, 0, 0.55 * s), M("ice_wall"), 0.08),
            rbox(name + "_keepcap", (1.06 * s, 0.86 * s, 0.14 * s), (0, 0, 1.12 * s), M("snow"), 0.4)]
    for i, (x, y, h, r) in enumerate(((-0.62, -0.3, 1.5, 0.24), (0.62, -0.3, 1.4, 0.22), (0.0, 0.25, 2.0, 0.28),
                                      (-0.5, 0.4, 1.2, 0.2), (0.55, 0.4, 1.25, 0.2))):
        objs.append(lathe(f"{name}_tw{i}", [(r * s, 0), (r * s, h * s), (r * 1.15 * s, h * s + 0.02)], M("ice_wall"), seg=20,
                          loc=(x * s, y * s, 0)))
        objs.append(lathe(f"{name}_rf{i}", [(r * 1.3 * s, 0), (r * 0.9 * s, 0.25 * s), (0.02 * s, 0.7 * s)],
                          M("ice_roof"), seg=20, loc=(x * s, y * s, h * s)))
        objs.append(lathe(f"{name}_sn{i}", [(r * 1.34 * s, 0), (r * 1.1 * s, 0.1 * s), (r * 0.6 * s, 0.17 * s)],
                          M("snow"), seg=20, jit=0.1, loc=(x * s, y * s, h * s - 0.02)))
        objs.append(rbox(f"{name}_fl{i}", (0.02 * s, 0.02 * s, 0.25 * s), (x * s, y * s, (h + 0.8) * s), M("wood"), 0.2))
        objs.append(rbox(f"{name}_fg{i}", (0.18 * s, 0.02 * s, 0.1 * s), ((x + 0.1) * s, y * s, (h + 0.86) * s), M("red_cloth"), 0.2))
    objs.append(rbox(name + "_gate", (0.3 * s, 0.05 * s, 0.45 * s), (0, -0.41 * s, 0.22 * s), M("ice_roof"), 0.4))
    return group(name, objs, loc)


def volcano(name, loc, s=1.0):
    objs = [lathe(name + "_cone", [(1.7 * s, 0), (1.35 * s, 0.45 * s), (0.95 * s, 1.0 * s), (0.6 * s, 1.55 * s),
                                    (0.48 * s, 1.7 * s), (0.36 * s, 1.62 * s)], M("dark_rock"), seg=36, jit=0.1, subsurf=1,
                  caps=(True, False)),
            lathe(name + "_pool", [(0.4 * s, 1.5 * s), (0.36 * s, 1.58 * s)], M("lava"), seg=24)]
    rnd = random.Random(3)
    for i in range(4):
        a = -1.9 + i * 0.35 + rnd.uniform(-0.1, 0.1)
        pts = [((0.5 + 1.1 * t) * s * math.cos(a + 0.2 * t), (0.5 + 1.1 * t) * s * math.sin(a + 0.2 * t),
                (1.62 - 1.55 * t + 0.05) * s) for t in np.linspace(0, 1, 6)]
        objs.append(wz.sweep(f"{name}_flow{i}", pts, [0.07 * s, 0.06 * s, 0.05 * s, 0.04 * s, 0.03 * s, 0.02 * s], ring=8,
                             mat=M("lava")))
    for i in range(4):
        objs.append(cloud(f"{name}_smoke{i}", (0.15 * s * i, 0.1 * s, (2.0 + 0.55 * i) * s), (0.4 + 0.15 * i) * s, 30 + i, n=5))
        objs[-1].data.materials.clear()
        objs[-1].data.materials.append(M("smoke"))
    objs.append(point_light(name + "_glow", (0, -0.2 * s, 1.9 * s), "ff7a20", 400 * s * s, 0.4 * s))
    return group(name, objs, loc)


def neon_city(name, loc, s=1.0, seed=5):
    rnd = random.Random(seed)
    objs = []
    for i in range(9):
        x, y = rnd.uniform(-1.0, 1.0) * s, rnd.uniform(-0.6, 0.6) * s
        h = rnd.uniform(0.6, 2.0) * s * (1.3 - 0.4 * abs(x) / s)
        w = rnd.uniform(0.3, 0.45) * s
        objs.append(rbox(f"{name}_b{i}", (w, w, h), (x, y, h / 2), blockmat("neon"), 0.06))
        # window stripes
        col = ["ff5ad8", "4ad8ff", "ffd84a"][i % 3]
        bm = bmesh.new()
        for k in range(int(h / (0.18 * s))):
            ico(bm, (x, y - w / 2 - 0.005, (0.15 + k * 0.18) * s), 0.04 * s, 1, (w * 7, 0.2, 0.6))
        objs.append(wz.mesh_obj(f"{name}_win{i}", bm, emit_mat(f"neonwin_{col}", col, 5.0)))
    objs.append(wz.sweep(name + "_halo", [(1.35 * s * math.cos(a), 1.0 * s * math.sin(a), 0.02)
                                           for a in np.linspace(0, 2 * math.pi, 48, endpoint=False)],
                         [0.035 * s] * 48, ring=8, mat=emit_mat("neon_halo", "ff5ad8", 6.0), closed=True))
    objs.append(point_light(name + "_glow", (0, -0.8 * s, 1.2 * s), "c060ff", 250 * s * s, 0.5 * s))
    return group(name, objs, loc)


def cart(name, load=True, seed=0):
    objs = [rbox(name + "_bed", (1.5, 0.95, 0.12), (0, 0, 0.42), M("wood"), 0.2)]
    for sx in (-1, 1):
        objs.append(rbox(f"{name}_wx{sx}", (0.08, 0.95, 0.34), (sx * 0.71, 0, 0.62), M("wood"), 0.25))
        objs.append(rbox(f"{name}_wy{sx}", (1.5, 0.08, 0.34), (0, sx * 0.44, 0.62), M("wood"), 0.25))
        for sy in (-1, 1):
            wl = lathe(f"{name}_wh{sx}{sy}", [(0.26, -0.05), (0.27, 0.0), (0.26, 0.05)], M("wood_dark"), seg=24)
            wl.location = (sx * 0.5, sy * 0.52, 0.27)
            wl.rotation_euler = (math.radians(90), 0, 0)
            objs.append(wl)
            hub = lathe(f"{name}_hub{sx}{sy}", [(0.08, -0.07), (0.08, 0.07)], M("steel"), seg=12)
            hub.location = wl.location
            hub.rotation_euler = wl.rotation_euler
            objs.append(hub)
    objs.append(rbox(name + "_band", (1.54, 0.99, 0.05), (0, 0, 0.78), M("steel"), 0.3))
    if load:
        k = 0
        for ix in range(3):
            for iy in range(2):
                objs.append(block(f"{name}_ld{k}", ((ix - 1) * 0.46, (iy - 0.5) * 0.43, 0.69), "toy",
                                  TOY_ORDER[k % 8], 0.42, rot=(0, 0, random.Random(k).uniform(-5, 5))))
                k += 1
    return objs


def chest(name, s=1.0):
    pw = paint("p_chest", "7a4aa8", shade="2a1640", noise=4.0, ao=0.3, coat=0.3)
    objs = [rbox(name + "_body", (1.2 * s, 0.75 * s, 0.6 * s), (0, 0, 0.3 * s), pw, 0.12)]
    for x in (-0.42, 0.42):
        objs.append(rbox(f"{name}_band{x}", (0.1 * s, 0.79 * s, 0.64 * s), (x * s, 0, 0.3 * s), M("gold"), 0.3))
    objs.append(rbox(name + "_rim", (1.24 * s, 0.79 * s, 0.08 * s), (0, 0, 0.6 * s), M("gold"), 0.3))
    objs.append(rbox(name + "_lock", (0.18 * s, 0.06 * s, 0.22 * s), (0, -0.4 * s, 0.48 * s), M("gold"), 0.3))
    lid = [rbox(name + "_lidb", (1.24 * s, 0.79 * s, 0.16 * s), (0, -0.395 * s, 0.08 * s), pw, 0.2),
           wz.ellipsoid(name + "_lidd", (0, -0.395 * s, 0.15 * s), (0.6 * s, 0.38 * s, 0.14 * s), pw)]
    for x in (-0.42, 0.42):
        lid.append(rbox(f"{name}_lband{x}", (0.1 * s, 0.82 * s, 0.2 * s), (x * s, -0.395 * s, 0.12 * s), M("gold"), 0.3))
    objs.append(group(name + "_lid", lid, (0, 0.38 * s, 0.62 * s), rot=(-112, 0, 0)))
    # treasure heap
    rnd = random.Random(11)
    gems = ["e0483c", "4cc04a", "4aa8e8", "b48ad8", "ff8ac8", "4ad8d8"]
    for i in range(34):
        a = rnd.uniform(0, 6.283)
        rr = math.sqrt(rnd.random())
        x, y = rr * 0.5 * s * math.cos(a), rr * 0.3 * s * math.sin(a)
        z = 0.6 * s + (1 - rr * rr) * 0.32 * s + rnd.uniform(0, 0.06) * s
        if i % 3 == 0:
            objs.append(rbox(f"{name}_gc{i}", (0.17 * s,) * 3, (x, y, z), M("gold"), 0.2,
                             rot=(rnd.uniform(0, 40), rnd.uniform(0, 40), rnd.uniform(0, 90))))
        else:
            bm = bmesh.new()
            ico(bm, (x, y, z), rnd.uniform(0.07, 0.11) * s, 1)
            g = wz.mesh_obj(f"{name}_gem{i}", bm, glassy("gem_" + gems[i % 6], gems[i % 6], 0.8, 0.3), smooth=False)
            objs.append(g)
    objs.append(point_light(name + "_glow", (0, -0.2 * s, 1.3 * s), "ffd870", 120 * s * s, 0.3))
    return objs


def confetti(name, center, size, n, seed):
    rnd = random.Random(seed)
    cols = ["e0483c", "f8c840", "4aa8e8", "6cc04a", "ee6aa0", "b48ad8", "ffffff"]
    for ci, c in enumerate(cols):
        bm = bmesh.new()
        for _ in range(n // len(cols)):
            p = Vector(center) + Vector((rnd.uniform(-1, 1) * size[0], rnd.uniform(-1, 1) * size[1], rnd.uniform(-1, 1) * size[2]))
            R = Matrix.Rotation(rnd.uniform(0, 6.28), 4, Vector((rnd.random(), rnd.random(), rnd.random())).normalized())
            vs = [bm.verts.new(p + (R @ Vector((x * 0.035, y * 0.06, 0)))) for x, y in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
            bm.faces.new(vs)
        wz.mesh_obj(f"{name}{ci}", bm, paint("conf_" + c, c, noise=1, var=0.0, ao=0.0, emit=0.5, rough=0.5), smooth=False)


def firework(name, center, radius, col, seed, rays=22):
    rnd = random.Random(seed)
    pts, rad = [], []
    for k in range(rays):
        a = 2 * math.pi * k / rays + rnd.uniform(-0.1, 0.1)
        el = rnd.uniform(-0.6, 0.6)
        d = Vector((math.cos(a) * math.cos(el), 0.3 * math.sin(a) * math.cos(el), math.sin(a) * math.cos(el) * 0.9 + 0.1 * el))
        for t in np.linspace(0.35, 1.0, 7):
            pts.append(Vector(center) + d.normalized() * radius * t)
            rad.append(0.035 * radius * (0.4 + t))
    motes(name, pts, rad, emit_mat("fw_" + col, col, 12.0))
    motes(name + "_c", [Vector(center)], [0.08 * radius], M("mote_white"), 2)


# ------------------------------------------------------------------------------------- panels
SKY_DAY = [(0.0, "fbefe0"), (0.45, "cfe4ff"), (1.0, "6fb2f0")]
SKY_DUSK = [(0.0, "ffd9b0"), (0.4, "f6c2d8"), (0.75, "b7a1e6"), (1.0, "7a6ad0")]
SKY_GOLD = [(0.0, "fff0c8"), (0.5, "ffd8a0"), (1.0, "f0a07a")]


def s01(a):
    sc = scene(a.samples, [(0.0, "2a1630"), (1.0, "3b2346")], amb="ffd8b0", amb_str=0.25, exposure=-0.1)
    f, r = camera(sc, (0.15, -6.9, 2.1), (0.15, 0.8, 1.5), 36)
    rig(f, r, key=("ffe2b8", 2.0), fill=("b8c4ff", 0.35), rim=("ffe0a8", 1.2))
    rbox("floor", (14, 9, 0.2), (0, 1.5, -0.1), M("planks"), 0)
    rbox("wall", (14, 0.4, 7.5), (0, 4.0, 3.6), M("wall"), 0)
    rbox("wainscot", (14, 0.12, 1.1), (0, 3.78, 0.55), M("wall_panel"), 0.1)
    rbox("rail", (14, 0.2, 0.12), (0, 3.76, 1.12), M("wood"), 0.3)
    # arched window behind the lectern: cool backlight for rims
    rbox("win_pane", (1.7, 0.05, 2.4), (0.25, 3.76, 2.9), M("window"), 0)
    wz.ellipsoid("win_arch", (0.25, 3.77, 4.1), (0.85, 0.03, 0.85), M("window"))
    for x in (-0.6, 0.25, 1.1):
        rbox(f"mull{x}", (0.09, 0.12, 3.3), (x, 3.7, 3.2), M("wood_dark"), 0.3)
    for z in (2.2, 3.3, 4.1):
        rbox(f"mullh{z}", (1.8, 0.12, 0.08), (0.25, 3.7, z), M("wood_dark"), 0.3)
    rbox("sill", (2.0, 0.35, 0.12), (0.25, 3.6, 1.66), M("wood"), 0.3)
    al = bpy.data.lights.new("win_light", "AREA")
    al.color, al.energy, al.size = lin("c8d4ff")[:3], 900, 2.0
    ao_ = link(bpy.data.objects.new("win_light", al))
    ao_.location = (0.25, 3.4, 3.0)
    ao_.rotation_euler = Vector((0, -1, -0.25)).to_track_quat("-Z", "Y").to_euler()
    shelf("shelfL", (-3.7, 2.4, 0), 28, 2.2, 3.8, 0.5, 4, 1,
          extras=[(1, 0.5, "potion:b48ad8"), (1, 0.85, "potion:e0483c"), (2, 0.6, "star"), (3, 0.6, "plant"),
                  (0, 0.6, "candle")])
    shelf("shelfR", (3.8, 2.4, 0), -28, 2.2, 3.8, 0.5, 4, 2,
          extras=[(2, 0.5, "potion:4ad8d8"), (2, 0.85, "potion:f8c840"), (3, 0.55, "candle"), (0, 0.6, "plant")])
    # lectern + glowing book
    lathe("lectern", [(0.36, 0), (0.34, 0.08), (0.17, 0.16), (0.13, 0.55), (0.18, 0.8), (0.32, 0.9)], M("wood_dark"), seg=24,
          loc=(-0.55, 0.6, 0))
    top = [rbox("lec_top", (0.95, 0.7, 0.07), (0, 0, 0), M("wood"), 0.3)] + open_book("book", 0.82)
    for o in top[1:]:
        o.location.z += 0.05
    group("lec_g", top, (-0.55, 0.6, 0.97), rot=(18, 0, 0))
    star("lec_star", (-0.55, 0.42, 0.5), 0.09, (0, -1, 0), M("gold"))
    point_light("book_glow", (-0.55, 0.45, 1.4), "ffd890", 140, 0.25)
    pts = spiral((-0.55, 0.62, 1.15), 0.12, 0.95, 2.6, 2.4, 70)
    rnd = random.Random(4)
    motes("book_motes", pts, [0.025 + 0.02 * rnd.random() for _ in pts], M("mote_gold"))
    pts2 = spiral((-0.55, 0.62, 1.2), 0.2, 1.2, 2.3, 2.0, 40, phase=2.5)
    motes("book_motes2", pts2, [0.018 + 0.015 * rnd.random() for _ in pts2], M("mote_white"))
    for i, p in enumerate(pts[18::12][:4]):
        block(f"spirit{i}", p + Vector((0, 0, 0.1)), "toy", TOY_ORDER[i], 0.15, rot=(20 * i, 30, 15 * i))
    sparkle_field("dust", (0, 1.0, 2.6), (3.0, 1.2, 1.6), 40, 9)
    # cast: wizard points from the right, elf gasps left, knight bottom right
    cast_member("wizard", "point", (1.15, 0.75, 0.12), -30)
    cast_member("elf", "idle", (-2.05, 0.15, 0), 32)
    cast_member("knight", "idle", (2.35, -0.25, 0), -32)
    globe("globe", (-3.0, 0.9, 0.0), 0.32)
    bottle("floor_pot", 0.5, "b48ad8", (-2.9, -0.35, 0))
    for i in range(3):
        rbox(f"stack{i}", (0.55 - i * 0.05, 0.4, 0.1), (3.1, 0.6, 0.05 + i * 0.1), paint("book_s" + str(i), ["4a6fb0", "c8352e", "4f9a3a"][i],
                                                                                         ao=0.2), 0.2, rot=(0, 0, i * 12))
    return sc


def s02(a):
    sc = scene(a.samples, SKY_DUSK, amb="e8dcff", amb_str=0.6, exposure=-0.25)
    f, r = camera(sc, (0, -10, 2.2), (0.5, 3, 1.6), 30)
    rig(f, r, key=("ffe6c4", 3.0), fill=("b8c4ff", 0.8), rim=("ffd8a8", 2.6))
    island("isA", (1.0, 3.0, 0), 2.1, 2.6, seed=1)
    island("isB", (-3.6, 7.5, 1.6), 1.4, 2.0, seed=2)
    island("isC", (5.2, 10, 3.0), 1.2, 1.8, seed=3)
    rnd = random.Random(2)
    kinds = [("meadow", "")] + [("toy", c) for c in TOY_ORDER]
    tower_stack("tA", (1.0, 3.0, 0.21), kinds[:4], 0.5, lean=10, seed=1)
    # broken upper half tumbling right and down
    for i in range(6):
        p = (1.9 + i * 0.55 + rnd.uniform(-0.2, 0.2), 3.0 + rnd.uniform(-0.4, 0.4), 2.6 - i * 0.75 + rnd.uniform(-0.2, 0.2))
        block(f"fallA{i}", p, "toy", TOY_ORDER[(i + 3) % 8], 0.5, rot=(rnd.uniform(-60, 60), rnd.uniform(-60, 60), rnd.uniform(0, 90)))
        cloud(f"dustA{i}", Vector(p) + Vector((-0.35, 0.2, 0.25)), 0.18, 50 + i, n=4)
    tower_stack("tB", (-3.6, 7.5, 1.74), [("meadow", "")] + [("toy", c) for c in ("pink", "yellow", "green", "blue")], 0.45,
                lean=-28, drift=(-0.9, 0), seed=2)
    for i in range(4):
        block(f"fallB{i}", (-4.8 - i * 0.4, 7.2, 2.6 - i * 1.0), "toy", TOY_ORDER[(i + 5) % 8], 0.45,
              rot=(rnd.uniform(-60, 60), rnd.uniform(-60, 60), rnd.uniform(0, 90)))
    tower_stack("tC", (5.2, 10, 3.12), [("meadow", ""), ("toy", "red")], 0.45, lean=6, seed=3)
    for i in range(3):
        block(f"fallC{i}", (5.9 + i * 0.3, 9.8, 3.0 - i * 1.1), "toy", TOY_ORDER[i + 1], 0.45, rot=(i * 30, 40, i * 20))
    sparkle_field("spk", (0.5, 4.0, 1.5), (5.0, 2.0, 2.2), 40, 3)
    # cloud sea + sky clouds
    for i in range(9):
        cloud(f"sea{i}", (-7 + i * 1.8, 5 + (i % 3) * 2.5, -2.6 - (i % 2) * 0.4), 1.4, 10 + i, n=7, stretch=1.4)
    sky_clouds([((-6, 16, 6), 2.0, 1), ((7, 18, 7), 2.4, 2)])
    cast_member("wizard", "oops", (-2.6, -0.5, 1.75), 22, 0.95)
    for i in range(2):
        cloud(f"poof{i}", (-2.5 + i * 0.5, -0.4, 1.7), 0.35, 70 + i, n=4)
    return sc


def s03(a):
    sc = scene(a.samples, SKY_GOLD, amb="ffe2c8", amb_str=0.55, exposure=-0.25)
    f, r = camera(sc, (0, -9.5, 2.3), (0.9, 3.5, 2.0), 30)
    rig(f, r, key=("ffd8a8", 3.2), fill=("c4b8ff", 0.7), rim=("ffe0a8", 2.8))
    island("isA", (2.6, 8, 2.6), 1.3, 1.8, seed=4)
    island("isB", (5.6, 13, 4.6), 1.1, 1.5, seed=5)
    island("isC", (-1.5, 14, 5.2), 1.0, 1.4, seed=6)
    tree("trA", (2.9, 8.2, 2.73), 0.8, 1)
    tree("trC", (-1.3, 14, 5.3), 0.6, 2)
    # foreground ledge of the library tower
    island("ledge", (-2.6, 0.6, 0.0), 1.9, 2.4, seed=7)
    tower_stack("libt", (-3.6, 1.2, 0.19), [("meadow", "")] + [("toy", c) for c in ("purple", "blue", "purple")], 0.55, seed=4)
    cast_member("wizard", "oops", (-1.9, 0.1, 0.38), 28)
    # the tomes flee in a sweeping arc toward the islands
    rnd = random.Random(8)
    targets = [(2.6, 8, 3.6), (5.6, 13, 5.4), (-1.5, 14, 6.0)]
    starts = [(-0.4, 0.6, 2.0), (0.4, 1.4, 2.7), (1.2, 2.6, 2.2), (0.0, 3.5, 3.4), (1.8, 5.0, 3.4), (3.6, 9.5, 4.6),
              (0.8, 7.5, 4.6)]
    for i, p in enumerate(starts):
        sz = 0.62 - 0.05 * i
        parts = tome(f"tome{i}", sz, rnd.uniform(90, 150))
        group(f"tome{i}_g", parts, p, rot=(rnd.uniform(-30, 30), rnd.uniform(-25, 25), rnd.uniform(-40, 40)))
        tgt = targets[i % 3]
        trail = arc(Vector(p) - (Vector(tgt) - Vector(p)).normalized() * 1.6, Vector(p), 0.25, 14)
        motes(f"trail{i}", trail[:-2], [0.012 + 0.02 * k / 14 for k in range(12)], M("mote_gold"))
        point_light(f"tglow{i}", p, "ffd890", 25, 0.2)
    sparkle_field("spk", (1.0, 4.0, 2.6), (4.0, 3.0, 1.8), 50, 5, ("mote_gold", "mote_pink"))
    for i in range(7):
        cloud(f"sea{i}", (-6 + i * 2.2, 8 + (i % 3) * 3, -1.4), 1.6, 20 + i, n=7, stretch=1.4)
    sky_clouds([((7, 20, 8), 2.6, 3), ((-7, 22, 8.5), 2.2, 4)])
    return sc


def s04(a):
    sc = scene(a.samples, SKY_DAY, amb="e8dcff", amb_str=0.65, exposure=-0.3)
    f, r = camera(sc, (0.2, -8.6, 3.0), (0.2, 3.0, 1.5), 30)
    rig(f, r, key=("fff0d6", 3.2), fill=("b8c4ff", 0.8), rim=("ffe0a8", 2.4))
    island("ground", (0.4, 1.6, 0), 4.6, 3.0, seed=11)
    gz = top_z(4.6)
    path = [(-3.4, -1.0, gz), (0.0, -0.9, gz), (2.4, 0.2, gz), (1.0, 2.2, gz), (-0.6, 3.6, gz), (0.4, 5.2, gz), (1.2, 6.0, gz)]
    ribbon("path", path, 1.3, M("path"))
    cyaw, cpos = 12.0, Vector((0.0, -0.9, gz))
    group("cart_g", cart("cart"), cpos, cyaw)
    Rz = Matrix.Rotation(math.radians(cyaw), 3, "Z")
    for i, (hero, lx) in enumerate((("knight", -0.46), ("dwarf", 0.0), ("elf", 0.46))):
        cast_member(hero, "cheer" if hero != "dwarf" else "idle", cpos + Rz @ Vector((lx, 0.0, 0.9)), cyaw + (1 - i) * 10, 0.92)
    fence = [(-3.2 + 0.45 * i, 0.6 + 0.5 * i, gz) for i in range(5)]
    for i, p in enumerate(fence):
        rbox(f"post{i}", (0.1, 0.1, 0.5), (p[0], p[1], gz + 0.22), M("fence"), 0.3)
    for i in range(4):
        a_, b_ = fence[i], fence[i + 1]
        mid = ((a_[0] + b_[0]) / 2, (a_[1] + b_[1]) / 2, gz + 0.34)
        ang = math.degrees(math.atan2(b_[1] - a_[1], b_[0] - a_[0]))
        rbox(f"rail{i}", (1.03, 0.06, 0.06), mid, M("fence"), 0.3, rot=(0, 0, ang))
    tree("tree1", (-2.6, 3.0, gz - 0.04), 1.1, 3)
    tree("tree2", (3.6, 0.9, gz - 0.06), 0.95, 4)
    tree("tree3", (2.6, 4.4, gz - 0.06), 0.8, 5)
    # biomes in the distance
    island("iceI", (-5.4, 9.0, 2.6), 1.9, 2.2, top="snow", under="ice_rock", seed=12, dress=False)
    ice_castle("castle", (-5.4, 9.2, 2.6 + top_z(1.9)), 1.0)
    for i, (x, y) in enumerate(((-6.6, 8.4), (-4.3, 8.3), (-6.3, 9.9))):
        pine(f"pine{i}", (x, y, 2.6 + top_z(1.9)), 0.7, snow=True)
    island("volI", (1.5, 16.0, 3.2), 2.4, 2.4, under="dark_rock", seed=13, flowers=False)
    volcano("volcano", (1.5, 16.2, 3.2 + top_z(2.4)), 1.5)
    island("neonI", (6.0, 10.5, 2.6), 1.9, 2.2, top="neon_ground", under="dark_rock", seed=14, dress=False)
    neon_city("city", (6.0, 10.5, 2.6 + top_z(1.9)), 1.0)
    for i in range(8):
        cloud(f"sea{i}", (-8 + i * 2.4, 9 + (i % 3) * 3.0, -1.0 - (i % 2) * 0.5), 1.7, 30 + i, n=7, stretch=1.4)
    sky_clouds([((-3, 24, 9), 2.4, 5), ((8, 22, 10.5), 2.0, 6), ((-9, 18, 7.5), 1.6, 7)])
    return sc


def s10(a):
    sc = scene(a.samples, SKY_DAY, amb="e8dcff", amb_str=0.65, exposure=-0.3)
    f, r = camera(sc, (0, -8.2, 2.6), (0, 1.0, 1.25), 33)
    rig(f, r, key=("fff0d6", 3.2), fill=("b8c4ff", 0.8), rim=("ffe0a8", 2.6))
    island("main", (0, 1.2, 0), 3.0, 2.8, seed=21)
    gz = top_z(3.0)
    group("chest_g", chest("chest", 1.0), (0, 1.5, gz), 0)
    rnd = random.Random(21)
    for i in range(7):
        p = (rnd.uniform(-1.0, 1.0), 1.4 + rnd.uniform(-0.2, 0.2), 1.9 + rnd.uniform(0, 1.2))
        if i % 2:
            rbox(f"flyc{i}", (0.2,) * 3, p, M("gold"), 0.2, rot=(rnd.uniform(0, 60), rnd.uniform(0, 60), 20))
        else:
            star(f"flys{i}", p, 0.13, (rnd.uniform(-0.3, 0.3), -1, 0.2))
    for i in range(6):
        p = (rnd.uniform(-1.1, 1.1), rnd.uniform(0.3, 0.8), gz + 0.06)
        bm = bmesh.new()
        ico(bm, p, 0.09, 1)
        c = ["e0483c", "4cc04a", "4aa8e8", "b48ad8", "ff8ac8", "4ad8d8"][i]
        wz.mesh_obj(f"spill{i}", bm, glassy("gem_" + c, c, 0.8, 0.3), smooth=False)
    cast_member("wizard", "cheer", (-2.0, 1.0, gz), 22)
    cast_member("knight", "cheer", (2.0, 1.0, gz), -24)
    cast_member("elf", "cheer", (-1.1, -0.2, gz), 14)
    cast_member("dwarf", "cheer", (1.15, -0.25, gz), -14)
    # restored towers in the distance, crowned with stars
    for i, (x, y, z, n) in enumerate(((-5.5, 11, 1.5, 6), (5.6, 12, 2.0, 7), (-1.8, 16, 3.5, 5))):
        island(f"far{i}", (x, y, z), 1.2, 1.6, seed=30 + i)
        tower_stack(f"ft{i}", (x, y, z + top_z(1.2)), [("meadow", "")] + [("toy", TOY_ORDER[(k + i) % 8]) for k in range(n - 1)], 0.42,
                    seed=i)
        star(f"fstar{i}", (x, y - 0.1, z + top_z(1.2) + n * 0.425 + 0.3), 0.22)
    confetti("conf", (0, 1.0, 2.4), (3.8, 1.5, 1.8), 210, 3)
    firework("fw1", (-4.2, 6, 5.6), 1.4, "ff8ac8", 1)
    firework("fw2", (4.4, 6, 5.4), 1.2, "ffd860", 2)
    firework("fw3", (-2.6, 9, 6.6), 0.9, "8ef0ff", 3)
    firework("fw4", (3.0, 9, 6.8), 0.8, "b4f080", 4)
    for i in range(7):
        cloud(f"sea{i}", (-7 + i * 2.3, 6 + (i % 3) * 3, -2.0), 1.7, 40 + i, n=7, stretch=1.4)
    sky_clouds([((-7, 20, 4.2), 2.2, 8), ((7.5, 21, 3.8), 2.4, 9)])
    return sc


def s11(a):
    sc = scene(a.samples, SKY_DAY, amb="e8dcff", amb_str=0.65, exposure=-0.3)
    f, r = camera(sc, (0, -8.0, 2.3), (0.3, 1.0, 1.25), 34)
    rig(f, r, key=("fff0d6", 3.2), fill=("b8c4ff", 0.8), rim=("ffe0a8", 2.4))
    island("tut", (1.3, 1.3, 0), 2.1, 2.4, seed=41)
    gz = top_z(2.1)
    tree("tutTree", (2.6, 2.3, gz - 0.03), 0.8, 6)
    for i, (x, y, c) in enumerate(((0.5, 0.9, "blue"), (0.95, 0.9, "blue"), (2.0, 1.1, "pink"), (2.0, 1.55, "yellow"),
                                   (1.6, 1.9, "green"))):
        block(f"tb{i}", (x, y, gz + 0.22), "toy", c, 0.44, rot=(0, 0, random.Random(i).uniform(-4, 4)))
    block("tb_up", (2.0, 1.1, gz + 0.66), "toy", "purple", 0.44)
    # target slot + ghost + the block being placed
    tx, ty = 1.4, 0.55
    for k, (dx, dy, sx, sy) in enumerate(((0, -0.24, 0.5, 0.04), (0, 0.24, 0.5, 0.04), (-0.24, 0, 0.04, 0.5), (0.24, 0, 0.04, 0.5))):
        rbox(f"slot{k}", (sx, sy, 0.03), (tx + dx, ty + dy, gz + 0.02), emit_mat("slot", "fff2a0", 6.0), 0.3)
    block("ghost", (tx, ty, gz + 0.22), "ghost", "", 0.44)
    block("placing", (tx - 0.05, ty - 0.05, 1.5), "toy", "orange", 0.44, rot=(8, -10, 12))
    path_pts = arc((-1.4, 0.2, 2.6), (tx - 0.1, ty, 1.8), 0.6, 16)
    motes("wandpath", path_pts, [0.03] * len(path_pts), M("mote_gold"))
    motes("dots", [Vector((tx, ty, 1.15 - 0.15 * k)) for k in range(4)], [0.03] * 4, M("mote_white"))
    sparkle_field("spk", (tx, ty, 1.5), (0.5, 0.3, 0.4), 18, 7)
    point_light("place_glow", (tx, ty - 0.4, 1.4), "fff0b0", 60, 0.2)
    cast_member("wizard", "point", (-2.1, -0.2, 1.55), 22, 1.0, mirror=True)
    for i in range(7):
        cloud(f"sea{i}", (-7 + i * 2.3, 5 + (i % 3) * 2.5, -2.2), 1.6, 50 + i, n=7, stretch=1.4)
    sky_clouds([((-6, 16, 5), 2.0, 10), ((6.5, 17, 6.5), 2.4, 11), ((1, 22, 8.5), 1.8, 12)])
    return sc


PANELS = {
    "S01": ("s01_story_begins", s01), "S02": ("s02_towers_fell", s02), "S03": ("s03_lost_tomes", s03),
    "S04": ("s04_explore_biomes", s04), "S10": ("s10_story_victory", s10), "S11": ("s11_tutorial", s11),
}
TIER_A = ["S01", "S02", "S03", "S04", "S10", "S11"]


# ------------------------------------------------------------------------------- 2D post (numpy)
def load_px(path):
    im = bpy.data.images.load(path, check_existing=False)
    w, h = im.size
    a = np.empty(w * h * 4, np.float32)
    im.pixels.foreach_get(a)
    bpy.data.images.remove(im)
    return a.reshape(h, w, 4)[::-1].copy()


def save_px(a, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    h, w, _ = a.shape
    im = bpy.data.images.new("out", w, h, alpha=True)
    im.pixels.foreach_set(np.ascontiguousarray(np.clip(a[::-1], 0, 1)).ravel().astype(np.float32))
    im.filepath_raw = path
    im.file_format = "PNG"
    im.save()
    bpy.data.images.remove(im)
    print("WROTE", path)


def _integ(a):
    s = a.astype(np.float64).cumsum(0).cumsum(1)
    pad = [(1, 0), (1, 0)] + [(0, 0)] * (a.ndim - 2)
    return np.pad(s, pad)


def box_blur(a, r):
    H_, W_ = a.shape[:2]
    p = np.pad(a, [(r + 1, r), (r + 1, r)] + [(0, 0)] * (a.ndim - 2), mode="edge")
    S = p.astype(np.float64).cumsum(0).cumsum(1)
    k = 2 * r + 1
    out = S[k:k + H_, k:k + W_] - S[0:H_, k:k + W_] - S[k:k + H_, 0:W_] + S[0:H_, 0:W_]
    return (out / (k * k)).astype(np.float32)


def kuwahara(rgb, r):
    """Classic 4-quadrant Kuwahara: flattens micro-noise into brush-like patches (painted look)."""
    H_, W_ = rgb.shape[:2]
    lum = rgb @ np.array([0.299, 0.587, 0.114], np.float32)
    p = np.pad(rgb, ((r, r), (r, r), (0, 0)), mode="edge")
    pl = np.pad(lum, r, mode="edge")
    S, SL, SL2 = _integ(p), _integ(pl), _integ(pl * pl)
    k = r + 1
    n = float(k * k)
    best = np.full((H_, W_), np.inf, np.float32)
    out = np.zeros_like(rgb)
    for dy in (0, r):
        for dx in (0, r):
            def win(I):
                return I[dy + k:dy + k + H_, dx + k:dx + k + W_] - I[dy:dy + H_, dx + k:dx + k + W_] \
                    - I[dy + k:dy + k + H_, dx:dx + W_] + I[dy:dy + H_, dx:dx + W_]
            m = (win(S) / n).astype(np.float32)
            ml = win(SL) / n
            v = win(SL2) / n - ml * ml
            sel = v < best
            out[sel] = m[sel]
            best = np.minimum(best, v)
    return out


def post(raw, final, thumb):
    a = load_px(raw)
    rgb = a[..., :3].astype(np.float32)
    h, w = rgb.shape[:2]
    k = max(1, round(2 * w / 1600))
    rgb = 0.55 * kuwahara(rgb, k) + 0.45 * rgb
    lum = rgb @ np.array([0.299, 0.587, 0.114], np.float32)
    bright = rgb * np.clip((lum - 0.72) / 0.28, 0, 1)[..., None]
    bloom = np.zeros_like(rgb)
    for rad, wgt in ((max(2, w // 200), 0.35), (max(6, w // 60), 0.3)):
        b = bright
        for _ in range(3):
            b = box_blur(b, rad)
        bloom += wgt * b
    rgb = 1 - (1 - rgb) * (1 - np.clip(bloom, 0, 1))          # screen blend
    lum = rgb @ np.array([0.299, 0.587, 0.114], np.float32)
    rgb = lum[..., None] + (rgb - lum[..., None]) * 1.1          # saturation
    plum = np.array([0.23, 0.14, 0.27], np.float32)
    lift = np.clip(0.18 - lum, 0, 0.18)[..., None] / 0.18 * 0.25
    rgb = rgb * (1 - lift) + plum * lift                        # shadows lift toward plum, never black
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    d = ((xx / w - 0.5) ** 2 + (yy / h - 0.5) ** 2 * 0.8) / 0.5
    vig = (1 - 0.22 * d ** 1.4)[..., None]
    rgb = rgb * vig + plum * (1 - vig) * 0.6
    out = np.dstack([np.clip(rgb, 0, 1), np.ones((h, w), np.float32)])
    save_px(out, final)
    th = out.reshape(h // 4, 4, w // 4, 4, 4).mean(axis=(1, 3))
    save_px(th, thumb)


def resize(a, w, h):
    H_, W_ = a.shape[:2]
    if W_ >= 2 * w:   # pre-average for clean downscales
        f = W_ // w
        a = a[:a.shape[0] // f * f, :a.shape[1] // f * f].reshape(a.shape[0] // f, f, a.shape[1] // f, f, -1).mean(axis=(1, 3))
        H_, W_ = a.shape[:2]
    ys = np.clip(((np.arange(h) + 0.5) * H_ / h - 0.5), 0, H_ - 1)
    xs = np.clip(((np.arange(w) + 0.5) * W_ / w - 0.5), 0, W_ - 1)
    y0, x0 = ys.astype(int), xs.astype(int)
    y1, x1 = np.minimum(y0 + 1, H_ - 1), np.minimum(x0 + 1, W_ - 1)
    fy, fx = (ys - y0)[:, None, None], (xs - x0)[None, :, None]
    top = a[y0][:, x0] * (1 - fx) + a[y0][:, x1] * fx
    bot = a[y1][:, x0] * (1 - fx) + a[y1][:, x1] * fx
    return top * (1 - fy) + bot * fy


def sheet(root):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    art = os.path.join(root, "assets/art/story")
    ev = os.path.join(root, "production/qa/evidence/story-v2")
    names = sorted(f for f in os.listdir(art) if f.endswith(".png") and not f.endswith("_thumb.png"))
    cols, tw, th, pad = 4, 400, 300, 16
    rows = max(1, math.ceil(len(names) / cols))
    canvas = np.ones((pad + rows * (th + pad), pad + cols * (tw + pad), 4), np.float32)
    canvas[..., :3] = np.array([0.965, 0.906, 0.769])
    for i, nm in enumerate(names):
        img = resize(load_px(os.path.join(art, nm)), tw, th)
        y, x = pad + (i // cols) * (th + pad), pad + (i % cols) * (tw + pad)
        canvas[y:y + th, x:x + tw] = img
        canvas[y + int(th * 0.82):y + int(th * 0.82) + 1, x:x + tw, :3] = (0.9, 0.3, 0.3)   # ribbon safe line
    save_px(canvas, os.path.join(ev, "contact_sheet.png"))
    board = load_px(os.path.join(root, "assets/art/reference/style/01_story_flow.jpg"))
    bh, bw = board.shape[:2]
    q1 = board[:bh // 2, :bw // 2]
    q3 = board[bh // 2:, :bw // 2]
    pw, ph = 800, 600
    out = np.ones((ph * 2 + 3 * pad, pw * 2 + 3 * pad, 4), np.float32)
    out[..., :3] = np.array([0.965, 0.906, 0.769])
    for r_, (ref, nm) in enumerate(((q1, "s01_story_begins.png"), (q3, "s04_explore_biomes.png"))):
        y = pad + r_ * (ph + pad)
        out[y:y + ph, pad:pad + pw] = resize(ref, pw, ph)
        p = os.path.join(art, nm)
        if os.path.exists(p):
            out[y:y + ph, 2 * pad + pw:2 * pad + 2 * pw] = resize(load_px(p), pw, ph)
    save_px(out, os.path.join(ev, "compare_s01_s04_vs_board01.png"))


# ---------------------------------------------------------------------------------------- main
def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    ap = argparse.ArgumentParser()
    ap.add_argument("--panel", default="tierA", help="S01,S04 | tierA | all")
    ap.add_argument("--samples", type=int, default=40)
    ap.add_argument("--preview", action="store_true", help="half size, 10 samples, writes to the temp dir")
    ap.add_argument("--sheet", action="store_true")
    ap.add_argument("--root", default=os.getcwd())
    a = ap.parse_args(argv)
    if a.sheet:
        sheet(a.root)
        return
    ids = TIER_A if a.panel == "tierA" else (list(PANELS) if a.panel == "all" else a.panel.upper().split(","))
    tmp = tempfile.gettempdir()
    for pid in ids:
        slug, fn = PANELS[pid]
        if a.preview:
            a.samples = 10
        sc = fn(a)
        sc.render.resolution_x, sc.render.resolution_y = (W // 2, H // 2) if a.preview else (W, H)
        raw = os.path.join(tmp, f"wt_{slug}_raw.png")
        wz.render(sc, raw)
        if a.preview:
            post(raw, os.path.join(tmp, f"wt_{slug}_preview.png"), os.path.join(tmp, f"wt_{slug}_pthumb.png"))
        else:
            art = os.path.join(a.root, "assets/art/story")
            post(raw, os.path.join(art, slug + ".png"), os.path.join(art, slug + "_thumb.png"))


if __name__ == "__main__":
    main()
