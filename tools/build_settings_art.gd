extends SceneTree

# Technical atlas cropping; keep the generated pixels and alpha intact.
func _initialize() -> void:
	var icon := tight_crop(Image.load_from_file("res://art/ui/settings_icon_source_v01.png"))
	assert(icon.save_png("res://art/ui/home_settings_icon_v01.png") == OK)
	var panel := tight_crop(Image.load_from_file("res://art/ui/settings_panel_source_v01.png"))
	assert(panel.save_png("res://art/ui/settings_panel_v01.png") == OK)
	var toggles := Image.load_from_file("res://art/ui/settings_toggles_source_v01.png")
	for index in 2:
		var left := index * toggles.get_width() / 2
		var cell := toggles.get_region(Rect2i(left, 0, toggles.get_width() / 2, toggles.get_height()))
		var sprite := tight_crop(cell)
		assert(sprite.save_png("res://art/ui/settings_toggle_%s_v01.png" % ("on" if index == 0 else "off")) == OK)
	print("Settings icon, panel and toggle states prepared")
	quit()

func tight_crop(source: Image) -> Image:
	assert(source != null)
	var left := source.get_width()
	var top := source.get_height()
	var right := 0
	var bottom := 0
	for y in source.get_height():
		for x in source.get_width():
			if source.get_pixel(x, y).a > 0.32:
				left = mini(left, x)
				top = mini(top, y)
				right = maxi(right, x + 1)
				bottom = maxi(bottom, y + 1)
	assert(right > left and bottom > top)
	return source.get_region(Rect2i(left, top, right - left, bottom - top))
