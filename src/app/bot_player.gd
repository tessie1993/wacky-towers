class_name WtBotPlayer extends RefCounted
## Deterministic practice opponent. Evaluates reachable horizontal placements and sends real commands.
const THINK_TICKS: int = 45
const STEP_TICKS: int = 6
var _shape: ShapeDef
var _orient: int = -1
var _target: Vector3i = Vector3i.ZERO
var _next_tick: int = 0
var _planned: bool = false

## Moves toward a low, hole-free landing; waits between actions so the opponent is legible.
func update(sim: BoardSim) -> void:
	var piece: ActivePiece = sim.get_piece()
	if piece == null or sim.get_phase() == BoardSim.Phase.ENDED: return
	if not _planned or piece.shape != _shape or (sim.get_phase() == BoardSim.Phase.FALLING and piece.pivot.y > _target.y + 2 and sim.get_tick() > _next_tick + THINK_TICKS):
		_plan(sim)
	if sim.get_tick() < _next_tick: return
	_next_tick = sim.get_tick() + STEP_TICKS
	if piece.orient != _orient:
		sim.queue_command(SimCommand.make(SimEvents.CMD_ROTATE, [Orientations.Axis.Y, 1]))
	elif piece.pivot.x != _target.x:
		sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(signi(_target.x - piece.pivot.x), 0, 0)]))
	elif piece.pivot.z != _target.z:
		sim.queue_command(SimCommand.make(SimEvents.CMD_MOVE, [Vector3i(0, 0, signi(_target.z - piece.pivot.z))]))
	else:
		sim.queue_command(SimCommand.make(SimEvents.CMD_HARD_DROP))
		_planned = false

func _plan(sim: BoardSim) -> void:
	var p: ActivePiece = sim.get_piece()
	_shape = p.shape
	_orient = p.orient
	_target = p.pivot
	_planned = true
	_next_tick = sim.get_tick() + THINK_TICKS
	var b: BoardState = sim.board()
	var best: int = -2147483648
	var candidate: ActivePiece = p.duplicate_piece()
	for turn: int in 4:
		for x: int in b.size().x:
			for z: int in b.size().z:
				candidate.pivot = Vector3i(x, p.pivot.y, z)
				if not b.can_place(candidate.cells()): continue
				var d: int = Movement.drop_distance(candidate, b)
				var landed: Array[Vector3i] = candidate.cells_at(candidate.orient, candidate.pivot + b.down_vector() * d)
				var value: int = d * 8
				for cell: Vector3i in landed:
					var below: Vector3i = cell + b.down_vector()
					if b.is_free(below) and not landed.has(below): value -= 45
					for side: Vector3i in [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]:
						if not b.is_free(cell + side): value += 3
				if value > best:
					best = value
					_target = candidate.pivot
					_orient = candidate.orient
		candidate.orient = Orientations.turn(candidate.orient, Orientations.Axis.Y, 1)
