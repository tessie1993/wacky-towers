# First playable (meadow_01) — part contract

Throwaway vertical slice so meadow_01 is playable now; real systems (BoardSim, BoardState, view/) replace it part by part.
All scripts: typed GDScript, short doc comment on public funcs. **Writers write ONLY into `prototypes/first_playable/_staging/` (has `.gdignore`, so Godot never parses half-done parts).** The integrator moves them up one level together, imports, fixes parse errors, then plays. No files in tests/ (prototype).
Every part codes against THIS contract, not against another part's file (they're written in parallel).

Level: `res://production/levels/meadow/data/meadow_01.json` — board 4x4, h_play 8, shapes i o t l s, opening o,i, goal clear_n 4, stars t2 145000 / t3 105000 ms, fall.g0 0.6, spin only.

## Conventions (adopted rules-audit defaults — tunable)
- Cell = Vector3i(x, y, z), 0 <= x < W, 0 <= z < D, y up, y = 0 floor. Board height = h_play + 4 (spawn room).
- World centre of a cell: Vector3(x - W/2.0 + 0.5, y + 0.5, z - D/2.0 + 0.5). Cell size 1.0.
- Shapes are flat in the XZ plane (y = 0). Pivot = the cube nearest the bbox centre (ties: lowest x, then z).
- spin(+1) = spin right = rotate around Y by -90°: (x, z) -> (z, -x) relative to pivot; spin(-1) the inverse.
  A spin whose result is the same cell set (O) changes nothing. Spin fails if blocked: try kicks (±1 x, ±1 z), else no-op.
- Gravity: cells per second = fall.g0 (0.6). Soft drop multiplies by 20. At most 1 fall step per tick() call.
- Lock: lock timer (500 ms) starts when the piece rests; resets on a successful move/spin, max 15 resets; hard drop locks at once.
- Clear: after lock, every layer y whose W*D cells are all filled is removed; everything above moves down by the number of cleared layers under it.
- Spawn: piece spawns with its lowest cubes at y = h_play, centred (x,z offset = floor((W - bbox_w)/2)). If it can't be placed -> LOST (rescue/warnings: later).
- Win: layers_cleared >= goal n -> WON. Stars: 3 if elapsed_ms <= t3, 2 if <= t2, else 1.
- Bag: seeded RandomNumberGenerator; first pieces = opening set in order, then 7-bag style shuffle of the shape list (refill when empty).

## Parts

### A. `fp_board.gd` — `class_name FpBoard extends RefCounted`
```
func _init(w: int, d: int, h: int) -> void
var size: Vector3i                                  # (W, H, D)
func in_bounds(c: Vector3i) -> bool
func is_free(c: Vector3i) -> bool                   # in bounds and empty
func can_place(cells: Array[Vector3i]) -> bool
func get_cell(c: Vector3i) -> int                   # colour index, -1 empty
func lock(cells: Array[Vector3i], colour: int) -> void
func clear_full_layers() -> PackedInt32Array        # cleared y values (ascending), board already collapsed
func filled_cells() -> Dictionary                   # Vector3i -> colour
func highest_filled_y() -> int                      # -1 when empty
```

### B. `fp_pieces.gd` — `class_name FpPieces extends RefCounted` (static shape data + spin) and `fp_bag.gd` — `class_name FpBag extends RefCounted`
```
# FpPieces
const SHAPES: Dictionary = { "i": [...], "o": [...], "t": [...], "l": [...], "s": [...] }   # Array[Vector3i] offsets, y = 0, min corner at 0,0,0
const COLOURS: Dictionary = { "i": 0, "o": 1, "t": 2, "l": 3, "s": 4 }
static func cells(shape: String) -> Array[Vector3i]
static func pivot(offsets: Array[Vector3i]) -> Vector3i
static func spin(offsets: Array[Vector3i], dir: int) -> Array[Vector3i]   # around pivot, result keeps pivot cell fixed
# FpBag
func _init(shapes: PackedStringArray, opening: PackedStringArray, seed: int) -> void
func next() -> String
func peek(n: int) -> PackedStringArray
```

### C. `fp_game.gd` — `class_name FpGame extends RefCounted` (pure sim; uses FpBoard, FpPieces, FpBag)
```
enum State { PLAYING, WON, LOST }
signal changed                      # anything visible changed
signal piece_locked(cells: Array[Vector3i], colour: int)
signal layers_cleared(ys: PackedInt32Array)
signal finished(state: int, stars: int)
func _init(level: Dictionary, seed: int) -> void    # level = parsed meadow_01.json
var board: FpBoard
var state: State
var active_cells: Array[Vector3i]   # world cells of the falling piece ([] when none)
var active_shape: String
var ghost_cells: Array[Vector3i]
var next_shapes: PackedStringArray  # peek(3)
var layers_cleared_total: int
var goal_n: int
var elapsed_ms: int
func move(dx: int, dz: int) -> bool
func spin(dir: int) -> bool
func set_soft_drop(on: bool) -> void
func hard_drop() -> void
func tick(delta_ms: int) -> void    # advances gravity, lock timer, elapsed time
func stars() -> int
func restart() -> void
```

### D. `fp_view.gd` — `class_name FpView extends Node3D`
```
func setup(game: FpGame) -> void    # builds floor grid, walls outline, camera, light; connects game.changed
var view_k: int                     # 0..3, 90° snaps; camera yaw = 45° + 90°*view_k, orthographic, elevation ~35°
func rotate_view(dir: int) -> void  # tween 0.2 s
```
Renders settled cells with a MultiMeshInstance3D (mesh = cube mesh taken from `res://assets/models/blocks/candy_toy/blk_candy_toy_cube.glb`; set use_colors BEFORE instance_count), the active piece the same way (separate MultiMesh), and the ghost as translucent cubes. Colour per index (5 cute pastel colours). Frame with `CameraMath.ortho_size` (src/view/camera_math.gd).

### E. `fp_input.gd` — `class_name FpInput extends Node` + `fp_touch.gd` / `fp_touch.tscn`
```
func setup(game: FpGame, view: FpView) -> void
```
Actions (integrator adds them to the InputMap): `wt_move_left/right/up/down` (arrows + WASD), `wt_spin_left` (Q), `wt_spin_right` (E / Space? no: E), `wt_soft_drop` (S? no: Shift), `wt_hard_drop` (Space), `wt_view_left` (Z), `wt_view_right` (C), `wt_restart` (R).
Movement is screen-relative: map screen up/down/left/right to world (dx, dz) using `view.view_k`. Auto-repeat 170 ms delay / 50 ms interval for moves. fp_touch: CanvasLayer of big buttons that call `Input.action_press/release` for the same actions.

### F. `fp_hud.gd` — `class_name FpHud extends CanvasLayer` (+ `fp_hud.tscn`)
```
func bind(game: FpGame) -> void
```
Shows "Layers x / n", timer m:ss, next pieces, a win panel (stars ★ + Restart) and a lose panel (Try again). Buttons call `game.restart()`.

### G. Integrator — `fp_main.tscn` + `fp_main.gd`
Root Node3D: loads level JSON, creates FpGame (seed 1), FpView, FpInput, FpTouch, FpHud; `_process` calls `game.tick(int(delta*1000))`. Adds InputMap actions, sets run/main_scene, runs + plays via input_simulate, screenshots to production/qa/evidence/first-playable/.
