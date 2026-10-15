"""Wacky Towers - KNIGHT hero, mid-poly rebuild (Blender 5.x, headless).

Run:  blender -b -P tools/art/build_knight_midpoly.py -- build|bake|export|render|all [workdir]

Pipeline (see report): procedural parts -> Bevel + (Boolean) + Weighted Normal (+ manual
smooth-by-angle) -> join -> per-vertex Col/MR attributes -> smart UV + pack -> Cycles EMIT bake
of albedo (gradient + painted noise + AO + Bevel-node edge wear) and metal/rough -> glTF.
Front faces -Y, right hand is -X, Z up (Blender), nodes: knight, knight_prop (child).
"""
import bpy, bmesh, math, sys, os, random
from mathutils import Vector, Matrix, Quaternion, Euler

REPO = "/home/user/wacky-towers"
OUT_DIR = REPO + "/assets/models/characters"
EVID = REPO + "/production/qa/evidence/heroes-midpoly"
argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else ["all"]
STAGES = argv[0]
WORK = argv[1] if len(argv) > 1 else "/tmp/knight_work"
os.makedirs(WORK, exist_ok=True)
BLEND = OUT_DIR + "/knight.blend"
R = random.Random(7)
SEGK, RINGK = 0.72, 0.78  # resolution scale: keeps the whole figure inside the 8k-20k tri budget


def lin(h):
    h = h.lstrip("#")
    c = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    return tuple(((x + 0.055) / 1.055) ** 2.4 if x > 0.04045 else x / 12.92 for x in c)


# name: (hex, roughness, metal)
MATS = {
    "silver": ("#C6CCD8", 0.26, 0.55),
    "steel": ("#8B929F", 0.34, 0.55),
    "gold": ("#EBB62A", 0.30, 0.65),
    "red": ("#D9352F", 0.85, 0.0),
    "red_dk": ("#A1221F", 0.9, 0.0),
    "plume": ("#E23B3B", 0.85, 0.0),
    "brown": ("#6A3A25", 0.7, 0.0),
    "skin": ("#EDB794", 0.55, 0.0),
    "blush": ("#E98C8C", 0.55, 0.0),
    "hair": ("#7B402A", 0.8, 0.0),
    "dark": ("#34202B", 0.3, 0.0),
    "white": ("#FFFFFF", 0.2, 0.0),
    "nose": ("#EFA08B", 0.5, 0.0),
    "blade": ("#DDE3EC", 0.22, 0.6),
    "fuller": ("#9AA6BA", 0.3, 0.6),
}

# ------------------------------------------------------------------ helpers
PARTS = []


def _new_obj(name, bm, mat, collection=None):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    ob["mat"] = mat
    return ob


def ellipsoid(name, c, r, rot=(0, 0, 0), mat="silver", seg=24, rings=14, bevel=0, **kw):
    seg, rings = max(8, round(seg * SEGK)), max(6, round(rings * RINGK))
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=rings, radius=1.0)
    M = Matrix.Translation(c) @ Euler([math.radians(a) for a in rot]).to_matrix().to_4x4() @ \
        Matrix.Diagonal((r[0], r[1], r[2], 1))
    bmesh.ops.transform(bm, matrix=M, verts=bm.verts)
    ob = _new_obj(name, bm, mat)
    return fin(ob, bevel=bevel, **kw)


def between(name, a, b, r, mat="steel", seg=16, rings=10, extra=0.8, **kw):
    a, b = Vector(a), Vector(b)
    d = b - a
    L = d.length
    seg, rings = max(8, round(seg * SEGK)), max(6, round(rings * RINGK))
    q = Vector((0, 0, 1)).rotation_difference(d)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=rings, radius=1.0)
    M = Matrix.Translation((a + b) / 2) @ q.to_matrix().to_4x4() @ \
        Matrix.Diagonal((r, r, L / 2 + r * extra, 1))
    bmesh.ops.transform(bm, matrix=M, verts=bm.verts)
    return fin(_new_obj(name, bm, mat), bevel=0, **kw)


def cyl(name, c, r1, r2, h, rot=(0, 0, 0), mat="silver", seg=32, bevel=0.008, bseg=3, **kw):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=seg, radius1=r1, radius2=r2, depth=h)
    M = Matrix.Translation(c) @ Euler([math.radians(a) for a in rot]).to_matrix().to_4x4()
    bmesh.ops.transform(bm, matrix=M, verts=bm.verts)
    return fin(_new_obj(name, bm, mat), bevel=bevel, bseg=bseg, **kw)


def box(name, c, s, rot=(0, 0, 0), mat="silver", bevel=0.008, bseg=3, **kw):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    M = Matrix.Translation(c) @ Euler([math.radians(a) for a in rot]).to_matrix().to_4x4() @ \
        Matrix.Diagonal((s[0], s[1], s[2], 1))
    bmesh.ops.transform(bm, matrix=M, verts=bm.verts)
    return fin(_new_obj(name, bm, mat), bevel=bevel, bseg=bseg, **kw)


def torus_arc(name, c, major, minor, rot=(0, 0, 0), mat="silver", seg=48, mseg=8, zmin=None, **kw):
    seg, mseg = max(16, round(seg * SEGK)), max(6, mseg - 1)
    bm = bmesh.new()
    verts = []
    for i in range(seg):
        a = 2 * math.pi * i / seg
        ring = []
        for j in range(mseg):
            b = 2 * math.pi * j / mseg
            rr = major + minor * math.cos(b)
            ring.append(bm.verts.new((rr * math.cos(a), rr * math.sin(a), minor * math.sin(b))))
        verts.append(ring)
    for i in range(seg):
        for j in range(mseg):
            bm.faces.new((verts[i][j], verts[(i + 1) % seg][j], verts[(i + 1) % seg][(j + 1) % mseg],
                          verts[i][(j + 1) % mseg]))
    M = Matrix.Translation(c) @ Euler([math.radians(a) for a in rot]).to_matrix().to_4x4()
    bmesh.ops.transform(bm, matrix=M, verts=bm.verts)
    return fin(_new_obj(name, bm, mat), bevel=0, **kw)


