# build_env_v3.py: Wacky Towers environment kit v3 (rocks, rim kit, hanging, distant islands).
# Run headless:
#   blender -b --factory-startup --python-exit-code 1 --python tools/asset-pipeline/build_env_v3.py -- \
#       <repo_root> [meadow,ice]
# Output: assets/models/env_v3/<biome>/<kind>.glb (one mesh, one vertex-colour material each) and
# the source scene assets/source/blender/env_v3/env_v3_<biome>.blend.
#
# Vertex colour contract (src/view/shaders/spatial_env_prop.gdshader): RGB = sRGB albedo stored
# as raw floats (FLOAT_COLOR, so the glTF exporter writes them unchanged), A >= 0.75 = tinted by
# the instance tint (store a grey value), 0.25..0.75 = fixed colour, < 0.25 = emissive.
# Rock blocks (spatial_env_rock) only use RGB as a value multiplier on the band colour.
# Axes: Blender Z-up becomes Godot Y-up; Godot +Z (block outward face) is Blender -Y.
# Third-party bases: Kenney Nature Kit (CC0), see assets/third_party/CREDITS.md.
import bpy
import bmesh
import math
import os
import random
import sys
from mathutils import Vector, Matrix, noise

ARGS = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
ROOT = ARGS[0] if ARGS else os.getcwd()
BIOMES = (ARGS[1] if len(ARGS) > 1 else "meadow,ice").split(",")
KENNEY = os.path.join(ROOT, "assets/third_party/kenney_nature_kit/extracted/Models/GLTF format")
OUT = os.path.join(ROOT, "assets/models/env_v3")
SRC = os.path.join(ROOT, "assets/source/blender/env_v3")

TINT = 1.0
FIX = 0.5


def hexc(h, a=FIX, mul=1.0):
	h = h.lstrip("#")
	return (int(h[0:2], 16) / 255.0 * mul, int(h[2:4], 16) / 255.0 * mul, int(h[4:6], 16) / 255.0 * mul, a)


def grey(v, a=TINT):
	v = max(0.0, min(1.0, v))
	return (v, v, v, a)


def lerpc(c1, c2, t):
	t = max(0.0, min(1.0, t))
	return tuple(c1[i] + (c2[i] - c1[i]) * t for i in range(3)) + (c1[3],)


def sstep(a, b, x):
	t = max(0.0, min(1.0, (x - a) / (b - a)))
	return t * t * (3.0 - 2.0 * t)


# ------------------------------------------------------------------ scene helpers

def clear_scene():
	for ob in list(bpy.data.objects):
		bpy.data.objects.remove(ob, do_unlink=True)
	for me in list(bpy.data.meshes):
		if me.users == 0:
			bpy.data.meshes.remove(me)


def link(ob, coll=None):
	(coll or bpy.context.scene.collection).objects.link(ob)
	return ob


def bm_to_obj(name, bm, smooth=True):
	me = bpy.data.meshes.new(name)
	bm.normal_update()
	bm.to_mesh(me)
	bm.free()
	ob = bpy.data.objects.new(name, me)
	link(ob)
	for p in me.polygons:
		p.use_smooth = smooth
	return ob


def paint(ob, fn):
	"""fn(co_world, normal_world, vertex_index) -> rgba. Writes a CORNER FLOAT_COLOR 'Col'."""
	me = ob.data
	attr = me.color_attributes.get("Col") or me.color_attributes.new("Col", "FLOAT_COLOR", "CORNER")
	mw = ob.matrix_world
	nm = mw.to_3x3().inverted().transposed()
	cache = {}
	for li, loop in enumerate(me.loops):
		vi = loop.vertex_index
		if vi not in cache:
			v = me.vertices[vi]
			cache[vi] = fn(mw @ v.co, (nm @ v.normal).normalized(), vi)
		attr.data[li].color = cache[vi]
	me.color_attributes.active_color = attr
	return ob


def cavity(ob, strength=1.0):
	"""Per-vertex concavity in 0..1 (1 = deep crease) from neighbour offsets along the normal."""
	bm = bmesh.new()
	bm.from_mesh(ob.data)
	bm.verts.ensure_lookup_table()
	out = {}
	for v in bm.verts:
		if not v.link_edges:
			out[v.index] = 0.0
			continue
		acc = 0.0
		for e in v.link_edges:
			o = e.other_vert(v)
			d = o.co - v.co
			if d.length > 1e-6:
				acc += d.normalized().dot(v.normal)
		acc /= len(v.link_edges)
		out[v.index] = max(0.0, min(1.0, acc * 2.5 * strength))
	bm.free()
	return out


def apply_xf(ob):
	ob.data.transform(ob.matrix_world)
	ob.matrix_world = Matrix.Identity(4)


def join(obs, name):
	obs = [o for o in obs if o is not None]
	for o in obs:
		apply_xf(o)
	if len(obs) > 1:
		with bpy.context.temp_override(active_object=obs[0], selected_editable_objects=obs, selected_objects=obs, object=obs[0]):
			bpy.ops.object.join()
	ob = obs[0]
	ob.name = name
	ob.data.name = name
	return ob


def modifier_apply(ob, mod):
	with bpy.context.temp_override(object=ob, active_object=ob, selected_objects=[ob], selected_editable_objects=[ob]):
		bpy.ops.object.modifier_apply(modifier=mod.name)


def vc_material():
	mat = bpy.data.materials.get("env_v3_vcol")
	if mat:
		return mat
	mat = bpy.data.materials.new("env_v3_vcol")
	mat.use_nodes = True
	nt = mat.node_tree
	bsdf = nt.nodes.get("Principled BSDF")
	attr = nt.nodes.new("ShaderNodeVertexColor")
	attr.layer_name = "Col"
	nt.links.new(attr.outputs["Color"], bsdf.inputs["Base Color"])
	bsdf.inputs["Roughness"].default_value = 0.85
	return mat


EXPORTED = []


BUDGET = {"far_": 6000, "flower": 640, "clover": 640, "bush": 900, "strand": 420, "tree": 900, "shrub": 900, "tree_white": 900, "mound": 500}


