extends SceneTree

# Podgląd nowych grafik w rzeczywistym widoku drużyny, bez zapisu postępu.
# Godot --path . --script tools/capture_hero_portraits.gd --audio-driver Dummy
class Preview:
	extends "res://scripts/puzzle_level.gd"

	func _ready() -> void:
		font = preload("res://scripts/game_typography.gd").create_font()
		game_logo = load_image_texture("res://art/logos/logo_serce_debu_v01.png")
		roster_action_button = load_image_texture("res://art/ui/roster_action_button_v01.png")
		roster_section_header = load_image_texture("res://art/ui/roster_section_header_v03.png")
		roster_tabs_active_v04 = load_image_texture("res://art/ui/roster_tabs_active_v04.png")
		roster_tabs_inactive_v04 = load_image_texture("res://art/ui/roster_tabs_inactive_v04.png")
		roster_experience_frame = load_image_texture("res://art/ui/roster_experience_frame_v01.png")
		roster_arrow_left = load_image_texture("res://art/ui/roster_arrow_left_v01.png")
		roster_arrow_right = load_image_texture("res://art/ui/roster_arrow_right_v01.png")
		home_party_portrait_ring = load_image_texture("res://art/ui/home_party_portrait_ring_v01.png")
		coin_resource_icon = load_image_texture("res://art/ui/icon_coin_oak_v01.png")
		perun_sparks_resource_icon = load_image_texture("res://art/ui/icon_perun_sparks_v01.png")
		rune_tile_icon = load_image_texture("res://art/tiles/tile_rune_v01.png")
		coins = 1285
		perun_sparks = 37
		event_marks = 8
		for hero_id in HERO_IDS:
			hero_portraits[hero_id] = load_image_texture("res://art/characters/hero_%s_portrait_v06.png" % hero_id)
			hero_accent_textures[hero_id] = load_image_texture("res://art/vfx/hero_accent_%s.png" % hero_id)
			owned_heroes[hero_id] = true
			hero_levels[hero_id] = 1
			hero_experience[hero_id] = 87
		set_process(false)
		set_process_unhandled_input(false)

	func _draw() -> void:
		draw_roster_overlay(get_viewport_rect().size)

	func save_progress() -> void:
		pass

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540, 960)
	var game := Preview.new()
	root.add_child(game)
	for hero_id in game.HERO_IDS:
		game.roster_filter = "all"
		game.roster_hero_index = game.HERO_IDS.find(hero_id)
		game.queue_redraw()
		for frame in 3:
			await process_frame
		RenderingServer.force_draw()
		var capture_path := "res://.godot/hero-portrait-%s.png" % hero_id
		var result := root.get_texture().get_image().save_png(capture_path)
		if result != OK:
			push_error("Nie udało się zapisać podglądu: %s" % hero_id)
			quit(1)
			return
	print("25 podglądów portretów zapisano w .godot/hero-portrait-*.png")
	quit(0)
