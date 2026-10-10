extends Node3D
## First-playable entry: loads meadow_01, wires FpGame to view, input, touch and HUD, ticks the sim.

const LEVEL_PATH: String = "res://prototypes/first_playable/test_level.json"
const SEED: int = 1
const PLATFORM_SIZE: float = 10.0

var game: FpGame


func _ready() -> void:
	var level: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LEVEL_PATH))
	game = FpGame.new(level, SEED)
	# Platform is authored 10x10 (an 8x8 board + 1-cell rim); stretch it to the board from the JSON.
	var s: Vector3i = game.board.size
	$Platform.scale = Vector3((s.x + 2) / PLATFORM_SIZE, 1.0, (s.z + 2) / PLATFORM_SIZE)
	var view := FpView.new()
	add_child(view)
	view.setup(game)
	var input := FpInput.new()
	add_child(input)
	input.setup(game, view)
	add_child(FpTouch.new())
	var hud := FpHud.new()
	add_child(hud)
	hud.bind(game)
	# wt_restart is handled by FpInput.


func _process(delta: float) -> void:
	game.tick(roundi(delta * 1000.0))