def export(ob, biome, kind):
	"""Decimates to the per-kind triangle budget (BUDGET, prefix match), then writes the GLB."""
	target = next((v for k, v in BUDGET.items() if kind.startswith(k)), 0)
	tris = sum(len(p.vertices) - 2 for p in ob.data.polygons)
	if target and tris > target:
		m = ob.modifiers.new("budget", "DECIMATE")
		m.ratio = target / tris
		modifier_apply(ob, m)
	ob.data.materials.clear()
	ob.data.materials.append(vc_material())
	d = os.path.join(OUT, biome)
	os.makedirs(d, exist_ok=True)
	path = os.path.join(d, kind + ".glb")
	for o in bpy.context.scene.objects:
		o.select_set(False)
	ob.select_set(True)
	bpy.context.view_layer.objects.active = ob
	kw = dict(filepath=path, export_format="GLB", use_selection=True, export_apply=True, export_normals=True,
		export_texcoords=False, export_materials="EXPORT", export_yup=True, export_animations=False)
	try:
		bpy.ops.export_scene.gltf(export_vertex_color="ACTIVE", export_all_vertex_colors=False, **kw)
	except TypeError:
		bpy.ops.export_scene.gltf(export_colors=True, **kw)
	tris = sum(len(p.vertices) - 2 for p in ob.data.polygons)
	EXPORTED.append((biome, kind, tris))
	coll = bpy.data.collections.get(biome + "_" + kind) or bpy.data.collections.new(biome + "_" + kind)
	if coll.name not in bpy.context.scene.collection.children:
		bpy.context.scene.collection.children.link(coll)
	for c in list(ob.users_collection):
		c.objects.unlink(ob)
	coll.objects.link(ob)
	ob.location.x += (len(EXPORTED) % 10) * 4.0
	ob.location.y += (len(EXPORTED) // 10) * 4.0
	print("EXPORT", biome, kind, tris, "tris")
	return path


# ------------------------------------------------------------------ primitives

def ico(r=1.0, sub=2):
	bm = bmesh.new()
	bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=r)
	return bm


def uvs(r=1.0, seg=12, rings=6):
	bm = bmesh.new()
	bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=rings, radius=r)
	return bm


def cone(r1, r2, h, seg=8, cap=True):
	bm = bmesh.new()
	bmesh.ops.create_cone(bm, cap_ends=cap, cap_tris=False, segments=seg, radius1=r1, radius2=r2, depth=h)
	bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, h * 0.5))
	return bm


def xform(bm, loc=(0, 0, 0), rot=(0, 0, 0), scl=(1, 1, 1)):
	m = Matrix.Translation(loc) @ (Matrix.Rotation(rot[2], 4, "Z") @ Matrix.Rotation(rot[1], 4, "Y") @ Matrix.Rotation(rot[0], 4, "X")) @ Matrix.Diagonal(Vector(scl).to_4d())
	bmesh.ops.transform(bm, matrix=m, verts=bm.verts)
	return bm


def lumpy(bm, amp=0.08, freq=2.5, seed=0.0):
	off = Vector((seed * 3.1, seed * 1.7, seed * 2.3))
	bm.normal_update()
	for v in bm.verts:
		n = noise.noise(v.co * freq + off)
		v.co += v.normal * n * amp
	return bm


def tube(points, radii, seg=6):
	"""Tapered tube along a polyline (closed tip when last radius is 0)."""
	bm = bmesh.new()
	rings = []
	for i, p in enumerate(points):
		t = (points[min(i + 1, len(points) - 1)] - points[max(i - 1, 0)]).normalized()
		a = Vector((1, 0, 0)) if abs(t.x) < 0.9 else Vector((0, 1, 0))
		u = t.cross(a).normalized()
		w = t.cross(u).normalized()
		ring = []
		for k in range(seg):
			ang = math.tau * k / seg
			ring.append(bm.verts.new(p + (u * math.cos(ang) + w * math.sin(ang)) * max(radii[i], 0.0005)))
		rings.append(ring)
	for i in range(len(rings) - 1):
		for k in range(seg):
			bm.faces.new((rings[i][k], rings[i][(k + 1) % seg], rings[i + 1][(k + 1) % seg], rings[i + 1][k]))
	bm.faces.new(list(reversed(rings[0])))
	bm.faces.new(rings[-1])
	bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
	return bm


def leaf(length, width, thick=0.012, cup=0.25, seg=4):
	"""Flattened, cupped leaf/petal pointing +X from the origin."""
	bm = uvs(1.0, 8, seg + 2)
	for v in bm.verts:
		x = (v.co.x + 1.0) * 0.5
		v.co = Vector((x * length, v.co.y * width * 0.5 * (1.0 - 0.35 * x), v.co.z * thick + cup * (abs(v.co.y) * width * 0.5) ** 2 / max(width, 1e-3) * 4.0))
	return bm


# ------------------------------------------------------------------ Kenney import + restyle

def import_kenney(name):
	path = os.path.join(KENNEY, name + ".glb")
	before = set(bpy.data.objects)
	bpy.ops.import_scene.gltf(filepath=path)
	new = [o for o in bpy.data.objects if o not in before]
	meshes = [o for o in new if o.type == "MESH"]
	for o in new:
		if o.type != "MESH":
			for c in o.children:
				mw = c.matrix_world.copy()
				c.parent = None
				c.matrix_world = mw
	for o in new:
		if o.type != "MESH":
			bpy.data.objects.remove(o, do_unlink=True)
	return join(meshes, name)


def kenney_mat_mask(ob, word):
	"""Set of vertex indices on faces whose material name contains `word` (Kenney colours)."""
	idx = set()
	mats = ob.data.materials
	for p in ob.data.polygons:
		m = mats[p.material_index] if p.material_index < len(mats) else None
		if m and word.lower() in m.name.lower():
			idx.update(p.vertices)
	return idx


def remesh(ob, voxel, smooth_iter=6, smooth_fac=0.6, target_tris=None):
	ob.data.remesh_voxel_size = voxel
	ob.data.use_remesh_fix_poles = True
	with bpy.context.temp_override(object=ob, active_object=ob, selected_objects=[ob], selected_editable_objects=[ob]):
		bpy.ops.object.voxel_remesh()
	if smooth_iter:
		m = ob.modifiers.new("smooth", "SMOOTH")
		m.factor = smooth_fac
		m.iterations = smooth_iter
		modifier_apply(ob, m)
	if target_tris:
		tris = sum(len(p.vertices) - 2 for p in ob.data.polygons)
		if tris > target_tris:
			m = ob.modifiers.new("dec", "DECIMATE")
			m.ratio = target_tris / tris
			modifier_apply(ob, m)
	for p in ob.data.polygons:
		p.use_smooth = True
	return ob


