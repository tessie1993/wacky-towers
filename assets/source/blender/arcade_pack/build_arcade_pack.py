"""Original Wacky Towers arcade dioramas, built with Blender 4.5+.

Run from the repo with: blender --background --python this_file.py
All geometry, materials and renders are generated locally; no external assets.
Blender Z-up -> glTF/Godot Y-up. Playable centre: [-2.5,2.5]^2, top = 0.
"""
import bpy
import bmesh
import math
import random
import json
import hashlib
import sys
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT / "assets/source/blender/arcade_pack"
MODELS = ROOT / "assets/models/arcade_pack"
EVIDENCE = ROOT / "production/qa/evidence/arcade_pack"
for folder in (SOURCE, MODELS, EVIDENCE):
    folder.mkdir(parents=True, exist_ok=True)
random.seed(731)
SKIP_RENDER = "--skip-render" in sys.argv
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.preferences.filepaths.save_version=0

def mat(name, color, roughness=0.94):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    p = m.node_tree.nodes.get("Principled BSDF")
    p.inputs["Base Color"].default_value = (*color, 1)
    p.inputs["Roughness"].default_value = roughness
    p.inputs["Metallic"].default_value = 0
    p.inputs["Specular IOR Level"].default_value = 0.12
    m.diffuse_color = (*color, 1)
    return m

P = {
    "ink": mat("arcade_ink_matte", (0.13, 0.115, 0.15)),
    "soil": mat("meadow_earth", (0.34, 0.26, 0.235)),
    "soil_light": mat("meadow_ochre_strata", (0.43, 0.345, 0.29)),
    "soil_dark": mat("meadow_earth_shadow", (0.27, 0.235, 0.22)),
    "grass": mat("meadow_sage_gouache", (0.44, 0.53, 0.38)),
    "grass_light": mat("meadow_sage_paint", (0.49, 0.565, 0.415)),
    "path": mat("meadow_clay_path", (0.66, 0.58, 0.455)),
    "wood": mat("warm_painted_wood", (0.46, 0.355, 0.28)),
    "wood_light": mat("warm_wood_worn_edge", (0.56, 0.44, 0.33)),
    "cream": mat("linen_paint", (0.81, 0.77, 0.64)),
    "sage": mat("weathered_sage_paint", (0.47, 0.56, 0.46)),
    "leaf": mat("meadow_leaf_shadow", (0.31, 0.41, 0.30)),
    "slate": mat("clockwork_walnut_shadow", (0.27, 0.235, 0.245)),
    "brass": mat("clockwork_painted_brass", (0.59, 0.49, 0.32)),
    "brass_light": mat("clockwork_worn_brass", (0.66, 0.565, 0.405)),
    "clock_stone": mat("clockwork_putty_courtyard", (0.59, 0.555, 0.49)),
    "clock_dark": mat("clockwork_stone_strata", (0.365, 0.345, 0.335)),
    "clock_mid": mat("clockwork_stone_mid", (0.445, 0.415, 0.37)),
    "celestial": mat("celestial_indigo_stone", (0.265, 0.255, 0.385)),
    "celestial_mid": mat("celestial_dusky_lavender", (0.355, 0.33, 0.445)),
    "marble": mat("celestial_moon_marble", (0.68, 0.65, 0.73)),
    "moon": mat("celestial_worn_cream", (0.77, 0.735, 0.735)),
    "glass": mat("celestial_opaque_lens", (0.39, 0.43, 0.48)),
}

def collection(name):
    c = bpy.data.collections.new(name)
    bpy.context.scene.collection.children.link(c)
    return c

def move(obj, c):
    for prev in list(obj.users_collection):
        prev.objects.unlink(obj)
    c.objects.link(obj)
    return obj

