extends RefCounted

# Każdy poziom od 2 do 50 daje punkt. Trzy ukończone gałęzie kosztują 48
# punktów; ostatni z 49 punktów jest zapasem na przyszłe rozszerzenie.
const BRANCHES := ["moc", "opieka", "splot"]
const RANK_CAPS := [3, 4, 4, 5]
const LEVEL_GATES := [2, 10, 22, 38]
const ELEMENT_NAMES := ["ogień", "woda", "liście", "bursztyn", "runy"]
const HERO_TREES := {
	"lada": {"element": 2, "names": ["Łuk Gromu", "Straż Dębu", "Splot Korzeni"]},
	"brun": {"element": 0, "names": ["Żar Kowala", "Pancerz Kuźni", "Kowadło Burzy"]},
	"mieta": {"element": 1, "names": ["Źródło Rosy", "Krąg Życia", "Wodny Szept"]},
	"wszebor": {"element": 0, "names": ["Ogień Straży", "Żelazna Warta", "Popielny Znak"]},
	"boruta": {"element": 0, "names": ["Rozłupanie", "Kamienna Skóra", "Korzeń Skały"]},
	"dobromir": {"element": 2, "names": ["Pieśń Dębu", "Osłona Korzeni", "Zielony Chór"]},
	"milena": {"element": 1, "names": ["Rosnąca Fala", "Deszcz Rosy", "Lustrzana Toń"]},
	"radomir": {"element": 3, "names": ["Bursztynowy Cios", "Złota Warta", "Blask Skarbu"]},
	"witosz": {"element": 2, "names": ["Szept Wiatru", "Lekki Krok", "Wir Liści"]},
	"jagna": {"element": 2, "names": ["Zielony Krąg", "Ziołowa Opieka", "Korona Gaju"]},
	"rada": {"element": 3, "names": ["Dar Bursztynu", "Złota Osłona", "Skarb Przodków"]},
	"welesa": {"element": 4, "names": ["Mgiełka Bagien", "Cicha Zasłona", "Runiczny Zmierzch"]},
	"zorya": {"element": 4, "names": ["Jutrzenka", "Świetlista Straż", "Pierwszy Znak"]},
	"jaromir": {"element": 0, "names": ["Przełamanie", "Straż Przodków", "Ostrze Rodu"]},
	"msciwoj": {"element": 0, "names": ["Ostrze Gromu", "Tarcza Żaru", "Burzowy Szlak"]},
	"dobrawa": {"element": 4, "names": ["Tkanie Run", "Runiczna Tarcza", "Nić Losu"]},
	"perunika": {"element": 4, "names": ["Piorunowa Strzała", "Burzowa Osłona", "Szlak Błyskawic"]},
	"czernik": {"element": 4, "names": ["Złamanie Klątwy", "Cień Kurhanu", "Pieczęć Nawi"]},
	"mirka": {"element": 1, "names": ["Dar Pokoju", "Łagodna Fala", "Źródło Zgody"]},
	"wlodzimierz": {"element": 3, "names": ["Kamienny Znak", "Mur Przodków", "Skała Gromu"]},
	"zywia": {"element": 4, "names": ["Gniew Burzy", "Oddech Życia", "Korona Piorunów"]},
	"mokosza": {"element": 2, "names": ["Matka Ziemi", "Opieka Gaju", "Splot Żywiołów"]},
	"stribog": {"element": 4, "names": ["Władca Wichru", "Skrzydło Wiatru", "Burza Znaków"]},
	"swarog": {"element": 0, "names": ["Kuźnia Słońca", "Słoneczny Mur", "Ognisty Krąg"]},
	"weles": {"element": 4, "names": ["Władca Przemian", "Zasłona Nawi", "Splot Światów"]}
}

static func node_key(branch: int, tier: int) -> String:
	return "%s_%d" % [BRANCHES[branch], tier]

static func branch_name(hero_id: String, branch: int) -> String:
	return str(HERO_TREES.get(hero_id, {}).get("names", ["Moc", "Opieka", "Splot"])[branch])

static func element(hero_id: String) -> int:
	return int(HERO_TREES.get(hero_id, {}).get("element", 0))

static func ranks(tree: Dictionary, branch: int, tier: int) -> int:
	return clampi(int(tree.get(node_key(branch, tier), 0)), 0, RANK_CAPS[tier])

static func branch_total(tree: Dictionary, branch: int) -> int:
	var total := 0
	for tier in RANK_CAPS.size():
		total += ranks(tree, branch, tier)
	return total

static func points_left(tree: Dictionary, hero_level: int) -> int:
	var used := 0
	for branch in BRANCHES.size():
		used += branch_total(tree, branch)
	return maxi(0, clampi(hero_level, 1, 50) - 1 - used)

