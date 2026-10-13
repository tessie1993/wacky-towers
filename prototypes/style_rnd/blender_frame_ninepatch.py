# Style R&D prototype (b): purple-wood UI frame with vines, rendered for a Godot nine-patch.
# Run: <blender> -b -P prototypes/style_rnd/blender_frame_ninepatch.py
# Output: prototypes/style_rnd/renders/frame_purple_vine.png (+ .json with nine-patch margins)
# Everything is procedural (no textures, no third-party assets). Cycles CPU.
import bpy, bmesh, math, json, os, random
from mathutils import Vector, Matrix

random.seed(7)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "renders")
os.makedirs(OUT, exist_ok=True)
RES = 1024          # 2x asset; shown at 512 in Godot
ORTHO = 2.30        # world units covered by the image
H = 1.0             # frame outer half-size
VARIANT = os.environ.get("WT_VARIANT", "panel")  # panel | chip
W = 0.34 if VARIANT == "panel" else 0.24   # plank width
T = 0.13            # plank thickness (towards camera, +Z)

bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene

def hexc(h, a=1.0):
    h = h.lstrip('#'); c = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    # sRGB -> linear, because Blender colour sockets are linear
    return tuple(((x + 0.055) / 1.055) ** 2.4 if x > 0.04045 else x / 12.92 for x in c) + (a,)

def principled(name):
    m = bpy.data.materials.new(name)
    try: m.use_nodes = True
    except Exception: pass
    return m, m.node_tree.nodes, m.node_tree.links, m.node_tree.nodes["Principled BSDF"]

def mix(nodes, links, fac, a, b, blend='MIX'):
    n = nodes.new("ShaderNodeMix"); n.data_type = 'RGBA'; n.blend_type = blend
    if isinstance(fac, float): n.inputs[0].default_value = fac
    else: links.new(fac, n.inputs[0])
    for sock, v in ((n.inputs[6], a), (n.inputs[7], b)):
        if isinstance(v, tuple): sock.default_value = v
        else: links.new(v, sock)
    return n.outputs[2]

def edge_mask(nodes, links, radius=0.025):
    """Painted edge-highlight mask: 1 - dot(bevelled normal, true normal). Cycles only."""
    bev = nodes.new("ShaderNodeBevel"); bev.inputs["Radius"].default_value = radius; bev.samples = 8
    geo = nodes.new("ShaderNodeNewGeometry")
    dot = nodes.new("ShaderNodeVectorMath"); dot.operation = 'DOT_PRODUCT'
    links.new(bev.outputs["Normal"], dot.inputs[0]); links.new(geo.outputs["Normal"], dot.inputs[1])
    inv = nodes.new("ShaderNodeMath"); inv.operation = 'SUBTRACT'; inv.inputs[0].default_value = 1.0
    links.new(dot.outputs["Value"], inv.inputs[1])
    mul = nodes.new("ShaderNodeMath"); mul.operation = 'MULTIPLY'; mul.inputs[1].default_value = 6.0
    mul.use_clamp = True; links.new(inv.outputs[0], mul.inputs[0])
    return mul.outputs[0], bev.outputs["Normal"]

def ao_cavity(nodes, links, dist=0.08):
    ao = nodes.new("ShaderNodeAmbientOcclusion"); ao.inputs["Distance"].default_value = dist; ao.samples = 8
    return ao.outputs["AO"]

def ramp(nodes, links, fac, stops):
    r = nodes.new("ShaderNodeValToRGB"); links.new(fac, r.inputs[0])
    els = r.color_ramp.elements
    while len(els) > 2: els.remove(els[-1])
    for i, (p, c) in enumerate(stops):
        e = els[i] if i < 2 else els.new(p)
        e.position = p; e.color = hexc(c)
    return r.outputs[0]

