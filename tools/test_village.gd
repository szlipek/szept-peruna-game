extends SceneTree

const VillageFixture = preload("res://tools/test_village_fixture.gd")

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var village: Node = VillageFixture.new()
	root.add_child(village)
	village.player_opening.stage = ""
	village.set("region_intro_open", false)
	village.set("daily_reward_popup_open", false)
	for building_id in village.BUILDING_IDS:
		assert(village.call("village_illustration", building_id, 5) != null)
		assert(village.call("village_illustration", building_id, 6) != null)
		if building_id != "tartak":
			assert(village.call("village_illustration", building_id, 5) != village.call("village_illustration", building_id, 6))
	village.set("main_menu_open", false)
	village.set("village_open", true)
	var levels: Dictionary = village.get("building_levels")
	levels["kuznia"] = 5
	levels["dwor_wiecowy"] = 6
	village.set("building_levels", levels)
	var cost: Dictionary = village.call("building_cost", "kuznia")
	village.set("coins", int(cost["coins"]))
	village.set("wood", int(cost["wood"]))
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
	# Po darmowej budowie tartaku X kończy samouczek i zamyka inspektor.
	village.set("main_menu_open", false)
	village.set("village_open", true)
	village.set("village_selected_id", "tartak")
	village.player_opening.home_tutorial_step = "buy_sawmill"
	village.call("handle_village_input", village.call("village_upgrade_rect").get_center())
	assert(village.get("building_levels")["tartak"] == 1)
	assert(village.player_opening.home_tutorial_step == "sawmill_built")
	village.set("village_upgrade_time", 0.0)
	village.call("handle_village_input", village.call("village_inspector_close_rect").get_center())
	assert(village.get("village_selected_id") == "")
	assert(village.player_opening.home_tutorial_step == "")
	assert(village.get("village_open") and not village.get("main_menu_open"))
	village.call("handle_village_input", village.call("village_building_rect", "tartak").get_center())
	assert(village.get("village_selected_id") == "tartak")
	village.call("handle_village_input", village.call("village_inspector_close_rect").get_center())
	assert(village.get("village_selected_id") == "")
	print("Village interaction tests passed")
	quit()
