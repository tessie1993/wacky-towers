#!/usr/bin/env python3
"""Generates assets/data/set_pieces.json (level landmarks, 5 per biome) from composed primitives.
Schema: see src/view/wt_set_piece_builder.gd. Run: python3 tools/asset-pipeline/build_set_pieces.py
Piece space: ground y=0, front +z, footprint radius <= 2.2. Colours: "#hex" painted, "!#hex" glow,
"~#hex" lit by time of day, "@" the level accent."""
import json, math, os

PIECES = {}
CUR = None

class Pc:
    def __init__(s, biome, name, title, accent, scale=1.0, islet_r=2.4):
        s.id = f"{biome}_{name}"
        s.rec = {"biome": biome, "title": title, "accent": accent, "scale": scale, "islet_r": islet_r, "groups": {}, "parts": []}
    def _a(s, kind, pos, size, col, rot, g, sc):
        r = lambda v: [round(float(x), 3) for x in v]
        part = [kind, r(pos), r(size), col]
        if rot or g or sc: part.append(r(rot) if rot else [])
        if g or sc: part.append(g or "")
        if sc: part.append(r(sc))
        s.rec["parts"].append(part)
    def box(s, pos, size, col, rot=None, g="", sc=None): s._a("b", pos, size, col, rot, g, sc)
    def cyl(s, pos, rt, rb, h, col, seg=12, rot=None, g=""): s._a("c", pos, [rt, rb, h, seg], col, rot, g, None)
    def sph(s, pos, r, col, g="", rot=None):
        s._a("s", pos, r if isinstance(r, (list, tuple)) else [r, r, r], col, rot, g, None)
    def tor(s, pos, i, o, col, rot=None, g="", sc=None): s._a("t", pos, [i, o], col, rot, g, sc)
    def pri(s, pos, w, h, d, col, rot=None, g=""): s._a("p", pos, [w, h, d], col, rot, g, None)
    def beam(s, p1, p2, t, col, g=""): s._a("m", p1, list(p2) + [t], col, None, g, None)
    def group(s, name, pivot, axis="y", speed=0.3, mode="spin", amp=20, parent="", counter=False):
        s.rec["groups"][name] = {"pivot": [round(x, 3) for x in pivot], "axis": axis, "speed": speed, "mode": mode, "amp": amp, "parent": parent, "counter": counter}

def piece(biome, name, title, accent, scale=1.0, islet_r=2.4):
    def deco(fn):
        p = Pc(biome, name, title, accent, scale, islet_r)
        fn(p)
        PIECES[p.id] = p.rec
        return fn
    return deco

def pol(cx, cy, r, a): return (cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a)))
def arc(p, cx, cy, r, a0, a1, n, thick, depth, cols, z=0.0, glow=None):
    """Boxes along an arc in the XY plane (a in degrees, 0 = +x)."""
    for i in range(n):
        a = a0 + (a1 - a0) * (i + .5) / n
        x, y = pol(cx, cy, r + thick / 2, a)
        ln = math.radians(abs(a1 - a0)) / n * (r + thick) * 1.08
        p.box([x, y, z], [ln, thick, depth], cols[i % len(cols)], rot=[0, 0, a - 90])
def lamps(p, pts, col="~#FFF0A0", r=.07):
    for q in pts: p.sph(q, r, col)
def smoke(p, x, y, z, col="#8B8494", r=.5, n=3):
    for i in range(n): p.sph([x + .2 * i * (-1) ** i, y + i * .85, z], r * (1 + .25 * i), col)
def tuft_ring(p, cols):
    pass

# ============================================================ MEADOW
@piece("meadow", "windmill", "Windmill", "#D9674E")
def _(p):
    p.cyl([0, 1.4, 0], .85, 1.25, 2.8, "#EADFC4", 14); p.cyl([0, .12, 0], 1.3, 1.3, .25, "#B9A98A", 14)
    p.cyl([0, 3.5, 0], 0, 1.15, 1.3, "@", 14); p.cyl([0, 2.85, 0], 1.0, 1.0, .12, "#8B6A4A", 14)
    p.box([0, .45, 1.22], [.55, .9, .1], "#7A4F33"); p.box([0, 1.7, .98], [.3, .3, .08], "~#FFD98A")
    p.box([.6, 1.1, 1.0], [.26, .26, .08], "~#FFD98A")
    c = (0, 2.9, 1.1); p.group("sails", c, "z", .35)
    p.sph(c, .24, "#8B6A4A", "sails")
    for k in range(4):
        a = math.radians(k * 90); d = (-math.sin(a), math.cos(a)); pe = (math.cos(a), math.sin(a))
        p.box([c[0] + d[0] * 1.35, c[1] + d[1] * 1.35, c[2]], [.14, 2.7, .09], "#8B6A4A", [0, 0, k * 90], "sails")
        p.box([c[0] + d[0] * 1.55 + pe[0] * .4, c[1] + d[1] * 1.55 + pe[1] * .4, c[2] + .02], [.7, 1.8, .05], "#F6EBD0", [0, 0, k * 90], "sails")
    for x in (-1.5, 1.6): p.sph([x, .12, 1.2], [.35, .2, .3], "#7BC24E")

@piece("meadow", "castle_gate", "Castle gate", "#6E86E0")
def _(p):
    p.box([0, .9, 0], [3.6, 1.8, .9], "#E4DFF0"); p.box([0, .68, .42], [1.1, 1.35, .25], "#4B3A5E"); p.cyl([0, 1.35, .42], .55, .55, .25, "#4B3A5E", 14, [90, 0, 0])
    for i in range(5): p.box([-.4 + i * .2, .65, .56], [.05, 1.3, .05], "#8D7BA8")
    for sx in (-1.85, 1.85):
        p.cyl([sx, 1.8, 0], .62, .7, 3.6, "#D8D3E8", 14); p.cyl([sx, 4.2, 0], 0, .9, 1.3, "@", 14)
        p.box([sx, 2.6, .64], [.16, .36, .08], "~#FFD98A"); p.cyl([sx, 5.2, 0], .02, .02, .8, "#8B6A4A", 5); p.box([sx + .25, 5.35, 0], [.5, .28, .03], "@")
    for i in range(6): p.box([-1.2 + i * .48, 1.95, 0], [.32, .28, .3], "#CFCADF")
    p.box([0, 1.55, .5], [.8, .5, .05], "@")

@piece("meadow", "barn", "Barn", "#C8503F")
def _(p):
    p.box([0, .85, 0], [3.0, 1.7, 2.1], "#C8503F"); p.pri([0, 2.35, 0], 3.3, 1.3, 2.3, "#7B4B3A")
    p.box([0, .63, 1.07], [1.1, 1.25, .08], "#F4E9DA"); p.box([0, .63, 1.1], [.08, 1.5, .06], "#B03F32", [0, 0, 40]); p.box([0, .63, 1.1], [.08, 1.5, .06], "#B03F32", [0, 0, -40])
    p.box([0, 1.9, 1.07], [.7, .55, .06], "#F4E9DA"); p.cyl([-1.95, 1.65, -.2], .62, .62, 3.3, "#D8D2C0", 14)
    p.sph([-1.95, 3.3, -.2], [.64, .6, .64], "#8E9BB0"); p.cyl([.9, .3, 1.2], .3, .3, .6, "#E3B84F", 10, [0, 0, 90])
    p.beam([0, 3.0, 0], [0, 3.7, 0], .05, "#3A3040"); p.box([.2, 3.7, 0], [.5, .15, .03], "#3A3040")

@piece("meadow", "well", "Wishing well", "#D9674E", 1.45)
def _(p):
    p.cyl([0, .5, 0], .95, 1.05, 1.0, "#B5ADA6", 14); p.cyl([0, 1.02, 0], .88, .88, .05, "#5AA9E6", 14); p.cyl([0, 1.05, 0], 1.0, 1.0, .12, "#9C948D", 14)
    for sx in (-.95, .95): p.box([sx, 1.9, 0], [.16, 1.8, .16], "#8A5A3A")
    p.pri([0, 3.1, 0], 2.5, .9, 1.6, "@"); p.cyl([0, 2.3, 0], .07, .07, 2.0, "#6B4A33", 8, [0, 0, 90])
    p.beam([0, 2.3, 0], [0, 1.6, 0], .03, "#C9B48A"); p.cyl([0, 1.4, 0], .2, .16, .3, "#6B7A8A", 10)
    for x in (-1.5, 1.4, 1.1): p.sph([x, .15, 1.0], [.3, .2, .3], "#FF9EC0")

@piece("meadow", "giant_sunflower", "Giant sunflower", "#FFCF3D")
def _(p):
    p.cyl([0, 2.15, 0], .1, .16, 4.3, "#5FA33C", 8); p.cyl([0, 4.5, .3], .85, .85, .3, "#5A3A28", 16, [90, 0, 0])
    for k in range(16):
        a = k * 22.5; x, y = pol(0, 4.5, 1.25, a)
        p.sph([x, y, .3], [.3, .65, .1], "#FFCF3D" if k % 2 else "#FFB82E", rot=[0, 0, a - 90])
    p.sph([.7, 1.7, 0], [.8, .12, .35], "#5FA33C", rot=[0, 0, 25]); p.sph([-.7, 1.1, 0], [.8, .12, .35], "#4F9A52", rot=[0, 0, -25])
    p.sph([1.5, 5.4, .5], .12, "#FFD84A"); p.sph([-1.7, .15, .8], [.35, .2, .3], "#FF9EC0")

# ============================================================ CANDY
@piece("candy", "gingerbread_house", "Gingerbread house", "#FF5E8E", 1.15)
def _(p):
    p.box([0, .75, 0], [2.8, 1.5, 2.2], "#B87A4A"); p.box([0, .07, 0], [2.9, .14, 2.3], "#FFF6EA"); p.pri([0, 2.2, 0], 3.2, 1.4, 2.5, "#FFF3E6")
    cols = ["#FF5E8E", "#7AD9FF", "#FFD34D", "#8CE08A", "#C69BFF"]; n = 0
    for z in (-.9, 0, .9):
        for t in (.2, .5, .8):
            for sx in (-1, 1): p.sph([sx * 1.6 * (1 - t), 1.5 + t * 1.4, z + 0.0], .14, cols[n % 5]); n += 1
    p.box([0, .5, 1.12], [.7, 1.0, .08], "#6B3F2A")
    for sx in (-.9, .9): p.box([sx, .9, 1.12], [.5, .5, .08], "~#FFD98A"); p.box([sx, .9, 1.17], [.5, .06, .04], "#FFF6EA")
    for i in range(5): p.cyl([1.0, 2.55 + i * .2, -.4], .22, .22, .17, "#F0405A" if i % 2 else "#FFF6F2", 10)
    for sx in (-1.7, 1.7):
        for i in range(4): p.cyl([sx, .2 + i * .32, 1.3], .07, .07, .31, "#F0405A" if i % 2 else "#FFF6F2", 8)
        p.sph([sx, 1.35, 1.3], .1, "#F0405A")
    for x, c in ((-1.5, "#FF5E8E"), (1.6, "#7AD9FF")): p.sph([x, .3, 1.7], .35, c)

