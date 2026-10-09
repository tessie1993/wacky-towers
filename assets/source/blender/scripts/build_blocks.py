"""Build the block cube and the 19 piece shapes (Piece Set GDD) as GLBs.

Every piece is made of individual cubes that share one mesh, so the game can
lock, clear and remove cubes one by one. Each cube is a soft "marshmallow"
toy cube, so a groove shows between cubes and the cube count reads clearly.
Colour, motif, gloss and outline come from Godot shaders/materials.

Run: blender -b --factory-startup -P scripts/build_blocks.py -- <game_models_dir>
Saves blocks.blend and writes exports/blk_cube_base.glb + blk_piece_*.glb
(copied to <game_models_dir> when given).
"""
import bpy, os, sys, shutil

BEVEL = 0.14      # support-loop chamfer before subdivision: smaller = boxier, bigger = rounder
SUBDIV = 2        # subdivision level: smoothness of the rounding
PUFF = 0.04       # cast-to-sphere factor: face pillowing
FILL = 1.03       # cube size vs cell: >1 overlaps neighbours so a piece reads as one object

# Piece-set coordinates (x, y, z); z is up (glTF export turns it into Godot +Y).
# Pivot cube (0,0,0) sits at the mesh origin.
SHAPES = {
    "i": [(0,0,0),(1,0,0),(2,0,0),(3,0,0)],
    "o": [(0,0,0),(1,0,0),(0,1,0),(1,1,0)],
    "t": [(0,0,0),(1,0,0),(2,0,0),(1,1,0)],
    "l": [(0,0,0),(1,0,0),(2,0,0),(2,1,0)],
    "s": [(0,0,0),(1,0,0),(1,1,0),(2,1,0)],
    "tripod": [(0,0,0),(1,0,0),(0,1,0),(0,0,1)],
    "screw_left": [(0,0,0),(1,0,0),(1,1,0),(1,1,1)],
    "screw_right": [(0,0,0),(1,0,0),(1,1,0),(1,1,-1)],
    "chair": [(0,0,0),(1,0,0),(0,1,0),(0,0,1),(0,0,2)],
    "twist_left": [(0,0,0),(1,0,0),(1,1,0),(1,1,1),(2,1,1)],
    "twist_right": [(0,0,0),(1,0,0),(1,1,0),(1,1,-1),(2,1,-1)],
    "staircase": [(0,0,0),(1,0,0),(1,1,0),(1,1,1),(2,1,1),(2,2,1)],
    "tall_corner": [(0,0,0),(1,0,0),(0,1,0),(0,0,1),(0,0,2),(0,0,3)],
    "big_tripod": [(0,0,0),(1,0,0),(2,0,0),(0,1,0),(0,2,0),(0,0,1),(0,0,2)],
    "big_cube": [(x,y,z) for x in (0,1) for y in (0,1) for z in (0,1)],
    "mono": [(0,0,0)],
    "duo": [(0,0,0),(1,0,0)],
    "tri_straight": [(0,0,0),(1,0,0),(2,0,0)],
    "tri_corner": [(0,0,0),(1,0,0),(0,1,0)],
}

# Right-handed face-tile UVs (U x V = normal) so motifs are never mirrored.
UVT = {(0,1):((0,1,0),(0,0,1)), (0,-1):((0,-1,0),(0,0,1)), (1,1):((-1,0,0),(0,0,1)),
       (1,-1):((1,0,0),(0,0,1)), (2,1):((1,0,0),(0,1,0)), (2,-1):((1,0,0),(0,-1,0))}


def unit_cube():
    """Chunky toy cube: chamfer + subdivision for soft round edges and slightly
    puffed faces, rescaled to fill the 1x1x1 cell. Origin at centre."""
    bpy.ops.mesh.primitive_cube_add(size=1.0)
    ob = bpy.context.active_object
    m = ob.modifiers.new("Chamfer", 'BEVEL')
    m.width, m.segments, m.limit_method = BEVEL, 2, "NONE"
    s = ob.modifiers.new("Round", 'SUBSURF')
    s.levels = s.render_levels = SUBDIV
    c = ob.modifiers.new("Puff", 'CAST')
    c.cast_type, c.factor = 'SPHERE', PUFF
    for mod in list(ob.modifiers):
        bpy.ops.object.modifier_apply(modifier=mod.name)
    d = ob.dimensions
    for v in ob.data.vertices:
        v.co.x *= FILL / d.x; v.co.y *= FILL / d.y; v.co.z *= FILL / d.z
    ob.data.shade_smooth()
    me = ob.data
    uv = me.uv_layers[0] if me.uv_layers else me.uv_layers.new(name="UVMap")
    for p in me.polygons:
        ax = max(range(3), key=lambda i: abs(p.normal[i]))
        U, V = UVT[(ax, 1 if p.normal[ax] > 0 else -1)]
        for li in p.loop_indices:
            c = me.vertices[me.loops[li].vertex_index].co
            uv.data[li].uv = (sum(U[i]*c[i] for i in range(3)) / FILL + 0.5,
                              sum(V[i]*c[i] for i in range(3)) / FILL + 0.5)
    return ob


def build(name, cells, cube_mesh, col):
    """Piece = empty at the pivot cube + one child object per cube (shared mesh)."""
    root = bpy.data.objects.new("blk_piece_" + name, None)
    col.objects.link(root)
    for c in cells:
        ob = bpy.data.objects.new("cube_%d_%d_%d" % c, cube_mesh)
        ob.location = c
        ob.parent = root
        col.objects.link(ob)
    return root


def export(objs, path, game_dir):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        o.select_set(True)
    bpy.ops.export_scene.gltf(
        filepath=path, export_format='GLB', use_selection=True,
        export_apply=True, export_yup=True, export_texcoords=True,
        export_normals=True, export_tangents=True, export_vertex_color='NONE',
        export_materials='PLACEHOLDER', export_animations=False,
        export_skins=False, export_morph=False, export_cameras=False,
        export_lights=False)
    if game_dir:
        shutil.copy2(path, game_dir)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    game_dir = argv[0] if argv else None
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    out = os.path.join(root, "exports")
    os.makedirs(out, exist_ok=True)

    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.unit_settings.system = 'METRIC'
    export_col = bpy.data.collections.new("EXPORT")
    scene.collection.children.link(export_col)
    mat = bpy.data.materials.new("blk_mat")

    cube = unit_cube()
    cube.name = cube.data.name = "blk_cube_base"
    cube.data.materials.append(mat)
    cube.data.calc_loop_triangles()
    base_col = bpy.data.collections.new("blk_cube_base")
    export_col.children.link(base_col)
    for c in list(cube.users_collection):
        c.objects.unlink(cube)
    base_col.objects.link(cube)
    export([cube], os.path.join(out, "blk_cube_base.glb"), game_dir)
    print(f"BUILT blk_cube_base: {len(cube.data.loop_triangles)} tris, dims {tuple(round(d, 3) for d in cube.dimensions)}")

    for name, cells in SHAPES.items():
        col = bpy.data.collections.new("blk_piece_" + name)
        export_col.children.link(col)
        piece = build(name, cells, cube.data, col)
        export([piece, *piece.children], os.path.join(out, piece.name + ".glb"), game_dir)
        print(f"BUILT {piece.name}: {len(cells)} cubes")
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(root, "blocks.blend"))
    print("SAVED", bpy.data.filepath)


main()
