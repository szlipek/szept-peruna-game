extends SceneTree

class Fixture:
	extends "res://scripts/puzzle_level.gd"
	func _ready() -> void:
		set_process(false)
		levels = load_levels()
		sfx_enabled = false
		for hero_id in HERO_IDS:
			hero_trees[hero_id] = {}
			hero_experience[hero_id] = 0
	func _draw() -> void:
		pass
	func save_progress() -> void:
		pass

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var game := Fixture.new()
	root.add_child(game)
	game.coins = 100000000
	game.wood = 100000000
	assert(game.try_upgrade_building("tartak"))
	assert(not game.try_upgrade_building("tartak"))
	assert(not game.try_upgrade_building("dwor_wiecowy"))
	assert(not game.try_upgrade_building("kuznia"))
	assert(game.building_requirement_text("kuznia").contains("etap 5"))
	game.level_stars = {5: 1, 10: 1, 20: 1, 50: 1, 100: 1, 250: 1}
	assert(game.try_upgrade_building("domostwa"))
	# Cała ścieżka do poziomu 50 jest osiągalna bez zależności cyklicznych.
	# Odblokowany etap mapy pozostaje 1: limitem nie jest już numer poziomu.
	for target in range(1, 51):
		var requirements := game.VillageProgression.hall_requirements(target)
		for building_id in requirements:
			while int(game.building_levels[building_id]) < int(requirements[building_id]):
				assert(game.try_upgrade_building(building_id), "Nieosiągalne wymaganie Dworu %d: %s" % [target, building_id])
		assert(game.try_upgrade_building("dwor_wiecowy"), "Nieosiągalny Dwór %d" % target)
		assert(game.building_level_cap() == target)
	assert(game.unlocked_level == 1)
	var before := Vector2i(game.coins, game.wood)
	assert(not game.try_upgrade_building("dwor_wiecowy"))
	assert(before == Vector2i(game.coins, game.wood))
	assert(game.VillageProgression.legacy_hall_level({"kuznia": 17, "tartak": 2}) == 17)
	assert(game.VillageProgression.legacy_hall_level({}) == 0)
	var old_save := ConfigFile.new()
	old_save.set_value("village", "kuznia_level", 17)
	old_save.set_value("village", "tartak_level", 2)
	game.load_village_progress(old_save)
	assert(game.building_levels["dwor_wiecowy"] == 17 and game.building_levels["kuznia"] == 17)
	old_save.set_value("village", "dwor_wiecowy_level", 0)
	game.load_village_progress(old_save)
	assert(game.building_levels["dwor_wiecowy"] == 0) # Nowy zapis nie dostaje darmowego awansu.
	game.building_levels["dwor_wiecowy"] = 10
	game.level_stars.erase(20)
	assert(game.building_requirement_text("dwor_wiecowy").contains("etap 20"))
	print("PASS: 50 poziomów Dworu, brak cykli, kamienie milowe i migracja.")
	assert(int(game.campaign_reward(game.levels[99])["wood"]) == 0)
	game.building_levels["dwor_wiecowy"] = 0
	var catalog := game.ForestExpeditions.catalog(game.building_levels)
	assert(catalog.size() == 6)
	game.forest_catalog_open = true
	assert(not game.training_choice_locked(catalog[0]))
	assert(not game.training_choice_locked(catalog[1]))
	assert(game.training_choice_locked(catalog[2]))
	game.training_battle = catalog[0]
	game.wood = 0
	game.expedition_bonus_claims.clear()
	game.grant_training_reward()
	assert(game.wood == 50)
	game.grant_training_reward()
	assert(game.wood == 75) # Po bonusie wyprawa nadal daje drewno.
	game.expedition_bonus_claims["polana"] = "2000-01-01"
	game.grant_training_reward()
	assert(game.wood == 125)
	game.training_battle = game.TRAINING_BATTLES[5]
	game.grant_training_reward()
	assert(game.wood == 125) # Zwykły trening nie obchodzi gospodarki.
	game.start_level(0, catalog[0])
	assert(game.goal_type == "clear_obstacles" and game.goal_target == 6)
	assert(game.obstacle_count(1) == 6)
	game.battle_moves = 18
	game.goal_progress = 5
	assert(game.expedition_move_limit_reached() and game.state == "lost")
	game.goal_progress = 6
	assert(not game.expedition_move_limit_reached()) # Cel w ostatnim ruchu wygrywa.
	game.start_level(0, catalog[1])
	for enemy in game.enemies:
		enemy["health"] = 0
	game.refresh_survival_wave()
	assert(game.has_living_enemies() and game.goal_target == 6)
	print("PASS: źródła drewna, bonus dzienny, dostęp do wypraw i limit ruchów.")
	game.training_mode = false
	game.level_index = 5
	game.side_objective_level_id = 6
	game.active_heroes = ["lada"]
	game.hero_health["lada"] = 100
	game.party_health = 100
	game.party_max_health = 100
	game.side_objective_met = false
	assert(game.calculate_stars() == 2)
	game.side_objective_met = true
	assert(game.calculate_stars() == 3)
	game.party_health = 69
	assert(game.calculate_stars() == 2)
	game.hero_health["lada"] = 0
	assert(game.calculate_stars() == 1)
	game.level_stars = {1: 1, 2: 1, 3: 1, 4: 1}
	assert(game.boss_star_gate_status(4)["unlocked"])
	game.level_stars.erase(4)
	assert(not game.boss_star_gate_status(4)["unlocked"])
	game.state = "playing"
	game.hero_health["lada"] = 100
	game.party_health = 100
	game.side_objective_met = true
	game.mastery_claims.clear()
	game.event_marks = 0
	game.finish_level("Test mistrzostwa")
	assert(game.mastery_claims.has("6") and game.event_marks == 1)
	var marks_before := game.event_marks
	var wood_before := game.wood
	game.state = "playing"
	game.finish_level("Powtórne mistrzostwo")
	assert(game.event_marks == marks_before and game.wood == wood_before)
	game.victory_screen_open = true
	game.current_battle = catalog[0]
	game.handle_release(game.victory_continue_rect().get_center())
	assert(game.training_open and game.forest_catalog_open and not game.main_menu_open)
	print("PASS: mistrzostwo opcjonalne, zwycięstwa otwierają kampanię.")
	game.free()
	quit(0)
