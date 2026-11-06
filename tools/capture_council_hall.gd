extends SceneTree

const Fixture = preload("res://tools/test_village_fixture.gd")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game := Fixture.new()
	root.add_child(game)
	game.set_process(false)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	game.player_opening.stage = ""
	game.player_opening.home_tutorial_step = ""
	game.region_intro_open = false
	game.daily_reward_popup_open = false
	game.main_menu_open = false
	game.victory_screen_open = false
	game.coins = 10000
	game.wood = 150
	game.level_stars = {5: 1, 10: 1, 20: 1, 50: 1, 100: 1, 250: 1}
	for size in [Vector2i(540, 960), Vector2i(390, 844)]:
		root.size = size
		await process_frame
		for level in [0, 1, 25, 50]:
			game.mastery_claims.clear()
			if level == 50:
				for id in 50:
					game.mastery_claims[str(id + 1)] = true
			for building_id in game.BUILDING_IDS:
				game.building_levels[building_id] = level
			game.village_open = true
			game.training_open = false
			game.village_selected_id = ""
			await save_capture(game, "village-level-%02d-%d" % [level, size.x])
		game.village_selected_id = "dwor_wiecowy"
		game.building_levels["dwor_wiecowy"] = 49
		await save_capture(game, "hall-preview-49-%d" % size.x)
		game.building_levels["dwor_wiecowy"] = 2
		game.building_levels["kuznia"] = 1
		game.building_levels["chata_zielarki"] = 0
		game.village_selected_id = "dwor_wiecowy"
		await save_capture(game, "hall-requirements-%d" % size.x)
		game.open_forest_expeditions()
		await save_capture(game, "forest-expeditions-%d" % size.x)
		game.building_levels["dwor_wiecowy"] = 8
		game.training_scroll = game.training_scroll_max()
		await save_capture(game, "forest-expeditions-late-%d" % size.x)
	root.size = Vector2i(540, 960)
	game.training_battle = game.ForestExpeditions.catalog(game.building_levels)[0]
	game.training_open = false
	game.village_open = false
	game.start_level(0, game.training_battle)
	game.main_menu_open = false
	await save_capture(game, "forest-battle-540")
	game.free()
	quit(0)

func save_capture(game: Node, label: String) -> void:
	game.queue_redraw()
	for frame in 3:
		await process_frame
	RenderingServer.force_draw()
	var screenshot := root.get_texture().get_image()
	if screenshot == null or screenshot.save_png("res://tmp/council_hall_previews/%s.png" % label) != OK:
		push_error("Nie udało się zapisać podglądu " + label)
		quit(1)
	print("PREVIEW: " + label)