def finish(obj, name, material, c, smooth=False, bevel=0):
    obj.name = name
    move(obj, c)
    if material:
        obj.data.materials.append(material)
    if smooth:
        for p in obj.data.polygons:
            p.use_smooth = True
    if bevel:
        mod = obj.modifiers.new("soft worn edge", "BEVEL")
        mod.width = bevel
        mod.segments = 2
    return obj

def cube(name, loc, scale, material, c, bevel=0.06):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object
    o.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(o, name, material, c, bevel=bevel)

def cylinder(name, loc, radius, depth, material, c, vertices=16):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc)
    return finish(bpy.context.object, name, material, c, smooth=True, bevel=0.02)

def beam(name, a, b, radius, material, c, vertices=10):
    a, b = Vector(a), Vector(b)
    o = cylinder(name, (a + b) / 2, radius, (b - a).length, material, c, vertices)
    o.rotation_euler = (b - a).to_track_quat("Z", "Y").to_euler()
    return o

def ico(name, loc, scale, material, c, subdivisions=1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1, location=loc)
    o = bpy.context.object
    o.scale = scale
    return finish(o, name, material, c)

def mesh(name, verts, faces, material, c):
    d = bpy.data.meshes.new(name)
    d.from_pydata(verts, [], faces)
    d.update()
    o = bpy.data.objects.new(name, d)
    c.objects.link(o)
    if material:
        d.materials.append(material)
    return o

def torus(name, loc, major, minor, material, c, rotation=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=32, minor_segments=8, location=loc, major_radius=major, minor_radius=minor, rotation=rotation)
    return finish(bpy.context.object, name, material, c, smooth=True)

def curve(name, points, thickness, material, c):
    d = bpy.data.curves.new(name, "CURVE")
    d.dimensions = "3D"
    d.resolution_u = 12
    d.bevel_depth = thickness
    d.bevel_resolution = 2
    s = d.splines.new("BEZIER")
    s.bezier_points.add(len(points)-1)
    for p, co in zip(s.bezier_points, points):
        p.co = co
        p.handle_left_type = "AUTO"
        p.handle_right_type = "AUTO"
    o = bpy.data.objects.new(name, d)
    c.objects.link(o)
    d.materials.append(material)
    return o

def island(c, surface, strata):
    n = 40
    jitter = [random.uniform(-0.11, 0.11) for i in range(n)]
    rings = [(4.42,0), (4.51,-0.2), (4.22,-0.62), (3.64,-1.03), (2.82,-1.58), (1.32,-2.02)]
    verts=[]
    for ri,(r,z) in enumerate(rings):
        for i in range(n):
            a = math.tau*i/n
            rr = r+jitter[i]*(1+ri*0.25)
            verts.append((rr*math.cos(a),rr*math.sin(a),z))
    verts.append((0,0,-2.32))
    faces=[tuple(range(n))]
    for ri in range(len(rings)-1):
        for i in range(n):
            faces.append((ri*n+i,ri*n+(i+1)%n,(ri+1)*n+(i+1)%n,(ri+1)*n+i))
    for i in range(n):
        faces.append(((len(rings)-1)*n+i, (len(rings)-1)*n+(i+1)%n, len(verts)-1))
    o = mesh("island_flat_top_zero",verts,faces,surface,c)
    for material in strata:
        o.data.materials.append(material)
    for p in o.data.polygons[1:]:
        band=(p.index-1)//n
        p.material_index=1+(band+random.randint(0,1))%len(strata)
    # A low, organic perimeter line keeps pale bodies distinct from the sky.
    pts=[]
    for i in range(n+1):
        a=math.tau*(i%n)/n
        rr=4.43+jitter[i%n]
        pts.append((rr*math.cos(a),rr*math.sin(a),-0.09))
    curve("island_dark_neutral_rim",pts,0.035,P["ink"],c)
    return o

def leaf(name, base, tip, width, material, c):
    a,b=Vector(base),Vector(tip)
    v=b-a
    side=Vector((-v.y,v.x,0)).normalized()*width
    mid=a+v*0.54
    return mesh(name,[a, mid+side, b, mid-side, mid+Vector((0,0,.055))],[(0,1,4),(1,2,4),(2,3,4),(3,0,4)],material,c)

