extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene: Node = load("res://scenes/puzzle_level.tscn").instantiate()
	root.add_child(scene)
	scene.set("main_menu_open", false)
	scene.set("map_open", true)
	var preview_args := OS.get_cmdline_user_args()
	var mountains := preview_args.has("mountains")
	scene.set("map_page", 9 if mountains else 7)
	scene.set("unlocked_level", 50 if mountains else 40)
	scene.set("level_index", 49 if mountains else 39)
	scene.set("level_stars", {46: 3, 47: 2, 48: 0, 49: 1, 50: 0} if mountains else {36: 3, 37: 2, 38: 0, 39: 1, 40: 3})
	for size in [Vector2i(540, 960), Vector2i(390, 844), Vector2i(900, 960)]:
		root.size = size
		for frame in 5:
			await process_frame
		scene.queue_redraw()
		await process_frame
		RenderingServer.force_draw()
		var screenshot := root.get_texture().get_image()
		var path := "res://.godot/world-map-%s%dx%d-preview.png" % ["mountains-" if mountains else "", size.x, size.y]
		if screenshot == null or screenshot.save_png(path) != OK:
			quit(1)
			return
		print("World map preview: %s" % path)
	quit()
