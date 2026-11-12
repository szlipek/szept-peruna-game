extends SceneTree

func _initialize() -> void:
	var checked := 0
	var worst_color_error := 0.0
	var worst_alpha_error := 0.0
	var worst_path := ""
	for group in [
		{"dir": "res://art/characters/", "prefix": "hero_", "suffix": "_portrait_v06.png"},
		{"dir": "res://art/avatars/", "prefix": "avatar_", "suffix": "_v01.png"},
		{"dir": "res://art/skill_backgrounds/", "prefix": "skill_tree_", "suffix": ".png"}
	]:
		for file in DirAccess.get_files_at(group.dir):
			if not file.begins_with(group.prefix) or not file.ends_with(group.suffix):
				continue
			if file == "avatar_selected_ring_v01.png":
				continue
			var path: String = group.dir + file
			var original := Image.new()
			if original.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
				printerr("Nie można odczytać oryginału: ", path)
				quit(1)
				return
			var texture := ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
			if texture == null or original == null:
				printerr("Nie można wczytać: ", path)
				quit(1)
				return
			var image := texture.get_image()
			if image == null:
				printerr("Pusta tekstura: ", path)
				quit(1)
				return
			if image.get_size() != original.get_size():
				original.resize(image.get_width(), image.get_height(), Image.INTERPOLATE_LANCZOS)
			var color_error := 0.0
			var alpha_error := 0.0
			var samples := 0
			for y in 32:
				for x in 32:
					var px := mini(original.get_width() - 1, int((x + 0.5) * original.get_width() / 32.0))
					var py := mini(original.get_height() - 1, int((y + 0.5) * original.get_height() / 32.0))
					var a := original.get_pixel(px, py)
					var b := image.get_pixel(px, py)
					alpha_error += absf(a.a - b.a)
					if a.a > 0.1:
						color_error += (absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)) / 3.0
						samples += 1
			var mean_color_error := color_error / maxi(samples, 1)
			if mean_color_error > worst_color_error:
				worst_color_error = mean_color_error
				worst_path = path
			worst_alpha_error = maxf(worst_alpha_error, alpha_error / 1024.0)
			checked += 1
	if checked != 81 or worst_alpha_error > 0.02 or worst_color_error > 0.04:
		printerr("Nieudana kontrola: %d tekstur, średni błąd alfa %.4f, kolor %.4f (%s)" % [checked, worst_alpha_error, worst_color_error, worst_path])
		quit(1)
		return
	print("Tekstury: %d, najwyższy średni błąd alfa %.4f, koloru %.4f" % [checked, worst_alpha_error, worst_color_error])
	quit()