@piece("candy", "cake_tower", "Cake tower", "#F0405A")
def _(p):
    p.cyl([0, .07, 0], 2.0, 2.0, .14, "#F4F0F8", 20)
    for y, r, h, c in ((.74, 1.6, 1.2, "#F6A9C4"), (2.0, 1.1, 1.0, "#C9A6F0"), (3.0, .65, .8, "#9FE0D0")):
        p.cyl([0, y, 0], r, r, h, c, 20); p.cyl([0, y + h / 2, 0], r + .05, r + .05, .16, "#FFFFFF", 20)
        for k in range(12):
            a = math.radians(k * 30)
            p.sph([math.cos(a) * (r + .06), y + h / 2 + .06, math.sin(a) * (r + .06)], .11, "#FFFFFF")
            p.sph([math.cos(a + .26) * (r + .03), y + h / 2 - .22, math.sin(a + .26) * (r + .03)], [.09, .2, .09], "#FFFFFF")
    p.sph([0, 3.65, 0], .28, "@")
    for x in (-.35, .35): p.cyl([x, 3.7, 0], .05, .05, .5, "#FFD34D", 6); p.sph([x, 4.05, 0], .08, "!#FFD34D")
    for a in (30, 150, 270): p.sph([math.cos(math.radians(a)) * 1.9, .3, math.sin(math.radians(a)) * 1.9], .24, "#F0405A")

@piece("candy", "lollipop_tree", "Lollipop trees", "#FF5E8E")
def _(p):
    for x, h, r, a, b in ((-1.3, 3.2, .9, "#FF5E8E", "#FFFFFF"), (.1, 4.4, 1.15, "#7AD9FF", "#FFD34D"), (1.4, 2.8, .75, "#8CE08A", "#FFFFFF")):
        p.cyl([x, h / 2, 0], .07, .09, h, "#F4EEE6", 8); y = h + r * .85
        for i, (rr, c) in enumerate(((1, a), (.72, b), (.46, a), (.22, b))): p.cyl([x, y, i * .02], r * rr, r * rr, .26, c, 20, [90, 0, 0])
    for x, z, c in ((-.5, 1.1, "#FF5E8E"), (.6, 1.4, "#FFD34D"), (-1.5, 1.2, "#C69BFF"), (1.7, 1.0, "#7AD9FF")): p.sph([x, .22, z], .26, c)

@piece("candy", "candy_cane_arch", "Candy cane arch", "#F0405A")
def _(p):
    arc(p, 0, .9, 1.7, 0, 180, 16, .42, .42, ["#F0405A", "#FFF6F2"])
    for sx in (-1.91, 1.91):
        for i in range(3): p.box([sx, .15 + i * .3, 0], [.42, .3, .42], "#F0405A" if i % 2 == 0 else "#FFF6F2")
    p.sph([0, 3.1, 0], .32, "!#FFE066")
    for x, z, c in ((-1.6, 1.0, "#7AD9FF"), (1.6, 1.0, "#FFD34D"), (-1.0, 1.4, "#8CE08A"), (1.2, 1.5, "#C69BFF")): p.sph([x, .24, z], .26, c)

@piece("candy", "gumdrop_hill", "Gumdrop hill", "#FF86B3")
def _(p):
    cols = ["#FF86B3", "#7AD9FF", "#FFD34D", "#8CE08A", "#C69BFF", "#FF9B5E"]
    p.sph([0, .5, 0], [1.6, 1.4, 1.5], "#FF86B3")
    for i in range(7):
        a = math.radians(i * 51 + 10); r = 1.5
        p.sph([math.cos(a) * r, .3, math.sin(a) * r], [.7, .7, .7], cols[(i + 1) % 6])
    for i in range(14):
        a = i * 2.4; rr = .2 + (i % 5) * .22
        p.box([math.cos(a) * rr, 1.7 - rr * .35, math.sin(a) * rr], [.22, .06, .06], cols[i % 6], [i * 30, i * 50, 0])
    p.cyl([1.3, 1.3, 1.3], .8, .8, .12, "#FFFFFF", 20, [80, 0, 0]); p.cyl([1.3, 1.3, 1.36], .5, .5, .12, "#F0405A", 20, [80, 0, 0])
    for x, z, h in ((-1.0, -.9, 1.9), (-.4, -1.2, 1.4)): p.cyl([x, 1.6 + h / 2 - .4, z], .02, .25, h, "#FFD1E8", 6)

# ============================================================ ICE
@piece("ice", "igloo", "Igloo", "#FF8A3D")
def _(p):
    p.sph([0, 0, 0], [1.9, 1.55, 1.9], "#F2F8FF")
    for h in (.3, .65, 1.0):
        r = 1.9 * math.sqrt(1 - (h / 1.55) ** 2); p.tor([0, h, 0], r - .02, r + .04, "#BCD6EE")
    p.cyl([0, .55, 1.7], .62, .62, 1.3, "#EAF3FC", 14, [90, 0, 0]); p.cyl([0, .5, 2.33], .46, .46, .06, "#27405E", 14, [90, 0, 0]); p.cyl([0, .5, 2.36], .3, .3, .04, "~#FFC46B", 14, [90, 0, 0])
    for x in (-1.6, 1.8): p.sph([x, .1, 1.2], [.5, .3, .45], "#FFFFFF")
    p.box([1.9, .8, .5], [.07, 1.6, .07], "#6B4A33"); p.box([1.9, 1.5, 1.5], [.07, 1.6, .07], "#6B4A33"); p.box([1.9, 1.5, 1.0], [.06, .06, 1.1], "#6B4A33")
    for z in (.7, 1.0, 1.3): p.sph([1.9, 1.3, z], [.06, .14, .1], "#7FB0E8")

@piece("ice", "frozen_falls", "Frozen falls", "#9FE3FF")
def _(p):
    p.box([0, 2.1, -.4], [3.2, 4.2, 1.6], "#BCD8EE"); p.box([-1.9, 1.3, 0], [1.4, 2.6, 1.4], "#A9C8E2"); p.box([1.9, .9, .1], [1.2, 1.8, 1.2], "#A9C8E2")
    p.sph([0, 4.3, -.4], [1.8, .45, .9], "#FFFFFF"); p.sph([-1.9, 2.7, 0], [.8, .3, .8], "#FFFFFF")
    for i, x in enumerate((-1.0, -.5, 0, .5, 1.0)):
        p.box([x, 2.05 - (i % 2) * .2, .5], [.28, 3.6 - (i % 2) * .4, .22], "#E8FBFF" if i % 2 else "#9FE3FF")
        p.cyl([x, 4.0, .5], .13, 0, .6 + (i % 3) * .2, "#E8FBFF", 6)
    p.cyl([0, .05, 1.1], 1.7, 1.7, .1, "#9FE3FF", 18)
    for x, z in ((-1.2, 1.5), (1.1, 1.7), (.2, 1.9)): p.box([x, .25, z], [.5, .5, .5], "#E8FBFF", [20, 30, 15])

@piece("ice", "snowman", "Snowman", "#E0485E")
def _(p):
    p.sph([0, 1.15, 0], 1.25, "#F8FBFF"); p.sph([0, 2.7, 0], .9, "#F8FBFF"); p.sph([0, 3.9, 0], .65, "#FFFFFF")
    p.cyl([0, 3.9, .85], 0, .12, .55, "#FF8A3D", 8, [90, 0, 0])
    for x in (-.22, .22): p.sph([x, 4.08, .58], .08, "#2D2A3C")
    for i in range(5): a = math.radians(-50 + i * 25); p.sph([math.sin(a) * .3, 3.7 - math.cos(a) * .08, .6], .05, "#2D2A3C")
    for y in (2.9, 2.5, 2.1): p.sph([0, y, .88], .1, "#2D2A3C")
    p.tor([0, 3.25, 0], .5, .95, "@"); p.box([.45, 2.9, .85], [.25, .8, .08], "@", [0, 0, -10])
    p.cyl([0, 4.85, 0], .4, .4, .6, "#2D2A3C", 14); p.cyl([0, 4.56, 0], .62, .62, .08, "#2D2A3C", 14)
    for sx in (-1, 1): p.box([sx * 1.5, 3.0, 0], [1.2, .07, .07], "#6B4A33", [0, 0, sx * -30])

@piece("ice", "crystal_spires", "Crystal spires", "#9ADCFF")
def _(p):
    for x, z, h, r, tx, tz, c in ((0, 0, 4.6, .7, 0, 0, "#9ADCFF"), (-.9, .4, 3.4, .55, 0, 10, "#C0A8FF"), (1.0, .3, 3.0, .5, 0, -12, "#7FB6FF"),
                                   (-.3, -.9, 3.8, .5, -8, 0, "#BDEBFF"), (.6, 1.0, 1.8, .4, 15, -10, "#C0A8FF"), (-1.5, -.2, 1.6, .38, 0, 18, "#9ADCFF"), (1.6, -.7, 2.2, .42, -10, -15, "#BDEBFF")):
        p.cyl([x, h / 2 - .1, z], .1, r, h, c, 6, [tx, 0, tz])
    for x, z in ((-1.2, 1.2), (1.2, 1.3), (0, 1.7)): p.sph([x, .1, z], [.6, .3, .5], "#FFFFFF")

