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
	game.village_open = true
	game.coins = 995
	game.wood = 82
	game.level_stars = {5: 1, 10: 1, 20: 1, 50: 1, 100: 1, 250: 1}
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/village_refresh"))
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
			game.building_levels["tartak"] = maxi(1, level)
			if level == 0:
				game.building_levels["domostwa"] = 1
				game.building_levels["dwor_wiecowy"] = 1
			game.village_selected_id = ""
			await save_capture(game, "village-%02d-%d" % [level, size.x])
		game.village_selected_id = "tartak"
		await save_capture(game, "sawmill-inspector-%d" % size.x)
	game.free()
	quit()

func save_capture(game: Node, label: String) -> void:
	game.queue_redraw()
	for frame in 3:
		await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://tmp/village_refresh/%s.png" % label) == OK)
	print("PREVIEW: " + label)