def normalize_unit(ob, centre_z=True):
	"""Fits the object into the -0.5..0.5 unit cube (per axis)."""
	apply_xf(ob)
	vs = [v.co for v in ob.data.vertices]
	lo = Vector((min(v.x for v in vs), min(v.y for v in vs), min(v.z for v in vs)))
	hi = Vector((max(v.x for v in vs), max(v.y for v in vs), max(v.z for v in vs)))
	size = hi - lo
	c = (hi + lo) * 0.5
	m = Matrix.Diagonal((1.0 / size.x, 1.0 / size.y, 1.0 / size.z, 1.0)) @ Matrix.Translation(-c)
	ob.data.transform(m)
	ob.data.update()
	return ob


# ------------------------------------------------------------------ rocks (strata blocks)

def hull_rock(seed, n=40, chip=0.22):
	rnd = random.Random(seed)
	bm = bmesh.new()
	for _ in range(n):
		d = Vector((rnd.gauss(0, 1), rnd.gauss(0, 1), rnd.gauss(0, 1))).normalized()
		r = 1.0 / (abs(d.x) ** 4 + abs(d.y) ** 4 + abs(d.z) ** 4) ** 0.25
		bm.verts.new(d * r * 0.5 * (1.0 - rnd.random() * chip))
	res = bmesh.ops.convex_hull(bm, input=list(bm.verts))
	bmesh.ops.delete(bm, geom=list(set(res["geom_interior"] + res["geom_unused"])), context="VERTS")
	bmesh.ops.dissolve_limit(bm, angle_limit=math.radians(8), verts=bm.verts, edges=bm.edges)
	bmesh.ops.triangulate(bm, faces=bm.faces)
	return bm


def rock_block(seed, kenney_base=None):
	"""Chunky sculpted block: chiselled hull (or a Kenney boulder), voxel-remeshed and smoothed so
	the planes stay but every edge turns soft and fat, then a sculpt-like noise pass."""
	if kenney_base:
		ob = import_kenney(kenney_base)
		normalize_unit(ob)
	else:
		ob = bm_to_obj("rock", hull_rock(seed), smooth=False)
	# Block proportions before remesh so the voxel size is uniform.
	ob.scale = (1.0, 0.8, 0.62)
	apply_xf(ob)
	remesh(ob, 0.045, smooth_iter=5, smooth_fac=0.55)
	bm = bmesh.new()
	bm.from_mesh(ob.data)
	lumpy(bm, 0.025, 3.0, seed)
	# Flatten the back (inward, +Y) so blocks pack against the core.
	for v in bm.verts:
		if v.co.y > 0.2:
			v.co.y = 0.2 + (v.co.y - 0.2) * 0.3
	bm.to_mesh(ob.data)
	bm.free()
	m = ob.modifiers.new("dec", "DECIMATE")
	tris = sum(len(p.vertices) - 2 for p in ob.data.polygons)
	m.ratio = min(1.0, 520.0 / max(tris, 1))
	modifier_apply(ob, m)
	for p in ob.data.polygons:
		p.use_smooth = True
	normalize_unit(ob)
	cav = cavity(ob)
	rnd = random.Random(seed + 7)
	off = Vector((rnd.random() * 10, rnd.random() * 10, rnd.random() * 10))

	def col(co, n, vi):
		top = sstep(0.25, 0.85, n.z)
		under = sstep(0.1, 0.8, -n.z)
		v = 0.86 + 0.2 * top - 0.26 * under - 0.4 * cav.get(vi, 0.0)
		v += 0.09 * noise.noise(co * 4.0 + off)
		v -= 0.12 * sstep(0.0, 0.5, co.y)  # back (into the core) darker
		return grey(v, TINT)
	return paint(ob, col)


def hanging_root(seed, biome_tip=None):
	"""Two or three tapered, kinked roots from one point, hanging down (-Z)."""
	rnd = random.Random(seed)
	parts = []
	for k in range(3):
		pts, rad = [], []
		p = Vector((rnd.uniform(-0.06, 0.06), rnd.uniform(-0.06, 0.06), 0.02))
		d = Vector((rnd.uniform(-0.3, 0.3), rnd.uniform(-0.3, 0.3), -1.0)).normalized()
		length = (0.95 if k == 0 else rnd.uniform(0.45, 0.7))
		steps = 9
		r0 = 0.055 if k == 0 else 0.035
		for i in range(steps + 1):
			t = i / steps
			pts.append(p.copy())
			rad.append(r0 * (1.0 - t) ** 0.8 + 0.004)
			d = (d + Vector((rnd.uniform(-0.35, 0.35), rnd.uniform(-0.35, 0.35), -0.15))).normalized()
			p += d * length / steps
		ob = bm_to_obj("root", tube(pts, rad, 6))
		parts.append(ob)
	ob = join(parts, "root")

	def col(co, n, vi):
		return grey(0.95 + 0.25 * co.z - 0.12 * sstep(0.0, 0.6, -n.z), TINT)
	return paint(ob, col)


def hanging_vine(seed, leaf_hex, stem_hex):
	"""Mossy vine strand with little leaves, hanging down (-Z)."""
	rnd = random.Random(seed)
	parts = []
	for k in range(2):
		pts, rad = [], []
		p = Vector(((k - 0.5) * 0.08, 0, 0.02))
		length = 0.55 if k == 0 else 0.38
		for i in range(8):
			t = i / 7
			pts.append(p + Vector((math.sin(t * 5 + seed) * 0.03, 0, -t * length)))
			rad.append(0.02 * (1 - t) + 0.006)
		parts.append(paint(bm_to_obj("vine", tube(pts, rad, 5)), lambda c, n, v: hexc(stem_hex)))
		for i in range(1, 7):
			t = i / 7
			lb = leaf(0.09, 0.06, 0.008, 0.2)
			xform(lb, loc=pts[i], rot=(0.0, math.radians(55 + rnd.uniform(-15, 15)), (i * 2.4) + rnd.random()))
			parts.append(paint(bm_to_obj("vleaf", lb), lambda c, n, v: lerpc(hexc(leaf_hex), hexc(leaf_hex, mul=1.25), n.z * 0.5 + 0.5)))
	return join(parts, "strand")