@piece("ice", "ski_lodge", "Ski lodge", "#E0485E")
def _(p):
    p.pri([0, 1.7, 0], 3.4, 3.4, 2.9, "#8A5A3A"); p.pri([0, 1.76, 0], 3.55, 3.5, 2.75, "#F6FAFF")
    p.box([0, .55, 1.47], [.7, 1.1, .08], "#5B3B2A"); p.box([0, 1.9, 1.47], [.6, .6, .08], "~#FFD98A"); p.box([1.0, 3.4, -.5], [.5, 1.0, .5], "#8D8798")
    smoke(p, 1.0, 4.2, -.5, "#FFFFFF", .3, 3)
    for sx in (-2.0, -1.8): p.box([sx, .9, 1.1], [.1, 2.0, .04], "@" if sx < -1.9 else "#6FA8E8", [0, 0, 10])
    lamps(p, [(-1.6 + i * .4, .15 + (i % 2) * .05, 1.5) for i in range(9)], "~#FFE08A", .06)

# ============================================================ UNDERWATER
@piece("underwater", "shipwreck", "Shipwreck", "#E7DCC4")
def _(p):
    p.sph([0, -.05, 0], [2.1, .5, 1.8], "#E6D3A3")
    p.box([0, .95, 0], [3.4, 1.1, 1.5], "#8A5A3A", [0, 0, 14]); p.box([-1.9, 1.1, 0], [1.2, 1.5, 1.4], "#6B4A33", [0, 0, 14])
    for i in range(5): p.box([-1.2 + i * .6, 1.9 + i * .15, .7], [.12, 1.3, .12], "#5B3F2A", [0, 0, 14])
    p.cyl([.2, 2.9, 0], .11, .14, 3.6, "#6B4A33", 8, [0, 0, -22]); p.box([-.5, 3.1, 0], [1.3, 1.5, .05], "#E7DCC4", [0, 0, -22])
    p.sph([.9, 1.3, .78], .16, "~#9FE8FF"); p.sph([.2, 1.2, .78], .16, "~#9FE8FF")
    for x, y, c in ((-1.0, .75, "#FF9B5E"), (.4, 1.0, "#B58CFF"), (1.3, 1.3, "#FF8FAE")): p.sph([x, y, .8], .17, c)
    for x in (-1.9, 1.9): p.sph([x, .8, .6], [.12, .7, .12], "#58D6C9")
    p.tor([1.7, .35, 1.0], .2, .3, "#6F7A86", [90, 0, 0])

@piece("underwater", "coral_arch", "Coral arch", "#FF8FAE")
def _(p):
    p.tor([0, 0, 0], 1.1, 1.9, "#FF8FAE", [90, 0, 0], "", [1, 1, 1.6])
    for x, y, c in ((-1.5, 3.4, "#FF9B5E"), (-.5, 4.5, "#B58CFF"), (.7, 4.6, "#58D6C9"), (1.6, 3.3, "#FF9B5E")):
        p.cyl([x, y, 0], .13, .18, .9, c, 8); p.sph([x, y + .5, 0], .2, c)
    for x, z, c in ((-2.0, 1.0, "#B58CFF"), (1.9, 1.1, "#FF9B5E"), (0, 1.7, "#FF8FAE")): p.sph([x, .4, z], [.6, .5, .6], c)
    p.sph([-1.3, .5, 1.4], [.6, .6, .1], "#58D6C9")
    for x, y in ((-1.0, 1.5), (1.2, 2.4)): p.sph([x, y, 1.0], [.22, .12, .1], "#FF9B5E"); p.pri([x - .25 * (1 if x > 0 else -1), y, 1.0], .2, .2, .04, "#FF9B5E", [0, 0, 90 if x > 0 else -90])

@piece("underwater", "giant_clam", "Giant clam", "#F6F0FF")
def _(p):
    p.sph([0, .45, 0], [1.9, .8, 1.5], "#B48CE8"); p.sph([0, 1.0, 0], [1.55, .35, 1.2], "#FFC1DA")
    p.sph([0, 1.9, -.7], [1.85, .75, 1.45], "#D2A8F5", rot=[-40, 0, 0])
    for k in range(9): a = -1.3 + k * .33; p.sph([math.sin(a) * 1.6, .55, math.cos(a) * 1.25], [.1, .45, .1], "#9A6CD0", rot=[0, math.degrees(a), 90])
    p.sph([0, 1.25, .1], .55, "~#F6F0FF"); p.sph([-1.2, .9, .9], .2, "#FFFFFF")
    for x in (-2.0, 1.9): p.sph([x, .8, 0], [.1, .9, .1], "#58D6C9")

@piece("underwater", "kraken_tentacles", "Kraken tentacles", "#F4C7FF")
def _(p):
    p.sph([0, .9, -1.3], [1.2, 1.0, 1.1], "#7A48C0"); 
    for x in (-.5, .5): p.sph([x, 1.3, -.4], .35, "#FFFFFF"); p.sph([x, 1.28, -.1], .16, "#2D2A3C")
    for x0, z0, H, curl in ((-1.3, .4, 4.2, 1.2), (-.4, 1.2, 3.4, -.9), (.9, .6, 4.8, 1.0), (1.6, -.2, 3.0, -1.1), (0, -.3, 5.2, -.8)):
        for i in range(11):
            t = i / 10; x = x0 + curl * math.sin(t * 3.0) * .6 + curl * t * t * .6; y = H * t + .1; r = .5 * (1 - .8 * t) + .07
            p.sph([x, y, z0], r, "#8F5BD6" if i % 2 == 0 else "#9B6AE2")
            if i % 2 and i < 9: p.sph([x, y, z0 + r * .8], r * .3, "#F4C7FF")

@piece("underwater", "sunken_temple", "Sunken temple", "#7FB89A")
def _(p):
    p.box([0, .12, 0], [4.2, .25, 3.0], "#C9D6D3"); p.box([0, .37, 0], [3.6, .25, 2.6], "#BCCBC8")
    for x, z, h in ((-1.4, -.7, 2.6), (1.4, -.7, 3.4), (-1.4, .8, 1.2), (1.4, .8, 2.2)):
        p.cyl([x, .5 + h / 2, z], .3, .34, h, "#D3DEDB", 10); p.box([x, .5 + h + .1, z], [.8, .2, .8], "#C9D6D3")
    p.box([.9, 4.1, -.7], [3.0, .4, .8], "#C9D6D3", [0, 0, 8]); p.cyl([0, .8, 1.9], .3, .3, 1.8, "#D3DEDB", 10, [0, 0, 90])
    p.sph([0, .75, 0], .3, "~#FFE066")
    for x, z, h in ((-1.8, 1.3, .9), (1.9, 1.4, 1.2), (.4, 1.5, .8)): p.sph([x, h * .5, z], [.1, h, .1], "#58B87A")
    p.sph([-1.0, .5, .9], [.7, .15, .5], "#7FB89A")

# ============================================================ PIRATE
@piece("pirate", "lighthouse", "Lighthouse", "#D9483F", .95)
def _(p):
    p.sph([0, .3, 0], [1.6, .8, 1.4], "#9A8F8A"); p.sph([-1.5, .3, .5], [.6, .5, .5], "#8A7F7A")
    for i in range(5): r = 1.0 - i * .075; p.cyl([0, .8 + i * .8, 0], r - .07, r, .8, "@" if i % 2 else "#F4F0EA", 16)
    p.cyl([0, 4.9, 0], 1.0, 1.0, .18, "#4A4458", 16)
    for k in range(10): a = k * 36 * math.pi / 180; p.box([math.cos(a) * .95, 5.2, math.sin(a) * .95], [.06, .4, .06], "#4A4458")
    p.cyl([0, 5.45, 0], .5, .55, .9, "~#FFE17A", 12); p.cyl([0, 6.2, 0], 0, .7, .8, "@", 14); p.sph([0, 6.65, 0], .1, "#E0B24A")
    p.box([0, .5, .95], [.4, .7, .08], "#5B3B2A"); p.box([0, 2.4, .8], [.2, .3, .06], "~#FFD98A")

@piece("pirate", "galleon", "Galleon", "#D9483F")
def _(p):
    p.cyl([0, .06, 0], 2.3, 2.3, .12, "#4FB6E8", 20); p.tor([0, .1, 0], 2.0, 2.3, "#FFFFFF")
    p.box([0, .8, 0], [3.2, .9, 1.3], "#7A4A2E"); p.pri([2.0, .8, 0], 1.3, .9, 1.3, "#7A4A2E", [0, 0, -90]); p.box([0, .85, 0], [3.25, .1, 1.35], "#E0B24A")
    p.box([-1.4, 1.55, 0], [1.0, 1.0, 1.3], "#6B3F2A"); p.box([-1.4, 2.15, 0], [1.1, .12, 1.4], "#8A5A3A")
    for x, h, w in ((-.9, 3.2, 1.2), (.3, 3.8, 1.5), (1.4, 2.6, 1.0)):
        p.cyl([x, 1.2 + h / 2, 0], .07, .1, h, "#5B3F2A", 8); p.box([x + .05, 1.5 + h * .62, .12], [w, h * .38, .08], "#F5EBD0"); p.box([x + .05, 1.4 + h * .27, .12], [w * 1.2, h * .26, .08], "#F5EBD0")
    p.cyl([.3, 5.0, 0], .3, .25, .3, "#6B4A33", 8); p.box([.7, 5.4, 0], [.7, .4, .04], "#2D2A3C"); p.sph([.7, 5.4, .03], .07, "#FFFFFF")
    for x in (-.8, 0, .8): p.sph([x, .8, .68], .1, "~#FFD98A")

@piece("pirate", "skull_rock", "Skull rock", "#7DFFC0")
def _(p):
    p.sph([0, 2.1, 0], [1.9, 1.6, 1.7], "#E9E4D8"); p.box([0, .85, .2], [1.5, .55, 1.2], "#DCD6C8")
    for k in range(6): p.box([-.62 + k * .25, 1.15, .83], [.2, .3, .1], "#FFFFFF")
    for x in (-.65, .65): p.sph([x, 2.2, 1.35], [.5, .6, .3], "#2B2358"); p.sph([x, 2.15, 1.55], .14, "!#7DFFC0")
    p.sph([.65, 2.25, 1.5], [.62, .66, .15], "#1E1A28"); p.box([0, 3.0, 1.2], [3.0, .08, .08], "#1E1A28", [0, 0, 28])
    p.sph([0, 1.7, 1.6], [.2, .3, .2], "#2B2358")
    for s in (-1, 1): p.cyl([0, .15, 1.6], .12, .12, 2.8, "#F4F0EA", 8, [0, s * 30, 90]); p.sph([s * 1.2, .15, 1.6 - s * .0], .2, "#F4F0EA")

