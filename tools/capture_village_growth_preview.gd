extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540, 960)
	var scene: Node = load("res://scenes/puzzle_level.tscn").instantiate()
	root.add_child(scene)
	scene.set("main_menu_open", false)
	scene.set("village_open", true)
	scene.set("region_intro_open", false)
	scene.set("village_selected_id", "spichlerz")
	scene.set("coins", 3200)
	scene.set("wood", 480)
	for level in [6, 7, 25, 26]:
		var levels: Dictionary = scene.get("building_levels")
		levels["spichlerz"] = level
		scene.set("building_levels", levels)
		scene.queue_redraw()
		for frame in 3:
			await process_frame
		RenderingServer.force_draw()
		var image := root.get_texture().get_image()
		var destination := ProjectSettings.globalize_path("res://.godot/spichlerz-level%d-preview.png" % level)
		if image == null or image.save_png(destination) != OK:
			quit(1)
			return
		print("Village preview: %s" % destination)
	quit(0)