def sweep(name, pts, radii, sides=12, mat="plume", flat=1.0, ripple=0.0, ripple_k=0.0, up=(1, 0, 0), **kw):
    """Loft an elliptical tube along a polyline (plume, mouth): radii per point, flat = x/y squash,
    ripple = chunky horsehair segmentation along the path."""
    pts = [Vector(p) for p in pts]
    bm = bmesh.new()
    rings = []
    n = len(pts)
    for i, p in enumerate(pts):
        t = (pts[min(i + 1, n - 1)] - pts[max(i - 1, 0)]).normalized()
        u = Vector(up) - t * Vector(up).dot(t)
        u.normalize()
        v = t.cross(u).normalized()
        rr = radii[i] * (1 + ripple * math.cos(ripple_k * i * math.pi))
        ring = []
        for k in range(sides):
            a = 2 * math.pi * k / sides
            ring.append(bm.verts.new(p + u * (math.cos(a) * rr * flat) + v * (math.sin(a) * rr)))
        rings.append(ring)
    for i in range(n - 1):
        for k in range(sides):
            bm.faces.new((rings[i][k], rings[i][(k + 1) % sides], rings[i + 1][(k + 1) % sides], rings[i + 1][k]))
    c0 = bm.verts.new(sum(pts[0:1], Vector()) - (pts[1] - pts[0]).normalized() * radii[0] * 0.5)
    c1 = bm.verts.new(pts[-1] + (pts[-1] - pts[-2]).normalized() * radii[-1] * 0.5)
    for k in range(sides):
        bm.faces.new((c0, rings[0][(k + 1) % sides], rings[0][k]))
        bm.faces.new((c1, rings[-1][k], rings[-1][(k + 1) % sides]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return fin(_new_obj(name, bm, mat), bevel=0, sharp=80, **kw)


def fin(ob, bevel=0.006, bseg=3, bangle=35, subsurf=0, mods=None, sharp=48):
    """Bevel (+Subsurf/extra modifiers) -> evaluate; manual Smooth-by-Angle; Weighted Normal -> evaluate."""
    ob.data.polygons.foreach_set("use_smooth", [True] * len(ob.data.polygons))
    if mods:
        mods(ob)
    if bevel:
        m = ob.modifiers.new("Bevel", "BEVEL")
        m.width = bevel
        m.segments = bseg
        m.limit_method = "ANGLE"
        m.angle_limit = math.radians(bangle)
        m.profile = 0.6
    if subsurf:
        s = ob.modifiers.new("Sub", "SUBSURF")
        s.levels = subsurf
        s.render_levels = subsurf
    _apply(ob)
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    for e in bm.edges:  # Smooth by Angle equivalent
        if len(e.link_faces) == 2 and e.calc_face_angle(0) > math.radians(sharp):
            e.smooth = False
    for f in bm.faces:
        f.smooth = True
    bm.to_mesh(ob.data)
    bm.free()
    wn = ob.modifiers.new("WN", "WEIGHTED_NORMAL")
    wn.mode = "FACE_AREA_WITH_ANGLE"
    wn.weight = 60
    wn.keep_sharp = True
    _apply(ob)
    PARTS.append(ob)
    return ob


def _apply(ob):
    if not ob.modifiers:
        return
    dg = bpy.context.evaluated_depsgraph_get()
    ev = ob.evaluated_get(dg)
    me = bpy.data.meshes.new_from_object(ev, preserve_all_data_layers=True, depsgraph=dg)
    old = ob.data
    ob.modifiers.clear()
    ob.data = me
    bpy.data.meshes.remove(old)


def paint(ob, fn=None):
    """Per-vertex Col (linear base colour) and MR (0, rough, metal) attributes."""
    hexc, rough, metal = MATS[ob["mat"]]
    base = lin(hexc)
    me = ob.data
    n = len(me.vertices)
    col, mr = [], []
    for v in me.vertices:
        c, ro, me_ = base, rough, metal
        if fn:
            res = fn(v.co)
            if res:
                c, ro, me_ = res
        col += [c[0], c[1], c[2], 1.0]
        mr += [0.0, ro, me_, 1.0]
    for nm, data in (("Col", col), ("MR", mr)):
        if nm in me.attributes:
            me.attributes.remove(me.attributes[nm])
        a = me.attributes.new(nm, "FLOAT_COLOR", "POINT")
        a.data.foreach_set("color", data)


def smooth(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)


def mix(c1, c2, t):
    return tuple(c1[i] * (1 - t) + c2[i] * t for i in range(3))


# ------------------------------------------------------------------ build
def build():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    PARTS.clear()
    body, sword = [], []

    def S(ob, lst=body):
        lst.append(ob)
        return ob

    # ---- boots / legs (dark steel sabatons)
    for s in (-1, 1):
        x = s * 0.105
        S(ellipsoid("boot", (x, -0.04, 0.075), (0.088, 0.135, 0.078), mat="steel", seg=28, rings=16))
        S(ellipsoid("toecap", (x, -0.125, 0.065), (0.07, 0.055, 0.05), mat="silver", seg=20, rings=12))
        S(cyl("greave", (x, 0.0, 0.17), 0.058, 0.052, 0.12, mat="steel", seg=20, bevel=0.01, bseg=2))
        S(torus_arc("ankle", (x, 0.0, 0.125), 0.062, 0.014, mat="silver", seg=28, mseg=8))

    # ---- skirt / tabard with pleats and rolled hem (displaced grid == sculpted folds)
    bm = bmesh.new()
    nz, ns = 8, 54
    z0, z1 = 0.205, 0.40
    rows = []
    for i in range(nz + 1):
        t = i / nz
        z = z0 + (z1 - z0) * t
        ring = []
        for j in range(ns):
            a = 2 * math.pi * j / ns
            pleat = (0.026 * (1 - t) ** 0.8 + 0.004) * math.cos(9 * a)
            fine = 0.004 * math.sin(23 * a + z * 17) * (1 - t * 0.5)
            r = 0.215 + (0.265 - 0.215) * (1 - t) ** 0.85 + pleat + fine
            zz = z + 0.014 * math.sin(4 * a + 1.0) * (1 - t) ** 1.5 + 0.01 * math.cos(9 * a) * (1 - t) ** 3
            ring.append(bm.verts.new((r * math.cos(a), r * math.sin(a), zz)))
        rows.append(ring)
    for i in range(nz):
        for j in range(ns):
            bm.faces.new((rows[i][j], rows[i][(j + 1) % ns], rows[i + 1][(j + 1) % ns], rows[i + 1][j]))
    sk = _new_obj("skirt", bm, "red")

    def solid(ob):
        m = ob.modifiers.new("Solid", "SOLIDIFY")
        m.thickness = 0.014
        m.offset = 1.0
    S(fin(sk, bevel=0, sharp=70))
    S(torus_arc("hem_roll", (0, 0, 0.215), 0.262, 0.017, mat="red_dk", seg=64, mseg=8))
    # front tabard panel (darker, folds)
    for k, (dx, w) in enumerate(((0, 0.075),)):
        S(box("tabard_panel", (0, -0.245, 0.29), (w * 2, 0.018, 0.2), mat="red_dk", bevel=0.01, bseg=3))

    # ---- belt + buckle
    S(cyl("belt", (0, 0, 0.405), 0.232, 0.232, 0.055, mat="brown", seg=36, bevel=0.007, bseg=2))
    S(box("buckle", (0, -0.238, 0.405), (0.075, 0.022, 0.065), mat="gold", bevel=0.012, bseg=4))
    S(box("buckle_in", (0, -0.252, 0.405), (0.04, 0.012, 0.035), mat="brown", bevel=0.006, bseg=3))
    S(box("belt_tail", (0.07, -0.236, 0.34), (0.035, 0.014, 0.1), mat="brown", bevel=0.006, rot=(0, 0, 0)))

    # ---- cuirass: chunky breast/back plate, central ridge, waist lames, gorget
    S(ellipsoid("cuirass", (0, 0, 0.545), (0.232, 0.188, 0.172), mat="silver", seg=40, rings=22))
    S(ellipsoid("breast_ridge", (0, -0.165, 0.565), (0.055, 0.045, 0.125), mat="silver", seg=20, rings=12))
    S(ellipsoid("breast_L", (0.095, -0.12, 0.575), (0.115, 0.095, 0.105), rot=(0, 0, 12), mat="silver", seg=28, rings=16))
    S(ellipsoid("breast_R", (-0.095, -0.12, 0.575), (0.115, 0.095, 0.105), rot=(0, 0, -12), mat="silver", seg=28, rings=16))
    S(torus_arc("waist_lame1", (0, 0, 0.455), 0.205, 0.022, mat="silver", seg=38, mseg=7))
    S(torus_arc("waist_lame2", (0, 0, 0.43), 0.215, 0.018, mat="steel", seg=38, mseg=6))
    S(cyl("gorget", (0, 0, 0.695), 0.15, 0.165, 0.05, mat="silver", seg=32, bevel=0.012, bseg=2))
    S(torus_arc("gorget_trim", (0, 0, 0.72), 0.152, 0.012, mat="gold", seg=40, mseg=6))
    S(ellipsoid("back_plate", (0, 0.1, 0.57), (0.16, 0.09, 0.1), mat="steel", seg=24, rings=14))

    # ---- pauldrons: three overlapping lames + dome + rivets
    for s in (-1, 1):
        x = s * 0.285
        S(ellipsoid("pauld_a", (x + s * 0.01, 0, 0.605), (0.1, 0.1, 0.05), rot=(0, s * 28, 0), mat="steel", seg=22, rings=12))
        S(ellipsoid("pauld_b", (x, 0, 0.64), (0.108, 0.108, 0.05), rot=(0, s * 24, 0), mat="silver", seg=22, rings=12))
        S(ellipsoid("pauld_c", (x - s * 0.005, 0, 0.675), (0.1, 0.1, 0.055), rot=(0, s * 20, 0), mat="silver", seg=26, rings=14))
        for k in range(2):
            ang = math.radians(-35 + k * 70)
            S(ellipsoid("rivet", (x + s * 0.03 + 0.09 * math.sin(ang) * 0.9, 0.09 * math.cos(ang) * -1 * 0.95, 0.655 + 0.005 * k), (0.012, 0.012, 0.012), mat="gold", seg=10, rings=6))

    # ---- arms: upper arm, cop, forearm, gauntlet fist
    L_elbow, L_hand = (0.325, 0.0, 0.46), (0.315, -0.035, 0.275)
    R_elbow, R_hand = (-0.325, -0.02, 0.46), (-0.275, -0.195, 0.255)
    for s, el, hand in ((1, L_elbow, L_hand), (-1, R_elbow, R_hand)):
        sh = (s * 0.285, 0, 0.60)
        S(between("upper_arm", sh, el, 0.062, mat="steel"))
        S(ellipsoid("elbow_cop", (el[0] + s * 0.012, el[1] - 0.005, el[2]), (0.062, 0.062, 0.062), mat="silver", seg=20, rings=12))
        S(between("forearm", el, hand, 0.062, mat="steel"))
        S(torus_arc("cuff", tuple(Vector(el).lerp(Vector(hand), 0.78)), 0.066, 0.012, mat="silver", seg=24, mseg=6,
                    rot=(math.degrees(math.atan2((hand[1] - el[1]), 0.2)) * 0 + 10 * 0, 0, 0)))
        S(ellipsoid("fist", hand, (0.09, 0.085, 0.085), mat="steel", seg=26, rings=16))
        S(ellipsoid("thumb", (hand[0] - s * 0.06, hand[1] - 0.04, hand[2] + 0.025), (0.03, 0.045, 0.03), mat="steel", seg=14, rings=8))

    # ---- head (face), helmet (Boolean cut), hair, face features
    fc, fr = Vector((0, -0.02, 0.83)), (0.19, 0.19, 0.165)

    def face_paint(co):
        x, y, z = co.x, co.y, co.z
        base = lin(MATS["skin"][0])
        if y < -0.08:
            for s in (-1, 1):
                d = math.hypot(x - s * 0.105, (z - 0.77) * 1.25)
                w = smooth(0.075, 0.015, d) * 0.85
                if w > 0:
                    return mix(base, lin(MATS["blush"][0]), w), 0.55, 0.0
        if z < 0.77:  # lighter chin / jaw
            return mix(base, lin("#F3C7A8"), 0.25), 0.55, 0.0
        return None
    S(paint_ret(ellipsoid("face", fc, fr, mat="skin", seg=48, rings=32), face_paint))

    def surf_y(x, z):
        v = 1 - (x / fr[0]) ** 2 - ((z - fc.z) / fr[2]) ** 2
        return fc.y - fr[1] * math.sqrt(max(v, 0.0))
    for s in (-1, 1):
        ex, ez = s * 0.07, 0.865
        S(ellipsoid("eye", (ex, surf_y(ex, ez) + 0.004, ez), (0.031, 0.019, 0.043), mat="dark", seg=20, rings=12))
        S(ellipsoid("eye_hl", (ex - s * 0.008, surf_y(ex, ez) - 0.006, ez + 0.014), (0.011, 0.007, 0.013), mat="white", seg=10, rings=6))
        S(between("brow", (s * 0.045, surf_y(s * 0.045, 0.925) + 0.004, 0.93), (s * 0.105, surf_y(s * 0.105, 0.915) + 0.004, 0.915), 0.009, mat="hair", seg=10, rings=6))
        S(ellipsoid("ear", (s * 0.19, -0.01, 0.82), (0.02, 0.04, 0.045), mat="skin", seg=12, rings=8))
    S(ellipsoid("nose", (0, surf_y(0, 0.79) - 0.018, 0.79), (0.034, 0.034, 0.032), mat="nose", seg=20, rings=12))
    # smile: lofted tapered tube along an arc
    mp, mr_ = [], []
    for k in range(11):
        t = (k - 5) / 5.0
        mx, mz = 0.06 * t, 0.735 + 0.02 * t * t
        mp.append((mx, surf_y(mx, mz) + 0.001, mz))
        mr_.append(0.0075 * (1 - 0.55 * abs(t) ** 2.5) + 0.0015)
    S(sweep("mouth", mp, mr_, sides=6, mat="dark", flat=1.0, up=(0, -1, 0)))

    # hair: side locks + nape
    for s in (-1, 1):
        S(ellipsoid("lock", (s * 0.178, -0.075, 0.80), (0.058, 0.075, 0.09), rot=(0, 0, s * -10), mat="hair", seg=20, rings=12))
        S(ellipsoid("lock2", (s * 0.15, -0.125, 0.745), (0.05, 0.05, 0.05), mat="hair", seg=14, rings=8))
    S(ellipsoid("nape", (0, 0.1, 0.78), (0.17, 0.12, 0.1), mat="hair", seg=24, rings=14))

    # helmet: solid dome minus face window (Boolean, Bool Tool engine) and minus bottom
    def helm_mods(ob):
        c1 = cutter("cut_face", (0, -0.2, 0.74), (0.3, 0.33, 0.43))   # z top 0.955
        c2 = cutter("cut_low", (0, 0, 0.55), (1.0, 1.0, 0.38))       # below z=0.74
        for c in (c1, c2):
            m = ob.modifiers.new("Bool", "BOOLEAN")
            m.operation = "DIFFERENCE"
            m.solver = "EXACT"
            m.object = c
        ob["_cut"] = [c1.name, c2.name]

    def cutter(n, c, s):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        bmesh.ops.transform(bm, matrix=Matrix.Translation(c) @ Matrix.Diagonal((s[0], s[1], s[2], 1)), verts=bm.verts)
        o = _new_obj(n, bm, "silver")
        return o
    helm = ellipsoid("helmet", (0, 0.01, 0.9), (0.238, 0.245, 0.205), mat="silver", seg=48, rings=28, bevel=0.008, bseg=3, bangle=30, mods=helm_mods)
    for n in helm.get("_cut", []):
        o = bpy.data.objects.get(n)
        if o:
            bpy.data.objects.remove(o)
    S(helm)
    S(torus_arc("helm_rim", (0, 0.01, 0.742), 0.232, 0.017, mat="silver", seg=56, mseg=8))
    S(ellipsoid("helm_brim", (0, -0.17, 0.958), (0.172, 0.085, 0.022), rot=(-8, 0, 0), mat="silver", seg=32, rings=10))
    S(ellipsoid("crest", (0, 0.01, 1.075), (0.03, 0.19, 0.04), mat="steel", seg=24, rings=12))
    for s in (-1, 1):
        S(ellipsoid("helm_stud", (s * 0.155, -0.145, 0.935), (0.014, 0.014, 0.014), mat="gold", seg=10, rings=6))

    # plume: chunky overlapping lobes sweeping up and back
    # plume: one lofted, flattened tube (horsehair ripple) sweeping up then back and down
    ctrl = [(0, -0.02, 1.07), (0, 0.0, 1.17), (0, 0.04, 1.26), (0, 0.10, 1.325), (0, 0.18, 1.335), (0, 0.26, 1.29),
            (0, 0.325, 1.2), (0, 0.37, 1.1), (0, 0.395, 1.0), (0, 0.40, 0.9)]
    pts, rad = [], []
    base_r = [0.055, 0.075, 0.085, 0.088, 0.088, 0.086, 0.082, 0.074, 0.062, 0.04]
    SUB = 3
    for i in range(len(ctrl) - 1):
        for k in range(SUB):
            f = k / SUB
            pts.append(Vector(ctrl[i]).lerp(Vector(ctrl[i + 1]), f))
            rad.append(base_r[i] * (1 - f) + base_r[i + 1] * f)
    pts.append(Vector(ctrl[-1])); rad.append(base_r[-1])
    S(sweep("plume", pts, rad, sides=14, mat="plume", flat=0.78, ripple=0.13, ripple_k=0.667, up=(1, 0, 0)))

    # ---- sword (knight_prop). Built along +Z, then tilted like the original (blade up and outward)
    def sw(ob):
        sword.append(ob)
        return ob
    sw(cyl("grip", (0, 0, 0.075), 0.017, 0.017, 0.11, mat="brown", seg=16, bevel=0.004, bseg=2))
    sw(ellipsoid("pommel", (0, 0, 0.012), (0.03, 0.03, 0.028), mat="gold", seg=20, rings=12))
    sw(box("guard", (0, 0, 0.138), (0.2, 0.026, 0.03), mat="gold", bevel=0.01, bseg=3))
    sw(ellipsoid("guard_L", (0.1, 0, 0.138), (0.022, 0.022, 0.032), mat="gold", seg=14, rings=8))
    sw(ellipsoid("guard_R", (-0.1, 0, 0.138), (0.022, 0.022, 0.032), mat="gold", seg=14, rings=8))
    sw(ellipsoid("guard_mid", (0, -0.012, 0.138), (0.038, 0.02, 0.04), mat="gold", seg=16, rings=10))
    bm = bmesh.new()
    prof = [(1, 0), (0.55, 1), (-0.55, 1), (-1, 0), (-0.55, -1), (0.55, -1)]
    stations = [(0.155, 0.04), (0.45, 0.037), (0.54, 0.03), (0.6, 0.012), (0.625, 0.0)]
    rings_ = []
    for z, w in stations:
        t = 0.0105 if w > 0.0 else 0.0
        ring = []
        for (px, py) in prof:
            ring.append(bm.verts.new((px * w, py * t, z)))
        rings_.append(ring)
    for i in range(len(rings_) - 1):
        for j in range(6):
            a, b = rings_[i], rings_[i + 1]
            bm.faces.new((a[j], a[(j + 1) % 6], b[(j + 1) % 6], b[j]))
    bm.faces.new(rings_[0][::-1])
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-5)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    blade = _new_obj("blade", bm, "blade")
    sw(fin(blade, bevel=0.002, bseg=2, sharp=60))
    sw(box("fuller_f", (0, -0.0105, 0.34), (0.016, 0.004, 0.36), mat="fuller", bevel=0.0015, bseg=2))
    sw(box("fuller_b", (0, 0.0105, 0.34), (0.016, 0.004, 0.36), mat="fuller", bevel=0.0015, bseg=2))
    for ob in sword:
        pass
    # tilt/place the sword in world space (matches original bounds x -0.53..-0.22, z 0.20..0.80)
    ang = math.radians(-21.5)
    Mx = Matrix.Translation((-0.262, -0.215, 0.195)) @ Matrix.Rotation(ang, 4, "Y")
    for ob in sword:
        ob.data.transform(Mx)
        ob.data.update()

    # paint attributes
    for ob in body + sword:
        if "Col" not in ob.data.attributes:
            paint(ob)
    return body, sword


def paint_ret(ob, fn):
    paint(ob, fn)
    return ob


def join(lst, name):
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    for o in lst:
        o.select_set(True)
    bpy.context.view_layer.objects.active = lst[0]
    bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active
    ob.name = name
    ob.data.name = name
    return ob


def tricount(ob):
    return sum(len(p.vertices) - 2 for p in ob.data.polygons)


def stage_build():
    body, sword = build()
    if os.environ.get("KNIGHT_DEBUG"):
        agg = {}
        for o in body + sword:
            agg[o.name.rstrip("0123456789.")] = agg.get(o.name.rstrip("0123456789."), 0) + tricount(o)
        print("PARTS", sorted(agg.items(), key=lambda x: -x[1]))
    kn = join(body, "knight")
    pr = join(sword, "knight_prop")
    pr.parent = kn
    for o in (kn, pr):
        o.data.polygons.foreach_set("use_smooth", [True] * len(o.data.polygons))
    print("TRIS knight", tricount(kn), "prop", tricount(pr), "total", tricount(kn) + tricount(pr))
    bpy.ops.wm.save_as_mainfile(filepath=WORK + "/knight_built.blend")


# ------------------------------------------------------------------ bake
def mk_bake_mat(name, kind):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    nt.nodes.clear()
    N = nt.nodes.new
    L = nt.links.new
    out = N("ShaderNodeOutputMaterial")
    em = N("ShaderNodeEmission")
    L(em.outputs[0], out.inputs[0])
    col = N("ShaderNodeAttribute"); col.attribute_name = "Col"
    mr = N("ShaderNodeAttribute"); mr.attribute_name = "MR"
    geo = N("ShaderNodeNewGeometry")
    # AO
    ao = N("ShaderNodeAmbientOcclusion"); ao.inputs["Distance"].default_value = 0.07; ao.samples = 16
    # bevel normal edge mask
    bev = N("ShaderNodeBevel"); bev.inputs["Radius"].default_value = 0.009; bev.samples = 10
    dot = N("ShaderNodeVectorMath"); dot.operation = "DOT_PRODUCT"
    L(geo.outputs["Normal"], dot.inputs[0]); L(bev.outputs[0], dot.inputs[1])
    mr_ = N("ShaderNodeMapRange"); mr_.clamp = True
    mr_.inputs["From Min"].default_value = 0.985; mr_.inputs["From Max"].default_value = 0.88
    mr_.inputs["To Min"].default_value = 0.0; mr_.inputs["To Max"].default_value = 1.0
    L(dot.outputs["Value"], mr_.inputs["Value"])
    # painted variation noise (two scales) in object space
    nz = N("ShaderNodeTexNoise"); nz.inputs["Scale"].default_value = 22; nz.inputs["Detail"].default_value = 5
    nz2 = N("ShaderNodeTexNoise"); nz2.inputs["Scale"].default_value = 4.5; nz2.inputs["Detail"].default_value = 2
    L(geo.outputs["Position"], nz.inputs["Vector"]); L(geo.outputs["Position"], nz2.inputs["Vector"])
    sep = N("ShaderNodeSeparateXYZ"); L(geo.outputs["Position"], sep.inputs[0])
    mrsep = N("ShaderNodeSeparateColor"); L(mr.outputs["Color"], mrsep.inputs[0])
    # edge amount = edge * (0.25 + 0.75*metal)
    mm = N("ShaderNodeMath"); mm.operation = "MULTIPLY_ADD"
    L(mrsep.outputs["Blue"], mm.inputs[0]); mm.inputs[1].default_value = 0.75; mm.inputs[2].default_value = 0.25
    ea = N("ShaderNodeMath"); ea.operation = "MULTIPLY"; ea.use_clamp = True
    L(mr_.outputs["Result"], ea.inputs[0]); L(mm.outputs[0], ea.inputs[1])
    if kind == "albedo":
        # gradient: darker at feet, lighter up high
        gr = N("ShaderNodeMapRange"); gr.clamp = True
        gr.inputs["From Min"].default_value = 0.0; gr.inputs["From Max"].default_value = 1.3
        gr.inputs["To Min"].default_value = 0.84; gr.inputs["To Max"].default_value = 1.08
        L(sep.outputs["Z"], gr.inputs["Value"])
        # noise variation 0.93..1.07
        v1 = N("ShaderNodeMapRange"); v1.inputs["To Min"].default_value = 0.93; v1.inputs["To Max"].default_value = 1.07
        v1.inputs["From Min"].default_value = 0.35; v1.inputs["From Max"].default_value = 0.65
        L(nz.outputs["Fac"], v1.inputs["Value"])
        v2 = N("ShaderNodeMapRange"); v2.inputs["To Min"].default_value = 0.96; v2.inputs["To Max"].default_value = 1.04
        v2.inputs["From Min"].default_value = 0.3; v2.inputs["From Max"].default_value = 0.7
        L(nz2.outputs["Fac"], v2.inputs["Value"])
        aoq = N("ShaderNodeMapRange"); aoq.inputs["To Min"].default_value = 0.6; aoq.inputs["To Max"].default_value = 1.0
        L(ao.outputs["AO"], aoq.inputs["Value"])
        m1 = N("ShaderNodeMath"); m1.operation = "MULTIPLY"; L(gr.outputs["Result"], m1.inputs[0]); L(v1.outputs["Result"], m1.inputs[1])
        m2 = N("ShaderNodeMath"); m2.operation = "MULTIPLY"; L(m1.outputs[0], m2.inputs[0]); L(v2.outputs["Result"], m2.inputs[1])
        m3 = N("ShaderNodeMath"); m3.operation = "MULTIPLY"; L(m2.outputs[0], m3.inputs[0]); L(aoq.outputs["Result"], m3.inputs[1])
        mulc = N("ShaderNodeMix"); mulc.data_type = "RGBA"; mulc.blend_type = "MULTIPLY"
        mulc.inputs["Factor"].default_value = 1.0
        L(col.outputs["Color"], mulc.inputs["A"])
        gcol = N("ShaderNodeCombineColor"); L(m3.outputs[0], gcol.inputs[0]); L(m3.outputs[0], gcol.inputs[1]); L(m3.outputs[0], gcol.inputs[2])
        L(gcol.outputs[0], mulc.inputs["B"])
        # edge wear highlight: lighten towards near-white silver
        wear = N("ShaderNodeMix"); wear.data_type = "RGBA"
        wear.inputs["B"].default_value = (0.95, 0.96, 1.0, 1.0)
        wf = N("ShaderNodeMath"); wf.operation = "MULTIPLY"; wf.inputs[1].default_value = 0.55
        L(ea.outputs[0], wf.inputs[0]); L(wf.outputs[0], wear.inputs["Factor"])
        L(mulc.outputs["Result"], wear.inputs["A"])
        L(wear.outputs["Result"], em.inputs["Color"])
    else:
        # R=0, G=roughness (+ wear + noise), B=metal (less on worn edges)
        rg = N("ShaderNodeMath"); rg.operation = "MULTIPLY_ADD"; L(ea.outputs[0], rg.inputs[0]); rg.inputs[1].default_value = 0.35
        L(mrsep.outputs["Green"], rg.inputs[2])
        nv = N("ShaderNodeMapRange"); nv.inputs["To Min"].default_value = -0.05; nv.inputs["To Max"].default_value = 0.06
        L(nz.outputs["Fac"], nv.inputs["Value"])
        rg2 = N("ShaderNodeMath"); rg2.operation = "ADD"; rg2.use_clamp = True
        L(rg.outputs[0], rg2.inputs[0]); L(nv.outputs["Result"], rg2.inputs[1])
        mt = N("ShaderNodeMath"); mt.operation = "MULTIPLY_ADD"; L(ea.outputs[0], mt.inputs[0]); mt.inputs[1].default_value = -0.35
        L(mrsep.outputs["Blue"], mt.inputs[2])
        mt2 = N("ShaderNodeMath"); mt2.operation = "MAXIMUM"; mt2.inputs[1].default_value = 0.0
        L(mt.outputs[0], mt2.inputs[0])
        cc = N("ShaderNodeCombineColor"); cc.inputs[0].default_value = 0.0
        L(rg2.outputs[0], cc.inputs[1]); L(mt2.outputs[0], cc.inputs[2])
        L(cc.outputs[0], em.inputs["Color"])
    return m


def stage_bake():
    bpy.ops.wm.open_mainfile(filepath=WORK + "/knight_built.blend")
    kn, pr = bpy.data.objects["knight"], bpy.data.objects["knight_prop"]
    sc = bpy.context.scene
    # --- UV: smart project + pack, both objects share one atlas
    for o in bpy.context.view_layer.objects:
        o.select_set(False)
    for o in (kn, pr):
        o.select_set(True)
        if o.data.uv_layers:
            for u in list(o.data.uv_layers):
                o.data.uv_layers.remove(u)
        o.data.uv_layers.new(name="UVMap")
    bpy.context.view_layer.objects.active = kn
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(70), island_margin=0.004, correct_aspect=True, scale_to_bounds=False)
    bpy.ops.uv.average_islands_scale()
    bpy.ops.uv.pack_islands(margin=0.004, rotate=True)
    bpy.ops.object.mode_set(mode="OBJECT")
    # --- bake setup
    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = 48
    sc.cycles.use_denoising = False
    sc.view_settings.view_transform = "Standard"
    imgs = {}
    for kind, nm, cs in (("albedo", "knight_albedo_1024", "sRGB"), ("mr", "knight_metal_rough_1024", "Non-Color")):
        im = bpy.data.images.new(nm, 1024, 1024, alpha=False)
        im.colorspace_settings.name = cs
        im.generated_color = (0, 0, 0, 1)
        imgs[kind] = im
        mat = mk_bake_mat("bake_" + kind, kind)
        node = mat.node_tree.nodes.new("ShaderNodeTexImage")
        node.image = im
        mat.node_tree.nodes.active = node
        for o in (kn, pr):
            o.data.materials.clear()
            o.data.materials.append(mat)
        for o in bpy.context.view_layer.objects:
            o.select_set(False)
        pr.select_set(True); kn.select_set(True)
        bpy.context.view_layer.objects.active = kn
        bpy.ops.object.bake(type="EMIT", margin=8, margin_type="EXTEND", use_clear=True)
        im.filepath_raw = WORK + "/%s.png" % nm
        im.file_format = "PNG"
        im.save()
        print("baked", nm)
    bpy.ops.wm.save_as_mainfile(filepath=WORK + "/knight_baked.blend")