# ---------- materials ----------
def wood_material(name, along_x, dark, mid, light):
    m, nodes, links, bsdf = principled(name)
    tc = nodes.new("ShaderNodeTexCoord")
    mp = nodes.new("ShaderNodeMapping")
    # stretch the coordinate along the plank so grain runs lengthwise
    mp.inputs["Scale"].default_value = (0.5, 3.5, 1.0) if along_x else (3.5, 0.5, 1.0)
    links.new(tc.outputs["Object"], mp.inputs["Vector"])
    wave = nodes.new("ShaderNodeTexWave"); wave.wave_type = 'BANDS'
    wave.bands_direction = 'Y' if along_x else 'X'
    wave.inputs["Scale"].default_value = 1.6; wave.inputs["Distortion"].default_value = 3.5
    wave.inputs["Detail"].default_value = 2.0; wave.inputs["Detail Scale"].default_value = 1.5
    links.new(mp.outputs[0], wave.inputs["Vector"])
    noise = nodes.new("ShaderNodeTexNoise"); noise.inputs["Scale"].default_value = 3.0
    noise.inputs["Detail"].default_value = 2.0      # low detail = painted, not photo
    links.new(tc.outputs["Object"], noise.inputs["Vector"])
    f = nodes.new("ShaderNodeMath"); f.operation = 'MULTIPLY_ADD'
    links.new(wave.outputs["Fac"], f.inputs[0]); f.inputs[1].default_value = 0.55
    links.new(noise.outputs["Fac"], f.inputs[2])
    f2 = nodes.new("ShaderNodeMath"); f2.operation = 'MULTIPLY'; f2.inputs[1].default_value = 0.75
    links.new(f.outputs[0], f2.inputs[0])
    base = ramp(nodes, links, f2.outputs[0], [(0.22, dark), (0.5, mid), (0.88, light)])
    # dark grain lines: a second, finer wave pushed through a narrow ramp
    wave2 = nodes.new("ShaderNodeTexWave"); wave2.wave_type = 'BANDS'
    wave2.bands_direction = 'Y' if along_x else 'X'
    wave2.inputs["Scale"].default_value = 5.0; wave2.inputs["Distortion"].default_value = 3.0
    wave2.inputs["Detail"].default_value = 1.0
    links.new(mp.outputs[0], wave2.inputs["Vector"])
    lines = ramp(nodes, links, wave2.outputs["Fac"], [(0.0, '#ffffff'), (0.08, '#ffffff'), (0.12, '#a58cbf')])
    base = mix(nodes, links, 0.7, base, lines, 'MULTIPLY')
    # painted lighting baked into albedo: cavity darkening + bright lit edge
    edge, bev_n = edge_mask(nodes, links, 0.03)
    ao = ao_cavity(nodes, links)
    col = mix(nodes, links, edge, base, hexc(light), 'MIX')
    aom = nodes.new("ShaderNodeMath"); aom.operation = 'POWER'; aom.inputs[1].default_value = 1.6
    links.new(ao, aom.inputs[0])
    col = mix(nodes, links, 1.0, col, aom.outputs[0], 'MULTIPLY') if False else col
    # multiply by AO (via mix MULTIPLY with fac 1)
    ao_rgb = nodes.new("ShaderNodeCombineColor")
    for i in range(3): links.new(aom.outputs[0], ao_rgb.inputs[i])
    col = mix(nodes, links, 0.85, col, ao_rgb.outputs[0], 'MULTIPLY')
    links.new(col, bsdf.inputs["Base Color"])
    links.new(bev_n, bsdf.inputs["Normal"])
    bsdf.inputs["Roughness"].default_value = 0.72
    bsdf.inputs["Specular IOR Level"].default_value = 0.3
    return m

def flat_material(name, base, rough=0.5, metal=0.0, edge_light=None, emission=None, coat=0.0):
    m, nodes, links, bsdf = principled(name)
    col = hexc(base)
    if edge_light:
        edge, bev_n = edge_mask(nodes, links, 0.012)
        c = mix(nodes, links, edge, col, hexc(edge_light))
        links.new(c, bsdf.inputs["Base Color"]); links.new(bev_n, bsdf.inputs["Normal"])
    else:
        bsdf.inputs["Base Color"].default_value = col
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    bsdf.inputs["Coat Weight"].default_value = coat
    if emission:
        bsdf.inputs["Emission Color"].default_value = hexc(emission); bsdf.inputs["Emission Strength"].default_value = 0.3
    return m

