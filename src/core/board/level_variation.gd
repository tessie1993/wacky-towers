class_name LevelVariation extends RefCounted
## Per-attempt layout variation for levels that opt in with a top-level "variation" block.
## Works on the raw level dictionary before LevelLoader, so every variant is re-validated by the
## normal loader. Pure: all randomness comes from Seeds (ADR-0006), so one attempt seed always
## yields the same variant and a logged seed replays the run.
##
## Level block (all keys optional):
##   "variation": {"symmetries": ["mirror_x", "rot180"], "jitter": {"glyphs": "nR", "radius": 1,
##                 "keep_spawn_clear": true, "rule_tiles": true}}
## Symmetry maps the whole board (mask, starting contents, spawn anchor, shape target, and the rule
## params listed in assets/data/variation/variation_rules.json). It is an isomorphism, so the
## variant is exactly as solvable as the authored level. Jitter then nudges sparse feature groups
## by up to `radius` cells. A move is kept only when layout_ok() still holds against the authored
## baseline (no pre-filled layer, no fewer clearable layers, lowest clearable layer no higher).
##
## Usage:
##   var cfg: Dictionary = LevelVariation.load_config()
##   var out: Dictionary = LevelVariation.apply(raw, attempt_seed, cfg, LevelVariation.nonfill_glyphs(types))
##   var level: LevelData = LevelLoader.parse_level(out.raw, catalog).level

const CONFIG_PATH := "res://assets/data/variation/variation_rules.json"
const KEY := "variation"
const EMPTY := "."
const BLOCK_KEYS: Array[String] = ["symmetries", "jitter", "note"]
const JITTER_KEYS: Array[String] = ["glyphs", "radius", "keep_spawn_clear", "rule_tiles"]
const DIR_TOKENS: Dictionary = {"+x": Vector2i(1, 0), "-x": Vector2i(-1, 0), "+z": Vector2i(0, 1), "-z": Vector2i(0, -1)}


