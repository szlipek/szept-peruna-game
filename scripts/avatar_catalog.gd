extends RefCounted

const IDS := ["lada", "brun", "mieta", "dobromir", "wilk", "lis", "kruk", "sowa", "jelen", "rys", "niedzwiedz", "dzik", "zubr", "zajac", "borsuk", "leszy", "rusalka", "zmij", "plomyk", "duch_debu", "kaplanka", "lowczyni", "wojownik", "wedrowiec", "tkaczka", "bartnik", "wieszczka", "guslarz", "strzyga", "zorza"]
const NAMES := ["Wędrowniczka", "Kowal", "Zielarka", "Strażnik", "Wilk", "Lis", "Kruk", "Sowa", "Jeleń", "Ryś", "Niedźwiedź", "Dzik", "Żubr", "Zając", "Borsuk", "Leszy", "Rusałka", "Żmij", "Płomyk", "Duch dębu", "Kapłanka", "Łowczyni", "Wojownik", "Wędrowiec", "Tkaczka", "Bartnik", "Wieszczka", "Guślarz", "Strzyga", "Zorza"]
var portraits := {}
var background: Texture2D
var selected_ring: Texture2D

func load_decoration(game) -> void:
	if background == null:
		background = game.load_image_texture("res://art/avatars/avatar_selection_background_v01.png")
	if selected_ring == null:
		selected_ring = game.load_image_texture("res://art/avatars/avatar_selected_ring_v01.png")

func portrait(game, avatar_id: String) -> Texture2D:
	if portraits.has(avatar_id):
		return portraits[avatar_id]
	if not IDS.has(avatar_id):
		return null
	var texture: Texture2D = game.load_image_texture("res://art/avatars/avatar_%s_v01.png" % avatar_id)
	if texture == null:
		return null
	var source := texture.get_image()
	var edge := mini(source.get_width(), source.get_height())
	var image := source.get_region(Rect2i((source.get_width() - edge) / 2, (source.get_height() - edge) / 2, edge, edge))
	image.resize(256, 256, Image.INTERPOLATE_LANCZOS)
	image.convert(Image.FORMAT_RGBA8)
	for y in 256:
		for x in 256:
			var distance := Vector2(x - 127.5, y - 127.5).length() / 127.5
			var pixel := image.get_pixel(x, y)
			pixel.a *= clampf((1.0 - distance) / 0.025, 0.0, 1.0)
			image.set_pixel(x, y, pixel)
	var circular := ImageTexture.create_from_image(image)
	portraits[avatar_id] = circular
	return circular

func draw_portrait(game, avatar_id: String, rect: Rect2, selected: bool) -> void:
	load_decoration(game)
	game.draw_circle(rect.get_center(), rect.size.x * 0.47, Color("#0b211c"))
	var face := portrait(game, avatar_id)
	if face != null:
		game.draw_texture_rect(face, rect.grow(-rect.size.x * 0.08), false)
	if selected_ring != null:
		game.draw_texture_rect(selected_ring, rect, false, Color.WHITE if selected else Color(0.65, 0.75, 0.65, 0.65))
	else:
		game.draw_circle(rect.get_center(), rect.size.x * 0.45, Color("#f0c96e") if selected else Color("#716342"), false, 2.0)
