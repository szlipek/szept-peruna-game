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
	root.size = Vector2i(540, 960)
	var game := Preview.new()
	root.add_child(game)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	root.size = Vector2i(540, 960)
	await process_frame
	game.set_process(false)
	game.player_opening.stage = ""
	game.player_opening.home_tutorial_step = ""
	game.region_intro_open = false
	game.daily_reward_popup_open = false
	game.coins = 5000
	game.wood = 120
	game.experience = 600
	game.perun_sparks = 8
	if OS.get_cmdline_user_args().has("mission-badge"):
		game.main_menu_open = true
		game.daily_missions = [{"target": 1, "progress": 1, "reward": 100}]
		game.weekly_missions = []
		await capture_state(game, "mission-badge-one")
		game.daily_missions = []
		for index in 6:
			game.daily_missions.append({"target": 1, "progress": 1, "reward": 100})
		await capture_state(game, "mission-badge-six")
		quit()
		return
	game.handle_roster_upgrade("wszebor")
	game.roster_hero_index = game.HERO_IDS.find("wszebor")
	game.main_menu_open = false
	game.roster_open = true
	await capture_state(game, "recruited-hero")
	game.roster_open = false
	game.main_menu_open = true
	game.missions_open = true
	game.daily_missions = [
		{"title": "Punkty z walk: 2700", "progress": 900, "target": 2700, "reward": 100},
		{"title": "Zdobądź gwiazdki: 3", "progress": 3, "target": 3, "reward": 100},
		{"title": "Ukończ cele dodatkowe: 2", "progress": 2, "target": 2, "reward": 100, "claimed": true}
	]
	game.weekly_missions = [
		{"title": "Zgromadzone punkty: 27000", "progress": 27000, "target": 27000, "reward": 350},
		{"title": "Potężne połączenia: 8", "progress": 4, "target": 8, "reward": 350},
		{"title": "Pokonani wrogowie: 6 zwycięstw", "progress": 6, "target": 6, "reward": 350, "claimed": true}
	]
	for size in [Vector2i(540, 960), Vector2i(390, 844)]:
		root.size = size
		await capture_state(game, "missions")
	game.missions_open = false
	game.main_menu_open = false
	game.village_open = true
	for building_id in game.BUILDING_IDS:
		game.building_levels[building_id] = 1
	game.sawmill_stored_wood = 40
	for size in [Vector2i(540, 960), Vector2i(390, 844)]:
		root.size = size
		game.village_selected_id = ""
		await capture_state(game, "village-stock")
		game.village_selected_id = "tartak"
		await capture_state(game, "sawmill-collect")
	quit()

func capture_state(game: Node2D, label: String) -> void:
	game.queue_redraw()
	for frame in 4:
		await process_frame
	RenderingServer.force_draw()
	var screenshot := root.get_texture().get_image()
	assert(screenshot != null and not screenshot.is_empty())
	var path := "res://.godot/%s-%dx%d.png" % [label, root.size.x, root.size.y]
	assert(screenshot.save_png(path) == OK)
	print("Preview saved: ", path)
