extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540, 960)
	var scene: Node = load("res://scenes/puzzle_level.tscn").instantiate()
	root.add_child(scene)
	var preview_args := OS.get_cmdline_user_args()
	var single_hero := preview_args.has("single-hero") or preview_args.has("first-level")
	var first_level := preview_args.has("first-level")
	var reward_available := preview_args.has("reward-available")
	var reward_opening := preview_args.has("reward-opening")
	var reward_claimed := preview_args.has("reward-claimed")
	if single_hero:
		var preview_team: Array[String] = ["lada"]
		scene.set("active_heroes", preview_team)
		scene.queue_redraw()
	if first_level:
		scene.set("unlocked_level", 1)
		scene.queue_redraw()
	if reward_available:
		scene.set("daily_reward_day", "")
		scene.queue_redraw()
	elif reward_opening or reward_claimed:
		scene.set("daily_reward_day", Time.get_date_string_from_system())
		scene.queue_redraw()
	for frame in 20:
		await process_frame
	if reward_opening:
		scene.set("daily_reward_open_time", 0.44)
		scene.queue_redraw()
		await process_frame
	RenderingServer.force_draw()
	var image := root.get_texture().get_image()
	if image == null:
		push_error("Nie udało się odczytać obrazu okna.")
		quit(1)
		return
	var preview_name := "home-menu-reward-opening-preview.png" if reward_opening else ("home-menu-reward-claimed-preview.png" if reward_claimed else ("home-menu-reward-available-preview.png" if reward_available else ("home-menu-first-level-preview.png" if first_level else ("home-menu-single-hero-preview.png" if single_hero else "home-menu-preview.png"))))
	var destination := ProjectSettings.globalize_path("res://.godot/%s" % preview_name)
	var result := image.save_png(destination)
	print("Menu preview: %s, %s" % [destination, result])
	quit(0 if result == OK else 1)
