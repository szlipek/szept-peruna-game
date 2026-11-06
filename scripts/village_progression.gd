extends RefCounted

const HALL_ID := "dwor_wiecowy"
const MAX_LEVEL := 50
const REQUIREMENT_PAIRS := [
	["domostwa", "spichlerz"],
	["kuznia", "chata_zielarki"],
	["swiety_gaj", "wieza_peruna"],
	["tartak", "spichlerz"],
	["domostwa", "kuznia"],
	["chata_zielarki", "swiety_gaj"],
	["wieza_peruna", "tartak"],
]

static func level_cap(buildings: Dictionary) -> int:
	# Poziom I pozostaje dostępny przed budową Dworu, także w samouczku.
	return clampi(int(buildings.get(HALL_ID, 0)), 1, MAX_LEVEL)

static func hall_requirements(target_level: int) -> Dictionary:
	if target_level <= 1:
		return {"domostwa": 1, "tartak": 1}
	var pair: Array = REQUIREMENT_PAIRS[(target_level - 2) % REQUIREMENT_PAIRS.size()]
	return {pair[0]: target_level - 1, pair[1]: target_level - 1}

static func missing_requirements(building_id: String, buildings: Dictionary) -> Dictionary:
	var current := int(buildings.get(building_id, 0))
	var required := hall_requirements(current + 1) if building_id == HALL_ID else {HALL_ID: current + 1}
	# Pierwsze budynki nie wymagają Dworu, by nie tworzyć zamkniętej zależności.
	if building_id != HALL_ID and current == 0:
		return {}
	var missing := {}
	for required_id in required:
		if int(buildings.get(required_id, 0)) < int(required[required_id]):
			missing[required_id] = required[required_id]
	return missing

static func legacy_hall_level(buildings: Dictionary) -> int:
	# Stary zapis zachowuje możliwość korzystania z już rozbudowanej osady.
	var highest := 0
	for building_id in buildings:
		if building_id != HALL_ID:
			highest = maxi(highest, int(buildings[building_id]))
	return clampi(highest, 0, MAX_LEVEL)

static func campaign_milestone(building_id: String, buildings: Dictionary) -> int:
	var level := int(buildings.get(building_id, 0))
	if level == 0:
		return int({"kuznia": 5, "chata_zielarki": 10, "swiety_gaj": 20, "wieza_peruna": 20}.get(building_id, 0))
	if building_id == HALL_ID:
		return int({10: 20, 20: 50, 30: 100, 40: 250}.get(level, 0))
	return 0
