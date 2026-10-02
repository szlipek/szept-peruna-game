extends SceneTree

const VillageFixture = preload("res://tools/test_village_fixture.gd")

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var village: Node = VillageFixture.new()
	root.add_child(village)
	for building_id in village.BUILDING_IDS:
		assert(village.call("village_illustration", building_id, 5) != null)
		assert(village.call("village_illustration", building_id, 6) != null)
		assert(village.call("village_illustration", building_id, 5) != village.call("village_illustration", building_id, 6))
	village.set("main_menu_open", false)
	village.set("village_open", true)
	village.set("coins", 1800)
	village.set("wood", 270)
	var levels: Dictionary = village.get("building_levels")
	levels["kuznia"] = 5
	village.set("building_levels", levels)
	village.call("handle_village_input", village.call("village_building_rect", "kuznia").get_center())
	assert(village.get("village_selected_id") == "kuznia")
	village.call("handle_village_input", village.call("village_upgrade_rect").get_center())
	assert(village.get("building_levels")["kuznia"] == 6)
	assert(village.get("coins") == 0 and village.get("wood") == 0)
	assert(village.get("village_upgrade_time") > 0.0)
	village.call("handle_village_input", village.call("village_upgrade_rect").get_center())
	assert(village.get("building_levels")["kuznia"] == 6)
	village.set("village_upgrade_time", 0.0)
	village.call("handle_village_input", village.call("village_upgrade_rect").get_center())
	assert(village.get("building_levels")["kuznia"] == 6)
	village.call("handle_village_input", village.call("village_building_rect", "domostwa").get_center())
	assert(village.get("village_selected_id") == "domostwa")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	village.call("_unhandled_input", escape)
	assert(village.get("village_selected_id") == "")
	village.call("_unhandled_input", escape)
	assert(not village.get("village_open") and village.get("main_menu_open"))
	print("Village interaction tests passed")
	quit()
