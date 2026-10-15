"""Wacky Towers - mid-poly ELF hero builder (Blender 5.x, headless).

Run:  blender -b -P tools/asset-pipeline/build_elf_midpoly.py -- <out_dir> [stage]
Pipeline (per part): control cage (tube / ellipsoid / loft) -> Subdivision Surface
-> Bevel on hard parts -> scripted "sculpt" brushes (grab/inflate/noise: cheeks,
chin, cloth folds, hair grooves) -> vertex-colour paint (gradient + hand-painted
noise + cavity AO) -> join -> Smooth-by-Angle sharp edges -> Weighted Normals ->
smart UV -> Cycles bake to elf_albedo_1024 / elf_metal_rough_1024 -> glTF.
Conventions match knight.glb: metres, feet at z=0, origin 0, front -Y (Blender),
mesh 'elf' with child 'elf_prop', one material 'wt_elf_baked'.
"""
import bpy, bmesh, sys, math, random
import numpy as np, time
T0 = time.time()
def tick(msg): print('T+%.1fs %s' % (time.time() - T0, msg), flush=True)
from mathutils import Vector, Euler, Matrix, noise
from mathutils.bvhtree import BVHTree

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
OUT = argv[0] if argv else "/tmp/elf_out"
STAGE = argv[1] if len(argv) > 1 else "all"
random.seed(7)

def lin(h):
    h = h.lstrip('#'); c = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    return Vector([(x / 12.92 if x <= .04045 else ((x + .055) / 1.055) ** 2.4) for x in c])

# palette: matched to assets/art/ui/elf_idle.png (albedo, not lit values)
PAL = dict(tunic='#4C9A3A', tunic_dark='#37802F', hat='#58A546', hat_rim='#3D8A3A', collar='#5DAA48',
           hair='#EFCB63', hair_hi='#FFE98A', skin='#F3BFA2', cheek='#F29A8C', nose='#EE9A8C',
           ear='#F0B598', belt='#8B5A3B', buckle='#FFD447', boot='#5B3F2C', trim='#E9C99C',
           wood='#7B4A32', band='#D8382F', eye='#1C1B38', iris='#7A4430', white='#FFFFFF', mouth='#8E3C3C')
C = {k: lin(v) for k, v in PAL.items()}

# ---------------------------------------------------------------- helpers
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
col = bpy.data.collections.new("elf_build"); scene.collection.children.link(col)

def mk_obj(name, me):
    o = bpy.data.objects.new(name, me); col.objects.link(o); return o

def frames(pts, up, closed):
    n = len(pts); out = []
    for i in range(n):
        if closed: t = pts[(i + 1) % n] - pts[i - 1]
        else: t = pts[min(i + 1, n - 1)] - pts[max(i - 1, 0)]
        t = t.normalized()
        u = up[i] if isinstance(up, list) else up
        u = Vector(u)
        nn = u - t * u.dot(t)
        if nn.length < 1e-4: nn = Vector((1, 0, 0)) - t * t.x
        nn.normalize(); b = t.cross(nn).normalized(); out.append((t, nn, b))
    return out

def tube(pts, rx, ry, segs=14, up=(0, 0, 1), closed=False, caps=(True, True)):
    """Swept elliptical tube. rx along the frame normal (toward `up`), ry along binormal."""
    pts = [Vector(p) for p in pts]; bm = bmesh.new(); fr = frames(pts, up, closed)
    rings = []
    for i, p in enumerate(pts):
        t, nn, b = fr[i]; r = []
        for k in range(segs):
            a = 2 * math.pi * k / segs
            r.append(bm.verts.new(p + nn * (rx[i] * math.cos(a)) + b * (ry[i] * math.sin(a))))
        rings.append(r)
    n = len(pts); rng = n if closed else n - 1
    for i in range(rng):
        A, B = rings[i], rings[(i + 1) % n]
        for k in range(segs): bm.faces.new((A[k], A[(k + 1) % segs], B[(k + 1) % segs], B[k]))
    if not closed:
        for end, flag in ((0, caps[0]), (n - 1, caps[1])):
            if flag:
                c = bm.verts.new(pts[end]); r = rings[end]
                for k in range(segs): bm.faces.new((r[k], r[(k + 1) % segs], c))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return bm