# ------------------------------------------------------------------ export
def final_materials():
    kn, pr = bpy.data.objects["knight"], bpy.data.objects["knight_prop"]
    ia = bpy.data.images["knight_albedo_1024"]
    im = bpy.data.images["knight_metal_rough_1024"]
    for o, nm in ((kn, "wt_knight_baked"), (pr, "wt_knight_baked.001")):
        for a in ("Col", "MR"):
            if a in o.data.attributes:
                o.data.attributes.remove(o.data.attributes[a])
        m = bpy.data.materials.new(nm)
        m.use_nodes = True
        nt = m.node_tree
        nt.nodes.clear()
        out = nt.nodes.new("ShaderNodeOutputMaterial")
        bs = nt.nodes.new("ShaderNodeBsdfPrincipled")
        nt.links.new(bs.outputs[0], out.inputs[0])
        ta = nt.nodes.new("ShaderNodeTexImage"); ta.image = ia
        tm = nt.nodes.new("ShaderNodeTexImage"); tm.image = im
        sp = nt.nodes.new("ShaderNodeSeparateColor")
        nt.links.new(ta.outputs["Color"], bs.inputs["Base Color"])
        nt.links.new(tm.outputs["Color"], sp.inputs[0])
        nt.links.new(sp.outputs["Green"], bs.inputs["Roughness"])
        nt.links.new(sp.outputs["Blue"], bs.inputs["Metallic"])
        o.data.materials.clear()
        o.data.materials.append(m)


