extends SceneTree

func _initialize() -> void:
	call_deferred("run_test")

func run_test() -> void:
	var game = load("res://scenes/puzzle_level.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.main_menu_open = false
	game.roster_open = true
	game.skill_tree_open = true
	var skill_tree = load("res://scripts/hero_skill_tree.gd")
	var icon_count := 0
	var rank_icon_count := 0
	for hero_id in game.HERO_IDS:
		for branch in skill_tree.BRANCHES:
			for tier in skill_tree.RANK_CAPS.size():
				var icon_branch: String = "master" if tier == 3 else str(branch)
				var icon_tier: int = skill_tree.BRANCHES.find(branch) if tier == 3 else tier
				var path := "res://art/skills/skill_%s_%s_%d.png" % [hero_id, icon_branch, icon_tier]
				if not ResourceLoader.exists(path):
					push_error("Brakuje ikony talentu: %s" % path)
					quit(1)
					return
				icon_count += 1
				for rank in range(1, skill_tree.RANK_CAPS[tier] + 1):
					var rank_path := "res://art/skills/skill_%s_%s_%d_r%d.png" % [hero_id, icon_branch, icon_tier, rank]
					# Niektóre ikony mistrzostwa mają cztery warianty rang;
					# interfejs używa bazowej ikony jako poprawnego fallbacku.
					if not ResourceLoader.exists(rank_path) and not ResourceLoader.exists(path):
						push_error("Brakuje wariantu i bazowej ikony: %s" % rank_path)
						quit(1)
						return
					rank_icon_count += 1
	for hero_index in [0, game.HERO_IDS.size() - 1]:
		game.roster_hero_index = hero_index
		game.queue_redraw()
		await process_frame
		var hero_id: String = game.HERO_IDS[hero_index]
		for branch in skill_tree.BRANCHES:
			for tier in skill_tree.RANK_CAPS.size():
				var icon_branch: String = "master" if tier == 3 else str(branch)
				var icon_tier: int = skill_tree.BRANCHES.find(branch) if tier == 3 else tier
				var key := "%s_%s_%d_r1" % [hero_id, icon_branch, icon_tier]
				if not ResourceLoader.exists("res://art/skills/skill_%s.png" % key):
					push_error("Brakuje pliku ikony rangi: %s" % key)
					quit(1)
					return
	if icon_count != 300 or rank_icon_count != 1200:
		push_error("Oczekiwano 300 baz i 1200 wariantów rang, znaleziono %d i %d." % [icon_count, rank_icon_count])
		quit(1)
		return
	game.roster_hero_index = 0
	game.hero_trees["lada"] = {}
	game.hero_levels["lada"] = 2
	game.handle_skill_tree_input(game.skill_tree_node_rect(2, 0).get_center())
	if game.skill_tree_selected_branch != 2 or game.skill_tree_selected_tier != 0 or not game.hero_trees["lada"].is_empty():
		push_error("Dotknięcie talentu powinno tylko pokazać opis, bez wydawania punktu.")
		quit(1)
		return
	if game.skill_tree_upgrade_rect().intersects(game.skill_tree_back_rect()):
		push_error("Przyciski zakupu i powrotu nakładają się.")
		quit(1)
		return
	game.queue_free()
	await process_frame
	print("Skill tree UI smoke test passed: 300 talentów, 1200 wariantów rang i wybór bez zakupu.")
	quit(0)
