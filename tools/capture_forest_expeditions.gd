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
	game.building_levels["dwor_wiecowy"] = 2
	game.building_levels["tartak"] = 1
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/forest_expeditions"))
	for size in [Vector2i(540, 960), Vector2i(390, 844)]:
		root.size = size
		await process_frame
		game.open_forest_expeditions()
		game.expedition_bonus_claims.clear()
		game.building_levels["dwor_wiecowy"] = 2
		await save_capture(game, "forest-expeditions-%d" % size.x)
		# Newly laid out cards must select the same mission as their illustration.
		game.handle_training_input(game.training_choice_rect(3).get_center())
		assert(game.training_open and game.forest_catalog_open)
		game.expedition_bonus_claims["polana"] = Time.get_date_string_from_system()
		await save_capture(game, "forest-expeditions-bonus-claimed-%d" % size.x)
		game.building_levels["dwor_wiecowy"] = 8
		game.training_scroll = game.training_scroll_max()
		await save_capture(game, "forest-expeditions-unlocked-%d" % size.x)
		game.handle_training_input(game.training_choice_rect(5).get_center())
		assert(not game.training_open and game.training_battle["id"] == "noc")
		game.open_forest_expeditions()
		game.handle_training_input(game.training_close_rect().get_center())
		assert(game.village_open and not game.training_open)
	game.free()
	print("PASS: expedition card selection, locks, scrolling and return to village")
	quit()

func save_capture(game: Node, label: String) -> void:
	game.queue_redraw()
	for frame in 3:
		await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://tmp/forest_expeditions/%s.png" % label) == OK)
	print("PREVIEW: " + label)