def stage_export():
    bpy.ops.wm.open_mainfile(filepath=WORK + "/knight_baked.blend")
    final_materials()
    for im in bpy.data.images:
        if im.name.startswith("knight_"):
            im.pack()
    bpy.ops.wm.save_as_mainfile(filepath=BLEND, copy=True)
    for o in bpy.context.view_layer.objects:
        o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=OUT_DIR + "/knight.glb", export_format="GLB", export_apply=False,
                              export_yup=True, export_image_format="AUTO", export_materials="EXPORT",
                              export_cameras=False, export_lights=False, export_animations=False,
                              export_normals=True, export_tangents=False, use_selection=True)
    # extracted copies kept next to the GLB (same names as before; Godot imports these)
    for nm in ("knight_albedo_1024", "knight_metal_rough_1024"):
        src = WORK + "/%s.png" % nm
        dst = OUT_DIR + "/knight_%s.png" % nm
        open(dst, "wb").write(open(src, "rb").read())
    print("exported")


# ------------------------------------------------------------------ render
def setup_studio(res):
    sc = bpy.context.scene
    sc.render.engine = "CYCLES"
    sc.cycles.device = "CPU"
    sc.cycles.samples = 48
    sc.cycles.use_denoising = True
    sc.render.resolution_x = sc.render.resolution_y = res
    sc.view_settings.view_transform = "Standard"
    sc.render.film_transparent = False
    w = bpy.data.worlds.new("w")
    sc.world = w
    w.use_nodes = True
    bg = w.node_tree.nodes["Background"]
    bg.inputs[0].default_value = (0.80, 0.83, 0.88, 1)
    bg.inputs[1].default_value = 1.0
    def area(loc, energy, size, col=(1, 1, 1)):
        d = bpy.data.lights.new("a", "AREA"); d.energy = energy; d.size = size; d.color = col
        o = bpy.data.objects.new("a", d); sc.collection.objects.link(o); o.location = loc
        o.rotation_euler = (Vector((0, 0, 0.7)) - Vector(loc)).to_track_quat("-Z", "Y").to_euler()
    area((-1.8, -2.4, 2.4), 260, 2.0, (1.0, 0.96, 0.9))
    area((2.4, -1.2, 1.4), 120, 2.0, (0.85, 0.92, 1.0))
    area((0.5, 2.5, 2.0), 140, 2.0)
    area((0, -0.5, 3.5), 100, 2.5)
    return sc


