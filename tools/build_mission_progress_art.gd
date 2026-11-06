extends SceneTree

# Crop transparent atlas padding without changing the generated artwork.
func _initialize() -> void:
	for material in ["amber", "emerald"]:
		var source := Image.load_from_file("res://art/ui/mission_progress_%s_source_v01.png" % material)
		assert(source != null)
		var left := source.get_width()
		var right := 0
		var top := source.get_height()
		var bottom := 0
		for y in source.get_height():
			for x in source.get_width():
				if source.get_pixel(x, y).a > 0.32:
					left = mini(left, x)
					right = maxi(right, x + 1)
					top = mini(top, y)
					bottom = maxi(bottom, y + 1)
		assert(right > left and bottom > top)
		var strip := source.get_region(Rect2i(left, top, right - left, bottom - top))
		assert(strip.save_png("res://art/ui/mission_progress_%s_fill_v01.png" % material) == OK)
		print("Prepared mission progress material: " + material)
	quit()
