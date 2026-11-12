extends SceneTree

class Game:
	extends "res://scripts/puzzle_level.gd"
	func _ready() -> void:
		set_process(false)
		levels = load_levels()
		for hero_id in HERO_IDS:
			hero_trees[hero_id] = {}
		sfx_enabled = false
	func _draw() -> void:
		pass
	func save_progress() -> void:
		pass
	func animate_swap(_a: Vector2i, _b: Vector2i) -> void:
		pass
	func wait_for_board_to_settle() -> void:
		tile_offsets.clear()
		removal_effects.clear()

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	Engine.time_scale = 30.0
	for scenario in [{"level": 1, "trained": false}, {"level": 5, "trained": false}, {"level": 10, "trained": false}, {"level": 25, "trained": false}, {"level": 50, "trained": false}, {"level": 10, "trained": true}, {"level": 25, "trained": true}, {"level": 50, "trained": true}]:
		var level_id := int(scenario.level)
		var trained := bool(scenario.trained)
		seed(1000 + level_id)
		var game := Game.new()
		root.add_child(game)
		if trained:
			game.active_heroes = ["lada", "brun", "mieta"]
			for hero_id in game.active_heroes:
				game.owned_heroes[hero_id] = true
				game.hero_levels[hero_id] = 5
		game.start_level(level_id - 1)
		game.region_intro_open = false
		game.active_story_dialogue.clear()
		var moves := 0
		while game.state == "playing" and moves < 80:
			var hint: Array[Vector2i] = game.find_hint_move()
			if hint.size() != 2:
				printerr("Brak ruchu na poziomie %d" % level_id)
				game.free()
				quit(1)
				return
			await game.try_swap(hint[0], hint[1])
			moves += 1
		print("Poziom %d (%s): %s, %d ruchów, zdrowie %d/%d" % [level_id, "drużyna 5" if trained else "startowa", game.state, moves, game.party_health, game.party_max_health])
		if moves <= 1 or game.state == "playing":
			printerr("Nieprawidłowa długość lub brak zakończenia walki.")
			game.free()
			quit(1)
			return
		game.free()
	var combo_game := Game.new()
	root.add_child(combo_game)
	combo_game.start_level(9)
	combo_game.region_intro_open = false
	combo_game.special_tiles[0][0] = 1
	combo_game.special_tiles[0][1] = 1
	await combo_game.try_swap(Vector2i(0, 0), Vector2i(1, 0))
	if combo_game.battle_moves != 1 or combo_game.player_cascade_active:
		printerr("Połączenie specjalnych kafelków nie zakończyło akcji poprawnie.")
		combo_game.free()
		quit(1)
		return
	combo_game.free()
	Engine.time_scale = 1.0
	quit()