def gear(name, centre, radius, teeth, thickness, material, c, vertical=False):
    # Flat toothed silhouette, with a real inner hole rather than a decal.
    n=teeth*4
    verts=[]
    for z in (-thickness/2, thickness/2):
        for ring in (0,1):
            for i in range(n):
                a=math.tau*i/n
                r=(radius*(1 if i%4 in (1,2) else .84)) if ring==0 else radius*.29
                verts.append((r*math.cos(a),r*math.sin(a),z))
    faces=[]
    for i in range(n):
        j=(i+1)%n
        faces.extend([(i,j,n+j,n+i), (2*n+i,3*n+i,3*n+j,2*n+j), (i,2*n+i,2*n+j,j), (n+i,n+j,3*n+j,3*n+i)])
    o=mesh(name,verts,faces,material,c)
    o.location=centre
    if vertical:
        o.rotation_euler.x=math.pi/2
    return o

def postbox(c):
    x,y=-4.0,1.12
    beam("mailbox_wood_post",(x,y,-.05),(x,y,.95),.105,P["wood"],c)
    # Rounded letterbox silhouette; avoiding a toy-block cube.
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, location=(x,y,1.09))
    o=bpy.context.object
    o.scale=(.43,.23,.32)
    finish(o,"meadow_round_postbox",P["sage"],c,smooth=True)
    cube("mailbox_letter_slot",(x,y-.227,1.09),(.39,.018,.043),P["ink"],c,.01)
    cube("mailbox_folded_letter",(x,y-.25,1.02),(.30,.025,.16),P["cream"],c,.02)
    beam("mailbox_letter_fold_left",(x-.14,y-.268,1.08),(x,y-.268,1.0),.009,P["wood"],c)
    beam("mailbox_letter_fold_right",(x+.14,y-.268,1.08),(x,y-.268,1.0),.009,P["wood"],c)
    beam("mailbox_flag_stem",(x-.44,y,.97),(x-.44,y,1.4),.025,P["wood"],c)
    mesh("mailbox_flag",[(x-.44,y,1.4),(x-.68,y,1.35),(x-.44,y,1.22)],[(0,1,2)],P["cream"],c)

def pennant(c):
    x,y=3.72,.9
    beam("wind_pennant_pole",(x,y,-.05),(x,y,1.55),.055,P["wood"],c)
    ico("wind_pennant_cap",(x,y,1.58),(.09,.09,.09),P["cream"],c)
    verts=[(x,y,1.45),(x+.24,y+.07,1.43),(x+.66,y+.03,1.30),(x+.30,y-.045,1.19),(x,y,1.17)]
    mesh("wind_linen_pennant",verts,[(0,1,4),(1,3,4),(1,2,3)],P["cream"],c)
    for yoff in (-.11,.11):
        beam("wind_sock_wood_brace",(x-.14,y+yoff,0),(x+.14,y+yoff,0),.04,P["wood_light"],c)

def footbridge(c):
    # A complete tiny repaired bridge sits on the back perimeter; never over cells.
    y=3.91
    for i in range(7):
        x=-1.12+i*.34
        z=.07+.1*math.sin(math.pi*i/6)
        cube("meadow_bridge_worn_plank_%02d"%i,(x,y,z-.055),(.30,.68,.09),P["wood_light"] if i%2 else P["wood"],c,.022)
    for x in (-1.24,1.05):
        for yy in (3.57,4.25):
            beam("bridge_rope_post",(x,yy,-.05),(x,yy,.54),.052,P["wood"],c)
    for yy in (3.57,4.25):
        curve("bridge_linen_rope",[(-1.24,yy,.50),(-.16,yy,.39),(1.05,yy,.50)],.024,P["cream"],c)

