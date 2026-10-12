extends RefCounted
## Standalone arcade round contract. No dependency on BoardSim, autoloads or UI.

signal round_finished(result: Dictionary)
signal interaction_requested(event: Dictionary)

var config: Dictionary = {}
var elapsed: float = 0.0
var finished: bool = false
var won: bool = false
var score: int = 0
var message: String = ""
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


## Starts a fresh deterministic round from a level dictionary.
func start(level: Dictionary, round_seed: int = 1) -> void:
	config = level.duplicate(true)
	elapsed = 0.0
	finished = false
	won = false
	score = 0
	message = ""
	rng.seed = round_seed
	_reset()


## Advances simulation time; paused callers simply stop calling this method.
func advance(delta: float) -> void:
	if finished or delta <= 0.0:
		return
	var remaining: float = maxf(0.0, float(config.get("time_limit", 90.0)) - elapsed)
	var step: float = minf(delta, remaining)
	elapsed += step
	_step(step)
	if not finished and elapsed >= float(config.get("time_limit", 90.0)):
		complete(false, "Time's up. Try again!")


## Accepts a semantic action such as primary, left, right, rotate_x, undo.
func act(_action: String) -> void:
	pass


## Returns renderer-neutral blocks and HUD data. Positions are Godot Y-up meters.
func snapshot() -> Dictionary:
	return {"blocks": [], "markers": [], "status": message, "progress": 0.0,
		"metric": str(score), "camera_target": Vector3(0, 2, 0), "camera_size": 12.0}


## Publishes one immutable result; later actions and time cannot finish twice.
func complete(success: bool, text: String) -> void:
	if finished:
		return
	finished = true
	won = success
	message = text
	var thresholds: Array = config.get("star_times", [60.0, 90.0])
	var stars: int = 0
	if success:
		stars = 3 if elapsed <= float(thresholds[0]) else (2 if elapsed <= float(thresholds[1]) else 1)
	round_finished.emit({"level_id": config.get("id", ""), "won": won,
		"score": score, "elapsed": elapsed, "stars": stars})


func _reset() -> void:
	pass


func _step(_delta: float) -> void:
	pass