@piece("pirate", "cannon_fort", "Cannon fort", "#2D2A3C")
def _(p):
    p.box([0, .6, 0], [3.6, 1.2, 2.6], "#A9A39C")
    for i in range(8): p.box([-1.5 + i * .43, 1.4, 1.2], [.3, .3, .3], "#9A948D")
    for sx in (-1.6, 1.6): p.cyl([sx, 1.2, -.4], .8, .85, 2.4, "#B9B3AC", 12); p.cyl([sx, 2.6, -.4], .95, .8, .3, "#9A948D", 12); p.box([sx, 1.7, .4], [.16, .4, .1], "~#FFD98A")
    for x in (-1, 0, 1): p.cyl([x, 1.15, 1.5], .2, .25, 1.3, "#3A3744", 10, [90, 0, 0]); p.cyl([x, .7, 1.2], .25, .25, .12, "#6B4A33", 10, [0, 0, 90])
    for x, z, y in ((1.6, 1.8, .16), (1.95, 1.8, .16), (1.78, 1.8, .45), (1.45, 1.8, .45)): p.sph([x, y, z], .16, "#3A3744")
    p.cyl([-1.6, 3.5, -.4], .03, .03, 1.2, "#6B4A33", 5); p.box([-1.3, 3.8, -.4], [.6, .4, .04], "#2D2A3C"); p.box([0, .5, 1.32], [.8, 1.0, .1], "#5B3B2A")

@piece("pirate", "treasure_cove", "Treasure cove", "#FFCF40")
def _(p):
    p.box([0, .55, 0], [2.3, 1.1, 1.5], "#8A5530")
    for x in (-.8, .8): p.box([x, .55, 0], [.15, 1.1, 1.55], "#E0B24A")
    p.box([0, 2.0, -1.6], [2.3, .25, 1.5], "#8A5530", [-110, 0, 0]); p.box([0, 1.9, -1.45], [2.1, .06, 1.3], "#E0B24A", [-110, 0, 0])
    for i in range(14):
        a = i * 2.1; p.sph([math.cos(a) * .7, 1.2 + (i % 3) * .1, math.sin(a) * .4], [.28, .2, .28], "#FFCF40")
    for i in range(6): p.cyl([-.8 + i * .35, .05, 1.3 + (i % 2) * .3], .22, .22, .05, "#FFCF40", 10, [10 * i, 0, 0])
    for x, z, c in ((.4, .9, "#FF4F7A"), (-.5, 1.0, "#4FD6FF"), (.9, 1.4, "#7BFF8A")): p.sph([x, .2, z], .14, c)
    for x, y in ((-.4, 1.5), (.6, 1.45)): p.sph([x, y, .1], .09, "!#FFF3B0")
    for i in range(5): t = i / 4; p.cyl([-1.7 + t * .5, .5 + t * 2.4, -.3], .15 - t * .04, .18 - t * .04, .7, "#8A6240", 8, [0, 0, -12])
    for k in range(6): a = k * 60; p.sph([-1.2 + math.cos(math.radians(a)) * .9, 3.0 - .1 * (k % 2), -.3 + math.sin(math.radians(a)) * .9], [.9, .1, .26], "#4FA43A", rot=[0, -a, -12])

# ============================================================ LAVA
@piece("lava", "vent", "Lava vent", "#FF7A1A")
def _(p):
    p.cyl([0, .5, 0], .9, 1.5, 1.0, "#3B3340", 12); p.cyl([0, 1.3, 0], .6, .95, .8, "#2E2833", 12)
    p.cyl([0, 1.72, 0], .62, .62, .1, "!#FF7A1A", 12); p.cyl([0, 1.78, 0], .38, .38, .1, "!#FFC93D", 12)
    for a in (20, 150, 260): 
        r = math.radians(a); p.box([math.cos(r) * .95, 1.0, math.sin(r) * .95], [.2, .9, .12], "!#FF8A2A", [0, -a, -12])
    smoke(p, 0, 2.7, 0, "#6B6370", .55, 4)
    for x, z in ((1.5, 1.0), (-1.6, .8), (1.0, -1.4)): p.sph([x, .3, z], [.5, .4, .5], "#2E2833")
    for x, y in ((.6, 3.6), (-.5, 4.2)): p.sph([x, y, .4], .07, "!#FFC93D")

@piece("lava", "forge", "Forge", "#FF8A2A")
def _(p):
    p.box([0, .9, 0], [3.0, 1.8, 2.2], "#6C6270"); p.pri([0, 2.35, 0], 3.4, 1.1, 2.5, "#6B3A3A")
    p.box([0, .65, 1.12], [1.0, 1.0, .1], "!#FF8A2A"); p.box([0, 1.25, 1.12], [1.2, .2, .12], "#51495A")
    p.cyl([1.0, 3.2, -.5], .35, .42, 2.4, "#51495A", 10); smoke(p, 1.0, 4.6, -.5, "#7A7280", .35, 3)
    p.box([-1.3, .2, 1.7], [.6, .4, .5], "#2F2C38"); p.box([-1.3, .5, 1.7], [1.0, .25, .45], "#2F2C38"); p.box([-1.3, .66, 1.7], [.5, .1, .2], "!#FFB347")
    p.box([-.6, 1.0, 1.9], [.08, .9, .08], "#6B4A33", [0, 0, 55]); p.box([-.3, 1.4, 1.9], [.35, .2, .2], "#2F2C38")
    p.cyl([1.7, .4, 1.5], .35, .35, .8, "#6B4A33", 10); p.sph([1.0, .15, 1.6], [.5, .3, .4], "#2E2833")
    for x, y in ((-1.0, 1.1), (-1.6, 1.4)): p.sph([x, y, 1.9], .05, "!#FFC93D")

@piece("lava", "volcano", "Volcano", "#FF7A1A", .85)
def _(p):
    p.cyl([0, 2.3, 0], .7, 2.5, 4.6, "#4A3A45", 14); p.tor([0, 4.55, 0], .6, .95, "#3B2F3A"); p.cyl([0, 4.6, 0], .75, .75, .12, "!#FF7A1A", 14)
    tilt = -math.degrees(math.atan((2.5 - .7) / 4.6))
    for a in (30, 150, 270):
        p.box([math.cos(math.radians(a)) * 1.6, 2.35, math.sin(math.radians(a)) * 1.6], [.3, 4.3, .08], "!#FF8A2A", [0, -a, tilt])
    for x, y, r, c in ((0, 5.7, .8, "#5A5260"), (.5, 6.6, 1.0, "#6A6270"), (-.3, 7.6, .8, "#7A7280")): p.sph([x, y, 0], r, c)
    for x, z in ((1.9, 1.1), (-1.8, 1.0)): p.sph([x, .3, z], [.5, .4, .5], "#3B3340")

@piece("lava", "lavafall", "Lavafall", "#FF8F2E")
def _(p):
    p.box([0, 2, -.5], [3.0, 4.0, 1.4], "#3F3541"); p.box([-1.8, 1.3, .1], [1.6, 2.6, 1.2], "#4A3F4D"); p.box([1.8, .8, .2], [1.2, 1.6, 1.0], "#4A3F4D")
    p.box([0, 4.05, -.4], [2.2, .15, 1.0], "!#FF7A1A"); p.box([-.5, 2.05, .25], [.5, 3.9, .12], "!#FF8F2E"); p.box([.45, 2.05, .28], [.35, 3.9, .12], "!#FFB347")
    p.cyl([0, .06, 1.3], 1.7, 1.7, .12, "!#FF6A1A", 18)
    for x, z in ((-1.3, 1.8), (1.2, 1.9), (0, 2.1)): p.box([x, .25, z], [.5, .4, .5], "#2E2833", [0, 25, 0])
    smoke(p, 0, 4.6, -.4, "#6B6370", .4, 3)

@piece("lava", "dragon_ribs", "Dragon ribs", "#FF6A1A")
def _(p):
    for z in (-1.6, -.8, 0): p.tor([0, 0, z], .9, 1.5, "#EFE6D2", [90, 0, 0], "", [1, 1, 1.5])
    p.cyl([0, 2.15, -.8], .2, .2, 3.6, "#E2D6BC", 8, [90, 0, 0]); p.cyl([0, .08, -.8], 1.4, 1.4, .1, "!#FF7A1A", 16); p.cyl([0, .12, -.8], .8, .8, .08, "!#FFC93D", 16)
    p.sph([0, .9, 1.4], [.9, .7, 1.2], "#EFE6D2")
    for x in (-.5, .5): p.cyl([x, 1.7, 1.2], 0, .18, 1.1, "#E2D6BC", 8, [-35, 0, 0]); p.sph([x * 1.1, 1.05, 2.15], .2, "!#FF6A1A")

# ============================================================ FOREST
@piece("forest", "treehouse", "Treehouse", "#D9674E", .85)
def _(p):
    p.cyl([0, 2.2, 0], .95, 1.3, 4.4, "#8B6240", 12)
    for a in (0, 90, 180, 270): p.sph([math.cos(math.radians(a)) * 1.2, .2, math.sin(math.radians(a)) * 1.2], [.6, .3, .35], "#8B6240", rot=[0, -a, 0])
    for x, y, z, r, c in ((0, 5.0, 0, 1.7, "#5FA85C"), (-1.2, 4.5, .3, 1.2, "#4F9A52"), (1.3, 4.6, -.2, 1.3, "#6DB868"), (0, 5.9, -.2, 1.1, "#78C672")): p.sph([x, y, z], r, c)
    p.box([1.15, 3.1, .8], [1.6, 1.1, 1.4], "#C28A55"); p.pri([1.15, 3.95, .8], 2.0, .8, 1.7, "@"); p.box([1.15, 3.05, 1.52], [.4, .5, .06], "~#FFD98A")
    p.box([1.15, 2.5, .8], [2.0, .14, 1.7], "#6E4B30"); p.beam([.9, 1.0, .8], [1.9, 2.5, .8], .15, "#6E4B30")
    for x in (.35, .65): p.box([x, 1.5, 1.2], [.04, 2.0, .04], "#C9B48A")
    for i in range(5): p.box([.5, .8 + i * .35, 1.2], [.3, .05, .05], "#8A6A44")
    p.sph([1.9, 2.8, 1.5], .08, "~#FFD98A")