def ellipsoid(c, r, rot=(0, 0, 0), u=16, v=10):
    bm = bmesh.new(); bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=1.0)
    m = Matrix.Translation(c) @ Euler(rot).to_matrix().to_4x4() @ Matrix.Diagonal((r[0], r[1], r[2], 1))
    bmesh.ops.transform(bm, matrix=m, verts=bm.verts[:]); return bm

def cube_box(c, r, rot=(0, 0, 0)):
    bm = bmesh.new(); bmesh.ops.create_cube(bm, size=2.0)
    m = Matrix.Translation(c) @ Euler(rot).to_matrix().to_4x4() @ Matrix.Diagonal((r[0], r[1], r[2], 1))
    bmesh.ops.transform(bm, matrix=m, verts=bm.verts[:]); return bm

def ellipse_ring(cx, cy, cz, rx, ry, n=28):
    return [Vector((cx + rx * math.sin(2 * math.pi * i / n), cy - ry * math.cos(2 * math.pi * i / n), cz)) for i in range(n)]

def zloft(prof, segs=28):
    """Body of revolution (elliptical) along Z. prof = [(z, rx, ry, cy)]"""
    pts = [Vector((0, p[3], p[0])) for p in prof]
    # tube's normal axis = up=(0,1,0) -> rx runs along Y; ry along X (swap)
    return tube(pts, [p[2] for p in prof], [p[1] for p in prof], segs=segs, up=(0, 1, 0))

PARTS = []   # (obj, tag, is_prop)

def finish(name, bm, tag, sub=1, bevel=None, solid=None, prop=False):
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    o = mk_obj(name, me)
    if solid:
        m = o.modifiers.new("Solid", 'SOLIDIFY'); m.thickness = solid; m.offset = -1
    if bevel:
        m = o.modifiers.new("Bevel", 'BEVEL'); m.width = bevel; m.segments = 3; m.limit_method = 'ANGLE'; m.angle_limit = math.radians(40)
    sub = max(sub - 1, 0) if name not in ("head", "tunic") else sub
    if sub:
        m = o.modifiers.new("Subsurf", 'SUBSURF'); m.levels = sub; m.render_levels = sub
    dg = bpy.context.evaluated_depsgraph_get(); ev = o.evaluated_get(dg)
    me2 = bpy.data.meshes.new_from_object(ev); o2 = mk_obj(name, me2)
    bpy.data.objects.remove(o); o2.name = name
    PARTS.append([o2, tag, prop]); return o2

def brush(o, centre, radius, strength, direction=None):
    """Sculpt-style grab/inflate brush on an object's vertices (smooth quartic falloff)."""
    c = Vector(centre)
    for v in o.data.vertices:
        d = (v.co - c).length
        if d < radius:
            f = (1 - (d / radius) ** 2) ** 2
            dirn = Vector(direction) if direction is not None else v.normal
            v.co += dirn * strength * f

def noise_disp(o, amp, freq, aniso=(1, 1, 1), seed=0, mask=None):
    for v in o.data.vertices:
        p = Vector((v.co.x * freq * aniso[0] + seed, v.co.y * freq * aniso[1], v.co.z * freq * aniso[2]))
        k = amp * noise.noise(p) * (mask(v.co) if mask else 1.0)
        v.co += v.normal * k

def smooth(x, a, b):
    t = max(0, min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t)

