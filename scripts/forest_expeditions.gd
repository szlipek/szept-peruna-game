extends RefCounted

const MISSIONS := [
	{"id": "polana", "name": "Leśna polana", "hall": 0, "goal_type": "clear_obstacles", "goal_value": 6, "move_limit": 18, "wood": 25, "mechanic": "Usuń 6 korzeni w 18 ruchach", "obstacles": {"root": 6}, "health": 80, "attack": 2},
	{"id": "obrona", "name": "Obrona tartaku", "hall": 0, "goal_type": "survive", "goal_value": 6, "wood": 35, "mechanic": "Przetrwaj 6 tur; liście dają tarczę", "obstacles": {"root": 3}, "health": 260, "attack": 4},
	{"id": "karawana", "name": "Szlak drwali", "hall": 2, "goal_type": "collect_rune", "goal_value": 24, "move_limit": 16, "wood": 55, "mechanic": "Zbierz 24 runy w 16 ruchach", "obstacles": {"stone": 4}, "health": 220, "attack": 6},
	{"id": "korzenie", "name": "Splątana knieja", "hall": 3, "goal_type": "clear_obstacles", "goal_value": 12, "move_limit": 16, "wood": 75, "mechanic": "Usuń 12 przeszkód w 16 ruchach", "obstacles": {"root": 8, "stone": 4}, "health": 300, "attack": 8},
	{"id": "straz", "name": "Straż starego boru", "hall": 5, "goal_type": "defeat_enemy", "wood": 100, "mechanic": "Obrońca osłania uzdrowiciela; wybierz cel", "obstacles": {"root": 5, "curse": 3}, "health": 400, "attack": 10},
	{"id": "noc", "name": "Nocna warta", "hall": 8, "goal_type": "survive", "goal_value": 10, "wood": 140, "mechanic": "Przetrwaj 10 tur ataków zwiadowców", "obstacles": {"stone": 5, "curse": 4}, "health": 600, "attack": 13},
]

static func catalog(buildings: Dictionary) -> Array:
	var hall := maxi(1, int(buildings.get("dwor_wiecowy", 0)))
	var result: Array = []
	for index in MISSIONS.size():
		var mission: Dictionary = MISSIONS[index].duplicate(true)
		mission["expedition"] = true
		mission["required_level"] = 1
		mission["region"] = "debowepogranicze"
		# Wyprawy rosną z osadą; rozwój bohaterów daje realną przewagę.
		var health := int(mission["health"]) + (hall - 1) * (10 + index * 3)
		var attack := int(mission["attack"]) + int((hall - 1) / 3)
		mission["enemies"] = [{"name": "Korzeniowy strażnik", "health": health, "attack": attack, "role": "attacker"}]
		if index == 4:
			mission["enemies"] = [{"name": "Strażnik totemu", "health": health, "attack": attack, "role": "defender"}, {"name": "Mglisty sługa", "health": int(health * 0.6), "attack": attack, "role": "support"}]
		elif index == 5:
			mission["enemies"][0]["role"] = "scout"
		mission["rewards"] = {"wood": int(mission["wood"]) + (hall - 1) * (3 + index), "coins": 25 + index * 15, "experience": 35 + index * 20}
		result.append(mission)
	return result

static func effective_reward(mission: Dictionary, bonus_available: bool) -> Dictionary:
	var reward: Dictionary = mission.get("rewards", {}).duplicate(true)
	if bonus_available:
		reward["wood"] = int(reward.get("wood", 0)) * 2
	return reward
