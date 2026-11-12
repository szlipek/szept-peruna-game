extends SceneTree

const Fixture = preload("res://tools/test_village_fixture.gd")

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game := Fixture.new()
	root.add_child(game)
	game.set_process(false)
	AudioServer.set_bus_mute(0, true)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	game.player_opening.stage = ""
	game.player_opening.home_tutorial_step = ""
	game.region_intro_open = false
	game.daily_reward_popup_open = false
	game.main_menu_open = true
	game.victory_screen_open = false
	game.unlocked_level = 9
	game.coins = 1705
	game.wood = 52
	game.experience = 781
	game.perun_sparks = 3
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://tmp/settings_previews"))
	for size in [Vector2i(540, 960), Vector2i(390, 844)]:
		root.size = size
		await process_frame
		game.sfx_enabled = false
		game.music_enabled = false
		game.vibration_enabled = false
		game.help_open = false
		game.settings_open = false
		assert(game.settings_button_rect().size == game.help_button_rect().size)
		assert(game.settings_button_rect().position.y == game.help_button_rect().position.y)
		await save_capture(game, "home-settings-icon-%d" % size.x)
		game.handle_main_menu_input(game.settings_button_rect().get_center())
		assert(game.settings_open and game.help_open)
		await save_capture(game, "settings-off-%d" % size.x)
		for index in 3:
			game.handle_help_input(game.audio_setting_rect(index).get_center())
		assert(game.sfx_enabled and game.music_enabled and game.vibration_enabled)
		await save_capture(game, "settings-on-%d" % size.x)
		for index in 3:
			game.handle_help_input(game.audio_setting_rect(index).get_center())
		assert(not game.sfx_enabled and not game.music_enabled and not game.vibration_enabled)
		game.handle_help_input(game.settings_guide_rect().get_center())
		assert(game.help_open and not game.settings_open)
		game.handle_help_input(game.help_close_rect().get_center())
		assert(not game.help_open)
		game.handle_main_menu_input(game.settings_button_rect().get_center())
		game.handle_help_input(game.help_close_rect().get_center())
		assert(not game.help_open and not game.settings_open)
	game.free()
	print("PASS: settings icon, all three toggles, guide and Done at both screen sizes")
	quit()

func save_capture(game: Node, label: String) -> void:
	game.queue_redraw()
	for frame in 4:
		await process_frame
	RenderingServer.force_draw()
	assert(root.get_texture().get_image().save_png("res://tmp/settings_previews/%s.png" % label) == OK)
	print("PREVIEW: " + label)
