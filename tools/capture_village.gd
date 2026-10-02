extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene: Node = load("res://scenes/puzzle_level.tscn").instantiate()
	root.add_child(scene)
	scene.set("main_menu_open", false)
	scene.set("village_open", true)
	scene.set("region_intro_open", false)
	scene.set("coins", 3200)
	scene.set("wood", 480)
	scene.set("building_levels", {"domostwa": 16, "kuznia": 5, "chata_zielarki": 2, "swiety_gaj": 2, "spichlerz": 6, "wieza_peruna": 3})
	assert(scene.call("village_illustration", "kuznia", 5) != scene.call("village_illustration", "kuznia", 6))
	for size in [Vector2i(540, 960), Vector2i(390, 844)]:
		root.size = size
		for frame in 5:
			await process_frame
		scene.set("village_selected_id", "")
		await capture_state(scene, size, "overview")
		scene.call("handle_village_input", scene.call("village_building_rect", "kuznia").get_center())
		assert(scene.get("village_selected_id") == "kuznia")
		await capture_state(scene, size, "inspector")
		scene.call("handle_village_input", scene.call("village_inspector_close_rect").get_center())
		assert(scene.get("village_selected_id") == "")
	root.size = Vector2i(540, 960)
	scene.set("village_selected_id", "kuznia")
	scene.set("coins", 0)
	scene.call("handle_village_input", scene.call("village_upgrade_rect").get_center())
	assert(scene.get("building_levels")["kuznia"] == 5)
	await capture_state(scene, root.size, "unaffordable")
	scene.set("coins", 3200)
	var levels: Dictionary = scene.get("building_levels")
	levels["kuznia"] = 50
	scene.set("building_levels", levels)
	await capture_state(scene, root.size, "max-level")
	levels["kuznia"] = 6
	scene.set("building_levels", levels)
	scene.set("village_upgrade_id", "kuznia")
	scene.set("village_upgrade_from_level", 5)
	scene.set("village_upgrade_time", 0.82)
	await capture_state(scene, root.size, "construction")
	scene.set("village_upgrade_time", 0.32)
	await capture_state(scene, root.size, "upgraded")
	quit()

func capture_state(scene: Node, size: Vector2i, state_name: String) -> void:
	scene.queue_redraw()
	await process_frame
	RenderingServer.force_draw()
	var screenshot := root.get_texture().get_image()
	var path := "res://.godot/village-%s-%dx%d-preview.png" % [state_name, size.x, size.y]
	if screenshot == null or screenshot.save_png(path) != OK:
		quit(1)
		return
	print("Village preview: %s" % path)
