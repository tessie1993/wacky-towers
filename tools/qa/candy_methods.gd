extends SceneTree
func _initialize()->void:
	var s:Script=load("res://tests/unit/mechanics/candy_rules_test.gd")
	for m:Dictionary in s.get_script_method_list():
		if String(m.name).begins_with("test_"):print(m.name)
	quit()