# ------------------------------------------------------------------ rim kit

def daisy_head(petal_hex, centre_hex, n_petals, petal_len, petal_w, loc, tilt, rnd):
	parts = []
	base = hexc(petal_hex)
	shade = hexc(petal_hex, mul=0.82)
	for k in range(n_petals):
		a = math.tau * k / n_petals + rnd.uniform(-0.08, 0.08)
		pb = leaf(petal_len, petal_w, 0.01, 0.35)
		xform(pb, rot=(0, -math.radians(14 + rnd.uniform(-6, 6)), a))
		xform(pb, loc=(0, 0, 0))
		ob = bm_to_obj("petal", pb)
		r_max = petal_len

		def pc(co, n, vi, base=base, shade=shade):
			r = math.sqrt(co.x * co.x + co.y * co.y) / r_max
			return lerpc(shade, base, sstep(0.05, 0.6, r))
		parts.append(paint(ob, pc))
	cb = uvs(petal_len * 0.32, 12, 6)
	xform(cb, scl=(1, 1, 0.62), loc=(0, 0, 0.012))
	lumpy(cb, 0.006, 40.0)
	cen = hexc(centre_hex)
	parts.append(paint(bm_to_obj("centre", cb), lambda co, n, vi: lerpc(hexc(centre_hex, mul=0.72), cen, n.z)))
	head = join(parts, "head")
	head.matrix_world = Matrix.Translation(loc) @ Matrix.Rotation(tilt[0], 4, "X") @ Matrix.Rotation(tilt[1], 4, "Y")
	apply_xf(head)
	return head


def leaf_rosette(hex_col, n, length, width, rnd, tint=False, z=0.01):
	parts = []
	for k in range(n):
		a = math.tau * k / n + rnd.uniform(-0.3, 0.3)
		lb = leaf(length * rnd.uniform(0.8, 1.1), width, 0.012, 0.3)
		xform(lb, rot=(0, -math.radians(rnd.uniform(15, 35)), a), loc=(0, 0, z))
		base = grey(0.82, TINT) if tint else hexc(hex_col)

		def lc(co, n_, vi, base=base):
			r = math.sqrt(co.x * co.x + co.y * co.y) / length
			return lerpc(tuple(c * 0.7 for c in base[:3]) + (base[3],), tuple(min(1.0, c * 1.18) for c in base[:3]) + (base[3],), r)
		parts.append(paint(bm_to_obj("leaf", lb), lc))
	return parts


def stem(p0, p1, r, hex_col):
	mid = (p0 + p1) * 0.5 + Vector((0.01, 0.0, 0.0))
	return paint(bm_to_obj("stem", tube([p0, mid, p1], [r, r * 0.9, r * 0.8], 5)), lambda c, n, v: hexc(hex_col))


def flower(kind, petal_hex, n_petals, petal_len, petal_w, seed):
	rnd = random.Random(seed)
	parts = leaf_rosette("#4E9A3A", 4, 0.16, 0.07, rnd)
	heads = [(Vector((0, 0, 0.17)), 1.0), (Vector((0.13, 0.06, 0.1)), 0.78), (Vector((-0.1, 0.1, 0.07)), 0.65)]
	for i, (p, s) in enumerate(heads[: 2 if kind == "flower_lilac" else 3]):
		parts.append(stem(Vector((p.x * 0.3, p.y * 0.3, 0)), p, 0.012, "#4E9A3A"))
		parts.append(daisy_head(petal_hex, "#FFC93A", n_petals, petal_len * s, petal_w * s, p, (rnd.uniform(-0.25, 0.25), rnd.uniform(-0.3, 0.3)), rnd))
	return join(parts, kind)


def clover(seed):
	"""Clump of three-leaf clovers: heart leaflets (two lobes), crease vein, lighter edges."""
	rnd = random.Random(seed)
	parts = []
	for c, (p, h) in enumerate([(Vector((0, 0, 0)), 0.17), (Vector((0.13, 0.05, 0)), 0.12), (Vector((-0.09, 0.11, 0)), 0.09)]):
		top = p + Vector((0, 0, h))
		sb = tube([p, p + Vector((0.01, 0, h * 0.5)), top], [0.012, 0.011, 0.01], 5)
		parts.append(paint(bm_to_obj("cstem", sb), lambda co, n, v: grey(0.62)))
		rot0 = rnd.random() * math.tau
		s = 1.0 - c * 0.18
		for k in range(3):
			a = rot0 + math.tau * k / 3
			for lobe in (-1, 1):
				lb = leaf(0.13 * s, 0.1 * s, 0.014, 0.15)
				xform(lb, rot=(0, -math.radians(12), a + lobe * 0.36), loc=top)
				parts.append(paint(bm_to_obj("lobe", lb), lambda co, n, v, top=top, s=s: grey(0.72 + 0.32 * sstep(0.02, 0.12 * s, (co - top).length) + 0.08 * n.z)))
	return join(parts, "clover")


def tuft(seed, blades=11, h=0.3):
	rnd = random.Random(seed)
	parts = []
	for k in range(blades):
		a = math.tau * k / blades + rnd.uniform(-0.2, 0.2)
		r0 = rnd.uniform(0.0, 0.05)
		base = Vector((math.cos(a) * r0, math.sin(a) * r0, 0))
		lean = rnd.uniform(0.25, 0.6)
		hh = h * rnd.uniform(0.6, 1.1)
		pts, rad = [], []
		for i in range(5):
			t = i / 4
			pts.append(base + Vector((math.cos(a), math.sin(a), 0)) * lean * hh * t * t + Vector((0, 0, hh * t)))
			rad.append(0.022 * (1 - t) + 0.002)
		bm = tube(pts, rad, 3)
		xform(bm, scl=(1, 1, 1))
		parts.append(paint(bm_to_obj("blade", bm), lambda co, n, v, hh=hh: grey(0.55 + 0.55 * sstep(0.0, hh, co.z))))
	return join(parts, "tuft")


