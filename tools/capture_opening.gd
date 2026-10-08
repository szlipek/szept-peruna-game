extends SceneTree

class Preview:
	extends "res://scripts/puzzle_level.gd"
	func _ready() -> void:
		font = ThemeDB.fallback_font
		var preview_font := FontFile.new()
		if preview_font.load_dynamic_font("res://art/fonts/AlegreyaSans-Bold.ttf") == OK:
			font = preview_font
		# Ładuj tylko portrety potrzebne do wprowadzenia, bez całej kolekcji.
		for hero_id in ["lada", "brun", "mieta", "dobromir"]:
			var portrait := Image.load_from_file("res://art/characters/hero_%s_portrait_v05.png" % hero_id)
			if portrait != null and not portrait.is_empty():
				hero_portraits[hero_id] = ImageTexture.create_from_image(portrait)
		set_process(false)
	func save_progress() -> void:
		pass

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540, 960)
	var game = load("res://scenes/puzzle_level.tscn").instantiate() if OS.get_cmdline_user_args().has("full-scene") else Preview.new()
	root.add_child(game)
	game.set_process(false)
	game.set_process_unhandled_input(false)
	# Zmieniamy tylko stan w pamięci; podgląd nie zapisuje postępu gracza.
	game.player_opening.reset_profile()
	for stage in ["intro", "avatar", "companion", "ready"]:
		game.player_opening.stage = stage
		game.player_opening.selected_companion = "mieta"
		game.player_opening.starter_companion = "mieta"
		game.last_reward = {"coins": 120, "wood": 20, "experience": 40}
		game.queue_redraw()
		for frame in 3:
			await process_frame
		RenderingServer.force_draw()
		var screenshot := root.get_texture().get_image()
		if screenshot == null or screenshot.save_png("res://.godot/opening-%s.png" % stage) != OK:
			push_error("Nie udało się zapisać podglądu: %s" % stage)
			quit(1)
			return
	print("Opening previews saved in .godot/.")
	quit(0)
