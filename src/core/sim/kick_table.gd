class_name KickTable extends RefCounted
## Pure list builder for Movement.try_rotate (Movement & Rotation GDD F2). Applies nothing, reads no board.
## Usage: var offs: Array[Vector3i] = KickTable.candidates(Orientations.Axis.Y, Vector3i(0, -1, 0), Vector2(3.5, 3.5), Vector3i(3, 5, 1), 3, {})

## Default for control.kick_wide_min_extent (GDD Tuning Knobs).
const DEFAULT_WIDE_MIN_EXTENT: int = 4
## control.kick_order value that keeps the fixed tie order instead of sorting toward the centre.
const ORDER_FIXED: String = "fixed"


## Kick offsets in try-order; the first is always Vector3i.ZERO (in place).
## axis: world rotation axis; down: unit gravity vector; footprint_center: centre of the active footprint in the two
## ground coordinates (the non-down axes in x, y, z order); pivot: current pivot; longest_extent: piece longest bbox side.
## opts (all optional): kick_enabled (true), kick_off_axis (true), kick_wide_min_extent (4), kick_order ("centre"|"fixed").
## Ties and kick_order "fixed" use the order +a1, -a1, +a2, -a2 over the ground axes in x, y, z order (GDD F2).
static func candidates(axis: Orientations.Axis, down: Vector3i, footprint_center: Vector2, pivot: Vector3i,
		longest_extent: int, opts: Dictionary) -> Array[Vector3i]:
	var out: Array[Vector3i] = [Vector3i.ZERO]
	if not bool(opts.get("kick_enabled", true)):
		return out
	var off_axis: bool = bool(opts.get("kick_off_axis", true))
	var wide_min: int = int(opts.get("kick_wide_min_extent", DEFAULT_WIDE_MIN_EXTENT))
	var by_centre: bool = str(opts.get("kick_order", "centre")) != ORDER_FIXED

	var ground: Array[int] = []
	var g_in: Array[Vector3i] = []
	var g_out: Array[Vector3i] = []
	for a: int in 3:
		if down[a] != 0:
			continue
		ground.append(a)
		for s: int in [1, -1]:
			var o: Vector3i = Vector3i.ZERO
			o[a] = s
			if a == int(axis):
				g_out.append(o)
			else:
				g_in.append(o)
	var up: Vector3i = -down
	if by_centre:
		g_in = _sorted(g_in, ground, pivot, footprint_center)
		g_out = _sorted(g_out, ground, pivot, footprint_center)

	out.append_array(g_in)
	out.append(up)
	for o: Vector3i in g_in:
		out.append(o + up)
	if off_axis:
		out.append_array(g_out)
		for o: Vector3i in g_out:
			out.append(o + up)
	if longest_extent >= wide_min:
		for o: Vector3i in g_in:
			out.append(o * 2)
	return out


## True if the offset has a component against the down axis (an up-kick, counted against the budget).
static func is_up_kick(offset: Vector3i, down: Vector3i) -> bool:
	return (offset.x * down.x + offset.y * down.y + offset.z * down.z) < 0


## True if the offset moves 2 cells along any axis (a wide kick, GDD rule 12).
static func is_wide(offset: Vector3i) -> bool:
	return maxi(absi(offset.x), maxi(absi(offset.y), absi(offset.z))) >= 2


# Stable insertion sort by squared distance of the resulting pivot's ground coords to the footprint centre.
static func _sorted(list: Array[Vector3i], ground: Array[int], pivot: Vector3i, center: Vector2) -> Array[Vector3i]:
	var out: Array[Vector3i] = list.duplicate()
	var keys: Array[float] = []
	for o: Vector3i in out:
		var p: Vector3i = pivot + o
		keys.append(Vector2(p[ground[0]], p[ground[1]]).distance_squared_to(center))
	for i: int in range(1, out.size()):
		var o: Vector3i = out[i]
		var k: float = keys[i]
		var j: int = i - 1
		while j >= 0 and keys[j] > k:
			out[j + 1] = out[j]
			keys[j + 1] = keys[j]
			j -= 1
		out[j + 1] = o
		keys[j + 1] = k
	return out
