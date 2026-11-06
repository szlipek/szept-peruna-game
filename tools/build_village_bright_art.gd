extends SceneTree

const IDS := ["domostwa", "swiety_gaj", "wieza_peruna", "kuznia", "chata_zielarki", "spichlerz"]

func _initialize() -> void:
	for id in IDS:
		var path := "res://art/environments/level_sources/building_%s_bright_sheet_v01.png" % id
		var source := Image.load_from_file(path)
		assert(source != null, "Missing atlas: " + id)
		var ranges: Array[Vector2i] = []
		var start := -1
		for x in source.get_width() + 1:
			var count := 0
			if x < source.get_width():
				for y in source.get_height():
					if source.get_pixel(x, y).a > 0.32:
						count += 1
			if count > 3:
				if start < 0:
					start = x
			elif start >= 0:
				if x - start > 25:
					ranges.append(Vector2i(start, x))
				start = -1
		# The soft roof edges in these two generated atlases meet in the gutters.
		if id == "kuznia":
			ranges = [Vector2i(20, 398), Vector2i(398, 786), Vector2i(786, 1193), Vector2i(1193, 1628), Vector2i(1628, 2100)]
		elif id == "spichlerz":
			ranges = [Vector2i(12, 310), Vector2i(310, 648), Vector2i(648, 1054), Vector2i(1054, 1496), Vector2i(1496, 1983)]
		assert(ranges.size() == 5, "%s: expected 5 isolated sprites, got %s" % [id, ranges])
		var stages: Array[Image] = []
		for bounds in ranges:
			var sprite := source.get_region(Rect2i(bounds.x, 0, bounds.y - bounds.x, source.get_height()))
			# Ignore near-transparent atlas padding when choosing the crop, while
			# preserving the original alpha and all pixels inside the crop.
			var left := sprite.get_width()
			var top := sprite.get_height()
			var right := 0
			var bottom := 0
			for y in sprite.get_height():
				for x in sprite.get_width():
					if sprite.get_pixel(x, y).a > 0.32:
						left = mini(left, x)
						top = mini(top, y)
						right = maxi(right, x + 1)
						bottom = maxi(bottom, y + 1)
			stages.append(sprite.get_region(Rect2i(left, top, right - left, bottom - top)))
		var destination := "res://art/environments/building_levels_bright/%s" % id
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(destination))
		for level in 51:
			var stage := clampi((maxi(1, level) - 1) / 10, 0, 4)
			var within_stage := (maxi(1, level) - 1) % 10
			var sprite := stages[stage].duplicate()
			# Technical size normalization keeps every sprite grounded in its plot.
			var growth := 0.88 + within_stage * 0.012
			var maximum_height := 360.0 if id == "swiety_gaj" else (390.0 if id == "wieza_peruna" else 448.0)
			var ratio := minf(440.0 * growth / sprite.get_width(), maximum_height * growth / sprite.get_height())
			sprite.resize(roundi(sprite.get_width() * ratio), roundi(sprite.get_height() * ratio), Image.INTERPOLATE_LANCZOS)
			var canvas := Image.create(512, 512, false, Image.FORMAT_RGBA8)
			canvas.fill(Color.TRANSPARENT)
			canvas.blit_rect(sprite, Rect2i(Vector2i.ZERO, sprite.get_size()), Vector2i((512 - sprite.get_width()) / 2, 486 - sprite.get_height()))
			assert(canvas.save_png("%s/building_%s_level_%02d.png" % [destination, id, level]) == OK)
		print("Bright building variants prepared: " + id)
	quit()
