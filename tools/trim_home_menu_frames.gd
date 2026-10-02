extends SceneTree

const FRAME_PAIRS := [
	["res://art/ui/home_status_header_source_v01.png", "res://art/ui/home_status_header_v01.png"],
	["res://art/ui/home_navigation_frame_v01.png", "res://art/ui/home_navigation_frame_v02.png"],
	["res://art/ui/home_party_panel_source_v01.png", "res://art/ui/home_party_panel_v01.png"],
	["res://art/ui/home_party_portrait_ring_source_v01.png", "res://art/ui/home_party_portrait_ring_v01.png"],
	["res://art/ui/home_status_header_source_v02.png", "res://art/ui/home_status_header_v02.png"],
	["res://art/ui/home_navigation_backdrop_source_v01.png", "res://art/ui/home_navigation_backdrop_v01.png"],
	["res://art/ui/home_help_icon_source_v01.png", "res://art/ui/home_help_icon_v01.png"],
]

const BADGE_SOURCE := "res://art/ui/home_reward_badges_source_v01.png"
const BADGE_OUTPUT := "res://art/ui/home_reward_badges_v01.png"

func _initialize() -> void:
	for pair in FRAME_PAIRS:
		var image := Image.load_from_file(pair[0])
		if image == null or image.is_empty():
			push_error("Nie można wczytać grafiki: %s" % pair[0])
			quit(1)
			return
		var used := visible_bounds(image)
		if used.size == Vector2i.ZERO:
			push_error("Grafika jest pusta: %s" % pair[0])
			quit(1)
			return
		var cropped := image.get_region(used)
		var result := cropped.save_png(ProjectSettings.globalize_path(pair[1]))
		if result != OK:
			push_error("Nie można zapisać grafiki: %s" % pair[1])
			quit(1)
			return
		print("%s: %s -> %s" % [pair[1], image.get_size(), cropped.get_size()])
	if not prepare_badges():
		quit(1)
		return
	quit(0)

func prepare_badges() -> bool:
	var source := Image.load_from_file(BADGE_SOURCE)
	if source == null or source.is_empty():
		push_error("Nie można wczytać plakietek nagrody.")
		return false
	var half_width := source.get_width() / 2
	var left := source.get_region(Rect2i(0, 0, half_width, source.get_height()))
	var right := source.get_region(Rect2i(half_width, 0, source.get_width() - half_width, source.get_height()))
	var left_bounds := visible_bounds(left)
	var right_bounds := visible_bounds(right)
	if left_bounds.size == Vector2i.ZERO or right_bounds.size == Vector2i.ZERO:
		push_error("Jedna z plakietek jest pusta.")
		return false
	var cell_size := Vector2i(maxi(left_bounds.size.x, right_bounds.size.x), maxi(left_bounds.size.y, right_bounds.size.y))
	var atlas := Image.create(cell_size.x * 2, cell_size.y, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	atlas.blit_rect(left, left_bounds, Vector2i((cell_size.x - left_bounds.size.x) / 2, (cell_size.y - left_bounds.size.y) / 2))
	atlas.blit_rect(right, right_bounds, Vector2i(cell_size.x + (cell_size.x - right_bounds.size.x) / 2, (cell_size.y - right_bounds.size.y) / 2))
	var result := atlas.save_png(ProjectSettings.globalize_path(BADGE_OUTPUT))
	if result != OK:
		push_error("Nie można zapisać plakietek nagrody: %s" % result)
		return false
	print("%s: %s" % [BADGE_OUTPUT, atlas.get_size()])
	return true

func visible_bounds(image: Image) -> Rect2i:
	var left := image.get_width()
	var top := image.get_height()
	var right := -1
	var bottom := -1
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a < 0.08:
				continue
			left = mini(left, x)
			top = mini(top, y)
			right = maxi(right, x)
			bottom = maxi(bottom, y)
	if right < left:
		return Rect2i()
	return Rect2i(left, top, right - left + 1, bottom - top + 1)
