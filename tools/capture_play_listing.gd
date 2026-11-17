extends SceneTree

class Preview:
	extends "res://scripts/puzzle_level.gd"
	func load_progress() -> void:
		pass
	func save_progress() -> void:
		pass

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	if OS.get_cmdline_user_args().has("hd"):
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		root.content_scale_size = Vector2i(540, 960)
		root.size = Vector2i(1080, 1920)
	else:
		root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		root.size = Vector2i(540, 960)
	var game := Preview.new()
	root.add_child(game)
	await process_frame
	game.set_process(false)
	game.player_opening.stage = ""
	game.player_opening.home_tutorial_step = ""
	game.tutorial_completed = true
	game.region_intro_open = false
	game.daily_reward_popup_open = false
	game.unlocked_level = 18
	game.coins = 1750
	game.wood = 320
	for hero_id in ["lada", "brun", "mieta"]:
		game.owned_heroes[hero_id] = true
		game.hero_levels[hero_id] = 3
	game.active_heroes.assign(["lada", "brun", "mieta"])
	game.main_menu_open = true
	await save_state(game, "01-menu")
	game.start_level(8)
	game.main_menu_open = false
	game.region_intro_open = false
	await save_state(game, "02-walka")
	game.main_menu_open = false
	game.roster_open = true
	await save_state(game, "03-druzyna")
	game.roster_open = false
	game.map_open = true
	game.map_page = 3
	await save_state(game, "04-mapa")
	game.map_open = false
	game.village_open = true
	for building_id in game.BUILDING_IDS:
		game.building_levels[building_id] = 1
	game.village_selected_id = ""
	await save_state(game, "05-osada")
	game.queue_free()
	print("Zrzuty zapisano w docs/google-play-zrzuty/.")
	quit()

func save_state(game: Node, file_name: String) -> void:
	var folder := "res://docs/google-play-zrzuty-hd" if OS.get_cmdline_user_args().has("hd") else "res://docs/google-play-zrzuty"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	game.queue_redraw()
	for frame in 5:
		await process_frame
	RenderingServer.force_draw()
	var image := root.get_texture().get_image()
	assert(image != null and not image.is_empty())
	image.convert(Image.FORMAT_RGB8)
	assert(image.save_png("%s/%s.png" % [folder, file_name]) == OK)