## Reads the variation config file; returns {} when it is missing or invalid.
## Usage: var cfg: Dictionary = LevelVariation.load_config()
static func load_config(path: String = CONFIG_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


## Glyphs whose content does not count toward a layer clear (e.g. rock, shelf).
## Usage: LevelVariation.nonfill_glyphs(catalog.content)
static func nonfill_glyphs(types: ContentTypes) -> String:
	var out: String = ""
	if types == null:
		return out
	for glyph: String in types.glyphs():
		if not types.fills_layer(types.kind_of_glyph(glyph)):
			out += glyph
	return out


## Builds one variant. Returns {"raw": Dictionary (without "variation"), "seed": int,
## "symmetry": String, "moved": int}. Levels without a variation block come back unchanged.
## forced_symmetry (validator use) skips the seeded symmetry pick.
## Usage: LevelVariation.apply(raw, 1234, cfg, "RH")
static func apply(raw: Dictionary, attempt_seed: int, config: Dictionary, nonfill: String, forced_symmetry: String = "") -> Dictionary:
	var out: Dictionary = raw.duplicate(true)
	var result: Dictionary = {"raw": out, "seed": attempt_seed, "symmetry": "identity", "moved": 0}
	if not out.has(KEY):
		return result
	var block: Variant = out[KEY]
	out.erase(KEY)
	if not block is Dictionary or not validate_block(raw, config, "").is_empty():
		return result
	var board: Dictionary = out.get("board", {})
	var w: int = int(board.get("width", 0))
	var d: int = int(board.get("depth", 0))
	var rng: RandomNumberGenerator = Seeds.make_rng(attempt_seed, [KEY, str(out.get("id", ""))])
	var allowed: PackedStringArray = allowed_symmetries(block, config, w, d)
	var symmetry: String = forced_symmetry
	if symmetry.is_empty():
		symmetry = allowed[rng.randi_range(0, allowed.size() - 1)] if not allowed.is_empty() else "identity"
	_apply_symmetry(out, symmetry, w, d, config)
	result.symmetry = symmetry
	if block.get("jitter") is Dictionary:
		result.moved = _apply_jitter(out, block.jitter, config, nonfill, rng)
	var metadata: Dictionary = out.get("metadata", {}) if out.get("metadata") is Dictionary else {}
	metadata["variation_applied"] = {"seed": attempt_seed, "symmetry": symmetry, "moved": result.moved}
	out["metadata"] = metadata
	return result


## Symmetries a level may use: its own list (or every configured one), minus square-only ones on
## non-square boards. Usage: LevelVariation.allowed_symmetries(block, cfg, 8, 8)
static func allowed_symmetries(block: Dictionary, config: Dictionary, w: int, d: int) -> PackedStringArray:
	var known: Array = config.get("symmetries", ["identity"])
	var square_only: Array = config.get("square_only", [])
	var wanted: Array = block.get("symmetries", known) if block.get("symmetries") is Array else known
	var out: PackedStringArray = PackedStringArray()
	for name: Variant in wanted:
		var s: String = str(name)
		if known.has(s) and (w == d or not square_only.has(s)) and not out.has(s):
			out.append(s)
	if not out.has("identity"):
		out.insert(0, "identity")
	return out


## Per-layer occupancy summary of a raw board: {"full": PackedInt32Array, "clearable": PackedInt32Array}.
## full = layers whose clear-counting cells are all filled at spawn (a blocked full row).
## clearable = layers with an empty cell where every empty cell is open to the sky.
## Usage: LevelVariation.layer_report(raw.board, "RH")
static func layer_report(board: Dictionary, nonfill: String) -> Dictionary:
	var w: int = int(board.get("width", 0))
	var d: int = int(board.get("depth", 0))
	var h: int = int(board.get("h_play", 0))
	var mask: Array = board.get("mask", []) if board.get("mask") is Array else []
	var layers: Dictionary = _layers(board)
	var full: PackedInt32Array = PackedInt32Array()
	var clearable: PackedInt32Array = PackedInt32Array()
	for y: int in h:
		var counted: int = 0
		var empties: int = 0
		var open: bool = true
		for z: int in d:
			for x: int in w:
				if not mask.is_empty() and str(mask[z])[x] == EMPTY:
					continue
				var glyph: String = _at(layers, x, y, z)
				if nonfill.contains(glyph) and glyph != EMPTY:
					continue
				counted += 1
				if glyph == EMPTY:
					empties += 1
					for above: int in range(y + 1, h):
						if _at(layers, x, above, z) != EMPTY:
							open = false
							break
		if counted > 0 and empties == 0:
			full.append(y)
		elif empties > 0 and open:
			clearable.append(y)
	return {"full": full, "clearable": clearable}


## Empty string when `report` is no worse than `baseline` for a goal needing `required` clears;
## otherwise the reason. Usage: LevelVariation.layout_ok(variant_report, authored_report, 3)
static func layout_ok(report: Dictionary, baseline: Dictionary, required: int) -> String:
	var full: PackedInt32Array = report.full
	var clearable: PackedInt32Array = report.clearable
	var base_clear: PackedInt32Array = baseline.clearable
	if not full.is_empty():
		return "layer %d is full at spawn" % full[0]
	if clearable.is_empty():
		return "no clearable layer at spawn"
	if clearable.size() < mini(maxi(1, required), base_clear.size()):
		return "%d clearable layers, goal needs %d" % [clearable.size(), required]
	if not base_clear.is_empty() and clearable[0] > base_clear[0]:
		return "lowest clearable layer rose from %d to %d" % [base_clear[0], clearable[0]]
	return ""


## Clears a level must be able to make: goal.n for clear_n, else 1. Usage: LevelVariation.required_clears(raw)
static func required_clears(raw: Dictionary) -> int:
	var goal: Dictionary = raw.get("goal", {}) if raw.get("goal") is Dictionary else {}
	return maxi(1, int(goal.get("n", 1))) if str(goal.get("type", "")) == "clear_n" else 1


## Schema and fitness errors of a level's variation block (empty = fine). legal_glyphs "" skips
## the glyph check. Usage: LevelVariation.validate_block(raw, cfg, catalog.content.glyphs())
static func validate_block(raw: Dictionary, config: Dictionary, legal_glyphs: String) -> PackedStringArray:
	var e: PackedStringArray = PackedStringArray()
	var block: Variant = raw.get(KEY)
	if config.is_empty():
		e.append("variation: config %s missing" % CONFIG_PATH)
		return e
	if not block is Dictionary:
		e.append("variation: must be an object")
		return e
	for key: Variant in block:
		if not BLOCK_KEYS.has(str(key)):
			e.append("variation.%s: unknown key" % str(key))
	var board: Dictionary = raw.get("board", {}) if raw.get("board") is Dictionary else {}
	var w: int = int(board.get("width", 0))
	var d: int = int(board.get("depth", 0))
	if str(board.get("down_axis", "-y")) != "-y":
		e.append("variation: only -y gravity boards can vary")
	if board.has("mask") and not board.mask is Array:
		e.append("variation: board.mask must be a row array")
	if block.has("symmetries"):
		if not block.symmetries is Array or block.symmetries.is_empty():
			e.append("variation.symmetries: must be a nonempty array")
		else:
			for name: Variant in block.symmetries:
				if not (config.get("symmetries", []) as Array).has(str(name)):
					e.append("variation.symmetries: unknown '%s'" % str(name))
				elif w != d and (config.get("square_only", []) as Array).has(str(name)):
					e.append("variation.symmetries: '%s' needs a square board" % str(name))
	var pieces: Dictionary = raw.get("pieces", {}) if raw.get("pieces") is Dictionary else {}
	if not (pieces.get("fixed_list", []) as Array).is_empty() or not (pieces.get("kit", []) as Array).is_empty():
		e.append("variation: finite fixed-list/kit puzzles keep their authored layout")
	for rule: Variant in raw.get("rules", []):
		if rule is Dictionary and (config.get("positional_rules", []) as Array).has(str(rule.get("id", ""))):
			e.append("variation: rule '%s' has untransformed positions" % str(rule.id))
	var jitter: Variant = block.get("jitter")
	if jitter != null:
		if not jitter is Dictionary:
			e.append("variation.jitter: must be an object")
			return e
		for key: Variant in jitter:
			if not JITTER_KEYS.has(str(key)):
				e.append("variation.jitter.%s: unknown key" % str(key))
		var glyphs: Variant = jitter.get("glyphs", "")
		if not glyphs is String or (glyphs as String).is_empty() or (glyphs as String).contains(EMPTY):
			e.append("variation.jitter.glyphs: must be a nonempty glyph string")
		elif not legal_glyphs.is_empty():
			for glyph: String in glyphs as String:
				if not legal_glyphs.contains(glyph):
					e.append("variation.jitter.glyphs: unknown glyph '%s'" % glyph)
		var radius_max: int = int(config.get("limits", {}).get("jitter_radius_max", 2))
		var radius: Variant = jitter.get("radius", config.get("defaults", {}).get("jitter_radius", 1))
		if not (radius is int or radius is float) or int(radius) < 1 or int(radius) > radius_max:
			e.append("variation.jitter.radius: must be 1..%d" % radius_max)
		if str(raw.get("goal", {}).get("type", "")) == "shape":
			e.append("variation.jitter: shape goals keep their target alignment; use symmetry only")
	return e


## Full validator check: block schema plus every allowed symmetry over seeded jitter samples.
## Each variant must keep a clearable layer (no blocked full rows at spawn) and be no worse than
## the authored layout. Returns the problems; empty = every sampled variant is fine.
## Usage: LevelVariation.check_variants(raw, cfg, types.glyphs(), "RH")
static func check_variants(raw: Dictionary, config: Dictionary, legal_glyphs: String, nonfill: String) -> PackedStringArray:
	var e: PackedStringArray = validate_block(raw, config, legal_glyphs)
	if not e.is_empty() or not raw.get(KEY) is Dictionary:
		return e
	var board: Dictionary = raw.get("board", {})
	var baseline: Dictionary = layer_report(board, nonfill)
	var required: int = required_clears(raw)
	var authored: String = layout_ok(baseline, baseline, required)
	if not authored.is_empty():
		e.append("variation: authored layout fails the clearable check (%s)" % authored)
		return e
	var samples: int = maxi(1, int(config.get("limits", {}).get("validator_seed_samples", 12)))
	for symmetry: String in allowed_symmetries(raw[KEY], config, int(board.get("width", 0)), int(board.get("depth", 0))):
		for sample: int in samples:
			var variant: Dictionary = apply(raw, sample, config, nonfill, symmetry)
			var reason: String = layout_ok(layer_report(variant.raw.board, nonfill), baseline, required)
			if not reason.is_empty():
				e.append("variation: %s seed %d: %s" % [symmetry, sample, reason])
				break
	return e


# --- symmetry -------------------------------------------------------------

static func _map(symmetry: String, p: Vector2i, w: int, d: int) -> Vector2i:
	match symmetry:
		"mirror_x": return Vector2i(w - 1 - p.x, p.y)
		"mirror_z": return Vector2i(p.x, d - 1 - p.y)
		"rot90": return Vector2i(d - 1 - p.y, p.x)
		"rot180": return Vector2i(w - 1 - p.x, d - 1 - p.y)
		"rot270": return Vector2i(p.y, w - 1 - p.x)
		"transpose": return Vector2i(p.y, p.x)
		"anti_transpose": return Vector2i(d - 1 - p.y, w - 1 - p.x)
	return p


static func _map_dir(symmetry: String, v: Vector2i) -> Vector2i:
	match symmetry:
		"mirror_x": return Vector2i(-v.x, v.y)
		"mirror_z": return Vector2i(v.x, -v.y)
		"rot90": return Vector2i(-v.y, v.x)
		"rot180": return Vector2i(-v.x, -v.y)
		"rot270": return Vector2i(v.y, -v.x)
		"transpose": return Vector2i(v.y, v.x)
		"anti_transpose": return Vector2i(-v.y, -v.x)
	return v


static func _map_rows(rows: Array, symmetry: String, w: int, d: int) -> Array:
	var grid: Array = []
	for z: int in d:
		var row: PackedStringArray = PackedStringArray()
		row.resize(w)
		row.fill(EMPTY)
		grid.append(row)
	for z: int in mini(d, rows.size()):
		var src: String = str(rows[z])
		for x: int in mini(w, src.length()):
			var to: Vector2i = _map(symmetry, Vector2i(x, z), w, d)
			var target: PackedStringArray = grid[to.y]
			target[to.x] = src[x]
			grid[to.y] = target
	var out: Array = []
	for row: PackedStringArray in grid:
		out.append("".join(row))
	return out


static func _apply_symmetry(out: Dictionary, symmetry: String, w: int, d: int, config: Dictionary) -> void:
	if symmetry == "identity":
		return
	var board: Dictionary = out.board
	if board.get("mask") is Array:
		board.mask = _map_rows(board.mask, symmetry, w, d)
	if board.get("starting_contents") is Dictionary and board.starting_contents.get("layers") is Dictionary:
		var layers: Dictionary = board.starting_contents.layers
		for key: Variant in layers.keys():
			layers[key] = _map_rows(layers[key], symmetry, w, d)
	if board.has("spawn_anchor"):
		board.spawn_anchor = _map_anchor(board.spawn_anchor, symmetry, w, d)
	var goal: Dictionary = out.get("goal", {}) if out.get("goal") is Dictionary else {}
	if goal.get("target_shape") is Dictionary and goal.target_shape.get("layers") is Dictionary:
		var target: Dictionary = goal.target_shape.layers
		for key: Variant in target.keys():
			target[key] = _map_rows(target[key], symmetry, w, d)
	var table: Dictionary = config.get("rule_params", {})
	for rule: Variant in out.get("rules", []):
		if not rule is Dictionary or not table.has(str(rule.get("id", ""))) or not rule.get("params") is Dictionary:
			continue
		var kinds: Dictionary = table[str(rule.id)]
		for param: String in kinds:
			if rule.params.has(param):
				rule.params[param] = _map_param(rule.params[param], str(kinds[param]), func(p: Vector2i) -> Vector2i: return _map(symmetry, p, w, d), symmetry)


static func _map_anchor(anchor: Variant, symmetry: String, w: int, d: int) -> Variant:
	if anchor is Array and anchor.size() == 2:
		var p: Vector2i = _map(symmetry, Vector2i(int(anchor[0]), int(anchor[1])), w, d)
		return [p.x, p.y]
	if anchor is Dictionary:
		var p: Vector2i = _map(symmetry, Vector2i(int(anchor.get("x", 0)), int(anchor.get("z", 0))), w, d)
		return {"x": p.x, "z": p.y}
	return anchor


## Maps one rule param of a known kind with `move` (column -> column); "dir" tokens use the symmetry.
static func _map_param(value: Variant, kind: String, move: Callable, symmetry: String) -> Variant:
	match kind:
		"cells_xyz":
			var cells: Array = []
			for cell: Variant in value if value is Array else []:
				cells.append(_map_param(cell, "cell_xyz", move, symmetry))
			return cells
		"cell_xyz":
			if value is Array and value.size() == 3:
				var p: Vector2i = move.call(Vector2i(int(value[0]), int(value[2])))
				return [p.x, int(value[1]), p.y]
		"tiles_xz":
			var tiles: Array = []
			for tile: Variant in value if value is Array else []:
				if tile is Array and tile.size() >= 2:
					var p: Vector2i = move.call(Vector2i(int(tile[0]), int(tile[1])))
					tiles.append([p.x, p.y])
				else:
					tiles.append(tile)
			return tiles
		"dir":
			if value is String and DIR_TOKENS.has(value) and not symmetry.is_empty():
				var v: Vector2i = _map_dir(symmetry, DIR_TOKENS[value])
				for token: String in DIR_TOKENS:
					if DIR_TOKENS[token] == v:
						return token
	return value


# --- jitter ---------------------------------------------------------------

static func _layers(board: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	var section: Variant = board.get("starting_contents")
	if section is Dictionary and section.get("layers") is Dictionary:
		for key: Variant in section.layers:
			out[int(str(key))] = section.layers[key]
	return out


static func _at(layers: Dictionary, x: int, y: int, z: int) -> String:
	if not layers.has(y):
		return EMPTY
	var rows: Array = layers[y]
	if z >= rows.size() or x >= str(rows[z]).length():
		return EMPTY
	return str(rows[z])[x]


static func _apply_jitter(out: Dictionary, jitter: Dictionary, config: Dictionary, nonfill: String, rng: RandomNumberGenerator) -> int:
	var board: Dictionary = out.board
	var w: int = int(board.width)
	var d: int = int(board.depth)
	var defaults: Dictionary = config.get("defaults", {})
	var glyphs: String = str(jitter.get("glyphs", ""))
	var radius: int = int(jitter.get("radius", defaults.get("jitter_radius", 1)))
	var keep_spawn: bool = bool(jitter.get("keep_spawn_clear", defaults.get("keep_spawn_clear", true)))
	var rule_tiles: bool = bool(jitter.get("rule_tiles", defaults.get("rule_tiles", true)))
	var mask: Array = board.get("mask", []) if board.get("mask") is Array else []
	var section: Dictionary = board.get("starting_contents", {}) if board.get("starting_contents") is Dictionary else {}
	var raw_layers: Dictionary = section.get("layers", {}) if section.get("layers") is Dictionary else {}
	# grids[key] = Array[PackedStringArray] (rows of single chars), edited in place.
	var grids: Dictionary = {}
	for key: Variant in raw_layers:
		var grid: Array = []
		for row: Variant in raw_layers[key]:
			var chars: PackedStringArray = PackedStringArray()
			for ch: String in str(row):
				chars.append(ch)
			grid.append(chars)
		grids[key] = grid
	var units: Array = _units(grids, glyphs, out, config, rule_tiles)
	if units.is_empty():
		return 0
	var static_cols: Dictionary = {}
	for key: Variant in grids:
		for z: int in (grids[key] as Array).size():
			var row: PackedStringArray = grids[key][z]
			for x: int in row.size():
				if row[x] != EMPTY and not glyphs.contains(row[x]):
					static_cols[Vector2i(x, z)] = true
	var anchor: Vector2i = Vector2i((w - 1) / 2, (d - 1) / 2)
	if board.get("spawn_anchor") is Array:
		anchor = Vector2i(int(board.spawn_anchor[0]), int(board.spawn_anchor[1]))
	elif board.get("spawn_anchor") is Dictionary:
		anchor = Vector2i(int(board.spawn_anchor.get("x", anchor.x)), int(board.spawn_anchor.get("z", anchor.y)))
	var baseline: Dictionary = layer_report(board, nonfill)
	var required: int = required_clears(out)
	var offsets: Array[Vector2i] = []
	for dz: int in range(-radius, radius + 1):
		for dx: int in range(-radius, radius + 1):
			if dx != 0 or dz != 0:
				offsets.append(Vector2i(dx, dz))
	var order: Array = range(units.size())
	Seeds.shuffle(rng, order)
	var moves: Dictionary = {}  # Vector2i old column -> Vector2i new column
	var moved: int = 0
	for index: int in order:
		var unit: Dictionary = units[index]
		var tries: Array = offsets.duplicate()
		Seeds.shuffle(rng, tries)
		for offset: Vector2i in tries:
			if not _fits(unit, offset, units, index, static_cols, mask, w, d, anchor if keep_spawn else Vector2i(-1, -1)):
				continue
			_move_unit(grids, unit, offset, glyphs)
			_write_layers(raw_layers, grids)
			if layout_ok(layer_report(board, nonfill), baseline, required).is_empty():
				var shifted: Array[Vector2i] = []
				for col: Vector2i in unit.cols:
					shifted.append(col + offset)
					moves[unit.origin[col]] = col + offset
				unit.origin = _rekey(unit.origin, offset)
				unit.cols = shifted
				moved += 1
				break
			_move_unit(grids, unit, -offset, glyphs, offset)
			_write_layers(raw_layers, grids)
	if moved > 0:
		_move_rule_params(out, config, moves)
	return moved


## Groups of columns that move together: 4-connected jitter-glyph columns, plus lone rule tiles.
static func _units(grids: Dictionary, glyphs: String, out: Dictionary, config: Dictionary, rule_tiles: bool) -> Array:
	var cols: Dictionary = {}
	for key: Variant in grids:
		for z: int in (grids[key] as Array).size():
			var row: PackedStringArray = grids[key][z]
			for x: int in row.size():
				if row[x] != EMPTY and glyphs.contains(row[x]):
					cols[Vector2i(x, z)] = true
	var units: Array = []
	var seen: Dictionary = {}
	var keys: Array = cols.keys()
	keys.sort()
	for start: Vector2i in keys:
		if seen.has(start):
			continue
		var group: Array[Vector2i] = []
		var queue: Array[Vector2i] = [start]
		seen[start] = true
		while not queue.is_empty():
			var c: Vector2i = queue.pop_back()
			group.append(c)
			for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if cols.has(c + step) and not seen.has(c + step):
					seen[c + step] = true
					queue.append(c + step)
		units.append(_unit(group))
	if rule_tiles:
		var table: Dictionary = config.get("rule_params", {})
		for rule: Variant in out.get("rules", []):
			if not rule is Dictionary or not table.has(str(rule.get("id", ""))) or not rule.get("params") is Dictionary:
				continue
			for param: String in table[str(rule.id)]:
				if str(table[str(rule.id)][param]) != "tiles_xz":
					continue
				for tile: Variant in rule.params.get(param, []):
					if tile is Array and tile.size() >= 2 and not cols.has(Vector2i(int(tile[0]), int(tile[1]))):
						var col := Vector2i(int(tile[0]), int(tile[1]))
						cols[col] = true
						units.append(_unit([col]))
	return units


static func _unit(group: Array) -> Dictionary:
	var cols: Array[Vector2i] = []
	var origin: Dictionary = {}
	for c: Vector2i in group:
		cols.append(c)
		origin[c] = c
	return {"cols": cols, "origin": origin}


static func _rekey(origin: Dictionary, offset: Vector2i) -> Dictionary:
	var out: Dictionary = {}
	for col: Vector2i in origin:
		out[col + offset] = origin[col]
	return out


static func _fits(unit: Dictionary, offset: Vector2i, units: Array, self_index: int, static_cols: Dictionary, mask: Array, w: int, d: int, anchor: Vector2i) -> bool:
	var others: Dictionary = {}
	for i: int in units.size():
		if i != self_index:
			for col: Vector2i in units[i].cols:
				others[col] = true
	for col: Vector2i in unit.cols:
		var to: Vector2i = col + offset
		if to.x < 0 or to.y < 0 or to.x >= w or to.y >= d or to == anchor:
			return false
		if not mask.is_empty() and str(mask[to.y])[to.x] == EMPTY:
			return false
		if static_cols.has(to) and not unit.cols.has(to):
			return false
		for step: Vector2i in [Vector2i.ZERO, Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			if others.has(to + step):
				return false
	return true


## Moves the unit's jitter glyphs by offset. `from_offset` is the unit's current displacement
## relative to unit.cols (non-zero only when undoing a tentative move).
static func _move_unit(grids: Dictionary, unit: Dictionary, offset: Vector2i, glyphs: String, from_offset: Vector2i = Vector2i.ZERO) -> void:
	for key: Variant in grids:
		var grid: Array = grids[key]
		var lifted: Array = []
		for col: Vector2i in unit.cols:
			var at: Vector2i = col + from_offset
			var row: PackedStringArray = grid[at.y]
			if glyphs.contains(row[at.x]) and row[at.x] != EMPTY:
				lifted.append([at + offset, row[at.x]])
				row[at.x] = EMPTY
				grid[at.y] = row
		for entry: Array in lifted:
			var to: Vector2i = entry[0]
			var row: PackedStringArray = grid[to.y]
			row[to.x] = entry[1]
			grid[to.y] = row


static func _write_layers(raw_layers: Dictionary, grids: Dictionary) -> void:
	for key: Variant in grids:
		var rows: Array = []
		for row: PackedStringArray in grids[key]:
			rows.append("".join(row))
		raw_layers[key] = rows


static func _move_rule_params(out: Dictionary, config: Dictionary, moves: Dictionary) -> void:
	var table: Dictionary = config.get("rule_params", {})
	var move: Callable = func(p: Vector2i) -> Vector2i: return moves.get(p, p)
	for rule: Variant in out.get("rules", []):
		if not rule is Dictionary or not table.has(str(rule.get("id", ""))) or not rule.get("params") is Dictionary:
			continue
		for param: String in table[str(rule.id)]:
			var kind: String = str(table[str(rule.id)][param])
			if kind != "dir" and rule.params.has(param):
				rule.params[param] = _map_param(rule.params[param], kind, move, "")