def cam(az, el, dist, target=(0, 0, 0.68), lens=62):
    sc = bpy.context.scene
    c = bpy.data.cameras.new("c"); c.lens = lens
    o = bpy.data.objects.new("c", c); sc.collection.objects.link(o)
    a, e = math.radians(az), math.radians(el)
    # az 0 = looking at the front (camera at -Y)
    o.location = (target[0] + dist * math.sin(a) * math.cos(e), target[1] - dist * math.cos(a) * math.cos(e), target[2] + dist * math.sin(e))
    o.rotation_euler = (Vector(target) - o.location).to_track_quat("-Z", "Y").to_euler()
    sc.camera = o
    return o


def stage_render(glb=None, outdir=None, prefix="knight"):
    outdir = outdir or EVID
    os.makedirs(outdir, exist_ok=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=glb or OUT_DIR + "/knight.glb")
    sc = setup_studio(512)
    views = {"front": (0, 8), "three_quarter": (-38, 12), "side": (-90, 6), "back": (180, 8)}
    for nm, (az, el) in views.items():
        cam(az, el, 3.0)
        sc.render.filepath = "%s/%s_tile_%s.png" % (outdir, prefix, nm)
        sc.render.resolution_x = sc.render.resolution_y = 512
        bpy.ops.render.render(write_still=True)
    sc.render.resolution_x = sc.render.resolution_y = 1024
    sc.cycles.samples = 96
    cam(-32, 10, 2.7, target=(0, 0, 0.68), lens=75)
    sc.render.filepath = "%s/%s_hero.png" % (outdir, prefix)
    bpy.ops.render.render(write_still=True)


