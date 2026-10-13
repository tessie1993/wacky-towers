"""Wacky Towers UI kit generator.

Builds every UI kit element as chunky, bevelled 3D geometry in Blender, shades it
with painted-wood / parchment / brass / glossy-paint materials (Poly Haven CC0
textures pushed through colour ramps for a hand-painted cartoon look, with an
inverted-hull ink outline) and renders each element top-down with an
orthographic camera onto a transparent background.

Usage (from the repo root):
    blender -b --factory-startup -P assets/source/blender/ui_kit/build_ui_kit.py
    blender -b --factory-startup -P .../build_ui_kit.py -- only=icon_star,panel_wood
    python3 assets/source/blender/ui_kit/build_ui_kit.py --contact-sheet

Outputs:
    assets/art/ui/kit/*.png             element textures (2x scale)
    assets/art/ui/kit/ninepatch.json    StyleBoxTexture / NinePatchRect margins
    production/qa/evidence/ui-kit/contact_sheet.png

Deterministic: no unseeded randomness; geometry and materials are pure functions
of the constants below. Set UIKIT_ENGINE=EEVEE to render with EEVEE instead
of Cycles.  (Default is Cycles CPU: EEVEE needs libEGL, absent on the headless build box.)
"""
import json
import math
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
OUT = os.path.join(REPO, "assets", "art", "ui", "kit")
TP = os.path.join(REPO, "assets", "third_party")
SHEET = os.path.join(REPO, "production", "qa", "evidence", "ui-kit", "contact_sheet.png")
CHEST_BLEND = os.path.join(TP, "blendkit", "stylised_treasure_chest", "stylised_treasure_chest.blend")

PPU = 100.0          # output pixels per Blender unit (before PAD)
PAD = 1.07           # camera framing slack so bevels + ink lines never clip
OUTLINE_PX = 3.0     # ink outline width for panels / buttons
ICON_OUTLINE_PX = 2.5

# Nine-patch margins (left, top, right, bottom) in output pixels.
NINEPATCH = {
    "panel_wood": (84, 84, 84, 84),
    "panel_parchment": (84, 84, 84, 84),
    "plaque_wood": (76, 64, 76, 64),
    "ribbon_red": (124, 52, 124, 60),
    "ribbon_gold": (124, 52, 124, 60),
    "btn_wood_square": (52, 52, 52, 56),
    "btn_wood_square_pressed": (52, 52, 52, 56),
    "btn_green_play": (76, 56, 76, 60),
    "btn_gold_pill": (76, 56, 76, 60),
    "btn_cream_pill": (76, 56, 76, 60),
    "slot_next_block": (48, 48, 48, 48),
    "card_player": (40, 40, 120, 40),
    "meter_tube": (36, 56, 36, 132),
    "meter_fill_mask": (36, 56, 36, 132),
    "bar_frame": (36, 26, 36, 26),
    "bar_fill": (36, 26, 36, 26),
    "counter_pill": (44, 34, 84, 34),
}

# --------------------------------------------------------------------------------------
# Contact sheet (plain CPython + Pillow; runs outside Blender)
# --------------------------------------------------------------------------------------