def meadow():
    c=collection("env_meadow_arcade")
    island(c,P["grass"],[P["soil"],P["soil_light"],P["soil_dark"]])
    # Broad, flat paint patches at the rim. The entire 5x5 central square stays empty.
    for i in range(12):
        a=math.tau*i/12+.12
        x,y=3.99*math.cos(a),3.99*math.sin(a)
        ico("meadow_soft_rim_paint_%02d"%i,(x,y,-.015),(.37,.23,.035),P["grass_light"],c,2)
    postbox(c);pennant(c);footbridge(c)
    for i,(x,y) in enumerate([(-3.45,-1.35),(3.55,-1.1),(-1.5,-3.56),(1.25,-3.6)]):
        for j in range(3):
            a=j*2.1+i
            leaf("meadow_rim_leaf",(x,y,.01),(x+.24*math.cos(a),y+.24*math.sin(a),.14),.085,P["leaf"],c)
    for x,y,z in [(-1.8,2.9,-1.18),(2.6,1.6,-1.03),(-2.1,-2.35,-1.00)]:
        curve("meadow_hanging_root",[(x,y,z),(x*.88,y*.92,z-.38),(x*.76,y*.84,z-.58)],.065,P["wood"],c)
        leaf("meadow_root_leaf",(x*.84,y*.89,z-.28),(x*.84+.36,y*.89,z-.35),.13,P["leaf"],c)
    return c

def clockwork():
    c=collection("env_clockwork_arcade")
    island(c,P["clock_stone"],[P["clock_dark"],P["clock_mid"],P["slate"]])
    torus("clockwork_perimeter_inlay",(0,0,-.005),4.0,.032,P["brass"],c)
    # Two rounded timbers and an arch support the counterweight; all outside play.
    y=3.75
    for x in (-1.27,1.27):
        beam("gate_rounded_support",(x,y,-.1),(x,y,1.0),.13,P["wood"],c)
        cylinder("gate_support_round_foot",(x,y,.03),.22,.14,P["brass"],c)
        gear("gate_support_rosette",(x,y-.13,.58),.24,8,.07,P["brass"],c,True)
    curve("gate_arch_lintel",[(-1.27,y,.96),(-.64,y,1.18),(0,y,1.26),(.64,y,1.18),(1.27,y,.96)],.13,P["wood_light"],c)
    gear("clockwork_story_counterweight",(0,3.78,.77),.45,12,.15,P["brass_light"],c,True)
    beam("clockwork_axle",(0,3.52,.77),(0,4.12,.77),.085,P["slate"],c)
    # Crank placed on a side rim so its function reads from the game camera.
    x,y=-3.98,.6
    beam("crank_wood_stand",(x,y,-.03),(x,y,.48),.12,P["wood"],c)
    gear("clockwork_handwheel",(x,y-.12,.58),.43,10,.10,P["brass"],c,True)
    beam("handwheel_handle",(x+.22,y-.13,.78),(x+.22,y-.38,.78),.065,P["wood_light"],c)
    # A low repair scroll with a cog sketch supports Tock's wordless repair story.
    x,y=3.82,-1.35
    mesh("clockwork_repair_scroll",[(x-.27,y-.43,.055),(x+.27,y-.43,.055),(x+.27,y+.43,.055),(x-.27,y+.43,.055)],[(0,1,2,3)],P["cream"],c)
    for yy in (y-.43,y+.43):
        beam("repair_scroll_rolled_end",(x-.3,yy,.062),(x+.3,yy,.062),.055,P["cream"],c)
    gear("repair_scroll_cog_diagram",(x,y,.067),.2,8,.004,P["clock_mid"],c)
    for yy in (y-.31,y+.31):
        beam("repair_scroll_ink_rule",(x-.16,yy,.062),(x+.16,yy,.062),.006,P["clock_mid"],c,8)
    for i in range(5):
        a=math.tau*i/5+.24
        x,y=3.93*math.cos(a),3.93*math.sin(a)
        cylinder("clockwork_rim_rivet",(x,y,.035),.095,.05,P["brass"],c,12)
    # Underside cogs and straps carry the clockwork story below the eye order.
    for x,y,z,r in [(-2.2,-2.6,-1.00,.75),(2.35,-2.55,-.80,.58),(.2,-3.3,-.58,.36)]:
        gear("clockwork_underside_cog",(x,y,z),r,12,.15,P["clock_mid"],c,True)
    for x in (-1.1,1.1):
        curve("clockwork_underbody_strap",[(x,-3.6,-.34),(x,-2.6,-1.26),(x,0,-2.15)],.055,P["brass"],c)
    return c

