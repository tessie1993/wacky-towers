"""Build the empty starter scene. Run: blender -b -P scripts/setup_scene.py"""
import bpy, os
bpy.ops.wm.read_factory_settings(use_empty=True)
s = bpy.context.scene
s.unit_settings.system = 'METRIC'
s.unit_settings.scale_length = 1.0
for name in ("EXPORT", "REF"):
    s.collection.children.link(bpy.data.collections.new(name))
ref = bpy.data.collections["REF"]
bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
cube = bpy.context.active_object
cube.name = "ref_grid_cell"
for c in cube.users_collection:
    c.objects.unlink(cube)
ref.objects.link(cube)
cube.display_type = 'WIRE'
cube.hide_render = True
here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(here, "wacky_towers.blend"), relative_remap=True)
print("saved", bpy.data.filepath)