# ---------------------------------------------------------------- geometry
HC = Vector((0, 0, .95)); HR = Vector((.27, .25, .24))     # head ellipsoid
def hs(a_deg, e_deg, off=0.0):
    a, e = math.radians(a_deg), math.radians(e_deg)
    d = Vector((math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e)))
    return HC + Vector((HR.x * d.x, HR.y * d.y, HR.z * d.z)) + d * off, d

# head
head = finish("head", ellipsoid(HC, HR, u=28, v=18), 'skin', sub=1)
for sx in (-1, 1):
    brush(head, (sx * .17, -.20, .875), .11, .014)       # cheek planes
    brush(head, (sx * .105, -.235, .955), .06, -.006)    # eye socket
brush(head, (0, -.215, .75), .09, .013, (0, -1, 0))      # chin
brush(head, (0, -.24, 1.03), .10, .006, (0, -1, .2))     # brow
# ears (pointed leaf, thin in Y, tall in Z, tip swept up/back) + inner dent
for sx in (-1, 1):
    pts = [(sx * .22, .02, .965), (sx * .31, .025, .995), (sx * .40, .03, 1.045), (sx * .48, .035, 1.11), (sx * .535, .04, 1.17)]
    ear = finish("ear%+d" % sx, tube(pts, [.032, .028, .02, .012, .003], [.075, .068, .048, .026, .004], segs=10, up=(0, 1, 0)), 'ear', sub=2)
    brush(ear, (sx * .33, -.012, 1.01), .07, -.011, (0, 1, 0))
# nose
finish("nose", ellipsoid((0, -.278, .885), (.056, .056, .054), u=16, v=12), 'nose', sub=1)
# mouth: dark smile tube following head surface
mp = []
for i in range(9):
    a = -24 + 6 * i; s = abs(a) / 24
    p, d = hs(a, -30 + 6 * (s ** 2) * -1 + 0, 0.004)      # corners lift
    mp.append(Vector((p.x, p.y, .838 + .02 * s * s)))
finish("mouth", tube(mp, [.0085] * 9, [.0085] * 9, segs=8, up=(0, 0, 1)), 'mouth', sub=1)
# eyes (tall glossy ovals, iris gradient painted later) + catchlights as tiny geometry
for sx in (-1, 1):
    a = sx * 23; p, d = hs(a, 2, -.004)
    rot = (0, 0, math.radians(-a))
    ec = Vector((p.x, p.y, .952)); R = Euler(rot).to_matrix()
    finish("eye%+d" % sx, ellipsoid(ec, (.053, .024, .076), rot=rot, u=20, v=14), 'eye', sub=1)
    eye_frame = R
    for nm, off, r in (("hi_big", (sx * .016, -.021, .034), .020), ("hi_small", (-sx * .016, -.021, -.03), .0105)):
        q = ec + R @ Vector(off)
        finish("%s%+d" % (nm, sx), ellipsoid(q, (r, r * .6, r), u=10, v=8), 'white', sub=1)

# torso (tunic) with hem flare, then trims
tun_prof = [(.255, .245, .205, 0), (.285, .272, .228, 0), (.34, .268, .225, 0), (.42, .25, .208, 0), (.50, .235, .198, 0),
            (.58, .242, .198, .0), (.645, .235, .19, 0), (.70, .19, .155, 0), (.735, .13, .11, 0)]
tun = finish("tunic", zloft(tun_prof, 32), 'tunic', sub=1)
def tunic_fold_mask(p): return 1.0
noise_disp(tun, .006, 9, (1, 1, 2.5), seed=3)
for v in tun.data.vertices:                                  # drape folds around hem + belt puff
    th = math.atan2(v.co.y, v.co.x)
    fold = math.sin(th * 9 + v.co.z * 4) * .007 * (1 - smooth(v.co.z, .27, .46))
    puff = .011 * math.exp(-((v.co.z - .535) / .035) ** 2)
    v.co += v.normal * (fold + puff)
