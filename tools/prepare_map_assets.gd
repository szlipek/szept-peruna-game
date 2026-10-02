extends SceneTree

func _initialize() -> void:
	for asset in ["world_map_route_connector_v01", "world_map_mission_nameplate_v01"]:
		var path := "res://art/ui/%s.png" % asset
		var image := Image.load_from_file(path)
		if image == null:
			quit(1)
			return
		# Ignore faint alpha noise so the ornament fills its intended UI bounds.
		var minimum := image.get_size()
		var maximum := Vector2i(-1, -1)
		for y in image.get_height():
			for x in image.get_width():
				if image.get_pixel(x, y).a > 0.1:
					minimum.x = mini(minimum.x, x)
					minimum.y = mini(minimum.y, y)
					maximum.x = maxi(maximum.x, x)
					maximum.y = maxi(maximum.y, y)
		if maximum.x < 0:
			quit(1)
			return
		var cropped := image.get_region(Rect2i(minimum, maximum - minimum + Vector2i.ONE))
		var max_width := 1024 if asset.contains("connector") else 768
		if cropped.get_width() > max_width:
			var height := roundi(float(cropped.get_height()) * max_width / cropped.get_width())
			cropped.resize(max_width, height, Image.INTERPOLATE_LANCZOS)
		if cropped.save_png(path) != OK:
			quit(1)
			return
		print("Prepared %s: %s" % [asset, cropped.get_size()])
	quit()
