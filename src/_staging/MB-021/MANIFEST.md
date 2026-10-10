# MB-021 manifest (CH-051, CH-160, CH-053)
| Final path | Action | Notes |
|---|---|---|
| src/core/sim/kick_table.gd | new | `KickTable.candidates` / `is_up_kick` / `is_wide` |
| src/core/sim/movement.gd | new | `Movement.try_translate / drop_distance / is_resting / try_rotate` |

ActivePiece (live, identical to the MB-010 staged one) already has `up_kicks_used`, so no edit. The ticket's `p.origin` / `p.travel_dir` are `p.pivot` / `board.down_vector()`.
Needs the MB-011 BoardState live (`can_place`, `cast`, `down_vector`, `is_active`, `index`, `size`).
Tie order follows the GDD (+a1, -a1, +a2, -a2 = +x, -x, +z, -z), not the ticket's (+x, +z, -x, -z). Extra opt `kick_order` ("fixed" skips the centre sort).

Editor check (script eval, meadow board):
- `KickTable.candidates(Orientations.Axis.Y, Vector3i(0,-1,0), Vector2(3.5,3.5), Vector3i(3,5,1), 3, {})` -> 10 entries: ZERO, +z, +x, -x, -z, then up and up+offsets. Extent 4 -> 14. Axis X -> at most 12.
- T at pivot (3,5,1) against the -z wall: `Movement.try_rotate(p, board, Orientations.Axis.Y, 1, {})` -> OK, kicked, offset (0,0,1).
- `try_translate` +x repeatedly on a 4-wide board: last call BLOCKED / out_of_bounds, pivot unchanged.
- `{"enabled_axes": [1]}` with Axis.X -> DISABLED.
