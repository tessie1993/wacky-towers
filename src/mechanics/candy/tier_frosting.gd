class_name TierFrostingRule extends RuleBehaviour
## Counts the authored two-layer tiers using flavour share, alternation and enough coverage.
const PLUGIN_ID := &"tier_frosting"
var _tiers: Array = []
func subscribed_hooks() -> Array[StringName]:return [&"on_resolve_end"]
func handle(_hook: StringName,_ctx: HookContext,api: RuleApi) -> void:
	var span: int = maxi(1,int(api.param(&"tier_layers",2)))
	var height: int = int(api.goal_config().get("h_target",8))
	var share: float = clampf(float(api.param(&"frost_share",0.5)),0.0,1.0)
	var previous: int = 0
	var frosted: int = 0
	_tiers.clear()
	for tier: int in int(ceil(float(height)/span)):
		var counts: Dictionary = {};var filled: int = 0;var active: int = 0
		for c: Vector3i in CandyCells.cells(api):
			if api.layer_of(c)<tier*span or api.layer_of(c)>=mini(height,(tier+1)*span):continue
			active+=1
			if api.kind_at(c)!=0:
				filled+=1
				var hue: int = api.color_at(c)
				if hue>0:counts[hue]=int(counts.get(hue,0))+1
		var leader: int = 0;var lead_count: int = 0
		for hue: Variant in counts:
			if int(counts[hue])>lead_count or (int(counts[hue])==lead_count and int(hue)<leader):leader=int(hue);lead_count=int(counts[hue])
		var qualifies: bool = filled>0 and float(lead_count)/filled>=share and leader!=previous
		if qualifies:frosted+=1
		_tiers.append({"flavour":leader,"frosted":qualifies,"filled":filled})
		previous=leader
	api.goal_metric(&"frosted_tiers",frosted)
	api.emit(&"frosted_tiers",{"count":frosted,"tiers":_tiers})
func snapshot() -> Dictionary:return {"tiers":_tiers.duplicate(true)}
