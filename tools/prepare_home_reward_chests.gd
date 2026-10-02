extends SceneTree

const PANEL_SOURCE := "res://art/ui/home_reward_panel_source_v02.png"
const PANEL_OUTPUT := "res://art/ui/home_reward_panel_v02.png"
const CHEST_PAIRS := [
	["res://art/ui/home_reward_coin_chest_source_v02.png", "res://art/ui/home_reward_coin_chest_frames_v02.png"],
	["res://art/ui/home_reward_wood_chest_source_v03.png", "res://art/ui/home_reward_wood_chest_frames_v03.png"],
	["res://art/ui/home_reward_xp_chest_source_v02.png", "res://art/ui/home_reward_xp_chest_frames_v02.png"],
]
const FRAME_COUNT := 8

func _initialize() -> void:
	var panel := Image.load_from_file(PANEL_SOURCE)
	if panel == null or panel.is_empty():
		push_error("Nie można wczytać tła skrzyń.")
		quit(1)
		return
	var panel_bounds := visible_bounds(panel)
	if panel_bounds.size == Vector2i.ZERO:
		push_error("Tło skrzyń jest puste.")
		quit(1)
		return
	var panel_result := panel.get_region(panel_bounds).save_png(ProjectSettings.globalize_path(PANEL_OUTPUT))
	if panel_result != OK:
		push_error("Nie można zapisać tła skrzyń.")
		quit(1)
		return
	for pair in CHEST_PAIRS:
		if not prepare_chest(pair[0], pair[1]):
			quit(1)
			return
	quit(0)

func prepare_chest(source_path: String, output_path: String) -> bool:
	var source := Image.load_from_file(source_path)
	if source == null or source.is_empty() or source.get_width() < FRAME_COUNT:
		push_error("Nieprawidłowy atlas skrzyni: %s" % source_path)
		return false
	var original_cell_width := source.get_width() / FRAME_COUNT
	var left := original_cell_width
	var right := -1
	var top := source.get_height()
	var bottom := -1
	for frame in FRAME_COUNT:
		for y in source.get_height():
			for x in original_cell_width:
				if source.get_pixel(roundi(float(frame) * source.get_width() / FRAME_COUNT) + x, y).a < 0.08:
					continue
				left = mini(left, x)
				right = maxi(right, x)
				top = mini(top, y)
				bottom = maxi(bottom, y)
	if right < left:
		push_error("Atlas skrzyni jest pusty: %s" % source_path)
		return false
	left = maxi(0, left - 12)
	right = mini(original_cell_width - 1, right + 12)
	top = maxi(0, top - 12)
	bottom = mini(source.get_height() - 1, bottom + 12)
	var cell_size := Vector2i(right - left + 1, bottom - top + 1)
	var atlas := Image.create(cell_size.x * FRAME_COUNT, cell_size.y, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for frame in FRAME_COUNT:
		atlas.blit_rect(source, Rect2i(roundi(float(frame) * source.get_width() / FRAME_COUNT) + left, top, cell_size.x, cell_size.y), Vector2i(frame * cell_size.x, 0))
	var result := atlas.save_png(ProjectSettings.globalize_path(output_path))
	if result != OK:
		push_error("Nie można zapisać atlasu skrzyni: %s" % output_path)
		return false
	print("%s: %d x %s" % [output_path, FRAME_COUNT, cell_size])
	return true

func visible_bounds(image: Image) -> Rect2i:
	var left := image.get_width()
	var right := -1
	var top := image.get_height()
	var bottom := -1
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a < 0.08:
				continue
			left = mini(left, x)
			right = maxi(right, x)
			top = mini(top, y)
			bottom = maxi(bottom, y)
	if right < left:
		return Rect2i()
	return Rect2i(left, top, right - left + 1, bottom - top + 1)
