extends SceneTree

# Uruchamia prawdziwe zamiany i kaskady; pomija wyłącznie animacje oraz AI.
# Zapis pozostaje w pamięci, więc test nie nadpisuje postępu gracza.
class Fixture:
	extends "res://scripts/puzzle_level.gd"
	var enemy_turns := 0
	var defeat_next_turn := false
	func _ready() -> void:
		font = ThemeDB.fallback_font
		levels = load_levels()
		set_process(false)
	func save_progress() -> void:
		pass
	func animate_swap(_a: Vector2i, _b: Vector2i) -> void:
		pass
	func wait_for_board_to_settle() -> void:
		tile_offsets.clear()
		animation_busy = false
	func enemy_take_turn() -> void:
		enemy_turns += 1
		if defeat_next_turn:
			hero_health["lada"] = 0
			party_health = 0

var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game := Fixture.new()
	root.add_child(game)
	var level := {"id": 1, "name": "Długa walka", "goal_type": "defeat_enemy", "enemies": [{"name": "Leśny cień", "health": 1000000000, "attack": 1}], "rewards": {}}
	# Dawne dane poziomu również nie mogą ograniczać czasu walki.
	level["moves"] = 1
	game.start_level(0, level)
	for turn in 60:
		var move: Array[Vector2i] = game.find_hint_move()
		if move.size() != 2:
			check(false, "Zabrakło legalnej zamiany.")
			break
		await game.try_swap(move[0], move[1])
		check(game.state == "playing", "Walka zakończyła się mimo żywej drużyny i przeciwnika.")
	check(game.enemy_turns == 60, "Przeciwnik powinien odpowiadać także po kilkudziesięciu ruchach.")
	game.defeat_next_turn = true
	var move: Array[Vector2i] = game.find_hint_move()
	await game.try_swap(move[0], move[1])
	check(game.state == "lost", "Utrata zdrowia musi nadal kończyć walkę porażką.")
	game.defeat_next_turn = false
	level["goal_type"] = "survive"
	level["goal_value"] = 2
	game.start_level(0, level)
	var before := game.enemy_turns
	for turn in 2:
		move = game.find_hint_move()
		await game.try_swap(move[0], move[1])
		check(game.goal_progress == turn + 1, "Przetrwanie powinno zaliczać pełne tury.")
	check(game.state == "won" and game.enemy_turns == before + 2, "Ostatnia tura przetrwania musi obejmować odpowiedź wroga.")
	game.start_level(0, level)
	game.defeat_next_turn = true
	move = game.find_hint_move()
	await game.try_swap(move[0], move[1])
	check(game.state == "lost" and game.goal_progress == 0, "Śmiertelnego ataku nie można zaliczać jako przetrwanej tury.")
	game.party_max_health = 100
	for sample in [[100, 3], [75, 3], [74, 2], [40, 2], [39, 1]]:
		game.party_health = sample[0]
		check(game.calculate_stars() == sample[1], "Gwiazdki muszą zależeć od zdrowia drużyny.")
	game.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("Battle duration: %s" % ("passed" if failures.is_empty() else "failed"))
	quit(0 if failures.is_empty() else 1)