@piece("forest", "giant_stump", "Giant stump", "#4F8A52")
def _(p):
    p.cyl([0, .95, 0], 1.75, 1.95, 1.9, "#8B6240", 16); p.cyl([0, 1.92, 0], 1.7, 1.7, .06, "#D9B98A", 16)
    for r, c in ((1.35, "#C7A272"), (.95, "#D9B98A"), (.55, "#C7A272"), (.2, "#B88C5C")): p.cyl([0, 1.95, 0], r, r, .07, c, 16)
    for k in range(12):
        a = math.radians(k * 30); p.box([math.cos(a) * 1.85, .95, math.sin(a) * 1.85], [.18, 1.8, .12], "#6F4B31", [0, -k * 30, 0])
    p.cyl([0, .75, 1.88], .55, .55, .12, "@", 14, [90, 0, 0]); p.sph([-1.1, 1.3, 1.5], .2, "~#FFD98A")
    for x, z, c in ((-.5, .4, "#E0483F"), (.7, -.4, "#FF8FAE")): p.cyl([x, 2.2, z], .09, .12, .5, "#F2E3C9", 8); p.sph([x, 2.5, z], [.38, .2, .38], c)
    for k in range(5): a = math.radians(k * 72 + 20); p.sph([math.cos(a) * 2.0, .15, math.sin(a) * 2.0], [.5, .25, .3], "#7C5638", rot=[0, -k * 72, 0])

@piece("forest", "mushroom_hut", "Mushroom hut", "#E0483F")
def _(p):
    p.cyl([0, .9, 0], .85, 1.0, 1.8, "#F2E3C9", 14); p.sph([0, 2.3, 0], [2.2, 1.1, 2.2], "#E0483F")
    for x, z in ((.0, 0), (1.0, .6), (-1.0, .7), (.6, -1.1), (-.7, -.9), (1.5, -.3)):
        y = 2.3 + 1.1 * math.sqrt(max(0, 1 - (x * x + z * z) / 4.84)); p.sph([x, y - .05, z], [.28, .12, .28], "#FFFFFF")
    p.cyl([0, .55, .98], .35, .35, .1, "#8B5A3A", 12, [90, 0, 0])
    for x in (-.5, .5): p.sph([x, 1.3, .86], .16, "~#FFD98A")
    for x, z, c in ((-1.6, 1.2, "#FF8FAE"), (1.7, 1.0, "#E0483F"), (1.2, 1.7, "#B58CFF")): p.cyl([x, .3, z], .07, .09, .6, "#F2E3C9", 8); p.sph([x, .65, z], [.32, .18, .32], c)

@piece("forest", "log_arch", "Log arch", "#FF9A4A")
def _(p):
    for sx in (-1.7, 1.7): p.cyl([sx, .8, 0], .75, .85, 1.6, "#7C5638", 12); p.cyl([sx, 1.62, 0], .7, .7, .06, "#D9B98A", 12)
    p.cyl([0, 2.15, 0], .55, .55, 4.6, "#8A6240", 14, [0, 0, 90])
    for sx in (-2.32, 2.32): p.cyl([sx, 2.15, 0], .5, .5, .08, "#D9B98A", 14, [0, 0, 90]); p.cyl([sx, 2.15, 0], .25, .25, .1, "#C7A272", 14, [0, 0, 90])
    for x in (-1.0, .2, 1.1): p.sph([x, 2.65, 0], [.6, .15, .4], "#4FA43A")
    for sx in (-2.3, 2.3): p.sph([sx, 1.0, .75], [.5, .15, .35], "#FF9A4A", rot=[0, 0, 0])
    for k in range(8): a = math.radians(k * 45); p.cyl([math.cos(a) * 1.5, .5, 1.0 + math.sin(a) * .6], 0, .15, 1.1, "#4FA43A", 6, [math.sin(a) * 25, 0, -math.cos(a) * 25])
    lamps(p, [(-.8, 1.7, .3), (.4, 1.4, .3), (1.0, 1.9, .3)], "~#FFD98A", .09)

@piece("forest", "watermill", "Watermill", "#8B6240")
def _(p):
    p.box([-.4, .9, 0], [2.2, 1.8, 1.8], "#D9C2A0"); p.pri([-.4, 2.35, 0], 2.6, 1.1, 2.1, "#8B6240")
    for x in (-1.3, .5): p.box([x, .9, .92], [.1, 1.8, .06], "#6E4B30")
    p.box([-.4, 1.0, .92], [.5, .9, .06], "#5B3B2A"); p.box([-1.0, 1.4, .92], [.4, .4, .06], "~#FFD98A")
    c = (1.45, 1.35, 0); p.group("wheel", c, "x", -.5)
    p.tor(c, .95, 1.1, "#8A6240", [0, 0, 90], "wheel")
    for k in range(4): p.box(c, [.1, 2.0, .1], "#6E4B30", [k * 45, 0, 0], "wheel")
    for k in range(12):
        a = math.radians(k * 30); p.box([c[0], c[1] + math.cos(a) * 1.05, c[2] + math.sin(a) * 1.05], [.4, .26, .1], "#A07A50", [math.degrees(a), 0, 0], "wheel")
    p.box([0, .06, 1.7], [4.2, .1, .9], "#5AB4E8"); p.sph([-1.6, .2, 1.5], [.5, .3, .4], "#7BC24E")

# ============================================================ CAVE
@piece("cave", "geode", "Cracked geode", "#B98CFF")
def _(p):
    p.sph([0, 1.8, -.6], [1.9, 1.7, 1.2], "#8A7F86"); p.sph([-1.5, .5, -.3], [.7, .6, .6], "#7A6F76"); p.sph([1.5, .6, -.2], [.6, .6, .6], "#7A6F76")
    p.tor([0, 1.8, .45], 1.35, 2.05, "#B9AEB8", [90, 0, 0]); p.tor([0, 1.8, .5], 1.25, 1.4, "#EFE6F2", [90, 0, 0]); p.cyl([0, 1.8, .3], 1.3, 1.3, .1, "#6E4DBA", 16, [90, 0, 0])
    p.cyl([0, 2.4, .8], 0, .32, 1.6, "#D9B8FF", 6, [0, 0, 0]);     for k in range(9):
        a = math.radians(k * 40 + 10); x, y = math.cos(a) * .85, 1.8 + math.sin(a) * .85
        p.cyl([x, y, .75], 0, .26, 1.3 - (k % 3) * .2, ["#B98CFF", "#8E63E8", "#D9B8FF"][k % 3], 6, [math.sin(a) * -40 + 60, 0, math.cos(a) * -40])
    p.sph([0, 1.7, 1.0], .3, "~#E3C8FF")

@piece("cave", "mine_cart", "Mine cart", "#FFC93D")
def _(p):
    for z in (-.55, .55): p.box([0, .15, z], [4.0, .08, .1], "#9A9AA6")
    for i in range(7): p.box([-1.8 + i * .6, .06, 0], [.2, .08, 1.5], "#8A5A3A")
    p.box([0, .85, 0], [1.8, .9, 1.2], "#7A8A99"); p.box([0, 1.35, 0], [1.9, .12, 1.3], "#4A5563")
    for x in (-.55, .55):
        for z in (-.6, .6): p.cyl([x, .4, z], .28, .28, .1, "#2F2C38", 10, [90, 0, 0])
    for i in range(7): a = i * 2.3; p.sph([math.cos(a) * .6, 1.5 + (i % 2) * .1, math.sin(a) * .35], [.3, .25, .3], "#FFC93D")
    for x, z in ((-.3, .1), (.5, -.2)): p.cyl([x, 1.8, z], 0, .2, .6, "#79E0FF", 6)
    p.cyl([1.9, 1.1, .9], .04, .05, 2.2, "#6B4A33", 6); p.sph([1.9, 2.2, .9], .12, "~#FFC46B")
    for z in (-1.0, 1.0): p.box([-1.9, 1.3, z], [.25, 2.6, .25], "#8A5A3A")
    p.box([-1.9, 2.7, 0], [.3, .3, 2.5], "#8A5A3A")

@piece("cave", "stalactite_arch", "Stalactite arch", "#9FE8FF")
def _(p):
    p.sph([0, 3.6, 0], [2.6, .7, 1.2], "#6F6A80")
    for sx in (-1.8, 1.8): p.cyl([sx, 1.7, 0], .6, 1.0, 3.4, "#7D788E", 10)
    for i, x in enumerate((-2.0, -1.4, -.8, -.2, .5, 1.1, 1.8)): p.cyl([x, 3.0 - (i % 3) * .2, (i % 2) * .3 - .15], .2, 0, .7 + (i % 3) * .4, "#8A859A", 7)
    for x, h in ((-.9, .8), (.2, 1.2), (1.0, .7)): p.cyl([x, h / 2, .2], 0, .3, h, "#7D788E", 7)
    for x, z in ((-1.2, 1.0), (1.4, 1.2)): p.sph([x, .15, z], .13, "~#7DFFB5"); p.cyl([x, .1, z], .03, .04, .25, "#CFE8D8", 5)
    p.cyl([0, 2.8, .1], 0, .12, .5, "~#9FE8FF", 5)

@piece("cave", "mine_entrance", "Mine entrance", "#FFC93D")
def _(p):
    p.sph([0, .7, -.5], [2.2, 1.8, 1.8], "#7F7A8C"); p.sph([-1.7, .4, .1], [.9, .8, .9], "#706B7E"); p.sph([1.7, .4, .1], [.9, .7, .9], "#706B7E")
    p.box([0, .85, .8], [1.5, 1.7, .4], "#1E1A28")
    for sx in (-.85, .85): p.box([sx, .95, .95], [.22, 1.9, .22], "#8A5A3A")
    p.box([0, 1.95, .95], [2.1, .25, .25], "#8A5A3A"); p.beam([.85, .3, .95], [.3, 1.9, .95], .1, "#8A5A3A")
    p.box([0, 2.25, .98], [.9, .35, .06], "@"); p.sph([-.5, 1.6, 1.0], .1, "~#FFC46B")
    p.beam([-.9, 1.5, -.9], [-.2, 4.2, -.9], .16, "#6B4A33"); p.beam([.9, 1.5, -.9], [.2, 4.2, -.9], .16, "#6B4A33"); p.tor([0, 4.3, -.9], .25, .4, "#4A5563", [90, 0, 0])
    for x in (-1.2, 1.3): p.sph([x, .25, 1.4], [.35, .3, .35], "~#9FE8FF")
    for z in (.5 + i * .5 for i in range(3)): p.box([0, .04, 1.4 + z - .5], [1.0, .06, .12], "#8A5A3A")