def parchment_material():
    m, nodes, links, bsdf = principled("parchment")
    tc = nodes.new("ShaderNodeTexCoord")
    # distance from centre -> burnt edge
    sep = nodes.new("ShaderNodeSeparateXYZ"); links.new(tc.outputs["Object"], sep.inputs[0])
    ax = nodes.new("ShaderNodeMath"); ax.operation = 'ABSOLUTE'; links.new(sep.outputs[0], ax.inputs[0])
    ay = nodes.new("ShaderNodeMath"); ay.operation = 'ABSOLUTE'; links.new(sep.outputs[1], ay.inputs[0])
    mx = nodes.new("ShaderNodeMath"); mx.operation = 'MAXIMUM'; links.new(ax.outputs[0], mx.inputs[0]); links.new(ay.outputs[0], mx.inputs[1])
    noise = nodes.new("ShaderNodeTexNoise"); noise.inputs["Scale"].default_value = 4.0; noise.inputs["Detail"].default_value = 3.0
    links.new(tc.outputs["Object"], noise.inputs["Vector"])
    f = nodes.new("ShaderNodeMath"); f.operation = 'MULTIPLY_ADD'; f.inputs[1].default_value = 0.08
    links.new(noise.outputs["Fac"], f.inputs[0]); links.new(mx.outputs[0], f.inputs[2])
    c = ramp(nodes, links, f.outputs[0], [(0.55, '#f6e7c4'), (0.72, '#e2c995'), (0.80, '#b98a55')])
    links.new(c, bsdf.inputs["Base Color"]); bsdf.inputs["Roughness"].default_value = 0.85
    return m

M_WOOD_H = wood_material("wood_purple_h", True, '#33224a', '#5e3f7e', '#8f6cae')
M_WOOD_V = wood_material("wood_purple_v", False, '#33224a', '#5e3f7e', '#8f6cae')
M_IRON = flat_material("iron_cap", '#4a3d5c', rough=0.35, metal=0.85, edge_light='#b7a8d0')
M_GOLD = flat_material("gold", '#f8c840', rough=0.22, metal=1.0, edge_light='#fff3b0', emission='#c98418')
M_VINE = flat_material("vine", '#4f9a3a', rough=0.5, edge_light='#8fd05a', coat=0.2)
M_LEAF = flat_material("leaf", '#5fae3e', rough=0.4, edge_light='#a6e070', coat=0.3)
M_PETAL = flat_material("petal", '#fff6f0', rough=0.45, edge_light='#ffffff')
M_PISTIL = flat_material("pistil", '#ffd34d', rough=0.4, emission='#ffb000')
M_PARCH = parchment_material()