def blob_cluster(spheres, seed, amp=0.035, freq=5.0, sub=2, grad=(0.62, 1.12), name="bush"):
	parts = []
	for (p, r) in spheres:
		bm = ico(r, sub)
		xform(bm, loc=p)
		lumpy(bm, amp, freq, seed + r * 10)
		parts.append(bm_to_obj("lobe", bm))
	ob = join(parts, name)
	remesh(ob, 0.03, smooth_iter=3, smooth_fac=0.5, target_tris=900)
	zmax = max(v.co.z for v in ob.data.vertices)
	cav = cavity(ob)
	off = Vector((seed, seed * 2, 0))

	def col(co, n, vi):
		v = grad[0] + (grad[1] - grad[0]) * (0.55 * sstep(0.0, zmax, co.z) + 0.45 * (n.z * 0.5 + 0.5))
		v -= 0.35 * cav.get(vi, 0.0)
		v += 0.07 * noise.noise(co * 9.0 + off)
		return grey(v)
	return paint(ob, col)


def bush(seed):
	rnd = random.Random(seed)
	sph = [(Vector((0, 0, 0.2)), 0.24), (Vector((0.2, 0.05, 0.15)), 0.18), (Vector((-0.17, 0.08, 0.14)), 0.18),
		(Vector((0.02, -0.02, 0.36)), 0.16), (Vector((-0.05, -0.18, 0.12)), 0.15), (Vector((0.1, 0.17, 0.12)), 0.14)]
	ob = blob_cluster(sph, seed)
	# Leaf tips poking out of the silhouette (reads as foliage, not a blob).
	parts = [ob]
	for k in range(14):
		a = rnd.random() * math.tau
		el = rnd.uniform(0.1, 1.2)
		d = Vector((math.cos(a) * math.cos(el), math.sin(a) * math.cos(el), math.sin(el)))
		p = Vector((0, 0, 0.18)) + Vector((d.x * 0.3, d.y * 0.3, d.z * 0.24))
		lb = leaf(0.1, 0.06, 0.01, 0.2)
		xform(lb, rot=(0, -el * 0.7, a), loc=p)
		parts.append(paint(bm_to_obj("tip", lb), lambda co, n, v: grey(1.05)))
	return join(parts, "bush")


def round_tree(seed, trunk_hex="#8B6A48", scale=1.0):
	rnd = random.Random(seed)
	pts = [Vector((0, 0, 0)), Vector((0.02, 0, 0.25)), Vector((0.05, 0.01, 0.5)), Vector((0.04, 0.0, 0.7))]
	trunk = paint(bm_to_obj("trunk", tube(pts, [0.09, 0.06, 0.05, 0.04], 7)), lambda co, n, v: lerpc(hexc(trunk_hex, mul=0.75), hexc(trunk_hex), co.z / 0.6))
	sph = [(Vector((0.03, 0, 0.82)), 0.3), (Vector((0.22, 0.06, 0.7)), 0.2), (Vector((-0.2, -0.04, 0.72)), 0.21),
		(Vector((0.0, 0.2, 0.74)), 0.19), (Vector((0.05, -0.2, 0.7)), 0.18), (Vector((0.04, 0.02, 1.02)), 0.18)]
	can = blob_cluster(sph, seed, amp=0.04, freq=4.0, grad=(0.6, 1.1), name="canopy")
	ob = join([trunk, can], "tree")
	ob.scale = (scale, scale, scale)
	apply_xf(ob)
	return ob


def pine(seed, snow=False, trunk_hex="#7A5A40", snow_hex="#F4F8FF", tiers=4, base_r=0.4, height=1.15):
	"""Stylised pine: drooping wavy-edged tiers, darker underside; optional snow on the tiers."""
	rnd = random.Random(seed)
	parts = [paint(bm_to_obj("trunk", cone(0.07, 0.05, 0.35, 7)), lambda co, n, v: hexc(trunk_hex, mul=0.85 + 0.3 * co.z))]
	for t in range(tiers):
		f = t / max(tiers - 1, 1)
		r = base_r * (1.0 - 0.62 * f)
		z0 = 0.22 + f * (height - 0.55)
		th = 0.42 - 0.08 * f
		bm = cone(r, 0.0, th, 14, cap=True)
		for v in bm.verts:
			if v.co.z < 0.02 and v.co.xy.length > 0.01:
				a = math.atan2(v.co.y, v.co.x)
				v.co.z -= 0.05 + 0.04 * math.sin(a * 7 + seed)
				v.co.xy *= 1.0 + 0.06 * math.sin(a * 7 + seed)
		xform(bm, loc=(0, 0, z0), rot=(0, 0, rnd.random()))
		ob = bm_to_obj("tier", bm)
		z_top = z0 + th

		def tc(co, n, vi, z0=z0, z_top=z_top):
			h = (co.z - z0) / (z_top - z0)
			v = 0.62 + 0.42 * sstep(-0.2, 1.0, h) - 0.25 * sstep(0.2, 0.9, -n.z)
			if snow and n.z > 0.35 and h > 0.05 + 0.25 * (0.5 + 0.5 * math.sin(math.atan2(co.y, co.x) * 7)):
				return hexc(snow_hex, mul=0.92 + 0.08 * h)
			return grey(v)
		parts.append(paint(ob, tc))
	return join(parts, "pine")


def frost_shrub(seed, branch_hex=None, tip_hex="#FFFFFF", tint=True):
	"""Frosty twig shrub: forked tapered twigs with frost puffs at the tips (ice ref 15)."""
	rnd = random.Random(seed)
	parts = []

	def twig(p, d, length, r, depth):
		pts, rad = [], []
		q = p.copy()
		for i in range(5):
			t = i / 4
			pts.append(q.copy())
			rad.append(r * (1 - 0.7 * t))
			d = (d + Vector((rnd.uniform(-0.2, 0.2), rnd.uniform(-0.2, 0.2), 0.05))).normalized()
			q = q + d * length / 4
		col = (lambda co, n, v: grey(0.86)) if tint else (lambda co, n, v: hexc(branch_hex))
		parts.append(paint(bm_to_obj("twig", tube(pts, rad, 4)), col))
		if depth > 0:
			for s in (-1, 1):
				nd = (d + Vector((rnd.uniform(-0.6, 0.6), rnd.uniform(-0.6, 0.6), 0)) * 0.9).normalized()
				twig(q, nd, length * 0.6, r * 0.6, depth - 1)
		else:
			bm = ico(0.035 + r * 0.6, 1)
			xform(bm, loc=q, scl=(1, 1, 0.8))
			parts.append(paint(bm_to_obj("puff", bm), lambda co, n, v: hexc(tip_hex, mul=0.9 + 0.1 * n.z) if not tint else grey(1.0 + 0.04 * n.z)))
	for k in range(5):
		a = math.tau * k / 5 + rnd.uniform(-0.3, 0.3)
		d = Vector((math.cos(a) * 0.45, math.sin(a) * 0.45, 1.0)).normalized()
		twig(Vector((0, 0, 0)), d, rnd.uniform(0.22, 0.3), 0.018, 2)
	return join(parts, "shrub")