def telescope(c):
    x,y=-3.97,.8
    for a in (0,math.tau/3,math.tau*2/3):
        beam("telescope_tripod_leg",(x+.36*math.cos(a),y+.36*math.sin(a),.03),(x,y,.76),.055,P["wood"],c)
    cylinder("telescope_mount",(x,y,.8),.15,.13,P["brass"],c)
    start=(x,y-.36,.9);end=(x,y+.44,1.25)
    beam("celestial_telescope_body",start,end,.17,P["moon"],c,20)
    v=Vector(end)-Vector(start)
    ring=torus("telescope_lens_rim",end,.173,.038,P["brass"],c)
    ring.rotation_euler=v.to_track_quat("Z","Y").to_euler()
    lens=cylinder("telescope_opaque_lens",end,.15,.025,P["glass"],c,20)
    lens.rotation_euler=v.to_track_quat("Z","Y").to_euler()
    beam("telescope_eyepiece",(x,y-.47,.85),(x,y-.34,.91),.073,P["brass"],c)

def star(name,loc,radius,material,c):
    verts=[]
    for y in (-.035,.035):
        for i in range(10):
            a=math.pi/2+math.tau*i/10
            r=radius if i%2==0 else radius*.43
            verts.append((loc[0]+r*math.cos(a),loc[1]+y,loc[2]+r*math.sin(a)))
    faces=[tuple(range(9,-1,-1)),tuple(range(10,20))]
    for i in range(10):
        faces.append((i,(i+1)%10,(i+1)%10+10,i+10))
    return mesh(name,verts,faces,material,c)

def celestial():
    c=collection("env_celestial_arcade")
    island(c,P["marble"],[P["celestial"],P["celestial_mid"],P["celestial"]])
    torus("observatory_matte_circle_inlay",(0,0,-.005),3.91,.027,P["brass"],c)
    telescope(c)
    x,y=3.8,.78
    beam("observatory_star_lamp_stem",(x,y,-.05),(x,y,1.36),.055,P["celestial"],c)
    cylinder("observatory_star_lamp_foot",(x,y,.055),.19,.11,P["brass"],c)
    curve("observatory_star_lamp_hook",[(x,y,1.27),(x,y,1.5),(x,y-.25,1.57),(x,y-.39,1.4)],.047,P["brass"],c)
    star("observatory_unlit_star_lantern",(x,y-.39,1.22),.21,P["moon"],c)
    # An old, quiet astrolabe behind the board suggests the shadow alignment story.
    y=3.75
    for x in (-.66,.66):
        beam("astrolabe_low_wood_support",(x,y,.03),(x,y,.36),.07,P["wood"],c)
    torus("astrolabe_meridian_ring",(0,y,.59),.65,.042,P["brass"],c,(math.pi/2,0,0))
    beam("astrolabe_horizontal_axis",(-.72,y,.59),(.72,y,.59),.022,P["brass"],c)
    beam("astrolabe_sight_needle",(-.37,y-.02,.3),(.37,y-.02,.89),.031,P["celestial"],c)
    ico("astrolabe_moon_centre",(0,y,.59),(.115,.09,.115),P["moon"],c,2)
    for i in range(8):
        a=math.tau*i/8
        x,y=4.03*math.cos(a),4.03*math.sin(a)
        # Low carved star marks are deliberately lower contrast than reward gold.
        ico("observatory_rim_moon_inlay",(x,y,.006),(.07,.07,.014),P["moon"],c)
    # Marble shards hanging under the dome-like floating island.
    for x,y,z,s in [(-2.6,-1.8,-1.0,.48),(2.2,-2.1,-1.06,.42),(.4,-2.75,-1.0,.35)]:
        bpy.ops.mesh.primitive_cone_add(vertices=5, radius1=s*.2, radius2=s*.55, depth=s*1.55, location=(x,y,z-.35))
        finish(bpy.context.object,"observatory_stone_pendant",P["celestial_mid"],c)
    return c

