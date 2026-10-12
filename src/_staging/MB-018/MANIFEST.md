# MB-018 (CH-038 + CH-041)
- src/view/palette_table.gd -> REPLACE (adds outline(hue), pattern(hue) from optional "outlines"/"patterns" keys; defaults BLACK / &"none"). Existing sampler tool, candy_toy.json, shape_hand_fields.json already in repo.
- src/view/art_set.gd -> NEW (needs PaletteTable, Orientations).
- src/view/board_geom.gd -> NEW.
Check in editor: logs_read clean; ArtSet.new(&"candy_toy").cube_scale()*1.03 ~ 1.0; ArtSet.new(&"meadow").palette().pattern(3) == &"waves" (meadow has no block dir, so palette only); BoardGeom.orient_basis(o)*Vector3(v) == Vector3(Orientations.apply(o,v)); cell_center((0,0,0),(4,12,4)) == (-1.5,0.5,-1.5).

## Review
- orient_basis verified: Basis(row0,row1,row2).transposed() is the matrix with rows = Orientations.matrix(o), so basis*Vector3(v) == Vector3(Orientations.apply(o,v)) for all 24 orientations (integer entries, exact); cell_center sample gives (-1.5,0.5,-1.5).
- palette_table.gd replacement is a strict superset of live (from_dict, color, size, errors unchanged); only other users are MB-025 staged files (color/from_dict) and tests/unit/view/palette_table_test.gd, all still valid.
- art_set.gd: added missing `##` doc on set_id(). No other change; MB-025 callers (cube_scale, cube_mesh, set_id, shape_scene, cell_center, piece_root_transform) match.
