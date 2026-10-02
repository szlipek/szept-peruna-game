extends SceneTree

func _initialize() -> void:
	var atlas := Image.load_from_file(ProjectSettings.globalize_path("res://art/ui/world_map_objective_badges_alpha_v01.png"))
	var plaque := Image.load_from_file(ProjectSettings.globalize_path("res://art/ui/world_map_level_number_source_v01.png"))
	if atlas == null or plaque == null:
		quit(1)
		return
	var objectives := ["defeat_enemy", "survive", "collect_amber", "collect_rune", "clear_obstacles", "score"]
	var cell_size := Vector2i(atlas.get_width() / 3, atlas.get_height() / 2)
	for index in objectives.size():
		var cell := atlas.get_region(Rect2i(Vector2i(index % 3, index / 3) * cell_size, cell_size))
		var cropped := crop_alpha(cell)
		var target := Image.create(256, 256, false, Image.FORMAT_RGBA8)
		target.fill(Color.TRANSPARENT)
		var scale_factor := 248.0 / maxf(cropped.get_width(), cropped.get_height())
		cropped.resize(roundi(cropped.get_width() * scale_factor), roundi(cropped.get_height() * scale_factor), Image.INTERPOLATE_LANCZOS)
		target.blit_rect(cropped, Rect2i(Vector2i.ZERO, cropped.get_size()), (target.get_size() - cropped.get_size()) / 2)
		if target.save_png("res://art/ui/world_map_objective_%s_v01.png" % objectives[index]) != OK:
			quit(1)
			return
	var number_plate := crop_alpha(plaque)
	number_plate.resize(512, roundi(number_plate.get_height() * 512.0 / number_plate.get_width()), Image.INTERPOLATE_LANCZOS)
	if number_plate.save_png("res://art/ui/world_map_level_number_v01.png") != OK:
		quit(1)
		return
	print("Prepared six objective badges and the level-number plaque.")
	quit()

func crop_alpha(source: Image) -> Image:
	# Faint generated alpha noise must not enlarge the sprite's visible bounds.
	var minimum := source.get_size()
	var maximum := Vector2i(-1, -1)
	for y in source.get_height():
		for x in source.get_width():
			if source.get_pixel(x, y).a > 0.1:
				minimum.x = mini(minimum.x, x)
				minimum.y = mini(minimum.y, y)
				maximum.x = maxi(maximum.x, x)
				maximum.y = maxi(maximum.y, y)
	if maximum.x < 0:
		return source
	return source.get_region(Rect2i(minimum, maximum - minimum + Vector2i.ONE))
