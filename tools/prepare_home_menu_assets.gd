extends SceneTree

const NAV_SOURCE := "res://art/ui/home_navigation_atlas_source_v01.png"
const NAV_OUTPUT := "res://art/ui/home_navigation_icons_v01.png"
const CHEST_SOURCE := "res://art/ui/home_reward_chests_source_v01.png"
const CHEST_OUTPUT := "res://art/ui/home_reward_chests_v01.png"

func _initialize() -> void:
	var nav_image := Image.load_from_file(NAV_SOURCE)
	if nav_image == null or nav_image.is_empty():
		push_error("Nie można wczytać atlasu ikon menu.")
		quit(1)
		return
	var cell_size := Vector2i(nav_image.get_width() / 3, nav_image.get_height() / 2)
	var masked_nav := Image.create(nav_image.get_width(), nav_image.get_height(), false, Image.FORMAT_RGBA8)
	masked_nav.fill(Color.TRANSPARENT)
	for row in 2:
		for column in 3:
			if row == 1 and column == 2:
				continue
			var center := Vector2((column + 0.5) * cell_size.x, (row + 0.5) * cell_size.y)
			var radius := minf(cell_size.x, cell_size.y) * 0.455
			var feather := minf(cell_size.x, cell_size.y) * 0.018
			for y in cell_size.y:
				for x in cell_size.x:
					var source_point := Vector2i(column * cell_size.x + x, row * cell_size.y + y)
					var pixel := nav_image.get_pixelv(source_point)
					var distance := Vector2(x + 0.5, y + 0.5).distance_to(center - Vector2(column * cell_size.x, row * cell_size.y))
					var edge_alpha := clampf((radius - distance) / feather, 0.0, 1.0)
					pixel.a *= edge_alpha
					masked_nav.set_pixelv(source_point, pixel)
	var nav_error := masked_nav.save_png(ProjectSettings.globalize_path(NAV_OUTPUT))
	if nav_error != OK:
		push_error("Nie można zapisać ikon menu: %s" % nav_error)
		quit(1)
		return

	var chest_image := Image.load_from_file(CHEST_SOURCE)
	if chest_image == null or chest_image.is_empty():
		push_error("Nie można wczytać grafiki skrzyń.")
		quit(1)
		return
	var chest_panel := chest_image.get_region(Rect2i(0, 117, chest_image.get_width(), 488))
	var chest_error := chest_panel.save_png(ProjectSettings.globalize_path(CHEST_OUTPUT))
	if chest_error != OK:
		push_error("Nie można zapisać grafiki skrzyń: %s" % chest_error)
		quit(1)
		return
	print("Przygotowano przezroczyste ikony nawigacji i przycięty panel skrzyń.")
	quit(0)
