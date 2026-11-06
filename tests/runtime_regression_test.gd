extends SceneTree

class Fixture:
	extends "res://scripts/puzzle_level.gd"
	func _ready() -> void:
		set_process(false)
		levels = load_levels()
		for hero_id in HERO_IDS:
			hero_trees[hero_id] = {}
			hero_experience[hero_id] = 0
		sync_party_battle_health()
	func _draw() -> void:
		pass
	func save_progress() -> void:
		pass

func _initialize() -> void:
	call_deferred("run_tests")

class BalanceFixture:
	extends Fixture
	func finish_special_turn(_success_message: String) -> void:
		pass

func run_tests() -> void:
	root.size = Vector2i(540, 960)
	var balance := BalanceFixture.new()
	root.add_child(balance)
	balance.sfx_enabled = false
	balance.start_level(0)
	balance.building_levels["domostwa"] = 5
	balance.building_levels["chata_zielarki"] = 5
	balance.building_levels["kuznia"] = 10
	balance.building_levels["wieza_peruna"] = 10
	for hero_id in balance.HERO_IDS:
		balance.active_heroes = [hero_id]
		balance.hero_levels[hero_id] = 1
		assert(balance.hero_health_limit(hero_id) == 150)
		balance.hero_levels[hero_id] = 10
		assert(balance.hero_health_limit(hero_id) == 312)
		balance.sync_party_battle_health()
		balance.hero_health[hero_id] = 100
		balance.heal_hero(hero_id, 20)
		assert(balance.hero_health[hero_id] == 122)
		balance.hero_health[hero_id] = 0
		balance.heal_hero(hero_id, 20)
		balance.sync_party_battle_health()
		assert(balance.hero_health[hero_id] == 0)
		balance.hero_health[hero_id] = 100
		balance.hero_levels[hero_id] = 11
		balance.sync_party_battle_health()
		assert(balance.hero_health[hero_id] == 118 and balance.hero_max_health[hero_id] == 330)
		balance.hero_trees[hero_id] = {"moc_0": 1, "opieka_0": 1}
		for branch in [0, 1]:
			balance.enemies = [{"name": "Leśny cień", "health": 10000, "max_health": 10000, "attack": 1, "role": "attacker"}]
			balance.hero_active_charge[hero_id] = 12
			balance.activate_hero_branch_skill(branch)
			var base_damage := 20 + 11 * 3 + 6 if branch == 0 else 10 + 11 * 2 + 4
			assert(balance.enemies[0]["health"] == 10000 - int(round(base_damage * 1.3)))
	assert(balance.active_ability_damage(100) == 130)
	assert(balance.combined_enemy_attack([10, 20, 30]) == 41)
	assert(balance.combined_enemy_attack([]) == 0)
	balance.board = []
	for row in balance.BOARD_SIZE:
		balance.board.append([])
		for col in balance.BOARD_SIZE:
			balance.board[row].append(0)
	var separate := {Vector2i(0, 0): true, Vector2i(1, 0): true, Vector2i(2, 0): true, Vector2i(0, 2): true, Vector2i(1, 2): true, Vector2i(2, 2): true}
	assert(not balance.matched_line_exists(separate, 5))
	var line := {}
	for col in 5:
		line[Vector2i(col, 0)] = true
	assert(balance.matched_line_exists(line, 5))
	balance.board[0][2] = 1
	assert(not balance.matched_line_exists(line, 5))
	var normalized: Array = balance.normalize_combat_levels([{ "id": 5, "enemies": [{"health": 100, "attack": 4}]}, { "id": 6, "enemies": [{"health": 100, "attack": 4}]}])
	assert(normalized[1]["enemies"][0]["health"] - normalized[0]["enemies"][0]["health"] < 10)
	balance.free()
	print("Balance passed: HP, healing and active skills for all 25 heroes, enemy combinations and campaign transition.")
	for hero_id in Fixture.HERO_RECRUIT_COSTS:
		var game := Fixture.new()
		root.add_child(game)
		game.main_menu_open = false
		game.roster_open = true
		game.coins = 100000
		game.perun_sparks = 100000
		game.event_marks = 100000
		game.roster_hero_index = game.HERO_IDS.find(hero_id)
		var currency: String = game.hero_recruit_currency(hero_id)
		var before: int = game.event_marks if currency == "marks" else (game.perun_sparks if currency == "sparks" else game.coins)
		game.handle_release(game.roster_upgrade_rect().get_center())
		assert(game.owned_heroes[hero_id] and game.active_heroes.has(hero_id))
		assert(game.hero_health[hero_id] > 0 and game.hero_max_health[hero_id] == game.hero_health[hero_id])
		assert(game.displayed_hero_health.has(hero_id))
		assert(game.roster_open and not game.main_menu_open)
		var after: int = game.event_marks if currency == "marks" else (game.perun_sparks if currency == "sparks" else game.coins)
		assert(before - after == game.HERO_RECRUIT_COSTS[hero_id])
		game.hero_health["lada"] = 12
		game.sync_party_battle_health()
		assert(game.hero_health["lada"] == 12)
		game.active_turn_index = 1
		game.handle_roster_input(game.roster_team_toggle_rect().get_center())
		assert(game.active_turn_index == 0)
		game.handle_roster_input(game.roster_team_toggle_rect().get_center())
		assert(game.active_heroes.has(hero_id))
		game.free()
	print("Recruitment tests passed for every purchasable hero and currency.")
	var party := Fixture.new()
	root.add_child(party)
	party.main_menu_open = false
	party.roster_open = true
	party.handle_roster_upgrade("wszebor")
	assert(not party.owned_heroes["wszebor"] and party.coins == 0)
	party.coins = 100000
	for hero_id in ["wszebor", "milena", "boruta"]:
		party.handle_roster_upgrade(hero_id)
	assert(party.active_heroes.size() == 3 and not party.active_heroes.has("boruta"))
	party.roster_hero_index = party.HERO_IDS.find("boruta")
	party.handle_roster_input(party.roster_team_toggle_rect().get_center())
	assert(party.roster_swap_open)
	party.handle_roster_swap_input(party.roster_swap_choice_rect(1).get_center())
	assert(party.active_heroes[1] == "boruta" and party.hero_health["boruta"] > 0)
	assert(party.roster_open and not party.main_menu_open)
	party.free()
	print("Insufficient funds and full-party recruitment/swap tests passed.")

	var game := Fixture.new()
	root.add_child(game)
	game.main_menu_open = false
	game.village_open = true
	game.village_selected_id = "tartak"
	game.player_opening.home_tutorial_step = "buy_sawmill"
	game.handle_village_input(game.village_upgrade_rect().get_center())
	assert(game.building_levels["tartak"] == 1)
	assert(game.player_opening.home_tutorial_step == "sawmill_built")
	game.village_upgrade_time = 0.0
	game.last_wood_production_unix = int(Time.get_unix_time_from_system())
	game.update_sawmill_production(1800.0)
	assert(game.sawmill_stored_wood == 10 and game.wood == 0)
	game.handle_village_input(game.village_collect_wood_rect().get_center())
	assert(game.sawmill_stored_wood == 0 and game.wood == 10)
	game.handle_village_input(game.village_collect_wood_rect().get_center())
	assert(game.wood == 10)
	game.handle_village_input(game.village_inspector_close_rect().get_center())
	assert(game.village_selected_id == "" and game.player_opening.home_tutorial_step == "")
	assert(game.village_open and not game.main_menu_open)
	game.handle_village_input(game.village_building_rect("tartak").get_center())
	assert(game.village_selected_id == "tartak")
	game.last_wood_production_unix = int(Time.get_unix_time_from_system()) - 3600
	game.update_sawmill_production(0.0)
	assert(game.sawmill_stored_wood == 20 and game.wood == 10)
	game.handle_village_input(game.village_collect_wood_rect().get_center())
	assert(game.wood == 30 and game.sawmill_stored_wood == 0)
	game.last_wood_production_unix = int(Time.get_unix_time_from_system()) - 172800
	game.update_sawmill_production(0.0)
	assert(game.sawmill_stored_wood == 480)
	game.wood = 999999998
	game.collect_sawmill_wood()
	assert(game.wood == 999999999 and game.sawmill_stored_wood == 479)
	game.free()
	print("Sawmill construction, close, online/offline production and collection tests passed.")
	var layout := Fixture.new()
	root.add_child(layout)
	for viewport_size in [Vector2i(540, 960), Vector2i(390, 844)]:
		root.size = viewport_size
		var last_top := 193.0 + layout.mission_row_stride() * 5.0 + 38.0
		assert(layout.mission_claim_rect(last_top).end.y < layout.missions_close_rect().position.y)
		var bar := Rect2(28, 32, viewport_size.x - 174, 24)
		assert(bar.encloses(layout.mission_progress_inner_rect(bar)))
		layout.daily_missions = [{"target": 1, "progress": 1, "reward": 100}]
		layout.weekly_missions = [{"target": 1, "progress": 1, "reward": 350}]
		layout.coins = 0
		layout.handle_missions_input(layout.mission_claim_rect(193.0).get_center())
		assert(layout.coins == 100 and layout.daily_missions[0].claimed)
		layout.handle_missions_input(layout.mission_claim_rect(193.0).get_center())
		assert(layout.coins == 100)
		layout.handle_missions_input(layout.mission_claim_rect(193.0 + layout.mission_row_stride() + 38.0).get_center())
		assert(layout.coins == 450 and layout.weekly_missions[0].claimed)
	layout.free()
	print("Mission layout and one-time claim hit areas passed at both viewport sizes.")
	quit()