def stage_preview():
    """Quick look at the vertex-colour build (no bake) -> WORK/prev_*.png"""
    bpy.ops.wm.open_mainfile(filepath=WORK + "/knight_built.blend")
    m = bpy.data.materials.new("prev")
    m.use_nodes = True
    nt = m.node_tree
    bs = nt.nodes["Principled BSDF"]
    c = nt.nodes.new("ShaderNodeAttribute"); c.attribute_name = "Col"
    q = nt.nodes.new("ShaderNodeAttribute"); q.attribute_name = "MR"
    sp = nt.nodes.new("ShaderNodeSeparateColor")
    nt.links.new(c.outputs["Color"], bs.inputs["Base Color"])
    nt.links.new(q.outputs["Color"], sp.inputs[0])
    nt.links.new(sp.outputs["Green"], bs.inputs["Roughness"])
    nt.links.new(sp.outputs["Blue"], bs.inputs["Metallic"])
    for o in bpy.data.objects:
        o.data.materials.clear(); o.data.materials.append(m)
    sc = setup_studio(480)
    sc.cycles.samples = 24
    for nm, (az, el) in {"front": (0, 8), "q3": (-38, 12), "back": (180, 8), "side": (-90, 6)}.items():
        cam(az, el, 3.0)
        sc.render.filepath = "%s/prev_%s.png" % (WORK, nm)
        bpy.ops.render.render(write_still=True)


if __name__ == "__main__":
    if STAGES == "preview":
        stage_preview()
    if STAGES in ("build", "all"):
        stage_build()
    if STAGES in ("bake", "all"):
        stage_bake()
    if STAGES in ("export", "all"):
        stage_export()
    if STAGES in ("render", "all"):
        stage_render()