finish("hem_trim", tube(ellipse_ring(0, 0, .272, .262, .222, 32), [.026] * 32, [.020] * 32, segs=8, closed=True), 'trim', sub=1)
finish("belt", tube(ellipse_ring(0, 0, .47, .254, .212, 32), [.032] * 32, [.017] * 32, segs=8, closed=True), 'belt', sub=1)
finish("buckle", cube_box((0, -.232, .47), (.034, .012, .034)), 'buckle', sub=2, bevel=.006)
col_r = finish("collar", tube(ellipse_ring(0, .0, .745, .245, .205, 32), [.062] * 32, [.060] * 32, segs=14, closed=True), 'collar', sub=1)
noise_disp(col_r, .008, 7, (1, 1, 1), seed=11)
# arms: sleeves + mitten hands + thumbs ; legs + boots
for sx in (-1, 1):
    sl = finish("sleeve%+d" % sx, tube([(sx * .235, 0, .625), (sx * .285, -.005, .53), (sx * .325, -.02, .44), (sx * .34, -.03, .395)],
                                        [.088, .084, .078, .074], [.088, .084, .078, .074], segs=14, up=(0, 1, 0)), 'tunic', sub=1)
    noise_disp(sl, .006, 10, (1, 1, 1), seed=sx * 5)
    finish("hand%+d" % sx, ellipsoid((sx * .352, -.04, .33), (.09, .082, .092), u=18, v=12), 'skin', sub=1)
    finish("thumb%+d" % sx, tube([(sx * .30, -.09, .35), (sx * .325, -.115, .365), (sx * .335, -.125, .39)], [.03, .027, .02], [.03, .027, .02], segs=8, up=(0, 0, 1)), 'skin', sub=1)
    finish("leg%+d" % sx, tube([(sx * .12, -.01, .27), (sx * .12, -.015, .17), (sx * .12, -.02, .10)], [.058] * 3, [.058] * 3, segs=10, up=(0, 1, 0)), 'skin', sub=1)
    b = finish("boot%+d" % sx, ellipsoid((sx * .12, -.05, .066), (.098, .145, .072), u=20, v=12), 'boot', sub=1)
    brush(b, (sx * .12, -.17, .05), .09, .008, (0, -1, 0))
    finish("boot_cuff%+d" % sx, tube(ellipse_ring(sx * .12, -.015, .115, .066, .066, 14), [.016] * 14, [.014] * 14, segs=8, closed=True), 'boot', sub=1)

