extends SceneTree

# Zapis w pamięci: test nie dotyka postępu gracza w user://.
class Fixture:
	extends "res://scripts/puzzle_level.gd"
	var snapshot := ConfigFile.new()
	func _ready() -> void:
		font = ThemeDB.fallback_font
		levels = load_levels()
		set_process(false)
	func save_progress() -> void:
		snapshot = ConfigFile.new()
		player_opening.save_profile(snapshot)

var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game := Fixture.new()
	root.add_child(game)
	var opening = game.player_opening
	opening.load_profile(ConfigFile.new(), game)
	check(opening.stage == "intro", "Nowy gracz powinien zobaczyć wstęp.")
	game.handle_release(opening.secondary_rect(game).get_center())
	check(opening.stage == "avatar", "Pominięcie wstępu powinno prowadzić do awatara.")
	game.handle_release(opening.choice_rect(game, 1).get_center())
	game.handle_release(opening.primary_rect(game).get_center())
	check(opening.avatar_id == "brun" and not game.owned_heroes["brun"], "Awatar nie może rekrutować bohatera.")
	check(not game.main_menu_open and game.level_index == 0, "Po awatarze pierwsza walka powinna rozpocząć się od razu.")
	check(game.active_heroes == ["lada"] and opening.tutorial_active(game), "Pierwsza walka powinna rozpocząć się z Ladą i tutorialem.")
	check(game.state == "playing" and game.goal_type == "defeat_enemy", "Wstęp powinien otworzyć właściwy cel pierwszej walki.")
	game.finish_level("Zwycięstwo")
	check(opening.stage == "" and game.tutorial_completed, "Pierwsza wygrana powinna kończyć tutorial.")
	check(opening.companion_claimed and opening.starter_companion == "brun" and game.active_heroes == ["lada", "brun"], "Po pierwszej wygranej Brun powinien dołączyć bez opłaty.")
	check(game.victory_screen_open and opening.home_tutorial_step == "upgrade_lada", "Po pierwszej wygranej powinien pojawić się ekran zwycięstwa i wskazówka rozwoju Lady.")
	var recovered = load("res://scripts/player_opening.gd").new()
	recovered.load_profile(game.snapshot, game)
	check(recovered.companion_claimed and recovered.starter_companion == "brun", "Zapis musi zachować przyznanego towarzysza.")
	game.handle_release(game.victory_continue_rect().get_center())
	check(not game.victory_screen_open and game.main_menu_open, "Po zamknięciu zwycięstwa gracz powinien wrócić do menu.")
	var earned_coins := game.coins
	game.start_level(1)
	check(game.level_index == 1 and game.hero_max_health["brun"] > 0, "Następna walka powinna uwzględniać Bruna.")
	check(game.coins == earned_coins, "Rozpoczęcie walki nie może zmieniać monet.")
	opening.edit_avatar(game)
	game.handle_release(opening.choice_rect(game, 2).get_center())
	game.handle_release(opening.secondary_rect(game).get_center())
	check(opening.avatar_id == "brun", "Anulowanie edycji musi zachować awatar.")
	opening.edit_avatar(game)
	game.handle_release(opening.choice_rect(game, 3).get_center())
	game.handle_release(opening.primary_rect(game).get_center())
	check(opening.avatar_id == "dobromir" and game.active_heroes == ["lada", "brun"], "Zmiana awatara powinna zachować skład.")
	recovered.load_profile(game.snapshot, game)
	check(recovered.avatar_id == "dobromir" and recovered.companion_claimed and recovered.stage == "", "Profil musi zachować wybory po restarcie.")
	game.start_level(4)
	game.finish_level("Leszy pokonany")
	check(game.owned_heroes["mieta"] and game.active_heroes.size() == 3, "Po poziomie 5 Mięta powinna dołączyć.")
	opening.on_victory(game, 5)
	check(game.active_heroes.size() == 3, "Powtórzenie poziomu nie może powielać postaci.")
	var legacy := ConfigFile.new()
	legacy.set_value("profile", "avatar", "nieistniejący")
	recovered.load_profile(legacy, game)
	check(recovered.stage == "" and recovered.avatar_id == "lada", "Stary zapis powinien ominąć wstęp i naprawić nieznany awatar.")
	game.reset_progress()
	check(opening.stage == "intro" and not opening.companion_claimed and opening.avatar_id == "lada", "Reset musi rozpocząć cały przepływ od nowa.")
	game.queue_free()
	await process_frame
	for failure in failures:
		push_error(failure)
	print("Opening flow: %s" % ("passed" if failures.is_empty() else "failed"))
	quit(0 if failures.is_empty() else 1)
