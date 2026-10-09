"""Export each child collection of EXPORT as <collection name>.glb.

Run inside Blender (Scripting tab) or: blender -b wacky_towers.blend -P scripts/export_glb.py
Writes to exports/ and, if it exists, the game's assets/models/ folder.
"""
import bpy, os, shutil

GAME_MODELS_DIR = r"C:/Users/tessi/Claude/repos/wacky towers/assets/models"

root = os.path.dirname(bpy.data.filepath)
out = os.path.join(root, "exports")
os.makedirs(out, exist_ok=True)

export = bpy.data.collections.get("EXPORT")
assets = list(export.children) if export else []
for col in assets:
    bpy.ops.object.select_all(action='DESELECT')
    objs = [o for o in col.all_objects if o.type in {'MESH', 'EMPTY', 'ARMATURE'}]
    if not objs:
        continue
    for o in objs:
        o.select_set(True)
    path = os.path.join(out, col.name + ".glb")
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True,
                              export_apply=True, export_yup=True)
    if os.path.isdir(GAME_MODELS_DIR):
        shutil.copy2(path, GAME_MODELS_DIR)
    print("exported", path)
print(f"{len(assets)} asset collection(s) in EXPORT")