# hat: shell over the head, rolled brim, drooping tail
bm = ellipsoid((0, .012, .99), (.318, .31, .305), u=36, v=22)
def zcut(y): return .985 - .30 * y
kill = [v for v in bm.verts if v.co.z < zcut(v.co.y)]
bmesh.ops.delete(bm, geom=kill, context='VERTS')
bm.verts.ensure_lookup_table()
bnd = [v.co.copy() for v in bm.verts if v.is_boundary]
bnd.sort(key=lambda p: math.atan2(p.y - .012, p.x))
bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
hat = finish("hat", bm, 'hat', sub=1, solid=.03)
noise_disp(hat, .007, 6, (1, 1, 1), seed=21)
step = max(1, len(bnd) // 36); bnd = bnd[::step]
rim = finish("hat_rim", tube(bnd, [.034] * len(bnd), [.032] * len(bnd), segs=10, up=(0, 0, 1), closed=True), 'hat_rim', sub=1)
noise_disp(rim, .004, 8, seed=2)
tail = finish("hat_tail", tube([(0, .20, 1.24), (.0, .32, 1.21), (.03, .43, 1.12), (.08, .49, 1.0), (.13, .50, .90)],
                               [.12, .105, .08, .045, .012], [.12, .105, .08, .045, .012], segs=14, up=(1, 0, 0)), 'hat', sub=1)
noise_disp(tail, .005, 8, seed=4)

# hair: blond clumps (side locks that wrap the ear, brim fringe), grooved
def clump(name, path, rad, wid=None, sub=1):
    pts, ups = [], []
    for a, e, off in path:
        p, d = hs(a, e, off); pts.append(p); ups.append(d)
    n = len(pts); wid = wid or rad
    rx = [rad[0] + (rad[1] - rad[0]) * i / (n - 1) for i in range(n)]
    ry = [wid[0] + (wid[1] - wid[0]) * i / (n - 1) for i in range(n)]
    o = finish(name, tube(pts, rx, ry, segs=10, up=ups), 'hair', sub=sub)
    noise_disp(o, .0045, 55, (0.4, 0.4, 0.4), seed=hash(name) % 50)   # fine groove sculpt
    return o
for sx in (-1, 1):
    clump("sidelock_a%+d" % sx, [(sx * 66, 54, .035), (sx * 74, 30, .06), (sx * 80, 5, .075), (sx * 83, -18, .06), (sx * 84, -34, .02)], (.062, .018), (.075, .035))
    clump("sidelock_b%+d" % sx, [(sx * 50, 56, .035), (sx * 58, 38, .05), (sx * 66, 20, .062), (sx * 72, 2, .048), (sx * 74, -10, .015)], (.05, .014), (.06, .028))
for i, a in enumerate((-48, -26, -4, 18, 40)):
    clump("fringe%d" % i, [(a, 62, .03), (a + 3, 52, .05), (a + 5, 44 - (i % 2) * 4, .052), (a + 6, 38 - (i % 2) * 6, .035)], (.05, .012), (.062, .02))

# slingshot prop
fork = lambda p: tube(p, [.026, .026, .023], [.026, .026, .023], segs=10, up=(0, 1, 0))
finish("sling_handle", fork([(-.365, -.05, .27), (-.395, -.07, .40), (-.43, -.09, .52)]), 'wood', sub=1, prop=True)
finish("sling_arm_l", fork([(-.43, -.09, .52), (-.48, -.095, .60), (-.535, -.09, .68)]), 'wood', sub=1, prop=True)
finish("sling_arm_r", fork([(-.43, -.09, .52), (-.405, -.10, .60), (-.40, -.10, .69)]), 'wood', sub=1, prop=True)
finish("sling_knob_l", ellipsoid((-.538, -.09, .69), (.044, .042, .042)), 'wood', sub=1, prop=True)
finish("sling_knob_r", ellipsoid((-.40, -.10, .70), (.044, .042, .042)), 'wood', sub=1, prop=True)
finish("sling_band", tube([(-.538, -.09, .69), (-.50, -.10, .655), (-.45, -.105, .64), (-.40, -.10, .70)], [.0105] * 4, [.0105] * 4, segs=8, up=(0, 1, 0)), 'band', sub=1, prop=True)

tick('geometry done verts=%d' % sum(len(p[0].data.vertices) for p in PARTS))
if STAGE == 'geo':
    tot = 0
    for o, tag, prop in PARTS:
        t = sum(len(p.vertices) - 2 for p in o.data.polygons); tot += t; print('  %-16s %6d' % (o.name, t))
    print('TOTAL', tot); sys.exit(0)
# ---------------------------------------------------------------- vertex colour paint
def gradient(p, z0, z1, ca, cb):
    t = smooth(p.z, z0, z1); return ca.lerp(cb, t)
def hp(p, s=1.0, seed=0):          # hand-painted variation
    return 1 + s * (noise.noise(p * 14 + Vector((seed, 0, 0))) * .07 + noise.noise(p * 3.2) * .05)

def paint(tag, p, n):
    rough, metal = .8, 0.0
    if tag == 'tunic':
        c = gradient(p, .26, .70, C['tunic_dark'], C['tunic']) * hp(p, 1, 1); rough = .88
    elif tag == 'collar':
        c = C['collar'].lerp(C['tunic'], smooth(-p.z + .75, 0, .1)) * hp(p, 1, 2); c = c * (.88 + .18 * n.z); rough = .88
    elif tag == 'hat':
        c = gradient(p, .9, 1.3, C['hat_rim'], C['hat']) * hp(p, 1, 3); rough = .85
    elif tag == 'hat_rim': c = C['hat_rim'] * hp(p, .8, 4); rough = .8
    elif tag == 'hair':
        c = C['hair'].lerp(C['hair_hi'], smooth(n.z + .35 * noise.noise(p * 40), .0, .9)) * hp(p, .7, 5)
        c = c.lerp(C['hair'] * .78, smooth(-p.z + 1.0, 0, .25)); rough = .5
    elif tag == 'skin':
        c = C['skin'].lerp(C['cheek'], .85 * max(smooth(.075 - ((abs(p.x) - .17) ** 2 + (p.y + .20) ** 2 + (p.z - .875) ** 2) ** .5, 0, .075), 0)) * hp(p, .5, 6)
        rough = .55
    elif tag == 'ear':
        c = C['ear'].lerp(C['cheek'], .5 * smooth(.14 - (p.x * 0 + abs(abs(p.x) - .3)), 0, .14) * (1 - smooth(p.z, 1.03, 1.15))) * hp(p, .5, 7); rough = .55
    elif tag == 'nose': c = C['nose'] * hp(p, .5, 8); rough = .45
    elif tag == 'belt': c = C['belt'] * hp(p, 1, 9); rough = .6
    elif tag == 'buckle': c = C['buckle']; rough = .3; metal = .9
    elif tag == 'boot': c = C['boot'].lerp(C['boot'] * .7, smooth(.09 - p.z, 0, .09)) * hp(p, 1, 10); rough = .7
    elif tag == 'trim': c = C['trim'] * hp(p, 1, 12); rough = .85
    elif tag == 'wood': c = C['wood'] * hp(p, 1.2, 13); rough = .6
    elif tag == 'band': c = C['band']; rough = .55
    elif tag == 'mouth': c = C['mouth']; rough = .5
    elif tag == 'white': c = Vector((1, 1, 1)); rough = .1
    elif tag == 'eye':
        t = smooth(p.z, .90, 1.0)   # iris: warm brown lower, navy upper
        c = C['iris'].lerp(C['eye'], t); rough = .12
    else: c = Vector((.5, .5, .5))
    return c, rough, metal

for o, tag, prop in PARTS:
    me = o.data
    ca = me.color_attributes.new("Color", 'FLOAT_COLOR', 'POINT'); cm = me.color_attributes.new("MR", 'FLOAT_COLOR', 'POINT')
    for v in me.vertices:
        c, r, m = paint(tag, v.co, v.normal)
        ca.data[v.index].color = (c.x, c.y, c.z, 1); cm.data[v.index].color = (1, r, m, 1)

tick('paint done')
# ---------------------------------------------------------------- join
def join(objs, name):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs: o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]; bpy.ops.object.join(); o = bpy.context.view_layer.objects.active; o.name = name; o.data.name = name; return o
body_parts = [p[0] for p in PARTS if not p[2]]; prop_parts = [p[0] for p in PARTS if p[2]]
elf = join(body_parts, "elf"); prop = join(prop_parts, "elf_prop")