static func can_invest(tree: Dictionary, hero_level: int, branch: int, tier: int) -> bool:
	if branch < 0 or branch >= BRANCHES.size() or tier < 0 or tier >= RANK_CAPS.size():
		return false
	if hero_level < LEVEL_GATES[tier] or points_left(tree, hero_level) <= 0:
		return false
	if ranks(tree, branch, tier) >= RANK_CAPS[tier]:
		return false
	return tier == 0 or ranks(tree, branch, tier - 1) == RANK_CAPS[tier - 1]

static func invest(tree: Dictionary, hero_level: int, branch: int, tier: int) -> bool:
	if not can_invest(tree, hero_level, branch, tier):
		return false
	var key := node_key(branch, tier)
	tree[key] = ranks(tree, branch, tier) + 1
	return true

static func sanitize(tree: Dictionary, hero_level: int) -> Dictionary:
	# Odtwarzaj tylko legalne punkty we właściwej kolejności, nawet gdy zapis
	# zawiera fałszywe poziomy, przeskoczone wymagania lub nadmiar punktów.
	var result := {}
	for tier in RANK_CAPS.size():
		for branch in BRANCHES.size():
			var wanted := clampi(int(tree.get(node_key(branch, tier), 0)), 0, RANK_CAPS[tier])
			for point in wanted:
				if not invest(result, hero_level, branch, tier):
					break
	return result

static func node_name(hero_id: String, branch: int, tier: int) -> String:
	var stems := ["Zalążek", "Wzmocnienie", "Przysięga", "Mistrzostwo"]
	return "%s: %s" % [stems[tier], branch_name(hero_id, branch)]

static func node_effect(branch: int, tier: int) -> String:
	var effects := [
		["+1 obrażenie za własny znak", "+3 obrażenia przy kombinacji 4+", "+4 obrażenia w kaskadzie", "+8 obrażeń za własny znak"],
		["+1 tarczy za własny znak", "+2 leczenia przy własnym znaku", "+3 maks. zdrowia", "+2 tarczy i leczenia za znak"],
		["+2 punkty za własny znak", "+2 obrażenia przy własnym 4+", "+4 punkty w kaskadzie", "+4 obrażenia i punkty za znak"]
	]
	return str(effects[branch][tier])

static func node_details(hero_id: String, branch: int, tier: int) -> Array[String]:
	var sign_name: String = ELEMENT_NAMES[element(hero_id)]
	var lines: Array[String] = []
	match branch:
		0:
			match tier:
				0: lines = ["Każdy zebrany własny znak (%s) wzmacnia atak." % sign_name, "+1 obrażenie za znak na każdą rangę."]
				1: lines = ["Przy układzie 4+, 5+ lub kwadracie z własnym znakiem", "+3 obrażenia na rangę."]
				2: lines = ["Kaskada z własnym znakiem uderza mocniej.", "+4 obrażenia na rangę za każdą kaskadę."]
				3: lines = ["Mistrzowski atak przy każdym własnym znaku.", "+8 obrażeń za znak na każdą rangę."]
		1:
			match tier:
				0: lines = ["Własne znaki (%s) osłaniają drużynę." % sign_name, "+1 punkt tarczy za znak na każdą rangę."]
				1: lines = ["Gdy pojawi się własny znak, bohater odzyskuje siły.", "+2 zdrowia na rangę, do maksimum zdrowia."]
				2: lines = ["Zwiększa maksymalne zdrowie tego bohatera.", "+3 punkty zdrowia na rangę."]
				3: lines = ["Własny znak jednocześnie chroni i leczy.", "+2 tarczy i +2 zdrowia za znak na rangę."]
		2:
			match tier:
				0: lines = ["Własne znaki (%s) podnoszą wynik." % sign_name, "+2 punkty za znak na każdą rangę."]
				1: lines = ["Układ 4+, 5+ lub kwadrat z własnym znakiem", "zadaje +2 obrażenia za znak na rangę."]
				2: lines = ["Kaskada z własnym znakiem daje premię do wyniku.", "+4 punkty na rangę za każdą kaskadę."]
				3: lines = ["Własny znak wzmacnia atak i wynik.", "+4 obrażenia i +4 punkty za znak na rangę."]
	return lines

static func invest_blocker(tree: Dictionary, hero_level: int, branch: int, tier: int) -> String:
	if ranks(tree, branch, tier) >= RANK_CAPS[tier]:
		return "Osiągnięto maksymalną rangę."
	if hero_level < LEVEL_GATES[tier]:
		return "Wymagany poziom bohatera: %d." % LEVEL_GATES[tier]
	if tier > 0 and ranks(tree, branch, tier - 1) < RANK_CAPS[tier - 1]:
		return "Najpierw rozwiń poprzedni talent do maksimum."
	if points_left(tree, hero_level) <= 0:
		return "Brak wolnych punktów umiejętności."
	return "Koszt: 1 punkt umiejętności."
