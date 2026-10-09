"""Review render of all pieces in Piece Set hues, gameplay-like 3/4 view.
Run: blender -b blocks.blend -P scripts/render_lineup.py"""
import bpy, os, math
HUES = {"i":"6EA4F0","o":"F5DD6A","t":"9FD65B","l":"FFB48C","s":"5DCB9E","tripod":"A78BEB",
 "screw_left":"73F07D","screw_right":"B673F0","chair":"F0BC73","twist_left":"8673F0",
 "twist_right":"D773F0","staircase":"738EF0","tall_corner":"73F096","big_tripod":"7377F0",
 "big_cube":"ECF073","mono":"D6ED93","duo":"AFED93","tri_straight":"9EED93","tri_corner":"93EDBD"}
def lin(h):
    c=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    return [x/12.92 if x<=0.04045 else ((x+0.055)/1.055)**2.4 for x in c]+[1]
s=bpy.context.scene
# Preview candy material: colour from each object's Object Color.
m=bpy.data.materials["blk_mat"]; m.use_nodes=True; nt=m.node_tree
b=next(n for n in nt.nodes if n.type=="BSDF_PRINCIPLED")
oi=nt.nodes.new("ShaderNodeObjectInfo"); nt.links.new(oi.outputs["Color"], b.inputs["Base Color"])
b.inputs["Roughness"].default_value=0.35
for k in ("Coat Weight","Clearcoat"):
    if k in b.inputs: b.inputs[k].default_value=0.6; break
for i,(k,h) in enumerate(HUES.items()):
    root=bpy.data.objects["blk_piece_"+k]; root.location=((i%7)*5.0,-(i//7)*5.5,0)
    for c in root.children: c.color=lin(h)
bpy.data.objects["blk_cube_base"].hide_render=True
bpy.ops.object.camera_add(location=(16,-30,24)); cam=bpy.context.active_object
t=bpy.data.objects.new('aim',None); s.collection.objects.link(t); t.location=(16,-5.5,0.5)
c=cam.constraints.new('TRACK_TO'); c.target=t; c.track_axis='TRACK_NEGATIVE_Z'; c.up_axis='UP_Y'
cam.data.type='ORTHO'; cam.data.ortho_scale=36; s.camera=cam
bpy.ops.object.light_add(type='SUN',rotation=(math.radians(45),math.radians(-35),math.radians(-30)))
bpy.context.active_object.data.energy=3.0
w=bpy.data.worlds.new("w"); s.world=w; w.use_nodes=True
bg=next(n for n in w.node_tree.nodes if n.type=="BACKGROUND"); bg.inputs[0].default_value=(0.35,0.38,0.55,1); bg.inputs[1].default_value=1.0
s.view_settings.view_transform='Standard'
s.render.resolution_x,s.render.resolution_y=1600,1100
s.render.filepath=os.path.join(os.path.dirname(bpy.data.filepath),"renders","probes","blocks_lineup.png")
bpy.ops.render.render(write_still=True); print("RENDER",s.render.filepath)