# ---------- geometry ----------
def bevelled_box(name, size, loc, mat, bevel=0.045, segs=4, rot_z=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
    o = bpy.context.active_object; o.name = name; o.scale = size; o.rotation_euler.z = rot_z
    bpy.ops.object.transform_apply(scale=True)
    b = o.modifiers.new("bevel", 'BEVEL'); b.width = bevel; b.segments = segs; b.limit_method = 'ANGLE'
    o.data.materials.append(mat)
    bpy.ops.object.shade_smooth()
    return o

# Planks: top/bottom run past the side posts (like refs 05/06), side posts between.
bevelled_box("plank_top", (2 * H + 0.10, W, T), (0, H - W / 2, T / 2), M_WOOD_H, rot_z=0.006)
bevelled_box("plank_bot", (2 * H + 0.10, W, T), (0, -H + W / 2, T / 2), M_WOOD_H, rot_z=-0.004)
bevelled_box("post_l", (W * 0.9, 2 * H - 2 * W + 0.02, T * 0.9), (-H + W * 0.5, 0, T * 0.45), M_WOOD_V)
bevelled_box("post_r", (W * 0.9, 2 * H - 2 * W + 0.02, T * 0.9), (H - W * 0.5, 0, T * 0.45), M_WOOD_V)
# Inner dark bevel lip (reads as the inset edge between frame and panel)
for nm, sz, lc in (("lip_t", (2 * H - 2 * W + 0.06, 0.05, 0.05), (0, H - W - 0.01, 0.02)),
                   ("lip_b", (2 * H - 2 * W + 0.06, 0.05, 0.05), (0, -H + W + 0.01, 0.02)),
                   ("lip_l", (0.05, 2 * H - 2 * W, 0.05), (-H + W + 0.01, 0, 0.02)),
                   ("lip_r", (0.05, 2 * H - 2 * W, 0.05), (H - W - 0.01, 0, 0.02))):
    bevelled_box(nm, sz, lc, flat_material("lip", '#2e1f40', rough=0.7), bevel=0.02, segs=2)

# Parchment panel behind
bpy.ops.mesh.primitive_plane_add(size=1.0, location=(0, 0, -0.01))
p = bpy.context.active_object; p.scale = (2 * H - 2 * W + 0.1, 2 * H - 2 * W + 0.1, 1); p.data.materials.append(M_PARCH)

def star_mesh(name, r_out, r_in, depth, loc, mat):
    bm = bmesh.new(); vs = []
    for i in range(10):
        a = math.pi / 2 + i * math.pi / 5; r = r_out if i % 2 == 0 else r_in
        vs.append(bm.verts.new((math.cos(a) * r, math.sin(a) * r, 0)))
    f = bm.faces.new(vs)
    ext = bmesh.ops.extrude_face_region(bm, geom=[f])
    for v in [e for e in ext["geom"] if isinstance(e, bmesh.types.BMVert)]: v.co.z += depth
    me = bpy.data.meshes.new(name); bm.to_mesh(me); bm.free()
    o = bpy.data.objects.new(name, me); bpy.context.collection.objects.link(o); o.location = loc
    b = o.modifiers.new("bevel", 'BEVEL'); b.width = depth * 0.45; b.segments = 3
    o.data.materials.append(mat)
    for poly in me.polygons: poly.use_smooth = True
    return o

# Metal corner caps with a gold star and gold rivets
for sx in (-1, 1):
    for sy in (-1, 1):
        cx, cy = sx * (H - W / 2), sy * (H - W / 2)
        bevelled_box("cap", (W * 1.05, W * 1.05, 0.05), (cx, cy, T + 0.02), M_IRON, bevel=0.03, segs=3)
        star_mesh("star", 0.12, 0.055, 0.05, (cx, cy, T + 0.045), M_GOLD)
        for rx, ry in ((-1, -1), (-1, 1), (1, -1), (1, 1)):
            bpy.ops.mesh.primitive_uv_sphere_add(radius=0.022, location=(cx + rx * W * 0.4, cy + ry * W * 0.4, T + 0.045))
            bpy.context.active_object.data.materials.append(M_GOLD); bpy.ops.object.shade_smooth()

# ---------- vines ----------
def vine(points, radius=0.024):
    cu = bpy.data.curves.new("vine", 'CURVE'); cu.dimensions = '3D'
    cu.bevel_depth = radius; cu.bevel_resolution = 3; cu.use_fill_caps = True
    sp = cu.splines.new('NURBS'); sp.points.add(len(points) - 1)
    for i, pnt in enumerate(points): sp.points[i].co = (*pnt, 1.0)
    sp.order_u = 4; sp.use_endpoint_u = True
    # taper toward the tip
    for i, pt in enumerate(sp.points): pt.radius = 1.4 - 0.9 * i / (len(points) - 1)
    o = bpy.data.objects.new("vine", cu); bpy.context.collection.objects.link(o)
    o.data.materials.append(M_VINE)
    return o, points

def leaf(loc, angle, size=0.095):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=1.0, location=loc)
    o = bpy.context.active_object; o.scale = (size, size * 0.45, size * 0.12)
    o.rotation_euler = (0.35 * random.uniform(-1, 1), 0.4, angle)
    o.data.materials.append(M_LEAF); bpy.ops.object.shade_smooth()
    # pointed tip: simple deform taper gives a leaf shape from an ellipsoid
    d = o.modifiers.new("taper", 'SIMPLE_DEFORM'); d.deform_method = 'TAPER'; d.factor = 0.9; d.deform_axis = 'X'

def blossom(loc, r=0.035):
    for i in range(5):
        a = i * 2 * math.pi / 5
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, radius=1.0,
            location=(loc[0] + math.cos(a) * r, loc[1] + math.sin(a) * r, loc[2]))
        o = bpy.context.active_object; o.scale = (r * 0.95, r * 0.6, r * 0.25); o.rotation_euler.z = a
        o.data.materials.append(M_PETAL); bpy.ops.object.shade_smooth()
    bpy.ops.mesh.primitive_uv_sphere_add(radius=r * 0.45, location=(loc[0], loc[1], loc[2] + r * 0.2))
    bpy.context.active_object.data.materials.append(M_PISTIL); bpy.ops.object.shade_smooth()

