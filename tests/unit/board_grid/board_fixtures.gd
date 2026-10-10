class_name BoardFixtures extends RefCounted
## Test-only factories for BoardState tests.


## Content types matching assets/data/content/blocks.json: block (kind 1), starter (kind 2, glyph "#").
static func types() -> ContentTypes:
	var entries: Array = [
		{"id": "block", "kind_id": 1, "glyph": "", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0, "mesh": ""},
		{"id": "starter", "kind_id": 2, "glyph": "#", "slot": "cell", "solid": true, "fills_layer": true, "hue": 0, "mesh": ""},
	]
	return ContentTypes.from_entries(entries)


## Trusted BoardSpec, size = (w, h_play + default spawn clearance, d). Usage: BoardFixtures.spec(4, 4, 3).
static func spec(w: int, d: int, h_play: int, down: int = BoardState.Down.Y_NEG,
		contents: Array[Dictionary] = [], mask: PackedByteArray = PackedByteArray()) -> BoardSpec:
	var s: BoardSpec = BoardSpec.new()
	s.size = Vector3i(w, h_play + BoardLimits.DEFAULT_SPAWN_CLEARANCE, d)
	s.h_play = h_play
	s.down = down
	s.mask = mask
	s.contents = contents
	return s


## BoardState built from spec() and types(). Usage: BoardFixtures.board(4, 4, 3).
static func board(w: int, d: int, h_play: int, down: int = BoardState.Down.Y_NEG,
		contents: Array[Dictionary] = [], mask: PackedByteArray = PackedByteArray()) -> BoardState:
	return BoardState.new(spec(w, d, h_play, down, contents, mask), types())
