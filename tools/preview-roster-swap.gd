extends SceneTree

# Renderuje ekran wymiany bez klikania i bez zmieniania zapisu gracza.
# Godot --path . --script tools/preview-roster-swap.gd --audio-driver Dummy
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://scenes/puzzle_level.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.main_menu_open = false
	game.roster_open = true
	game.roster_swap_open = true
	game.region_intro_open = false
	game.active_heroes.assign(["lada", "mieta", "wszebor"])
	game.roster_swap_hero_id = "brun"
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "res://.godot/roster-swap-preview.png"
	var result := root.get_texture().get_image().save_png(path)
	print("Roster swap preview: ", path, " (", result, ")")
	quit(result)