@piece("cave", "drill_rig", "Drill rig", "#FF7A1A")
def _(p):
    for bx, bz in ((-1.1, -1.1), (1.1, -1.1), (-1.1, 1.1), (1.1, 1.1)): p.beam([bx, 0, bz], [0, 5.0, 0], .14, "#8A6A44")
    for y, w in ((1.5, .8), (3.0, .5)):
        for sx, sz, ex, ez in ((-1, -1, 1, -1), (1, -1, 1, 1), (1, 1, -1, 1), (-1, 1, -1, -1)): p.beam([sx * w * 1.0, y, sz * w], [ex * w, y, ez * w], .1, "#8A6A44")
    p.box([0, 5.1, 0], [.7, .3, .7], "#4A5563"); p.cyl([0, 2.4, 0], .1, .1, 5.0, "#9A9AA6", 8)
    c = (0, .3, 0); p.group("bit", c, "y", 4.0); p.cyl([0, .35, 0], .35, 0, .6, "#C9C9D6", 8, [0, 0, 0], "bit")
    p.box([1.8, .5, 1.0], [.9, 1.0, .9], "#4A5563"); p.sph([1.8, 1.3, 1.0], .13, "!#FF7A1A")
    for x, z in ((-1.8, 1.3), (-1.4, 1.7)): p.box([x, .3, z], [.6, .6, .6], "#8A5A3A", [0, 20, 0])
    for x in (-1.6, .6): p.sph([x, .2, -1.8], [.4, .3, .4], "~#79E0FF")

# ============================================================ CLOCKWORK
@piece("clockwork", "clock_tower", "Clock tower", "#5B8F86", .8)
def _(p):
    p.box([0, 1.3, 0], [2.0, 2.6, 2.0], "#C99A5B"); p.box([0, .3, 0], [2.1, .14, 2.1], "#8A5F36"); p.box([0, 2.5, 0], [2.1, .14, 2.1], "#8A5F36")
    p.box([0, 3.9, 0], [2.5, 2.3, 2.5], "#B8864D"); p.cyl([0, 3.9, 1.27], 1.0, 1.0, .12, "#FFF4DC", 20, [90, 0, 0]); p.tor([0, 3.9, 1.27], .95, 1.15, "#E0B24A", [90, 0, 0])
    for k in range(12): x, y = pol(0, 3.9, .8, k * 30); p.box([x, y, 1.34], [.07, .2, .04], "#4A3A2E", [0, 0, k * 30 - 90])
    c = (0, 3.9, 1.38); p.group("minute", c, "z", -.6); p.group("hour", c, "z", -.05)
    p.box([0, 4.3, 1.38], [.08, .85, .05], "#2D2A3C", None, "minute"); p.box([0, 4.16, 1.4], [.12, .55, .05], "#2D2A3C", None, "hour")
    p.sph([0, 3.9, 1.42], .1, "#E0B24A"); p.cyl([0, 6.0, 0], 0, 1.9, 1.6, "#5B8F86", 4, [0, 45, 0]); p.cyl([0, 7.0, 0], .03, .05, .8, "#E0B24A", 6)
    for sx in (-1.27, 1.27): p.box([sx, 3.9, 0], [.06, 1.0, .8], "#2D2A3C")
    p.box([0, .5, 1.02], [.6, .9, .06], "#5B3B2A")

@piece("clockwork", "gear_bridge", "Gear bridge", "#E0B24A")
def _(p):
    for name, cx, cy, R, n, sp, off in (("gA", -1.2, 1.6, 1.4, 14, .28, 0), ("gB", 1.3, 1.45, 1.2, 12, -.28 * 14 / 12, 15)):
        p.group(name, (cx, cy, -.8), "z", sp)
        p.cyl([cx, cy, -.8], R * .9, R * .9, .3, "#C99A5B", 20, [90, 0, 0], name); p.cyl([cx, cy, -.8], .35, .35, .5, "#8A5F36", 12, [90, 0, 0], name)
        p.tor([cx, cy, -.8], R * .5, R * .65, "#8A5F36", [90, 0, 0], name)
        for k in range(3): p.box([cx, cy, -.8], [.14, R * 1.8, .22], "#8A5F36", [0, 0, k * 60], name)
        for k in range(n):
            a = k * 360 / n + off; x, y = pol(cx, cy, R * 1.0, a); p.box([x, y, -.8], [.34, .3, .3], "#B8864D", [0, 0, a - 90], name)
    p.box([0, 1.2, .4], [4.4, .3, 1.3], "#8A5A3A")
    for x in (-1.9, 0, 1.9): p.box([x, .6, .4], [.22, 1.2, .22], "#6B4A33")
    for x in (-2.0, -1.0, 0, 1.0, 2.0): p.box([x, 1.8, 1.0], [.1, .9, .1], "#E0B24A")
    p.box([0, 2.3, 1.0], [4.2, .1, .1], "#E0B24A")

@piece("clockwork", "pendulum", "Pendulum clock", "#E0B24A")
def _(p):
    for sx in (-1.5, 1.5): p.box([sx, 2.6, 0], [.3, 5.2, .3], "#8A5F36")
    p.box([0, 5.35, 0], [3.6, .4, .5], "#6B4A33"); p.box([0, .2, 0], [4.0, .4, 1.4], "#6B4A33")
    p.cyl([0, 4.1, -.3], .95, .95, .1, "#FFF4DC", 20, [90, 0, 0]); p.tor([0, 4.1, -.3], .9, 1.05, "#E0B24A", [90, 0, 0])
    c = (0, 5.1, 0); p.group("pend", c, "z", 1.5, "swing", 22)
    p.box([0, 3.6, 0], [.08, 3.0, .08], "#E0B24A", None, "pend"); p.cyl([0, 2.1, 0], .65, .65, .2, "#E0B24A", 18, [90, 0, 0], "pend"); p.sph([0, 2.1, .12], .22, "@", "pend")
    for sx in (-1.15, 1.15): p.box([sx, 3.0, 0], [.03, 3.0, .03], "#9A9AA6"); p.cyl([sx, 1.4, 0], .22, .22, .5, "#4A4458", 10)
    p.sph([0, 5.7, 0], .2, "#E0B24A")

@piece("clockwork", "boiler", "Brass boiler", "#E0B24A")
def _(p):
    p.cyl([0, 1.4, 0], 1.0, 1.0, 3.0, "#B8794A", 16, [0, 0, 90]); p.sph([-1.5, 1.4, 0], [.4, 1.0, 1.0], "#B8794A"); p.sph([1.5, 1.4, 0], [.4, 1.0, 1.0], "#B8794A")
    for x in (-.9, 0, .9): p.tor([x, 1.4, 0], .94, 1.07, "#E0B24A", [0, 0, 90])
    p.cyl([-.8, 2.9, 0], .28, .34, 1.6, "#4A3A2E", 10); smoke(p, -.8, 3.9, 0, "#D8D4DC", .35, 3)
    p.sph([.5, 2.45, 0], [.5, .4, .5], "#E0B24A"); p.cyl([.4, 1.6, 1.02], .3, .3, .1, "#FFF4DC", 14, [90, 0, 0]); p.tor([.4, 1.6, 1.02], .27, .36, "#E0B24A", [90, 0, 0])
    for sx in (-1.0, 1.0): p.box([sx, .25, 0], [.3, .5, 1.4], "#4A3A2E")
    p.cyl([-1.6, 1.0, 0], .35, .35, .1, "!#FF8A2A", 12, [0, 0, 90])
    c = (1.95, 1.4, 0); p.group("fly", c, "x", -.9)
    p.tor(c, .5, .65, "#4A3A2E", [0, 0, 90], "fly"); 
    for k in range(3): p.box(c, [.1, 1.2, .1], "#4A3A2E", [k * 60, 0, 0], "fly")
    p.box([1.0, .8, .9], [1.4, .1, .1], "#8A5F36", [0, 0, 20])

@piece("clockwork", "music_box", "Music box", "#FFB3D1")
def _(p):
    p.box([0, .7, 0], [3.2, 1.4, 2.2], "#8A4A3A"); p.box([0, .12, 0], [3.3, .14, 2.3], "#E0B24A"); p.box([0, 1.4, 0], [3.3, .1, 2.3], "#E0B24A")
    p.box([0, 2.48, -1.29], [3.2, .18, 2.2], "#8A4A3A", [-100, 0, 0]); p.box([0, 2.45, -1.2], [3.0, .05, 2.0], "#D9C7A8", [-100, 0, 0])
    c = (0, 1.65, -.2); p.group("drum", c, "x", .8); p.cyl(c, .4, .4, 2.6, "#E0B24A", 14, [0, 0, 90], "drum")
    for k in range(10): p.sph([-1.0 + k * .22, 1.65 + .4 * math.cos(k), -.2 + .4 * math.sin(k)], .05, "#4A3A2E", "drum")
    p.box([0, 1.5, .35], [2.6, .05, .3], "#C9C9D6")
    d = (-.9, 1.5, .7); p.group("dancer", d, "y", .9)
    p.cyl([-.9, 1.62, .7], .02, .45, .35, "@", 10, None, "dancer"); p.cyl([-.9, 1.95, .7], .1, .1, .35, "#FFF0E6", 8, None, "dancer"); p.sph([-.9, 2.2, .7], .14, "#FFF0E6", "dancer")
    k = (1.65, .9, 0); p.group("key", k, "x", .4)
    p.cyl([1.8, .9, 0], .06, .06, .5, "#E0B24A", 8, [0, 0, 90], "key"); p.sph([2.1, 1.15, 0], .22, "#E0B24A", "key"); p.sph([2.1, .65, 0], .22, "#E0B24A", "key")

