class_name WtProgression extends RefCounted
## Pure gates use earned level stars, independently of the spendable Star Jar.

## Sum the ten main-path bests only.
static func biome_stars(records: Dictionary, biome: String) -> int:
	var total: int = 0
	for tier: int in range(1, 11):
		total += int(records.get("%s_%02d" % [biome, tier], {}).get("stars", 0))
	return total

## A biome opens only after the preceding finale and its earned-star gate.
static func biome_open(records: Dictionary, biome: String, order: Array, gate: int = 15) -> bool:
	var index: int = order.find(biome)
	if index < 0:
		return false
	if index == 0:
		return true
	var previous: String = str(order[index - 1])
	return int(records.get(previous + "_10", {}).get("stars", 0)) > 0 and biome_stars(records, previous) >= gate

## Main levels are linear; bonus needs 20 stars, hard-track needs the finale.
static func level_open(records: Dictionary, entry: Dictionary, order: Array, gate: int = 15, bonus_gate: int = 20) -> bool:
	var biome: String = str(entry.get("biome", "meadow"))
	if not biome_open(records, biome, order, gate):
		return false
	var tier: int = int(entry.get("tier", 1))
	if tier == 1:
		return true
	if tier == 11:
		return biome_stars(records, biome) >= bonus_gate
	if tier > 11:
		return int(records.get(biome + "_10", {}).get("stars", 0)) > 0
	return int(records.get("%s_%02d" % [biome, tier - 1], {}).get("stars", 0)) > 0
