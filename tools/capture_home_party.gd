extends SceneTree

# Podgląd samych medalionów drużyny, bez odczytu i zapisu postępu.
class Preview:
	extends "res://scripts/puzzle_level.gd"

	func _ready() -> void:
		font = preload("res://scripts/game_typography.gd").create_font()
		home_party_panel = load_image_texture("res://art/ui/home_party_panel_v01.png")
		home_party_portrait_ring = load_image_texture("res://art/ui/home_party_portrait_ring_v01.png")
		home_party_add_plus = load_image_texture("res://art/ui/home_party_add_plus_v01.png")
		for hero_id in HERO_IDS:
			hero_portraits[hero_id] = load_image_texture("res://art/characters/hero_%s_portrait_v06.png" % hero_id)
		set_process(false)
		set_process_unhandled_input(false)

	func _draw() -> void:
		draw_rect(get_viewport_rect(), Color("#071610"))
		draw_home_party(get_viewport_rect().size)

	func save_progress() -> void:
		pass

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540, 960)
	var game := Preview.new()
	root.add_child(game)
	var teams := [["lada", "brun"], ["lada", "brun", "mieta"]]
	for index in teams.size():
		game.active_heroes.assign(teams[index])
		game.queue_redraw()
		for frame in 3:
			await process_frame
		RenderingServer.force_draw()
		var capture_path := "res://.godot/home-party-%d.png" % index
		var result := root.get_texture().get_image().save_png(capture_path)
		if result != OK:
			quit(1)
			return
	print("Podglądy medalionów: .godot/home-party-0.png i home-party-1.png")
	quit(0)