# ============================================================ NEON
@piece("neon", "arcade_tower", "Arcade tower", "#FF4FD8")
def _(p):
    levels = ((.7, 2.4, 1.4, 2.0, "!#3FF2E0"), (2.1, 2.0, 1.4, 1.7, "!#FF4FD8"), (3.5, 1.6, 1.4, 1.4, "!#FFD84A"), (4.8, 1.2, 1.2, 1.1, "!#7B7BFF"))
    for y, w, h, d, sc in levels:
        p.box([0, y, 0], [w, h, d], "#2B2358"); p.box([0, y + .1, d / 2 + .02], [w * .75, h * .6, .06], sc)
        for sx in (-1, 1): p.box([sx * w / 2, y, d / 2], [.08, h, .08], "!#FF4FD8")
        for k in range(4): p.box([-w * .25 + k * w * .17, y + .1 + (k % 2) * .15, d / 2 + .06], [.1, .1, .04], "#1A1440")
    p.sph([-.4, .1, 1.2], .12, "#FF4F4F"); p.sph([.3, .1, 1.2], .08, "#FFD84A"); p.sph([.55, .1, 1.2], .08, "#3FF2E0")
    p.cyl([0, 5.85, 0], .03, .04, 1.0, "#3A3070", 6); p.sph([0, 6.4, 0], .12, "!#FF4FD8")
    p.group("coin", (0, 6.9, 0), "y", 1.5); p.cyl([0, 6.9, 0], .45, .45, .08, "!#FFD84A", 16, [90, 0, 0], "coin")

@piece("neon", "billboard", "Billboard", "#FF4FD8")
def _(p):
    for sx in (-1.5, 1.5): p.box([sx, 1.6, -.2], [.25, 3.2, .25], "#3A3070")
    p.box([0, 4.1, 0], [4.2, 2.4, .3], "#2A2358"); p.box([0, 4.1, .17], [3.9, 2.1, .06], "#1C1640")
    p.cyl([-.9, 4.2, .22], .8, .8, .05, "!#FFD84A", 20, [90, 0, 0])
    for i in range(4): p.box([.9, 3.6 + i * .3, .22], [1.6, .12, .05], "!#FF4FD8")
    p.pri([.5, 3.3, .22], 1.2, .7, .05, "!#3FF2E0")
    for p1, p2 in (((-2.1, 2.9, .2), (2.1, 2.9, .2)), ((-2.1, 5.3, .2), (2.1, 5.3, .2)), ((-2.1, 2.9, .2), (-2.1, 5.3, .2)), ((2.1, 2.9, .2), (2.1, 5.3, .2))): p.beam(p1, p2, .07, "!#3FF2E0")
    for x in (-1.2, 0, 1.2): p.box([x, 5.45, 0], [.3, .2, .3], "#3A3070"); p.sph([x, 5.4, .25], .08, "~#FFF0A0")
    p.box([0, 2.9, -.1], [4.0, .15, .8], "#3A3070")

@piece("neon", "hover_ring", "Hover ring", "#3FF2E0")
def _(p):
    p.cyl([0, .15, 0], 1.3, 1.5, .3, "#2B2358", 16)
    for sx in (-1.5, 1.5): p.box([sx, .8, 0], [.3, 1.6, .3], "#3A3070"); p.sph([sx, 1.7, 0], .15, "!#FF4FD8")
    p.tor([0, 3.0, 0], 1.35, 1.75, "!#3FF2E0", [90, 0, 0]); p.tor([0, 3.0, 0], 1.0, 1.15, "!#FF4FD8", [90, 0, 0]); p.cyl([0, 3.0, 0], .95, .95, .03, "!#4A2FA8", 20, [90, 0, 0])
    c = (0, 3.0, 0); p.group("orbit", c, "z", .8)
    for k in range(6): x, y = pol(0, 3.0, 1.55, k * 60); p.sph([x, y, .1], .13, "!#FFD84A", "orbit")

@piece("neon", "pylon_array", "Pylon array", "#FF4FD8")
def _(p):
    pts = []
    for x, z, h, c in ((-1.8, .3, 2.4, "!#3FF2E0"), (-.9, -.3, 3.6, "!#FF4FD8"), (0, 0, 5.0, "!#3FF2E0"), (.9, -.3, 3.6, "!#FF4FD8"), (1.8, .3, 2.4, "!#3FF2E0")):
        p.box([x, h / 2, z], [.34, h, .34], "#3A3070"); p.box([x, h * .45, z + .18], [.1, h * .8, .04], c)
        p.cyl([x, h + .3, z], 0, .32, .5, c, 4); p.cyl([x, h + .8, z], .32, 0, .5, c, 4); pts.append((x, h + .55, z))
    for a, b in zip(pts, pts[1:]): p.beam(a, b, .05, "!#FFD84A")
    p.box([0, .08, 0], [4.6, .16, 1.6], "#2B2358")

@piece("neon", "torii_gate", "Neon torii", "#FF4FD8")
def _(p):
    for sx in (-1.6, 1.6): p.cyl([sx, 2.1, 0], .3, .36, 4.2, "#2B2358", 10); p.box([sx, 2.0, .36], [.07, 4.0, .07], "!#FF4FD8")
    p.box([0, 4.5, 0], [3.0, .34, .7], "#2B2358"); p.box([-1.9, 4.62, 0], [1.1, .34, .7], "#2B2358", [0, 0, 14]); p.box([1.9, 4.62, 0], [1.1, .34, .7], "#2B2358", [0, 0, -14])
    p.box([0, 4.68, .36], [3.0, .07, .05], "!#FF4FD8"); p.box([0, 3.6, 0], [3.6, .22, .4], "#2B2358"); p.box([0, 3.6, .21], [3.6, .05, .04], "!#3FF2E0")
    p.box([0, 4.05, 0], [.5, .8, .1], "!#3FF2E0")
    for sx in (-.8, .8): p.beam([sx, 3.5, 0], [sx, 3.1, 0], .02, "#9A9AA6"); p.sph([sx, 2.95, 0], .17, "!#FFD84A")
    for i in range(3): p.box([0, .06 + i * .1, 1.2 - i * .3], [2.4 - i * .3, .12, .5], "#3A3070")

# ============================================================ CELESTIAL
@piece("celestial", "observatory", "Observatory", "#E0B24A", .95)
def _(p):
    p.cyl([0, .9, 0], 1.3, 1.5, 1.8, "#F2EEF8", 16); p.cyl([0, 1.85, 0], 1.55, 1.55, .12, "#E0B24A", 16)
    for k in range(6): a = math.radians(k * 60 + 30); p.cyl([math.cos(a) * 1.55, .8, math.sin(a) * 1.55], .12, .14, 1.6, "#EDE6D6", 8)
    c = (0, 1.9, 0); p.group("dome", c, "y", .08)
    p.sph(c, [1.45, 1.45, 1.45], "#E9E3F6", "dome"); p.box([0, 2.6, 1.25], [.55, 1.5, .3], "#2B2358", None, "dome")
    p.tor(c, 1.4, 1.52, "#E0B24A", [90, 0, 0], "dome"); p.tor(c, 1.4, 1.52, "#E0B24A", [90, 90, 0], "dome")
    p.cyl([0, 3.1, 1.6], .14, .24, 1.6, "#C9A24A", 10, [-50, 0, 0], "dome"); p.sph([0, 3.9, .98], .14, "#FFF4C0", "dome")
    for i in range(3): p.box([0, .08 + i * .12, 1.7 + .3 * (2 - i)], [1.4 + i * .1, .12, .6], "#EDE6D6")
    p.sph([-1.8, 2.3, .9], .14, "!#FFE066"); p.sph([1.8, 2.8, .6], .12, "!#FFE066"); p.box([0, .6, 1.52], [.45, .9, .06], "~#FFD98A")

@piece("celestial", "moon_bed", "Moon bed", "#6B4FBF", 1.0, 2.5)
def _(p):
    cy = 2.5
    for i in range(18):
        a = 190 + 160 * (i + .5) / 18; th = .15 + .6 * math.sin(math.pi * (i + .5) / 18); Ri = 1.9
        x, y = pol(0, cy, Ri + th / 2, a); ln = math.radians(160) / 18 * (Ri + th) * 1.1
        p.box([x, y, 0], [ln, th, .8], "#F4ECC8" if i % 2 else "#EBDDA8", rot=[0, 0, a - 90])
    p.box([0, .85, 0], [2.3, .3, 1.2], "#FFFFFF"); p.sph([-.75, 1.15, 0], [.5, .24, .42], "#FFFFFF"); p.box([.35, 1.1, 0], [1.4, .22, 1.25], "@")
    for x, z in ((.0, .6), (.7, -.4), (.4, .5), (-.1, -.5), (.9, .3)): p.sph([x, 1.22, z], .07, "!#FFE066")
    p.sph([-1.7, 3.3, 0], .2, "!#FFE066")
    for x, z in ((-1.7, 1.2), (1.5, 1.4), (-.4, 1.7), (.9, -1.5)): p.sph([x, .18, z], [.6, .3, .5], "#FFFFFF")

@piece("celestial", "star_arch", "Star arch", "#FFE066", .85)
def _(p):
    for sx in (-1.5, 1.5): p.cyl([sx, 1.8, 0], .32, .38, 3.6, "#EDE6D6", 12); p.box([sx, .1, 0], [1.0, .2, 1.0], "#DDD3C4"); p.box([sx, 3.7, 0], [.9, .25, .9], "#DDD3C4")
    arc(p, 0, 3.8, 1.5, 0, 180, 9, .38, .6, ["#EDE6D6", "#DDD3C4"]); p.box([0, 5.95, 0], [.45, .5, .65], "#E0B24A")
    p.sph([0, 3.9, 0], [.12, .95, .12], "!#FFE066"); p.sph([0, 3.9, 0], [.95, .12, .12], "!#FFE066"); p.sph([0, 3.9, 0], .22, "!#FFFFFF")
    p.sph([0, 3.9, 0], [.07, .55, .07], "!#FFE066", rot=[0, 0, 45]); p.sph([0, 3.9, 0], [.07, .55, .07], "!#FFE066", rot=[0, 0, -45])
    for x, y, z in ((-1.9, 4.6, .2), (1.9, 5.0, -.2), (.6, 6.6, 0)): p.box([x, y, z], [.2, .2, .2], "#EDE6D6", [30, 40, 20])

@piece("celestial", "orrery", "Orrery", "#FF8FC8")
def _(p):
    p.cyl([0, .25, 0], 1.1, 1.5, .5, "#6B4FBF", 16); p.cyl([0, 1.1, 0], .14, .2, 1.2, "#E0B24A", 8); p.sph([0, 2.3, 0], .5, "!#FFC93D")
    p.tor([0, 2.3, 0], 1.0, 1.06, "#E0B24A"); p.tor([0, 2.3, 0], 1.55, 1.62, "#E0B24A", [60, 0, 0]); p.tor([0, 2.3, 0], 1.88, 1.94, "#E0B24A", [-30, 20, 0])
    p.group("arms", (0, 2.3, 0), "y", .25)
    for r, c, s, y in ((1.03, "#7EC8FF", .22, 0), (1.58, "#FF8FC8", .3, .7), (1.9, "#B58CFF", .36, -.2)):
        p.beam([0, 2.3, 0], [r, 2.3 + y, 0], .04, "#E0B24A", "arms"); p.sph([r, 2.3 + y, 0], s, c, "arms")
    p.sph([1.5, 2.9, .2], .08, "#FFFFFF", "arms")
    for x, y in ((-1.6, 3.6), (1.3, 4.0)): p.sph([x, y, 0], .12, "!#FFE066")