def build_contact_sheet():
    from PIL import Image, ImageDraw, ImageFont, ImageChops

    def load(n):
        return Image.open(os.path.join(OUT, n + ".png")).convert("RGBA")

    def tint(im, rgb):
        r, g, b = rgb
        px = Image.new("RGBA", im.size, (r, g, b, 255))
        out = ImageChops.multiply(im, px)
        out.putalpha(im.getchannel("A"))
        return out

    W, H = 2200, 2350
    sheet = Image.new("RGBA", (W, H))
    top, bot = (110, 190, 245), (190, 232, 255)
    d = ImageDraw.Draw(sheet)
    for y in range(H):
        t = y / H
        d.line([(0, y), (W, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)) + (255,))
    try:
        font = ImageFont.load_default(size=22)
        big = ImageFont.load_default(size=40)
    except TypeError:
        font = big = ImageFont.load_default()
    d.text((40, 24), "Wacky Towers - UI kit (Blender build_ui_kit.py)", fill=(30, 40, 70, 255), font=big)

    def put(im, x, y, label, scale=1.0):
        if scale != 1.0:
            im = im.resize((int(im.width * scale), int(im.height * scale)), Image.LANCZOS)
        sheet.alpha_composite(im, (int(x), int(y)))
        d.text((x, y + im.height + 4), label, fill=(25, 35, 60, 255), font=font)
        return im

    # Row 1: big panels
    y = 90
    x = 40
    for n in ["panel_wood", "panel_parchment"]:
        put(load(n), x, y, n, 0.75)
        x += 420
    put(load("plaque_wood"), x, y, "plaque_wood", 1.0)
    put(load("ribbon_red"), x, y + 290, "ribbon_red")
    put(load("ribbon_gold"), x + 540, y + 290, "ribbon_gold", 0.9)
    put(load("bunting"), x + 540, y + 40, "bunting", 0.9)

    # Row 2: buttons
    y = 590
    x = 40
    btn = load("btn_wood_square")
    for n, lab in [("btn_wood_square", "btn_wood_square"), ("btn_wood_square_pressed", "..._pressed")]:
        put(load(n), x, y, lab, 0.8)
        x += 200
    # usage demo: cog icon on wood button
    demo = load("btn_wood_square").copy()
    cog = load("icon_cog")
    demo.alpha_composite(cog, ((demo.width - 128) // 2, (demo.height - 128) // 2 - 4))
    put(demo, x, y, "btn + icon_cog", 0.8)
    x += 200
    for n in ["btn_green_play", "btn_gold_pill", "btn_cream_pill"]:
        put(load(n), x, y + 10, n, 0.8)
        x += 330
    put(load("timer_gear"), x + 20, y - 20, "timer_gear", 0.75)

    # Row 3: HUD elements
    y = 860
    x = 40
    put(load("slot_next_block"), x, y, "slot_next_block")
    x += 220
    put(load("card_player"), x, y + 30, "card_player")
    x += 420
    put(load("counter_pill"), x, y + 30, "counter_pill")
    cp = load("counter_pill").copy()
    cp.alpha_composite(load("icon_coin").resize((76, 76), Image.LANCZOS), (6, 2))
    put(cp, x, y + 150, "counter + coin")
    x += 300
    frame = load("bar_frame")
    put(frame, x, y + 30, "bar_frame")
    fill = tint(load("bar_fill"), (120, 220, 70))
    demo = frame.copy()
    crop = fill.crop((0, 0, int(fill.width * 0.65), fill.height))
    demo.alpha_composite(crop, (0, 0))
    put(demo, x, y + 150, "bar_frame + bar_fill (65%, tinted)")
    put(tint(load("bar_fill"), (240, 90, 60)), x, y + 270, "bar_fill (tinted red)")
    x += 430
    tube = load("meter_tube")
    put(tube, x, y - 20, "meter_tube")
    mask = load("meter_fill_mask")
    put(mask, x + 130, y - 20, "fill_mask")
    # meter demo: gradient fill clipped to 60% from bottom
    grad = Image.new("RGBA", mask.size)
    gd = ImageDraw.Draw(grad)
    stops = [(0.0, (230, 50, 30)), (0.5, (250, 200, 40)), (1.0, (90, 200, 60))]
    for yy in range(mask.height):
        t = 1 - yy / mask.height
        for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
            if t0 <= t <= t1:
                k = (t - t0) / (t1 - t0)
                c = tuple(int(c0[i] + (c1[i] - c0[i]) * k) for i in range(3))
        gd.line([(0, yy), (mask.width, yy)], fill=c + (255,))
    level = int(mask.height * 0.40)
    a = ImageChops.multiply(mask.getchannel("A"), Image.new("L", mask.size, 255))
    a.paste(0, (0, 0, mask.width, level))
    grad.putalpha(a)
    meter = Image.new("RGBA", mask.size)
    meter.alpha_composite(grad)
    meter.alpha_composite(tube)
    put(meter, x + 260, y - 20, "meter demo")

    # Row 4: icons
    y = 1330
    x = 40
    d.text((40, y - 40), "Icons (128 px)", fill=(30, 40, 70, 255), font=big)
    names = ["icon_cog", "icon_pause", "icon_trophy", "icon_play", "icon_star", "icon_coin",
             "icon_gem", "icon_home", "icon_map", "icon_shop", "icon_party", "icon_back"]
    for i, n in enumerate(names):
        put(load(n), 40 + (i % 12) * 175, y + 10, n.replace("icon_", ""))
    # Icons on cream buttons
    y = 1560
    d.text((40, y - 10), "Icons on btn_wood_square (in-game usage)", fill=(30, 40, 70, 255), font=big)
    for i, n in enumerate(names):
        b = btn.copy()
        b.alpha_composite(load(n), ((b.width - 128) // 2, (b.height - 128) // 2 - 4))
        put(b, 40 + (i % 6) * 250, y + 50 + (i // 6) * 260, "", 1.0)

    os.makedirs(os.path.dirname(SHEET), exist_ok=True)
    sheet.convert("RGB").save(SHEET)
    print("contact sheet ->", SHEET)


if __name__ == "__main__" and "--contact-sheet" in sys.argv:
    build_contact_sheet()
    sys.exit(0)

# --------------------------------------------------------------------------------------
# Blender part
# --------------------------------------------------------------------------------------
import bpy  # noqa: E402
import bmesh  # noqa: E402
from mathutils import Vector  # noqa: E402


def srgb(h):
    h = h.lstrip("#")
    c = [int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
    return tuple(((v / 12.92) if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4) for v in c) + (1.0,)


# ---------------------------------------------------------------- geometry helpers (px)

def rrect(w, h, r, seg=10, cx=0.0, cy=0.0):
    r = max(0.0, min(r, w / 2, h / 2))
    pts = []
    corners = [(w / 2 - r, h / 2 - r, 0), (-w / 2 + r, h / 2 - r, 90),
               (-w / 2 + r, -h / 2 + r, 180), (w / 2 - r, -h / 2 + r, 270)]
    for x, y, a0 in corners:
        for i in range(seg + 1):
            a = math.radians(a0 + 90 * i / seg)
            pts.append((cx + x + r * math.cos(a), cy + y + r * math.sin(a)))
    return dedupe(pts)


def circle(r, seg=48, cx=0.0, cy=0.0):
    return [(cx + r * math.cos(2 * math.pi * i / seg), cy + r * math.sin(2 * math.pi * i / seg)) for i in range(seg)]


def dedupe(pts, eps=1e-4):
    out = []
    for p in pts:
        if not out or (abs(p[0] - out[-1][0]) > eps or abs(p[1] - out[-1][1]) > eps):
            out.append(p)
    if len(out) > 1 and abs(out[0][0] - out[-1][0]) < eps and abs(out[0][1] - out[-1][1]) < eps:
        out.pop()
    return out


def round_poly(pts, r, seg=6):
    """Fillet every corner of a closed polygon with radius r."""
    n = len(pts)
    out = []
    for i in range(n):
        P = Vector(pts[i])
        A = Vector(pts[i - 1])
        B = Vector(pts[(i + 1) % n])
        u1 = (A - P)
        u2 = (B - P)
        l1, l2 = u1.length, u2.length
        if l1 < 1e-6 or l2 < 1e-6:
            continue
        u1.normalize()
        u2.normalize()
        cosang = max(-1.0, min(1.0, u1.dot(u2)))
        theta = math.acos(cosang)
        if theta > math.radians(178) or theta < 1e-3:
            out.append(tuple(P))
            continue
        rr = r
        d = rr / math.tan(theta / 2)
        dmax = min(l1, l2) * 0.45
        if d > dmax:
            d = dmax
            rr = d * math.tan(theta / 2)
        T1 = P + u1 * d
        T2 = P + u2 * d
        bis = (u1 + u2).normalized()
        C = P + bis * (rr / math.sin(theta / 2))
        a1 = math.atan2(T1.y - C.y, T1.x - C.x)
        a2 = math.atan2(T2.y - C.y, T2.x - C.x)
        da = (a2 - a1 + math.pi) % (2 * math.pi) - math.pi
        for k in range(seg + 1):
            a = a1 + da * k / seg
            out.append((C.x + rr * math.cos(a), C.y + rr * math.sin(a)))
    return dedupe(out)


def star_pts(R, r, n=5, rot=90.0):
    pts = []
    for i in range(2 * n):
        a = math.radians(rot + 180.0 * i / n)
        rad = R if i % 2 == 0 else r
        pts.append((rad * math.cos(a), rad * math.sin(a)))
    return pts


def gear_pts(n, ro, ri, tooth=0.5, taper=0.62, fillet=3.0):
    pts = []
    da = 2 * math.pi / n
    w = da * tooth
    for i in range(n):
        a0 = da * i
        inset = w * (1 - taper) / 2
        pts.append((ri * math.cos(a0), ri * math.sin(a0)))
        pts.append((ro * math.cos(a0 + inset), ro * math.sin(a0 + inset)))
        pts.append((ro * math.cos(a0 + w - inset), ro * math.sin(a0 + w - inset)))
        pts.append((ri * math.cos(a0 + w), ri * math.sin(a0 + w)))
        for k in range(1, 4):
            a = a0 + w + (da - w) * k / 4
            pts.append((ri * math.cos(a), ri * math.sin(a)))
    return round_poly(pts, fillet, 3)


def thermo_loop(a, top, cy, R, seg=40):
    """Outline of a thermometer: capsule tube (half width a, top y) joined to a bulb circle."""
    pts = []
    tc = top - a
    for i in range(seg // 2 + 1):           # top semicircle, right -> left
        ang = math.pi * i / (seg // 2)
        pts.append((a * math.cos(ang), tc + a * math.sin(ang)))
    phi = math.asin(a / R)                  # angle from vertical where tube meets bulb
    start = math.pi / 2 + phi               # left join, going CCW round the bottom
    end = math.pi / 2 - phi + 2 * math.pi
    for i in range(seg + 1):
        ang = start + (end - start) * i / seg
        pts.append((R * math.cos(ang), cy + R * math.sin(ang)))
    return dedupe(pts)


def offset_pts(pts, dx, dy):
    return [(x + dx, y + dy) for x, y in pts]


def rot_pts(pts, deg, cx=0.0, cy=0.0):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [(cx + (x - cx) * c - (y - cy) * s, cy + (x - cx) * s + (y - cy) * c) for x, y in pts]


# ---------------------------------------------------------------- scene / materials

SC = None
CAM = None
MATS = {}


def link(ob):
    bpy.context.scene.collection.objects.link(ob)


def tex_path(tid, kind):
    return os.path.join(TP, "polyhaven", tid, f"{tid}_{kind}_1k.jpg")


def load_img(path, noncolor=False):
    im = bpy.data.images.load(path, check_existing=True)
    if noncolor:
        im.colorspace_settings.name = "Non-Color"
    return im


def set_render_method(m, blended):
    for attr, val in (("surface_render_method", "BLENDED" if blended else "DITHERED"),
                      ("blend_method", "BLEND" if blended else "OPAQUE")):
        try:
            setattr(m, attr, val)
        except Exception:
            pass


def mat_painted(name, stops, tex=None, scale=1.0, rot=0.0, rough=0.6, metal=0.0, nstr=0.35,
                coat=0.0, grad=0.0, noise=0.25, ao=0.55, alpha=1.0, spec=0.5, grain=0.0):
    """Painted cartoon material: texture luminance + brush noise + vertical gradient -> colour ramp."""
    if name in MATS:
        return MATS[name]
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    N, L = nt.nodes, nt.links
    N.clear()
    out = N.new("ShaderNodeOutputMaterial")
    b = N.new("ShaderNodeBsdfPrincipled")
    L.new(b.outputs[0], out.inputs["Surface"])
    tc = N.new("ShaderNodeTexCoord")
    mp = N.new("ShaderNodeMapping")
    mp.inputs["Scale"].default_value = (scale, scale, scale)
    mp.inputs["Rotation"].default_value = (0, 0, rot)
    L.new(tc.outputs["Object"], mp.inputs["Vector"])

    nz = N.new("ShaderNodeTexNoise")
    nz.inputs["Scale"].default_value = 3.0
    nz.inputs["Detail"].default_value = 3.0
    L.new(mp.outputs[0], nz.inputs["Vector"])
    acc = N.new("ShaderNodeMath")
    acc.operation = "MULTIPLY"
    L.new(nz.outputs["Fac"], acc.inputs[0])
    acc.inputs[1].default_value = noise
    cur = acc.outputs[0]
    base_w = 1.0 - noise - grad - grain
    if grain > 0:  # painted cartoon grain streaks running along X
        wv = N.new("ShaderNodeTexWave")
        wv.wave_type = "BANDS"
        wv.bands_direction = "Y"
        wv.inputs["Scale"].default_value = 0.9
        wv.inputs["Distortion"].default_value = 4.0
        wv.inputs["Detail"].default_value = 2.5
        wv.inputs["Detail Scale"].default_value = 1.5
        L.new(mp.outputs[0], wv.inputs["Vector"])
        gm = N.new("ShaderNodeMath")
        gm.operation = "MULTIPLY_ADD"
        L.new(wv.outputs["Fac"], gm.inputs[0])
        gm.inputs[1].default_value = grain
        L.new(cur, gm.inputs[2])
        cur = gm.outputs[0]
    if tex:
        it = N.new("ShaderNodeTexImage")
        it.image = load_img(tex_path(tex, "diff"))
        L.new(mp.outputs[0], it.inputs[0])
        bw = N.new("ShaderNodeRGBToBW")
        L.new(it.outputs["Color"], bw.inputs[0])
        ma = N.new("ShaderNodeMath")
        ma.operation = "MULTIPLY_ADD"
        L.new(bw.outputs[0], ma.inputs[0])
        ma.inputs[1].default_value = base_w
        L.new(cur, ma.inputs[2])
        cur = ma.outputs[0]
        ni = N.new("ShaderNodeTexImage")
        ni.image = load_img(tex_path(tex, "nor_gl"), True)
        L.new(mp.outputs[0], ni.inputs[0])
        nm = N.new("ShaderNodeNormalMap")
        nm.inputs["Strength"].default_value = nstr
        L.new(ni.outputs["Color"], nm.inputs["Color"])
        L.new(nm.outputs[0], b.inputs["Normal"])
    else:
        ma = N.new("ShaderNodeMath")
        ma.operation = "ADD"
        L.new(cur, ma.inputs[0])
        ma.inputs[1].default_value = base_w * 0.5
        cur = ma.outputs[0]
    if grad > 0:
        sx = N.new("ShaderNodeSeparateXYZ")
        L.new(tc.outputs["Generated"], sx.inputs[0])
        ma = N.new("ShaderNodeMath")
        ma.operation = "MULTIPLY_ADD"
        L.new(sx.outputs["Y"], ma.inputs[0])
        ma.inputs[1].default_value = grad
        L.new(cur, ma.inputs[2])
        cur = ma.outputs[0]
    ramp = N.new("ShaderNodeValToRGB")
    ramp.color_ramp.interpolation = "EASE"
    els = ramp.color_ramp.elements
    while len(els) < len(stops):
        els.new(0.5)
    for e, (pos, col) in zip(els, stops):
        e.position = pos
        e.color = srgb(col)
    L.new(cur, ramp.inputs[0])
    col = ramp.outputs["Color"]
    if ao > 0:
        aon = N.new("ShaderNodeAmbientOcclusion")
        aon.inputs["Distance"].default_value = 0.25
        am = N.new("ShaderNodeMath")
        am.operation = "MULTIPLY_ADD"
        L.new(aon.outputs["AO"], am.inputs[0])
        am.inputs[1].default_value = ao
        am.inputs[2].default_value = 1.0 - ao
        vm = N.new("ShaderNodeVectorMath")
        vm.operation = "MULTIPLY"
        L.new(col, vm.inputs[0])
        L.new(am.outputs[0], vm.inputs[1])
        col = vm.outputs[0]
    L.new(col, b.inputs["Base Color"])
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    for nm_ in ("Specular IOR Level", "Specular"):
        if nm_ in b.inputs:
            b.inputs[nm_].default_value = spec
            break
    if coat > 0 and "Coat Weight" in b.inputs:
        b.inputs["Coat Weight"].default_value = coat
        b.inputs["Coat Roughness"].default_value = 0.15
    if alpha < 1.0:
        b.inputs["Alpha"].default_value = alpha
        set_render_method(m, True)
    MATS[name] = m
    return m


def mat_emit(name, hexcol, strength=1.0, cull=False, alpha=1.0):
    if name in MATS:
        return MATS[name]
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    N, L = m.node_tree.nodes, m.node_tree.links
    N.clear()
    out = N.new("ShaderNodeOutputMaterial")
    e = N.new("ShaderNodeEmission")
    e.inputs["Color"].default_value = srgb(hexcol)
    e.inputs["Strength"].default_value = strength
    if alpha < 1.0:
        tr = N.new("ShaderNodeBsdfTransparent")
        mx = N.new("ShaderNodeMixShader")
        mx.inputs[0].default_value = alpha
        L.new(tr.outputs[0], mx.inputs[1])
        L.new(e.outputs[0], mx.inputs[2])
        L.new(mx.outputs[0], out.inputs["Surface"])
        set_render_method(m, True)
    else:
        L.new(e.outputs[0], out.inputs["Surface"])
    m.use_backface_culling = cull
    if cull:  # Cycles ignores use_backface_culling: make back faces transparent explicitly
        geo = N.new("ShaderNodeNewGeometry")
        tr = N.new("ShaderNodeBsdfTransparent")
        mx = N.new("ShaderNodeMixShader")
        L.new(geo.outputs["Backfacing"], mx.inputs[0])
        L.new(e.outputs[0], mx.inputs[1])
        L.new(tr.outputs[0], mx.inputs[2])
        L.new(mx.outputs[0], out.inputs["Surface"])
    MATS[name] = m
    return m


def build_materials():
    M = {}
    M["outline"] = mat_emit("outline", "#2a140b", 1.0, cull=True)
    M["wood"] = mat_painted("wood", [(0.25, "#a3602a"), (0.45, "#d4943f"), (0.68, "#f4c878")],
                            tex="fine_grained_wood", scale=1.1, rough=0.62, nstr=0.8, noise=0.1, grain=0.16)
    M["wood_dark"] = mat_painted("wood_dark", [(0.25, "#3c1f0f"), (0.45, "#6a3a1c"), (0.68, "#97592c")],
                                 tex="fine_grained_wood", scale=1.1, rough=0.6, nstr=0.8, noise=0.1, grain=0.16)
    M["wood_plank"] = mat_painted("wood_plank", [(0.25, "#c07a32"), (0.5, "#e2a654"), (0.8, "#f8d48c")],
                                  tex="brown_planks_05", scale=0.35, rough=0.6, nstr=0.5)
    M["wood_base"] = mat_painted("wood_base", [(0.3, "#24140c"), (0.7, "#3e271b")],
                                 tex="fine_grained_wood", scale=0.55, rough=0.7, ao=0.3)
    M["cream"] = mat_painted("cream", [(0.3, "#e9cf9c"), (0.6, "#f6e6c0"), (0.85, "#fff6dc")],
                             tex="white_plaster_rough_01", scale=0.6, rough=0.75, nstr=0.25, grad=0.15)
    M["parchment"] = mat_painted("parchment", [(0.25, "#d9b47a"), (0.5, "#efd6a2"), (0.8, "#faecc8")],
                                 tex="white_plaster_rough_01", scale=0.4, rough=0.8, nstr=0.35, ao=0.7)
    M["gold"] = mat_painted("gold", [(0.2, "#d47f12"), (0.5, "#f7b733"), (0.85, "#ffe17a")],
                            rough=0.32, metal=0.25, coat=0.4, grad=0.35, noise=0.15)
    M["gold_light"] = mat_painted("gold_light", [(0.2, "#f2a42a"), (0.6, "#ffd257"), (0.9, "#fff0a8")],
                                  rough=0.3, metal=0.2, coat=0.5, grad=0.35, noise=0.12)
    M["brass"] = mat_painted("brass", [(0.25, "#8f5a17"), (0.55, "#d29a32"), (0.85, "#f5d27a")],
                             tex="metal_plate", scale=0.6, rough=0.38, metal=0.55, nstr=0.3)
    M["green"] = mat_painted("green", [(0.2, "#3f9a1c"), (0.55, "#6cc931"), (0.9, "#a9ee63")],
                             rough=0.35, coat=0.5, grad=0.45, noise=0.12)
    M["green_dark"] = mat_painted("green_dark", [(0.3, "#1f5a10"), (0.7, "#2f7a18")], rough=0.5)
    M["red"] = mat_painted("red", [(0.2, "#a8231a"), (0.55, "#dd3b2a"), (0.9, "#ff7a55")],
                           tex="white_plaster_rough_01", scale=0.5, rough=0.55, nstr=0.25, grad=0.35, noise=0.1)
    M["red_dark"] = mat_painted("red_dark", [(0.3, "#6e130f"), (0.7, "#9c2219")],
                                tex="white_plaster_rough_01", scale=0.5, rough=0.6, nstr=0.25)
    M["ribbon_gold"] = mat_painted("ribbon_gold", [(0.2, "#c77a10"), (0.55, "#f2ae2a"), (0.9, "#ffe07a")],
                                   tex="white_plaster_rough_01", scale=0.5, rough=0.5, nstr=0.25, grad=0.35, noise=0.1)
    M["ribbon_gold_dark"] = mat_painted("ribbon_gold_dark", [(0.3, "#7a4508"), (0.7, "#a8650f")],
                                        tex="white_plaster_rough_01", scale=0.5, rough=0.6, nstr=0.25)
    M["slot"] = mat_painted("slot", [(0.2, "#2c2638"), (0.6, "#463c55"), (0.95, "#5d5170")],
                            rough=0.6, grad=0.35, noise=0.15, ao=0.8)
    M["trough"] = mat_painted("trough", [(0.2, "#21140f"), (0.8, "#3b2519")], rough=0.6, grad=0.3, ao=0.8)
    M["sky"] = mat_painted("sky", [(0.2, "#7fb4d6"), (0.7, "#b6dcf0"), (0.95, "#dff1fb")],
                           rough=0.7, grad=0.5, noise=0.1, ao=0.7)
    M["glyph"] = mat_painted("glyph", [(0.2, "#2f1820"), (0.6, "#4f2c38"), (0.95, "#6e4250")],
                             rough=0.45, grad=0.35, noise=0.1, coat=0.3)
    M["purple"] = mat_painted("purple", [(0.15, "#4b1d8a"), (0.5, "#8a45d6"), (0.9, "#d6a6ff")],
                              rough=0.15, coat=0.8, grad=0.3, noise=0.1, spec=0.8)
    M["purple_light"] = mat_painted("purple_light", [(0.2, "#7a3cc8"), (0.6, "#b37cf0"), (0.95, "#f0dcff")],
                                    rough=0.12, coat=0.8, grad=0.3, noise=0.1, spec=0.8)
    M["blue"] = mat_painted("blue", [(0.2, "#1c5fbf"), (0.6, "#3b8ff0"), (0.9, "#8cc8ff")], rough=0.4, grad=0.4, coat=0.3)
    M["white"] = mat_painted("white", [(0.2, "#e3e3e3"), (0.6, "#f6f6f6"), (0.95, "#ffffff")], rough=0.35, grad=0.35, coat=0.3)
    M["fill_white"] = mat_painted("fill_white", [(0.1, "#c9c9c9"), (0.55, "#ededed"), (0.9, "#ffffff")],
                                  rough=0.3, coat=0.6, grad=0.55, noise=0.05, ao=0.2)
    M["glass"] = mat_painted("glass", [(0.2, "#a9d6e6"), (0.9, "#e9f8ff")], rough=0.05, alpha=0.28,
                             grad=0.4, noise=0.05, ao=0.0, spec=1.0)
    M["gloss"] = mat_emit("gloss", "#ffffff", 1.0, alpha=0.32)
    M["mask"] = mat_emit("mask", "#ffffff", 1.0)
    M["leaf"] = mat_painted("leaf", [(0.2, "#2f7a1e"), (0.55, "#5aad2e"), (0.9, "#a6dc5a")], rough=0.5, grad=0.4, noise=0.15)
    M["confetti_y"] = mat_painted("confetti_y", [(0.3, "#f0b020"), (0.8, "#ffe060")], rough=0.4)
    M["confetti_b"] = M["blue"]
    M["confetti_g"] = M["green"]
    return M


def setup_scene():
    global SC, CAM
    SC = bpy.context.scene
    for o in list(bpy.data.objects):
        bpy.data.objects.remove(o)
    eng = os.environ.get("UIKIT_ENGINE", "CYCLES").upper()
    if eng == "CYCLES":
        SC.render.engine = "CYCLES"
        SC.cycles.samples = 24
        SC.cycles.use_denoising = True
        SC.cycles.device = "CPU"
    else:
        SC.render.engine = "BLENDER_EEVEE"
        SC.eevee.taa_render_samples = 48
    SC.render.film_transparent = True
    SC.render.image_settings.file_format = "PNG"
    SC.render.image_settings.color_mode = "RGBA"
    SC.render.resolution_percentage = 100
    SC.view_settings.view_transform = "Standard"
    SC.view_settings.look = "None"
    SC.view_settings.exposure = 0.0
    w = SC.world or bpy.data.worlds.new("World")
    SC.world = w
    w.use_nodes = True
    bg = w.node_tree.nodes.get("Background")
    bg.inputs["Color"].default_value = srgb("#c9d6ea")
    bg.inputs["Strength"].default_value = 0.85

    cd = bpy.data.cameras.new("cam")
    cd.type = "ORTHO"
    CAM = bpy.data.objects.new("cam", cd)
    link(CAM)
    SC.camera = CAM
    CAM.location = (0, 0, 20)
    cd.clip_end = 100

    ld = bpy.data.lights.new("sun", "SUN")
    ld.energy = 3.2
    ld.angle = math.radians(6)
    sun = bpy.data.objects.new("sun", ld)
    link(sun)
    dirv = Vector((0.55, -0.75, -1.0)).normalized()   # light travels from top-left to bottom-right
    sun.rotation_euler = dirv.to_track_quat("-Z", "Y").to_euler()
    ld2 = bpy.data.lights.new("rim", "SUN")
    ld2.energy = 0.6
    ld2.angle = math.radians(20)
    rim = bpy.data.objects.new("rim", ld2)
    link(rim)
    rim.rotation_euler = Vector((-0.6, 0.6, -1.0)).normalized().to_track_quat("-Z", "Y").to_euler()


def clear_elements():
    for o in list(bpy.data.objects):
        if o.name not in ("cam", "sun", "rim"):
            bpy.data.objects.remove(o)
    for coll in (bpy.data.meshes, bpy.data.curves):
        for d in list(coll):
            if d.users == 0:
                coll.remove(d)
    CAM.location = (0, 0, 20)
    CAM.rotation_euler = (0, 0, 0)


def add_outline(ob, px):
    """Inverted-hull ink line: a copy of the mesh pushed out along vertex normals,
    faces reversed, shaded with an emission material whose front faces are transparent."""
    if px <= 0:
        return None
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    bm.normal_update()
    t = px / PPU
    for v in bm.verts:
        v.co += v.normal * t
    bmesh.ops.reverse_faces(bm, faces=bm.faces)
    me = bpy.data.meshes.new(ob.name + "_ink")
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.material_index = 0
    me.materials.append(MATS["outline"])
    hull = bpy.data.objects.new(ob.name + "_ink", me)
    link(hull)
    hull.parent = ob
    # camera-only: otherwise the hull shadows the object it wraps
    for attr in ("visible_shadow", "visible_diffuse", "visible_glossy", "visible_transmission",
                 "visible_volume_scatter"):
        setattr(hull, attr, False)
    return hull


def slab(name, loops, mat, depth=20, bevel=6, z=0.0, outline=OUTLINE_PX, bevel_res=4):
    """Extrude one or more closed loops (outer + holes, px) into a bevelled slab.

    Returns the mesh object; its top surface sits at z + depth/2 + bevel (px).
    """
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "2D"
    cu.fill_mode = "BOTH"
    cu.extrude = max(depth / 2.0, 0.01) / PPU
    cu.bevel_depth = bevel / PPU
    cu.bevel_resolution = bevel_res
    for loop in loops:
        sp = cu.splines.new("POLY")
        sp.points.add(len(loop) - 1)
        for p, (x, y) in zip(sp.points, loop):
            p.co = (x / PPU, y / PPU, 0.0, 1.0)
        sp.use_cyclic_u = True
        sp.use_smooth = True
    tmp = bpy.data.objects.new(name + "_c", cu)
    link(tmp)
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(tmp.evaluated_get(dg))
    bpy.data.objects.remove(tmp)
    bpy.data.curves.remove(cu)
    bm = bmesh.new()
    bm.from_mesh(me)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    for f in bm.faces:
        f.smooth = abs(f.normal.z) < 0.999
    bm.to_mesh(me)
    bm.free()
    me.materials.clear()
    me.materials.append(mat)
    ob = bpy.data.objects.new(name, me)
    link(ob)
    ob.location.z = z / PPU
    add_outline(ob, outline)
    return ob


def ring(name, outer, hole, mat, **kw):
    return slab(name, [outer, hole], mat, **kw)


def dome(name, r, x, y, mat, z, outline=2.0):
    """A small domed bolt / nail head."""
    return slab(name, [circle(max(r - 4, 1), 24, x, y)], mat, depth=2, bevel=4, z=z, outline=outline, bevel_res=5)


def gem_mesh(name, outline_pts, table_pts, h, mat, z=0.0, outline=ICON_OUTLINE_PX):
    bm = bmesh.new()
    ov = [bm.verts.new((x / PPU, y / PPU, 0)) for x, y in outline_pts]
    tv = [bm.verts.new((x / PPU, y / PPU, h / PPU)) for x, y in table_pts]
    n = len(ov)
    assert len(tv) == n
    for i in range(n):
        j = (i + 1) % n
        bm.faces.new((ov[i], ov[j], tv[j], tv[i]))
    bm.faces.new(tv)
    bm.faces.new(list(reversed(ov)))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    me.materials.append(mat)
    ob = bpy.data.objects.new(name, me)
    link(ob)
    ob.location.z = z / PPU
    add_outline(ob, outline)
    return ob


def rope(name, pts3, r, mat, outline=2.0):
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = r / PPU
    cu.bevel_resolution = 3
    sp = cu.splines.new("POLY")
    sp.points.add(len(pts3) - 1)
    for p, (x, y, z) in zip(sp.points, pts3):
        p.co = (x / PPU, y / PPU, z / PPU, 1)
    sp.use_smooth = True
    cu.materials.append(mat)
    ob = bpy.data.objects.new(name, cu)
    link(ob)
    return ob


def hide(o):
    o.hide_render = True
    for c in o.children:
        c.hide_render = True


def render(name, W, H):
    SC.render.resolution_x = W
    SC.render.resolution_y = H
    CAM.data.ortho_scale = max(W, H) / PPU * PAD
    SC.render.filepath = os.path.join(OUT, name + ".png")
    bpy.ops.render.render(write_still=True)
    print("rendered", name, W, H)


# ---------------------------------------------------------------- elements

def el_panel(kind):
    M = MATS
    W = 512
    ring("frame", rrect(492, 492, 70), rrect(388, 388, 40), M["wood_dark"], depth=24, bevel=10, z=20)
    inner = M["wood"] if kind == "wood" else M["parchment"]
    slab("inner", [rrect(420, 420, 44)], inner, depth=10, bevel=6, z=0, outline=0)
    if kind == "wood":
        # painted plank seams (thin dark grooves) for a carpentered look
        for x in (-96, 0, 96):
            slab(f"seam{x}", [rrect(5, 380, 2, 2, x, 0)], M["wood_base"], depth=1, bevel=1.5, z=11, outline=0)
    for sx in (-1, 1):
        for sy in (-1, 1):
            dome(f"nail{sx}{sy}", 13, sx * 220, sy * 220, M["brass"], z=44)
    render(f"panel_{kind}", W, W)


def el_plaque():
    M = MATS
    slab("back", [rrect(500, 244, 46)], M["wood_dark"], depth=20, bevel=10, z=0)
    for i, y in enumerate((50, -48)):
        slab(f"plank{i}", [rrect(448, 92, 26, cy=y)], M["wood_plank"], depth=14, bevel=9, z=24, outline=2.5)
    for sx in (-1, 1):
        for sy in (-1, 1):
            dome(f"bolt{sx}{sy}", 14, sx * 206, sy * 50, M["brass"], z=50)
    vine(-228, 92, 1, 30)
    vine(232, -96, -1, 200)
    daisy(-186, 104, 60)
    render("plaque_wood", 512, 256)


def leaf(name, x, y, ang, size, z):
    pts = []
    for i in range(24):
        t = i / 24 * 2 * math.pi
        x_ = size * math.cos(t)
        pts.append((x_, size * 0.46 * math.copysign(1.0, math.sin(t)) * (1 - (x_ / size) ** 2) * (1 - 0.25 * x_ / size)))
    pts = offset_pts(rot_pts(pts, ang), x, y)
    slab(name, [pts], MATS["leaf"], depth=4, bevel=3, z=z, outline=2)
    vein = offset_pts(rot_pts(rrect(size * 1.3, 2.5, 1.2), ang), x, y)
    slab(name + "_v", [vein], MATS["green_dark"], depth=1, bevel=0.8, z=z + 8, outline=0)


def vine(x, y, s, ang):
    """Little curling vine with three leaves, like the logo sign's corners."""
    pts = [(x + s * 14 * math.cos(t * 4) * (1 - t * 0.6) + s * t * 30, y + 14 * math.sin(t * 4) * (1 - t * 0.6) - t * 10, 60)
           for t in [i / 30 for i in range(31)]]
    rope(f"vine{x}", pts, 2.2, MATS["green_dark"], outline=0)
    for k, (dx, dy, a) in enumerate([(4, 10, ang), (22 * s, -6, ang + 70), (-14 * s, -14, ang - 60)]):
        leaf(f"leaf{x}_{k}", x + dx, y + dy, a, 17 - k * 2, 58)


def daisy(x, y, z):
    for k in range(8):
        a = k * 45
        pet = offset_pts(rot_pts([(6 + 9 * math.cos(t / 12 * 2 * math.pi), 4.2 * math.sin(t / 12 * 2 * math.pi)) for t in range(12)], a), x, y)
        slab(f"pet{x}{k}", [pet], MATS["white"], depth=2, bevel=1.5, z=z, outline=1.2)
    slab(f"dc{x}", [circle(5.5, 20, x, y)], MATS["confetti_y"], depth=3, bevel=2.5, z=z + 6, outline=1.2)


def el_ribbon(color):
    M = MATS
    main = M["red"] if color == "red" else M["ribbon_gold"]
    dark = M["red_dark"] if color == "red" else M["ribbon_gold_dark"]
    for s in (-1, 1):
        tail = [(s * 150, 26), (s * 252, 26), (s * 214, -14), (s * 252, -56), (s * 150, -56)]
        if s > 0:
            tail = list(reversed(tail))
        slab(f"tail{s}", [round_poly(tail, 5)], main, depth=10, bevel=5, z=0)
        fold = [(s * 198, -32), (s * 160, -32), (s * 160, -56)]
        if s < 0:
            fold = list(reversed(fold))
        slab(f"fold{s}", [round_poly(fold, 3)], dark, depth=6, bevel=3, z=14, outline=2)
    slab("band", [rrect(404, 100, 14, cy=10)], main, depth=12, bevel=8, z=24)
    for y in (48, -28):
        slab(f"trim{y}", [rrect(392, 6, 3, cy=y)], dark, depth=2, bevel=2, z=46, outline=0)
    render(f"ribbon_{color}", 512, 160)


def el_btn_square(pressed=False):
    M = MATS
    lift = 2 if pressed else 10
    slab("base", [rrect(176, 172, 42, cy=-8)], M["wood_base"], depth=20, bevel=8, z=0)
    oy = -6 if pressed else 2
    slab("body", [rrect(176, 168, 42, cy=oy + 2)], M["wood"], depth=16, bevel=10, z=lift + 10)
    slab("face", [rrect(132, 124, 28, cy=oy + 4)], M["cream"], depth=10, bevel=8, z=lift + 26, outline=2.5)
    render("btn_wood_square_pressed" if pressed else "btn_wood_square", 192, 192)


def el_pill(name, body, rim, base):
    M = MATS
    slab("base", [rrect(372, 124, 62, cy=-10)], base, depth=20, bevel=8, z=0)
    ring("rim", rrect(372, 122, 61, cy=0), rrect(330, 82, 41, cy=2), rim, depth=18, bevel=8, z=14)
    slab("body", [rrect(344, 96, 48, cy=2)], body, depth=14, bevel=10, z=8, outline=0)
    slab("gloss", [rrect(290, 22, 11, cy=26)], M["gloss"], depth=1, bevel=2, z=40, outline=0)
    render(name, 384, 144)


def el_slot():
    M = MATS
    ring("frame", rrect(180, 180, 40), rrect(124, 124, 18), M["wood"], depth=20, bevel=9, z=16)
    slab("inner", [rrect(140, 140, 24)], M["slot"], depth=6, bevel=4, z=0, outline=0)
    render("slot_next_block", 192, 192)


def el_card():
    M = MATS
    holes = [rrect(236, 86, 18, cx=-58, cy=0), rrect(88, 88, 16, cx=128, cy=0)]
    holes = [offset_pts(h, 0, 0) for h in holes]
    slab("frame", [rrect(376, 120, 32)] + holes, M["wood"], depth=18, bevel=8, z=16)
    slab("name", [rrect(252, 100, 22, cx=-58)], M["parchment"], depth=6, bevel=4, z=0, outline=0)
    slab("portrait", [rrect(104, 104, 20, cx=128)], M["sky"], depth=6, bevel=4, z=0, outline=0)
    render("card_player", 384, 128)


def el_timer():
    M = MATS
    slab("gear", [gear_pts(14, 124, 104), circle(80, 64)], M["brass"], depth=18, bevel=6, z=0)
    ring("ring", circle(100, 64), circle(78, 64), M["wood_dark"], depth=18, bevel=8, z=20)
    slab("face", [circle(86, 64)], M["cream"], depth=6, bevel=4, z=4, outline=0)
    for i in range(14):
        a = 2 * math.pi * (i + 0.25) / 14
    for k in range(4):
        a = math.pi / 4 + k * math.pi / 2
        dome(f"rivet{k}", 8, 89 * math.cos(a), 89 * math.sin(a), M["brass"], z=44, outline=1.5)
    render("timer_gear", 256, 256)


def el_meter():
    M = MATS
    top, cy = 178, -138
    frame = ring("frame", thermo_loop(30, top, cy, 44), thermo_loop(15, top - 13, cy, 29), M["wood_dark"],
                 depth=18, bevel=8, z=20)
    for i in range(6):
        y = 120 - i * 40
        slab(f"tick{i}", [rrect(10, 5, 2, cx=33, cy=y)], M["brass"], depth=2, bevel=2, z=46, outline=1.2)
    back = slab("back", [thermo_loop(20, top - 8, cy, 33)], M["trough"], depth=4, bevel=2, z=-6, outline=0)
    glass = slab("glass", [thermo_loop(19, top - 9, cy, 32)], M["glass"], depth=6, bevel=6, z=10, outline=0)
    hl = slab("hl", [rrect(5, 230, 2.5, cx=-8, cy=30)], M["gloss"], depth=1, bevel=1, z=30, outline=0)
    hl2 = slab("hl2", [circle(7, 20, -12, cy + 12)], M["gloss"], depth=1, bevel=1, z=30, outline=0)
    # render the tube without the dark back so the tube works as an "over" texture
    hide(back)
    render("meter_tube", 96, 384)
    for o in (frame, glass, hl, hl2):
        hide(o)
    for o in bpy.data.objects:
        if o.name.startswith("tick"):
            hide(o)
    slab("mask", [thermo_loop(16, top - 12, cy, 30)], M["mask"], depth=2, bevel=0.5, z=0, outline=0)
    render("meter_fill_mask", 96, 384)


def el_bar():
    M = MATS
    frame = ring("frame", rrect(380, 60, 30), rrect(348, 46, 23), M["wood"], depth=16, bevel=5, z=16)
    trough = slab("trough", [rrect(352, 40, 20)], M["trough"], depth=4, bevel=3, z=0, outline=0)
    render("bar_frame", 384, 64)
    hide(frame)
    hide(trough)
    slab("fill", [rrect(346, 38, 19)], M["fill_white"], depth=6, bevel=5, z=4, outline=0)
    slab("gloss", [rrect(320, 7, 3.5, cy=7)], M["gloss"], depth=1, bevel=1, z=20, outline=0)
    render("bar_fill", 384, 64)


def el_counter():
    M = MATS
    ring("frame", rrect(244, 70, 35, cx=-4), rrect(206, 40, 20, cx=-8), M["wood_dark"], depth=16, bevel=7, z=16)
    slab("trough", [rrect(216, 50, 25, cx=-8)], M["trough"], depth=4, bevel=3, z=0, outline=0)
    slab("plus_base", [circle(30, 48, 96, -3)], M["green_dark"], depth=12, bevel=6, z=26)
    slab("plus_btn", [circle(27, 48, 96, 2)], M["green"], depth=10, bevel=7, z=38)
    slab("plus_h", [rrect(30, 9, 4.5, cx=96, cy=2)], M["white"], depth=4, bevel=3, z=56, outline=1.5)
    slab("plus_v", [rrect(9, 30, 4.5, cx=96, cy=2)], M["white"], depth=4, bevel=3, z=56, outline=1.5)
    render("counter_pill", 256, 80)


def el_bunting():
    M = MATS
    cols = [M["red"], M["ribbon_gold"], M["blue"], M["green"], M["purple_light"]]

    def ry(x):
        return 46 - 22 * (1 - (x / 256.0) ** 2)

    pts = [(x, ry(x), 40) for x in range(-262, 263, 8)]
    rope("rope", pts, 3.2, M["wood_dark"])
    n = 7
    for i in range(n):
        x = -256 + (i + 0.5) * 512 / n
        slope = math.degrees(math.atan2(ry(x + 1) - ry(x - 1), 2))
        tri = [(-30, 0), (30, 0), (0, -74)]
        tri = round_poly(tri, 5)
        tri = rot_pts(tri, slope)
        tri = offset_pts(tri, x, ry(x) + 2)
        slab(f"flag{i}", [tri], cols[i % len(cols)], depth=6, bevel=4, z=10, outline=2.5)
    render("bunting", 512, 128)


# ---------------------------------------------------------------- icons

def icon_cog():
    slab("cog", [gear_pts(8, 54, 40, tooth=0.5, taper=0.7, fillet=4), circle(16, 40)], MATS["glyph"],
         depth=14, bevel=7, z=0, outline=ICON_OUTLINE_PX)


def icon_pause():
    for x in (-20, 20):
        slab(f"bar{x}", [rrect(28, 84, 10, cx=x)], MATS["glyph"], depth=14, bevel=7, z=0, outline=ICON_OUTLINE_PX)


def icon_play():
    slab("tri", [round_poly([(-34, -48), (50, 0), (-34, 48)], 10)], MATS["glyph"], depth=14, bevel=7,
         z=0, outline=ICON_OUTLINE_PX)


def icon_back():
    arrow = [(-52, 0), (-4, 46), (-4, 18), (50, 18), (50, -18), (-4, -18), (-4, -46)]
    slab("arrow", [round_poly(arrow, 6)], MATS["glyph"], depth=14, bevel=7, z=0, outline=ICON_OUTLINE_PX)


def icon_home():
    house = [(-56, 4), (0, 54), (56, 4), (40, 4), (40, -50), (-40, -50), (-40, 4)]
    slab("house", [round_poly(house, 6)], MATS["glyph"], depth=14, bevel=6, z=0, outline=ICON_OUTLINE_PX)
    slab("door", [rrect(24, 36, 10, cy=-24)], MATS["cream"], depth=4, bevel=3, z=18, outline=1.5)
    slab("chim", [rrect(14, 24, 3, cx=28, cy=40)], MATS["glyph"], depth=10, bevel=4, z=-4, outline=ICON_OUTLINE_PX)


def icon_star():
    slab("star", [round_poly(star_pts(60, 28), 6)], MATS["gold"], depth=14, bevel=8, z=0, outline=ICON_OUTLINE_PX)
    slab("star_in", [round_poly(star_pts(36, 17), 4)], MATS["gold_light"], depth=4, bevel=4, z=18, outline=0)


def icon_coin():
    slab("coin", [circle(56, 64)], MATS["gold"], depth=14, bevel=8, z=0, outline=ICON_OUTLINE_PX)
    ring("rim", circle(46, 64), circle(39, 64), MATS["gold_light"], depth=4, bevel=3, z=20, outline=0)
    slab("emb", [round_poly(star_pts(28, 13), 3)], MATS["gold_light"], depth=4, bevel=4, z=20, outline=1.2)


def icon_gem():
    outline = [(-50, 22), (-26, 46), (26, 46), (50, 22), (0, -52)]
    table = [(-26, 20), (-12, 32), (12, 32), (26, 20), (0, -14)]
    g = gem_mesh("gem", outline, table, 30, MATS["purple"])
    for p in g.data.polygons:
        p.use_smooth = False
    slab("spark", [round_poly(star_pts(10, 3, 4, 0), 1)], MATS["mask"], depth=1, bevel=1, z=40, outline=0)
    bpy.data.objects["spark"].location.x = -18 / PPU
    bpy.data.objects["spark"].location.y = 30 / PPU


def icon_trophy():
    cup = [(-38, 50), (38, 50), (36, 22), (24, 2), (8, -10), (8, -26), (26, -36), (26, -52),
           (-26, -52), (-26, -36), (-8, -26), (-8, -10), (-24, 2), (-36, 22)]
    for s in (-1, 1):
        ring(f"handle{s}", circle(19, 40, s * 38, 26), circle(10, 40, s * 38, 26), MATS["gold"],
             depth=8, bevel=5, z=-6, outline=ICON_OUTLINE_PX)
    slab("cup", [round_poly(cup, 5)], MATS["gold"], depth=14, bevel=7, z=0, outline=ICON_OUTLINE_PX)
    slab("lip", [rrect(80, 10, 5, cy=48)], MATS["gold_light"], depth=4, bevel=3, z=18, outline=1.2)
    slab("tstar", [round_poly(star_pts(15, 7), 2)], MATS["gold_light"], depth=4, bevel=3, z=18, outline=1.2)
    o = bpy.data.objects["tstar"]
    o.location.y = 24 / PPU


def icon_map():
    widths = [(-38, 0.22), (0, -0.22), (38, 0.22)]
    for i, (x, tilt) in enumerate(widths):
        o = slab(f"panel{i}", [rrect(40, 96, 4, cx=0)], MATS["parchment"], depth=4, bevel=3, z=0,
                 outline=ICON_OUTLINE_PX)
        o.location.x = x / PPU
        o.rotation_euler.y = tilt
        o.location.y = (4 if i % 2 else -4) / PPU
    for k, (x, y) in enumerate([(-44, -30), (-32, -14), (-18, -4), (-4, 4), (10, 14)]):
        slab(f"dot{k}", [circle(3.5, 16, x, y)], MATS["red_dark"], depth=2, bevel=1.5, z=14, outline=0)
    for a in (45, -45):
        slab(f"x{a}", [rot_pts(rrect(30, 8, 4), a)], MATS["red"], depth=3, bevel=2.5, z=16, outline=1.2)
        bpy.data.objects[f"x{a}"].location.x = 34 / PPU
        bpy.data.objects[f"x{a}"].location.y = 24 / PPU


def icon_party():
    M = MATS
    hat = round_poly([(-36, -42), (36, -42), (6, 52)], 6)
    slab("hat", [hat], M["purple_light"], depth=12, bevel=6, z=0, outline=ICON_OUTLINE_PX)
    for k, (x, y) in enumerate([(-14, -18), (12, -24), (0, 6), (14, -2), (-4, 26)]):
        slab(f"dot{k}", [circle(5.5, 20, x, y)], M["confetti_y"], depth=2, bevel=2, z=16, outline=0)
    slab("brim", [rrect(84, 14, 7, cy=-44)], M["gold"], depth=8, bevel=5, z=14, outline=ICON_OUTLINE_PX)
    slab("pom", [circle(13, 32, 8, 52)], M["red"], depth=10, bevel=8, z=10, outline=ICON_OUTLINE_PX)
    conf = [(-44, 30, 30, M["blue"]), (40, 34, -25, M["green"]), (44, 4, 60, M["red"]),
            (-50, 0, -40, M["green"]), (-36, 52, 10, M["confetti_y"]), (30, 54, 70, M["blue"])]
    for k, (x, y, a, m) in enumerate(conf):
        slab(f"conf{k}", [offset_pts(rot_pts(rrect(12, 6, 2), a), x, y)], m, depth=3, bevel=2, z=4, outline=1.5)


def icon_shop_procedural():
    M = MATS
    slab("body", [rrect(104, 60, 10, cy=-20)], M["wood"], depth=14, bevel=6, z=0, outline=ICON_OUTLINE_PX)
    slab("lid", [rrect(108, 42, 18, cy=28)], M["wood_dark"], depth=14, bevel=6, z=4, outline=ICON_OUTLINE_PX)
    for x in (-34, 34):
        slab(f"band{x}", [rrect(12, 104, 3, cx=x, cy=0)], M["gold"], depth=3, bevel=2, z=20, outline=1.2)
    slab("lock", [rrect(22, 26, 6, cy=4)], M["gold_light"], depth=4, bevel=3, z=24, outline=1.5)


def icon_shop():
    """Shop icon: BlendKit 'Stylised Treasure Chest' (royalty free) rendered at a 3/4 angle."""
    if not os.path.exists(CHEST_BLEND):
        icon_shop_procedural()
        return False
    with bpy.data.libraries.load(CHEST_BLEND, link=False) as (src, dst):
        dst.objects = [n for n in src.objects]
    objs = []
    for o in dst.objects:
        if o is None:
            continue
        if o.type in ("CAMERA", "LIGHT"):
            bpy.data.objects.remove(o)
            continue
        link(o)
        if o.type == "MESH":
            objs.append(o)
    if not objs:
        icon_shop_procedural()
        return False
    bpy.context.view_layer.update()
    # 3/4 camera
    CAM.rotation_euler = (math.radians(62), 0, math.radians(32))
    pts = [o.matrix_world @ Vector(c) for o in objs for c in o.bound_box]
    ctr = sum(pts, Vector()) / len(pts)
    fwd = CAM.rotation_euler.to_matrix() @ Vector((0, 0, -1))
    CAM.location = ctr - fwd * 50
    bpy.context.view_layer.update()
    inv = CAM.matrix_world.inverted()
    loc = [inv @ p for p in pts]
    xs = [p.x for p in loc]
    ys = [p.y for p in loc]
    span = max(max(xs) - min(xs), max(ys) - min(ys)) * 1.08
    cx = (max(xs) + min(xs)) / 2
    cy = (max(ys) + min(ys)) / 2
    right = CAM.rotation_euler.to_matrix() @ Vector((1, 0, 0))
    up = CAM.rotation_euler.to_matrix() @ Vector((0, 1, 0))
    CAM.location = CAM.location + right * cx + up * cy
    return span


def el_icons(only=None):
    table = {"icon_cog": icon_cog, "icon_pause": icon_pause, "icon_trophy": icon_trophy,
             "icon_play": icon_play, "icon_star": icon_star, "icon_coin": icon_coin,
             "icon_gem": icon_gem, "icon_home": icon_home, "icon_map": icon_map,
             "icon_shop": icon_shop, "icon_party": icon_party, "icon_back": icon_back}
    for name, fn in table.items():
        if only and name not in only:
            continue
        clear_elements()
        res = fn()
        if name == "icon_shop" and res:
            SC.render.resolution_x = SC.render.resolution_y = 128
            CAM.data.ortho_scale = res
            SC.render.filepath = os.path.join(OUT, name + ".png")
            bpy.ops.render.render(write_still=True)
            print("rendered", name)
        else:
            render(name, 128, 128)


ELEMENTS = [
    ("panel_wood", lambda: el_panel("wood")),
    ("panel_parchment", lambda: el_panel("parchment")),
    ("plaque_wood", el_plaque),
    ("ribbon_red", lambda: el_ribbon("red")),
    ("ribbon_gold", lambda: el_ribbon("gold")),
    ("btn_wood_square", lambda: el_btn_square(False)),
    ("btn_wood_square_pressed", lambda: el_btn_square(True)),
    ("btn_green_play", lambda: el_pill("btn_green_play", MATS["green"], MATS["green_dark"], MATS["green_dark"])),
    ("btn_gold_pill", lambda: el_pill("btn_gold_pill", MATS["gold"], MATS["wood_dark"], MATS["wood_base"])),
    ("btn_cream_pill", lambda: el_pill("btn_cream_pill", MATS["cream"], MATS["wood_dark"], MATS["wood_base"])),
    ("slot_next_block", el_slot),
    ("card_player", el_card),
    ("timer_gear", el_timer),
    ("meter_tube", el_meter),
    ("bar_frame", el_bar),
    ("counter_pill", el_counter),
    ("bunting", el_bunting),
]


def write_ninepatch():
    data = {"_doc": "Patch margins in pixels (left, top, right, bottom) for StyleBoxTexture / NinePatchRect. "
                    "Textures are rendered at 2x; set StyleBoxTexture texture_margin_* to these values and "
                    "scale the node by 0.5 (or use content margins) for 1x layouts. meter_fill_mask and bar_fill "
                    "share their frame's canvas and margins: use them as TextureProgressBar texture_progress "
                    "(tint with tint_progress) with meter_tube as texture_over and bar_frame as texture_under.",
            "scale": 2,
            "landscape_hud": "Target 1280x720 landscape. At 1x (texture scale 0.5): score card 192x64, "
                             "Next Block slot 96x96, timer 128x128, square buttons 96x96, pills 192x72, "
                             "meter 48x192, bar 192x32, counter 128x40, icons 64x64; panels stretch to any size "
                             "above their margins (min 84x84 at 1x).",
            "patches": {}}
    for k, (l, t, r, b) in NINEPATCH.items():
        data["patches"][k] = {"file": f"res://assets/art/ui/kit/{k}.png",
                              "left": l, "top": t, "right": r, "bottom": b}
    with open(os.path.join(OUT, "ninepatch.json"), "w") as f:
        json.dump(data, f, indent=2)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    only = None
    for a in argv:
        if a.startswith("only="):
            only = set(a[5:].split(","))
    os.makedirs(OUT, exist_ok=True)
    setup_scene()
    build_materials()
    for name, fn in ELEMENTS:
        if only and name not in only:
            continue
        clear_elements()
        fn()
    el_icons(only)
    write_ninepatch()
    if not only or "sheet" in only:
        subprocess.run(["python3", os.path.abspath(__file__), "--contact-sheet"], check=False)


if __name__ == "__main__":
    main()
