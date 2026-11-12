extends SceneTree

class Game:
	extends "res://scripts/puzzle_level.gd"
	var controlled := false
	var wave := 0
	var health_after_wave: Array[int] = []
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
	func wait_for_board_to_settle() -> void:
		pass
	func collapse_board() -> void:
		wave += 1
		if wave <= 3:
			for x in range(wave + 2):
				board[0][x] = 0
	func find_matches() -> Dictionary:
		if not controlled:
			return super.find_matches()
		var result := {}
		if wave <= 3:
			for x in range(wave + 2):
				result[Vector2i(x, 0)] = true
		return result
	func board_has_legal_move() -> bool:
		return true if controlled else super.board_has_legal_move()
	func deal_damage_to_enemies(amount: int, multiplier := 1.0) -> void:
		super.deal_damage_to_enemies(amount, multiplier)
		health_after_wave.append(int(enemies[0]["health"]))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game := Game.new()
	root.add_child(game)
	game.start_level(0)
	game.setup_obstacles({})
	game.enemies = [{"name": "Test", "health": 10000, "max_health": 1000, "role": "attacker"}]
	game.target_enemy_index = 0
	game.controlled = true
	game.wave = 1
	for x in range(3):
		game.board[0][x] = 0
	await game.resolve_matches(game.find_matches(), 5000)
	if game.health_after_wave.size() != 3 or game.health_after_wave[0] >= 10000 or game.health_after_wave[1] >= game.health_after_wave[0] or game.health_after_wave[2] >= game.health_after_wave[1]:
		printerr("Kolejne fale kaskady nie zadały obrażeń: ", game.health_after_wave)
		game.free()
		quit(1)
		return
	print("Obrażenia każdej fali kaskady: ", game.health_after_wave)
	game.free()
	quit()