def frost_tree(seed):
	"""White frost tree: bent trunk forking into frosted twigs (fixed colours)."""
	rnd = random.Random(seed)
	parts = []

	def br(p, d, length, r, depth):
		pts, rad = [], []
		q = p.copy()
		for i in range(5):
			t = i / 4
			pts.append(q.copy())
			rad.append(r * (1 - 0.6 * t))
			d = (d + Vector((rnd.uniform(-0.15, 0.15), rnd.uniform(-0.15, 0.15), 0.04))).normalized()
			q = q + d * length / 4
		parts.append(paint(bm_to_obj("br", tube(pts, rad, 5)), lambda co, n, v: lerpc(hexc("#C9D2E6"), hexc("#F2F6FC"), n.z * 0.5 + 0.5)))
		if depth > 0:
			for k in range(2 if depth < 3 else 3):
				nd = (d + Vector((rnd.uniform(-0.8, 0.8), rnd.uniform(-0.8, 0.8), 0.1))).normalized()
				br(q, nd, length * 0.62, r * 0.62, depth - 1)
		else:
			bm = ico(0.04, 1)
			xform(bm, loc=q)
			parts.append(paint(bm_to_obj("frost", bm), lambda co, n, v: hexc("#FFFFFF")))
	br(Vector((0, 0, 0)), Vector((0.05, 0, 1)).normalized(), 0.45, 0.05, 3)
	return join(parts, "tree_white")


def snow_mound(seed):
	sph = [(Vector((0, 0, 0.0)), 0.26), (Vector((0.22, 0.08, -0.02)), 0.18), (Vector((-0.18, 0.1, -0.03)), 0.16)]
	ob = blob_cluster(sph, seed, amp=0.025, freq=3.0, grad=(0.82, 1.06), name="mound")
	bm = bmesh.new()
	bm.from_mesh(ob.data)
	bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < -0.06], context="VERTS")
	for v in bm.verts:
		v.co.z = max(v.co.z, -0.04) * 0.75 + 0.03
	bm.to_mesh(ob.data)
	bm.free()
	return ob


def icicles(seed):
	rnd = random.Random(seed)
	parts = []
	for k in range(5):
		p = Vector((rnd.uniform(-0.12, 0.12), rnd.uniform(-0.08, 0.08), 0.02))
		ln = (0.75 if k == 0 else rnd.uniform(0.25, 0.5))
		pts, rad = [], []
		for i in range(6):
			t = i / 5
			pts.append(p + Vector((math.sin(t * 4 + k) * 0.012, 0, -ln * t)))
			rad.append((0.075 if k == 0 else 0.045) * (1 - t) ** 1.2 + 0.001)
		parts.append(paint(bm_to_obj("ice", tube(pts, rad, 6)), lambda co, n, v, ln=ln: lerpc(hexc("#EEF8FF"), hexc("#B8DCF6"), -co.z / ln)))
	return join(parts, "icicle")


def kenney_restyle(name, kind, colour_fn, voxel=0.03, target=900, scale=1.0, smooth_iter=3):
	"""Imports a Kenney model, keeps its silhouette, rounds it (voxel remesh + smooth), repaints."""
	ob = import_kenney(name)
	masks = {w: kenney_mat_mask(ob, w) for w in ("wood", "bark", "brown", "trunk", "leaf", "leafs", "grass", "green", "snow", "stone")}
	# Remesh loses the material split, so record the trunk region by height/radius before.
	ob.scale = (scale, scale, scale)
	apply_xf(ob)
	trunk_pts = [ob.data.vertices[i].co.copy() for i in (masks["wood"] | masks["bark"] | masks["brown"] | masks["trunk"])]
	remesh(ob, voxel, smooth_iter=smooth_iter, smooth_fac=0.5, target_tris=target)
	cav = cavity(ob)
	zmax = max(v.co.z for v in ob.data.vertices)

	def near_trunk(co):
		for p in trunk_pts[::3]:
			if (p - co).length < voxel * 2.5:
				return True
		return False
	return paint(ob, lambda co, n, vi: colour_fn(co, n, vi, near_trunk(co), cav.get(vi, 0.0), zmax))


# ------------------------------------------------------------------ distant islands

def superellipse_slab(hx, hy, top, depth, n=40, rings=3):
	"""Rounded-rectangle slab with a domed top (top at z = top), returns bmesh."""
	bm = bmesh.new()
	loops = []
	prof = [(1.0, top - 0.05 * (1 - k / rings)) for k in range(rings)]
	prof = [(0.0, top + 0.02), (0.55, top + 0.01), (0.9, top), (0.98, top - 0.06), (1.0, top - 0.16), (0.98, top - depth * 0.6), (0.9, top - depth)]
	centre = bm.verts.new((0, 0, top + 0.03))
	for (rf, z) in prof[1:]:
		ring = []
		for i in range(n):
			a = math.tau * i / n
			c, s = math.cos(a), math.sin(a)
			sq = 1.0 / (abs(c) ** 4 + abs(s) ** 4) ** 0.25
			ring.append(bm.verts.new((c * sq * hx * rf, s * sq * hy * rf, z)))
		loops.append(ring)
	for i in range(n):
		bm.faces.new((centre, loops[0][(i + 1) % n], loops[0][i]))
	for r in range(len(loops) - 1):
		for i in range(n):
			bm.faces.new((loops[r][i], loops[r][(i + 1) % n], loops[r + 1][(i + 1) % n], loops[r + 1][i]))
	bm.faces.new(list(loops[-1]))
	bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
	return bm


