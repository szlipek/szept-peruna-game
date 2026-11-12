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
	var original_board: Array = balance.board.duplicate(true)
	var original_specials: Array = balance.special_tiles.duplicate(true)
	balance.handle_tile_click(balance.FIRST_TUTORIAL_MOVE_FROM)
	assert(balance.move_preview_target == balance.FIRST_TUTORIAL_MOVE_TO)
	assert(not balance.move_preview_cells.is_empty())
	assert(balance.board == original_board and balance.special_tiles == original_specials)
	var tutorial_target: Vector2i = balance.FIRST_TUTORIAL_MOVE_TO
	balance.special_tiles[tutorial_target.y][tutorial_target.x] = 1
	balance.refresh_move_preview()
	assert(balance.move_preview_target != tutorial_target)
	balance.special_tiles[tutorial_target.y][tutorial_target.x] = 0
	balance.handle_tile_click(balance.FIRST_TUTORIAL_MOVE_FROM)
	assert(balance.move_preview_target == Vector2i(-1, -1))
	assert(balance.side_objective_kind(3) == "combo")
	assert(balance.side_objective_kind(21) == "no_booster")
	assert(balance.side_objective_kind(22) == "cascade")
	assert(balance.side_objective_kind(23) == "obstacles")
	balance.side_objective_level_id = 21
	assert(balance.side_objective_succeeded())
	balance.battle_booster_used = true
	assert(not balance.side_objective_succeeded())
	balance.side_objective_level_id = 22
	balance.battle_best_cascade = 1
	assert(not balance.side_objective_succeeded())
	balance.battle_best_cascade = 2
	assert(balance.side_objective_succeeded())
	balance.side_objective_level_id = 23
	balance.battle_obstacles_cleared = 2
	assert(not balance.side_objective_succeeded())
	balance.battle_obstacles_cleared = 3
	assert(balance.side_objective_succeeded())
	balance.start_level(0)
	assert(not balance.battle_booster_used and balance.battle_obstacles_cleared == 0 and balance.battle_best_cascade == 0)
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
	balance.active_heroes = ["lada"]
	balance.hero_levels["lada"] = 1
	balance.setup_obstacles({})
	balance.enemies = [{"name": "Strażnik", "health": 1000, "max_health": 1000, "role": "defender"}]
	balance.target_enemy_index = 0
	balance.player_action_damage_dealt = 0
	balance.deal_damage_to_enemies(5000, 1.15)
	assert(balance.enemies[0]["health"] == 720)
	balance.deal_damage_to_enemies(5000, 1.15)
	assert(balance.enemies[0]["health"] == 720)
	balance.player_action_damage_dealt = 0
	balance.deal_damage_to_enemies(5000)
	assert(balance.enemies[0]["health"] == 440)
	balance.perun_sparks = 0
	balance.event_marks = 0
	balance.claimed_boss_sparks.clear()
	for level_id in [5, 20, 25, 50, 175]:
		balance.level_index = level_id - 1
		var awarded: int = balance.grant_boss_spark()
		assert(awarded == (12 if level_id == 25 else (16 if level_id == 175 else 0)))
		assert(balance.grant_boss_spark() == 0)
	assert(balance.event_marks == 28 and balance.perun_sparks == 0)
	assert(balance.hero_recruit_currency("zywia") == "marks")
	balance.handle_roster_upgrade("zywia")
	assert(balance.owned_heroes["zywia"] and balance.event_marks == 16)
	assert(not balance.grant_event_mark())
	var saved_rewards := ConfigFile.new()
	saved_rewards.set_value("bosses", "spark_10025", true)
	var loaded := Fixture.new()
	root.add_child(loaded)
	loaded.load_reward_claims(saved_rewards)
	assert(loaded.legend_milestone_reward_label(25) == "")
	assert(loaded.legend_milestone_reward_label(175) == "+16 ZNAKÓW")
	assert(loaded.legend_milestone_reward_label(30) == "")
	loaded.level_index = 24
	assert(loaded.grant_boss_spark() == 0)
	assert(loaded.next_legend_milestone() == 175)
	assert(loaded.legend_milestone_hint().contains("ukończ poziom 175"))
	loaded.unlocked_level = 200
	assert(loaded.legend_milestone_hint().contains("wróć i wygraj poziom 175"))
	for milestone in loaded.LEGENDARY_SPARK_MILESTONES:
		loaded.claimed_boss_sparks[10000 + int(milestone)] = true
	assert(loaded.next_legend_milestone() == 0)
	loaded.enemies = [{"name": "Wilk cienia", "health": 100, "max_health": 100, "role": "attacker"}]
	loaded.wolf_charge = 2
	loaded.wolf_warded = false
	assert(loaded.boss_turn_hint().contains("2/3"))
	assert(loaded.enemy_tactical_hint(loaded.enemies[0]).contains("3 liście"))
	loaded.wolf_warded = true
	assert(loaded.boss_turn_hint().contains("ROZPROSZONY"))
	loaded.enemies[0]["health"] = 0
	assert(loaded.boss_turn_hint() == "")
	assert(loaded.enemy_tactical_hint({"name": "Leszy"}).contains("korzenie"))
	assert(loaded.enemy_tactical_hint({"name": "Rusałka z Czarnego Stawu"}).contains("wodę"))
	loaded.start_level(4)
	assert(loaded.active_boss_tutorial_id == 5 and loaded.region_intro_open)
	assert(str(loaded.active_story_dialogue[-1].text).contains("korzenie"))
	loaded.advance_story_dialogue(true)
	assert(bool(loaded.seen_boss_tutorials.get("5", false)))
	loaded.start_level(4)
	assert(loaded.active_boss_tutorial_id == 0)
	loaded.start_level(64)
	assert(loaded.living_named_boss("Baba Jaga z Żelaznego Boru"))
	assert(loaded.boss_turn_hint().contains("SZYKUJE"))
	assert(loaded.advance_baba_curse() == 0)
	assert(loaded.boss_turn_hint().contains("3 RUNY"))
	assert(loaded.advance_baba_curse() == 12)
	loaded.baba_curse_warded = true
	assert(loaded.boss_turn_hint().contains("ODPĘDZAJĄ"))
	assert(loaded.advance_baba_curse() == 0)
	assert(loaded.enemy_tactical_hint({"name": "Baba Jaga z Żelaznego Boru"}).contains("3 runy"))
	loaded.start_level(29)
	assert(not loaded.baba_curse_pending and not loaded.baba_curse_warded)
	assert(loaded.living_named_boss("Rusałka z Czarnego Stawu"))
	var water_changed: int = loaded.rusalka_water_spell()
	assert(water_changed >= 0 and water_changed <= 2)
	assert(loaded.find_matches().is_empty() and loaded.board_has_legal_move())
	for enemy in loaded.enemies:
		enemy["health"] = 0
	assert(loaded.rusalka_water_spell() == 0)
	loaded.unlocked_level = 10
	assert(not loaded.map_shrine_available())
	loaded.unlocked_level = 11
	var wood_before: int = loaded.wood
	loaded.claim_map_shrine(1)
	assert(loaded.wood == wood_before + 150 and not loaded.map_shrine_available())
	loaded.claim_map_shrine(1)
	assert(loaded.wood == wood_before + 150)
	var weekly: Dictionary = loaded.training_catalog()[0]
	assert(bool(weekly.get("weekly_challenge", false)))
	loaded.training_battle = weekly
	var weekly_coins_before: int = loaded.coins
	loaded.grant_training_reward()
	assert(loaded.coins == weekly_coins_before + 500)
	loaded.grant_training_reward()
	assert(loaded.coins == weekly_coins_before + 500)
	loaded.training_battle["week"] = "2000-01-01"
	loaded.grant_training_reward()
	assert(loaded.coins == weekly_coins_before + 500)
	loaded.start_level(0)
	loaded.special_tiles[0][0] = 1
	loaded.special_tiles[0][1] = 1
	var pair_cells: Dictionary = loaded.special_pair_cells(Vector2i(0, 0), Vector2i(1, 0))
	assert(pair_cells.size() == 12 and pair_cells.has(Vector2i(3, 2)))
	loaded.special_tiles[0][0] = 0
	loaded.special_tiles[0][1] = 0
	loaded.endless_stage = 1
	loaded.training_battle = loaded.endless_battle(1)
	loaded.start_level(0, loaded.training_battle)
	loaded.hero_health["lada"] = 40
	loaded.refresh_party_health()
	loaded.endless_choice_open = true
	var endless_coins_before: int = loaded.coins
	loaded.handle_endless_choice(loaded.endless_choice_rect(1).get_center())
	assert(loaded.endless_stage == 2 and loaded.coins == endless_coins_before + 175)
	assert(loaded.hero_health["lada"] == 40 and not loaded.endless_choice_open)
	loaded.endless_choice_open = true
	loaded.handle_endless_choice(loaded.endless_choice_rect(3).get_center())
	assert(not loaded.endless_choice_open and loaded.main_menu_open)
	loaded.balance_stats["best_cascade"] = 3
	loaded.balance_stats["endless_best"] = 5
	var achievements: Array = loaded.achievement_rows()
	assert(achievements.size() >= 35)
	assert(loaded.ACHIEVEMENT_ICONS.size() == achievements.size())
	var icons_seen := {}
	for icon_key in loaded.ACHIEVEMENT_ICONS:
		assert(not icons_seen.has(icon_key))
		assert(ResourceLoader.exists("res://art/skills/skill_%s.png" % icon_key))
		icons_seen[icon_key] = true
	assert(int(achievements[2].value) >= int(achievements[2].target))
	assert(int(achievements[3].value) >= int(achievements[3].target))
	loaded.achievements_open = true
	loaded.handle_missions_input(loaded.achievements_page_rect(1).get_center())
	assert(loaded.achievements_page == 1)
	loaded.handle_missions_input(loaded.achievements_page_rect(1).get_center())
	loaded.handle_missions_input(loaded.achievements_page_rect(1).get_center())
	assert(loaded.achievements_page == 3)
	loaded.achievements_page = ceili(float(achievements.size()) / 4.0) - 1
	loaded.handle_missions_input(loaded.achievements_page_rect(1).get_center())
	assert(loaded.achievements_page == ceili(float(achievements.size()) / 4.0) - 1)
	loaded.achievements_page = 2
	loaded.handle_missions_input(loaded.achievements_page_rect(-1).get_center())
	assert(loaded.achievements_page == 1)
	loaded.owned_heroes["lada"] = true
	loaded.hero_levels["lada"] = loaded.MAX_HERO_LEVEL
	loaded.hero_trees["lada"] = {"moc_0": 3, "moc_1": 4, "moc_2": 4, "moc_3": 5, "opieka_0": 3, "opieka_1": 4, "opieka_2": 4, "opieka_3": 5, "splot_0": 3, "splot_1": 4, "splot_2": 4, "splot_3": 5}
	var updated_achievements: Array = loaded.achievement_rows()
	for title in ["Legenda Peruna", "Mistrzowska ścieżka", "Pełnia mocy"]:
		var matches: Array = updated_achievements.filter(func(row): return row.name == title)
		assert(matches.size() == 1 and int(matches[0].value) >= int(matches[0].target))
	loaded.handle_missions_input(loaded.achievements_cosmetic_rect().get_center())
	assert(loaded.cascade_cosmetic)
	var board_area: Rect2 = loaded.board_rect()
	assert(board_area.size.x == 440.0 and board_area.end.y <= 760.0)
	for y in loaded.BOARD_SIZE:
		for x in loaded.BOARD_SIZE:
			var center: Vector2 = board_area.position + (Vector2(x, y) + Vector2.ONE * 0.5) * board_area.size.x / loaded.BOARD_SIZE
			assert(loaded.point_to_cell(center) == Vector2i(x, y))
	loaded.free()
	print("Legend milestones, one-time rewards and per-action damage cap passed.")
	assert(balance.combined_enemy_attack([10, 20, 30]) == 41)
	assert(balance.combined_enemy_attack([]) == 0)
	balance.board = []
	for row in balance.BOARD_SIZE:
		balance.board.append([])
		for col in balance.BOARD_SIZE:
			balance.board[row].append(0)
	for col in 3:
		balance.board[0][col] = -1
	var empty_matches: Dictionary = balance.find_matches()
	for col in 3:
		assert(not empty_matches.has(Vector2i(col, 0)))
		balance.board[0][col] = 0
	var separate := {Vector2i(0, 0): true, Vector2i(1, 0): true, Vector2i(2, 0): true, Vector2i(0, 2): true, Vector2i(1, 2): true, Vector2i(2, 2): true}
	assert(not balance.matched_line_exists(separate, 5))
	var line := {}
	for col in 5:
		line[Vector2i(col, 0)] = true
	assert(balance.matched_line_exists(line, 5))
	balance.board[0][2] = 1
	assert(not balance.matched_line_exists(line, 5))
	assert(balance.matched_line_cells(line, 5).is_empty())
	assert(balance.enemy_match_value(line) == 25)
	var mixed_square := {Vector2i(0, 0): true, Vector2i(1, 0): true, Vector2i(0, 1): true, Vector2i(1, 1): true}
	balance.board[1][1] = 1
	assert(not balance.matched_square_exists(mixed_square))
	balance.board[1][1] = 0
	assert(balance.matched_square_exists(mixed_square))
	for col in 5:
		balance.board[0][col] = 0
	assert(balance.matched_line_cells(line, 5).size() == 5)
	assert(balance.enemy_match_value(line) == 85)
	assert(balance.choose_special_creation_cell(balance.matched_line_cells(line, 5), [Vector2i(0, 2)]) != Vector2i(0, 2))
	var cross := {Vector2i(1, 0): true, Vector2i(1, 1): true, Vector2i(0, 2): true, Vector2i(1, 2): true, Vector2i(2, 2): true}
	assert(balance.matched_cross_centers(cross).has(Vector2i(1, 2)))
	balance.board[1][1] = 1
	assert(balance.matched_cross_centers(cross).is_empty())
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
