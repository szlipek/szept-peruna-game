extends SceneTree

# Technical atlas slicing only; preserve generated artwork and alpha.
func _initialize() -> void:
	var source := Image.load_from_file("res://art/environments/level_sources/building_tartak_dry_stages_v01.png")
	var edges := [0, 630, 1370, source.get_width()]
	for stage in 3:
		var sprite := source.get_region(Rect2i(edges[stage], 0, edges[stage + 1] - edges[stage], source.get_height()))
		sprite = sprite.get_region(sprite.get_used_rect())
		var ratio := minf(460.0 / sprite.get_width(), 448.0 / sprite.get_height())
		sprite.resize(roundi(sprite.get_width() * ratio), roundi(sprite.get_height() * ratio), Image.INTERPOLATE_LANCZOS)
		var canvas := Image.create(512, 512, false, Image.FORMAT_RGBA8)
		canvas.fill(Color.TRANSPARENT)
		canvas.blit_rect(sprite, Rect2i(Vector2i.ZERO, sprite.get_size()), Vector2i((512 - sprite.get_width()) / 2, 486 - sprite.get_height()))
		assert(canvas.save_png("res://art/environments/building_tartak_dry_stage_%02d.png" % (stage + 1)) == OK)
	var plaques := Image.load_from_file("res://art/ui/village_plaques_source_v01.png")
	assert(plaques.get_region(Rect2i(0, 0, 1536, 570)).save_png("res://art/ui/village_goal_plaque_v01.png") == OK)
	assert(plaques.get_region(Rect2i(0, 647, 1536, 325)).save_png("res://art/ui/village_mastery_plaque_v01.png") == OK)
	print("Village refresh art prepared")
	quit()