def far_island(biome, kind, P, seed, rocks):
	"""Floating island: grass/snow capped slab with drips, chunky rock strata to a point, landmark."""
	rnd = random.Random(seed)
	hx, hy = 1.6, 1.35
	parts = []
	slab = bm_to_obj("slab", superellipse_slab(hx, hy, 0.25, 0.55))
	cap, cap_l, cap_d, body = P["cap"], P["cap_light"], P["cap_dark"], P["far_rock"]

	def slab_col(co, n, vi):
		drip = 0.12 + 0.07 * math.sin(math.atan2(co.y, co.x) * 9 + seed)
		if co.z > 0.25 - drip or n.z > 0.6:
			t = sstep(0.2, 0.9, n.z)
			return lerpc(hexc(cap_d), hexc(cap_l if t > 0.8 else cap), 0.4 + 0.6 * t)
		return lerpc(hexc(body, mul=0.7), hexc(body), sstep(-0.3, 0.2, co.z))
	parts.append(paint(slab, slab_col))
	# Rock strata: rings of sculpted blocks tapering to a point.
	bands = [(0.97, -0.25, 0.55, 22), (0.78, -0.75, 0.6, 16), (0.52, -1.3, 0.62, 11), (0.26, -1.85, 0.6, 6)]
	strata = P["strata"]
	for bi, (rf, z, h, cnt) in enumerate(bands):
		core = cone(rf * 0.9, rf * 0.55, h, 16)
		xform(core, loc=(0, 0, z - h), scl=(hx, hy, 1))
		parts.append(paint(bm_to_obj("core", core), lambda co, n, v, bi=bi: hexc(strata[min(bi, 2)], mul=0.55)))
		for k in range(cnt):
			a = math.tau * (k + rnd.uniform(-0.15, 0.15)) / cnt
			c, s = math.cos(a), math.sin(a)
			sq = 1.0 / (abs(c) ** 4 + abs(s) ** 4) ** 0.25
			p = Vector((c * sq * hx * rf, s * sq * hy * rf, z - h * 0.5))
			w = (math.tau * rf * (hx + hy) * 0.5) / cnt * rnd.uniform(1.0, 1.25)
			src = rocks[rnd.randrange(len(rocks))]
			ob = src.copy()
			ob.data = src.data.copy()
			link(ob)
			ob.matrix_world = Matrix.Translation(p) @ Matrix.Rotation(a + math.pi * 0.5, 4, "Z") @ Matrix.Diagonal((w, 0.5, h * rnd.uniform(0.95, 1.15), 1))
			bc = hexc(strata[min(bi, 2)], mul=rnd.uniform(0.9, 1.08))
			def rc(co, n, vi, bc=bc):
				k = max(0.55, min(1.15, 0.85 + 0.25 * n.z))
				return (bc[0] * k, bc[1] * k, bc[2] * k, FIX)
			paint(ob, rc)
			parts.append(ob)
	# Landmark.
	lm = []
	if kind in ("trees", "waterfall"):
		spots = [(-0.8, -0.45), (-0.15, -0.7), (0.65, -0.4), (-1.05, 0.35), (0.95, 0.45), (0.25, 0.1)]
		for i, (x, y) in enumerate(spots[: 6 if kind == "trees" else 4]):
			t = round_tree(seed + i, scale=rnd.uniform(1.15, 1.5))
			paint(t, lambda co, n, vi, t=t: (hexc("#8B6A48") if co.z < 0.5 and math.hypot(co.x, co.y) < 0.13 else lerpc(hexc(P["far_tree_dark"]), hexc(P["far_tree_light"]), sstep(0.5, 1.6, co.z) * 0.6 + 0.4 * (n.z * 0.5 + 0.5))))
			t.location = (x, y, 0.25)
			lm.append(t)
	if kind == "pine":
		for i, (x, y) in enumerate([(-0.8, -0.4), (-0.1, -0.7), (0.6, -0.3), (1.05, 0.4), (-1.05, 0.45), (0.2, 0.25)]):
			t = pine(seed + i, snow=P.get("snowy", False), snow_hex=P.get("snow", "#F4F8FF"))
			paint(t, lambda co, n, vi, t=t: _fixed_pine_colour(co, n, P))
			t.scale = (1.6,) * 3
			t.location = (x, y, 0.25)
			lm.append(t)
	if kind == "castle":
		lm += castle(P, seed)
	if kind == "mountain":
		m = bm_to_obj("mtn", lumpy(xform(cone(1.15, 0.12, 2.0, 10), loc=(-0.2, -0.15, 0.2)), 0.08, 1.5, seed))
		paint(m, lambda co, n, v: hexc(P["snow"]) if co.z > 1.25 + 0.15 * math.sin(math.atan2(co.y, co.x + 0.2) * 6) or n.z > 0.75 else hexc(P["far_rock"], mul=0.8 + 0.25 * n.z))
		lm.append(m)
		t = pine(seed, snow=True, snow_hex=P.get("snow", "#F4F8FF"))
		paint(t, lambda co, n, vi: _fixed_pine_colour(co, n, P))
		t.location = (1.0, 0.5, 0.25)
		lm.append(t)
	ob = join(parts + lm, "far_" + kind)
	return ob


def _fixed_pine_colour(co, n, P):
	if co.z < 0.3 * 1.6 + 0.25 and n.z < 0.6 and abs(n.z) < 0.6 and math.hypot(n.x, n.y) > 0.9 and False:
		return hexc("#7A5A40")
	v = 0.62 + 0.4 * (n.z * 0.5 + 0.5)
	if P.get("snowy") and n.z > 0.45:
		return hexc(P["snow"])
	return hexc(P["pine"], mul=v)