COLLECTIONS=[meadow(),clockwork(),celestial()]

def realise(c):
    # Convert curves and apply edge modifiers/transforms. Origin stays at top-centre.
    bpy.ops.object.select_all(action="DESELECT")
    for o in list(c.objects):
        if o.type in {"MESH","CURVE"}:
            o.select_set(True)
    bpy.context.view_layer.objects.active=next(o for o in c.objects if o.type=="MESH")
    bpy.ops.object.convert(target="MESH")
    bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
    for o in c.objects:
        if o.type=="MESH":
            o.data.validate()
            bm=bmesh.new()
            bm.from_mesh(o.data)
            bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
            bm.to_mesh(o.data)
            bm.free()
            o.data.update()

manifest={
    "schema":1,
    "author":"Wacky Towers game suite art team",
    "blender_version":bpy.app.version_string,
    "blender_build_hash":bpy.app.build_hash.decode(),
    "units":"metres; 1 unit = 1 grid cell",
    "godot_axes":"Y-up; flat play surface Y=0; X/Z centre square [-2.5,2.5]",
    "play_area":{"min_x":-2.5,"max_x":2.5,"min_z":-2.5,"max_z":2.5,"surface_y":0.0},
    "collision":"decorative models only; gameplay owns the grid and collision",
    "license":"MIT (repository LICENSE); original geometry and flat matte materials; no external assets",
    "assets":[]
}
for c in COLLECTIONS:
    realise(c)
    bpy.ops.object.select_all(action="DESELECT")
    bounds=[]
    tris=0
    centre_raised_vertices=0
    primary_margin_raised_vertices=0
    primary_names=("mailbox_", "meadow_round_postbox", "wind_", "meadow_bridge_", "bridge_", "gate_", "clockwork_story_counterweight", "clockwork_axle", "crank_", "clockwork_handwheel", "handwheel_", "clockwork_repair_", "repair_scroll_", "celestial_telescope", "telescope_", "observatory_star_", "observatory_unlit_", "astrolabe_")
    for o in c.objects:
        o.select_set(True)
        if o.type=="MESH":
            o.data.calc_loop_triangles()
            tris+=len(o.data.loop_triangles)
            bounds.extend(o.matrix_world@Vector(v) for v in o.bound_box)
            for vert in o.data.vertices:
                v=o.matrix_world@vert.co
                if abs(v.x)<2.5 and abs(v.y)<2.5 and v.z>0.015:
                    centre_raised_vertices+=1
                if o.name.startswith(primary_names) and max(abs(v.x),abs(v.y))<3.5 and v.z>0.015:
                    primary_margin_raised_vertices+=1
    filepath=MODELS/(c.name+".glb")
    bpy.ops.export_scene.gltf(filepath=str(filepath),export_format="GLB",use_selection=True,export_yup=True,export_apply=True,export_materials="EXPORT",export_cameras=False,export_lights=False)
    bmin=[min(v[i] for v in bounds) for i in range(3)]
    bmax=[max(v[i] for v in bounds) for i in range(3)]
    # Blender X,Y,Z -> glTF/Godot X,Z,-Y.
    godot_min=[bmin[0],bmin[2],-bmax[1]]
    godot_max=[bmax[0],bmax[2],-bmin[1]]
    assert centre_raised_vertices==0, "Decoration intersects the 5x5 play area"
    assert primary_margin_raised_vertices==0, "Primary story prop enters the one-cell quiet margin"
    manifest["assets"].append({"name":c.name,"path":str(filepath.relative_to(ROOT)),"triangles":tris,"mesh_objects":len(c.objects),"godot_bounds_min":godot_min,"godot_bounds_max":godot_max,"raised_vertices_in_play_area":centre_raised_vertices,"primary_story_prop_vertices_in_quiet_margin":primary_margin_raised_vertices,"bytes":filepath.stat().st_size,"sha256":hashlib.sha256(filepath.read_bytes()).hexdigest()})

