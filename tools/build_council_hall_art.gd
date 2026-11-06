extends SceneTree

# Techniczne rozcięcie atlasów ImageGen; zachowuje kanał alfa i ilustracje.
func _initialize() -> void:
	var destination := "res://art/environments/building_levels/dwor_wiecowy"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(destination))
	for stage in 5:
		var first := stage * 10 + 1
		var path := "res://art/environments/level_sources/building_dwor_wiecowy_levels_%02d_%02d_v01.png" % [first, first + 9]
		var source := Image.load_from_file(ProjectSettings.globalize_path(path))
		if source == null:
			push_error("Brak atlasu: " + path)
			quit(1)
			return
		for cell in 10:
			var col := cell % 5
			var row := int(cell / 5)
			var left := roundi(float(col) * source.get_width() / 5.0)
			var right := roundi(float(col + 1) * source.get_width() / 5.0)
			var top := roundi(float(row) * source.get_height() / 2.0)
			var bottom := roundi(float(row + 1) * source.get_height() / 2.0)
			var sprite := source.get_region(Rect2i(left + 2, top + 2, right - left - 4, bottom - top - 4))
			sprite.convert(Image.FORMAT_RGBA8)
			var bounds := sprite.get_used_rect()
			if bounds.size.x < 50 or bounds.size.y < 50:
				push_error("Pusta komórka atlasu: %d" % (first + cell))
				quit(1)
				return
			sprite = sprite.get_region(bounds)
			var ratio := minf(440.0 / sprite.get_width(), 448.0 / sprite.get_height())
			sprite.resize(roundi(sprite.get_width() * ratio), roundi(sprite.get_height() * ratio), Image.INTERPOLATE_LANCZOS)
			var canvas := Image.create(512, 512, false, Image.FORMAT_RGBA8)
			canvas.fill(Color.TRANSPARENT)
			canvas.blit_rect(sprite, Rect2i(Vector2i.ZERO, sprite.get_size()), Vector2i(int((512 - sprite.get_width()) / 2), 486 - sprite.get_height()))
			if canvas.save_png("%s/building_dwor_wiecowy_level_%02d.png" % [destination, first + cell]) != OK:
				quit(1)
				return
	print("Dwór Wiecowy: zapisano 50 osobnych grafik z przezroczystością.")
	quit(0)