def castle(P, seed):
	stone, roof = P["far_stone"], P["far_accent"]
	out = []

	def scol(co, n, v):
		return hexc(stone, mul=0.82 + 0.2 * (n.z * 0.5 + 0.5) - 0.06 * (math.sin(co.z * 22) > 0.85))
	keep = bmesh.new()
	bmesh.ops.create_cube(keep, size=1.0)
	xform(keep, loc=(0, -0.2, 0.25 + 0.4), scl=(1.1, 0.7, 0.8))
	b = bm_to_obj("keep", keep, smooth=False)
	bev = b.modifiers.new("bev", "BEVEL")
	bev.width = 0.05
	bev.segments = 2
	modifier_apply(b, bev)
	out.append(paint(b, scol))
	for (x, y, h, r) in [(-0.6, -0.2, 1.2, 0.2), (0.6, -0.2, 1.2, 0.2), (0.0, -0.5, 1.9, 0.24), (0.3, 0.25, 0.85, 0.16), (-0.3, 0.3, 0.7, 0.14)]:
		t = bm_to_obj("tower", xform(cone(r, r * 0.92, h, 14), loc=(x, y, 0.25)))
		out.append(paint(t, scol))
		ring = bm_to_obj("ring", xform(cone(r * 1.15, r * 1.15, 0.1, 14), loc=(x, y, 0.25 + h - 0.05)))
		out.append(paint(ring, scol))
		rf = bm_to_obj("roof", xform(cone(r * 1.25, 0.0, r * 3.2, 14), loc=(x, y, 0.25 + h + 0.05)))
		out.append(paint(rf, lambda co, n, v: hexc(roof, mul=0.75 + 0.35 * (n.z * 0.5 + 0.5))))
		# windows
		w = bmesh.new()
		bmesh.ops.create_cube(w, size=1.0)
		xform(w, loc=(x, y - r * 0.95, 0.25 + h * 0.7), scl=(0.06, 0.05, 0.12))
		out.append(paint(bm_to_obj("win", w, smooth=False), lambda co, n, v: hexc(roof, mul=0.45)))
	return out


# ------------------------------------------------------------------ biome palettes (from biome_looks.json)

def palettes():
	import json
	d = json.load(open(os.path.join(ROOT, "assets/data/biome_looks.json")))["biomes"]
	out = {}
	for b in ("meadow", "ice"):
		e = d[b]["env"]
		out[b] = {"cap": e["cap"]["color"], "cap_light": e["cap"]["light"], "cap_dark": e["cap"]["dark"],
			"far_rock": e.get("far_rock", "#A07650"), "strata": e["strata"], "far_stone": e.get("far_stone", "#ECE8F4"),
			"far_accent": e.get("far_accent", "#6A7FD0"), "far_cap": e.get("far_cap", e["cap"]["color"]),
			"snow": e["cap"]["light"] if b == "ice" else "#F4F8FF", "snowy": b == "ice"}
	# Tree / pine paint for the distant islands: the far_cap green family (meadow) or the ice cap.
	out["meadow"].update({"far_tree_dark": out["meadow"]["cap_dark"], "far_tree_light": out["meadow"]["cap_light"], "pine": out["meadow"]["cap_dark"]})
	out["ice"].update({"far_tree_dark": out["ice"]["cap_dark"], "far_tree_light": out["ice"]["cap_light"], "pine": "#5E7FA8"})
	return out


# ------------------------------------------------------------------ main

def build(biome, P):
	clear_scene()
	rocks = []
	kenney_rocks = ["rock_largeA", "rock_largeB", "rock_largeC", "rock_largeD", "rock_largeE", "rock_largeF"]
	for i in range(8):
		base = kenney_rocks[i] if i < len(kenney_rocks) and os.path.isdir(KENNEY) else None
		r = rock_block(11 + i * 7 + (0 if biome == "meadow" else 100), base)
		if biome == "ice":
			# Frosted rock: snow settles on the top lip (fixed white, A = 0.5 is ignored by the rock
			# shader, which only reads RGB as value, so frost is painted as a bright value).
			paint(r, (lambda cav: (lambda co, n, vi: grey(1.25 if n.z > 0.55 else (0.86 + 0.2 * sstep(0.25, 0.85, n.z) - 0.26 * sstep(0.1, 0.8, -n.z) - 0.4 * cav.get(vi, 0.0)))))(cavity(r)))
		rocks.append(r)
		export(r, biome, "rock_block_%02d" % (i + 1))
	if biome == "meadow":
		export(hanging_root(5), biome, "root")
		export(hanging_vine(9, "#6CB040", "#4E8A34"), biome, "strand")
		export(flower("flower_white", "#FFF6F0", 11, 0.12, 0.05, 1), biome, "flower_white")
		export(flower("flower_lilac", "#B99CF2", 5, 0.12, 0.09, 2), biome, "flower_lilac")
		export(clover(3), biome, "clover")
		export(tuft(4), biome, "tuft")
		export(bush(6), biome, "bush")
		export(round_tree(7), biome, "tree")
		pk = pine(8)
		export(pk, biome, "pine")
		for kind in ("trees", "waterfall", "castle"):
			export(far_island(biome, kind, P, 20 + len(kind), rocks), biome, "far_" + kind)
		# Kenney flower restyle for the yellow/pink variants (silhouette from Kenney, paint ours).
		if os.path.isdir(KENNEY):
			def kflower(co, n, vi, trunk, cav, zmax, petal):
				if co.z > zmax * 0.55:
					return hexc(petal, mul=0.85 + 0.2 * n.z)
				return hexc("#4E9A3A", mul=0.8 + 0.3 * co.z / max(zmax, 1e-3))
			export(kenney_restyle("flower_yellowA", "flower_yellow", lambda *a: kflower(*a, petal="#FFE27A"), voxel=0.012, target=700, scale=0.8), biome, "flower_yellow")
			export(kenney_restyle("flower_redA", "flower_pink", lambda *a: kflower(*a, petal="#F6A8C8"), voxel=0.012, target=700, scale=0.8), biome, "flower_pink")
	if biome == "ice":
		export(icicles(12), biome, "icicle")
		export(pine(13, snow=True, snow_hex=P["snow"]), biome, "pine")
		export(frost_shrub(14), biome, "shrub")
		export(frost_tree(15), biome, "tree_white")
		export(snow_mound(16), biome, "mound")
		for kind in ("castle", "pine", "mountain", "waterfall"):
			export(far_island(biome, kind, P, 40 + len(kind), rocks), biome, "far_" + kind)
	os.makedirs(SRC, exist_ok=True)
	bpy.ops.wm.save_as_mainfile(filepath=os.path.join(SRC, "env_v3_%s.blend" % biome), compress=True)


if __name__ == "__main__":
	pal = palettes()
	for b in BIOMES:
		build(b, pal[b])
	for e in EXPORTED:
		print("SUMMARY", *e)