# Non-exported look-check setup.
scene=bpy.context.scene
scene.render.engine="CYCLES"
scene.cycles.device="CPU"
scene.cycles.samples=32
scene.cycles.use_denoising=True
scene.render.resolution_x=720
scene.render.resolution_y=720
scene.render.resolution_percentage=100
scene.render.image_settings.file_format="PNG"
scene.render.film_transparent=False
scene.world=bpy.data.worlds.new("quiet_arcade_sky")
scene.world.use_nodes=True
scene.world.node_tree.nodes["Background"].inputs["Color"].default_value=(0.64,.68,.77,1)
scene.world.node_tree.nodes["Background"].inputs["Strength"].default_value=.65
scene.view_settings.view_transform="AgX"
scene.view_settings.look="AgX - Medium High Contrast"
scene.view_settings.exposure=0
scene.view_settings.gamma=1
preview=collection("PREVIEW_NOT_EXPORTED")
floor=cube("lookcheck_ground",(0,0,-2.7),(200,200,.1),mat("lookcheck_backdrop",(.67,.69,.75)),preview,0)
for name,loc,power,size in [("soft_key",(-5,-6,10),1000,7),("cool_fill",(6,3,6),500,6)]:
    d=bpy.data.lights.new(name,"AREA")
    d.energy=power
    d.shape="DISK"
    d.size=size
    o=bpy.data.objects.new(name,d)
    preview.objects.link(o)
    o.location=loc
    o.rotation_euler=(Vector((0,0,-.5))-o.location).to_track_quat("-Z","Y").to_euler()
cam_d=bpy.data.cameras.new("lookcheck_camera")
cam=bpy.data.objects.new("lookcheck_camera",cam_d)
preview.objects.link(cam)
scene.camera=cam
cam_d.type="ORTHO"
cam_d.ortho_scale=11.1

def view(loc):
    cam.location=loc
    cam.rotation_euler=(Vector((0,0,-.4))-cam.location).to_track_quat("-Z","Y").to_euler()

SOURCE.joinpath("manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
view((9,-12,10))
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/"arcade_pack.blend"))
for c in COLLECTIONS:
    for other in COLLECTIONS:
        other.hide_render=other!=c
        other.hide_viewport=other!=c
    for angle,loc in [("front",(9,-12,10)),("rear",(-10,12,9)),("top",(0,-.1,15))]:
        view(loc)
        scene.render.filepath=str(EVIDENCE/("blender_"+c.name+"_"+angle+".png"))
        if not SKIP_RENDER:
            bpy.ops.render.render(write_still=True)
for other in COLLECTIONS:
    other.hide_render=other!=COLLECTIONS[0]
    other.hide_viewport=other!=COLLECTIONS[0]
view((9,-12,10))
bpy.ops.object.select_all(action="DESELECT")
SOURCE.joinpath("manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE/"arcade_pack.blend"))
(SOURCE/"arcade_pack.blend1").unlink(missing_ok=True)
print("ARCADE_PACK_COMPLETE "+json.dumps(manifest))
