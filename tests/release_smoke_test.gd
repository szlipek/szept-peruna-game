extends SceneTree

const EXPECTED_GOALS := ["defeat_enemy", "clear_obstacles", "collect_amber", "collect_rune", "survive", "score"]
const EXPECTED_REGIONS := ["debowepogranicze", "swiety_gaj", "bagna_welesa", "gory_peruna", "nawia", "prawia", "grzmotne_szczyty", "jeziora_rusalek", "ziemie_marzanny", "kraina_zmijow", "korona_drzewa"]

func fail(message: String) -> void:
	push_error("RELEASE SMOKE TEST: %s" % message)
	quit(1)

func _init() -> void:
	var level_file := FileAccess.open("res://data/levels.json", FileAccess.READ)
	if level_file == null:
		fail("Nie można otworzyć data/levels.json.")
		return
	var handcrafted = JSON.parse_string(level_file.get_as_text())
	if not handcrafted is Array or handcrafted.size() != 100:
		fail("Kampania ręczna musi zawierać dokładnie 100 poziomów.")
		return
	var gameplay = load("res://scripts/puzzle_level.gd").new()
	var rarity_count := {"ZWYKŁA": 0, "PREMIUM": 0, "LEGENDA": 0}
	for hero_id in gameplay.HERO_IDS:
		var rarity := str(gameplay.HERO_CLASSES.get(hero_id, ""))
		if not rarity_count.has(rarity) or not gameplay.HERO_SKILLS.has(hero_id) or not gameplay.HERO_SYNERGIES.has(hero_id):
			fail("Bohater %s nie ma kompletnej klasy, zdolności lub synergii." % hero_id)
			return
		rarity_count[rarity] = int(rarity_count[rarity]) + 1
	if gameplay.HERO_IDS.size() != 25 or int(rarity_count["ZWYKŁA"]) != 10 or int(rarity_count["PREMIUM"]) != 10 or int(rarity_count["LEGENDA"]) != 5:
		fail("Kolekcja bohaterów powinna mieć 10 zwykłych, 10 premium i 5 legend.")
		return
	var skill_model = load("res://scripts/hero_skill_tree.gd")
	if skill_model.HERO_TREES.size() != gameplay.HERO_IDS.size():
		fail("Drzewko nie obejmuje wszystkich 25 bohaterów.")
		return
	for hero_id in gameplay.HERO_IDS:
		if not skill_model.HERO_TREES.has(hero_id):
			fail("Brak drzewka dla bohatera %s." % hero_id)
			return
		var tree := {}
		if skill_model.can_invest(tree, 1, 0, 0) or skill_model.can_invest(tree, 38, 0, 3):
			fail("Drzewko %s pomija wymaganie poziomu lub wcześniejszych zdolności." % hero_id)
			return
		var gate_tree := {}
		for tier in 3:
			for rank_index in skill_model.RANK_CAPS[tier]:
				if not skill_model.invest(gate_tree, 37, 0, tier):
					fail("Nie można przygotować wcześniejszych węzłów bohatera %s." % hero_id)
					return
		if skill_model.can_invest(gate_tree, 37, 0, 3) or not skill_model.can_invest(gate_tree, 38, 0, 3):
			fail("Mistrzostwo bohatera %s nie ma właściwej bramki poziomu 38." % hero_id)
			return
		for tier in skill_model.RANK_CAPS.size():
			for branch in skill_model.BRANCHES.size():
				for rank_index in skill_model.RANK_CAPS[tier]:
					if not skill_model.invest(tree, 50, branch, tier):
						fail("Na poziomie 50 nie da się rozwinąć trzech umiejętności %s do maksimum." % hero_id)
						return
		if skill_model.points_left(tree, 50) != 1 or skill_model.invest(tree, 50, 0, 3):
			fail("Drzewko %s przekracza budżet punktów lub limit rang." % hero_id)
			return
		var damaged_tree := {"moc_0": 99, "moc_3": 5, "opieka_1": 4}
		var repaired: Dictionary = skill_model.sanitize(damaged_tree, 5)
		if skill_model.ranks(repaired, 0, 0) != 3 or skill_model.ranks(repaired, 0, 3) != 0 or skill_model.ranks(repaired, 1, 1) != 0:
			fail("Naprawa zapisu drzewka %s nie pilnuje zależności talentów." % hero_id)
			return
	for pair in gameplay.HERO_SYNERGY_PAIRS:
		if pair.size() != 2 or not gameplay.HERO_IDS.has(str(pair[0])) or not gameplay.HERO_IDS.has(str(pair[1])):
			fail("Zespół bohaterów zawiera niepoprawną parę synergii.")
			return
	var campaign: Array = gameplay.append_generated_levels(handcrafted)
	for boss_id in [3, 68, 100, 125, 2000]:
		if not gameplay.is_boss_level({"id": boss_id}):
			fail("Poziom bossa %d nie jest oznaczony jako boss." % boss_id)
			return
	for ordinary_id in [101, 105, 110, 124, 126, 1999]:
		if gameplay.is_boss_level({"id": ordinary_id}):
			fail("Zwykły poziom %d jest błędnie oznaczony jako boss." % ordinary_id)
			return
	gameplay.free()
	if campaign.size() != 2000:
		fail("Kampania powinna mieć 2000 poziomów, ma %d." % campaign.size())
		return
	var found_goals := {}
	var found_regions := {}
	var found_guardian := false
	var found_grand_boss := false
	var previous_generated_enemy_health := 0
	for index in campaign.size():
		var level: Dictionary = campaign[index]
		var expected_id := index + 1
		if int(level.get("id", 0)) != expected_id:
			fail("Nieciągły identyfikator poziomu przy pozycji %d." % expected_id)
			return
		if str(level.get("name", "")).strip_edges().is_empty() or int(level.get("moves", 0)) <= 0:
			fail("Poziom %d nie ma nazwy albo dodatniego limitu ruchów." % expected_id)
			return
		var region := str(level.get("region", "debowepogranicze"))
		if not EXPECTED_REGIONS.has(region):
			fail("Poziom %d używa nieznanej krainy: %s." % [expected_id, region])
			return
		found_regions[region] = true
		var goal := str(level.get("goal_type", "defeat_enemy"))
		if not EXPECTED_GOALS.has(goal):
			fail("Poziom %d używa nieznanego celu: %s." % [expected_id, goal])
			return
		found_goals[goal] = true
		var rewards: Dictionary = level.get("rewards", {})
		for reward_id in ["coins", "wood", "experience"]:
			if int(rewards.get(reward_id, 0)) < 0:
				fail("Poziom %d ma ujemną nagrodę %s." % [expected_id, reward_id])
				return
		var enemies: Array = level.get("enemies", [])
		if expected_id > 100 and not enemies.is_empty() and not (expected_id % 40 == 0 and expected_id % 50 != 0):
			var first_enemy_health := int(enemies[0].get("health", 0))
			if previous_generated_enemy_health > 0 and first_enemy_health < previous_generated_enemy_health:
				fail("Zdrowie bazowego przeciwnika maleje na poziomie %d." % expected_id)
				return
			previous_generated_enemy_health = first_enemy_health
		if goal == "defeat_enemy" and enemies.is_empty():
			fail("Poziom walki %d nie ma przeciwnika." % expected_id)
			return
		if goal != "defeat_enemy" and goal != "survive" and not enemies.is_empty():
			fail("Poziom zadaniowy %d nie powinien wymagać pokonania wrogów." % expected_id)
			return
		if expected_id > 100 and expected_id % 25 == 0 and goal == "defeat_enemy":
			found_guardian = true
		if expected_id > 100 and expected_id % 50 == 0 and enemies.size() >= 2:
			found_grand_boss = true
	if previous_generated_enemy_health <= 520:
		fail("Końcowe poziomy kampanii nie rosną ponad bazowe zdrowie prologu.")
		return
	var final_level: Dictionary = campaign.back()
	var final_enemies: Array = final_level.get("enemies", [])
	if final_enemies.size() < 2 or int(final_enemies[1].get("health", 0)) > 3400 or int(final_enemies[1].get("attack", 0)) > 34:
		fail("Wielki boss poziomu 2000 przekracza zaplanowany próg trudności do przejścia.")
		return
	for goal in EXPECTED_GOALS:
		if not found_goals.has(goal):
			fail("W kampanii nie występuje cel: %s." % goal)
			return
	for region in EXPECTED_REGIONS:
		if not found_regions.has(region):
			fail("W kampanii nie występuje kraina: %s." % region)
			return
	if not found_guardian or not found_grand_boss:
		fail("W kampanii brakuje strażnika krainy albo wielkiego bossa.")
		return
	# Jawnie pusta lista przeciwników jest częścią reguł poziomu zadaniowego.
	# Nie wolno zamieniać jej w awaryjną walkę podczas uruchamiania etapu.
	var encounter_test = load("res://scripts/puzzle_level.gd").new()
	for level in campaign:
		encounter_test.setup_enemies(level)
		var configured_enemies: Array = level.get("enemies", [])
		if configured_enemies.is_empty() and not encounter_test.enemies.is_empty():
			fail("Poziom zadaniowy %d otrzymał nieplanowanego przeciwnika." % int(level.get("id", 0)))
			return
		if not configured_enemies.is_empty() and encounter_test.enemies.size() != configured_enemies.size():
			fail("Poziom %d uruchamia inną liczbę przeciwników niż zapisano w kampanii." % int(level.get("id", 0)))
			return
	encounter_test.setup_enemies({"id": 0, "moves": 10, "target": 100})
	if encounter_test.enemies.size() != 1:
		fail("Starszy poziom bez konfiguracji przeciwników nie otrzymuje bezpiecznego wroga awaryjnego.")
		return
	encounter_test.goal_type = "survive"
	encounter_test.goal_progress = 2
	encounter_test.goal_target = 6
	if encounter_test.goal_label() != "Przetrwaj: 2 / 6 tur":
		fail("HUD etapu przetrwania pokazuje pokonanie wrogów zamiast liczby tur.")
		return
	encounter_test.free()
	# Symulacja starego/uszkodzonego zapisu: start gry musi odzyskać grywalny stan.
	var recovery = load("res://scripts/puzzle_level.gd").new()
	recovery.levels = campaign
	recovery.unlocked_level = 99999
	recovery.coins = -50
	recovery.wood = -1
	recovery.experience = -7
	recovery.perun_sparks = -3
	recovery.event_marks = -2
	recovery.owned_heroes = {"lada": false, "brun": true, "mieta": false, "wszebor": false, "rada": false, "zywia": false}
	recovery.hero_levels = {"lada": -2, "brun": 999, "mieta": 0, "wszebor": 0, "rada": 0, "zywia": 0}
	recovery.hero_experience = {"lada": -3, "brun": -5, "mieta": 0, "wszebor": 0, "rada": 0, "zywia": 0}
	var corrupted_active: Array[String] = ["brun", "nieistniejacy", "lada", "mieta"]
	recovery.active_heroes = corrupted_active
	recovery.building_levels = {"domostwa": -1, "kuznia": 500, "chata_zielarki": 0, "swiety_gaj": 0, "spichlerz": 0, "wieza_peruna": 0}
	recovery.sanitize_progress()
	if recovery.unlocked_level != 2000 or recovery.coins != 0 or recovery.wood != 0 or recovery.experience != 0:
		fail("Naprawa zapisu nie ogranicza postępu albo walut.")
		return
	if not bool(recovery.owned_heroes.get("lada", false)) or recovery.active_heroes.size() < 1 or recovery.active_heroes.size() > 3:
		fail("Naprawa zapisu nie odtwarza bezpiecznego składu.")
		return
	if int(recovery.hero_levels.get("brun", 0)) != 50 or int(recovery.building_levels.get("kuznia", 0)) != 50:
		fail("Naprawa zapisu nie ogranicza poziomów do bezpiecznego maksimum.")
		return
	var coins_before_max_upgrade: int = recovery.coins
	var wood_before_max_upgrade: int = recovery.wood
	if recovery.try_upgrade_building("kuznia") or int(recovery.building_levels["kuznia"]) != recovery.MAX_BUILDING_LEVEL:
		fail("Osada pozwala ulepszyć budynek ponad maksymalny poziom.")
		return
	if recovery.coins != coins_before_max_upgrade or recovery.wood != wood_before_max_upgrade:
		fail("Próba ulepszenia maksymalnego budynku zużywa zasoby.")
		return
	recovery.free()
	# Rdzeń match-3: wielokrotne tworzenie planszy ma być stabilne i grywalne.
	var board_test = load("res://scripts/puzzle_level.gd").new()
	for attempt in 100:
		board_test.fill_fresh_board()
		if board_test.board.size() != 8 or not board_test.find_matches().is_empty() or not board_test.board_has_legal_move():
			fail("Plansza startowa nie jest stabilna lub nie ma legalnego ruchu (próba %d)." % attempt)
			return
		board_test.setup_obstacles({"id": 2000, "obstacles": {"root": 50, "stone": 50, "curse": 50}})
		var obstacle_count := 0
		for row in board_test.obstacles:
			for obstacle in row:
				if int(obstacle) > 0:
					obstacle_count += 1
		if obstacle_count > 48:
			fail("Limit przeszkód na planszy nie działa (próba %d)." % attempt)
			return
	board_test.free()
	print("Release smoke test passed: 2000 poziomów, cele, krainy i bossowie są spójne.")
	quit(0)