@piece("celestial", "star_fountain", "Star fountain", "#FFE066")
def _(p):
    p.cyl([0, .3, 0], 1.8, 1.5, .6, "#EDE6D6", 20); p.cyl([0, .62, 0], 1.65, 1.65, .05, "~#9FDCFF", 20); p.cyl([0, 1.1, 0], .25, .35, 1.0, "#DDD3C4", 10)
    p.cyl([0, 1.75, 0], 1.0, .8, .35, "#EDE6D6", 16); p.cyl([0, 1.94, 0], .9, .9, .05, "~#9FDCFF", 16); p.cyl([0, 2.4, 0], .15, .2, .9, "#DDD3C4", 8)
    p.tor([0, .6, 0], 1.6, 1.8, "#E0B24A"); 
    p.sph([0, 3.3, 0], [.12, .8, .12], "!#FFE066"); p.sph([0, 3.3, 0], [.8, .12, .12], "!#FFE066"); p.sph([0, 3.3, 0], .2, "!#FFFFFF")
    for k in range(8):
        a = math.radians(k * 45); 
        for t, r in ((.3, .3), (.6, .6), (.9, .95)): p.sph([math.cos(a) * (.2 + r * 1.0), 2.5 - t * .7 + math.sin(t * 3.14) * .5, math.sin(a) * (.2 + r * 1.0)], .06, "~#CFEFFF")

# ============================================================ CARNIVAL
@piece("carnival", "ferris_wheel", "Ferris wheel", "#E98AA6", .8)
def _(p):
    c = (0, 3.4, 0); p.group("wheel", c, "z", .2)
    for z in (-.3, .3): p.tor([0, 3.4, z], 2.25, 2.4, "#E98AA6", [90, 0, 0], "wheel")
    for k in range(4): p.box([0, 3.4, 0], [.06, 4.6, .06], "#FBF1DE", [0, 0, k * 45], "wheel")
    p.cyl([0, 3.4, 0], .35, .35, .8, "#EDC873", 12, [90, 0, 0], "wheel")
    cols = ["#9CC3DE", "#A9D8C0", "#EDC873"]
    for k in range(8):
        a = k * 45; x, y = pol(0, 3.4, 2.33, a); cn = f"cab{k}"; p.group(cn, (x, y, 0), "z", 0, "spin", 0, "wheel", True)
        p.box([x, y - .15, 0], [.04, .3, .5], "#B9937A", None, cn); p.box([x, y - .5, 0], [.55, .42, .55], cols[k % 3], None, cn); p.box([x, y - .25, 0], [.65, .08, .65], "@", None, cn)
        p.sph([x, y, .35], .06, "~#FFF0A0", "wheel")
    for z in (-.55, .55):
        for sx in (-1.6, 1.6): p.beam([sx, 0, z], [0, 3.4, z], .15, "#B9937A")
    p.box([0, .12, 0], [3.8, .25, 1.8], "#F1E4CF"); p.box([0, 6.0, 0], [.04, .6, .04], "#B9937A"); p.box([.25, 6.1, 0], [.5, .26, .03], "#E98AA6")

@piece("carnival", "big_top", "Big top", "#9CC3DE")
def _(p):
    p.cyl([0, .6, 0], 1.9, 1.9, 1.2, "#FBF1DE", 12)
    for k in range(6): a = math.radians(k * 60 + 15); p.box([math.cos(a) * 1.9, .6, math.sin(a) * 1.9], [.9, 1.2, .08], "#E98AA6", [0, -math.degrees(a) + 90, 0])
    p.cyl([0, 1.25, 0], 2.05, 2.05, .1, "#EDC873", 12)
    for i in range(6): rb = 2.2 * (1 - i / 6); rt = 2.2 * (1 - (i + 1) / 6); p.cyl([0, 1.4 + i * .37, 0], rt, rb, .37, "#E98AA6" if i % 2 == 0 else "#FBF1DE", 12)
    p.cyl([0, 3.9, 0], .02, .02, .8, "#B9937A", 5); p.box([.25, 4.15, 0], [.5, .3, .03], "@")
    p.box([0, .5, 1.88], [.9, 1.0, .1], "#5B3B5E"); p.box([-.55, .5, 1.9], [.3, 1.0, .06], "#E98AA6", [0, 0, 8]); p.box([.55, .5, 1.9], [.3, 1.0, .06], "#E98AA6", [0, 0, -8])
    lamps(p, [(math.cos(math.radians(k * 25.7)) * 2.0, 1.3, math.sin(math.radians(k * 25.7)) * 2.0) for k in range(14)], "~#FFF0A0", .08)
    for x, y, c in ((1.8, 2.4, "#E98AA6"), (2.1, 2.9, "#9CC3DE"), (1.6, 3.0, "#EDC873")): p.sph([x, y, 1.0], [.24, .3, .24], c); p.beam([x, y - .3, 1.0], [1.9, 1.3, 1.0], .01, "#B9937A")

@piece("carnival", "high_striker", "High striker", "#EDC873")
def _(p):
    p.box([0, .15, 0], [1.8, .3, 1.8], "#B9937A"); p.box([0, 2.6, 0], [.5, 4.6, .3], "#FBF1DE"); p.box([0, 2.6, .17], [.14, 4.0, .05], "#5B3B5E")
    for i in range(10): p.box([0, .7 + i * .4, .17], [.5, .06, .06], "#E98AA6")
    p.sph([0, 3.8, .2], .2, "!#FFD84A"); p.sph([0, 5.1, 0], .4, "#EDC873"); p.sph([0, 5.5, 0], .08, "#EDC873")
    lamps(p, [(sx * .27, .7 + i * .38, .0) for i in range(11) for sx in (-1, 1)], "~#FFF0A0", .06)
    p.cyl([1.2, .55, 1.0], .06, .06, 1.5, "#8A5A3A", 6, [0, 0, 60]); p.cyl([.72, .85, 1.0], .3, .3, .7, "#8A5A3A", 10, [0, 0, 90]); p.cyl([0, .35, .8], .5, .5, .1, "@", 14)
    p.sph([0, 6.0, 0], [.1, .6, .1], "!#FFE066"); p.sph([0, 6.0, 0], [.6, .1, .1], "!#FFE066")

@piece("carnival", "carousel", "Carousel", "#E98AA6", .95, 2.5)
def _(p):
    p.cyl([0, .15, 0], 2.0, 2.0, .3, "#EDC873", 20)
    p.group("ride", (0, 0, 0), "y", .4)
    p.cyl([0, 1.5, 0], .15, .15, 2.6, "#FBF1DE", 8, None, "ride"); p.cyl([0, 3.0, 0], 0, 2.1, .9, "@", 20, None, "ride"); p.cyl([0, 2.5, 0], 2.1, 2.1, .25, "#FBF1DE", 20, None, "ride"); p.cyl([0, .4, 0], 1.9, 1.9, .12, "#F1E4CF", 20, None, "ride")
    p.sph([0, 3.55, 0], .12, "#EDC873", "ride")
    for h in range(4):
        a = math.radians(h * 90 + 20); x, z = math.cos(a) * 1.3, math.sin(a) * 1.3; y = .9 + (h % 2) * .25; col = ["#FBF1DE", "#9CC3DE", "#A9D8C0", "#E98AA6"][h]
        p.cyl([x, 1.5, z], .03, .03, 2.1, "#EDC873", 5, None, "ride"); p.box([x, y, z], [.32, .4, .9], col, [0, -math.degrees(a), 0], "ride")
        p.sph([x - math.sin(a) * .4, y + .35, z + math.cos(a) * .4], .17, col, "ride")
        p.sph([math.cos(a) * 2.0, 2.5, math.sin(a) * 2.0], .08, "~#FFF0A0", "ride")

@piece("carnival", "funhouse_face", "Funhouse face", "#E83F5B")
def _(p):
    for sx in (-1.0, 1.0): p.box([sx, .5, 0], [.3, 1.0, .3], "#E98AA6")
    p.cyl([0, 2.4, 0], 2.0, 2.0, .6, "#FFE0B8", 24, [90, 0, 0])
    for k, c in enumerate(["#E98AA6", "#EDC873", "#A9D8C0", "#9CC3DE", "#A98BFF", "#E98AA6", "#EDC873", "#A9D8C0", "#9CC3DE"]):
        x, y = pol(0, 2.4, 2.1, 10 + k * 20); p.sph([x, y, -.1], .5, c)
    for sx in (-.8, .8): p.sph([sx, 2.9, .35], [.45, .55, .2], "#FFFFFF"); p.sph([sx, 2.85, .52], .18, "#2D2A3C"); p.box([sx, 3.55, .35], [.8, .14, .06], "@", [0, 0, -sx * 15])
    p.sph([0, 2.4, .55], .35, "#E83F5B")
    for sx in (-1.3, 1.3): p.sph([sx, 2.2, .4], [.35, .25, .1], "#FF9EC0")
    arc(p, 0, 2.0, .95, 200, 340, 9, .22, .2, ["#7A1F3A"], .3)
    p.box([0, 1.2, .33], [1.5, .9, .1], "#3B1F3A")
    lamps(p, [(math.cos(math.radians(k * 22.5)) * 2.05, 2.4 + math.sin(math.radians(k * 22.5)) * 2.05, .34) for k in range(16)], "~#FFF0A0", .08)

out = {"schema": 1, "notes": "Generated by tools/asset-pipeline/build_set_pieces.py. Schema in src/view/wt_set_piece_builder.gd.", "pieces": PIECES}
for pid in PIECES:
    pc = PIECES[pid]
    for part in pc["parts"]:
        pass
path = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "data", "set_pieces.json")
with open(path, "w") as f: json.dump(out, f, separators=(",", ":"))
from collections import Counter
print(len(PIECES), "pieces", dict(Counter(v["biome"] for v in PIECES.values())), os.path.getsize(path), "bytes")