def corner_vine(sx, sy):
    # runs along the top/bottom plank, wraps the corner cap, then down/up the side post.
    pts = []
    n = 14
    for i in range(n):
        t = i / (n - 1)
        if t < 0.5:   # along horizontal plank, from inside toward the corner
            u = t / 0.5
            x = sx * (0.52 + 0.45 * u); y = sy * (H - W / 2 + 0.11 * math.sin(u * 9.0))
        else:         # down the post
            u = (t - 0.5) / 0.5
            x = sx * (H - W / 2 + 0.11 * math.sin(u * 8.0 + 1.0)); y = sy * (H - W * 0.4 - 0.45 * u)
        z = T + 0.045 + 0.012 * math.sin(t * 20.0)   # rides on the plank surface
        pts.append((x, y, z))
    vine(pts)
    for i in range(1, n - 1):
        x, y, z = pts[i]
        ang = math.atan2(pts[i + 1][1] - pts[i - 1][1], pts[i + 1][0] - pts[i - 1][0])
        side = 1 if i % 2 == 0 else -1
        leaf((x + math.cos(ang + side * 1.57) * 0.06, y + math.sin(ang + side * 1.57) * 0.06, z + 0.02), ang + side * 0.9)
    blossom((pts[3][0], pts[3][1] + sy * 0.05, T + 0.08))
    blossom((pts[10][0] - sx * 0.05, pts[10][1], T + 0.08), 0.03)

if VARIANT == "panel":
    corner_vine(-1, 1)
    corner_vine(1, -1)
# small extra sprig on the other two corners so all four corners read decorated
for sx, sy in (((1, 1), (-1, -1)) if VARIANT == "panel" else ((-1, 1),)):
    blossom((sx * (H - W * 1.1), sy * (H - W * 0.5), T + 0.08), 0.03)
    leaf((sx * (H - W * 1.45), sy * (H - W * 0.45), T + 0.06), 0.4 * sx)

# ---------- light rig (shared UI rig: see design/art/style-techniques.md §2) ----------
def area(name, loc, energy, color, size, target=(0, 0, 0)):
    ld = bpy.data.lights.new(name, 'AREA'); ld.energy = energy; ld.color = color; ld.size = size
    o = bpy.data.objects.new(name, ld); bpy.context.collection.objects.link(o); o.location = loc
    d = Vector(target) - Vector(loc); o.rotation_euler = d.to_track_quat('-Z', 'Y').to_euler()
area("key_warm", (-2.5, 3.0, 4.0), 520, (1.0, 0.90, 0.76), 3.0)
area("fill_cool", (3.0, -1.0, 3.0), 140, (0.72, 0.80, 1.0), 4.0)
area("rim_top", (0.0, 4.0, 1.0), 160, (1.0, 0.95, 0.85), 2.0)
w = bpy.data.worlds.new("w"); sc.world = w
try: w.use_nodes = True
except Exception: pass
w.node_tree.nodes["Background"].inputs[0].default_value = hexc('#e8dcff'); w.node_tree.nodes["Background"].inputs[1].default_value = 0.25

cam_d = bpy.data.cameras.new("cam"); cam_d.type = 'ORTHO'; cam_d.ortho_scale = ORTHO
cam = bpy.data.objects.new("cam", cam_d); bpy.context.collection.objects.link(cam)
cam.location = (0, 0, 6); sc.camera = cam

sc.render.engine = 'CYCLES'; sc.cycles.device = 'CPU'; sc.cycles.samples = 48
sc.cycles.use_denoising = True
sc.render.film_transparent = True
sc.render.resolution_x = sc.render.resolution_y = RES
sc.render.image_settings.file_format = 'PNG'; sc.render.image_settings.color_mode = 'RGBA'
sc.view_settings.view_transform = 'Standard'   # keeps palette hexes predictable (AgX desaturates)
sc.view_settings.look = 'None'
NAME = "frame_purple_vine" if VARIANT == "panel" else "frame_purple_chip"
path = os.path.join(OUT, NAME + ".png"); sc.render.filepath = path
bpy.ops.render.render(write_still=True)

# nine-patch margins (pixels, at 2x). Corner patch must contain caps, vines and blossoms.
px_per_unit = RES / ORTHO
margin = int(round((ORTHO / 2 - (H - W - (0.22 if VARIANT == 'panel' else 0.06))) * px_per_unit))
json.dump({"texture": NAME + ".png", "scale": 2, "margin_left": margin, "margin_top": margin,
           "margin_right": margin, "margin_bottom": margin, "axis_stretch": "stretch",
           "content_inset_px": int(round((ORTHO / 2 - (H - W)) * px_per_unit))},
          open(os.path.join(OUT, NAME + ".json"), "w"), indent=1)
print("WROTE", path, "margin", margin)