# cavity / ambient occlusion painted into the colour (soft hand-painted shading)
bm = bmesh.new(); 
for o in (elf, prop): bm.from_mesh(o.data)
bm.faces.ensure_lookup_table(); bvh = BVHTree.FromBMesh(bm); bm.free()
rng = random.Random(3)
dirs = []
for i in range(8):
    z = rng.uniform(.05, 1); ph = rng.uniform(0, 2 * math.pi); r = math.sqrt(1 - z * z); dirs.append((r * math.cos(ph), r * math.sin(ph), z))
for o in (elf, prop):
    me = o.data; ca = me.color_attributes["Color"]; me.calc_loop_triangles()
    for v in me.vertices:
        n = v.normal; t = n.cross(Vector((0, 0, 1)) if abs(n.z) < .9 else Vector((1, 0, 0))).normalized(); b = n.cross(t)
        hit = 0
        for d in dirs:
            w = t * d[0] + b * d[1] + n * d[2]
            if bvh.ray_cast(v.co + n * .004, w, .09)[0] is not None: hit += 1
        ao = 1 - .42 * hit / len(dirs)
        c = ca.data[v.index].color; ca.data[v.index].color = (c[0] * ao, c[1] * ao, c[2] * ao, 1)

tick('AO done')
# ---------------------------------------------------------------- shading: smooth by angle + weighted normals
for o in (elf, prop):
    bpy.ops.object.select_all(action='DESELECT'); o.select_set(True); bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_smooth()
    bmx = bmesh.new(); bmx.from_mesh(o.data)           # Smooth by Angle: edges sharper than 60 deg become sharp
    for e in bmx.edges:
        if len(e.link_faces) == 2 and e.calc_face_angle(0) > math.radians(60): e.smooth = False
    bmx.to_mesh(o.data); bmx.free()
    m = o.modifiers.new("WN", 'WEIGHTED_NORMAL'); m.mode = 'FACE_AREA'; m.weight = 50; m.keep_sharp = True; m.thresh = .01
    bpy.ops.object.modifier_apply(modifier="WN")

tick('shading done')
# ---------------------------------------------------------------- UV + bake
bpy.ops.object.select_all(action='DESELECT')
for o in (elf, prop): o.select_set(True)
bpy.context.view_layer.objects.active = elf
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=.003, correct_aspect=True, scale_to_bounds=False)
bpy.ops.uv.pack_islands(margin=.004)
bpy.ops.object.mode_set(mode='OBJECT')
# multi-object edit mode: both objects share one packed atlas
def tri_count(o): return sum(len(p.vertices) - 2 for p in o.data.polygons)

mat = bpy.data.materials.new("wt_elf_baked"); mat.use_nodes = True
nt = mat.node_tree; nt.nodes.clear()
out = nt.nodes.new('ShaderNodeOutputMaterial'); em = nt.nodes.new('ShaderNodeEmission'); at = nt.nodes.new('ShaderNodeAttribute')
nt.links.new(at.outputs['Color'], em.inputs['Color']); nt.links.new(em.outputs[0], out.inputs[0])
img_node = nt.nodes.new('ShaderNodeTexImage')
for o in (elf, prop):
    o.data.materials.clear(); o.data.materials.append(mat)
scene.render.engine = 'CYCLES'; scene.cycles.device = 'CPU'; scene.cycles.samples = 1; scene.cycles.use_denoising = False
scene.render.bake.margin = 8; scene.render.bake.use_clear = True
def bake(attr, imgname, srgb):
    im = bpy.data.images.new(imgname, 1024, 1024, alpha=False, float_buffer=False)
    im.colorspace_settings.name = 'sRGB' if srgb else 'Non-Color'
    at.attribute_name = attr; img_node.image = im; nt.nodes.active = img_node
    bpy.ops.object.select_all(action='DESELECT'); elf.select_set(True); prop.select_set(True); bpy.context.view_layer.objects.active = elf
    bpy.ops.object.bake(type='EMIT'); return im
print("TRIS body", tri_count(elf), "prop", tri_count(prop))

import os
os.makedirs(OUT, exist_ok=True)
tick('uv done tris %d' % (tri_count(elf)+tri_count(prop)))
alb = bake("Color", "elf_albedo_1024", True); mr = bake("MR", "elf_metal_rough_1024", False)
for im, nm in ((alb, "elf_albedo_1024"), (mr, "elf_metal_rough_1024")):
    im.filepath_raw = os.path.join(OUT, nm + ".png"); im.file_format = 'PNG'; im.save(); im.pack()

tick('bake done')
# final PBR material (matches knight: albedo + metal_rough with Separate Color)
nt.nodes.clear()
out = nt.nodes.new('ShaderNodeOutputMaterial'); bs = nt.nodes.new('ShaderNodeBsdfPrincipled')
ta = nt.nodes.new('ShaderNodeTexImage'); ta.image = alb
tm = nt.nodes.new('ShaderNodeTexImage'); tm.image = mr
sp = nt.nodes.new('ShaderNodeSeparateColor')
nt.links.new(ta.outputs['Color'], bs.inputs['Base Color']); nt.links.new(tm.outputs['Color'], sp.inputs['Color'])
nt.links.new(sp.outputs['Green'], bs.inputs['Roughness']); nt.links.new(sp.outputs['Blue'], bs.inputs['Metallic'])
nt.links.new(bs.outputs[0], out.inputs[0])
bs.inputs['Specular IOR Level'].default_value = .35
for o in (elf, prop):
    for a in list(o.data.color_attributes): o.data.color_attributes.remove(a)
prop.parent = elf
print("FINAL TRIS body", tri_count(elf), "prop", tri_count(prop), "total", tri_count(elf) + tri_count(prop))
print("DIMS", tuple(round(x, 3) for x in elf.dimensions))
for k in ("elf_build",): pass
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT, "elf.blend"))
bpy.ops.object.select_all(action='DESELECT'); elf.select_set(True); prop.select_set(True)
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, "elf.glb"), export_format='GLB', use_selection=True, export_yup=True,
                          export_apply=False, export_image_format='AUTO', export_materials='EXPORT')

# ---------------------------------------------------------------- renders
def render_set(prefix):
    scene.render.engine = 'CYCLES'; scene.cycles.samples = 48; scene.cycles.use_denoising = True; scene.cycles.device = 'CPU'
    scene.render.film_transparent = False
    w = bpy.data.worlds.new("w"); scene.world = w; w.use_nodes = True
    bg = w.node_tree.nodes['Background']; bg.inputs[0].default_value = (.93, .94, .95, 1); bg.inputs[1].default_value = .9
    scene.view_settings.view_transform = 'Standard'
    def light(name, loc, energy, size, color=(1, 1, 1)):
        l = bpy.data.lights.new(name, 'AREA'); l.energy = energy; l.size = size; l.color = color
        o = bpy.data.objects.new(name, l); scene.collection.objects.link(o); o.location = loc
        d = (Vector((0, 0, .65)) - o.location).to_track_quat('-Z', 'Y'); o.rotation_euler = d.to_euler()
    light("key", (1.6, -2.2, 2.4), 260, 1.6, (1, .96, .9)); light("fill", (-2.4, -1.6, 1.2), 90, 2.2, (.85, .92, 1)); light("rim", (-.5, 2.5, 2.2), 160, 1.4)
    cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); scene.collection.objects.link(cam); scene.camera = cam
    cam.data.lens = 70
    def shot(path, az, dist=4.6, tz=.64, res=768):
        a = math.radians(az); cam.location = Vector((math.sin(a) * dist, -math.cos(a) * dist, tz + .25))
        cam.rotation_euler = (Vector((0, 0, tz)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
        scene.render.resolution_x = scene.render.resolution_y = res; scene.render.filepath = path; bpy.ops.render.render(write_still=True)
    rd = os.path.join(OUT, "render"); os.makedirs(rd, exist_ok=True)
    shot(os.path.join(rd, prefix + "_hero.png"), 28, dist=3.4, tz=.7, res=1024)
    for nm, az in (("front", 0), ("three_quarter", 40), ("side", 90), ("back", 180)):
        shot(os.path.join(rd, prefix + "_tile_%s.png" % nm), az)
if STAGE in ("all", "render"): render_set("elf")
