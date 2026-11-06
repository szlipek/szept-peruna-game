extends Node2D

const SkillTree = preload("res://scripts/hero_skill_tree.gd")
const GameAudio = preload("res://scripts/game_audio.gd")
const VillageProgression = preload("res://scripts/village_progression.gd")
const ForestExpeditions = preload("res://scripts/forest_expeditions.gd")
var forest_expeditions_view = preload("res://scripts/forest_expeditions_view.gd").new()
const PlayerOpening = preload("res://scripts/player_opening.gd")
var player_opening = PlayerOpening.new()
const GroveShop = preload("res://scripts/grove_shop.gd")
var grove_shop = GroveShop.new()

## Prototyp Fazy A: plansza 8×8, zamiana sąsiednich kafelków, match-3,
## kaskady, punkty, walka turowa i lokalny zapis.

const BOARD_SIZE := 8
const FIRST_TUTORIAL_MOVE_FROM := Vector2i(3, 4)
const FIRST_TUTORIAL_MOVE_TO := Vector2i(3, 3)
const LEVEL_TWO_TUTORIAL_FROM := Vector2i(2, 6)
const LEVEL_TWO_TUTORIAL_TO := Vector2i(2, 5)
const TILE_TYPES := 5
const LADA_MAX_CHARGE := 8
const BRUN_MAX_CHARGE := 7
const MIETA_MAX_CHARGE := 7
const MAX_CASCADE_STEPS := 30
const MAX_HERO_LEVEL := 50
const MAX_BUILDING_LEVEL := 50
const WINS_BETWEEN_INTERSTITIALS := 4
const MAX_INTERSTITIALS_PER_DAY := 2
const HERO_IDS := ["lada", "brun", "mieta", "wszebor", "boruta", "dobromir", "milena", "radomir", "witosz", "jagna", "rada", "welesa", "zorya", "jaromir", "msciwoj", "dobrawa", "perunika", "czernik", "mirka", "wlodzimierz", "zywia", "mokosza", "stribog", "swarog", "weles"]
const HERO_NAMES := ["Lada", "Brun", "Mięta", "Wszebor", "Boruta", "Dobromir", "Milena", "Radomir", "Witosz", "Jagna", "Rada", "Welesa", "Zorya", "Jaromir", "Mściwoj", "Dobrawa", "Perunika", "Czernik", "Mirka", "Włodzimierz", "Żywia", "Mokosza", "Stribóg", "Swaróg", "Weles"]
const HERO_CLASSES := {"lada": "ZWYKŁA", "brun": "ZWYKŁA", "mieta": "ZWYKŁA", "wszebor": "ZWYKŁA", "boruta": "ZWYKŁA", "dobromir": "ZWYKŁA", "milena": "ZWYKŁA", "radomir": "ZWYKŁA", "witosz": "ZWYKŁA", "jagna": "ZWYKŁA", "rada": "PREMIUM", "welesa": "PREMIUM", "zorya": "PREMIUM", "jaromir": "PREMIUM", "msciwoj": "PREMIUM", "dobrawa": "PREMIUM", "perunika": "PREMIUM", "czernik": "PREMIUM", "mirka": "PREMIUM", "wlodzimierz": "PREMIUM", "zywia": "LEGENDA", "mokosza": "LEGENDA", "stribog": "LEGENDA", "swarog": "LEGENDA", "weles": "LEGENDA"}
const HERO_SKILLS := {
	"lada": "Strzała Peruna: niszczy kolumnę",
	"brun": "Uderzenie Kowala: niszczy 3×3",
	"mieta": "Krąg Uzdrowienia: leczy z wody",
	"wszebor": "Żar Strażnika: +3 obrażenia za ogień",
	"rada": "Dar Bursztynu: +2 monety za bursztyn",
	"zywia": "Gniew Burzy: +6 obrażeń za runę",
	"boruta": "Rozbicie Skały: ogień zadaje +2 obrażenia przeszkodom",
	"dobromir": "Pieśń Dębu: liście dają +1 tarczy całej drużynie",
	"milena": "Źródło Rosy: woda leczy dodatkowe 2 zdrowia",
	"radomir": "Bursztynowy Cios: bursztyn daje +4 obrażenia",
	"witosz": "Szept Wiatru: kombinacja 4+ daje +1 do następnej tarczy",
	"jagna": "Zielony Krąg: każdy liść leczy najsłabszego bohatera o 1",
	"welesa": "Mgiełka Bagien: runy osłabiają następny atak wroga o 1",
	"zorya": "Jutrzenka: pierwsza kombinacja tury daje +20 punktów",
	"jaromir": "Straż Przodków: obrońcy otrzymują 15% więcej obrażeń",
	"msciwoj": "Ostrze Gromu: ogień w kombie 4+ zadaje +4 obrażenia",
	"dobrawa": "Tkanie Run: runy zwiększają tarczę o 2",
	"perunika": "Piorunowa Strzała: kombinacja 5+ daje +6 tarczy",
	"czernik": "Cień Kurhanu: klątwy szybciej tracą wytrzymałość",
	"mirka": "Dar Pokoju: leczenie rozdziela 2 zdrowia na drużynę",
	"wlodzimierz": "Kamienny Znak: kamienie mają o 1 mniej wytrzymałości",
	"mokosza": "Matka Ziemi: liście i woda wspólnie dają +4 tarczy",
	"stribog": "Władca Wichru: kombinacja 5+ zadaje +10 obrażeń",
	"swarog": "Kuźnia Słońca: ogień i bursztyn dają +8 obrażeń",
	"weles": "Władca Przemian: pierwsza kaskada po turze zadaje podwójne obrażenia"
}
const BUILDING_IDS := ["domostwa", "kuznia", "chata_zielarki", "swiety_gaj", "spichlerz", "wieza_peruna", "tartak", "dwor_wiecowy"]
const BUILDING_NAMES := ["Domostwa", "Kuźnia", "Chata Zielarki", "Święty Gaj", "Spichlerz", "Wieża Peruna", "Tartak", "Dwór Wiecowy"]
const SAWMILL_WOOD_PER_HOUR_PER_LEVEL := 20.0
const SAWMILL_OFFLINE_CAP_SECONDS := 86400.0
const DEFAULT_LEVELS := [
	{"id": 1, "target": 600, "name": "Pierwszy szept"},
	{"id": 2, "target": 850, "name": "Ślad w mchu"},
	{"id": 3, "target": 1050, "name": "Żar kowadła"},
	{"id": 4, "target": 1250, "name": "Źródło Miety"},
	{"id": 5, "target": 1500, "name": "Próba dębu"}
]
const TILE_COLORS := [Color("#c4523b"), Color("#4a92bd"), Color("#5f9c56"), Color("#d49a34"), Color("#8b61a8")]
const TILE_SIGNS := ["✦", "≈", "♣", "◆", "ᚱ"]
const HERO_RECRUIT_COSTS := {"brun": 1200, "mieta": 1500, "wszebor": 2200, "boruta": 2600, "dobromir": 3000, "milena": 3400, "radomir": 3800, "witosz": 4300, "jagna": 4800, "rada": 12, "welesa": 16, "zorya": 20, "jaromir": 24, "msciwoj": 28, "dobrawa": 32, "perunika": 36, "czernik": 40, "mirka": 44, "wlodzimierz": 48, "zywia": 4, "mokosza": 5, "stribog": 6, "swarog": 7, "weles": 8}
const HERO_SYNERGIES := {"lada": "Najlepiej z Dobromirem i Mokoszą", "brun": "Najlepiej z Borutą i Swarogiem", "mieta": "Najlepiej z Mileną i Mirką", "wszebor": "Najlepiej z Brunem i Mściwojem", "boruta": "Najlepiej z Brunem i Włodzimierzem", "dobromir": "Najlepiej z Ladą i Jagną", "milena": "Najlepiej z Mietą i Mokoszą", "radomir": "Najlepiej z Radą i Swarogiem", "witosz": "Najlepiej z Peruniką i Stribogiem", "jagna": "Najlepiej z Ladą i Dobromirem", "rada": "Najlepiej z Radomirem i Swarogiem", "welesa": "Najlepiej z Czernikiem i Welesem", "zorya": "Najlepiej z Peruniką i Ladą", "jaromir": "Najlepiej z Brunem i Dobrawą", "msciwoj": "Najlepiej z Wszeborem i Brunem", "dobrawa": "Najlepiej z Żywią i Jaromirem", "perunika": "Najlepiej z Witoszem i Zoryą", "czernik": "Najlepiej z Welesą i Welesem", "mirka": "Najlepiej z Mietą i Mileną", "wlodzimierz": "Najlepiej z Borutą i Brunem", "zywia": "Najlepiej z Dobrawą i Welesem", "mokosza": "Najlepiej z Mietą i Dobromirem", "stribog": "Najlepiej z Witoszem i Peruniką", "swarog": "Najlepiej z Brunem i Radomirem", "weles": "Najlepiej z Welesą i Żywią"}
const HERO_SYNERGY_PAIRS := [["lada", "dobromir"], ["lada", "mokosza"], ["lada", "zorya"], ["brun", "boruta"], ["brun", "swarog"], ["brun", "wszebor"], ["brun", "jaromir"], ["brun", "msciwoj"], ["brun", "wlodzimierz"], ["mieta", "milena"], ["mieta", "mirka"], ["mieta", "mokosza"], ["dobromir", "jagna"], ["radomir", "rada"], ["radomir", "swarog"], ["witosz", "perunika"], ["witosz", "stribog"], ["perunika", "zorya"], ["jaromir", "dobrawa"], ["dobrawa", "zywia"], ["welesa", "czernik"], ["welesa", "weles"], ["czernik", "weles"], ["zywia", "weles"]]
const LEGENDARY_EVENT_MARK_COST := 4
const ENEMY_ROLES := {
	"Cień mchu": "scout", "Kruczy posłaniec": "scout", "Popielny chochlik": "scout", "Bursztynowy chrząszcz": "scout", "Zimny chochlik": "scout", "Mroczna ćma": "scout", "Duch jaru": "scout",
	"Korzeniowy strażnik": "defender", "Ropuch kurhanów": "defender", "Kamienny gąsienicznik": "defender", "Dąbrowy drwal widmo": "defender", "Gliniany sługa": "defender", "Strażnik totemu": "defender", "Kościany kurhanek": "defender", "Korzeń Leszego": "defender", "Korzeń gniewu": "defender",
	"Wilcze szczenię cienia": "attacker", "Szczenię cienia": "attacker", "Topielec źródlany": "attacker", "Żmijowe pisklę": "attacker", "Cierniowy wilk": "attacker", "Kruczy rycerz": "attacker", "Płomienny chochlik": "attacker", "Leszy": "attacker", "Wilk cienia": "attacker", "Stary Leszy": "attacker",
	"Mglisty sługa": "support", "Widmo żaren": "support", "Szeptnica bagienna": "support", "Zarośnięty wędrowiec": "support", "Duch dębu": "support",
	"Utopiec z trzcin": "attacker", "Mgielna rusałka": "support", "Wodny chochlik": "scout", "Strażnik wiru": "defender", "Topielny krab": "defender", "Król Topielców": "attacker", "Pani Głębin": "support",
	"Lodowy wid": "support", "Zamrożona wrona": "scout", "Córka zamieci": "attacker", "Srebrny upiór": "support", "Strażnik szronu": "defender", "Pani Zimy": "attacker", "Marzannowy Herold": "defender",
	"Żmijowy zwiadowca": "scout", "Jaskiniowy duch": "support", "Strażnik skarbca": "defender", "Jadowity bazyliszek": "attacker", "Wężowy skryba": "support", "Matka Żmijów": "attacker", "Wąż Wiślany": "attacker",
	"Cień pamięci": "scout", "Widmo przewoźnika": "support", "Nawijski strażnik": "defender", "Przewoźnik": "attacker", "Królowa Kurhanów": "support",
	"Złoty posłaniec": "scout", "Strażnik równowagi": "defender", "Świetlisty woj": "attacker", "Runiczna sowa": "support", "Opiekun przysięgi": "defender", "Strażnik Równowagi": "defender", "Władca Kruczych Znaków": "attacker",
	"Czarny Bóg Przesmyku": "attacker", "Serce Starego Dębu": "defender"
}
const TRAINING_BATTLES := [
	{"required_level": 1, "name": "Ćwiczenie: Mchy", "goal_type": "defeat_enemy", "mechanic": "Podstawowe kombinacje", "enemies": [{"name": "Cień mchu", "health": 42, "attack": 2}], "rewards": {"coins": 8, "wood": 0, "experience": 55}},
	{"required_level": 5, "name": "Ćwiczenie: Żar", "goal_type": "defeat_enemy", "mechanic": "Ogień zadaje większe obrażenia", "enemies": [{"name": "Popielny chochlik", "health": 58, "attack": 3}], "rewards": {"coins": 15, "wood": 0, "experience": 100}},
	{"required_level": 10, "name": "Ćwiczenie: Straż gaju", "goal_type": "defeat_enemy", "mechanic": "Korzenie zarastają pola", "enemies": [{"name": "Korzeniowy strażnik", "health": 76, "attack": 4}], "rewards": {"coins": 30, "wood": 2, "experience": 180}},
	{"required_level": 15, "name": "Próba kamienia", "goal_type": "defeat_enemy", "mechanic": "Kamienie chronią wroga", "enemies": [{"name": "Kamienny gąsienicznik", "health": 120, "attack": 6}], "obstacles": {"stone": 8}, "rewards": {"coins": 45, "wood": 5, "experience": 280}},
	{"required_level": 20, "name": "Próba klątwy", "goal_type": "defeat_enemy", "mechanic": "Klątwy wzmacniają atak", "enemies": [{"name": "Ropuch kurhanów", "health": 155, "attack": 8}], "obstacles": {"curse": 7}, "rewards": {"coins": 70, "wood": 8, "experience": 400}},
	{"required_level": 25, "name": "Krąg strażnika", "goal_type": "defeat_enemy", "mechanic": "Korzenie, kamienie i klątwy", "enemies": [{"name": "Strażnik totemu", "health": 230, "attack": 11}], "obstacles": {"root": 5, "stone": 5, "curse": 4}, "rewards": {"coins": 110, "wood": 12, "experience": 600}},
	{"required_level": 30, "name": "Próba bagien", "goal_type": "defeat_enemy", "mechanic": "Woda leczy, klątwy wzmacniają atak", "enemies": [{"name": "Topielec źródlany", "health": 280, "attack": 13}], "obstacles": {"root": 6, "curse": 5}, "rewards": {"coins": 150, "wood": 16, "experience": 820}},
	{"required_level": 40, "name": "Próba mgły", "goal_type": "defeat_enemy", "mechanic": "Wróg wspiera swoich sojuszników", "enemies": [{"name": "Mglisty sługa", "health": 340, "attack": 15}], "obstacles": {"stone": 7, "curse": 5}, "rewards": {"coins": 210, "wood": 22, "experience": 1100}},
	{"required_level": 50, "name": "Strażnik szczytów", "goal_type": "defeat_enemy", "mechanic": "Kamienny pancerz i silne kaskady", "enemies": [{"name": "Strażnik szronu", "health": 420, "attack": 18}], "obstacles": {"stone": 9, "root": 5}, "rewards": {"coins": 290, "wood": 30, "experience": 1450}},
	{"required_level": 60, "name": "Próba Żmija", "goal_type": "defeat_enemy", "mechanic": "Ogień przełamuje obronę", "enemies": [{"name": "Żmijowe pisklę", "health": 510, "attack": 21}], "obstacles": {"curse": 8, "stone": 6}, "rewards": {"coins": 380, "wood": 38, "experience": 1850}},
	{"required_level": 70, "name": "Próba Nawii", "goal_type": "defeat_enemy", "mechanic": "Runy osłabiają nadchodzący atak", "enemies": [{"name": "Nawijski strażnik", "health": 620, "attack": 24}], "obstacles": {"root": 8, "curse": 8}, "rewards": {"coins": 490, "wood": 48, "experience": 2350}},
	{"required_level": 80, "name": "Próba równowagi", "goal_type": "defeat_enemy", "mechanic": "Wróg łączy trzy role", "enemies": [{"name": "Strażnik równowagi", "health": 750, "attack": 28}], "obstacles": {"root": 7, "stone": 7, "curse": 7}, "rewards": {"coins": 620, "wood": 60, "experience": 2950}},
	{"required_level": 90, "name": "Próba burzy", "goal_type": "defeat_enemy", "mechanic": "Każda tura zwiększa presję", "enemies": [{"name": "Władca Kruczych Znaków", "health": 900, "attack": 32}], "obstacles": {"stone": 10, "curse": 8}, "rewards": {"coins": 780, "wood": 74, "experience": 3650}},
	{"required_level": 100, "name": "Wielki krąg", "goal_type": "defeat_enemy", "mechanic": "Pełny sprawdzian wszystkich przeszkód", "enemies": [{"name": "Czarny Bóg Przesmyku", "health": 1100, "attack": 38}], "obstacles": {"root": 9, "stone": 9, "curse": 9}, "rewards": {"coins": 1000, "wood": 95, "experience": 4600}}
]
const REGION_INTROS := {
	21: ["ŚWIĘTY GAJ", "Korzenie starych dębów pamiętają imiona tych, którzy zaginęli. Idź ostrożnie — gaj słucha każdego kroku."],
	36: ["BAGNA WELESA", "Mgła zasnuwa wodę, a pod jej powierzchnią budzą się dawne przysięgi. Nie ufaj temu, co widzisz."],
	46: ["GÓRY PERUNA", "Grzmot odbija się od kamiennych ścian. Tylko wytrwali usłyszą odpowiedź boga burzy."],
	56: ["CIENIE NAWII", "Granica między światami staje się cienka. Zabierz światło Gaju ze sobą."],
	71: ["PRAWIA", "Za cieniem Nawii otwiera się kraina ładu. Jej światło nie wybacza niepewnych kroków."],
	86: ["GRZMOTNE SZCZYTY", "Na granicy chmur Perun mierzy odwagę tych, którzy chcą dosięgnąć jego kamienia."],
}
const REGION_CHAPTERS := {
	"prawia": ["POWRÓT DO PRAWII", "Światło ładu prowadzi dalej, lecz każda próba odsłania nową rysę w równowadze świata."],
	"grzmotne_szczyty": ["SZLAK GROMU", "Kamienie pamiętają kroki dawnych wojowników. Każdy grzmot jest ostrzeżeniem i obietnicą."],
	"nawia": ["PĘTLA NAWII", "Mgła wraca cichsza niż wcześniej. Nie pozwól, by wspomnienia przejęły drogę."],
	"swiety_gaj": ["ODDECH GAJU", "Korzenie znów budzą się pod stopami. Oczyść drogę, zanim cień wrośnie w ich serce."],
	"jeziora_rusalek": ["JEZIORA RUSAŁEK", "Woda pamięta każdą obietnicę. Jej wiry mogą uleczyć drogę albo pociągnąć w głąb."],
	"ziemie_marzanny": ["ZIEMIE MARZANNY", "Mróz zatrzymuje kroki, lecz nie zatrzyma iskry, która płonie w sercu drużyny."],
	"kraina_zmijow": ["KRAINA ŻMIJÓW", "W szczelinach skał syczą stare rody. Ogień jest tu językiem odwagi."],
	"korona_drzewa": ["KORONA DRZEWA ŚWIATA", "Korzenie i gwiazdy spotykają się nad tobą. Ostatni szlak wymaga równowagi wszystkich mocy."]
}
const CAMPAIGN_STORY := {
	1: [
		{"speaker": "Lada", "portrait": "lada", "text": "Od trzech nocy Dąb nie wypuszcza liści. Nawet ptaki ucichły."},
		{"speaker": "Lada", "portrait": "lada", "text": "W jego korze tli się obca runa. Ktoś wysysa z gaju pamięć i życie."},
		{"speaker": "Lada", "portrait": "lada", "text": "Cień mchu strzeże pierwszego śladu. Pomóż mi go odnaleźć."}
	],
	2: [
		{"speaker": "Lada", "portrait": "lada", "text": "To nie był zwykły potwór. Runa poruszała nim jak marionetką."},
		{"speaker": "Brun", "portrait": "brun", "requires": "brun", "text": "Znam ten zapach. Popiół z kuźni, której ogień zgasł sto lat temu."},
		{"speaker": "Mięta", "portrait": "mieta", "requires": "mieta", "text": "A ja słyszę wodę płynącą pod ziemią. Prowadzi wprost do starego źródła."}
	],
	5: [
		{"speaker": "Lada", "portrait": "lada", "text": "Leszy! Ten znak płonie na jego piersi. Nie pozwólcie, by runa przejęła nad nim władzę."},
		{"speaker": "Brun", "portrait": "brun", "requires": "brun", "text": "Uderzę w korzenie, ty dosięgnij znaku. Musimy go uwolnić, nie zgubić!"},
		{"speaker": "Mięta", "portrait": "mieta", "requires": "mieta", "text": "Odsłonię wodą krawędź runy. Lada, uderz w znak, zanim zdąży pochłonąć Leszego!"}
	],
	6: [
		{"speaker": "Leszy", "portrait": "enemy", "text": "Dzieci gaju… Wybaczcie. Coś szeptało moim głosem i karmiło się waszym strachem."},
		{"speaker": "Lada", "portrait": "lada", "text": "Kto wyrył runę?"},
		{"speaker": "Leszy", "portrait": "enemy", "text": "Ten, który nie ma imienia. Szuka serca Dębu. A jego słudzy idą za bursztynowym szlakiem."}
	],
	10: [
		{"speaker": "Mięta", "portrait": "mieta", "text": "Woda pokazuje mi twarze ludzi z osady. Każdy śni o czarnym lesie i bezlistnym Dębie."},
		{"speaker": "Lada", "portrait": "lada", "text": "To nie są sny. Ktoś wplata runy w ich wspomnienia, żeby nikt nie pamiętał drogi do źródła."},
		{"speaker": "Brun", "portrait": "brun", "text": "Więc przerwiemy mu tę pieśń. Zanim zapomnimy, po co wyruszyliśmy."}
	],
	11: [
		{"speaker": "Lada", "portrait": "lada", "text": "Kruczy posłaniec niósł mapę, ale jej znaki zmieniają się, gdy na nie patrzę."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "Nie patrz na tusz. Słuchaj strumienia. Pod mapą ukryto prawdziwą drogę — na mokradła Welesa."}
	],
	15: [
		{"speaker": "Mięta", "portrait": "mieta", "text": "Król Topielców nie atakuje źródła. Zasłania je własnym ciałem."},
		{"speaker": "Lada", "portrait": "lada", "text": "Runa oplata jego koronę. Uwolnijmy go, zanim bagna stracą ostatnią czystą wodę."},
		{"speaker": "Brun", "portrait": "brun", "text": "Jeśli usłyszy nas choć przez chwilę, nie będzie musiał walczyć sam."}
	],
	16: [
		{"speaker": "Król Topielców", "portrait": "enemy", "text": "Nie byłem jej strażnikiem. Próbowałem powstrzymać ją przed wypłynięciem na powierzchnię."},
		{"speaker": "Lada", "portrait": "lada", "text": "Czarna runa pękła, ale jej cień popłynął dalej. Ku sercu gaju."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "Teraz przynajmniej wiemy: nie ścigamy potwora. Ścigamy to, co potwory przed nim ukrywają."}
	],
	20: [
		{"speaker": "Lada", "portrait": "lada", "text": "Strażnik dębu nie walczył z nami. Zamykał przejście do korzeni, bo coś już tam weszło."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "Pod ziemią nie płynie woda. Płynie światło — i ktoś je dusi."},
		{"speaker": "Brun", "portrait": "brun", "text": "W takim razie kończymy pościg. Wchodzimy do Świętego Gaju."}
	],
	21: [
		{"speaker": "Lada", "portrait": "lada", "text": "Korzenie pamiętają imiona zaginionych. Jedno z nich powtarza się wszędzie: Perun."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "To nie imię ofiary. To ostrzeżenie. Grom milczy, bo ktoś zamknął jego echo w kamieniu."},
		{"speaker": "Brun", "portrait": "brun", "text": "Odnajdziemy kamień. A potem zmusimy go, żeby przemówił."}
	],
	25: [
		{"speaker": "Strażnik Bursztynowej Jaskini", "portrait": "enemy", "text": "Nie oddam wam serca jaskini. W jego świetle wciąż widzę twarz mojej córki."},
		{"speaker": "Lada", "portrait": "lada", "text": "To nie jej twarz. Runa karmi cię wspomnieniem, żebyś strzegł jej więzienia."},
		{"speaker": "Brun", "portrait": "brun", "text": "Rozbijmy bursztyn. Nie pozwolimy, żeby pamięć stała się łańcuchem."}
	],
	30: [
		{"speaker": "Rusałka z Czarnego Stawu", "portrait": "enemy", "text": "Oddajcie mi głos. Woda pamięta słowo, którym cień nazwał samego siebie."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "Odbiorę runie to, co ukradła. Ty powiedz nam, czego boi się najbardziej."},
		{"speaker": "Lada", "portrait": "lada", "text": "Milczenia. Bez cudzych wspomnień nie potrafi istnieć."}
	],
	35: [
		{"speaker": "Królowa Kurhanów", "portrait": "enemy", "text": "Widziałam go przed wiekami. Nie miał imienia, dopóki nie zabrał go umarłym."},
		{"speaker": "Lada", "portrait": "lada", "text": "Więc każde uratowane wspomnienie odbiera mu część siły."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "Na bagnach zostały głosy, których jeszcze nie odzyskaliśmy. Musimy tam wrócić."}
	],
	40: [
		{"speaker": "Król Topielców", "portrait": "enemy", "text": "Wróciliście. Dobrze. Woda oddała mi wspomnienie, które runa próbowała wymazać."},
		{"speaker": "Lada", "portrait": "lada", "text": "Kim był, zanim stał się cieniem?"},
		{"speaker": "Król Topielców", "portrait": "enemy", "text": "Strażnikiem burzy. I pierwszym, który odwrócił się od Peruna."}
	],
	45: [
		{"speaker": "Pan Zimnych Mgieł", "portrait": "enemy", "text": "Zamroziłem echo, żeby nie zawołało swego pana."},
		{"speaker": "Brun", "portrait": "brun", "text": "A teraz echo woła nas. Za górami jest ktoś, kto może odpowiedzieć."},
		{"speaker": "Lada", "portrait": "lada", "text": "Wtedy przestaniemy tylko gasić runy. Dowiemy się, kto je rozpalił."}
	],
	50: [
		{"speaker": "Strażnik szronu", "portrait": "enemy", "text": "Burza nie jest więźniem kamienia. To kamień więzi coś, co burza kiedyś odrzuciła."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "Część Peruna? Jego gniew, oddzielony od reszty?"},
		{"speaker": "Lada", "portrait": "lada", "text": "Jeśli to prawda, nie możemy po prostu go zniszczyć."}
	],
	55: [
		{"speaker": "Lada", "portrait": "lada", "text": "Echo wskazuje na Nawię. Tam runy nie pokazują tego, co było — tylko to, co mogłoby się stać."},
		{"speaker": "Brun", "portrait": "brun", "text": "Niech pokażą najgorszą wersję. Tym razem żadne z nas nie pójdzie tam samo."}
	],
	60: [
		{"speaker": "Matka Żmijów", "portrait": "enemy", "text": "Cień obiecał mi powrót tych, których straciłam. Dałam mu w zamian własne imię."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "Możemy ci je oddać. Ale musisz przestać karmić jego runy."},
		{"speaker": "Matka Żmijów", "portrait": "enemy", "text": "W takim razie posłuchajcie: to, co odpadło od Peruna, chce znów być całością."}
	],
	65: [
		{"speaker": "Lada", "portrait": "lada", "text": "Jeśli cień jest częścią Peruna, jego gniew może spalić cały świat, gdy do niego wróci."},
		{"speaker": "Brun", "portrait": "brun", "text": "Nie pozwolimy mu wrócić jako gniew. Pokażemy mu, co jeszcze może czuć."}
	],
	70: [
		{"speaker": "Nawijski strażnik", "portrait": "enemy", "text": "Widziałem wasze drogi. W każdej zwycięstwo wymagało ofiary."},
		{"speaker": "Lada", "portrait": "lada", "text": "Nie wierzę w przyszłość, która każe nam zostawić kogoś z tyłu."},
		{"speaker": "Nawijski strażnik", "portrait": "enemy", "text": "W takim razie Prawia wystawi was na próbę, której nie da się wygrać siłą."}
	],
	75: [
		{"speaker": "Opiekun przysięgi", "portrait": "enemy", "text": "Perun i jego cień złożyli kiedyś tę samą przysięgę: chronić świat, choćby mieli go za to znienawidzić."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "A potem zapomnieli, że świat to nie tylko kamień i grom. To także ludzie, których kochają."}
	],
	80: [
		{"speaker": "Strażnik równowagi", "portrait": "enemy", "text": "Cień nie przybył z zewnątrz. To gniew Peruna odcięty od jego serca."},
		{"speaker": "Lada", "portrait": "lada", "text": "Nie pokonamy go, rozcinając go na kolejne kawałki."},
		{"speaker": "Brun", "portrait": "brun", "text": "Najpierw musimy sprawić, żeby znów usłyszał coś poza własnym gniewem."}
	],
	85: [
		{"speaker": "Lada", "portrait": "lada", "text": "Znamy już prawdę, ale Czarny Bóg jest blisko kamienia Peruna."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "Odzyskane wspomnienia wiążą go mocniej niż jakiekolwiek łańcuchy. Przywołajmy je, zanim uderzymy."}
	],
	90: [
		{"speaker": "Władca Kruczych Znaków", "portrait": "enemy", "text": "Nie zatrzymacie go. Cień już dotyka kamienia, a grom odpowiada na każde jego słowo."},
		{"speaker": "Lada", "portrait": "lada", "text": "Nie odpowiada jemu. Odpowiada tym, których pamięci nie zdołał ukraść."},
		{"speaker": "Brun", "portrait": "brun", "text": "Jeszcze pięć kroków. Potem przemówi za nas cała droga."}
	],
	95: [
		{"speaker": "Mięta", "portrait": "mieta", "text": "Słyszę Peruna. Nie prosi o ratunek. Prosi, żebyśmy nie nienawidzili tego, co z niego odpadło."},
		{"speaker": "Lada", "portrait": "lada", "text": "Nie obiecuję, że mu wybaczę. Obiecuję, że najpierw spróbuję go zrozumieć."}
	],
	36: [
		{"speaker": "Mięta", "portrait": "mieta", "text": "Bagna oddają głosy tych, którzy zaginęli. Jeden z nich zna imię bezimiennego."},
		{"speaker": "Lada", "portrait": "lada", "text": "Nie możemy pozwolić, by mgła skłóciła nas tymi szeptami. Trzymajmy się razem."}
	],
	46: [
		{"speaker": "Brun", "portrait": "brun", "text": "W górach Peruna runy są starsze niż osady. Ktoś nie kradnie już mocy — układa z niej własne wezwanie."},
		{"speaker": "Lada", "portrait": "lada", "text": "Jeśli dokończy znak, obudzi coś po drugiej stronie burzy."}
	],
	56: [
		{"speaker": "Lada", "portrait": "lada", "text": "Nawia pamięta każdą wersję naszej drogi. W jednej z nich już przegraliśmy."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "To tylko wspomnienie, nie przepowiednia. Wybierzmy drogę, której jeszcze nie widziała."}
	],
	71: [
		{"speaker": "Lada", "portrait": "lada", "text": "W Prawii wszystko ma swoje miejsce. Nawet cień — jeśli ktoś go tam umieścił."},
		{"speaker": "Brun", "portrait": "brun", "text": "Znalazłem znak pod posadzką. Ten, kto go stworzył, znał nasze ruchy, zanim wyruszyliśmy."}
	],
	86: [
		{"speaker": "Lada", "portrait": "lada", "text": "Jesteśmy pod samym kamieniem Peruna. Czarny znak oplata go jak łańcuch."},
		{"speaker": "Mięta", "portrait": "mieta", "text": "To nie potwór więzi grom. To grom więzi potwora."},
		{"speaker": "Brun", "portrait": "brun", "text": "Jeszcze jeden szlak. Tym razem nie pozwolimy mu uciec."}
	],
	100: [
		{"speaker": "Lada", "portrait": "lada", "text": "Czarny Bóg Przesmyku czeka przy sercu Dębu. Nie ma twarzy — tylko głosy tych, których skrzywdził."},
		{"speaker": "Czarny Bóg Przesmyku", "portrait": "enemy", "text": "Przyszedłeś po grom? Perun milczał, zanim ty nauczyłeś się słuchać."},
		{"speaker": "Lada", "portrait": "lada", "text": "Może. Ale nie będziesz już mówił za niego."}
	],
	101: [
		{"speaker": "Perun", "portrait": "unknown", "text": "Słyszę was. Nie przez runy ani kamień. Przez tych, którzy nie odwrócili się od siebie."},
		{"speaker": "Brun", "portrait": "brun", "text": "Więc grom wrócił?"},
		{"speaker": "Lada", "portrait": "lada", "text": "Wrócił. Ale las wciąż ma przed nami wiele dróg."}
	]
}
const MAP_REGION_ORDER := ["debowepogranicze", "swiety_gaj", "bagna_welesa", "gory_peruna", "nawia", "prawia", "grzmotne_szczyty"]
const MAP_REGION_RANGES := {
	"debowepogranicze": Vector2i(1, 20),
	"swiety_gaj": Vector2i(21, 35),
	"bagna_welesa": Vector2i(36, 45),
	"gory_peruna": Vector2i(46, 55),
	"nawia": Vector2i(56, 70),
	"prawia": Vector2i(71, 85),
	"grzmotne_szczyty": Vector2i(86, 100)
}
const MANUAL_BOSS_LEVELS := [3, 5, 7, 10, 12, 15, 17, 19, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 68, 70, 75, 80, 85, 90, 95, 100]
const NORMAL_ENEMY_PORTRAIT_SLUGS := {
	"Cień mchu": "cien_mchu", "Korzeniowy strażnik": "korzeniowy_straznik", "Wilcze szczenię cienia": "wilcze_szczenie_cienia", "Kruczy posłaniec": "kruczy_poslaniec",
	"Mglisty sługa": "mglisty_sluga", "Topielec źródlany": "topielec_zrodlany", "Ropuch kurhanów": "ropuch_kurhanow", "Żmijowe pisklę": "zmijowe_piskle",
	"Popielny chochlik": "popielny_chochlik", "Kamienny gąsienicznik": "kamienny_gasienicznik", "Bursztynowy chrząszcz": "bursztynowy_chrzaszcz", "Widmo żaren": "widmo_zaren",
	"Zimny chochlik": "zimny_chochlik", "Szeptnica bagienna": "szeptnica_bagienna", "Cierniowy wilk": "cierniowy_wilk", "Dąbrowy drwal widmo": "dabrowy_drwal_widmo",
	"Gliniany sługa": "gliniany_sluga", "Kruczy rycerz": "kruczy_rycerz", "Mroczna ćma": "mroczna_cma", "Strażnik totemu": "straznik_totemu",
	"Zarośnięty wędrowiec": "zarosniety_wedrowiec", "Płomienny chochlik": "plomienny_chochlik", "Duch jaru": "duch_jaru", "Kościany kurhanek": "kosciany_kurhanek",
	"Szczenię cienia": "szczenie_cienia", "Korzeń Leszego": "korzen_leszego", "Korzeń gniewu": "korzen_gniewu"
}

var board: Array = []
var special_tiles: Array = []
var obstacles: Array = []
var levels: Array = []
var level_index := 0
var score := 0
var bonus_moves_pending := 0
var unlocked_level := 1
var state := "playing" # playing, won, lost
var touch_start := Vector2i(-1, -1)
var last_screen_touch_msec := -1000
var selected_cell := Vector2i(-1, -1)
var move_preview_target := Vector2i(-1, -1)
var move_preview_cells := {}
var move_preview_text := ""
var message := "Połącz trzy takie same znaki."
var lada_charge := 0
var lada_targeting := false
var brun_charge := 0
var brun_targeting := false
var mieta_charge := 0
var hammer_count := 1
var hammer_targeting := false
var bolt_count := 1
var bolt_targeting := false
var gale_count := 1
var gale_targeting := false
var coins := 0
var wood := 0
var experience := 0
var perun_sparks := 0
var event_marks := 0
var claimed_boss_sparks := {}
var last_reward := {}
var last_stars := 0
var level_stars := {}
var tutorial_completed := false
var party_health := 100
var party_max_health := 100
var party_shield := 0
var enemy_attack_weakened := 0
var hero_health := {"lada": 0, "brun": 0, "mieta": 0}
var hero_max_health := {"lada": 0, "brun": 0, "mieta": 0}
var last_enemy_attack_text := ""
var enemy_name := ""
var enemy_health := 0
var enemy_max_health := 0
var enemy_attack := 0
var enemies: Array = []
var target_enemy_index := 0
var held_tooltip := ""
var held_tooltip_icon: Texture2D
var held_tooltip_hero_id := ""
var animation_busy := false
var player_cascade_active := false
var enemy_turn_active := false
var tile_offsets := {}
var removal_effects := {}
var goal_type := "score"
var goal_target := 0
var goal_progress := 0
var hero_levels := {"lada": 1, "brun": 0, "mieta": 0, "wszebor": 0, "boruta": 0, "dobromir": 0, "milena": 0, "radomir": 0, "witosz": 0, "jagna": 0, "rada": 0, "welesa": 0, "zorya": 0, "jaromir": 0, "msciwoj": 0, "dobrawa": 0, "perunika": 0, "czernik": 0, "mirka": 0, "wlodzimierz": 0, "zywia": 0, "mokosza": 0, "stribog": 0, "swarog": 0, "weles": 0}
var hero_experience := {"lada": 0, "brun": 0, "mieta": 0, "wszebor": 0, "boruta": 0, "dobromir": 0, "milena": 0, "radomir": 0, "witosz": 0, "jagna": 0, "rada": 0, "welesa": 0, "zorya": 0, "jaromir": 0, "msciwoj": 0, "dobrawa": 0, "perunika": 0, "czernik": 0, "mirka": 0, "wlodzimierz": 0, "zywia": 0, "mokosza": 0, "stribog": 0, "swarog": 0, "weles": 0}
var hero_active_charge := {}
var hero_trees := {}
var owned_heroes := {"lada": true, "brun": false, "mieta": false, "wszebor": false, "boruta": false, "dobromir": false, "milena": false, "radomir": false, "witosz": false, "jagna": false, "rada": false, "welesa": false, "zorya": false, "jaromir": false, "msciwoj": false, "dobrawa": false, "perunika": false, "czernik": false, "mirka": false, "wlodzimierz": false, "zywia": false, "mokosza": false, "stribog": false, "swarog": false, "weles": false}
var active_heroes: Array[String] = ["lada"]
var active_turn_index := 0
var roster_open := false
var skill_tree_open := false
var talent_tutorial_node_selected := false
var skill_tree_selected_branch := 0
var skill_tree_selected_tier := 0
var skill_icons := {}
var skill_tree_backgrounds := {}
var skill_tree_connector_arrow: Texture2D
var roster_filter := "all"
var roster_hero_index := 0
var roster_swap_open := false
var roster_swap_hero_id := ""
var roster_swap_return_hero_id := ""
var roster_transition_time := 1.0
var roster_transition_direction := 1.0
var roster_transition_from_id := ""
const ROSTER_TRANSITION_DURATION := 0.34
var building_levels := {"domostwa": 0, "kuznia": 0, "chata_zielarki": 0, "swiety_gaj": 0, "spichlerz": 0, "wieza_peruna": 0, "tartak": 0, "dwor_wiecowy": 0}
var sawmill_production_progress := 0.0
var sawmill_stored_wood := 0
var last_wood_production_unix := 0
var village_open := false
var village_selected_id := ""
var village_upgrade_id := ""
var village_upgrade_from_level := 0
var village_upgrade_time := 0.0
const VILLAGE_UPGRADE_DURATION := 1.0
var map_open := false
var map_page := 0
var map_transition_from_page := 0
var map_transition_time := 0.4
var map_transition_direction := 1.0
var map_transition_from_blur: Texture2D
var map_transition_to_blur: Texture2D
const MAP_TRANSITION_DURATION := 0.4
var map_drag_distance := 0.0
var map_was_dragged := false
var booster_open := false
var main_menu_open := true
var victory_screen_open := false
var victory_open_time := 0.0
var help_open := false
var settings_open := false
var defender_help_open := false
var training_open := false
var training_scroll := 0.0
var training_mode := false
var training_battle: Dictionary = {}
var forest_catalog_open := false
var expedition_bonus_claims := {}
var mastery_claims := {}
var balance_stats := {}
var battle_moves := 0
var battle_started_ms := 0
var bestiary_open := false
var missions_open := false
var mission_day_key := ""
var mission_week_key := ""
var daily_missions: Array = []
var weekly_missions: Array = []
var daily_mission_history: Array = []
var weekly_mission_history: Array = []
var battle_combo_count := 0
var bestiary_region_index := 0
var bestiary_page := 0
var bestiary_region_catalog := {}
var bestiary_regions: Array[String] = []
var bestiary_seen := {}
var bestiary_kills := {}
var claimed_bestiary_regions := {}
var side_objective_level_id := -1
var side_objective_met := false
var claimed_side_objectives := {}
var region_intro_open := false
var seen_region_intros := {}
var seen_region_chapters := {}
var seen_campaign_scenes := {}
var active_region_intro: Array = []
var active_region_intro_key := ""
var active_story_dialogue: Array[Dictionary] = []
var story_dialogue_page := 0
var current_battle: Dictionary = {}
var reset_confirmation := false
var daily_reward_day := ""
var daily_reward_open_time := -1.0
var daily_reward_popup_open := false
var daily_reward_popup_kind := ""
var daily_reward_popup_loot: Dictionary = {}
var pending_daily_chest_bonus := false
var ad_quota_day := ""
var ad_interstitials_today := 0
var campaign_wins_since_interstitial := 0
var daily_ad_bonus_day := ""
var pending_ad_resume_level := -1
var pending_rewarded_bonus := false
var ads_manager: Node
var oak_borderland_background: Texture2D
var story_dialogue_background: Texture2D
var board_roots_frame: Texture2D
var tile_remove_burst: Texture2D
var village_background: Texture2D
var village_layout: Texture2D
var village_mastery_badges: Texture2D
var village_goal_plaque: Texture2D
var village_mastery_plaque: Texture2D
var village_sawmill_stages: Array[Texture2D] = []
var village_inspector_frame: Texture2D
var village_popup_close_button: Texture2D
var village_upgrade_vfx_frames: Texture2D
var village_upgrade_alert_icon: Texture2D
var village_starting_illustrations := {}
var village_upgraded_illustrations := {}
var village_level_illustrations := {}
var leszy_portrait: Texture2D
var wilk_cienia_portrait: Texture2D
var rusalka_portrait: Texture2D
var zmij_portrait: Texture2D
var krolowa_kurhanow_portrait: Texture2D
var pan_zimnych_mgiel_portrait: Texture2D
var wladca_kruczych_znakow_portrait: Texture2D
var niedzwiedz_gromu_portrait: Texture2D
var biala_pani_mlynow_portrait: Texture2D
var swiety_gaj_illustration: Texture2D
var kuznia_illustration: Texture2D
var domostwa_illustration: Texture2D
var chata_zielarki_illustration: Texture2D
var spichlerz_illustration: Texture2D
var wieza_peruna_illustration: Texture2D
var fire_tile_icon: Texture2D
var water_tile_icon: Texture2D
var leaf_tile_icon: Texture2D
var amber_tile_icon: Texture2D
var rune_tile_icon: Texture2D
var special_blast_icons: Array[Texture2D] = []
var special_global_icons: Array[Texture2D] = []
var obstacle_root_icon: Texture2D
var obstacle_stone_icon: Texture2D
var obstacle_curse_icon: Texture2D
var obstacle_root_damaged_icon: Texture2D
var obstacle_stone_damaged_icon: Texture2D
var obstacle_curse_damaged_icon: Texture2D
var obstacle_curse_critical_icon: Texture2D
var heart_icon: Texture2D
var healthbar_frame: Texture2D
var booster_hammer_icon: Texture2D
var booster_bolt_icon: Texture2D
var booster_gale_icon: Texture2D
var healthbar_fill: Texture2D
var game_logo: Texture2D
var hud_oak_ornament: Texture2D
var portrait_backdrop_oak: Texture2D
var pause_button_oak: Texture2D
var turn_banner_oak: Texture2D
var tutorial_tooltip_banner: Texture2D
var tutorial_leaf_highlight: Texture2D
var tutorial_leaf_arrow: Texture2D
var board_cell_stone: Texture2D
var board_hint_frame: Texture2D
var booster_roots_pedestal: Texture2D
var booster_count_medallion: Texture2D
var defeat_modal_oak: Texture2D
var victory_crest: Texture2D
var victory_background: Texture2D
var defeat_background: Texture2D
var button_oak: Texture2D
var roster_action_button: Texture2D
var experience_bar_frame: Texture2D
var roster_hero_card_frame: Texture2D
var roster_active_badge: Texture2D
var roster_active_button: Texture2D
var roster_team_leafy_button: Texture2D
var roster_arrow_left: Texture2D
var roster_arrow_right: Texture2D
var roster_filter_tab: Texture2D
var roster_filter_tab_active: Texture2D
var roster_tabs_oak_beam: Texture2D
var roster_experience_frame: Texture2D
var roster_hero_panel_v02: Texture2D
var roster_section_header: Texture2D
var roster_tabs_bar_v04: Texture2D
var roster_tabs_active_v04: Texture2D
var roster_tabs_inactive_v04: Texture2D
var skill_branch_headers: Array[Texture2D] = []
var skill_description_parchment: Texture2D
var skill_back_arrow: Texture2D
var roster_swap_panel: Texture2D
var roster_swap_card_frame: Texture2D
var roster_swap_card_backdrop: Texture2D
var battle_header_oak: Texture2D
var battle_board_roots: Texture2D
var enemy_role_scout_icon: Texture2D
var enemy_role_mystic_icon: Texture2D
var enemy_role_attacker_icon: Texture2D
var enemy_role_emblems: Texture2D
var star_rating_icon: Texture2D
var coin_resource_icon: Texture2D
var wood_resource_icon: Texture2D
var experience_resource_icon: Texture2D
var perun_sparks_resource_icon: Texture2D
var map_mission_icon_atlas: Texture2D
var map_ui_frames: Texture2D
var map_route_connector: Texture2D
var map_mission_nameplate: Texture2D
var map_level_number_plate: Texture2D
var map_region_backgrounds := {}
var home_navigation_icons: Texture2D
var home_reward_chests: Texture2D
var home_reward_panel: Texture2D
var home_reward_coin_frames: Texture2D
var home_reward_wood_frames: Texture2D
var home_reward_xp_frames: Texture2D
var home_reward_premium_chest: Texture2D
var home_help_icon: Texture2D
var bestiary_icon: Texture2D
var bestiary_background: Texture2D
var home_navigation_frame: Texture2D
var home_missions_icon: Texture2D
var mission_counter_badge: Texture2D
var mission_progress_frame: Texture2D
var mission_progress_amber: Texture2D
var mission_progress_emerald: Texture2D
var mission_counter_plaque: Texture2D
var mission_claim_button: Texture2D
var mission_ui_art_bounds := {}
var mission_progress_track_style: StyleBoxFlat
var mission_progress_fill_style: StyleBoxFlat
var home_status_header: Texture2D
var home_tutorial_glow_style: StyleBoxFlat
var home_party_panel: Texture2D
var home_party_portrait_ring: Texture2D
var home_party_add_plus: Texture2D
var home_face_portraits := {}
var hero_portraits := {}
var hero_accent_textures := {}
var enemy_portraits := {}
var font: Font
var enemy_attack_anim := 0.0
var displayed_enemy_health := {}
var displayed_hero_health := {}
var ui_anim_time := 0.0
var target_transition := 0.0
var previous_target_index := 0
var damage_popup_time := 0.0
var damage_popup_value := 0
var enemy_damage_popup_time := 0.0
var enemy_damage_popup_value := 0
var enemy_damage_popup_index := -1
var enemy_action_cells: Array[Vector2i] = []
var enemy_action_phase := 0
var board_shuffle_time := 0.0
var idle_hint_time := 0.0
var hinted_cells: Array[Vector2i] = []
var drag_current_cell := Vector2i(-1, -1)
var sfx_player: AudioStreamPlayer
var sfx_playback: AudioStreamGeneratorPlayback
var sfx_phase := 0.0
var sfx_frequency := 0.0
var sfx_remaining_frames := 0
var sfx_amplitude := 0.0
var sfx_enabled := true
var music_enabled := true
var vibration_enabled := true
var last_vibration_ms := -1000
var game_audio: Node
const SFX_MIX_RATE := 22050.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	skill_tree_connector_arrow = load_image_texture("res://art/ui/skill_tree_connector_arrow_v01.png")
	# Tła kart są już ładowane przy otwarciu wybranego bohatera.
	# Na starcie nie trzymaj w pamięci wszystkich 25 dużych ilustracji.
	font = preload("res://scripts/game_typography.gd").create_font()
	oak_borderland_background = load_image_texture("res://art/environments/environment_debowe_pogranicze_v01.png")
	story_dialogue_background = load_image_texture("res://art/avatars/avatar_selection_background_v01.png")
	board_roots_frame = null
	tile_remove_burst = load_image_texture("res://art/vfx/tile_remove_burst_v02.png")
	village_background = load_image_texture("res://art/environments/village_debowe_pogranicze_v01.png")
	village_layout = load_image_texture("res://art/environments/village_layout_v06.png")
	village_mastery_badges = load_image_texture("res://art/environments/village_mastery_badges_v01.png")
	village_goal_plaque = load_image_texture("res://art/ui/village_goal_plaque_v01.png")
	village_mastery_plaque = load_image_texture("res://art/ui/village_mastery_plaque_v01.png")
	forest_expeditions_view.load_art(load_image_texture)
	for stage in 3:
		village_sawmill_stages.append(load_image_texture("res://art/environments/building_tartak_dry_stage_%02d.png" % (stage + 1)))
	village_inspector_frame = load_image_texture("res://art/ui/village_inspector_frame_v01.png")
	village_popup_close_button = load_image_texture("res://art/ui/village_popup_close_button_v01.png")
	village_upgrade_vfx_frames = load_image_texture("res://art/vfx/village_upgrade_vfx_frames_v01.png")
	village_upgrade_alert_icon = load_image_texture("res://art/ui/village_upgrade_alert_icon_v01.png")
	for building_id in BUILDING_IDS:
		if building_id == "dwor_wiecowy":
			village_starting_illustrations[building_id] = load_image_texture("res://art/environments/building_dwor_wiecowy_v00.png")
			continue
		var starting_art_path := "res://art/environments/building_%s_v00.png" % building_id
		if building_id == "tartak":
			starting_art_path = "res://art/environments/building_tartak_dry_stage_01.png"
		village_starting_illustrations[building_id] = load_image_texture(starting_art_path)
		village_upgraded_illustrations[building_id] = load_image_texture("res://art/environments/building_%s_v02.png" % building_id)
	leszy_portrait = load_image_texture("res://art/characters/boss_leszy_portrait_v02.png")
	wilk_cienia_portrait = load_image_texture("res://art/characters/boss_wilk_cienia_portrait_v02.png")
	rusalka_portrait = load_image_texture("res://art/characters/boss_rusalka_czarnego_stawu_portrait_v02.png")
	zmij_portrait = load_image_texture("res://art/characters/boss_zmij_popielny_portrait_v02.png")
	krolowa_kurhanow_portrait = load_image_texture("res://art/characters/boss_krolowa_kurhanow_portrait_v02.png")
	pan_zimnych_mgiel_portrait = load_image_texture("res://art/characters/boss_pan_zimnych_mgiel_portrait_v02.png")
	wladca_kruczych_znakow_portrait = load_image_texture("res://art/characters/boss_wladca_kruczych_znakow_portrait_v02.png")
	niedzwiedz_gromu_portrait = load_image_texture("res://art/characters/boss_niedzwiedz_gromu_portrait_v02.png")
	biala_pani_mlynow_portrait = load_image_texture("res://art/characters/boss_biala_pani_mlynow_portrait_v02.png")
	swiety_gaj_illustration = load_image_texture("res://art/environments/building_swiety_gaj_v01.png")
	kuznia_illustration = load_image_texture("res://art/environments/building_kuznia_v01.png")
	domostwa_illustration = load_image_texture("res://art/environments/building_domostwa_v01.png")
	chata_zielarki_illustration = load_image_texture("res://art/environments/building_chata_zielarki_v01.png")
	spichlerz_illustration = load_image_texture("res://art/environments/building_spichlerz_v01.png")
	wieza_peruna_illustration = load_image_texture("res://art/environments/building_wieza_peruna_v01.png")
	fire_tile_icon = load_image_texture("res://art/tiles/tile_fire_v01.png")
	water_tile_icon = load_image_texture("res://art/tiles/tile_water_v01.png")
	leaf_tile_icon = load_image_texture("res://art/tiles/tile_leaf_v01.png")
	amber_tile_icon = load_image_texture("res://art/tiles/tile_amber_v01.png")
	rune_tile_icon = load_image_texture("res://art/tiles/tile_rune_v01.png")
	special_blast_icons = [
		load_image_texture("res://art/tiles/tile_special_blast_fire_v01.png"),
		load_image_texture("res://art/tiles/tile_special_blast_water_v01.png"),
		load_image_texture("res://art/tiles/tile_special_blast_leaf_v01.png"),
		load_image_texture("res://art/tiles/tile_special_blast_amber_v01.png"),
		load_image_texture("res://art/tiles/tile_special_blast_rune_v01.png")
	]
	special_global_icons = [
		load_image_texture("res://art/tiles/tile_special_global_fire_v01.png"),
		load_image_texture("res://art/tiles/tile_special_global_water_v01.png"),
		load_image_texture("res://art/tiles/tile_special_global_leaf_v01.png"),
		load_image_texture("res://art/tiles/tile_special_global_amber_v01.png"),
		load_image_texture("res://art/tiles/tile_special_global_rune_v01.png")
	]
	obstacle_root_icon = load_image_texture("res://art/vfx/obstacle_root_v01.png")
	obstacle_stone_icon = load_image_texture("res://art/vfx/obstacle_stone_v01.png")
	obstacle_curse_icon = load_image_texture("res://art/vfx/obstacle_curse_v01.png")
	obstacle_root_damaged_icon = load_image_texture("res://art/vfx/obstacle_root_damaged_v01.png")
	obstacle_stone_damaged_icon = load_image_texture("res://art/vfx/obstacle_stone_damaged_v01.png")
	obstacle_curse_damaged_icon = load_image_texture("res://art/vfx/obstacle_curse_damaged_v01.png")
	obstacle_curse_critical_icon = load_image_texture("res://art/vfx/obstacle_curse_critical_v01.png")
	heart_icon = load_image_texture("res://art/ui/heart_v01.png")
	healthbar_frame = load_image_texture("res://art/vfx/healthbar_frame_v04.png")
	booster_hammer_icon = load_image_texture("res://art/vfx/booster_hammer_v01.png")
	booster_bolt_icon = load_image_texture("res://art/vfx/booster_bolt_v01.png")
	booster_gale_icon = load_image_texture("res://art/vfx/booster_gale_v01.png")
	healthbar_fill = load_image_texture("res://art/vfx/healthbar_fill_v02.png")
	game_logo = load_image_texture("res://art/logos/logo_serce_debu_v01.png")
	hud_oak_ornament = load_image_texture("res://art/vfx/hud_level_frame_v01.png")
	portrait_backdrop_oak = load_image_texture("res://art/vfx/portrait_backdrop_oak_v01.png")
	pause_button_oak = load_image_texture("res://art/vfx/pause_button_oak_v01.png")
	turn_banner_oak = load_image_texture("res://art/vfx/turn_banner_oak_v01.png")
	tutorial_tooltip_banner = preload("res://art/ui/tutorial_tooltip_banner_v01.png")
	tutorial_leaf_highlight = load_image_texture("res://art/ui/tutorial_leaf_highlight_v01.png")
	tutorial_leaf_arrow = load_image_texture("res://art/ui/tutorial_leaf_arrow_v01.png")
	# Grafiki planszy są wymagane; brak importu nie może ukryć ich za starym tłem.
	board_cell_stone = preload("res://art/ui/board_cell_stone_v02.png")
	board_hint_frame = preload("res://art/ui/board_hint_frame_v01.svg")
	booster_roots_pedestal = load_image_texture("res://art/vfx/booster_roots_pedestal_v01.png")
	booster_count_medallion = load_image_texture("res://art/vfx/booster_count_medallion_v01.png")
	defeat_modal_oak = load_image_texture("res://art/vfx/defeat_modal_oak_v01.png")
	victory_crest = load_image_texture("res://art/ui/victory_crest_v01.png")
	victory_background = load_image_texture("res://art/ui/victory_background_v01.png")
	defeat_background = load_image_texture("res://art/ui/defeat_background_v02.png")
	button_oak = load_image_texture("res://art/vfx/button_oak_v01.png")
	roster_action_button = load_image_texture("res://art/ui/roster_action_button_v01.png")
	experience_bar_frame = load_image_texture("res://art/ui/experience_bar_frame_v01.png")
	roster_hero_card_frame = load_image_texture("res://art/ui/roster_hero_card_frame_v01.png")
	roster_active_badge = load_image_texture("res://art/ui/roster_active_badge_v01.png")
	roster_active_button = load_image_texture("res://art/ui/roster_active_button_v01.png")
	roster_team_leafy_button = load_image_texture("res://art/ui/roster_team_leafy_button_v01.png")
	roster_arrow_left = load_image_texture("res://art/ui/roster_arrow_left_v01.png")
	roster_arrow_right = load_image_texture("res://art/ui/roster_arrow_right_v01.png")
	roster_filter_tab = load_image_texture("res://art/ui/roster_filter_tab_v01.png")
	roster_filter_tab_active = load_image_texture("res://art/ui/roster_filter_tab_active_v01.png")
	roster_tabs_oak_beam = load_image_texture("res://art/ui/roster_tabs_oak_beam_v01.png")
	roster_experience_frame = load_image_texture("res://art/ui/roster_experience_frame_v01.png")
	roster_hero_panel_v02 = load_image_texture("res://art/ui/roster_hero_panel_v02.png")
	roster_section_header = load_image_texture("res://art/ui/roster_section_header_v03.png")
	roster_tabs_bar_v04 = load_image_texture("res://art/ui/roster_tabs_bar_v08.png")
	roster_tabs_active_v04 = load_image_texture("res://art/ui/roster_tabs_active_v04.png")
	roster_tabs_inactive_v04 = load_image_texture("res://art/ui/roster_tabs_inactive_v04.png")
	skill_branch_headers = [
		load_image_texture("res://art/ui/skill_branch_moc_v01.png"),
		load_image_texture("res://art/ui/skill_branch_opieka_v01.png"),
		load_image_texture("res://art/ui/skill_branch_splot_v01.png")
	]
	skill_description_parchment = load_image_texture("res://art/ui/skill_description_parchment_v01.png")
	skill_back_arrow = load_image_texture("res://art/ui/skill_back_arrow_v02.png")
	roster_swap_panel = load_image_texture("res://art/ui/roster_swap_forest_v03.png")
	roster_swap_card_frame = load_image_texture("res://art/ui/roster_swap_card_gold_v04.png")
	roster_swap_card_backdrop = load_image_texture("res://art/ui/roster_swap_card_leaf_v05.png")
	battle_header_oak = load_image_texture("res://art/ui/battle_header_oak_v01.png")
	battle_board_roots = load_image_texture("res://art/ui/battle_board_roots_v02.png")
	enemy_role_scout_icon = load_image_texture("res://art/ui/enemy_role_scout_v01.png")
	enemy_role_mystic_icon = load_image_texture("res://art/ui/enemy_role_mystic_v01.png")
	enemy_role_attacker_icon = load_image_texture("res://art/ui/enemy_role_attacker_v01.png")
	enemy_role_emblems = load_image_texture("res://art/ui/enemy_role_emblems_v01.png")
	star_rating_icon = load_image_texture("res://art/ui/icon_star_leaf_v01.png")
	coin_resource_icon = load_image_texture("res://art/ui/icon_coin_oak_v01.png")
	wood_resource_icon = load_image_texture("res://art/ui/icon_wood_oak_v01.png")
	experience_resource_icon = load_image_texture("res://art/ui/icon_xp_oak_v01.png")
	perun_sparks_resource_icon = load_image_texture("res://art/ui/icon_perun_sparks_v01.png")
	map_mission_icon_atlas = load_image_texture("res://art/ui/world_map_mission_icons_v01.png")
	map_ui_frames = load_image_texture("res://art/ui/world_map_frames_v01.png")
	map_route_connector = load_image_texture("res://art/ui/world_map_route_connector_v01.png")
	map_mission_nameplate = load_image_texture("res://art/ui/world_map_mission_nameplate_v01.png")
	map_level_number_plate = load_image_texture("res://art/ui/world_map_level_number_v01.png")
	map_region_backgrounds = {
		"debowepogranicze": load_image_texture("res://art/environments/world_map_debowepogranicze_v02.png"),
		"swiety_gaj": load_image_texture("res://art/environments/world_map_swiety_gaj_v02.png"),
		"bagna_welesa": load_image_texture("res://art/environments/world_map_bagna_welesa_v02.png"),
		"gory_peruna": load_image_texture("res://art/environments/world_map_gory_peruna_v02.png"),
		"nawia": load_image_texture("res://art/environments/world_map_nawia_v02.png"),
		"prawia": load_image_texture("res://art/environments/world_map_prawia_v02.png"),
		"grzmotne_szczyty": load_image_texture("res://art/environments/world_map_grzmotne_szczyty_v02.png"),
		"jeziora_rusalek": load_image_texture("res://art/environments/world_map_bagna_welesa_v02.png"),
		"ziemie_marzanny": load_image_texture("res://art/environments/world_map_grzmotne_szczyty_v02.png"),
		"kraina_zmijow": load_image_texture("res://art/environments/world_map_gory_peruna_v02.png"),
		"korona_drzewa": load_image_texture("res://art/environments/world_map_swiety_gaj_v02.png")
	}
	home_navigation_icons = load_image_texture("res://art/ui/home_navigation_icons_v01.png")
	home_reward_chests = load_image_texture("res://art/ui/home_reward_chests_v01.png")
	home_reward_panel = load_image_texture("res://art/ui/home_reward_panel_v02.png")
	home_reward_coin_frames = load_image_texture("res://art/ui/home_reward_coin_chest_frames_v03.png")
	home_reward_wood_frames = load_image_texture("res://art/ui/home_reward_wood_chest_frames_v04.png")
	home_reward_xp_frames = load_image_texture("res://art/ui/home_reward_xp_chest_frames_v03.png")
	home_reward_premium_chest = load_image_texture("res://art/ui/home_reward_premium_chest_v01.png")
	home_help_icon = load_image_texture("res://art/ui/home_help_icon_v01.png")
	bestiary_icon = load_image_texture("res://art/ui/bestiary_icon_v01.png")
	bestiary_background = load_image_texture("res://art/environments/bestiary_background_v01.png")
	home_navigation_frame = load_image_texture("res://art/ui/home_navigation_backdrop_v01.png")
	home_missions_icon = preload("res://art/ui/mission_nav_icon_v02.png")
	mission_counter_badge = load_image_texture("res://art/ui/mission_counter_badge_v01.png")
	if mission_counter_badge != null:
		mission_ui_art_bounds[mission_counter_badge.get_instance_id()] = Rect2(46, 20, 1150, 1208)
	mission_progress_frame = load_image_texture("res://art/ui/mission_progress_frame_v02.png")
	mission_progress_amber = load_image_texture("res://art/ui/mission_progress_amber_fill_v01.png")
	mission_progress_emerald = load_image_texture("res://art/ui/mission_progress_emerald_fill_v01.png")
	mission_counter_plaque = load_image_texture("res://art/ui/mission_counter_plaque_v01.png")
	mission_claim_button = load_image_texture("res://art/ui/mission_claim_button_v01.png")
	# Pomijamy niemal niewidoczne piksele poza właściwą ilustracją.
	if mission_progress_frame != null:
		mission_ui_art_bounds[mission_progress_frame.get_instance_id()] = Rect2(12, 260, 2149, 212)
	if mission_counter_plaque != null:
		mission_ui_art_bounds[mission_counter_plaque.get_instance_id()] = Rect2(15, 91, 2142, 534)
	if mission_claim_button != null:
		mission_ui_art_bounds[mission_claim_button.get_instance_id()] = Rect2(0, 0, 2172, 685)
	home_status_header = load_image_texture("res://art/ui/home_status_header_v02.png")
	home_party_panel = load_image_texture("res://art/ui/home_party_panel_v01.png")
	home_party_portrait_ring = load_image_texture("res://art/ui/home_party_portrait_ring_v01.png")
	home_party_add_plus = load_image_texture("res://art/ui/home_party_add_plus_v01.png")
	for enemy_name_key in NORMAL_ENEMY_PORTRAIT_SLUGS:
		var enemy_slug: String = NORMAL_ENEMY_PORTRAIT_SLUGS[enemy_name_key]
		enemy_portraits[enemy_name_key] = load_image_texture("res://art/characters/normal_enemies/enemy_%s_portrait_v03.png" % enemy_slug)
	enemy_portraits["Król Topielców"] = load_image_texture("res://art/characters/boss_krol_topielcow_portrait_v02.png")
	enemy_portraits["Matka Ciernistych Pól"] = load_image_texture("res://art/characters/boss_matka_ciernistych_pol_portrait_v02.png")
	enemy_portraits["Strażnik Bursztynowej Jaskini"] = load_image_texture("res://art/characters/boss_straznik_bursztynowej_jaskini_portrait_v02.png")
	enemy_portraits["Baba Jaga z Żelaznego Boru"] = load_image_texture("res://art/characters/boss_baba_jaga_zelazny_bor_portrait_v02.png")
	enemy_portraits["Wąż Wiślany"] = load_image_texture("res://art/characters/boss_waz_wislany_portrait_v02.png")
	enemy_portraits["Czarny Bóg Przesmyku"] = load_image_texture("res://art/characters/boss_czarny_bog_przesmyku_portrait_v02.png")
	# Nazwy kampanii bez osobnego pliku wykorzystują właściwy portret bossa.
	enemy_portraits["Stary Leszy"] = load_image_texture("res://art/characters/normal_enemies/enemy_stary_leszy_portrait_v03.png")
	enemy_portraits["Wilk cienia"] = load_image_texture("res://art/characters/normal_enemies/enemy_wilk_cienia_portrait_v03.png")
	enemy_portraits["Duch dębu"] = load_image_texture("res://art/characters/normal_enemies/enemy_duch_debu_portrait_v03.png")
	for hero_id in HERO_IDS:
		var portrait := load_image_texture("res://art/characters/hero_%s_portrait_v06.png" % hero_id)
		if portrait != null:
			hero_portraits[hero_id] = portrait
		else:
			# Nowi bohaterowie zachowują pełną czytelność kart przed dostarczeniem
			# ich indywidualnych portretów — nigdy nie rysujemy pustej sylwetki.
			hero_portraits[hero_id] = hero_portraits.get("lada", null)
	for hero_id in HERO_IDS:
		hero_accent_textures[hero_id] = load_image_texture("res://art/vfx/hero_accent_%s.png" % hero_id)
	# Te dwa kadry z planszy ImageGen miały sąsiedni pierścień w kadrze;
	# używamy czystego akcentu żywiołu zamiast pokazywać nakładające się koła.
	hero_accent_textures["rada"] = null
	hero_accent_textures["welesa"] = null
	setup_procedural_sfx()
	game_audio = GameAudio.new()
	add_child(game_audio)
	game_audio.setup()
	levels = load_levels()
	build_bestiary_catalog()
	load_progress()
	update_sawmill_production(0.0)
	refresh_ad_day()
	setup_ads_manager()
	start_level(0)
	main_menu_open = not talent_tutorial_active()
	if village_tutorial_active():
		main_menu_open = false
		village_open = true
		village_selected_id = "tartak"
	if talent_tutorial_active():
		roster_open = true
		roster_filter = "all"
		roster_hero_index = maxi(0, HERO_IDS.find("lada"))
		skill_tree_open = true
		skill_tree_selected_branch = 0
		skill_tree_selected_tier = 0
	queue_redraw()

func setup_ads_manager() -> void:
	ads_manager = get_node_or_null("GameAds")
	if ads_manager == null:
		return
	ads_manager.interstitial_closed.connect(_on_interstitial_closed)
	ads_manager.rewarded_ad_completed.connect(_on_rewarded_ad_completed)
	ads_manager.rewarded_ad_closed.connect(_on_rewarded_ad_closed)
	ads_manager.ad_availability_changed.connect(queue_redraw)
	ads_manager.initialize(get_node_or_null("Admob"))

func refresh_ad_day() -> void:
	var today := Time.get_date_string_from_system()
	if ad_quota_day != today:
		ad_quota_day = today
		ad_interstitials_today = 0

func ad_bonus_available_today() -> bool:
	return daily_ad_bonus_day != Time.get_date_string_from_system()

func campaign_ads_unlocked() -> bool:
	return not training_mode and int(levels[level_index].get("id", level_index + 1)) > 5

func _on_interstitial_closed() -> void:
	if pending_ad_resume_level < 0:
		return
	var next_level := pending_ad_resume_level
	pending_ad_resume_level = -1
	if state == "won" and next_level < levels.size():
		start_level(next_level)

func _on_rewarded_ad_completed() -> void:
	if pending_daily_chest_bonus:
		pending_daily_chest_bonus = false
		if not ad_bonus_available_today():
			queue_redraw()
			return
		var bonus := daily_premium_reward()
		coins += int(bonus.get("coins", 0))
		wood += int(bonus.get("wood", 0))
		experience += int(bonus.get("experience", 0))
		daily_ad_bonus_day = Time.get_date_string_from_system()
		daily_reward_open_time = 0.0
		daily_reward_popup_open = true
		daily_reward_popup_kind = "premium_loot"
		daily_reward_popup_loot = bonus
		message = "Skrzynia premium: +%d monet, +%d drewna, +%d PD." % [int(bonus["coins"]), int(bonus["wood"]), int(bonus["experience"])]
		save_progress()
		play_audio_event("chest_open", 820.0, 0.18, 0.20)
		queue_audio_event("reward_reveal_rare", 1.3)
		queue_audio_event("resource_coin", 2.3)
		queue_redraw()
		return
	if not pending_rewarded_bonus or state != "won" or not campaign_ads_unlocked() or not ad_bonus_available_today():
		return
	pending_rewarded_bonus = false
	var base_coins := int(last_reward.get("coins", 0))
	if base_coins <= 0:
		return
	var bonus := maxi(1, int(round(float(base_coins) * 0.5)))
	coins += bonus
	last_reward["coins"] = base_coins + bonus
	daily_ad_bonus_day = Time.get_date_string_from_system()
	message = "Dar Gaju podwaja połowę monet: +%d." % bonus
	save_progress()
	play_audio_event("resource_coin", 760.0, 0.16, 0.18)
	queue_redraw()

func _on_rewarded_ad_closed() -> void:
	pending_daily_chest_bonus = false
	pending_rewarded_bonus = false
	queue_redraw()

func daily_premium_reward() -> Dictionary:
	return {
		"coins": 300 + mini(1200, unlocked_level * 18),
		"wood": 0,
		"experience": 120 + mini(480, unlocked_level * 7)
	}

func show_rewarded_coin_bonus() -> void:
	if ads_manager == null or not campaign_ads_unlocked() or not ad_bonus_available_today() or not ads_manager.rewarded_ready:
		return
	pending_rewarded_bonus = true
	if not ads_manager.show_rewarded():
		pending_rewarded_bonus = false

func _process(delta: float) -> void:
	update_game_audio()
	if not get_tree().paused and DisplayServer.window_is_focused():
		balance_stats["active_seconds"] = float(balance_stats.get("active_seconds", 0.0)) + delta
	ui_anim_time += delta
	update_sawmill_production(delta)
	if daily_reward_open_time >= 0.0:
		daily_reward_open_time += delta
		if daily_reward_open_time > 1.05:
			daily_reward_open_time = -1.0
		queue_redraw()
	if roster_transition_time < ROSTER_TRANSITION_DURATION:
		roster_transition_time = minf(ROSTER_TRANSITION_DURATION, roster_transition_time + delta)
		queue_redraw()
	if map_transition_time < MAP_TRANSITION_DURATION:
		map_transition_time = minf(MAP_TRANSITION_DURATION, map_transition_time + delta)
		if map_transition_time >= MAP_TRANSITION_DURATION:
			map_transition_from_blur = null
			map_transition_to_blur = null
		queue_redraw()
	if village_upgrade_time > 0.0:
		village_upgrade_time = maxf(0.0, village_upgrade_time - delta)
		if village_upgrade_time == 0.0:
			village_upgrade_id = ""
		queue_redraw()
	fill_sfx_buffer()
	if target_transition > 0.0:
		target_transition = maxf(0.0, target_transition - delta * 4.0)
	if damage_popup_time > 0.0:
		damage_popup_time = maxf(0.0, damage_popup_time - delta)
	if enemy_damage_popup_time > 0.0:
		enemy_damage_popup_time = maxf(0.0, enemy_damage_popup_time - delta)
	if enemy_attack_anim > 0.0:
		enemy_attack_anim = maxf(0.0, enemy_attack_anim - delta)
		queue_redraw()
	if board_shuffle_time > 0.0:
		board_shuffle_time = maxf(0.0, board_shuffle_time - delta)
		queue_redraw()
	for enemy in enemies:
		var key := str(enemy.get("name", ""))
		var actual := float(enemy.get("health", 0))
		var shown := float(displayed_enemy_health.get(key, actual))
		displayed_enemy_health[key] = move_toward(shown, actual, delta * 180.0)
	for hero_id in active_heroes:
		var actual_hero := float(hero_health.get(hero_id, 0))
		var shown_hero := float(displayed_hero_health.get(hero_id, actual_hero))
		displayed_hero_health[hero_id] = move_toward(shown_hero, actual_hero, delta * 90.0)
	if not animation_busy and not tile_offsets.is_empty():
		for tile_cell in tile_offsets.keys():
			var tile_offset: Vector2 = tile_offsets[tile_cell]
			tile_offsets[tile_cell] = tile_offset.move_toward(Vector2.ZERO, delta * 5.5)
			if tile_offsets[tile_cell].length() < 0.02:
				tile_offsets.erase(tile_cell)
		queue_redraw()
	for cell in removal_effects.keys():
		removal_effects[cell] = float(removal_effects[cell]) + delta
		if removal_effects[cell] > 0.34:
			removal_effects.erase(cell)
	queue_redraw()

func update_sawmill_production(delta: float) -> void:
	var now := int(Time.get_unix_time_from_system())
	if last_wood_production_unix <= 0:
		last_wood_production_unix = now
		return
	var elapsed := maxf(0.0, delta)
	if delta <= 0.0:
		elapsed = clampf(float(now - last_wood_production_unix), 0.0, SAWMILL_OFFLINE_CAP_SECONDS)
		last_wood_production_unix = now
	var sawmill_level := int(building_levels.get("tartak", 0))
	if sawmill_level <= 0 or elapsed <= 0.0:
		return
	sawmill_production_progress += elapsed * float(sawmill_level) * SAWMILL_WOOD_PER_HOUR_PER_LEVEL / 3600.0
	var produced := int(floor(sawmill_production_progress))
	if produced > 0:
		sawmill_stored_wood = mini(999999999, sawmill_stored_wood + produced)
		sawmill_production_progress -= float(produced)
		last_wood_production_unix = now
		save_progress()

func collect_sawmill_wood() -> void:
	if int(building_levels.get("tartak", 0)) <= 0:
		return
	var collected := mini(sawmill_stored_wood, maxi(0, 999999999 - wood))
	if collected <= 0:
		return
	wood += collected
	balance_stats["wood_sawmill"] = int(balance_stats.get("wood_sawmill", 0)) + collected
	sawmill_stored_wood -= collected
	message = "Odebrano %d drewna z tartaku." % collected
	play_audio_event("resource_wood", 430.0, 0.12, 0.12)
	save_progress()
	queue_redraw()

func village_tutorial_active() -> bool:
	return player_opening.home_tutorial_step in ["buy_sawmill", "sawmill_built"]

func setup_procedural_sfx() -> void:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SFX_MIX_RATE
	stream.buffer_length = 0.18
	sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.volume_db = -15.0
	add_child(sfx_player)
	sfx_player.play()
	sfx_playback = sfx_player.get_stream_playback()

func update_game_audio() -> void:
	if sfx_player != null:
		if not sfx_enabled:
			sfx_remaining_frames = 0
			sfx_player.stop()
		elif not sfx_player.playing:
			sfx_player.play()
			sfx_playback = sfx_player.get_stream_playback()
	if game_audio == null:
		return
	var in_battle: bool = state == "playing" and not (main_menu_open or roster_open or village_open or map_open or booster_open or training_open or help_open or region_intro_open or victory_screen_open or grove_shop.opened or player_opening.stage != "")
	game_audio.update_context(in_battle, sfx_enabled, music_enabled)

func load_audio_settings(data: ConfigFile) -> void:
	sfx_enabled = bool(data.get_value("settings", "sfx_enabled", true))
	# Stary przełącznik wyciszał całość: zachowaj to dla starych zapisów.
	music_enabled = bool(data.get_value("settings", "music_enabled", sfx_enabled))
	vibration_enabled = bool(data.get_value("settings", "vibration_enabled", true))

func save_audio_settings(data: ConfigFile) -> void:
	data.set_value("settings", "sfx_enabled", sfx_enabled)
	data.set_value("settings", "music_enabled", music_enabled)
	data.set_value("settings", "vibration_enabled", vibration_enabled)

func vibrate_invalid_move() -> void:
	var now := Time.get_ticks_msec()
	if not vibration_enabled or now - last_vibration_ms < 250:
		return
	last_vibration_ms = now
	send_handheld_vibration(55)

func send_handheld_vibration(duration_ms: int) -> void:
	if OS.get_name() in ["Android", "iOS"]:
		Input.vibrate_handheld(duration_ms)

func play_sfx(frequency: float, duration: float, amplitude: float = 0.18) -> void:
	play_audio_event("ui_confirm", frequency, duration, amplitude)

func play_audio_event(event_name: String, frequency := 660.0, duration := 0.12, amplitude := 0.18) -> void:
	if not sfx_enabled:
		return
	if game_audio != null and game_audio.play_effect(event_name):
		return
	play_procedural_sfx(frequency, duration, amplitude)

func play_procedural_sfx(frequency: float, duration: float, amplitude: float = 0.18) -> void:
	if not sfx_enabled or sfx_playback == null:
		return
	sfx_frequency = frequency
	sfx_phase = 0.0
	sfx_remaining_frames = maxi(1, int(duration * SFX_MIX_RATE))
	sfx_amplitude = clampf(amplitude, 0.0, 0.45)

func queue_audio_event(event_name: String, delay: float) -> void:
	if not sfx_enabled:
		return
	if game_audio != null and game_audio.can_play_effect(event_name):
		game_audio.queue_effect(event_name, delay)
	else:
		play_audio_event(event_name)

func play_hero_attack_audio() -> void:
	play_audio_event(game_audio.hero_attack_event(current_turn_hero()) if game_audio != null else "hero_attack", 470.0, 0.13, 0.12)

func hero_skill_audio_event(hero_id: String) -> String:
	if hero_id in ["stribog", "witosz"]:
		return "skill_activate_wind"
	if hero_id in ["lada", "perunika", "zywia"]:
		return "skill_activate_thunder"
	return "skill_activate_" + str(["fire", "water", "roots", "amber", "runes"][SkillTree.element(hero_id)])

func fill_sfx_buffer() -> void:
	if sfx_playback == null:
		return
	var frames := sfx_playback.get_frames_available()
	for ignored in frames:
		var sample := 0.0
		if sfx_remaining_frames > 0:
			var envelope := float(sfx_remaining_frames) / maxf(1.0, SFX_MIX_RATE * 0.32)
			sample = sin(sfx_phase * TAU) * sfx_amplitude * minf(1.0, envelope * 3.0)
			sfx_phase = fmod(sfx_phase + sfx_frequency / SFX_MIX_RATE, 1.0)
			sfx_remaining_frames -= 1
		sfx_playback.push_frame(Vector2(sample, sample))

func start_level(index: int, level_override: Dictionary = {}) -> void:
	if game_audio != null:
		game_audio.pending_effects.clear()
	refresh_missions()
	defender_help_open = false
	level_index = clampi(index, 0, levels.size() - 1)
	training_mode = not level_override.is_empty()
	side_objective_level_id = -1 if training_mode else int(levels[level_index].get("id", level_index + 1))
	side_objective_met = false
	if not training_mode:
		training_battle.clear()
	var level: Dictionary = level_override if not level_override.is_empty() else levels[level_index]
	current_battle = level.duplicate(true)
	battle_moves = 0
	battle_started_ms = Time.get_ticks_msec()
	var attempt_key := "expedition_attempts" if bool(level.get("expedition", false)) else ("training_attempts" if training_mode else "campaign_attempts")
	balance_stats[attempt_key] = int(balance_stats.get(attempt_key, 0)) + 1
	score = 0
	battle_combo_count = 0
	bonus_moves_pending = 0
	state = "playing"
	lada_charge = 0
	lada_targeting = false
	brun_charge = 0
	brun_targeting = false
	mieta_charge = 0
	for hero_id in HERO_IDS:
		hero_active_charge[hero_id] = 0
	hammer_count = 1
	hammer_targeting = false
	bolt_count = 1
	bolt_targeting = false
	gale_count = 1
	gale_targeting = false
	selected_cell = Vector2i(-1, -1)
	clear_move_preview()
	last_reward = {}
	last_stars = 0
	active_turn_index = 0
	party_max_health = 0
	party_health = 0
	for hero_id in active_heroes:
		var max_health := hero_health_limit(hero_id)
		hero_max_health[hero_id] = max_health
		hero_health[hero_id] = max_health
		displayed_hero_health[hero_id] = max_health
		party_max_health += max_health
		party_health += max_health
	party_shield = 0
	enemy_attack_weakened = 0
	last_enemy_attack_text = ""
	setup_enemies(level)
	displayed_enemy_health.clear()
	target_enemy_index = 0
	goal_type = str(level.get("goal_type", "score"))
	goal_target = int(level.get("goal_value", level.get("target", 0)))
	goal_progress = 0
	player_opening.tutorial_moves = 0
	message = "Trening: pokonaj przeciwnika i zdobądź PD dla aktywnego składu." if training_mode else "Połącz trzy takie same znaki."
	if bool(current_battle.get("expedition", false)):
		message = str(current_battle.get("mechanic", "Wyprawa po drewno"))
	if not training_mode and level_index == 0 and not tutorial_completed:
		fill_level_one_tutorial_board()
		player_opening.tutorial_popup_open = true
	elif not training_mode and level_index == 1:
		fill_level_two_tutorial_board()
		player_opening.tutorial_popup_open = true
	else:
		fill_fresh_board()
	setup_obstacles(level)
	var intro_level_id := int(level.get("id", 0))
	if not training_mode and intro_level_id == 6:
		message = "Nowe przeszkody: korzenie zarastają pola, kamienie chronią wrogów, a klątwy wzmacniają ich atak."
	active_region_intro = []
	active_region_intro_key = ""
	active_story_dialogue.clear()
	story_dialogue_page = 0
	region_intro_open = false
	if not training_mode and CAMPAIGN_STORY.has(intro_level_id) and not bool(seen_campaign_scenes.get(intro_level_id, false)):
		for story_line_value in CAMPAIGN_STORY[intro_level_id]:
			var story_line: Dictionary = story_line_value
			var required_hero := str(story_line.get("requires", ""))
			if required_hero != "" and not bool(owned_heroes.get(required_hero, false)):
				continue
			active_story_dialogue.append(story_line.duplicate(true))
		active_region_intro_key = "story_%d" % intro_level_id
		region_intro_open = true
	elif not training_mode and REGION_INTROS.has(intro_level_id) and not bool(seen_region_intros.get(intro_level_id, false)):
		active_region_intro = REGION_INTROS[intro_level_id]
		active_region_intro_key = "level_%d" % intro_level_id
		region_intro_open = true
	elif not training_mode and intro_level_id >= 101:
		var chapter_key := str(level.get("region", ""))
		if REGION_CHAPTERS.has(chapter_key) and not bool(seen_region_chapters.get(chapter_key, false)):
			active_region_intro = REGION_CHAPTERS[chapter_key]
			active_region_intro_key = "chapter_%s" % chapter_key
			region_intro_open = true
	queue_redraw()

func load_image_texture(file_path: String) -> Texture2D:
	# Opcjonalne portrety i efekty mogą pojawiać się etapami rozwoju gry.
	# Nie próbujemy dekodować nieistniejącego pliku — pozostaje wtedy bezpieczne
	# zastępcze rysowanie, bez błędów podczas uruchamiania.
	if not ResourceLoader.exists(file_path):
		return null
	return ResourceLoader.load(file_path) as Texture2D

func fill_fresh_board() -> void:
	for attempt in range(64):
		generate_clean_board()
		# Plansza startowa musi być stabilna: bez gotowej linii 3+ i bez kwadratu 2×2.
		if find_matches().is_empty() and board_has_legal_move():
			return
	# Awaryjny, zawsze grywalny wzór — zapobiega nieskończonemu losowaniu.
	generate_clean_board()
	board[0][0] = 0
	board[0][1] = 1
	board[0][2] = 0
	board[1][1] = 0

func fill_level_one_tutorial_board() -> void:
	# Gwarantuje pierwszy ruch z liśćmi: przeciągnij liść w górę,
	# aby ułożyć pionową trójkę.
	for attempt in range(128):
		generate_clean_board()
		board[1][3] = 2
		board[2][3] = 2
		board[3][3] = 1
		board[4][3] = 2
		if not find_matches().is_empty():
			continue
		swap_tiles(FIRST_TUTORIAL_MOVE_FROM, FIRST_TUTORIAL_MOVE_TO)
		var tutorial_matches := find_matches()
		swap_tiles(FIRST_TUTORIAL_MOVE_FROM, FIRST_TUTORIAL_MOVE_TO)
		var is_leaf_triple := tutorial_matches.size() == 3
		for matched_cell in tutorial_matches:
			var cell: Vector2i = matched_cell
			is_leaf_triple = is_leaf_triple and int(board[cell.y][cell.x]) == 2
		if is_leaf_triple:
			return
	# Deterministyczne zabezpieczenie: wzór szachownicy nie ma gotowych
	# połączeń, a wymiana nadal tworzy dokładnie tę samą trójkę liści.
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			board[row][col] = posmod(row + col, TILE_TYPES)
			special_tiles[row][col] = 0
	board[1][3] = 2
	board[2][3] = 2
	board[3][3] = 1
	board[4][3] = 2

func fill_level_two_tutorial_board() -> void:
	# Zapewnij w drugiej rundzie czytelny ruch 4× liście: zamiana kafelka
	# w siódmym rzędzie z polem bezpośrednio nad nim tworzy poziomą czwórkę.
	for attempt in range(128):
		generate_clean_board()
		board[6][0] = 2
		board[6][1] = 2
		board[6][2] = 4
		board[6][3] = 2
		board[6][4] = 1
		board[6][5] = 3
		board[5][2] = 2
		board[4][2] = 1
		if not find_matches().is_empty():
			continue
		swap_tiles(LEVEL_TWO_TUTORIAL_FROM, LEVEL_TWO_TUTORIAL_TO)
		var tutorial_matches := find_matches()
		swap_tiles(LEVEL_TWO_TUTORIAL_FROM, LEVEL_TWO_TUTORIAL_TO)
		if tutorial_matches.size() == 4:
			return
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			board[row][col] = posmod(row + col, TILE_TYPES)
			special_tiles[row][col] = 0
	board[6][0] = 2
	board[6][1] = 2
	board[6][2] = 4
	board[6][3] = 2
	board[6][4] = 1
	board[6][5] = 3
	board[5][2] = 2
	board[4][2] = 1

func reshuffle_board() -> void:
	var values: Array[Dictionary] = []
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			values.append({"type": int(board[row][col]), "special": int(special_tiles[row][col])})
	for attempt in range(64):
		values.shuffle()
		var value_index := 0
		for row in BOARD_SIZE:
			for col in BOARD_SIZE:
				board[row][col] = int(values[value_index]["type"])
				special_tiles[row][col] = int(values[value_index]["special"])
				value_index += 1
		if find_matches().is_empty() and board_has_legal_move():
			for row in BOARD_SIZE:
				for col in BOARD_SIZE:
					tile_offsets[Vector2i(col, row)] = Vector2(randi_range(-2, 2), randi_range(-2, 2))
			board_shuffle_time = 1.1
			message = "Przetasowanie gaju — szukamy nowej ścieżki!"
			return
	# Bardzo rzadkie zabezpieczenie, gdy zachowany zestaw znaków nie daje grywalnego układu.
	fill_fresh_board()
	board_shuffle_time = 1.1
	message = "Przetasowanie gaju — plansza odzyskuje równowagę!"

func generate_clean_board() -> void:
	board.clear()
	special_tiles.clear()
	for row in BOARD_SIZE:
		board.append([])
		special_tiles.append([])
		for col in BOARD_SIZE:
			var choices: Array[int] = []
			for tile in TILE_TYPES:
				choices.append(tile)
			# Nie pozwalaj, by plansza startowała z gotowymi trójkami.
			if col >= 2 and board[row][col - 1] == board[row][col - 2]:
				choices.erase(board[row][col - 1])
			if row >= 2 and board[row - 1][col] == board[row - 2][col]:
				choices.erase(board[row - 1][col])
			# Ostatni kafelek potencjalnego kwadratu 2×2 nie może domknąć gotowego komba.
			if col >= 1 and row >= 1:
				var square_type: int = int(board[row][col - 1])
				if board[row - 1][col] == square_type and board[row - 1][col - 1] == square_type:
					choices.erase(square_type)
			board[row].append(choices.pick_random())
			special_tiles[row].append(0)

func obstacle_limit(level: Dictionary) -> int:
	var level_id := int(level.get("id", level_index + 1))
	var late_campaign_obstacles := int(maxi(0, level_id - 1000) / 100)
	var budget := mini(48, mini(36, 8 + int(level_id / 12)) + late_campaign_obstacles)
	if str(level.get("goal_type", "")) == "clear_obstacles":
		budget = maxi(budget, mini(48, int(level.get("goal_value", 0))))
	return budget

func setup_obstacles(level: Dictionary) -> void:
	obstacles.clear()
	for row in BOARD_SIZE:
		obstacles.append([])
		for col in BOARD_SIZE:
			obstacles[row].append(0)
	var obstacle_config: Dictionary = level.get("obstacles", {})
	var types := {"root": 1, "stone": 2, "curse": 3}
	# Trudniejsze etapy stopniowo wypełniają planszę przeszkodami, ale zostawiają
	# co najmniej 16 pól na kombinacje nawet w końcówce kampanii.
	var obstacle_budget := obstacle_limit(level)
	var planned: Array[int] = []
	for obstacle_id in types:
		for ignored in int(obstacle_config.get(obstacle_id, 0)):
			planned.append(int(types[obstacle_id]))
	planned.shuffle()
	for obstacle_type in planned:
		if obstacle_budget <= 0:
			return
		var available: Array = []
		for row in BOARD_SIZE:
			for col in BOARD_SIZE:
				if obstacles[row][col] == 0:
					available.append(Vector2i(col, row))
		if available.is_empty():
			return
		var cell: Vector2i = available.pick_random()
		obstacles[cell.y][cell.x] = obstacle_type
		obstacle_budget -= 1

func obstacle_count(kind: int) -> int:
	var total := 0
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if int(obstacles[row][col]) == kind:
				total += 1
	return total

func apply_obstacle_powers() -> String:
	var roots: Array[Vector2i] = []
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if int(obstacles[row][col]) == 1:
				roots.append(Vector2i(col, row))
	if roots.is_empty():
		return ""
	var candidates: Array[Vector2i] = []
	for root in roots:
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var target: Vector2i = root + offset
			if target.x < 0 or target.y < 0 or target.x >= BOARD_SIZE or target.y >= BOARD_SIZE:
				continue
			if int(obstacles[target.y][target.x]) == 0 and int(board[target.y][target.x]) >= 0 and not candidates.has(target):
				candidates.append(target)
	if candidates.is_empty():
		return ""
	var grown: Vector2i = candidates.pick_random()
	obstacles[grown.y][grown.x] = 1
	return "Korzenie zarosły sąsiednie pole."

func board_has_legal_move() -> bool:
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var cell := Vector2i(col, row)
			for offset in [Vector2i(1, 0), Vector2i(0, 1)]:
				var neighbor: Vector2i = cell + offset
				if neighbor.x >= BOARD_SIZE or neighbor.y >= BOARD_SIZE:
					continue
				swap_tiles(cell, neighbor)
				var creates_match := not find_matches().is_empty()
				swap_tiles(cell, neighbor)
				if creates_match:
					return true
	return false

func find_hint_move() -> Array[Vector2i]:
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var cell := Vector2i(col, row)
			for offset in [Vector2i.RIGHT, Vector2i.DOWN]:
				var neighbor: Vector2i = cell + offset
				if neighbor.x >= BOARD_SIZE or neighbor.y >= BOARD_SIZE:
					continue
				swap_tiles(cell, neighbor)
				var creates_match := not find_matches().is_empty()
				swap_tiles(cell, neighbor)
				if creates_match:
					return [cell, neighbor]
	return []

func _unhandled_input(event: InputEvent) -> void:
	if player_opening.stage != "" and event is InputEventKey:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if region_intro_open and not active_story_dialogue.is_empty():
			if event.keycode == KEY_ESCAPE:
				advance_story_dialogue(true)
			elif event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				advance_story_dialogue(false)
			return
		if daily_reward_popup_open and event.keycode == KEY_ESCAPE:
			daily_reward_popup_open = false
			daily_reward_popup_kind = ""
			daily_reward_popup_loot.clear()
			queue_redraw()
			return
		if grove_shop.opened:
			if event.keycode == KEY_ESCAPE:
				if grove_shop.pending_index >= 0:
					grove_shop.pending_index = -1
					queue_redraw()
				else:
					grove_shop.close(self)
			return
		if village_open and event.keycode == KEY_ESCAPE:
			if village_selected_id != "":
				village_selected_id = ""
			else:
				village_open = false
				main_menu_open = true
			queue_redraw()
			return
		if training_open and event.keycode == KEY_ESCAPE:
			handle_training_input(training_close_rect().get_center())
			return
		if roster_open and not skill_tree_open:
			var filtered := roster_filter_ids()
			if event.keycode == KEY_LEFT and not filtered.is_empty():
				begin_roster_transition(-1.0)
				roster_hero_index = posmod(roster_hero_index - 1, filtered.size())
				queue_redraw()
				return
			if event.keycode == KEY_RIGHT and not filtered.is_empty():
				begin_roster_transition(1.0)
				roster_hero_index = posmod(roster_hero_index + 1, filtered.size())
				queue_redraw()
				return
		if skill_tree_open and event.keycode == KEY_ESCAPE:
			if talent_tutorial_active():
				return
			skill_tree_open = false
			queue_redraw()
			return
		if bestiary_open and event.keycode == KEY_ESCAPE:
			bestiary_open = false
			queue_redraw()
			return
		if missions_open and event.keycode == KEY_ESCAPE:
			missions_open = false
			queue_redraw()
			return
	if training_open and event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		training_scroll = clampf(training_scroll + (-118.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 118.0), 0.0, training_scroll_max())
		queue_redraw()
		return
	if training_open and event is InputEventScreenDrag:
		training_scroll = clampf(training_scroll - event.relative.y, 0.0, training_scroll_max())
		queue_redraw()
		return
	if event is InputEventScreenDrag and touch_start.x >= 0:
		drag_current_cell = point_to_cell(event.position)
		queue_redraw()
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0 and touch_start.x >= 0:
		drag_current_cell = point_to_cell(event.position)
		queue_redraw()
	if event is InputEventScreenTouch:
		# Android/iOS can also emit an emulated left mouse event for the same
		# finger tap. Remember the touch so that event cannot activate the UI twice.
		last_screen_touch_msec = Time.get_ticks_msec()
		if event.pressed:
			handle_press(event.position)
		else:
			handle_release(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if Time.get_ticks_msec() - last_screen_touch_msec < 500:
			return
		if event.pressed:
			handle_press(event.position)
		else:
			handle_release(event.position)

func handle_press(position: Vector2) -> void:
	if player_cascade_active or region_intro_open:
		return
	if player_opening.stage != "" or grove_shop.opened:
		return
	if state != "playing":
		return
	idle_hint_time = 0.0
	hinted_cells.clear()
	drag_current_cell = point_to_cell(position)
	for index in enemies.size():
		if is_in_button(position, enemy_target_rect(index)):
			var enemy: Dictionary = enemies[index]
			held_tooltip = "%s • %s" % [str(enemy.get("name", "Wróg")), enemy_tactical_hint(enemy)]
			held_tooltip_icon = boss_portrait_for(str(enemy.get("name", "Wróg")))
			held_tooltip_hero_id = ""
			queue_redraw()
			return
	for index in active_heroes.size():
		if is_in_button(position, hero_battle_rect(index)):
			var hero_id: String = active_heroes[index]
			held_tooltip = "%s • %s" % [HERO_NAMES[HERO_IDS.find(hero_id)], HERO_SKILLS[hero_id]]
			held_tooltip_icon = hero_portraits.get(hero_id, null)
			held_tooltip_hero_id = hero_id
			queue_redraw()
			return
	if player_opening.tutorial_active(self) and player_opening.tutorial_popup_open and is_in_button(position, player_opening.tutorial_close_rect(self)):
		player_opening.tutorial_popup_open = false
		queue_redraw()
		return
	if player_opening.tutorial_active(self) and player_opening.tutorial_popup_open and point_to_cell(position).x < 0:
		touch_start = Vector2i(-1, -1)
		return
	if not training_mode and level_index == 0 and not tutorial_completed and player_opening.tutorial_moves == 0:
		var tutorial_cell := point_to_cell(position)
		if tutorial_cell != FIRST_TUTORIAL_MOVE_FROM and tutorial_cell != FIRST_TUTORIAL_MOVE_TO:
			touch_start = Vector2i(-1, -1)
			message = "W pierwszym ruchu użyj tylko podświetlonych liści."
			queue_redraw()
			return
	if not training_mode and level_index == 1 and player_opening.tutorial_moves == 0:
		var level_two_tutorial_cell := point_to_cell(position)
		if level_two_tutorial_cell != LEVEL_TWO_TUTORIAL_FROM and level_two_tutorial_cell != LEVEL_TWO_TUTORIAL_TO:
			touch_start = Vector2i(-1, -1)
			message = "Wykonaj wskazany ruch, aby utworzyć cztery liście."
			queue_redraw()
			return
	touch_start = point_to_cell(position)

func handle_release(position: Vector2) -> void:
	if player_cascade_active:
		touch_start = Vector2i(-1, -1)
		return
	if victory_screen_open:
		if victory_continue_rect().has_point(position):
			victory_screen_open = false
			training_mode = false
			if bool(current_battle.get("expedition", false)):
				open_forest_expeditions()
			else:
				main_menu_open = true
			queue_redraw()
		return
	if player_opening.stage != "":
		player_opening.handle_input(self, position)
		return
	if grove_shop.opened:
		grove_shop.handle_input(self, position)
		return
	var pressed_cell := touch_start
	touch_start = Vector2i(-1, -1)
	drag_current_cell = Vector2i(-1, -1)
	if enemy_turn_active:
		return
	if region_intro_open and not active_story_dialogue.is_empty():
		if story_dialogue_skip_rect(get_viewport_rect().size).has_point(position):
			advance_story_dialogue(true)
		elif story_dialogue_continue_rect(get_viewport_rect().size).has_point(position):
			advance_story_dialogue(false)
		return
	if held_tooltip != "":
		held_tooltip = ""
		held_tooltip_icon = null
		held_tooltip_hero_id = ""
		queue_redraw()
	if region_intro_open:
		region_intro_open = false
		if active_region_intro_key.begins_with("chapter_"):
			seen_region_chapters[active_region_intro_key.trim_prefix("chapter_")] = true
		else:
			seen_region_intros[int(current_battle.get("id", 0))] = true
		save_progress()
		message = "Wyprawa trwa — odnajdź drogę przez krainę."
		queue_redraw()
		return

	if defender_help_open:
		defender_help_open = false
		queue_redraw()
		return
	if not roster_open and not village_open and not map_open and not booster_open and not training_open and not help_open and not main_menu_open and has_living_defender():
		for index in enemies.size():
			var guarded_enemy: Dictionary = enemies[index]
			if int(guarded_enemy.get("health", 0)) > 0 and str(guarded_enemy.get("role", "attacker")) != "defender" and is_in_button(position, enemy_guard_icon_rect(index)):
				defender_help_open = true
				queue_redraw()
				return
	for index in enemies.size():
		if not roster_open and not village_open and not map_open and not booster_open and not training_open and not help_open and not main_menu_open and is_in_button(position, enemy_target_rect(index)) and int(enemies[index].get("health", 0)) > 0:
			previous_target_index = target_enemy_index
			target_enemy_index = index
			target_transition = 1.0
			message = "Cel: %s" % str(enemies[index].get("name", "Wróg"))
			queue_redraw()
			return
	if main_menu_open:
		if daily_reward_popup_open:
			handle_daily_reward_popup_input(position)
			return
		if bestiary_open:
			handle_bestiary_input(position)
			return
		if help_open:
			handle_help_input(position)
			return
		handle_main_menu_input(position)
		return
	if skill_tree_open:
		handle_skill_tree_input(position)
		return
	if not village_open and is_in_button(position, pause_rect()):
		main_menu_open = true
		queue_redraw()
		return
	if roster_open:
		handle_roster_input(position)
		return
	if village_open:
		handle_village_input(position)
		return
	if map_open:
		if map_was_dragged:
			map_was_dragged = false
			return
		handle_map_input(position)
		return
	if training_open:
		handle_training_input(position)
		return
	if booster_open:
		handle_booster_input(position)
		return
	if is_in_button(position, map_rect()):
		map_page = int(maxi(0, campaign_frontier_count() - 1) / 5)
		map_open = true
		queue_redraw()
		return
	if state != "playing":
		handle_action_button(position)
		return
	if is_in_button(position, roster_rect()):
		roster_open = true
		queue_redraw()
		return
	if is_in_button(position, village_rect()):
		village_open = true
		village_selected_id = ""
		queue_redraw()
		return
	for branch in 3:
		if is_in_button(position, hero_active_skill_rect(branch)):
			activate_hero_branch_skill(branch)
			return
	var released_cell := point_to_cell(position)
	if released_cell.x < 0:
		return
	if not training_mode and level_index == 1 and player_opening.tutorial_moves == 0:
		var tutorial_endpoint := released_cell == LEVEL_TWO_TUTORIAL_FROM or released_cell == LEVEL_TWO_TUTORIAL_TO
		var tutorial_move_made := (pressed_cell == LEVEL_TWO_TUTORIAL_FROM and released_cell == LEVEL_TWO_TUTORIAL_TO) or (pressed_cell == LEVEL_TWO_TUTORIAL_TO and released_cell == LEVEL_TWO_TUTORIAL_FROM) or (selected_cell == LEVEL_TWO_TUTORIAL_FROM and pressed_cell == released_cell and released_cell == LEVEL_TWO_TUTORIAL_TO) or (selected_cell == LEVEL_TWO_TUTORIAL_TO and pressed_cell == released_cell and released_cell == LEVEL_TWO_TUTORIAL_FROM) or (pressed_cell == released_cell and tutorial_endpoint)
		if not tutorial_move_made:
			message = "Najpierw wykonaj ruch z samouczka — utworzy kafelek wybuchowy."
			queue_redraw()
			return
	if not training_mode and level_index == 0 and not tutorial_completed and player_opening.tutorial_moves == 0:
		var tutorial_move_made := (pressed_cell == FIRST_TUTORIAL_MOVE_FROM or pressed_cell == FIRST_TUTORIAL_MOVE_TO) and (released_cell == FIRST_TUTORIAL_MOVE_FROM or released_cell == FIRST_TUTORIAL_MOVE_TO)
		if not tutorial_move_made:
			message = "Przeciągnij podświetlony liść na sąsiednie podświetlone pole."
			queue_redraw()
			return
	if lada_targeting:
		activate_lada(released_cell)
		return
	if brun_targeting:
		activate_brun(released_cell)
		return
	if hammer_targeting:
		activate_hammer(released_cell)
		return
	if bolt_targeting:
		activate_bolt(released_cell)
		return
	if gale_targeting:
		activate_gale(released_cell)
		return
	if pressed_cell == released_cell:
		handle_tile_click(released_cell)
		return
	if pressed_cell.x < 0:
		return
	if abs(pressed_cell.x - released_cell.x) + abs(pressed_cell.y - released_cell.y) != 1:
		message = "Przesuń znak na sąsiednie pole."
		queue_redraw()
		return
	selected_cell = Vector2i(-1, -1)
	try_swap(pressed_cell, released_cell)

func story_dialogue_continue_rect(screen: Vector2) -> Rect2:
	var width := minf(236.0, screen.x - 64.0)
	return Rect2(Vector2((screen.x - width) * 0.5, (screen.y - 440.0) * 0.5 + 354.0), Vector2(width, 48.0))

func story_dialogue_skip_rect(screen: Vector2) -> Rect2:
	return Rect2(Vector2(screen.x - 190.0, (screen.y - 440.0) * 0.5 + 8.0), Vector2(120.0, 42.0))

func advance_story_dialogue(skip_scene: bool) -> void:
	if not skip_scene and story_dialogue_page + 1 < active_story_dialogue.size():
		story_dialogue_page += 1
		queue_redraw()
		return
	region_intro_open = false
	var scene_id := int(active_region_intro_key.trim_prefix("story_")) if active_region_intro_key.begins_with("story_") else -1
	if scene_id >= 0:
		seen_campaign_scenes[scene_id] = true
		if REGION_INTROS.has(scene_id):
			seen_region_intros[scene_id] = true
		var chapter_id := str(current_battle.get("region", ""))
		if REGION_CHAPTERS.has(chapter_id):
			seen_region_chapters[chapter_id] = true
	else:
		if active_region_intro_key.begins_with("chapter_"):
			seen_region_chapters[active_region_intro_key.trim_prefix("chapter_")] = true
		else:
			seen_region_intros[int(current_battle.get("id", 0))] = true
	active_story_dialogue.clear()
	active_region_intro_key = ""
	save_progress()
	message = "Wyprawa trwa — odnajdź drogę przez krainę."
	queue_redraw()

func handle_tile_click(cell: Vector2i) -> void:
	play_audio_event("tile_select", 580.0, 0.06, 0.08)
	if int(special_tiles[cell.y][cell.x]) > 0:
		selected_cell = Vector2i(-1, -1)
		clear_move_preview()
		activate_special_tile(cell)
		return
	if selected_cell.x < 0:
		selected_cell = cell
		message = ""
		clear_move_preview()
	elif selected_cell == cell:
		selected_cell = Vector2i(-1, -1)
		clear_move_preview()
		message = "Wybór anulowany."
	elif abs(selected_cell.x - cell.x) + abs(selected_cell.y - cell.y) == 1:
		var first := selected_cell
		selected_cell = Vector2i(-1, -1)
		clear_move_preview()
		try_swap(first, cell)
	else:
		selected_cell = cell
		message = ""
		clear_move_preview()
	queue_redraw()

func activate_special_tile(cell: Vector2i) -> void:
	if animation_busy or enemy_turn_active or player_cascade_active or state != "playing":
		return
	var special_kind := int(special_tiles[cell.y][cell.x])
	var element := int(board[cell.y][cell.x])
	if special_kind <= 0 or element < 0:
		return
	battle_moves += 1
	special_tiles[cell.y][cell.x] = 0
	var struck := {}
	if special_kind == 1:
		for row in range(maxi(0, cell.y - 2), mini(BOARD_SIZE, cell.y + 3)):
			for col in range(maxi(0, cell.x - 2), mini(BOARD_SIZE, cell.x + 3)):
				if board[row][col] >= 0:
					struck[Vector2i(col, row)] = true
		message = "Wybuch! Uderzenie obejmuje pole 5×5."
	else:
		for row in BOARD_SIZE:
			for col in BOARD_SIZE:
				if int(board[row][col]) == element:
					struck[Vector2i(col, row)] = true
		message = "Żywiołowa fala usuwa wszystkie znaki tego rodzaju!"
	for key in struck:
		var affected_cell: Vector2i = key
		special_tiles[affected_cell.y][affected_cell.x] = 0
	side_objective_met = side_objective_met or (side_objective_level_id >= 0 and side_objective_kind(side_objective_level_id) == "ability")
	play_audio_event("match_4_5", 920.0 if special_kind == 1 else 1080.0, 0.22, 0.24)
	var points_multiplier: float = 1.2 if special_kind == 1 else 2.0
	await resolve_matches(struck, 0, false, [], false, points_multiplier)
	if is_level_complete():
		finish_level("Moc specjalnego kafelka rozstrzygnęła starcie.")
	else:
		await finish_special_turn("Specjalny kafelek zadał %s obrażenia." % ("zwiększone" if special_kind == 1 else "podwójne"))
	queue_redraw()

func try_swap(a: Vector2i, b: Vector2i) -> void:
	if animation_busy or enemy_turn_active or player_cascade_active:
		return
	selected_cell = Vector2i(-1, -1)
	clear_move_preview()
	swap_tiles(a, b)
	var matches := find_matches()
	if matches.is_empty():
		await animate_swap(a, b)
		swap_tiles(a, b)
		play_audio_event("ui_back", 185.0, 0.09, 0.12)
		vibrate_invalid_move()
		message = "Ten ruch nie tworzy połączenia."
		queue_redraw()
		return
	record_bestiary_encounter(current_battle)
	battle_moves += 1
	await animate_swap(a, b)
	play_audio_event("tile_swap", 540.0, 0.08, 0.16)
	await resolve_matches(matches, 0, true, [a, b], true)
	if level_index == 0 and not training_mode and not tutorial_completed:
		player_opening.tutorial_moves += 1
		player_opening.tutorial_popup_open = true
	elif level_index == 1 and not training_mode and player_opening.tutorial_moves == 0:
		player_opening.tutorial_moves = 1
		player_opening.tutorial_popup_open = true
	if is_level_complete():
		finish_level("Las odpowiada na twój szept.")
		return
	if expedition_move_limit_reached():
		return
	# Plansza musi najpierw pokazać opadanie i nowe znaki. Dopiero na
	# ustabilizowanej planszy przeciwnik zaczyna analizować swój ruch.
	await wait_for_board_to_settle()
	if bonus_moves_pending > 0:
		bonus_moves_pending -= 1
		message = "DODATKOWY RUCH! Przeciwnik nie odpowiada — wykonaj kolejne połączenie."
		queue_redraw()
		return
	refresh_survival_wave()
	await enemy_take_turn()
	advance_turn()
	if party_health <= 0:
		state = "lost"
		play_audio_event("defeat_sting", 180.0, 0.3, 0.15)
		main_menu_open = true
		message = "Drużyna została pokonana przez %s." % enemy_name
	else:
		if goal_type == "survive":
			goal_progress = mini(goal_target, goal_progress + 1)
			if is_level_complete():
				finish_level("Drużyna przetrwała ataki przeciwnika.")
				return
		if not message.contains("KOMBO") and not message.contains("ULTRA"):
			message = last_enemy_attack_text if last_enemy_attack_text != "" else "Dobra kombinacja!"
	queue_redraw()

func animate_swap(a: Vector2i, b: Vector2i) -> void:
	animation_busy = true
	var duration := 0.18
	tile_offsets[a] = Vector2(b - a)
	tile_offsets[b] = Vector2(a - b)
	var elapsed := 0.0
	while elapsed < duration:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var progress := minf(1.0, elapsed / duration)
		var eased := 1.0 - pow(1.0 - progress, 3.0)
		tile_offsets[a] = Vector2(b - a) * (1.0 - eased)
		tile_offsets[b] = Vector2(a - b) * (1.0 - eased)
		queue_redraw()
	tile_offsets.erase(a)
	tile_offsets.erase(b)
	animation_busy = false

func wait_for_board_to_settle() -> void:
	while not tile_offsets.is_empty() or not removal_effects.is_empty():
		await get_tree().process_frame

func activate_lada(target: Vector2i) -> void:
	play_audio_event("skill_activate_thunder", 740.0, 0.18, 0.18)
	lada_targeting = false
	lada_charge = 0
	side_objective_met = side_objective_met or side_objective_kind(side_objective_level_id) == "ability"
	var struck := {}
	for row in BOARD_SIZE:
		struck[Vector2i(target.x, row)] = true
	await resolve_matches(struck, active_ability_damage(8 * int(hero_levels["lada"])))
	if is_level_complete():
		finish_level("Piorun Ledy prowadzi cię dalej.")
	else:
		finish_special_turn("Strzała Peruna rozdarła kolumnę!")
	queue_redraw()

func activate_brun(target: Vector2i) -> void:
	play_audio_event("skill_activate_fire", 340.0, 0.18, 0.18)
	brun_targeting = false
	brun_charge = 0
	side_objective_met = side_objective_met or side_objective_kind(side_objective_level_id) == "ability"
	var struck := {}
	for row in range(maxi(0, target.y - 1), mini(BOARD_SIZE, target.y + 2)):
		for col in range(maxi(0, target.x - 1), mini(BOARD_SIZE, target.x + 2)):
			struck[Vector2i(col, row)] = true
	await resolve_matches(struck, active_ability_damage(25 + 10 * int(hero_levels["brun"])))
	if is_level_complete():
		finish_level("Uderzenie Bruna skruszyło obronę wroga.")
	else:
		finish_special_turn("Uderzenie Kowala niszczy obszar i zadaje dodatkowe obrażenia!")
	queue_redraw()

func activate_mieta() -> void:
	play_audio_event("skill_activate_water", 600.0, 0.18, 0.18)
	mieta_charge = 0
	side_objective_met = side_objective_met or side_objective_kind(side_objective_level_id) == "ability"
	var healed_tiles := 0
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if board[row][col] == 1:
				board[row][col] = -1
				special_tiles[row][col] = 0
				healed_tiles += 1
	var healing := healed_tiles * (6 + int(hero_levels["mieta"]))
	heal_all_living_heroes(healing)
	collapse_board()
	await resolve_matches(find_matches())
	if is_level_complete():
		finish_level("Krąg Uzdrowienia ocalił drużynę.")
	else:
		finish_special_turn("Krąg Uzdrowienia przywrócił drużynie po %d zdrowia." % healing)
	queue_redraw()

func activate_hero_branch_skill(branch: int) -> void:
	var hero_id := current_turn_hero()
	var rank := hero_active_skill_rank(hero_id, branch)
	var skill_name := SkillTree.branch_name(hero_id, branch)
	if rank <= 0:
		message = "%s jest zablokowana. Zainwestuj punkt w tę gałąź talentów." % skill_name
		queue_redraw()
		return
	var cost := hero_active_skill_cost(branch)
	var charge := int(hero_active_charge.get(hero_id, 0))
	if charge < cost:
		message = "%s potrzebuje jeszcze %d energii żywiołu." % [skill_name, cost - charge]
		queue_redraw()
		return
	side_objective_met = side_objective_met or side_objective_kind(side_objective_level_id) == "ability"
	hero_active_charge[hero_id] = charge - cost
	play_audio_event(hero_skill_audio_event(hero_id), 740.0, 0.18, 0.18)
	var hero_level := int(hero_levels.get(hero_id, 1))
	var damage := 0
	match branch:
		0:
			damage = active_ability_damage(20 + hero_level * 3 + rank * 6)
			score += damage
			if has_living_enemies():
				deal_damage_to_enemies(damage)
		1:
			damage = active_ability_damage(10 + hero_level * 2 + rank * 4)
			party_shield += 5 + rank * 2
			heal_all_living_heroes(2 + rank)
			score += damage
			if has_living_enemies():
				deal_damage_to_enemies(damage)
		2:
			var favored_element := SkillTree.element(hero_id)
			var removal_limit := mini(8, 2 + int(rank / 3))
			var struck := {}
			for row in BOARD_SIZE:
				for col in BOARD_SIZE:
					if struck.size() >= removal_limit:
						break
					if board[row][col] == favored_element:
						struck[Vector2i(col, row)] = true
				if struck.size() >= removal_limit:
					break
			damage = active_ability_damage(15 + hero_level * 2 + rank * 5 + struck.size() * 4)
			score += damage
			if not struck.is_empty():
				await resolve_matches(struck, damage)
			elif has_living_enemies():
				deal_damage_to_enemies(damage)
	if is_level_complete():
		finish_level("%s kończy starcie." % skill_name)
	else:
		finish_special_turn("%s: %d obrażeń specjalnych." % [skill_name, damage])
	queue_redraw()

func finish_special_turn(success_message: String) -> void:
	if expedition_move_limit_reached():
		return
	if bonus_moves_pending > 0:
		bonus_moves_pending -= 1
		message = "DODATKOWY RUCH! Przeciwnik nie odpowiada — wykonaj kolejne działanie."
		queue_redraw()
		return
	refresh_survival_wave()
	await enemy_take_turn()
	advance_turn()
	if party_health <= 0:
		state = "lost"
		play_audio_event("defeat_sting", 180.0, 0.3, 0.15)
		main_menu_open = true
		message = "Drużyna została pokonana przez wrogów."
	else:
		if goal_type == "survive":
			goal_progress = mini(goal_target, goal_progress + 1)
			if is_level_complete():
				finish_level("Drużyna obroniła tartak.")
				return
		message = success_message

func refresh_survival_wave() -> void:
	if bool(current_battle.get("expedition", false)) and goal_type == "survive" and not has_living_enemies():
		setup_enemies(current_battle)
		target_enemy_index = 0
		displayed_enemy_health.clear()
		message = "Kolejna fala napastników! Utrzymaj obronę tartaku."

func activate_hammer(target: Vector2i) -> void:
	hammer_targeting = false
	hammer_count -= 1
	side_objective_met = side_objective_met or side_objective_kind(side_objective_level_id) == "ability"
	var struck := {}
	for row in range(maxi(0, target.y - 1), mini(BOARD_SIZE, target.y + 2)):
		for col in range(maxi(0, target.x - 1), mini(BOARD_SIZE, target.x + 2)):
			struck[Vector2i(col, row)] = true
	await resolve_matches(struck)
	if is_level_complete():
		finish_level("Uderzenie młota otworzyło dalszą drogę.")
	else:
		message = "Młot bursztynowy zniszczył pobliskie znaki!"
	queue_redraw()

func activate_bolt(target: Vector2i) -> void:
	play_audio_event("skill_activate_thunder", 740.0, 0.18, 0.18)
	bolt_targeting = false
	bolt_count -= 1
	side_objective_met = side_objective_met or side_objective_kind(side_objective_level_id) == "ability"
	var struck := {}
	for col in BOARD_SIZE:
		struck[Vector2i(col, target.y)] = true
	await resolve_matches(struck)
	if is_level_complete():
		finish_level("Grom Peruna otworzył dalszą drogę.")
	else:
		message = "Grom Peruna zniszczył cały rząd!"
	queue_redraw()

func activate_gale(target: Vector2i) -> void:
	play_audio_event("skill_activate_wind", 640.0, 0.18, 0.18)
	gale_targeting = false
	gale_count -= 1
	side_objective_met = side_objective_met or side_objective_kind(side_objective_level_id) == "ability"
	var selected_type: int = board[target.y][target.x]
	var struck := {}
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if board[row][col] == selected_type:
				struck[Vector2i(col, row)] = true
	await resolve_matches(struck)
	if is_level_complete():
		finish_level("Wiatr Gaju odsłonił nową ścieżkę.")
	else:
		message = "Wiatr Gaju rozwiał wszystkie znaki tego typu!"
	queue_redraw()

func resolve_matches(matches: Dictionary, initial_bonus_damage := 0, can_create_special := false, preferred_cells: Array = [], grant_bonus_move := false, special_multiplier := 1.0) -> void:
	player_cascade_active = true
	hinted_cells.clear()
	idle_hint_time = 0.0
	var chain := 1
	var cascade_steps := 0
	while not matches.is_empty() and cascade_steps < MAX_CASCADE_STEPS:
		var has_five := false
		var has_four := false
		var has_square := false
		if is_equal_approx(special_multiplier, 1.0):
			for key in matches:
				var match_cell: Vector2i = key
				for length in [5, 4]:
					if match_cell.x + length <= BOARD_SIZE:
						var horizontal_ok := true
						for step in length:
							if not matches.has(Vector2i(match_cell.x + step, match_cell.y)):
								horizontal_ok = false
						if horizontal_ok:
							has_five = has_five or length == 5
							has_four = has_four or length == 4
					if match_cell.y + length <= BOARD_SIZE:
						var vertical_ok := true
						for step in length:
							if not matches.has(Vector2i(match_cell.x, match_cell.y + step)):
								vertical_ok = false
						if vertical_ok:
							has_five = has_five or length == 5
							has_four = has_four or length == 4
				if matches.has(Vector2i(match_cell.x + 1, match_cell.y)) and matches.has(Vector2i(match_cell.x, match_cell.y + 1)) and matches.has(Vector2i(match_cell.x + 1, match_cell.y + 1)):
					has_square = true
		if has_four or has_five or has_square:
			play_audio_event("match_4_5", 920.0, 0.18, 0.20)
		elif cascade_steps == 0:
			play_audio_event("match_3", 720.0, 0.12, 0.20)
		if cascade_steps > 0:
			play_audio_event("tile_cascade", 650.0, 0.08, 0.10)
		var special_kind_to_create := 2 if can_create_special and has_five else (1 if can_create_special and has_four else 0)
		var special_cell_to_create := choose_special_creation_cell(matches, preferred_cells) if special_kind_to_create > 0 else Vector2i(-1, -1)
		if special_kind_to_create > 0 and special_cell_to_create.x < 0:
			special_kind_to_create = 0
		if grant_bonus_move and (has_four or has_five):
			bonus_moves_pending += 1
		if side_objective_level_id >= 0 and side_objective_kind(side_objective_level_id) == "combo" and (has_four or has_five or has_square):
			side_objective_met = true
		if has_four or has_five or has_square:
			battle_combo_count += 1
		if has_five:
			message = "KAFEL GLOBALNY! Dotknij go, by usunąć wszystkie znaki tego żywiołu."
		elif has_square:
			message = "KOMBO KWADRAT — fala uderzeniowa niszczy otoczenie!"
		elif has_four:
			message = "KAFEL WYBUCHOWY! Dotknij go, by uderzyć w obszarze 5×5."
		var gained := matches.size() * 25 * chain
		if matches.size() >= 4:
			gained += 50 * chain
		score += int(round(float(gained) * special_multiplier))
		var leaf_count := 0
		var fire_count := 0
		var water_count := 0
		var amber_count := 0
		var rune_count := 0
		for key in matches:
			var cell: Vector2i = key
			var tile_type: int = board[cell.y][cell.x]
			if tile_type == 0:
				fire_count += 1
			elif tile_type == 1:
				water_count += 1
			elif tile_type == 2:
				leaf_count += 1
			elif tile_type == 3:
				amber_count += 1
			elif tile_type == 4:
				rune_count += 1
			var obstacle_health := int(obstacles[cell.y][cell.x])
			var obstacle_damage := 1
			if active_heroes.has("boruta") and tile_type == 0:
				obstacle_damage += 2
			if active_heroes.has("wlodzimierz"):
				obstacle_damage += 1
			if active_heroes.has("czernik") and obstacle_health == 3:
				obstacle_damage += 2
			if obstacle_health > obstacle_damage:
				obstacles[cell.y][cell.x] = obstacle_health - obstacle_damage
			else:
				if obstacle_health > 0:
					obstacles[cell.y][cell.x] = 0
					if goal_type == "clear_obstacles":
						goal_progress += 1
			if cell == special_cell_to_create:
				special_tiles[cell.y][cell.x] = special_kind_to_create
			elif obstacle_health <= obstacle_damage:
				removal_effects[cell] = 0.0
				board[cell.y][cell.x] = -1
				special_tiles[cell.y][cell.x] = 0
		lada_charge = mini(LADA_MAX_CHARGE, lada_charge + leaf_count)
		brun_charge = mini(BRUN_MAX_CHARGE, brun_charge + fire_count)
		mieta_charge = mini(MIETA_MAX_CHARGE, mieta_charge + water_count)
		# Pasywne moce nowych bohaterów działają, gdy bohater jest w aktywnym składzie.
		if active_heroes.has("rada") and amber_count > 0:
			coins += amber_count * 2 * int(hero_levels["rada"])
		var hero_bonus_damage := 0
		var hero_extra_healing := 0
		var hero_extra_shield := 0
		var talent_damage := 0
		var element_counts := [fire_count, water_count, leaf_count, amber_count, rune_count]
		for skill_hero_id in active_heroes:
			var skill_tree: Dictionary = hero_trees.get(skill_hero_id, {})
			var favored_count: int = element_counts[SkillTree.element(skill_hero_id)]
			# Każdy bohater zbiera energię ze swoich znaków, nawet gdy trwa
			# tura innego członka drużyny. Ładunek pozostaje osobny dla każdej osoby.
			if favored_count > 0:
				hero_active_charge[skill_hero_id] = mini(12, int(hero_active_charge.get(skill_hero_id, 0)) + favored_count)
			if favored_count <= 0:
				continue
			talent_damage += favored_count * (SkillTree.ranks(skill_tree, 0, 0) + SkillTree.ranks(skill_tree, 0, 3) * 8)
			if has_four or has_five or has_square:
				talent_damage += SkillTree.ranks(skill_tree, 0, 1) * 3 + favored_count * SkillTree.ranks(skill_tree, 2, 1) * 2
			if chain > 1:
				talent_damage += SkillTree.ranks(skill_tree, 0, 2) * 4
				score += SkillTree.ranks(skill_tree, 2, 2) * 4
			talent_damage += favored_count * SkillTree.ranks(skill_tree, 2, 3) * 4
			party_shield += favored_count * (SkillTree.ranks(skill_tree, 1, 0) + SkillTree.ranks(skill_tree, 1, 3) * 2)
			heal_hero(skill_hero_id, SkillTree.ranks(skill_tree, 1, 1) * 2 + favored_count * SkillTree.ranks(skill_tree, 1, 3) * 2)
			score += favored_count * (SkillTree.ranks(skill_tree, 2, 0) * 2 + SkillTree.ranks(skill_tree, 2, 3) * 4)
		var synergy_count := active_synergy_pairs().size()
		var defender_damage_multiplier := 1.0
		var cascade_damage_multiplier := 1
		if active_heroes.has("milena") and water_count > 0:
			hero_extra_healing += water_count * 2
		if active_heroes.has("radomir") and amber_count > 0:
			hero_bonus_damage += amber_count * 4
		if active_heroes.has("witosz") and (has_four or has_five):
			hero_extra_shield += 1
		if active_heroes.has("jagna") and leaf_count > 0:
			heal_hero(lowest_living_hero(), leaf_count)
		if active_heroes.has("welesa") and rune_count > 0:
			enemy_attack_weakened += rune_count
		if active_heroes.has("zorya") and chain == 1:
			score += 20
		if active_heroes.has("jaromir"):
			defender_damage_multiplier = 1.15
		if active_heroes.has("msciwoj") and (has_four or has_five):
			hero_bonus_damage += fire_count * 4
		if active_heroes.has("dobrawa") and rune_count > 0:
			hero_extra_shield += rune_count * 2
		if active_heroes.has("perunika") and has_five:
			hero_extra_shield += 6
		if active_heroes.has("mirka") and water_count > 0:
			heal_all_living_heroes(2)
		if active_heroes.has("mokosza") and leaf_count > 0 and water_count > 0:
			hero_extra_shield += 4
		if active_heroes.has("stribog") and has_five:
			hero_bonus_damage += 10
		if active_heroes.has("swarog") and fire_count > 0 and amber_count > 0:
			hero_bonus_damage += 8
		if active_heroes.has("weles") and chain == 1:
			cascade_damage_multiplier = 2
		var region_id := str(current_battle.get("region", "debowepogranicze"))
		var region_effect_text := ""
		var region_bonus_damage := 0
		var water_healing := water_count * 4 + hero_extra_healing + synergy_count
		match region_id:
			"swiety_gaj":
				if leaf_count > 0:
					party_shield += leaf_count * 2
					region_effect_text = "Święty Gaj wzmacnia ochronę liści."
			"bagna_welesa":
				if water_count > 0:
					water_healing += water_count * 2
					region_effect_text = "Bagna Welesa wzmacniają wodne leczenie."
			"gory_peruna":
				if fire_count > 0:
					region_bonus_damage += fire_count * 3
					region_effect_text = "Góry Peruna wzmacniają ogień."
			"nawia":
				if rune_count > 0:
					region_bonus_damage += rune_count * 4
					region_effect_text = "Nawia wzmacnia runy."
			"prawia":
				if rune_count > 0:
					party_shield += rune_count * 2
					region_effect_text = "Prawia osłania drużynę mocą run."
			"grzmotne_szczyty":
				if amber_count > 0:
					region_bonus_damage += amber_count * 5
					region_effect_text = "Grzmotne Szczyty wzmacniają bursztyn."
			"jeziora_rusalek":
				if water_count > 0:
					water_healing += water_count * 3
					region_effect_text = "Jeziora Rusałek niosą kojące leczenie."
			"ziemie_marzanny":
				if water_count > 0:
					party_shield += water_count * 3
					region_effect_text = "Ziemie Marzanny hartują drużynę lodem."
			"kraina_zmijow":
				if fire_count > 0:
					region_bonus_damage += fire_count * 4
					region_effect_text = "Kraina Żmijów roznieca żar ognia."
			"korona_drzewa":
				var korona_moc := leaf_count + rune_count
				if korona_moc > 0:
					party_shield += leaf_count * 2
					region_bonus_damage += rune_count * 3
					region_effect_text = "Korona Drzewa Świata jednoczy liście i runy."
		heal_hero(current_turn_hero(), water_healing)
		party_shield += leaf_count * (2 + int(building_levels["swiety_gaj"])) + hero_extra_shield + synergy_count
		if region_effect_text != "" and chain == 1:
			message = region_effect_text
		if goal_type == "collect_amber":
			goal_progress += amber_count
		elif goal_type == "collect_rune":
			goal_progress += rune_count
		if has_living_enemies():
			var match_total := fire_count + water_count + leaf_count + amber_count + rune_count
			var damage := match_total * 5
			if has_four:
				damage += 20
			if has_five:
				damage += 60
			if has_square:
				damage += 35
			var turn_hero := current_turn_hero()
			if turn_hero == "lada":
				damage += leaf_count * 10
			elif turn_hero == "brun":
				damage += fire_count * 10
			elif turn_hero == "mieta":
				damage += water_count * 10
			damage += amber_count * 3 + rune_count * 5
			damage += region_bonus_damage
			if active_heroes.has("wszebor"):
				damage += fire_count * 3 * int(hero_levels["wszebor"])
			if active_heroes.has("zywia"):
				damage += rune_count * 6 * int(hero_levels["zywia"])
			damage += hero_bonus_damage + talent_damage
			var synergy_damage := int(round(float(damage * chain * cascade_damage_multiplier) * (1.0 + 0.08 * synergy_count)))
			# Bonus umiejętności należy do pierwszej kasacji i tego samego celu.
			var forged_damage := float(synergy_damage) * forge_damage_multiplier()
			if chain == 1:
				forged_damage += initial_bonus_damage
			var final_damage := int(round(forged_damage * special_multiplier))
			deal_damage_to_enemies(final_damage, defender_damage_multiplier)
		collapse_board()
		queue_redraw()
		# Kolejny cel może dostać obrażenia dopiero po widocznej następnej kasacji.
		await wait_for_board_to_settle()
		matches = find_matches()
		chain += 1
		cascade_steps += 1
	# Długa kaskada nie jest powodem do przetasowania. Po zwiększeniu limitu
	# pozostawiamy planszę w jej rzeczywistym stanie, zamiast wyglądać jak reset.
	if not board_has_legal_move():
		reshuffle_board()
	await wait_for_board_to_settle()
	player_cascade_active = false
	queue_redraw()

func choose_special_creation_cell(matches: Dictionary, preferred_cells: Array) -> Vector2i:
	for preferred in preferred_cells:
		var cell: Vector2i = preferred
		if matches.has(cell) and int(special_tiles[cell.y][cell.x]) == 0 and int(obstacles[cell.y][cell.x]) == 0:
			return cell
	for key in matches:
		var cell: Vector2i = key
		if int(special_tiles[cell.y][cell.x]) == 0 and int(obstacles[cell.y][cell.x]) == 0:
			return cell
	for key in matches:
		var cell: Vector2i = key
		if int(special_tiles[cell.y][cell.x]) == 0:
			return cell
	return Vector2i(-1, -1)

func enemy_match_value(matches: Dictionary) -> int:
	# Ta sama wartość, która jest później naliczana przez wrogą kaskadę.
	var value := matches.size() * 5
	if matches.size() >= 5:
		value += 60
	return value

func enemy_choose_best_move() -> Dictionary:
	var best_move: Dictionary = {}
	var best_value := -1
	# Przeciwnik ogląda wyłącznie aktualną planszę. Sprawdza każdą sąsiednią
	# zamianę, a następnie wybiera kombinację o największych obrażeniach.
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var first := Vector2i(col, row)
			for direction in [Vector2i.RIGHT, Vector2i.DOWN]:
				var second: Vector2i = first + direction
				if second.x >= BOARD_SIZE or second.y >= BOARD_SIZE:
					continue
				swap_tiles(first, second)
				var matches := find_matches()
				var value := enemy_match_value(matches) if not matches.is_empty() else -1
				swap_tiles(first, second)
				if value > best_value:
					best_value = value
					best_move = {"from": first, "to": second, "value": value}
	return best_move

func resolve_enemy_cascade(matches: Dictionary) -> int:
	var total_combo_damage := 0
	var chain := 1
	var cascade_steps := 0
	while not matches.is_empty() and cascade_steps < MAX_CASCADE_STEPS:
		var removed_count := matches.size()
		# Pięć w jednej fali to najsilniejsza premia, a kolejne kaskady ją wzmacniają.
		var wave_damage := removed_count * 5
		if matched_line_exists(matches, 5):
			wave_damage += 60
		total_combo_damage += wave_damage * chain
		for key in matches:
			var cell: Vector2i = key
			if board[cell.y][cell.x] >= 0:
				removal_effects[cell] = 0.0
				board[cell.y][cell.x] = -1
				special_tiles[cell.y][cell.x] = 0
		collapse_board()
		matches = find_matches()
		chain += 1
		cascade_steps += 1
	if not board_has_legal_move():
		reshuffle_board()
	return total_combo_damage

func is_level_complete() -> bool:
	if goal_type == "survive":
		return goal_progress >= goal_target
	if goal_type == "collect_amber" or goal_type == "collect_rune" or goal_type == "clear_obstacles":
		return goal_progress >= goal_target
	if goal_type == "score":
		return score >= goal_target
	if not enemies.is_empty():
		return not has_living_enemies()
	return true

func expedition_move_limit_reached() -> bool:
	var limit := int(current_battle.get("move_limit", 0))
	if limit <= 0 or battle_moves < limit or is_level_complete():
		return false
	state = "lost"
	play_audio_event("defeat_sting", 180.0, 0.3, 0.15)
	main_menu_open = true
	message = "Koniec ruchów wyprawy. Zmień taktykę i spróbuj ponownie — bez utraty zasobów."
	balance_stats["expedition_losses"] = int(balance_stats.get("expedition_losses", 0)) + 1
	save_progress()
	return true

func goal_label() -> String:
	var move_limit := int(current_battle.get("move_limit", 0))
	if move_limit > 0:
		var objective := "Przeszkody" if goal_type == "clear_obstacles" else "Runy"
		return "%s: %d/%d • Ruchy: %d/%d" % [objective, goal_progress, goal_target, battle_moves, move_limit]
	# Przetrwanie celowo ma aktywnych wrogów, ale zwycięstwo zależy od liczby
	# wytrzymanych tur, a nie od ich pokonania. Pokazuj więc właściwy warunek.
	if goal_type == "survive":
		return "Przetrwaj: %d / %d tur" % [goal_progress, goal_target]
	if goal_type == "defeat_enemy" and not enemies.is_empty():
		return "Pokonaj wrogów: %d / %d" % [living_enemy_count(), enemies.size()]
	if goal_type == "collect_amber":
		return "Bursztyn: %d / %d" % [goal_progress, goal_target]
	if goal_type == "collect_rune":
		return "Runy: %d / %d" % [goal_progress, goal_target]
	if goal_type == "clear_obstacles":
		return "Oczyść przeszkody: %d / %d" % [goal_progress, goal_target]
	return "Punkty: %d / %d" % [score, goal_target]

func finish_level(success_message: String) -> void:
	if state == "won":
		return
	state = "won"
	play_audio_event("victory_sting", 880.0, 0.32, 0.24)
	last_stars = calculate_stars()
	if training_mode:
		grant_training_reward()
		save_progress()
		message = "%s %s" % [success_message, "Drewno dostarczono do osady. Wyprawę można powtarzać bez limitu." if bool(current_battle.get("expedition", false)) else "Aktywny skład otrzymuje PD — trening można powtarzać bez ograniczeń."]
		main_menu_open = true
		victory_screen_open = true
		victory_open_time = ui_anim_time
		return
	var level_id := int(levels[level_index].get("id", level_index + 1))
	var first_campaign_clear := int(level_stars.get(level_id, 0)) == 0
	level_stars[level_id] = maxi(int(level_stars.get(level_id, 0)), last_stars)
	var previously_unlocked := unlocked_level
	unlocked_level = max(unlocked_level, min(level_index + 2, levels.size()))
	if unlocked_level > previously_unlocked:
		queue_audio_event("level_unlock", 3.8)
	if level_id > 5:
		campaign_wins_since_interstitial = mini(WINS_BETWEEN_INTERSTITIALS, campaign_wins_since_interstitial + 1)
	record_bestiary_encounter(current_battle, true)
	grant_level_reward()
	if first_campaign_clear and level_id in [3, 5, 10, 20, 50, 100]:
		var rebuilding_wood := 40 if level_id <= 5 else 60
		wood += rebuilding_wood
		last_reward["wood"] = rebuilding_wood
	if last_stars == 3 and not bool(mastery_claims.get(str(level_id), false)):
		mastery_claims[str(level_id)] = true
		event_marks += 1
		coins += 100
		last_reward["coins"] = int(last_reward.get("coins", 0)) + 100
		last_reward["mastery"] = true
	balance_stats["campaign_wins"] = int(balance_stats.get("campaign_wins", 0)) + 1
	balance_stats["last_battle_seconds"] = maxi(0, int((Time.get_ticks_msec() - battle_started_ms) / 1000))
	if first_campaign_clear and level_id == 1:
		# Pierwsze zwycięstwo gwarantuje pierwszy poziom Lady. To jej tutorial,
		# więc PD trafiają bezpośrednio do niej, niezależnie od składu zapisu.
		var xp_needed := maxi(0, hero_experience_to_next_level("lada") - int(hero_experience.get("lada", 0)))
		hero_experience["lada"] = int(hero_experience.get("lada", 0)) + xp_needed
		experience += xp_needed
		last_reward["experience"] = int(last_reward.get("experience", 0)) + xp_needed
	var extra_coins := 0
	var side_goal_complete := side_objective_succeeded()
	var side_goal_reward_granted := false
	if side_goal_complete and not bool(claimed_side_objectives.get(str(level_id), false)):
		claimed_side_objectives[str(level_id)] = true
		extra_coins += 150
		side_goal_reward_granted = true
	var regional_codex_coins := claim_completed_bestiary_regions()
	extra_coins += regional_codex_coins
	coins += extra_coins
	last_reward["coins"] = int(last_reward.get("coins", 0)) + extra_coins
	var gained_spark := grant_boss_spark()
	var gained_event_mark := grant_event_mark()
	last_reward["sparks"] = 1 if gained_spark else 0
	last_reward["event_marks"] = (1 if gained_event_mark else 0) + (1 if bool(last_reward.get("mastery", false)) else 0)
	var mission_rewards := advance_missions()
	coins += int(mission_rewards.get("coins", 0))
	last_reward["coins"] = int(last_reward.get("coins", 0)) + int(mission_rewards.get("coins", 0))
	player_opening.on_victory(self, level_id, first_campaign_clear)
	save_progress()
	message = success_message
	if bool(last_reward.get("mastery", false)):
		message += " Mistrzostwo: +100 monet i Znak Wyprawy!"
	if side_goal_complete:
		message += " Cel dodatkowy ukończony%s." % (" — +150 monet" if side_goal_reward_granted else " ponownie!")
	if int(mission_rewards.get("coins", 0)) > 0:
		message += " Misje: +%d monet." % int(mission_rewards.get("coins", 0))
	side_objective_met = side_goal_complete
	main_menu_open = true
	victory_screen_open = true
	victory_open_time = ui_anim_time

func calculate_stars() -> int:
	var total_heroes := active_heroes.size()
	if total_heroes <= 0:
		return 1
	var living_heroes := 0
	for hero_id in active_heroes:
		if int(hero_health.get(hero_id, 0)) > 0:
			living_heroes += 1
	if living_heroes < total_heroes:
		return 1
	# Pierwsze dwa etapy uczą podstaw. Mistrzostwo później wymaga celu i zdrowia.
	if not training_mode and level_index < 2:
		return 3
	return 3 if party_health * 10 >= maxi(1, party_max_health) * 7 and side_objective_succeeded() else 2

func enemy_take_turn() -> void:
	if not has_living_enemies():
		return
	play_audio_event(game_audio.enemy_attack_event(enemy_name) if game_audio != null else "enemy_attack", 170.0, 0.18, 0.18)
	# Blokujemy wejście tylko do zakończenia zamiany i opadania znaków.
	enemy_turn_active = true
	animation_busy = true
	var obstacle_effect_text := apply_obstacle_powers()
	var attacks: Array[int] = []
	var enrage_text := ""
	for enemy in enemies:
		if int(enemy.get("health", 0)) > 0:
			var enemy_attack_value := int(enemy.get("attack", 0)) + int(level_index / 4)
			var enemy_maximum := int(enemy.get("max_health", 1))
			if enemy_maximum >= 350 and int(enemy.get("health", 0)) * 2 <= enemy_maximum:
				if not bool(enemy.get("enraged", false)):
					enemy["enraged"] = true
					enrage_text = "%s wpada w szał!" % str(enemy.get("name", "Wróg"))
				enemy_attack_value += maxi(3, int(enemy_attack_value / 2))
			attacks.append(enemy_attack_value)
	var total_attack := combined_enemy_attack(attacks)
	var curse_count := obstacle_count(3)
	if curse_count > 0:
		total_attack += curse_count * 2
	var target_hero := scout_target_hero()
	enemy_attack_anim = 6.5
	message = "Przeciwnik wykonuje ruch."
	var support_text := enemy_support_action()
	enemy_action_phase = 0
	enemy_action_cells.clear()
	queue_redraw()
	var best_move := enemy_choose_best_move()
	var combo_damage := 0
	if not best_move.is_empty():
		var first: Vector2i = best_move["from"]
		var second: Vector2i = best_move["to"]
		enemy_action_cells = [first, second]
		enemy_action_phase = 1
		message = "Wróg wybrał dwa znaki — za chwilę je zamieni."
		queue_redraw()
		await get_tree().create_timer(0.25).timeout
		swap_tiles(first, second)
		queue_redraw()
		await animate_swap(first, second)
		animation_busy = true
		enemy_action_phase = 2
		message = "Kombinacja przeciwnika rozbrzmiewa po planszy..."
		combo_damage = resolve_enemy_cascade(find_matches())
		queue_redraw()
		# Po wrogiej kombinacji na chwilę odblokowujemy wyłącznie animację
		# opadania. Wejście gracza nadal blokuje enemy_turn_active.
		animation_busy = false
		message = "Znaki opadają po ruchu przeciwnika..."
		await wait_for_board_to_settle()
	enemy_action_cells.clear()
	enemy_action_phase = 0
	# Kombinacja przeciwnika ma realnie zagrażać drużynie, ale pozostawiać czas
	# na reakcję i leczenie. Runy nadal mogą osłabić ten atak.
	var total_damage := maxi(0, total_attack + int(round(float(combo_damage) * 0.35)) - enemy_attack_weakened)
	enemy_attack_weakened = 0
	var absorbed := mini(party_shield, total_damage)
	party_shield -= absorbed
	var damage := total_damage - absorbed
	if damage > 0:
		play_audio_event("hero_hurt", 200.0, 0.12, 0.14)
		hero_health[target_hero] = maxi(0, int(hero_health[target_hero]) - damage)
		damage_popup_value = damage
		damage_popup_time = 0.8
	refresh_party_health()
	var attack_name := "Kombinacja przeciwnika" if not best_move.is_empty() else "Atak przeciwnika"
	last_enemy_attack_text = "%s%s%s: %d obrażeń w %s%s.%s" % ["%s " % enrage_text if enrage_text != "" else "", "%s " % support_text if support_text != "" else "", attack_name, damage, HERO_NAMES[HERO_IDS.find(target_hero)], " (tarcza pochłonęła %d)" % absorbed if absorbed > 0 else "", " %s" % obstacle_effect_text if obstacle_effect_text != "" else ""]
	message = "Twój ruch — wybierz kafelek i wykonaj ruch."
	animation_busy = false
	enemy_turn_active = false
	enemy_attack_anim = 0.0
	idle_hint_time = 0.0
	hinted_cells.clear()
	queue_redraw()

func refresh_party_health() -> void:
	party_health = 0
	party_max_health = 0
	for hero_id in active_heroes:
		party_health += int(hero_health[hero_id])
		party_max_health += int(hero_max_health[hero_id])

func hero_health_limit(hero_id: String) -> int:
	var tree: Dictionary = hero_trees.get(hero_id, {})
	return 90 + 18 * (maxi(1, int(hero_levels.get(hero_id, 1))) - 1) + 8 * int(building_levels["domostwa"]) + 4 * int(building_levels["chata_zielarki"]) + SkillTree.ranks(tree, 1, 2) * 3

func forge_damage_multiplier() -> float:
	return 1.0 + 0.01 * int(building_levels["kuznia"])

func active_ability_damage(base_damage: int) -> int:
	# Bonus umiejętności trafia do resolve_matches już po premiach budynków.
	var tower_bonus := 0.02 * int(building_levels["wieza_peruna"])
	return int(round(base_damage * (forge_damage_multiplier() + tower_bonus)))

func combined_enemy_attack(attacks: Array[int]) -> int:
	if attacks.is_empty():
		return 0
	var strongest := 0
	var total := 0
	for attack in attacks:
		strongest = maxi(strongest, attack)
		total += attack
	return strongest + int(round((total - strongest) * 0.35))

func matched_line_exists(matches: Dictionary, length: int) -> bool:
	for key in matches:
		var cell: Vector2i = key
		for direction in [Vector2i.RIGHT, Vector2i.DOWN]:
			var complete := true
			for step in length:
				var next: Vector2i = cell + direction * step
				if not matches.has(next) or board[next.y][next.x] < 0 or board[next.y][next.x] != board[cell.y][cell.x]:
					complete = false
					break
			if complete:
				return true
	return false

func sync_party_battle_health() -> void:
	# Skład można zmienić między walkami, zanim start_level ustawi nowe zdrowie.
	for hero_id in active_heroes:
		var previous_max := int(hero_max_health.get(hero_id, 0))
		var max_health := hero_health_limit(hero_id)
		if previous_max <= 0:
			hero_max_health[hero_id] = max_health
			hero_health[hero_id] = max_health
			displayed_hero_health[hero_id] = max_health
		else:
			hero_max_health[hero_id] = max_health
			# Awans zachowuje brakujące HP; poległych nie wskrzesza.
			if int(hero_health.get(hero_id, 0)) > 0:
				hero_health[hero_id] = clampi(int(hero_health[hero_id]) + max_health - previous_max, 1, max_health)
	active_turn_index = clampi(active_turn_index, 0, maxi(0, active_heroes.size() - 1))
	refresh_party_health()

func lowest_living_hero() -> String:
	var chosen := current_turn_hero()
	var lowest_ratio := 2.0
	for hero_id in active_heroes:
		if int(hero_health.get(hero_id, 0)) <= 0:
			continue
		var ratio := float(hero_health[hero_id]) / float(maxi(1, hero_max_health[hero_id]))
		if ratio < lowest_ratio:
			lowest_ratio = ratio
			chosen = hero_id
	return chosen

func scout_target_hero() -> String:
	for enemy in enemies:
		if int(enemy.get("health", 0)) > 0 and str(enemy.get("role", "attacker")) == "scout":
			return lowest_living_hero()
	return current_turn_hero()

func heal_hero(hero_id: String, amount: int) -> void:
	if int(hero_health.get(hero_id, 0)) <= 0:
		return
	var previous_health := int(hero_health[hero_id])
	var healing := int(round(maxi(0, amount) * (1.0 + 0.02 * int(building_levels["chata_zielarki"]))))
	hero_health[hero_id] = mini(int(hero_max_health[hero_id]), previous_health + healing)
	if int(hero_health[hero_id]) > previous_health:
		play_audio_event("heal", 390.0, 0.14, 0.13)
	refresh_party_health()

func heal_all_living_heroes(amount: int) -> void:
	for hero_id in active_heroes:
		heal_hero(hero_id, amount)

func setup_enemies(level: Dictionary) -> void:
	enemies.clear()
	var configured: Array = level.get("enemies", [])
	# Pusta, jawnie zapisana lista oznacza poziom zadaniowy bez walki.
	# Przeciwnika awaryjnego dodajemy tylko starszym konfiguracjom, które nie
	# mają ani pola `enemies`, ani pojedynczego pola `enemy`.
	if level.has("enemies"):
		for source in configured:
			var name := str(source.get("name", "Cień"))
			enemies.append({"name": name, "health": int(source.get("health", 60)), "max_health": int(source.get("health", 60)), "attack": int(source.get("attack", 5)), "role": str(source.get("role", ENEMY_ROLES.get(name, "attacker")))})
	elif level.has("enemy"):
		var source: Dictionary = level.get("enemy", {})
		var name := str(source.get("name", "Cień"))
		enemies.append({"name": name, "health": int(source.get("health", 60)), "max_health": int(source.get("health", 60)), "attack": int(source.get("attack", 5)), "role": str(source.get("role", ENEMY_ROLES.get(name, "attacker")))})
	else:
		var health := 65 + level_index * 12
		enemies.append({"name": "Leśny cień", "health": health, "max_health": health, "attack": 4 + level_index / 3, "role": "attacker"})
	sync_primary_enemy()

func sync_primary_enemy() -> void:
	for enemy in enemies:
		if int(enemy.get("health", 0)) > 0:
			enemy_name = str(enemy.get("name", ""))
			enemy_health = int(enemy.get("health", 0))
			enemy_max_health = int(enemy.get("max_health", enemy_health))
			enemy_attack = int(enemy.get("attack", 0))
			return
	enemy_name = "Pokonani"
	enemy_health = 0
	enemy_max_health = 0
	enemy_attack = 0

func has_living_enemies() -> bool:
	return living_enemy_count() > 0

func living_enemy_count() -> int:
	var count := 0
	for enemy in enemies:
		if int(enemy.get("health", 0)) > 0:
			count += 1
	return count

func next_living_enemy_index() -> int:
	for index in enemies.size():
		if int(enemies[index].get("health", 0)) > 0:
			return index
	return -1

func deal_damage_to_enemies(amount: int, defender_damage_multiplier := 1.0) -> void:
	# Jedna fala kombinacji ma dokładnie jeden cel. Nadmiar obrażeń przepada:
	# nie może "przelać się" na kolejnego wroga w tej samej fali.
	var damaged_index := target_enemy_index
	if damaged_index < 0 or damaged_index >= enemies.size() or int(enemies[damaged_index].get("health", 0)) <= 0:
		damaged_index = next_living_enemy_index()
	if damaged_index < 0:
		return
	var target: Dictionary = enemies[damaged_index]
	var actual_damage := amount
	var stone_count := obstacle_count(2)
	if stone_count > 0:
		# Każdy aktywny kamień osłabia pierwsze obrażenia zadane w tej fali.
		actual_damage = maxi(1, actual_damage - stone_count * 2)
	if str(target.get("role", "attacker")) == "defender":
		actual_damage = int(round(float(actual_damage) * defender_damage_multiplier))
	if str(target.get("role", "attacker")) != "defender" and has_living_defender():
		actual_damage = maxi(1, int(round(float(amount) * 0.55)))
		target["guarded"] = true
	enemies[damaged_index]["health"] = maxi(0, int(enemies[damaged_index].get("health", 0)) - actual_damage)
	enemy_damage_popup_index = damaged_index
	enemy_damage_popup_value = actual_damage
	enemy_damage_popup_time = 0.9
	play_hero_attack_audio()
	play_audio_event("hit_impact_armor" if stone_count > 0 else ("hit_impact_shield" if str(target.get("role", "attacker")) == "defender" else "hit_impact"), 235.0, 0.10, 0.18)
	# Dopiero od następnej fali kaskady wskazujemy kolejnego żywego wroga.
	# Nie wykonujemy tu drugiego odejmowania obrażeń.
	if int(enemies[damaged_index].get("health", 0)) <= 0:
		var family: String = game_audio.enemy_sound_family(str(target.get("name", ""))) if game_audio != null else "organic"
		play_audio_event("enemy_defeated_" + family, 250.0, 0.16, 0.12)
		var next_index := next_living_enemy_index()
		if next_index >= 0:
			previous_target_index = damaged_index
			target_enemy_index = next_index
			target_transition = 1.0
	sync_primary_enemy()

func has_living_defender() -> bool:
	for enemy in enemies:
		if int(enemy.get("health", 0)) > 0 and str(enemy.get("role", "attacker")) == "defender":
			return true
	return false

func enemy_support_action() -> String:
	var healed_text := ""
	for support in enemies:
		if int(support.get("health", 0)) <= 0 or str(support.get("role", "attacker")) != "support":
			continue
		var chosen_index := -1
		var missing_health := 0
		for index in enemies.size():
			var ally: Dictionary = enemies[index]
			var missing := int(ally.get("max_health", 0)) - int(ally.get("health", 0))
			if int(ally.get("health", 0)) > 0 and missing > missing_health:
				chosen_index = index
				missing_health = missing
		if chosen_index >= 0:
			var heal_amount := mini(missing_health, 6 + level_index / 5)
			enemies[chosen_index]["health"] = int(enemies[chosen_index].get("health", 0)) + heal_amount
			healed_text = "%s leczy %s o %d." % [str(support.get("name", "Wsparcie")), str(enemies[chosen_index].get("name", "sojusznika")), heal_amount]
	return healed_text

func enemy_role_label(enemy: Dictionary) -> String:
	match str(enemy.get("role", "attacker")):
		"defender": return "OBROŃCA"
		"support": return "WSPARCIE"
		"scout": return "ZWIADOWCA"
	return "NAPASTNIK"

func enemy_role_color(enemy: Dictionary) -> Color:
	match str(enemy.get("role", "attacker")):
		"defender": return Color("#5d92b8")
		"support": return Color("#72ad82")
		"scout": return Color("#b18bca")
	return Color("#bd654d")

func draw_enemy_role_icon(center: Vector2, role: String, color: Color, icon_size := 28.0) -> void:
	if enemy_role_emblems != null:
		# Arkusz ma różne szerokości symboli; równe ćwiartki ucinały tarczę.
		var regions := {
			"attacker": Rect2(0.0, 0.08, 0.28, 0.84),
			"defender": Rect2(0.27, 0.08, 0.30, 0.84),
			"support": Rect2(0.57, 0.0, 0.17, 1.0),
			"scout": Rect2(0.74, 0.06, 0.26, 0.91)
		}
		var region: Rect2 = regions.get(role, regions["attacker"])
		var sheet_size := enemy_role_emblems.get_size()
		var source := Rect2(region.position * sheet_size, region.size * sheet_size)
		var scale_factor := icon_size / maxf(source.size.x, source.size.y)
		var fitted_size := source.size * scale_factor
		draw_texture_rect_region(enemy_role_emblems, Rect2(center - fitted_size * 0.5, fitted_size), source, Color.WHITE)
		return
	var role_icon: Texture2D = null
	if role == "scout":
		role_icon = enemy_role_scout_icon
	elif role == "support":
		role_icon = enemy_role_mystic_icon
	elif role == "attacker":
		role_icon = enemy_role_attacker_icon
	if role_icon != null:
		draw_texture_rect(role_icon, texture_aspect_fit_rect(role_icon, Rect2(center - Vector2.ONE * icon_size * 0.5, Vector2.ONE * icon_size)), false)
		return
	draw_circle(center, 8.0, Color(color, 0.94))
	draw_circle(center, 8.0, Color("#f6e3aa"), false, 1.0)
	match role:
		"defender":
			draw_rect(Rect2(center - Vector2(3.0, 4.0), Vector2(6.0, 8.0)), Color("#fff5d6"), false, 1.5)
		"support":
			draw_line(center - Vector2(4.0, 0.0), center + Vector2(4.0, 0.0), Color("#fff5d6"), 1.5)
			draw_line(center - Vector2(0.0, 4.0), center + Vector2(0.0, 4.0), Color("#fff5d6"), 1.5)
		"scout":
			draw_circle(center, 3.0, Color("#fff5d6"), false, 1.5)
		_:
			draw_line(center - Vector2(4.0, 4.0), center + Vector2(4.0, 4.0), Color("#fff5d6"), 1.5)
			draw_line(center + Vector2(4.0, -4.0), center + Vector2(-4.0, 4.0), Color("#fff5d6"), 1.5)

func draw_enemy_guard_help() -> void:
	var panel := enemy_guard_help_rect()
	if defeat_modal_oak != null:
		draw_texture_rect(defeat_modal_oak, panel, false)
	else:
		draw_style_box(make_panel(Color("#0b211c"), Color("#d2ae62")), panel)
	var layout_scale := panel.size.x / 420.0
	draw_enemy_role_icon(panel.position + Vector2(84.0, 103.0) * layout_scale, "defender", Color("#75b6dd"), 52.0 * layout_scale)
	draw_string(font, panel.position + Vector2(135.0, 108.0) * layout_scale, "OSŁONA OBROŃCY", HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 174.0 * layout_scale, 16, Color("#ffe9ae"))
	draw_string(font, panel.position + Vector2(42.0, 157.0) * layout_scale - Vector2(0.0, 20.0), "Dopóki żyje Obrońca, pozostali wrogowie", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 84.0 * layout_scale, 12, Color("#edf4df"))
	draw_string(font, panel.position + Vector2(42.0, 180.0) * layout_scale - Vector2(0.0, 20.0), "otrzymują tylko 55% obrażeń.", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 84.0 * layout_scale, 12, Color("#edf4df"))
	draw_string(font, panel.position + Vector2(42.0, 209.0) * layout_scale - Vector2(0.0, 20.0), "Pokonaj Obrońcę jako pierwszego.", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 84.0 * layout_scale, 13, Color("#b9e58a"))
	if village_popup_close_button != null:
		draw_texture_rect(village_popup_close_button, enemy_guard_help_close_rect(), false)
	else:
		draw_string(font, enemy_guard_help_close_rect().position + Vector2(0.0, 24.0), "X", HORIZONTAL_ALIGNMENT_CENTER, enemy_guard_help_close_rect().size.x, 16, Color("#ffe9ae"))

func hero_selection_color(hero_id: String) -> Color:
	match hero_id:
		"lada": return Color("#9bd36a")
		"brun": return Color("#ef7d42")
		"mieta": return Color("#61c8da")
		"wszebor": return Color("#e7a24d")
		"rada": return Color("#e7bc58")
		"zywia": return Color("#b27ae1")
	return Color("#d9b45d")

func hero_damage_hint(hero_id: String) -> String:
	var element_names := ["ogień", "wodę", "liście", "bursztyn", "runy"]
	var element_index := clampi(SkillTree.element(hero_id), 0, element_names.size() - 1)
	return "Najwięcej obrażeń: %s. Łącz te znaki w czwórki i piątki." % element_names[element_index]

func hero_damage_coefficients(hero_id: String) -> Array[int]:
	# Wartości odpowiadają obrażeniom za pojedynczy znak w zwykłej kombinacji;
	# premie za czwórki, piątki i kaskady są doliczane osobno.
	var coefficients: Array[int] = [5, 5, 5, 8, 10]
	var favored_element := clampi(SkillTree.element(hero_id), 0, coefficients.size() - 1)
	coefficients[favored_element] += 10
	return coefficients

func hero_selection_mark(hero_id: String) -> String:
	match hero_id:
		"lada": return "♣"
		"brun": return "✦"
		"mieta": return "≈"
		"wszebor": return "✹"
		"rada": return "◆"
		"zywia": return "ᚱ"
	return "•"

func enemy_tactical_hint(enemy: Dictionary) -> String:
	var attack := int(enemy.get("attack", 0))
	var health := int(enemy.get("max_health", enemy.get("health", 0)))
	var role := str(enemy.get("role", "attacker"))
	if role == "defender":
		return "Obrońca: osłania pozostałych. Pokonaj go najpierw. Zdrowie %d." % health
	if role == "support":
		return "Wsparcie: co turę leczy najbardziej rannego sojusznika. Atak %d." % attack
	if role == "scout":
		return "Zwiadowca: atak %d, wybiera najbardziej rannego bohatera." % attack
	return "Napastnik: atak %d. Priorytetowy cel." % attack

func campaign_reward(level: Dictionary) -> Dictionary:
	var reward: Dictionary = level.get("rewards", {})
	return {"coins": int(reward.get("coins", 0)) + int(building_levels["spichlerz"]) * 10, "wood": 0, "experience": int(reward.get("experience", 0))}

func grant_level_reward() -> void:
	var reward := campaign_reward(levels[level_index])
	var received_coins := int(reward["coins"])
	var received_wood := int(reward["wood"])
	var received_experience := int(reward["experience"])
	coins += received_coins
	wood += received_wood
	experience += received_experience
	grant_hero_experience(received_experience)
	last_reward = {"coins": received_coins, "wood": received_wood, "experience": received_experience}

func build_bestiary_catalog() -> void:
	bestiary_region_catalog.clear()
	bestiary_regions.clear()
	for level in levels:
		var region_id := str(level.get("region", "debowepogranicze"))
		var region_enemies: Array = bestiary_region_catalog.get(region_id, [])
		for enemy in level.get("enemies", []):
			var enemy_name := str(enemy.get("name", "Wróg"))
			if not region_enemies.has(enemy_name):
				region_enemies.append(enemy_name)
		bestiary_region_catalog[region_id] = region_enemies
		if not bestiary_regions.has(region_id):
			bestiary_regions.append(region_id)
	for region_id in MAP_REGION_ORDER:
		if bestiary_region_catalog.has(region_id) and not bestiary_regions.has(region_id):
			bestiary_regions.append(region_id)

func bestiary_enemy_names(region_id: String) -> Array:
	var names: Array = bestiary_region_catalog.get(region_id, []).duplicate()
	names.sort()
	return names

func bestiary_region_found_count(region_id: String) -> int:
	var found := 0
	for enemy_name in bestiary_enemy_names(region_id):
		if bool(bestiary_seen.get(enemy_name, false)):
			found += 1
	return found

func record_bestiary_encounter(level: Dictionary, defeated := false) -> void:
	if training_mode:
		return
	var changed := false
	for enemy in level.get("enemies", []):
		var enemy_name := str(enemy.get("name", "Wróg"))
		if not bool(bestiary_seen.get(enemy_name, false)):
			bestiary_seen[enemy_name] = true
			changed = true
		if defeated:
			bestiary_kills[enemy_name] = int(bestiary_kills.get(enemy_name, 0)) + 1
			changed = true
	if changed:
		save_progress()

func claim_completed_bestiary_regions() -> int:
	var reward_coins := 0
	for region_id in bestiary_regions:
		if bool(claimed_bestiary_regions.get(region_id, false)):
			continue
		var names := bestiary_enemy_names(region_id)
		if names.is_empty() or bestiary_region_found_count(region_id) < names.size():
			continue
		claimed_bestiary_regions[region_id] = true
		reward_coins += 250
	return reward_coins

func side_objective_kind(level_id: int) -> String:
	match posmod(level_id, 3):
		0: return "combo"
		1: return "ability"
		_: return "healthy"

func side_objective_description(level_id: int) -> String:
	match side_objective_kind(level_id):
		"combo": return "Utwórz kombinację 4+"
		"ability": return "Użyj umiejętności lub boostera"
		_: return "Zakończ z 70% zdrowia drużyny"

func side_objective_succeeded() -> bool:
	if side_objective_level_id < 0:
		return false
	if side_objective_kind(side_objective_level_id) == "healthy":
		return party_health * 10 >= party_max_health * 7
	return side_objective_met

func side_objective_progress_text() -> String:
	match side_objective_kind(side_objective_level_id):
		"combo": return "%d / 1" % mini(1, battle_combo_count)
		"ability": return "%d / 1" % (1 if side_objective_met else 0)
		"healthy":
			var health_percent := int(round(float(party_health) * 100.0 / float(maxi(1, party_max_health))))
			return "%d%% / 70%%" % health_percent
	return ""

func mission_pool(period: String) -> Array:
	var pool: Array = []
	var metrics := ["wins", "points", "combos", "side", "stars"]
	var labels := {
		"wins": ["Zwycięstwa w walkach: %d", "Pokonani wrogowie: %d zwycięstw", "Wygrane wyprawy: %d"],
		"points": ["Punkty z walk: %d", "Zadane obrażenia: %d", "Zgromadzone punkty: %d"],
		"combos": ["Kombinacje 4+: %d", "Potężne połączenia: %d", "Połączenia 4+: %d"],
		"side": ["Ukończ cele dodatkowe: %d", "Wypełnij zadania poboczne: %d", "Zrealizuj cele walki: %d"],
		"stars": ["Zdobądź gwiazdki: %d", "Zbierz gwiazdki w walkach: %d", "Łączna liczba gwiazdek: %d"]
	}
	var targets := [1, 2, 3, 4]
	for metric_index in metrics.size():
		var metric: String = metrics[metric_index]
		for tier in targets.size():
			var target: int = int(targets[tier])
			if metric == "points":
				target = 2500 + tier * 2500 if period == "daily" else 9000 + tier * 6000
			elif metric in ["combos", "side"]:
				target = 2 + tier * 2 if period == "daily" else 5 + tier * 3
			elif metric == "wins" and period == "weekly":
				target += 2
			var title_templates: Array = labels[metric]
			var title := str(title_templates[posmod(tier, title_templates.size())]) % target
			var id := "%s_%d" % [metric, tier]
			pool.append({"id": id, "metric": metric, "target": target, "progress": 0, "title": title, "reward": 100 if period == "daily" else 350, "completed": false, "claimed": false})
	return pool

func mission_period_keys() -> Dictionary:
	var date := Time.get_date_dict_from_system()
	var day_key := "%04d-%02d-%02d" % [int(date.year), int(date.month), int(date.day)]
	var weekday := int(date.weekday) # Monday=1
	var at_midnight := {"year": int(date.year), "month": int(date.month), "day": int(date.day), "hour": 0, "minute": 0, "second": 0}
	var day_number := int(Time.get_unix_time_from_datetime_dict(at_midnight) / 86400.0)
	var monday_number := day_number - posmod(weekday - 1, 7)
	var monday_date := Time.get_date_dict_from_unix_time(monday_number * 86400)
	var week_key := "%04d-%02d-%02d" % [int(monday_date.year), int(monday_date.month), int(monday_date.day)]
	return {"day": day_key, "week": week_key}

func roll_missions(period: String, history: Array) -> Array:
	var pool := mission_pool(period)
	var used := {}
	for mission_id in history:
		used[str(mission_id)] = true
	var eligible: Array = []
	for mission in pool:
		if not used.has(str(mission.id)):
			eligible.append(mission)
	if eligible.size() < 3 and eligible.is_empty():
		history.clear()
		eligible = pool.duplicate(true)
	eligible.shuffle()
	var selected: Array = []
	for index in mini(3, eligible.size()):
		var mission: Dictionary = eligible[index].duplicate(true)
		selected.append(mission)
		history.append(str(mission.id))
	return selected

func refresh_missions() -> void:
	var keys := mission_period_keys()
	var changed := false
	if mission_day_key != str(keys.day):
		mission_day_key = str(keys.day)
		daily_missions = roll_missions("daily", daily_mission_history)
		changed = true
	if mission_week_key != str(keys.week):
		mission_week_key = str(keys.week)
		weekly_missions = roll_missions("weekly", weekly_mission_history)
		changed = true
	if changed:
		save_progress()

func advance_missions() -> Dictionary:
	refresh_missions()
	var increments := {"wins": 1, "points": score, "combos": battle_combo_count, "side": 1 if side_objective_succeeded() else 0, "stars": last_stars}
	var rewards := {"coins": 0}
	for list_name in ["daily_missions", "weekly_missions"]:
		var missions: Array = get(list_name)
		for index in missions.size():
			var mission: Dictionary = missions[index]
			if bool(mission.get("claimed", false)) or mission_is_complete(mission):
				continue
			mission.progress = mini(int(mission.target), int(mission.progress) + int(increments.get(str(mission.metric), 0)))
			if int(mission.progress) >= int(mission.target):
				mission.completed = true
			missions[index] = mission
		set(list_name, missions)
	return rewards

func mission_is_complete(mission: Dictionary) -> bool:
	return bool(mission.get("completed", false)) or int(mission.get("progress", 0)) >= int(mission.get("target", 1)) or bool(mission.get("claimed", false))

func claim_mission_reward(list_name: String, index: int) -> bool:
	var missions: Array = get(list_name)
	if index < 0 or index >= missions.size():
		return false
	var mission: Dictionary = missions[index]
	if not mission_is_complete(mission) or bool(mission.get("claimed", false)):
		return false
	coins += int(mission.get("reward", 0))
	mission.claimed = true
	missions[index] = mission
	set(list_name, missions)
	save_progress()
	play_audio_event("resource_coin", 880.0, 0.12, 0.12)
	queue_redraw()
	return true

func mission_ready_count() -> int:
	var ready := 0
	for mission in daily_missions + weekly_missions:
		if mission_is_complete(mission) and not bool(mission.get("claimed", false)):
			ready += 1
	return ready

func draw_missions_overlay(screen: Vector2) -> void:
	draw_main_menu_background(screen)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#061511c4"))
	if home_missions_icon != null:
		draw_texture_rect(home_missions_icon, Rect2(24.0, 20.0, 78.0, 78.0), false)
	draw_string(font, Vector2(108.0, 59.0), "ZADANIA GAJU", HORIZONTAL_ALIGNMENT_LEFT, screen.x - 124.0, 23 if screen.x < 430.0 else 27, Color("#ffe5a4"))
	draw_string(font, Vector2(108.0, 86.0), "Cele i nagrody za aktywną grę", HORIZONTAL_ALIGNMENT_LEFT, screen.x - 124.0, 12 if screen.x < 430.0 else 14, Color("#d7e4c8"))
	var wallet_kinds := ["coins", "wood", "experience", "sparks"]
	var wallet_values := [coins, wood, experience, perun_sparks]
	var wallet_width := 0.0
	for index in wallet_kinds.size():
		wallet_width += resource_amount_width(int(wallet_values[index]), 24.0, 14)
	wallet_width += 18.0 * (wallet_kinds.size() - 1)
	var wallet_x := (screen.x - wallet_width) * 0.5
	for index in wallet_kinds.size():
		wallet_x += draw_resource_amount(Vector2(wallet_x, 124.0), wallet_kinds[index], int(wallet_values[index]), 24.0, 14, Color("#ffe4a3")) + 18.0
	draw_string(font, Vector2(34.0, 174.0), "DZIENNE", HORIZONTAL_ALIGNMENT_LEFT, 170.0, 14, Color("#ffe5a4"))
	draw_string(font, Vector2(176.0, 174.0), mission_day_key, HORIZONTAL_ALIGNMENT_RIGHT, screen.x - 210.0, 11, Color("#c8d7be"))
	draw_mission_divider(183.0, false, screen.x)
	var y := 193.0
	for mission in daily_missions:
		draw_mission_row(mission, y, false)
		y += mission_row_stride()
	draw_string(font, Vector2(34.0, y + 12.0), "TYGODNIOWE", HORIZONTAL_ALIGNMENT_LEFT, 170.0, 14, Color("#c8f0b0"))
	draw_string(font, Vector2(176.0, y + 12.0), "tydzień od %s" % mission_week_key, HORIZONTAL_ALIGNMENT_RIGHT, screen.x - 210.0, 11, Color("#c8d7be"))
	draw_mission_divider(y + 21.0, true, screen.x)
	y += 38.0
	for mission in weekly_missions:
		draw_mission_row(mission, y, true)
		y += mission_row_stride()
	draw_button(missions_close_rect(), "POWRÓT", true, 16)

func draw_mission_row(mission: Dictionary, top: float, weekly: bool) -> void:
	var row := Rect2(28.0, top, get_viewport_rect().size.x - 56.0, mission_row_stride() - 2.0)
	var completed := mission_is_complete(mission)
	var reward_claimed := bool(mission.get("claimed", false))
	draw_multiline_string(font, Vector2(row.position.x + 4.0, row.position.y + 13.0), str(mission.get("title", "Zadanie")), HORIZONTAL_ALIGNMENT_LEFT, row.size.x - 8.0, 12, 2, Color("#c8f0b0") if completed else Color("#f0ecd9"))
	var progress := int(mission.get("progress", 0))
	var target := maxi(1, int(mission.get("target", 1)))
	var bar := Rect2(row.position.x, row.position.y + 32.0, row.size.x - 118.0, 24.0)
	if mission_progress_track_style == null:
		mission_progress_track_style = StyleBoxFlat.new()
		mission_progress_track_style.set_corner_radius_all(8)
	if mission_progress_fill_style == null:
		mission_progress_fill_style = StyleBoxFlat.new()
		mission_progress_fill_style.set_corner_radius_all(7)
	mission_progress_track_style.bg_color = Color("#071b16f2")
	mission_progress_fill_style.bg_color = Color("#65ad72") if weekly else Color("#d9ae50")
	# Wypełnienie mieści się wyłącznie w otworze ramki, z dala od liści i szyn.
	var track := mission_progress_inner_rect(bar)
	draw_style_box(mission_progress_track_style, track)
	var fill_width := track.size.x * clampf(float(progress) / float(target), 0.0, 1.0)
	if fill_width > 0.0:
		var fill_rect := Rect2(track.position, Vector2(fill_width, track.size.y))
		var fill_art := mission_progress_emerald if weekly else mission_progress_amber
		if fill_art != null:
			draw_mission_progress_fill(fill_art, fill_rect)
		else:
			draw_style_box(mission_progress_fill_style, fill_rect)
	if mission_progress_frame != null:
		draw_mission_ui_art(mission_progress_frame, bar)
	var value_badge := Rect2(bar.position.x + (bar.size.x - minf(142.0, bar.size.x)) * 0.5, top + 60.0, minf(142.0, bar.size.x), 25.0)
	if mission_counter_plaque != null:
		draw_mission_ui_art(mission_counter_plaque, value_badge)
	draw_string(font, Vector2(value_badge.position.x, value_badge.position.y + 17.0), "%d / %d" % [progress, target], HORIZONTAL_ALIGNMENT_CENTER, value_badge.size.x, 11, Color("#fff0ce"))
	var claim_rect := mission_claim_rect(top)
	var reward := int(mission.get("reward", 0))
	# Zadania wypłacają monety; ikona ma odzwierciedlać faktyczną nagrodę.
	var reward_label := "+%d" % reward
	var reward_width := 25.0 + font.get_string_size(reward_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	var reward_x := claim_rect.get_center().x - reward_width * 0.5
	var icon := resource_icon("coins")
	if icon != null:
		draw_texture_rect(icon, Rect2(reward_x, top + 30.0, 22.0, 22.0), false)
	draw_string(font, Vector2(reward_x + 25.0, top + 46.0), reward_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#ffe08a"))
	if mission_claim_button != null:
		draw_mission_ui_art(mission_claim_button, claim_rect, Color.WHITE if completed and not reward_claimed else Color(0.55, 0.60, 0.52))
	var action_label := "ODEBRANO" if reward_claimed else ("ODBIERZ" if completed else "W TRAKCIE")
	draw_string(font, Vector2(claim_rect.position.x, claim_rect.get_center().y + 4.0), action_label, HORIZONTAL_ALIGNMENT_CENTER, claim_rect.size.x, 11, Color("#fff0bd") if completed else Color("#b9c7af"))
	draw_mission_divider(row.end.y + 1.0, weekly, get_viewport_rect().size.x)

func draw_mission_progress_fill(texture: Texture2D, target: Rect2) -> void:
	# Keep the rounded caps intact even when a mission has very little progress.
	var source_size := texture.get_size()
	var source_cap := minf(source_size.y * 0.5, source_size.x * 0.5)
	var cap := minf(target.size.y * 0.5, target.size.x * 0.5)
	draw_texture_rect_region(texture, Rect2(target.position, Vector2(cap, target.size.y)), Rect2(0.0, 0.0, source_cap, source_size.y))
	var middle_width := target.size.x - cap * 2.0
	if middle_width > 0.01:
		draw_texture_rect_region(texture, Rect2(target.position + Vector2(cap, 0.0), Vector2(middle_width, target.size.y)), Rect2(source_cap, 0.0, source_size.x - source_cap * 2.0, source_size.y))
	draw_texture_rect_region(texture, Rect2(Vector2(target.end.x - cap, target.position.y), Vector2(cap, target.size.y)), Rect2(source_size.x - source_cap, 0.0, source_cap, source_size.y))

func mission_row_stride() -> float:
	return clampf((get_viewport_rect().size.y - 314.0) / 6.0, 88.0, 106.0)

func mission_progress_inner_rect(bar: Rect2) -> Rect2:
	# Otwór grafiki v02 po przycięciu do Rect2(12, 260, 2149, 212).
	# Wypełnienie wchodzi odrobinę pod złoty obrys rysowany na wierzchu,
	# dzięki czemu pełny pasek nie zostawia szczelin na zaokrąglonych końcach.
	return Rect2(bar.position + bar.size * Vector2(0.077, 0.31), bar.size * Vector2(0.846, 0.405))

func draw_mission_ui_art(texture: Texture2D, target: Rect2, tint := Color.WHITE) -> void:
	var key := texture.get_instance_id()
	if not mission_ui_art_bounds.has(key):
		mission_ui_art_bounds[key] = Rect2(texture.get_image().get_used_rect())
	draw_texture_rect_region(texture, target, mission_ui_art_bounds[key], tint)

func draw_mission_divider(y: float, weekly: bool, screen_width: float) -> void:
	var tint := Color("#82b88c") if weekly else Color("#c49c52")
	var left := 34.0
	var right := screen_width - 34.0
	var center := screen_width * 0.5
	draw_line(Vector2(left, y), Vector2(center - 7.0, y), Color(tint, 0.30), 1.0, true)
	draw_line(Vector2(center + 7.0, y), Vector2(right, y), Color(tint, 0.30), 1.0, true)
	draw_line(Vector2(left + 3.0, y + 2.0), Vector2(right - 3.0, y + 2.0), Color(tint, 0.10), 1.0, true)
	var diamond := PackedVector2Array([Vector2(center, y - 3.0), Vector2(center + 3.0, y), Vector2(center, y + 3.0), Vector2(center - 3.0, y)])
	draw_colored_polygon(diamond, Color(tint, 0.85))
	draw_circle(Vector2(left, y), 1.4, Color(tint, 0.8))
	draw_circle(Vector2(right, y), 1.4, Color(tint, 0.8))

func grant_boss_spark() -> bool:
	var level: Dictionary = levels[level_index]
	var level_id := int(level.get("id", level_index + 1))
	if not is_boss_level(level) or bool(claimed_boss_sparks.get(level_id, false)):
		return false
	perun_sparks += 1
	queue_audio_event("resource_perun", 2.5)
	claimed_boss_sparks[level_id] = true
	return true

func grant_event_mark() -> bool:
	var level_id := int(levels[level_index].get("id", level_index + 1))
	# Co piąty etap daje znak wyprawy; Iskra Peruna pozostaje nagrodą za bossa.
	if level_id % 5 == 0 and not bool(claimed_boss_sparks.get(-level_id, false)):
		event_marks += 1
		claimed_boss_sparks[-level_id] = true
		return true
	return false

func is_boss_level(level: Dictionary) -> bool:
	var level_id := int(level.get("id", 0))
	# Ręcznie zaprojektowane etapy korzystają z rozpiski bossów prologu.
	# W długiej kampanii strażnik pojawia się co 25, a wielki boss co 50 poziomów.
	if level_id <= 100:
		return MANUAL_BOSS_LEVELS.has(level_id)
	return level_id % 25 == 0

func grant_hero_experience(amount: int) -> void:
	var eligible: Array[String] = []
	for hero_id in active_heroes:
		if bool(owned_heroes.get(hero_id, false)):
			eligible.append(hero_id)
	if eligible.is_empty():
		return
	var share := maxi(1, amount / eligible.size())
	for hero_id in eligible:
		hero_experience[hero_id] = int(hero_experience[hero_id]) + share

func grant_training_reward() -> void:
	var reward: Dictionary = training_battle.get("rewards", {})
	var expedition := bool(training_battle.get("expedition", false))
	if expedition:
		var mission_id := str(training_battle.get("id", ""))
		var day := Time.get_date_string_from_system()
		var bonus_available := str(expedition_bonus_claims.get(mission_id, "")) != day
		reward = ForestExpeditions.effective_reward(training_battle, bonus_available)
		expedition_bonus_claims[mission_id] = day
		balance_stats["expedition_wins"] = int(balance_stats.get("expedition_wins", 0)) + 1
	var received_coins := int(reward.get("coins", 0))
	var received_wood := int(reward.get("wood", 0)) if expedition else 0
	if expedition:
		balance_stats["wood_expeditions"] = int(balance_stats.get("wood_expeditions", 0)) + received_wood
	var received_experience := int(reward.get("experience", 0))
	coins += received_coins
	wood += received_wood
	experience += received_experience
	# Trening rozwija wyłącznie bohaterów, których gracz świadomie wystawił.
	for hero_id in active_heroes:
		hero_experience[hero_id] = int(hero_experience[hero_id]) + received_experience
	last_reward = {"coins": received_coins, "wood": received_wood, "experience": received_experience}
	if received_wood > 0:
		queue_audio_event("resource_wood", 1.5)

func restart_current_battle() -> void:
	if training_mode:
		start_level(level_index, training_battle)
	else:
		start_level(level_index)

func hero_experience_to_next_level(hero_id: String) -> int:
	# Pierwsze zwycięstwo gwarantuje PD na ten pierwszy, darmowy awans Lady.
	if hero_id == "lada" and int(hero_levels.get(hero_id, 0)) == 1:
		return 60
	return maxi(100, int(hero_levels[hero_id]) * 100)

func get_total_hero_levels() -> int:
	var total := 0
	for hero_id in HERO_IDS:
		total += int(hero_levels[hero_id])
	return total

func get_active_hero_levels() -> int:
	var total := 0
	for hero_id in active_heroes:
		total += int(hero_levels[hero_id])
	return total

func current_turn_hero() -> String:
	if active_heroes.is_empty():
		return "lada"
	for offset in active_heroes.size():
		var hero_id: String = active_heroes[(active_turn_index + offset) % active_heroes.size()]
		if int(hero_health.get(hero_id, 1)) > 0:
			return hero_id
	return active_heroes[0]

func active_synergy_pairs() -> Array:
	var active_pairs: Array = []
	for pair in HERO_SYNERGY_PAIRS:
		if active_heroes.has(str(pair[0])) and active_heroes.has(str(pair[1])):
			active_pairs.append(pair)
	return active_pairs

func synergy_portrait_ids(hero_id: String) -> Array[String]:
	var partners: Array[String] = []
	for pair in HERO_SYNERGY_PAIRS:
		if str(pair[0]) == hero_id:
			partners.append(str(pair[1]))
		elif str(pair[1]) == hero_id:
			partners.append(str(pair[0]))
		if partners.size() == 2:
			break
	return partners

func advance_turn() -> void:
	if party_health > 0:
		play_audio_event("turn_start", 600.0, 0.08, 0.07)
	if active_heroes.size() > 1:
		active_turn_index = (active_turn_index + 1) % active_heroes.size()
		for unused in active_heroes.size():
			if int(hero_health.get(active_heroes[active_turn_index], 1)) > 0:
				break
			active_turn_index = (active_turn_index + 1) % active_heroes.size()

func find_matches() -> Dictionary:
	var found := {}
	for row in BOARD_SIZE:
		var run_start := 0
		for col in range(1, BOARD_SIZE + 1):
			if col < BOARD_SIZE and board[row][col] == board[row][run_start]:
				continue
			if col - run_start >= 3:
				for mark in range(run_start, col):
					found[Vector2i(mark, row)] = true
			run_start = col
	for col in BOARD_SIZE:
		var run_start := 0
		for row in range(1, BOARD_SIZE + 1):
			if row < BOARD_SIZE and board[row][col] == board[run_start][col]:
				continue
			if row - run_start >= 3:
				for mark in range(run_start, row):
					found[Vector2i(col, mark)] = true
			run_start = row
	# Kwadrat 2x2 jest osobną kombinacją i nie musi tworzyć linii trzech.
	for row in range(BOARD_SIZE - 1):
		for col in range(BOARD_SIZE - 1):
			var square_type: int = int(board[row][col])
			if square_type >= 0 and board[row][col + 1] == square_type and board[row + 1][col] == square_type and board[row + 1][col + 1] == square_type:
				found[Vector2i(col, row)] = true
				found[Vector2i(col + 1, row)] = true
				found[Vector2i(col, row + 1)] = true
				found[Vector2i(col + 1, row + 1)] = true
	return found

func clear_move_preview() -> void:
	move_preview_target = Vector2i(-1, -1)
	move_preview_cells.clear()
	move_preview_text = ""

func refresh_move_preview() -> void:
	clear_move_preview()
	if selected_cell.x < 0 or selected_cell.y < 0 or selected_cell.x >= BOARD_SIZE or selected_cell.y >= BOARD_SIZE:
		return
	var best_count := 0
	var best_counts := [0, 0, 0, 0, 0]
	for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var candidate: Vector2i = selected_cell + direction
		if candidate.x < 0 or candidate.y < 0 or candidate.x >= BOARD_SIZE or candidate.y >= BOARD_SIZE:
			continue
		swap_tiles(selected_cell, candidate)
		var matches := find_matches()
		if matches.size() > best_count:
			best_count = matches.size()
			move_preview_target = candidate
			move_preview_cells = matches.duplicate()
			best_counts = [0, 0, 0, 0, 0]
			for key in matches:
				var match_cell: Vector2i = key
				var tile_type: int = int(board[match_cell.y][match_cell.x])
				if tile_type >= 0 and tile_type < best_counts.size():
					best_counts[tile_type] += 1
		swap_tiles(selected_cell, candidate)
	if best_count == 0:
		move_preview_text = "Brak połączenia przy tym znaku."
		return
	var effects: Array[String] = []
	if best_counts[0] > 0:
		effects.append("ogień ×%d: obrażenia" % best_counts[0])
	if best_counts[1] > 0:
		effects.append("woda ×%d: leczenie" % best_counts[1])
	if best_counts[2] > 0:
		effects.append("liście ×%d: tarcza" % best_counts[2])
	if best_counts[3] > 0:
		effects.append("bursztyn ×%d: obrażenia" % best_counts[3])
	if best_counts[4] > 0:
		effects.append("runy ×%d: obrażenia i osłabienie" % best_counts[4])
	move_preview_text = "Podgląd: %d znaków • %s" % [best_count, " • ".join(effects)]

func collapse_board() -> void:
	# Zachowaj pozycje istniejących kafelków, aby mogły płynnie opaść na wolne miejsca.
	for col in BOARD_SIZE:
		var destination := BOARD_SIZE - 1
		for row in range(BOARD_SIZE - 1, -1, -1):
			if board[row][col] >= 0:
				var fall_distance := destination - row
				if fall_distance > 0:
					tile_offsets[Vector2i(col, destination)] = Vector2(0, -fall_distance)
				destination -= 1
		for row in range(destination, -1, -1):
			tile_offsets[Vector2i(col, row)] = Vector2(0, -(destination - row + 1))
	for col in BOARD_SIZE:
		var kept: Array[Dictionary] = []
		for row in range(BOARD_SIZE - 1, -1, -1):
			if board[row][col] >= 0:
				kept.append({"type": int(board[row][col]), "special": int(special_tiles[row][col])})
		var row := BOARD_SIZE - 1
		for tile_data in kept:
			board[row][col] = int(tile_data["type"])
			special_tiles[row][col] = int(tile_data["special"])
			row -= 1
		while row >= 0:
			board[row][col] = randi_range(0, TILE_TYPES - 1)
			special_tiles[row][col] = 0
			row -= 1

func swap_tiles(a: Vector2i, b: Vector2i) -> void:
	var saved: int = board[a.y][a.x]
	board[a.y][a.x] = board[b.y][b.x]
	board[b.y][b.x] = saved
	var saved_special: int = int(special_tiles[a.y][a.x])
	special_tiles[a.y][a.x] = int(special_tiles[b.y][b.x])
	special_tiles[b.y][b.x] = saved_special

func board_rect() -> Rect2:
	var width := minf(get_viewport_rect().size.x - 120.0, 400.0)
	return Rect2((get_viewport_rect().size.x - width) / 2.0, 350.0, width, width)

func enemy_card_rect(index: int) -> Rect2:
	var enemy_count := maxi(1, enemies.size())
	var gap := 8.0
	var card_width := minf(165.0, (get_viewport_rect().size.x - 32.0 - gap * float(enemy_count - 1)) / float(enemy_count))
	var group_width := card_width * float(enemy_count) + gap * float(enemy_count - 1)
	var start_x := (get_viewport_rect().size.x - group_width) * 0.5
	return Rect2(start_x + index * (card_width + gap), 94.0, card_width, 192.0)

func enemy_guard_icon_rect(index: int) -> Rect2:
	var card := enemy_card_rect(index)
	return Rect2(card.get_center().x - 18.0, card.position.y + 44.0, 36.0, 36.0)

func enemy_guard_help_rect() -> Rect2:
	var screen := get_viewport_rect().size
	var width := minf(screen.x - 56.0, 420.0)
	# Proporcje ilustracji 3:2 zachowują pełną ramę, bez obcinania korzeni.
	return Rect2((screen.x - width) * 0.5, 116.0, width, width * 2.0 / 3.0)

func enemy_guard_help_close_rect() -> Rect2:
	var panel := enemy_guard_help_rect()
	var layout_scale := panel.size.x / 420.0
	return Rect2(panel.end.x - 67.0 * layout_scale - 30.0, panel.position.y + 40.0 * layout_scale + 40.0, 34.0, 34.0)

func boss_portrait_for(name: String) -> Texture2D:
	if enemy_portraits.has(name):
		return enemy_portraits[name]
	if name.contains("Leszy"):
		return leszy_portrait
	if name.contains("Wilk"):
		return wilk_cienia_portrait
	if name.to_lower().contains("duch dębu") or name.to_lower().contains("duch debu"):
		return enemy_portraits.get("Duch dębu", null)
	if name.to_lower().contains("stary leszy"):
		return leszy_portrait
	if name.contains("Rusałka"):
		return rusalka_portrait
	if name.contains("Topiel") or name.contains("Głębin") or name.contains("Utopiec"):
		return enemy_portraits.get("Król Topielców", rusalka_portrait)
	if name.contains("Żmij"):
		return zmij_portrait
	if name.contains("Lod") or name.contains("Szron") or name.contains("Zim") or name.contains("Marzann"):
		return pan_zimnych_mgiel_portrait
	if name.contains("Królowa Kurhanów"):
		return krolowa_kurhanow_portrait
	if name.contains("Przewoźnik") or name.contains("Kurhan") or name.contains("Nawij"):
		return krolowa_kurhanow_portrait
	if name.contains("Pan Zimnych Mgieł"):
		return pan_zimnych_mgiel_portrait
	if name.contains("Władca Kruczych Znaków"):
		return wladca_kruczych_znakow_portrait
	if name.contains("Równowagi") or name.contains("Złoty") or name.contains("Świetlist") or name.contains("Przysięgi"):
		return wladca_kruczych_znakow_portrait
	if name.contains("Niedźwiedź Gromu"):
		return niedzwiedz_gromu_portrait
	if name.contains("Biała Pani Młynów"):
		return biala_pani_mlynow_portrait
	# Każda karta wroga musi zachować ilustrację — nawet gdy późniejsza
	# aktualizacja doda nazwę bez własnego portretu.
	return leszy_portrait

func point_to_cell(point: Vector2) -> Vector2i:
	var rect := board_rect()
	if not rect.has_point(point):
		return Vector2i(-1, -1)
	var cell_size := rect.size.x / BOARD_SIZE
	return Vector2i(int((point.x - rect.position.x) / cell_size), int((point.y - rect.position.y) / cell_size))

func restart_rect() -> Rect2:
	# Przyciski są aktywne tylko w modalu wyniku. Wyższa forma lepiej pasuje
	# do ozdobnej tablicy i pozostaje wygodna na ekranie dotykowym.
	return Rect2(get_viewport_rect().size.x / 2.0 - 150.0, 610.0, 300.0, 56.0)

func defeat_training_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 150.0, 674.0, 300.0, 56.0)

func rewarded_coin_bonus_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 150.0, 552.0, 300.0, 46.0)

func result_modal_rect() -> Rect2:
	return Rect2(12.0, 280.0, get_viewport_rect().size.x - 24.0, 460.0)

func victory_continue_rect() -> Rect2:
	var screen := get_viewport_rect().size
	return Rect2(screen.x * 0.5 - 150.0, screen.y - 76.0, 300.0, 62.0)

func previous_rect() -> Rect2:
	return Rect2(24.0, 902.0, 160.0, 42.0)

func next_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 184.0, 902.0, 160.0, 42.0)

func lada_skill_rect() -> Rect2:
	return Rect2(20.0, 792.0, 160.0, 72.0)

func brun_skill_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 80.0, 792.0, 160.0, 72.0)

func mieta_skill_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 180.0, 792.0, 160.0, 72.0)

func hero_battle_rect(index: int) -> Rect2:
	if active_heroes.size() == 1:
		return Rect2(get_viewport_rect().size.x / 2.0 - 80.0, 796.0, 160.0, 72.0)
	return [lada_skill_rect(), brun_skill_rect(), mieta_skill_rect()][index]

func hero_active_skill_rect(branch: int) -> Rect2:
	var screen_width := get_viewport_rect().size.x
	var group_width := minf(360.0, screen_width - 54.0)
	var width := group_width / 3.0
	var group_left := (screen_width - group_width) * 0.5
	return Rect2(group_left + branch * width, 884.0, width, 68.0)

func hero_active_skill_cost(branch: int) -> int:
	return [4, 6, 8][clampi(branch, 0, 2)]

func hero_active_skill_rank(hero_id: String, branch: int) -> int:
	return SkillTree.branch_total(hero_trees.get(hero_id, {}), branch)

func enemy_target_rect(index: int) -> Rect2:
	return enemy_card_rect(index)

func pause_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 66.0, 4.0, 58.0, 58.0)

func hammer_rect() -> Rect2:
	return Rect2((get_viewport_rect().size.x - 300.0) / 2.0, 898.0, 90.0, 50.0)

func bolt_booster_rect() -> Rect2:
	return Rect2((get_viewport_rect().size.x - 300.0) / 2.0 + 125.0, 898.0, 90.0, 50.0)

func gale_booster_rect() -> Rect2:
	return Rect2((get_viewport_rect().size.x - 300.0) / 2.0 + 250.0, 898.0, 90.0, 50.0)

func roster_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 207.0, 112.0, 175.0, 30.0)

func village_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 207.0, 147.0, 175.0, 30.0)

func roster_close_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 92.0, 884.0, 184.0, 42.0)

func roster_detail_rect() -> Rect2:
	return Rect2(22, 280, get_viewport_rect().size.x - 44, 492)

func roster_upgrade_rect() -> Rect2:
	return Rect2(262.0, 676.0, 283.0, 62.0)

func roster_upgrade_tutorial_hero_id() -> String:
	var step: String = player_opening.home_tutorial_step
	if not step.begins_with("upgrade_") or not step.ends_with("_roster"):
		return ""
	var hero_id: String = step.substr(8, step.length() - 15)
	return hero_id if HERO_IDS.has(hero_id) else ""

func home_upgrade_tutorial_hero_id() -> String:
	var step: String = player_opening.home_tutorial_step
	if not step.begins_with("upgrade_") or step.ends_with("_roster"):
		return ""
	var hero_id: String = step.substr(8)
	return hero_id if HERO_IDS.has(hero_id) else ""

func talent_tutorial_active() -> bool:
	return player_opening.home_tutorial_step == "talent_lada_tree"

func talent_roster_tutorial_active() -> bool:
	return player_opening.home_tutorial_step == "talent_lada_roster"

func roster_skill_tree_rect() -> Rect2:
	return Rect2(110.0, 744.0, get_viewport_rect().size.x - 220.0, 70.0)

func skill_tree_node_rect(branch: int, tier: int) -> Rect2:
	return Rect2(24.0 + branch * 168.0, 600.0 - tier * 130.0, 156.0, 102.0)

func skill_tree_back_rect() -> Rect2:
	# Przycisk jest odsunięty od dolnej krawędzi, tak jak pozostałe akcje.
	return Rect2(178.0, 916.0, 184.0, 40.0)

func skill_tree_upgrade_rect() -> Rect2:
	return Rect2(114.0, 848.0, 312.0, 62.0)

func roster_team_toggle_rect() -> Rect2:
	# Liściasty przycisk celowo zachodzi na dolną krawędź sylwetki bohatera.
	return Rect2(30.0, 644.0, 240.0, 76.0)

func roster_filter_rect(index: int) -> Rect2:
	# Szersze zakładki mieszczą nazwy, ale zachowują jeden równy rytm na telefonie.
	var positions := [5.0, 137.0, 269.0, 401.0]
	return Rect2(positions[index], 200.0, 132.0, 55.0)

func roster_previous_page_rect() -> Rect2:
	return Rect2(166.0, 832.0, 48.0, 40.0)

func roster_next_page_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 214.0, 832.0, 48.0, 40.0)

func roster_filter_ids() -> Array[String]:
	var filtered: Array[String] = []
	for hero_id in HERO_IDS:
		if roster_filter == "all" or str(HERO_CLASSES[hero_id]) == roster_filter:
			filtered.append(hero_id)
	return filtered

func selected_roster_hero_id() -> String:
	var filtered := roster_filter_ids()
	if filtered.is_empty():
		return "lada"
	roster_hero_index = posmod(roster_hero_index, filtered.size())
	return filtered[roster_hero_index]

func roster_filter_label(filter_id: String) -> String:
	match filter_id:
		"ZWYKŁA": return "STRAŻ GAJU"
		"PREMIUM": return "WYBRAŃCY"
		"LEGENDA": return "LEGENDY"
	return "CAŁY KRĄG"

func roster_filter_display_label(filter_id: String) -> String:
	match filter_id:
		"ZWYKŁA": return "STRAŻ\nGAJU"
		"PREMIUM": return "WYBRANI\nPERUNA"
		"LEGENDA": return "DAWNE\nLEGENDY"
	return "CAŁY\nKRĄG"

func hero_name(hero_id: String) -> String:
	var index := HERO_IDS.find(hero_id)
	return HERO_NAMES[index] if index >= 0 else hero_id.capitalize()

func hero_recruit_currency(hero_id: String) -> String:
	match str(HERO_CLASSES.get(hero_id, "ZWYKŁA")):
		"PREMIUM": return "sparks"
		"LEGENDA": return "marks"
	return "coins"

func village_close_rect() -> Rect2:
	var screen := get_viewport_rect().size
	return Rect2(screen.x - 174.0, screen.y - 68.0, 164.0, 50.0)

func village_expeditions_rect() -> Rect2:
	return Rect2(12.0, get_viewport_rect().size.y - 68.0, minf(190.0, get_viewport_rect().size.x - 200.0), 50.0)

func village_next_goal_rect() -> Rect2:
	var width := minf(440.0, get_viewport_rect().size.x - 28.0)
	return Rect2((get_viewport_rect().size.x - width) * 0.5, 116.0, width, 81.0 * width / 440.0)

func open_forest_expeditions() -> void:
	forest_catalog_open = true
	training_scroll = 0.0
	training_open = true
	village_open = false
	village_selected_id = ""
	main_menu_open = false
	queue_redraw()

func village_next_target() -> String:
	var hall_level := int(building_levels.get("dwor_wiecowy", 0))
	if hall_level >= MAX_BUILDING_LEVEL:
		for building_id in BUILDING_IDS:
			if int(building_levels.get(building_id, 0)) < MAX_BUILDING_LEVEL:
				return building_id
		return "dwor_wiecowy"
	var missing := VillageProgression.missing_requirements("dwor_wiecowy", building_levels)
	if not missing.is_empty():
		var target: String = str(missing.keys()[0])
		var prerequisite := VillageProgression.campaign_milestone(target, building_levels)
		return "campaign" if prerequisite > 0 and int(level_stars.get(prerequisite, 0)) == 0 else target
	var milestone := VillageProgression.campaign_milestone("dwor_wiecowy", building_levels)
	return "campaign" if milestone > 0 and int(level_stars.get(milestone, 0)) == 0 else "dwor_wiecowy"

func village_next_goal_text() -> String:
	var hall_level := int(building_levels.get("dwor_wiecowy", 0))
	if hall_level == MAX_BUILDING_LEVEL and village_next_target() == "dwor_wiecowy":
		return "OSADA W PEŁNI ROZBUDOWANA\nZdobywaj mistrzostwa i tytuły osady na mapie."
	var target := village_next_target()
	if target == "campaign":
		return "CEL OSADY: ważny etap kampanii\nDotknij, aby przejść do mapy i odblokować rozbudowę."
	var index := BUILDING_IDS.find(target)
	var next_level := int(building_levels.get(target, 0)) + 1
	var cost := building_cost(target)
	var missing_coins := maxi(0, int(cost["coins"]) - coins)
	var missing_wood := maxi(0, int(cost["wood"]) - wood)
	var action := "Dotknij, aby rozbudować."
	if missing_wood > 0:
		action = "Brakuje %d drewna — wybierz WYPRAWY LEŚNE." % missing_wood
	elif missing_coins > 0:
		action = "Brakuje %d monet — zdobądź je w kampanii." % missing_coins
	return "CEL OSADY: %s • poziom %d\n%s" % [BUILDING_NAMES[index], next_level, action]

func village_inspector_rect() -> Rect2:
	var screen := get_viewport_rect().size
	var width := minf(350.0, screen.x - 70.0)
	var height := minf(380.0, screen.y * 0.46)
	if village_selected_id == "tartak" and int(building_levels.get("tartak", 0)) > 0:
		height += 64.0
	return Rect2(8.0, screen.y - height - 8.0, width, height)

func village_collect_wood_rect() -> Rect2:
	var panel := village_inspector_rect()
	return Rect2(panel.position.x + 42.0, panel.end.y - 218.0, panel.size.x - 84.0, 44.0)

func village_sawmill_stock_rect() -> Rect2:
	var building := village_building_rect("tartak")
	var width := minf(152.0, get_viewport_rect().size.x * 0.38)
	return Rect2(building.get_center().x - width * 0.5, village_building_label_rect("tartak").end.y + 1.0, width, 38.0)

func village_inspector_close_rect() -> Rect2:
	var panel := village_inspector_rect()
	return Rect2(panel.end.x - 68.0, panel.position.y + 22.0, 48.0, 48.0)

func village_upgrade_rect() -> Rect2:
	var panel := village_inspector_rect()
	return Rect2(panel.position.x + 42.0, panel.end.y - 64.0, panel.size.x - 84.0, 49.0)

func village_building_rect(building_id: String) -> Rect2:
	var screen := get_viewport_rect().size
	var center := Vector2(270.0, 470.0)
	var dimensions := Vector2(150.0, 150.0)
	match building_id:
		"domostwa":
			center = Vector2(100.0, 228.0)
			dimensions = Vector2(122.0, 122.0)
		"swiety_gaj":
			center = Vector2(266.0, 219.0)
			dimensions = Vector2(122.0, 128.0)
		"wieza_peruna":
			center = Vector2(449.0, 239.0)
			dimensions = Vector2(104.0, 158.0)
		"kuznia":
			center = Vector2(85.0, 405.0)
			dimensions = Vector2(122.0, 116.0)
		"chata_zielarki":
			center = Vector2(452.0, 405.0)
			dimensions = Vector2(120.0, 120.0)
		"spichlerz":
			center = Vector2(425.0, 572.0)
			dimensions = Vector2(126.0, 134.0)
		"tartak":
			center = Vector2(126.0, 572.0)
			dimensions = Vector2(142.0, 134.0)
		"dwor_wiecowy":
			center = Vector2(270.0, 418.0)
			dimensions = Vector2(142.0, 142.0)
	var scale_factor := minf(screen.x / 540.0, screen.y / 960.0)
	var size := dimensions * scale_factor
	var position := Vector2(center.x * screen.x / 540.0, center.y * screen.y / 960.0) - size * 0.5
	return Rect2(position, size)

func village_building_label_rect(building_id: String) -> Rect2:
	var building := village_building_rect(building_id)
	var width := minf(132.0, get_viewport_rect().size.x * 0.32)
	return Rect2(building.get_center().x - width * 0.5, building.end.y - 5.0, width, 33.0)

func map_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 178.0, 34.0, 98.0, 32.0)

func map_close_rect() -> Rect2:
	var screen := get_viewport_rect().size
	var button_size := Vector2(248.0, 64.0)
	return Rect2(Vector2((screen.x - button_size.x) / 2.0, screen.y - button_size.y - 24.0), button_size)

func map_previous_page_rect() -> Rect2:
	var screen := get_viewport_rect().size
	var button_width := minf(189.0, screen.x - 16.0)
	return Rect2(8.0, 189.5, button_width, 45.0)

func map_next_page_rect() -> Rect2:
	var screen := get_viewport_rect().size
	var button_width := minf(189.0, screen.x - 16.0)
	return Rect2(screen.x - button_width - 8.0, 189.5, button_width, 45.0)

func map_level_rect(index: int) -> Rect2:
	var screen := get_viewport_rect().size
	var positions := [Vector2(0.50, 0.755), Vector2(0.27, 0.625), Vector2(0.70, 0.495), Vector2(0.33, 0.365), Vector2(0.64, 0.235)]
	var center: Vector2 = positions[index] * screen
	center.y += 50.0
	var level_id := map_page * 5 + index
	var radius := 62.0 if level_id < levels.size() and is_boss_level(levels[level_id]) else 44.0
	return Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2.0)

func map_has_unlocked_next_page() -> bool:
	return map_page < int(maxi(0, campaign_frontier_count() - 1) / 5)

func boss_star_gate_status(boss_index: int) -> Dictionary:
	var previous_count := mini(4, boss_index)
	var required_stars := previous_count # Zwycięstwa wystarczą; mistrzostwo jest opcjonalne.
	var earned_stars := 0
	for offset in previous_count:
		var previous_level: Dictionary = levels[boss_index - previous_count + offset]
		var previous_id := int(previous_level.get("id", boss_index - previous_count + offset + 1))
		earned_stars += int(level_stars.get(previous_id, 0))
	return {"earned": earned_stars, "required": required_stars, "count": previous_count, "unlocked": previous_count > 0 and earned_stars >= required_stars}

func campaign_frontier_count() -> int:
	var available_count := mini(unlocked_level, levels.size())
	for index in available_count:
		if is_boss_level(levels[index]) and not bool(boss_star_gate_status(index).get("unlocked", false)):
			return index
	return available_count

func campaign_level_is_accessible(index: int) -> bool:
	return index >= 0 and index < unlocked_level and index < campaign_frontier_count()

func boss_star_gate_message(boss_index: int) -> String:
	var gate := boss_star_gate_status(boss_index)
	return "Ukończ %d poprzednie etapy, aby ruszyć na bossa. Gwiazdki: %d/%d." % [int(gate.get("count", 0)), int(gate.get("earned", 0)), int(gate.get("required", 0))]

func region_display_name(region_id: String) -> String:
	var labels := {"debowepogranicze": "Dębowe Pogranicze", "swiety_gaj": "Święty Gaj", "bagna_welesa": "Bagna Welesa", "gory_peruna": "Góry Peruna", "nawia": "Cienie Nawii", "prawia": "Prawia", "grzmotne_szczyty": "Grzmotne Szczyty", "jeziora_rusalek": "Jeziora Rusałek", "ziemie_marzanny": "Ziemie Marzanny", "kraina_zmijow": "Kraina Żmijów", "korona_drzewa": "Korona Drzewa Świata"}
	return str(labels.get(region_id, "Nieznana kraina"))

func level_difficulty_label(level_id: int) -> String:
	if level_id <= 10:
		return "ŁATWY"
	if level_id <= 25:
		return "SPOKOJNY"
	if level_id <= 45:
		return "WYMAGAJĄCY"
	if level_id <= 100:
		return "TRUDNY"
	if level_id <= 500:
		return "MISTRZOWSKI"
	return "LEGENDARNY"

func level_difficulty_color(level_id: int) -> Color:
	if level_id <= 10:
		return Color("#8fd37b")
	if level_id <= 25:
		return Color("#e4ca79")
	if level_id <= 45:
		return Color("#e59a5a")
	if level_id <= 100:
		return Color("#dc6d6a")
	if level_id <= 500:
		return Color("#c96edc")
	return Color("#e9b95b")

func level_kind_label(level: Dictionary) -> String:
	var level_id := int(level.get("id", 0))
	if level_id > 100 and level_id % 50 == 0:
		return "WIELKI BOSS"
	if level_id > 100 and level_id % 25 == 0:
		return "STRAŻNIK KRAINY"
	if level_id <= 100 and is_boss_level(level):
		return "BOSS"
	match str(level.get("goal_type", "defeat_enemy")):
		"clear_obstacles": return "OCZYSZCZENIE"
		"collect_amber": return "ZBIERANIE BURSZTYNU"
		"collect_rune": return "ZBIERANIE RUN"
		"survive": return "PRZETRWANIE"
		"score": return "PRÓBA WYNIKU"
	if level_id % 5 == 0:
		return "WYPRAWA SPECJALNA"
	return "WYPRAWA"

func level_kind_color(level: Dictionary) -> Color:
	var label := level_kind_label(level)
	if label == "WIELKI BOSS":
		return Color("#ffbd68")
	if label == "BOSS":
		return Color("#ffbd68")
	if label == "STRAŻNIK KRAINY":
		return Color("#f2d783")
	if label == "PRZETRWANIE":
		return Color("#e88876")
	if label == "OCZYSZCZENIE":
		return Color("#88d7a1")
	if label.begins_with("ZBIERANIE"):
		return Color("#73cddd")
	return Color("#c7ddba")

func booster_close_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 75.0, 590.0, 150.0, 36.0)

func booster_choice_rect(index: int) -> Rect2:
	return Rect2(70.0, 254.0 + index * 100.0, get_viewport_rect().size.x - 140.0, 76.0)

func main_menu_play_rect() -> Rect2:
	return Rect2(79.0, 568.0, get_viewport_rect().size.x - 158.0, 104.0)

func main_menu_party_rect() -> Rect2:
	return Rect2(20.0, 375.0, get_viewport_rect().size.x - 40.0, 188.0)

func daily_reward_rect() -> Rect2:
	return Rect2(20.0, 724.0, get_viewport_rect().size.x - 40.0, 112.0)

func daily_reward_base_rect() -> Rect2:
	var shelf := daily_reward_rect()
	return Rect2(shelf.position, Vector2(shelf.size.x * 0.75, shelf.size.y))

func daily_reward_premium_rect() -> Rect2:
	var shelf := daily_reward_rect()
	return Rect2(shelf.position.x + shelf.size.x * 0.75, shelf.position.y, shelf.size.x * 0.25, shelf.size.y)

func daily_reward_popup_rect() -> Rect2:
	var screen := get_viewport_rect().size
	return Rect2((screen.x - 480.0) * 0.5, 276.0, 480.0, 430.0)

func daily_reward_popup_ad_rect() -> Rect2:
	var width := get_viewport_rect().size.x - 130.0
	return Rect2(65.0, 575.0, width, 67.0)

func daily_reward_popup_close_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x * 0.5 - 132.0, 648.0, 264.0, 48.0)

func daily_reward_banner_rect() -> Rect2:
	return Rect2(106.0, 690.0, get_viewport_rect().size.x - 212.0, 32.0)

func main_menu_nav_rect(index: int) -> Rect2:
	var screen := get_viewport_rect().size
	var item_width := minf(74.0, (screen.x - 72.0) / 6.0)
	var side_margin := (screen.x - item_width * 6.0) * 0.5
	return Rect2(side_margin + index * item_width, 837.0, item_width, 123.0)

func main_menu_map_rect() -> Rect2:
	return main_menu_nav_rect(0)

func main_menu_roster_rect() -> Rect2:
	return main_menu_nav_rect(1)

func main_menu_village_rect() -> Rect2:
	return main_menu_nav_rect(2)

func main_menu_training_rect() -> Rect2:
	return main_menu_nav_rect(3)

func main_menu_shop_rect() -> Rect2:
	return main_menu_nav_rect(4)

func main_menu_missions_rect() -> Rect2:
	return main_menu_nav_rect(5)

func missions_close_rect() -> Rect2:
	var screen := get_viewport_rect().size
	return Rect2(screen.x * 0.5 - 118.0, screen.y - 76.0, 236.0, 48.0)

func mission_claim_rect(top: float) -> Rect2:
	return Rect2(get_viewport_rect().size.x - 136.0, top + 55.0, 108.0, 30.0)

func help_button_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 72.0, 120.0, 62.0, 62.0)

func settings_button_rect() -> Rect2:
	return Rect2(14.0, 248.0, 160.0, 44.0)

func bestiary_button_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 74.0, 184.0, 64.0, 68.0)

func bestiary_close_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 115.0, 868.0, 230.0, 48.0)

func bestiary_region_previous_rect() -> Rect2:
	return Rect2(25.0, 133.0, 48.0, 40.0)

func bestiary_region_next_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 73.0, 133.0, 48.0, 40.0)

func bestiary_page_previous_rect() -> Rect2:
	return Rect2(166.0, 754.0, 48.0, 40.0)

func bestiary_page_next_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 214.0, 754.0, 48.0, 40.0)

func bestiary_current_region() -> String:
	if bestiary_regions.is_empty():
		return "debowepogranicze"
	return bestiary_regions[clampi(bestiary_region_index, 0, bestiary_regions.size() - 1)]

func bestiary_page_count(region_id: String) -> int:
	return maxi(1, int(ceil(float(bestiary_enemy_names(region_id).size()) / 6.0)))

func help_close_rect() -> Rect2:
	if settings_open:
		return Rect2(get_viewport_rect().size.x * .5 - 135.0, get_viewport_rect().size.y * .5 + 180.0, 270.0, 48.0)
	return Rect2(get_viewport_rect().size.x / 2.0 - 120.0, 764.0, 240.0, 48.0)

func sound_toggle_rect() -> Rect2:
	if settings_open:
		return audio_setting_rect(0)
	return Rect2(get_viewport_rect().size.x / 2.0 - 120.0, 702.0, 240.0, 46.0)

func audio_setting_rect(index: int) -> Rect2:
	var screen := get_viewport_rect().size
	var width := minf(330.0, screen.x - 48.0)
	return Rect2((screen.x - width) * .5, screen.y * .5 - 100.0 + index * 60.0, width, 46.0)

func music_toggle_rect() -> Rect2:
	return audio_setting_rect(1)

func vibration_toggle_rect() -> Rect2:
	return audio_setting_rect(2)

func settings_guide_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x * .5 - 135.0, get_viewport_rect().size.y * .5 + 122.0, 270.0, 46.0)

func training_close_rect() -> Rect2:
	if forest_catalog_open:
		return Rect2(get_viewport_rect().size.x * 0.5 - 124.0, get_viewport_rect().size.y - 68.0, 248.0, 56.0)
	# Zachowaj proporcje ozdobnej belki: +40 px szerokości skaluje też wysokość.
	return Rect2(get_viewport_rect().size.x / 2.0 - 95.0, get_viewport_rect().size.y - 65.0, 190.0, 48.0)

func training_choice_rect(index: int) -> Rect2:
	if forest_catalog_open:
		return forest_expeditions_view.card_rect(get_viewport_rect().size, index, training_scroll)
	return Rect2(42.0, 158.0 + index * 118.0 - training_scroll, get_viewport_rect().size.x - 84.0, 112.0)

func training_scroll_max() -> float:
	if forest_catalog_open:
		return forest_expeditions_view.scroll_max(get_viewport_rect().size, training_catalog().size())
	return maxf(0.0, float(training_catalog().size() * 118) - (get_viewport_rect().size.y - 240.0))

func training_catalog() -> Array:
	return ForestExpeditions.catalog(building_levels) if forest_catalog_open else TRAINING_BATTLES

func training_choice_locked(battle: Dictionary) -> bool:
	return int(battle.get("hall", 0)) > int(building_levels.get("dwor_wiecowy", 0)) if bool(battle.get("expedition", false)) else int(battle.get("required_level", 1)) > unlocked_level

func visible_training_indices() -> Array[int]:
	var unlocked: Array[int] = []
	for index in TRAINING_BATTLES.size():
		if int(TRAINING_BATTLES[index].get("required_level", 1)) <= unlocked_level:
			unlocked.append(index)
	var first := maxi(0, unlocked.size() - 3)
	var visible: Array[int] = []
	for index in range(first, unlocked.size()):
		visible.append(unlocked[index])
	return visible

func display_training_indices() -> Array[int]:
	var available := visible_training_indices()
	var display: Array[int] = available.duplicate()
	var next_index := available.size()
	while display.size() < 3 and next_index < TRAINING_BATTLES.size():
		display.append(next_index)
		next_index += 1
	return display

func building_cost(building_id: String) -> Dictionary:
	var bases := {
		"domostwa": {"coins": 500, "wood": 80}, "kuznia": {"coins": 800, "wood": 120},
		"chata_zielarki": {"coins": 600, "wood": 60}, "swiety_gaj": {"coins": 1000, "wood": 100},
		"spichlerz": {"coins": 550, "wood": 90}, "wieza_peruna": {"coins": 1200, "wood": 140},
		"tartak": {"coins": 350, "wood": 35}, "dwor_wiecowy": {"coins": 800, "wood": 100}
	}
	var base: Dictionary = bases[building_id]
	var current := float(building_levels[building_id])
	var multiplier := 1.0 + current * 0.25 + current * current * 0.008
	if (building_id == "tartak" and int(building_levels.get("tartak", 0)) == 0) or first_building_upgrade_free():
		return {"coins": 0, "wood": 0}
	return {"coins": int(round(int(base["coins"]) * multiplier)), "wood": int(round(int(base["wood"]) * multiplier))}

func first_building_upgrade_free() -> bool:
	for building_id in BUILDING_IDS:
		if int(building_levels.get(building_id, 0)) > 0:
			return false
	return true

func building_level_cap() -> int:
	return VillageProgression.level_cap(building_levels)

func building_requirement_text(building_id: String) -> String:
	var missing := VillageProgression.missing_requirements(building_id, building_levels)
	var labels: Array[String] = []
	for required_id in missing:
		var index := BUILDING_IDS.find(required_id)
		labels.append("%s %d/%d" % [BUILDING_NAMES[index], int(building_levels.get(required_id, 0)), int(missing[required_id])])
	var milestone := VillageProgression.campaign_milestone(building_id, building_levels)
	if milestone > 0 and int(level_stars.get(milestone, 0)) == 0:
		labels.append("Ukończ etap %d kampanii" % milestone)
	return "\n".join(labels)

func try_upgrade_building(building_id: String) -> bool:
	var building_index := BUILDING_IDS.find(building_id)
	if building_index < 0:
		return false
	if int(building_levels.get(building_id, 0)) >= MAX_BUILDING_LEVEL:
		message = "%s: maksymalny poziom %d." % [BUILDING_NAMES[building_index], MAX_BUILDING_LEVEL]
		return false
	var requirements := building_requirement_text(building_id)
	if not requirements.is_empty():
		message = "Wymagania: %s" % requirements.replace("\n", "; ")
		return false
	var cost := building_cost(building_id)
	if coins < int(cost["coins"]) or wood < int(cost["wood"]):
		message = "Brakuje zasobów na %s." % BUILDING_NAMES[building_index]
		return false
	coins -= int(cost["coins"])
	wood -= int(cost["wood"])
	balance_stats["coins_buildings"] = int(balance_stats.get("coins_buildings", 0)) + int(cost["coins"])
	balance_stats["wood_buildings"] = int(balance_stats.get("wood_buildings", 0)) + int(cost["wood"])
	building_levels[building_id] = int(building_levels[building_id]) + 1
	sync_party_battle_health()
	balance_stats["building_upgrades"] = int(balance_stats.get("building_upgrades", 0)) + 1
	balance_stats["last_upgrade_active_seconds"] = int(balance_stats.get("active_seconds", 0))
	save_progress()
	message = "%s osiąga poziom %d." % [BUILDING_NAMES[building_index], building_levels[building_id]]
	play_audio_event("village_upgrade_sting", 780.0, 0.25, 0.18)
	return true

func upgrade_cost(hero_id: String) -> int:
	if hero_id == "lada" and int(hero_levels.get(hero_id, 0)) == 1:
		return 0
	return 300 + (int(hero_levels[hero_id]) - 1) * 100

func handle_roster_input(position: Vector2) -> void:
	var forced_upgrade_hero_id := roster_upgrade_tutorial_hero_id()
	if forced_upgrade_hero_id != "":
		if is_in_button(position, roster_close_rect()):
			player_opening.home_tutorial_step = "upgrade_%s" % forced_upgrade_hero_id
			roster_open = false
			main_menu_open = true
			queue_redraw()
			return
		if is_in_button(position, roster_upgrade_rect()):
			handle_roster_upgrade(forced_upgrade_hero_id)
			if int(hero_levels.get(forced_upgrade_hero_id, 1)) > 1:
				player_opening.home_tutorial_step = "talent_lada_roster"
				talent_tutorial_node_selected = false
				roster_open = true
				main_menu_open = false
				save_progress()
			queue_redraw()
		return
	if roster_swap_open:
		handle_roster_swap_input(position)
		return
	if talent_roster_tutorial_active():
		if is_in_button(position, roster_skill_tree_rect()):
			player_opening.home_tutorial_step = "talent_lada_tree"
			skill_tree_open = true
			skill_tree_selected_branch = 0
			skill_tree_selected_tier = 0
			talent_tutorial_node_selected = false
			save_progress()
			queue_redraw()
		return
	if skill_tree_open:
		handle_skill_tree_input(position)
		return
	if is_in_button(position, roster_close_rect()):
		roster_open = false
		main_menu_open = true
		queue_redraw()
		return
	var filters := ["all", "ZWYKŁA", "PREMIUM", "LEGENDA"]
	for filter_index in filters.size():
		if is_in_button(position, roster_filter_rect(filter_index)):
			roster_filter = str(filters[filter_index])
			roster_hero_index = 0
			queue_redraw()
			return
	var filtered := roster_filter_ids()
	if is_in_button(position, roster_previous_page_rect()) and not filtered.is_empty():
		begin_roster_transition(-1.0)
		roster_hero_index = posmod(roster_hero_index - 1, filtered.size())
		queue_redraw()
		return
	if is_in_button(position, roster_next_page_rect()) and not filtered.is_empty():
		begin_roster_transition(1.0)
		roster_hero_index = posmod(roster_hero_index + 1, filtered.size())
		queue_redraw()
		return
	var hero_id := selected_roster_hero_id()
	if is_in_button(position, roster_skill_tree_rect()):
		skill_tree_open = true
		skill_tree_selected_branch = 0
		skill_tree_selected_tier = 0
		queue_redraw()
		return
	if is_in_button(position, roster_team_toggle_rect()) and bool(owned_heroes[hero_id]):
		if active_heroes.has(hero_id):
			if active_heroes.size() > 1:
				active_heroes.erase(hero_id)
				message = "%s opuszcza skład." % hero_name(hero_id)
			else:
				message = "Skład musi mieć co najmniej jednego bohatera."
		elif active_heroes.size() < 3:
			active_heroes.append(hero_id)
			message = "%s dołącza do składu." % hero_name(hero_id)
		else:
			roster_swap_hero_id = hero_id
			roster_swap_return_hero_id = hero_id
			roster_swap_open = true
		sync_party_battle_health()
		save_progress()
		queue_redraw()
		return
	if not is_in_button(position, roster_upgrade_rect()):
		return
	handle_roster_upgrade(hero_id)

func begin_roster_transition(direction: float) -> void:
	roster_transition_from_id = selected_roster_hero_id()
	roster_transition_direction = direction
	roster_transition_time = 0.0

func handle_roster_upgrade(hero_id: String) -> void:
	if not bool(owned_heroes[hero_id]):
		var recruit_cost := int(HERO_RECRUIT_COSTS.get(hero_id, 0))
		var currency := hero_recruit_currency(hero_id)
		var available := event_marks if currency == "marks" else (perun_sparks if currency == "sparks" else coins)
		if available >= recruit_cost:
			if currency == "marks": event_marks -= recruit_cost
			elif currency == "sparks": perun_sparks -= recruit_cost
			else: coins -= recruit_cost
			owned_heroes[hero_id] = true
			hero_levels[hero_id] = maxi(1, int(hero_levels[hero_id]))
			hero_experience[hero_id] = 0
			hero_trees[hero_id] = {}
			if active_heroes.size() < 3: active_heroes.append(hero_id)
			sync_party_battle_health()
			message = "%s dołącza do drużyny!" % hero_name(hero_id)
		else:
			var currency_label := "Znaków Wydarzenia" if currency == "marks" else ("Iskier Peruna" if currency == "sparks" else "monet")
			message = "Brakuje %d %s na rekrutację %s." % [recruit_cost - available, currency_label, hero_name(hero_id)]
		save_progress()
		queue_redraw()
		return
	if int(hero_levels[hero_id]) >= MAX_HERO_LEVEL:
		message = "%s osiągnął maksymalny poziom %d." % [hero_name(hero_id), MAX_HERO_LEVEL]
		queue_redraw()
		return
	var cost := upgrade_cost(hero_id)
	var required_experience := hero_experience_to_next_level(hero_id)
	if int(hero_experience[hero_id]) < required_experience:
		message = "Brakuje %d PD do poziomu %d." % [required_experience - int(hero_experience[hero_id]), int(hero_levels[hero_id]) + 1]
	elif coins >= cost:
		coins -= cost
		hero_experience[hero_id] = int(hero_experience[hero_id]) - required_experience
		hero_levels[hero_id] = int(hero_levels[hero_id]) + 1
		sync_party_battle_health()
		save_progress()
		message = "%s osiąga poziom %d." % [hero_name(hero_id), hero_levels[hero_id]]
		play_audio_event("reward_reveal_common", 790.0, 0.16, 0.15)
	else:
		message = "Brakuje %d monet do ulepszenia %s." % [cost - coins, hero_name(hero_id)]
	queue_redraw()

func handle_roster_swap_input(position: Vector2) -> void:
	if is_in_button(position, roster_swap_cancel_rect()):
		roster_swap_open = false
		roster_swap_hero_id = ""
		roster_swap_return_hero_id = ""
		queue_redraw()
		return
	for index in active_heroes.size():
		var choice_rect := roster_swap_choice_rect(index)
		if is_in_button(position, choice_rect):
			active_heroes[index] = roster_swap_hero_id
			sync_party_battle_health()
			roster_swap_open = false
			message = "%s zastępuje bohatera w składzie." % hero_name(roster_swap_hero_id)
			roster_swap_hero_id = ""
			restore_roster_selection(roster_swap_return_hero_id)
			roster_swap_return_hero_id = ""
			roster_open = true
			main_menu_open = false
			map_open = false
			roster_transition_from_id = ""
			roster_transition_time = ROSTER_TRANSITION_DURATION
			save_progress()
			queue_redraw()
			return

func restore_roster_selection(hero_id: String) -> void:
	if hero_id == "":
		return
	var filtered := roster_filter_ids()
	var hero_index := filtered.find(hero_id)
	if hero_index >= 0:
		roster_hero_index = hero_index
		return
	roster_filter = str(HERO_CLASSES.get(hero_id, "all"))
	filtered = roster_filter_ids()
	hero_index = filtered.find(hero_id)
	if hero_index >= 0:
		roster_hero_index = hero_index

func handle_skill_tree_input(position: Vector2) -> void:
	var tutorial_active := talent_tutorial_active()
	if is_in_button(position, skill_tree_back_rect()):
		if tutorial_active:
			return
		skill_tree_open = false
		queue_redraw()
		return
	var hero_id := selected_roster_hero_id()
	if is_in_button(position, skill_tree_upgrade_rect()):
		if tutorial_active and not talent_tutorial_node_selected:
			queue_redraw()
			return
		if bool(owned_heroes.get(hero_id, false)):
			var tree: Dictionary = hero_trees.get(hero_id, {})
			if SkillTree.invest(tree, int(hero_levels[hero_id]), skill_tree_selected_branch, skill_tree_selected_tier):
				hero_trees[hero_id] = tree
				if skill_tree_selected_branch == 1 and skill_tree_selected_tier == 2 and active_heroes.has(hero_id) and state == "playing":
					hero_max_health[hero_id] = int(hero_max_health.get(hero_id, 0)) + 3
					hero_health[hero_id] = int(hero_health.get(hero_id, 0)) + 3
					refresh_party_health()
				if tutorial_active:
					player_opening.home_tutorial_step = "play_next"
					talent_tutorial_node_selected = false
					skill_tree_open = false
					roster_open = false
					main_menu_open = true
				save_progress()
				play_sfx(790.0, 0.14, 0.15)
		queue_redraw()
		return
	for branch in SkillTree.BRANCHES.size():
		for tier in SkillTree.RANK_CAPS.size():
			if not is_in_button(position, skill_tree_node_rect(branch, tier)):
				continue
			if tutorial_active and (branch != 0 or tier != 0):
				return
			skill_tree_selected_branch = branch
			skill_tree_selected_tier = tier
			if tutorial_active:
				talent_tutorial_node_selected = true
			queue_redraw()
			return

func handle_village_input(position: Vector2) -> void:
	if not village_tutorial_active() and village_selected_id == "":
		if is_in_button(position, village_expeditions_rect()):
			open_forest_expeditions()
			return
		if is_in_button(position, village_next_goal_rect()):
			var target := village_next_target()
			if target == "campaign":
				village_open = false
				map_open = true
				map_page = int(maxi(0, unlocked_level - 1) / 5)
			else:
				village_selected_id = target
			queue_redraw()
			return
	if village_upgrade_time > 0.0:
		return
	if village_tutorial_active():
		if player_opening.home_tutorial_step == "buy_sawmill":
			if is_in_button(position, village_close_rect()):
				village_open = false
				village_selected_id = ""
				main_menu_open = true
				queue_redraw()
				return
			village_selected_id = "tartak"
			if is_in_button(position, village_upgrade_rect()):
				var previous_level := int(building_levels.get("tartak", 0))
				if try_upgrade_building("tartak"):
					village_upgrade_id = "tartak"
					village_upgrade_from_level = previous_level
					village_upgrade_time = VILLAGE_UPGRADE_DURATION
					player_opening.home_tutorial_step = "sawmill_built"
					save_progress()
			queue_redraw()
			return
		if player_opening.home_tutorial_step == "sawmill_built":
			if village_selected_id == "tartak" and is_in_button(position, village_collect_wood_rect()):
				collect_sawmill_wood()
				return
			if village_selected_id != "" and is_in_button(position, village_inspector_close_rect()):
				player_opening.home_tutorial_step = ""
				village_selected_id = ""
				save_progress()
				queue_redraw()
				return
			if is_in_button(position, village_close_rect()):
				player_opening.home_tutorial_step = ""
				save_progress()
				village_open = false
				village_selected_id = ""
				main_menu_open = true
				queue_redraw()
			return
	if is_in_button(position, village_close_rect()):
		village_open = false
		village_selected_id = ""
		main_menu_open = true
		queue_redraw()
		return
	if village_selected_id != "":
		if is_in_button(position, village_inspector_close_rect()):
			village_selected_id = ""
			queue_redraw()
			return
		if village_selected_id == "tartak" and int(building_levels.get("tartak", 0)) > 0 and is_in_button(position, village_collect_wood_rect()):
			collect_sawmill_wood()
			return
		if is_in_button(position, village_upgrade_rect()):
			var previous_level := int(building_levels[village_selected_id])
			if try_upgrade_building(village_selected_id):
				village_upgrade_id = village_selected_id
				village_upgrade_from_level = previous_level
				village_upgrade_time = VILLAGE_UPGRADE_DURATION
			queue_redraw()
			return
		if is_in_button(position, village_inspector_rect()):
			return
	for building_id in BUILDING_IDS:
		var stock_clicked: bool = building_id == "tartak" and int(building_levels.get("tartak", 0)) > 0 and village_sawmill_stock_rect().has_point(position)
		if not stock_clicked and not village_building_rect(building_id).grow(7.0).has_point(position) and not village_building_label_rect(building_id).has_point(position):
			continue
		village_selected_id = building_id
		queue_redraw()
		return
	if village_selected_id != "":
		village_selected_id = ""
		queue_redraw()

func handle_map_input(position: Vector2) -> void:
	if map_transition_time < MAP_TRANSITION_DURATION:
		return
	if is_in_button(position, map_previous_page_rect()) and map_page > 0:
		start_map_page_transition(-1)
		return
	if is_in_button(position, map_next_page_rect()) and map_has_unlocked_next_page():
		start_map_page_transition(1)
		return
	if is_in_button(position, map_close_rect()):
		map_open = false
		main_menu_open = true
		map_drag_distance = 0.0
		map_was_dragged = false
		queue_redraw()
		return
	for slot in 5:
		if not is_in_button(position, map_level_rect(slot)):
			continue
		var index := map_page * 5 + slot
		if index >= levels.size():
			return
		if campaign_level_is_accessible(index):
			map_open = false
			start_level(index)
		elif index < unlocked_level and is_boss_level(levels[index]):
			message = boss_star_gate_message(index)
			queue_redraw()
		else:
			message = "Pokonaj wcześniejszego bossa i spełnij wymagania gwiazdek, aby ruszyć dalej."
			queue_redraw()
		return

func start_map_page_transition(direction: int) -> void:
	map_transition_from_page = map_page
	map_transition_direction = float(direction)
	var target_page := clampi(map_page + direction, 0, maxi(0, int(maxi(0, campaign_frontier_count() - 1) / 5)))
	map_transition_from_blur = create_blurred_map_texture(map_background_for_page(map_page))
	map_transition_to_blur = create_blurred_map_texture(map_background_for_page(target_page))
	map_page = target_page
	map_transition_time = 0.0
	queue_redraw()

func map_background_for_page(page: int) -> Texture2D:
	var focus_index := clampi(page * 5, 0, levels.size() - 1)
	var level: Dictionary = levels[focus_index] if not levels.is_empty() else {}
	return map_region_backgrounds.get(str(level.get("region", "debowepogranicze")), oak_borderland_background)

func create_blurred_map_texture(texture: Texture2D) -> Texture2D:
	if texture == null:
		return null
	var image := texture.get_image()
	if image == null or image.is_empty():
		return texture
	var original_size := image.get_size()
	image.resize(maxi(1, original_size.x / 12), maxi(1, original_size.y / 12), Image.INTERPOLATE_BILINEAR)
	image.resize(original_size.x, original_size.y, Image.INTERPOLATE_BILINEAR)
	return ImageTexture.create_from_image(image)

func handle_booster_input(position: Vector2) -> void:
	if is_in_button(position, booster_close_rect()):
		booster_open = false
		main_menu_open = true
		queue_redraw()
		return
	if is_in_button(position, booster_choice_rect(0)) and hammer_count > 0:
		booster_open = false
		lada_targeting = false
		brun_targeting = false
		bolt_targeting = false
		gale_targeting = false
		hammer_targeting = true
		message = "Młot bursztynowy: wybierz środek obszaru 3×3."
	elif is_in_button(position, booster_choice_rect(1)) and bolt_count > 0:
		booster_open = false
		lada_targeting = false
		brun_targeting = false
		hammer_targeting = false
		gale_targeting = false
		bolt_targeting = true
		message = "Grom Peruna: wybierz rząd do zniszczenia."
	elif is_in_button(position, booster_choice_rect(2)) and gale_count > 0:
		booster_open = false
		lada_targeting = false
		brun_targeting = false
		hammer_targeting = false
		bolt_targeting = false
		gale_targeting = true
		message = "Wiatr Gaju: wybierz typ znaku do rozwiania."
	queue_redraw()

func handle_training_input(position: Vector2) -> void:
	if is_in_button(position, training_close_rect()):
		training_open = false
		village_open = forest_catalog_open
		main_menu_open = not forest_catalog_open
		queue_redraw()
		return
	var catalog := training_catalog()
	for index in catalog.size():
		if is_in_button(position, training_choice_rect(index)):
			if forest_catalog_open and not forest_expeditions_view.card_visible(get_viewport_rect().size, training_choice_rect(index)):
				return
			if training_choice_locked(catalog[index]):
				message = "Rozwiń Dwór Wiecowy, aby odblokować tę wyprawę." if forest_catalog_open else "Ta próba wymaga dalszego postępu kampanii."
				return
			training_battle = catalog[index].duplicate(true)
			training_mode = true
			training_open = false
			start_level(level_index, training_battle)
			return

func handle_missions_input(position: Vector2) -> void:
	var row_top := 193.0
	for index in daily_missions.size():
		var mission: Dictionary = daily_missions[index]
		if mission_is_complete(mission) and not bool(mission.get("claimed", false)) and mission_claim_rect(row_top).has_point(position):
			claim_mission_reward("daily_missions", index)
			return
		row_top += mission_row_stride()
	row_top += 38.0
	for index in weekly_missions.size():
		var mission: Dictionary = weekly_missions[index]
		if mission_is_complete(mission) and not bool(mission.get("claimed", false)) and mission_claim_rect(row_top).has_point(position):
			claim_mission_reward("weekly_missions", index)
			return
		row_top += mission_row_stride()

func handle_main_menu_input(position: Vector2) -> void:
	for button in [main_menu_play_rect(), main_menu_roster_rect(), main_menu_party_rect(), main_menu_village_rect(), main_menu_training_rect(), main_menu_map_rect(), main_menu_missions_rect(), main_menu_shop_rect(), help_button_rect(), bestiary_button_rect()]:
		if is_in_button(position, button):
			play_audio_event("ui_click", 540.0, 0.08, 0.12)
			break
	if missions_open:
		if is_in_button(position, missions_close_rect()):
			missions_open = false
		else:
			handle_missions_input(position)
		queue_redraw()
		return
	if is_in_button(position, settings_button_rect()):
		help_open = true
		settings_open = true
		play_audio_event("ui_click")
		queue_redraw()
		return
	var forced_upgrade_hero_id := home_upgrade_tutorial_hero_id()
	if forced_upgrade_hero_id != "":
		if is_in_button(position, main_menu_roster_rect()):
			main_menu_open = false
			roster_open = true
			roster_hero_index = maxi(0, HERO_IDS.find(forced_upgrade_hero_id))
			roster_filter = "all"
			skill_tree_open = false
			player_opening.home_tutorial_step = "upgrade_%s_roster" % forced_upgrade_hero_id
			queue_redraw()
		return
	if player_opening.home_tutorial_step == "play_next":
		if is_in_button(position, main_menu_play_rect()):
			player_opening.home_tutorial_step = ""
			save_progress()
			main_menu_open = false
			start_level(maxi(0, campaign_frontier_count() - 1))
		return
	if player_opening.home_tutorial_step == "village_unlocked":
		if is_in_button(position, main_menu_village_rect()):
			player_opening.home_tutorial_step = "buy_sawmill"
			save_progress()
			main_menu_open = false
			village_open = true
			village_selected_id = "tartak"
			queue_redraw()
		return
	if village_tutorial_active():
		if is_in_button(position, main_menu_village_rect()):
			main_menu_open = false
			village_open = true
			village_selected_id = "tartak"
			queue_redraw()
		return
	if player_opening.home_tutorial_step == "third_companion_unlocked":
		if is_in_button(position, main_menu_roster_rect()):
			player_opening.home_tutorial_step = ""
			save_progress()
			main_menu_open = false
			roster_open = true
			queue_redraw()
		return
	if unlocked_level < 2 and (is_in_button(position, bestiary_button_rect()) or is_in_button(position, main_menu_map_rect()) or is_in_button(position, main_menu_shop_rect())):
		return
	if unlocked_level < 3 and is_in_button(position, main_menu_village_rect()):
		return
	if unlocked_level < 5 and is_in_button(position, main_menu_training_rect()):
		return
	if is_in_button(position, bestiary_button_rect()):
		bestiary_open = true
		bestiary_region_index = 0
		bestiary_page = 0
		help_open = false
		queue_redraw()
		return
	if is_in_button(position, main_menu_shop_rect()):
		grove_shop.open(self)
		return
	if Rect2(15, 4, 115, 115).has_point(position):
		player_opening.edit_avatar(self)
		queue_redraw()
		return
	if is_in_button(position, help_button_rect()):
		help_open = true
		settings_open = false
		queue_redraw()
		return
	if is_in_button(position, daily_reward_base_rect()) or is_in_button(position, daily_reward_banner_rect()):
		claim_daily_reward()
		return
	if is_in_button(position, daily_reward_premium_rect()):
		open_daily_premium_offer()
		return
	if is_in_button(position, main_menu_party_rect()):
		main_menu_open = false
		roster_open = true
		queue_redraw()
		return
	if is_in_button(position, main_menu_play_rect()):
		var frontier := campaign_frontier_count()
		if frontier < unlocked_level:
			main_menu_open = false
			map_page = int(maxi(0, frontier - 1) / 5)
			map_open = true
			queue_redraw()
		else:
			main_menu_open = false
			start_level(maxi(0, frontier - 1))
		return
	if is_in_button(position, main_menu_map_rect()):
		main_menu_open = false
		map_page = int(maxi(0, campaign_frontier_count() - 1) / 5)
		map_open = true
		queue_redraw()
		return
	if is_in_button(position, main_menu_roster_rect()):
		main_menu_open = false
		roster_open = true
		queue_redraw()
		return
	if is_in_button(position, main_menu_village_rect()):
		main_menu_open = false
		village_open = true
		village_selected_id = ""
		queue_redraw()
		return
	if is_in_button(position, main_menu_training_rect()):
		main_menu_open = false
		training_open = true
		forest_catalog_open = false
		training_scroll = 0.0
		queue_redraw()
		return
	if is_in_button(position, main_menu_missions_rect()):
		refresh_missions()
		missions_open = true
		queue_redraw()

func handle_help_input(position: Vector2) -> void:
	if not settings_open and is_in_button(position, sound_toggle_rect()):
		settings_open = true
		play_audio_event("ui_click")
		queue_redraw()
		return
	if settings_open and is_in_button(position, settings_guide_rect()):
		settings_open = false
		play_audio_event("ui_back")
		queue_redraw()
		return
	if settings_open and is_in_button(position, music_toggle_rect()):
		music_enabled = not music_enabled
		update_game_audio()
		save_progress()
		queue_redraw()
		return
	if settings_open and is_in_button(position, vibration_toggle_rect()):
		vibration_enabled = not vibration_enabled
		save_progress()
		queue_redraw()
		return
	if settings_open and is_in_button(position, sound_toggle_rect()):
		sfx_enabled = not sfx_enabled
		update_game_audio()
		if sfx_enabled:
			play_sfx(660.0, 0.10, 0.14)
		save_progress()
		queue_redraw()
		return
	if is_in_button(position, help_close_rect()):
		play_audio_event("ui_back", 330.0, 0.10, 0.12)
		help_open = false
		settings_open = false
		queue_redraw()

func handle_bestiary_input(position: Vector2) -> void:
	if is_in_button(position, bestiary_close_rect()):
		bestiary_open = false
		queue_redraw()
		return
	if is_in_button(position, bestiary_region_previous_rect()) and bestiary_region_index > 0:
		bestiary_region_index -= 1
		bestiary_page = 0
		queue_redraw()
		return
	if is_in_button(position, bestiary_region_next_rect()) and bestiary_region_index + 1 < bestiary_regions.size():
		bestiary_region_index += 1
		bestiary_page = 0
		queue_redraw()
		return
	var page_count := bestiary_page_count(bestiary_current_region())
	if is_in_button(position, bestiary_page_previous_rect()) and bestiary_page > 0:
		bestiary_page -= 1
		queue_redraw()
		return
	if is_in_button(position, bestiary_page_next_rect()) and bestiary_page + 1 < page_count:
		bestiary_page += 1
		queue_redraw()

func reset_progress() -> void:
	# Reset jest świadomie dwuetapowy w UI; po potwierdzeniu nadpisuje lokalny zapis.
	unlocked_level = 1
	grove_shop.opened = false
	grove_shop.pending_index = -1
	coins = 0
	wood = 0
	sawmill_production_progress = 0.0
	sawmill_stored_wood = 0
	last_wood_production_unix = int(Time.get_unix_time_from_system())
	experience = 0
	perun_sparks = 0
	event_marks = 0
	daily_reward_day = ""
	daily_ad_bonus_day = ""
	daily_reward_popup_open = false
	daily_reward_popup_kind = ""
	daily_reward_popup_loot.clear()
	pending_daily_chest_bonus = false
	claimed_boss_sparks.clear()
	level_stars.clear()
	bestiary_seen.clear()
	bestiary_kills.clear()
	claimed_bestiary_regions.clear()
	claimed_side_objectives.clear()
	expedition_bonus_claims.clear()
	mastery_claims.clear()
	balance_stats.clear()
	forest_catalog_open = false
	daily_mission_history.clear()
	weekly_mission_history.clear()
	daily_missions.clear()
	weekly_missions.clear()
	mission_day_key = ""
	mission_week_key = ""
	missions_open = false
	bestiary_open = false
	bestiary_region_index = 0
	bestiary_page = 0
	seen_region_intros.clear()
	seen_region_chapters.clear()
	seen_campaign_scenes.clear()
	tutorial_completed = false
	player_opening.reset_profile()
	for hero_id in HERO_IDS:
		hero_levels[hero_id] = 1 if hero_id == "lada" else 0
		hero_experience[hero_id] = 0
		hero_trees[hero_id] = {}
		owned_heroes[hero_id] = hero_id == "lada"
	active_heroes = ["lada"]
	for building_id in BUILDING_IDS:
		building_levels[building_id] = 0
	reset_confirmation = false
	training_mode = false
	skill_tree_open = false
	training_battle.clear()
	save_progress()
	start_level(0)
	main_menu_open = true
	message = "Postęp został zresetowany. Witaj ponownie w Dębowym Pograniczu!"
	queue_redraw()

func daily_reward_available() -> bool:
	return daily_reward_day != Time.get_date_string_from_system()

func claim_daily_reward() -> void:
	if not daily_reward_available():
		daily_reward_popup_open = true
		daily_reward_popup_kind = "already_claimed"
		daily_reward_popup_loot.clear()
		queue_redraw()
		return
	var coin_reward := 180 + mini(820, unlocked_level * 10)
	var wood_reward := 0
	var experience_reward := 60 + mini(240, unlocked_level * 2)
	coins += coin_reward
	wood += wood_reward
	experience += experience_reward
	daily_reward_day = Time.get_date_string_from_system()
	daily_reward_open_time = 0.0
	daily_reward_popup_open = true
	daily_reward_popup_kind = "daily_loot"
	daily_reward_popup_loot = {"coins": coin_reward, "wood": wood_reward, "experience": experience_reward}
	message = "Dar Gaju: +%d monet, +%d drewna, +%d PD." % [coin_reward, wood_reward, experience_reward]
	save_progress()
	play_audio_event("chest_open", 760.0, 0.16, 0.18)
	queue_audio_event("reward_reveal_common", 1.3)
	queue_audio_event("resource_coin", 2.1)
	queue_redraw()

func open_daily_premium_offer() -> void:
	daily_reward_popup_open = true
	daily_reward_popup_kind = "premium_offer"
	daily_reward_popup_loot = daily_premium_reward()
	queue_redraw()

func show_daily_premium_ad() -> void:
	if ads_manager == null or not ad_bonus_available_today() or not ads_manager.rewarded_ready:
		return
	pending_daily_chest_bonus = true
	if not ads_manager.show_rewarded():
		pending_daily_chest_bonus = false
		queue_redraw()

func handle_daily_reward_popup_input(position: Vector2) -> void:
	if daily_reward_popup_kind in ["daily_loot", "premium_offer"] and is_in_button(position, daily_reward_popup_ad_rect()):
		show_daily_premium_ad()
		return
	if is_in_button(position, daily_reward_popup_close_rect()) or not is_in_button(position, daily_reward_popup_rect()):
		daily_reward_popup_open = false
		daily_reward_popup_kind = ""
		daily_reward_popup_loot.clear()
		queue_redraw()

func draw_daily_reward_values(reward: Dictionary, baseline_y: float, reveal := 1.0) -> void:
	var kinds: Array[String] = ["coins", "wood", "experience"]
	var total_width := 0.0
	var item_widths: Array[float] = []
	for kind in kinds:
		var width := resource_amount_width(int(reward.get(kind, 0)), 28.0, 14)
		item_widths.append(width)
		total_width += width
	total_width += float(maxi(0, kinds.size() - 1)) * 15.0
	var current_x := (get_viewport_rect().size.x - total_width) * 0.5
	for index in kinds.size():
		var shown_amount := int(round(float(reward.get(kinds[index], 0)) * reveal))
		draw_resource_amount(Vector2(current_x, baseline_y), kinds[index], shown_amount, 28.0, 14, Color("#ffe6a5"))
		current_x += item_widths[index] + 15.0

func draw_daily_chest_reveal(panel: Rect2, reveal: float) -> void:
	var chest_center := Vector2(panel.get_center().x, panel.position.y + 108.0)
	var chest_size := Vector2(104.0, 80.0)
	if home_reward_coin_frames != null:
		var frame_index := clampi(roundi(reveal * 28.0), 0, 28)
		var frame_width := home_reward_coin_frames.get_width() / 29.0
		var source := Rect2(frame_index * frame_width, 0.0, frame_width, home_reward_coin_frames.get_height())
		draw_texture_rect_region(home_reward_coin_frames, Rect2(chest_center - chest_size * 0.5, chest_size), source, Color.WHITE)
	elif home_reward_premium_chest != null:
		var scale := 0.92 + reveal * 0.08
		draw_texture_rect(home_reward_premium_chest, Rect2(chest_center - chest_size * scale * 0.5, chest_size * scale), false)

func draw_daily_reward_popup(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#03100ed9"))
	var panel := daily_reward_popup_rect()
	if defeat_modal_oak != null:
		draw_texture_rect(defeat_modal_oak, panel, false)
	else:
		draw_style_box(make_panel(Color("#0b241df7"), Color("#d2a350")), panel)
	var title := "SKRZYNIA PREMIUM" if daily_reward_popup_kind == "premium_offer" else ("SKRZYNIA PREMIUM OTWARTA" if daily_reward_popup_kind == "premium_loot" else ("DAR GAJU ODEBRANY" if daily_reward_popup_kind == "daily_loot" else "DAR GAJU ODEBRANO DZIŚ"))
	if daily_reward_popup_kind == "premium_offer":
		if home_reward_premium_chest != null:
			draw_texture_rect(home_reward_premium_chest, Rect2(panel.get_center().x - 40.0, panel.position.y + 78.0, 80.0, 80.0), false)
		draw_string(font, Vector2(panel.position.x + 18.0, panel.position.y + 170.0), title, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 36.0, 21, Color("#ffe5a4"))
		draw_multiline_string(font, Vector2(panel.get_center().x - 150.0, panel.position.y + 190.0), "Obejrzyj krótką reklamę, aby zdobyć dodatkowe bonusy:", HORIZONTAL_ALIGNMENT_CENTER, 300.0, 13, 17, Color("#e6ddc5"))
		draw_daily_reward_values(daily_reward_popup_loot, panel.position.y + 221.0)
		if not ad_bonus_available_today():
			draw_string(font, Vector2(panel.position.x + 25.0, panel.position.y + 275.0), "Dzisiejszy bonus został już odebrany.", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 50.0, 12, Color("#aebba9"))
		elif ads_manager == null or not ads_manager.rewarded_ready:
			draw_string(font, Vector2(panel.position.x + 25.0, panel.position.y + 275.0), "Reklama jest teraz niedostępna. Spróbuj za chwilę.", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 50.0, 12, Color("#aebba9"))
	else:
		draw_string(font, Vector2(panel.position.x + 18.0, panel.position.y - 48.0), title, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 36.0, 21, Color("#ffe5a4"))
		var reveal_progress := 1.0
		if daily_reward_popup_kind in ["daily_loot", "premium_loot"] and daily_reward_open_time >= 0.0:
			var raw_progress := clampf(daily_reward_open_time / 0.9, 0.0, 1.0)
			reveal_progress = raw_progress * raw_progress * (3.0 - 2.0 * raw_progress)
		if daily_reward_popup_kind in ["daily_loot", "premium_loot"]:
			draw_daily_chest_reveal(panel, reveal_progress)
		var reward_heading := "Otrzymano dodatkowo:" if daily_reward_popup_kind == "premium_loot" else ("Dzisiejsza nagroda:" if daily_reward_popup_kind == "daily_loot" else "Kolejna skrzynia będzie dostępna jutro.")
		draw_string(font, Vector2(panel.position.x + 25.0, panel.position.y + 163.0), reward_heading, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 50.0, 15, Color("#e6ddc5"))
		if not daily_reward_popup_loot.is_empty():
			draw_daily_reward_values(daily_reward_popup_loot, panel.position.y + 188.0, reveal_progress)
		if daily_reward_popup_kind == "daily_loot":
			draw_multiline_string(font, Vector2(panel.get_center().x - 150.0, panel.position.y + 237.0), "Otwórz skrzynię premium, aby zobaczyć bonus za reklamę.", HORIZONTAL_ALIGNMENT_CENTER, 300.0, 12, 16, Color("#c5d3bd"))
			if not ad_bonus_available_today():
				draw_multiline_string(font, Vector2(panel.get_center().x - 150.0, panel.position.y + 252.0), "Dzisiejszy bonus reklamowy został już odebrany.", HORIZONTAL_ALIGNMENT_CENTER, 300.0, 11, 15, Color("#aebba9"))
			elif ads_manager == null or not ads_manager.rewarded_ready:
				draw_multiline_string(font, Vector2(panel.get_center().x - 150.0, panel.position.y + 262.0), "Bonus premium jest dostępny po przygotowaniu reklamy.", HORIZONTAL_ALIGNMENT_CENTER, 300.0, 11, 15, Color("#aebba9"))
	if daily_reward_popup_kind in ["daily_loot", "premium_offer"]:
		var ad_available: bool = ad_bonus_available_today() and ads_manager != null and ads_manager.rewarded_ready
		var ad_label := "OBEJRZYJ REKLAMĘ  •  OTWÓRZ SKRZYNIĘ" if ad_available else ("BONUS ODEBRANY" if not ad_bonus_available_today() else "REKLAMA NIEDOSTĘPNA")
		draw_button(daily_reward_popup_ad_rect(), ad_label, ad_available, 13)
	draw_button(daily_reward_popup_close_rect(), "ZAMKNIJ", true, 15)

func is_in_button(point: Vector2, rect: Rect2) -> bool:
	return rect.has_point(point)

func handle_action_button(position: Vector2) -> void:
	if state == "won":
		if campaign_ads_unlocked() and ad_bonus_available_today() and ads_manager != null and ads_manager.rewarded_ready and is_in_button(position, rewarded_coin_bonus_rect()):
			show_rewarded_coin_bonus()
			return
		if is_in_button(position, restart_rect()):
			if bool(current_battle.get("expedition", false)):
				victory_screen_open = false
				open_forest_expeditions()
			else:
				main_menu_open = true
			queue_redraw()
			return
		if is_in_button(position, defeat_training_rect()):
			if training_mode:
				restart_current_battle()
			elif level_index + 1 < levels.size():
				var next_level := level_index + 1
				refresh_ad_day()
				if campaign_wins_since_interstitial >= WINS_BETWEEN_INTERSTITIALS and ad_interstitials_today < MAX_INTERSTITIALS_PER_DAY and ads_manager != null:
					pending_ad_resume_level = next_level
					if ads_manager.show_interstitial():
						ad_interstitials_today += 1
						campaign_wins_since_interstitial = 0
						save_progress()
						return
					pending_ad_resume_level = -1
				start_level(next_level)
			return
	if is_in_button(position, restart_rect()):
		restart_current_battle()
	elif state == "lost" and not training_mode and is_in_button(position, defeat_training_rect()):
		roster_open = true
		roster_filter = "all"
		roster_hero_index = maxi(0, HERO_IDS.find("lada"))
		skill_tree_open = false
		queue_redraw()

func draw_button(rect: Rect2, label: String, enabled := true, text_size := 18, text_offset_y := 0.0) -> void:
	if button_oak != null:
		draw_texture_rect(button_oak, rect, false, Color.WHITE if enabled else Color(0.45, 0.45, 0.45, 0.8))
	else:
		var color := Color("#a96e2c") if enabled else Color("#5f5548")
		draw_style_box(make_panel(color, Color("#f3d49b")), rect)
	var label_width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x
	var baseline := rect.position.y + rect.size.y / 2.0 + text_size * 0.36 + text_offset_y
	draw_string(font, Vector2(rect.position.x + (rect.size.x - label_width) / 2.0, baseline), label, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, Color("#fff4d4"))

func resource_icon(kind: String) -> Texture2D:
	match kind:
		"coins": return coin_resource_icon
		"wood": return wood_resource_icon
		"experience": return experience_resource_icon
		"sparks": return perun_sparks_resource_icon
		"marks": return rune_tile_icon
	return null

func texture_aspect_fit_rect(texture: Texture2D, bounds: Rect2) -> Rect2:
	if texture == null:
		return bounds
	var source_size := texture.get_size()
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return bounds
	var scale_factor := minf(bounds.size.x / source_size.x, bounds.size.y / source_size.y)
	var fitted_size := source_size * scale_factor
	return Rect2(bounds.get_center() - fitted_size * 0.5, fitted_size)

func draw_resource_amount(position: Vector2, kind: String, amount: int, icon_size := 22.0, text_size := 14, color := Color("#fff0c7")) -> float:
	var icon := resource_icon(kind)
	if icon != null:
		draw_texture_rect(icon, Rect2(position, Vector2(icon_size, icon_size)), false)
	else:
		draw_circle(position + Vector2(icon_size * 0.5, icon_size * 0.5), icon_size * 0.38, Color("#d8b25c"))
	var text := str(amount)
	var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x
	draw_string(font, Vector2(position.x + icon_size + 3.0, position.y + icon_size * 0.74), text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, color)
	return icon_size + 3.0 + text_width

func resource_amount_width(amount: int, icon_size := 22.0, text_size := 14) -> float:
	return icon_size + 3.0 + font.get_string_size(str(amount), HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x

func draw_star_rating(center: Vector2, stars: int, icon_size := 30.0) -> void:
	var total_width := 3.0 * icon_size
	var first_x := center.x - total_width * 0.5
	for star_index in 3:
		var earned := star_index < stars
		var tint := Color.WHITE if earned else Color(0.42, 0.45, 0.42, 0.9)
		if star_rating_icon != null:
			draw_texture_rect(star_rating_icon, Rect2(first_x + star_index * icon_size, center.y - icon_size * 0.5, icon_size, icon_size), false, tint)
		else:
			draw_string(font, Vector2(first_x + star_index * icon_size, center.y + 7.0), "★", HORIZONTAL_ALIGNMENT_LEFT, -1, int(icon_size), Color("#f5d36f") if earned else Color("#747a70"))

func make_panel(fill: Color, border: Color) -> StyleBoxFlat:
	var panel := StyleBoxFlat.new()
	panel.bg_color = fill
	panel.border_color = border
	panel.set_border_width_all(2)
	panel.corner_radius_top_left = 10
	panel.corner_radius_top_right = 10
	panel.corner_radius_bottom_left = 10
	panel.corner_radius_bottom_right = 10
	return panel

func battle_mood_color() -> Color:
	if enemies.is_empty():
		return Color("#0b1e1b66")
	var first_name := str(enemies[0].get("name", ""))
	if first_name.contains("Leszy") or first_name.contains("Dąb") or first_name.contains("Korzeń"):
		return Color("#123f2c66")
	if first_name.contains("Cień") or first_name.contains("Wilk"):
		return Color("#111c3c88")
	if first_name.contains("Bagien") or first_name.contains("Topielec") or first_name.contains("Ropuch"):
		return Color("#123b4966")
	return Color("#0b1e1b66")

func draw_game_logo(center: Vector2, max_size: Vector2) -> void:
	if game_logo == null:
		return
	var texture_size := game_logo.get_size()
	if texture_size.x <= 0 or texture_size.y <= 0:
		return
	var scale_factor := minf(max_size.x / float(texture_size.x), max_size.y / float(texture_size.y))
	var draw_size := Vector2(float(texture_size.x) * scale_factor, float(texture_size.y) * scale_factor)
	draw_texture_rect(game_logo, Rect2(center - draw_size / 2.0, draw_size), false)

func draw_battle_fireflies(screen: Vector2) -> void:
	var protected: Array[Rect2] = [
		board_rect().grow(2.0),
		Rect2(0, 0, screen.x, 156),
		Rect2(20, 750, screen.x - 40, 36),
		pause_rect(),
	]
	for index in enemies.size():
		protected.append(enemy_card_rect(index).grow(8.0))
	for index in active_heroes.size():
		protected.append(hero_battle_rect(index).grow(20.0))
	for branch in 3:
		protected.append(hero_active_skill_rect(branch))
	player_opening.draw_background_fireflies(self, screen, protected, 0.8)

func _draw() -> void:
	var screen := get_viewport_rect().size
	if player_opening.stage != "" and not victory_screen_open:
		player_opening.draw(self)
		return
	if grove_shop.opened:
		grove_shop.draw(self)
		return
	if oak_borderland_background != null:
		draw_texture_rect(oak_borderland_background, Rect2(Vector2.ZERO, screen), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, screen), Color("#122b2a"))
	draw_rect(Rect2(Vector2.ZERO, screen), battle_mood_color())
	if state == "playing" and not (main_menu_open or roster_open or village_open or map_open or booster_open or training_open or region_intro_open or victory_screen_open):
		draw_battle_fireflies(screen)
	var level: Dictionary = current_battle if not current_battle.is_empty() else levels[level_index]
	if battle_header_oak != null:
		draw_texture_rect(battle_header_oak, Rect2(10, 4, screen.x - 20, 152), false)
	elif hud_oak_ornament != null:
		# Ciemne, półprzezroczyste wypełnienie poprawia kontrast tekstu,
		# pozostawiając ozdobną ramkę widoczną na wierzchu.
		draw_rect(Rect2(27, 27, screen.x - 54, 88), Color("#10251fdd"))
		draw_texture_rect(hud_oak_ornament, Rect2(20, 20, screen.x - 40, 104), false)
	var level_title := "Trening  •  %s" % str(level.get("name", "Krąg treningowy")) if training_mode else "Poziom %d  •  %s" % [int(level.get("id", level_index + 1)), str(level.get("name", "Wyprawa"))]
	var turn_title := "Tura: %s  •  wybieraj kafelki i łącz znaki" % HERO_NAMES[HERO_IDS.find(current_turn_hero())]
	draw_string(font, Vector2(34, 80), "LAS" if bool(level.get("expedition", false)) else "P. %d" % int(level.get("id", level_index + 1)), HORIZONTAL_ALIGNMENT_CENTER, 96, 17, Color("#fff0c7"))
	draw_string(font, Vector2(140, 85), str(level.get("name", "Wyprawa")), HORIZONTAL_ALIGNMENT_CENTER, 250, 17, Color("#fff0c7"))
	draw_string(font, Vector2(428, 79), "Tura: %s" % HERO_NAMES[HERO_IDS.find(current_turn_hero())], HORIZONTAL_ALIGNMENT_CENTER, 70, 11, Color("#d8efac"))
	var active_synergy_count := active_synergy_pairs().size()
	if active_synergy_count > 0:
		draw_string(font, Vector2(390, 111), "SYNERGIA +%d%%" % (active_synergy_count * 8), HORIZONTAL_ALIGNMENT_CENTER, 104, 10, Color("#f4d06d"))
	if side_objective_level_id > 0 and not training_mode:
		var reward_text := "NAGRODA ODEBRANA" if bool(claimed_side_objectives.get(str(side_objective_level_id), false)) else "+150 MONET"
		var objective_complete := side_objective_succeeded()
		var objective_panel := Rect2(14.0, -10.0, screen.x - 88.0, 90.0)
		if tutorial_tooltip_banner != null:
			draw_texture_rect(tutorial_tooltip_banner, objective_panel, false)
		else:
			draw_style_box(make_panel(Color("#10271ff5"), Color("#d9b75e")), objective_panel)
		draw_string(font, Vector2(objective_panel.position.x + 8.0, objective_panel.position.y + 27.0), "CEL DODATKOWY", HORIZONTAL_ALIGNMENT_CENTER, objective_panel.size.x - 16.0, 11, Color("#ffe5a4"))
		draw_string(font, Vector2(objective_panel.position.x + 8.0, objective_panel.position.y + 41.0), side_objective_description(side_objective_level_id), HORIZONTAL_ALIGNMENT_CENTER, objective_panel.size.x - 16.0, 14, Color("#f0ecd9"))
		var objective_status := "%s  •  %s  •  %s" % [side_objective_progress_text(), "UKOŃCZONY" if objective_complete else "W TRAKCIE", reward_text]
		draw_string(font, Vector2(objective_panel.position.x + 8.0, objective_panel.position.y + 55.0), objective_status, HORIZONTAL_ALIGNMENT_CENTER, objective_panel.size.x - 16.0, 10, Color("#c9f0a8") if objective_complete else Color("#f1dfb4"))
	if enemies.is_empty():
		draw_string(font, Vector2(140, 111), "CEL: %s" % goal_label(), HORIZONTAL_ALIGNMENT_CENTER, 250, 12, Color("#b9e7ca"))
	if bool(current_battle.get("expedition", false)):
		var expedition_panel := Rect2(14.0, 5.0, screen.x - 88.0, 64.0)
		if tutorial_tooltip_banner != null:
			draw_texture_rect(tutorial_tooltip_banner, expedition_panel, false)
		else:
			draw_style_box(make_panel(Color("#10271ff5"), Color("#d9b75e")), expedition_panel)
		draw_string(font, expedition_panel.position + Vector2(16.0, 22.0), "CEL WYPRAWY", HORIZONTAL_ALIGNMENT_CENTER, expedition_panel.size.x - 32.0, 11, Color("#ffe5a4"))
		draw_string(font, expedition_panel.position + Vector2(16.0, 44.0), goal_label(), HORIZONTAL_ALIGNMENT_CENTER, expedition_panel.size.x - 32.0, 14, Color("#f0ecd9"))
	var turn_banner := "RUCH PRZECIWNIKA" if enemy_turn_active else "TWÓJ RUCH"
	var turn_banner_color := Color("#ff9b72") if enemy_turn_active else Color("#b9e58a")
	if not enemies.is_empty():
		var banner_rect := Rect2(screen.x / 2.0 - 126.0, 288.0, 252.0, 48.0)
		if turn_banner_oak != null:
			draw_texture_rect(turn_banner_oak, banner_rect.grow(10.0), false)
		else:
			draw_style_box(make_panel(Color("#102a22f2"), Color("#d9b45d")), banner_rect)
		draw_string(font, Vector2(banner_rect.position.x, banner_rect.position.y + 28.0), turn_banner, HORIZONTAL_ALIGNMENT_CENTER, banner_rect.size.x, 16, turn_banner_color)
		for enemy_index in enemies.size():
			var enemy: Dictionary = enemies[enemy_index]
			var card := enemy_card_rect(enemy_index)
			var is_target := enemy_index == target_enemy_index and int(enemy.get("health", 0)) > 0
			# Wrogowie pozostają w równym rzędzie obok siebie; aktywność pokazuje animacja portretu.
			# Aktywny wróg ma ten sam rozmiar co pozostali; wyróżnia go tylko delikatne wychylenie.
			var enemy_health_value := int(enemy.get("health", 0))
			var enemy_max_health_value := int(enemy.get("max_health", 1))
			var alive := enemy_health_value > 0
			var enemy_color := Color("#fff0c7") if alive else Color("#879087")
			var shown_health := float(displayed_enemy_health.get(str(enemy.get("name", "")), enemy_health_value))
			var enemy_ratio := shown_health / float(maxi(1, enemy_max_health_value))
			var health_y := card.position.y + 158.0
			var portrait := boss_portrait_for(str(enemy.get("name", "")))
			var portrait_window := Rect2(card.position.x + (card.size.x - 86.0) / 2.0, card.position.y + 48.0, 86.0, 86.0)
			if portrait_backdrop_oak != null:
				var backdrop_tint := Color(1.0, 0.86, 0.46, 0.96) if is_target else Color(0.62, 0.84, 0.65, 0.76)
				draw_texture_rect(portrait_backdrop_oak, portrait_window, false, backdrop_tint if alive else Color(0.45, 0.5, 0.46, 0.65))
			if portrait != null:
				var portrait_size := 78.0 + (sin(ui_anim_time * 4.0) * 2.0 if is_target else 0.0)
				var attack_bob := sin((6.5 - enemy_attack_anim) * 5.0) * 7.0 if enemy_attack_anim > 0.0 else 0.0
				var portrait_y := portrait_window.get_center().y - portrait_size / 2.0 + attack_bob
				draw_texture_rect(portrait, Rect2(card.position.x + (card.size.x - portrait_size) / 2.0, portrait_y, portrait_size, portrait_size), false)
			if portrait == null:
				draw_circle(portrait_window.get_center(), 28, Color("#5b356e") if alive else Color("#424843"))
			var role_rect := Rect2(card.position.x + 12, card.position.y + 148.0, card.size.x - 24, 28)
			var role_color := enemy_role_color(enemy)
			var role_name := enemy_role_label(enemy)
			var role_text_width := font.get_string_size(role_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
			var role_content_width := role_text_width + 34.0
			var role_x := role_rect.get_center().x - role_content_width * 0.5
			draw_enemy_role_icon(Vector2(role_x + 14.0, role_rect.get_center().y), str(enemy.get("role", "attacker")), role_color)
			draw_string(font, Vector2(role_x + 31.0, role_rect.position.y + 18), role_name, HORIZONTAL_ALIGNMENT_LEFT, role_text_width + 2.0, 10, Color("#fff1c5"))
			if bool(enemy.get("enraged", false)):
				draw_string(font, Vector2(card.position.x, role_rect.position.y - 5.0), "SZAŁ", HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 10, Color("#ffbf69"))
			if alive and str(enemy.get("role", "attacker")) != "defender" and has_living_defender():
				draw_enemy_role_icon(enemy_guard_icon_rect(enemy_index).get_center(), "defender", Color("#75b6dd"))
			if enemy_damage_popup_time > 0.0 and enemy_damage_popup_index == enemy_index:
				var hit_alpha := enemy_damage_popup_time / 0.9
				draw_string(font, Vector2(card.position.x, card.position.y - 10.0 - (0.9 - enemy_damage_popup_time) * 28.0), "-%d" % enemy_damage_popup_value, HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 22, Color(1.0, 0.82, 0.32, hit_alpha))
			# Nazwa przeciwnika znajduje się pod grafiką portretu.
			# Nazwa wroga jest wyżej niż etykieta roli, żeby nie nachodziła na „ZWIADOWCA”.
			var info_y := card.position.y + 148.0
			draw_string(font, Vector2(card.position.x, info_y), str(enemy.get("name", "Wróg")), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 11, enemy_color)
			var bar_rect := Rect2(card.position.x + 12, health_y + 2, card.size.x - 24, 42)
			if healthbar_fill != null:
				draw_texture_rect(healthbar_fill, Rect2(bar_rect.position + Vector2(3, 4), Vector2((bar_rect.size.x - 6) * enemy_ratio, bar_rect.size.y - 8)), false)
			if healthbar_frame != null:
				draw_texture_rect(healthbar_frame, bar_rect, false)
			else:
				draw_style_box(make_panel(Color("#2a2524dd"), Color("#8e6b45")), bar_rect)
			draw_string(font, Vector2(bar_rect.position.x, health_y + 27.0), "%d/%d" % [enemy_health_value, enemy_max_health_value], HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 13, Color("#fff8df"))
	var rect := board_rect()
	if battle_board_roots != null:
		draw_texture_rect(battle_board_roots, Rect2(rect.position + Vector2(-25.0, -25.0), rect.size + Vector2(50.0, 50.0)), false)
	elif board_roots_frame != null:
		var frame_rect := Rect2(rect.position + Vector2(-32.0, -72.0), rect.size + Vector2(64.0, 144.0))
		draw_texture_rect(board_roots_frame, frame_rect, false)
	var cell := rect.size.x / BOARD_SIZE
	# Kamienne pola pozostają na miejscu, poruszają się wyłącznie znaki.
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var field_rect := Rect2(rect.position + Vector2(col, row) * cell, Vector2.ONE * cell)
			# Przygaszona szachownica utrzymuje kontrast między polami bez rozjaśniania tła.
			var field_tint := Color(0.82, 0.94, 0.82) if (row + col) % 2 == 0 else Color(0.58, 0.72, 0.72)
			if board_cell_stone != null:
				draw_texture_rect(board_cell_stone, field_rect, false, field_tint)
			else:
				draw_rect(field_rect, Color("#354d39") if (row + col) % 2 == 0 else Color("#0a2428"))
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var tile_cell := Vector2i(col, row)
			var offset_cells: Vector2 = tile_offsets.get(tile_cell, Vector2.ZERO)
			var tile_rect := Rect2(rect.position + Vector2(col * cell + 3, row * cell + 3) + offset_cells * cell, Vector2(cell - 6, cell - 6))
			if selected_cell == tile_cell:
				var selected_center := tile_rect.get_center()
				var active_hero := current_turn_hero()
				var selection_color := hero_selection_color(active_hero)
				var accent_texture: Texture2D = hero_accent_textures.get(active_hero, null)
				if accent_texture != null:
					draw_texture_rect(accent_texture, tile_rect.grow(9), false, Color(1.0, 1.0, 1.0, 0.84))
				draw_circle(selected_center, tile_rect.size.x * 0.48, Color(selection_color, 0.32), true)
				draw_circle(selected_center, tile_rect.size.x * 0.46, selection_color, false, 3.0)
				var mark := hero_selection_mark(active_hero)
				var mark_width := font.get_string_size(mark, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
				draw_string(font, Vector2(selected_center.x - mark_width / 2.0, selected_center.y + 7), mark, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#fff4d4"))
			var tile_icon: Texture2D = null
			if board[row][col] == 0:
				tile_icon = fire_tile_icon
			elif board[row][col] == 1:
				tile_icon = water_tile_icon
			elif board[row][col] == 2:
				tile_icon = leaf_tile_icon
			elif board[row][col] == 3:
				tile_icon = amber_tile_icon
			elif board[row][col] == 4:
				tile_icon = rune_tile_icon
			var special_kind := int(special_tiles[row][col])
			var special_icon: Texture2D = null
			var tile_type: int = int(board[row][col])
			if special_kind > 0 and tile_type >= 0 and tile_type < 5:
				if special_kind == 1:
					special_icon = special_blast_icons[tile_type]
				else:
					special_icon = special_global_icons[tile_type]
			if special_icon != null:
				draw_texture_rect(special_icon, tile_rect.grow(1.0), false)
			elif tile_icon != null:
				draw_texture_rect(tile_icon, tile_rect.grow(1), false)
			else:
				var sign: String = TILE_SIGNS[board[row][col]]
				var sign_width := font.get_string_size(sign, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
				draw_string(font, Vector2(tile_rect.get_center().x - sign_width / 2.0, tile_rect.get_center().y + 11), sign, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#fff1bc"))
			if obstacles[row][col] > 0:
				var obstacle_kind: int = obstacles[row][col]
				var obstacle_health := int(obstacles[row][col])
				var obstacle_icon: Texture2D = obstacle_root_icon
				if obstacle_kind == 1 and obstacle_health <= 0:
					obstacle_icon = obstacle_root_damaged_icon
				elif obstacle_kind == 2:
					obstacle_icon = obstacle_stone_icon if obstacle_health >= 2 else obstacle_stone_damaged_icon
				elif obstacle_kind == 3:
					obstacle_icon = obstacle_curse_icon if obstacle_health >= 3 else (obstacle_curse_damaged_icon if obstacle_health == 2 else obstacle_curse_critical_icon)
				if obstacle_icon != null:
					draw_texture_rect(obstacle_icon, tile_rect.grow(-2), false)
	if not training_mode and level_index == 0 and not tutorial_completed and player_opening.tutorial_moves == 0:
		var first_tutorial_cells: Array[Vector2i] = [FIRST_TUTORIAL_MOVE_FROM, FIRST_TUTORIAL_MOVE_TO, Vector2i(3, 1), Vector2i(3, 2)]
		for row in BOARD_SIZE:
			for col in BOARD_SIZE:
				var cell_position := Vector2i(col, row)
				if first_tutorial_cells.has(cell_position):
					continue
				var dim_rect := Rect2(rect.position + Vector2(col, row) * cell + Vector2(2.0, 2.0), Vector2.ONE * (cell - 4.0))
				draw_rect(dim_rect, Color(0.005, 0.018, 0.012, 0.72), true)
		var tutorial_highlight_pulse := 0.82 + 0.18 * (0.5 + 0.5 * sin(ui_anim_time * 4.5))
		for tutorial_cell in first_tutorial_cells:
			var highlight_rect := Rect2(rect.position + Vector2(tutorial_cell) * cell + Vector2(4.0, 4.0), Vector2.ONE * (cell - 8.0))
			var is_leaf_cell := tutorial_cell != FIRST_TUTORIAL_MOVE_TO
			var highlight_color := Color(0.70, 1.0, 0.76, tutorial_highlight_pulse) if is_leaf_cell else Color(1.0, 0.88, 0.56, tutorial_highlight_pulse)
			if tutorial_leaf_highlight != null:
				draw_texture_rect(tutorial_leaf_highlight, highlight_rect.grow(3.0), false, highlight_color)
			else:
				draw_rect(highlight_rect, highlight_color, false, 4.0, true)
		var move_from_center := rect.position + (Vector2(FIRST_TUTORIAL_MOVE_FROM) + Vector2.ONE * 0.5) * cell
		var move_to_center := rect.position + (Vector2(FIRST_TUTORIAL_MOVE_TO) + Vector2.ONE * 0.5) * cell
		draw_line(move_from_center, move_to_center, Color(0.30, 0.95, 0.66, 0.58), 2.0, true)
		var arrow_progress := 0.5 - 0.5 * cos(ui_anim_time * 2.4)
		var arrow_center := move_from_center.lerp(move_to_center, arrow_progress)
		if tutorial_leaf_arrow != null:
			var arrow_size := Vector2(cell * 0.55, cell * 1.05)
			draw_texture_rect(tutorial_leaf_arrow, Rect2(arrow_center - arrow_size * 0.5, arrow_size), false, Color(1.0, 1.0, 1.0, tutorial_highlight_pulse))
		else:
			draw_circle(move_to_center, cell * (0.12 + 0.025 * sin(ui_anim_time * 5.0)), Color("#ffe27d"), false, 3.0, true)
	if not training_mode and level_index == 1 and player_opening.tutorial_active(self):
		if player_opening.tutorial_moves == 0:
			var level_two_highlight_cells: Array[Vector2i] = [Vector2i(0, 6), Vector2i(1, 6), LEVEL_TWO_TUTORIAL_FROM, Vector2i(3, 6), LEVEL_TWO_TUTORIAL_TO]
			for row in BOARD_SIZE:
				for col in BOARD_SIZE:
					var cell_position := Vector2i(col, row)
					if level_two_highlight_cells.has(cell_position):
						continue
					var dim_rect := Rect2(rect.position + Vector2(col, row) * cell + Vector2(2.0, 2.0), Vector2.ONE * (cell - 4.0))
					draw_rect(dim_rect, Color(0.005, 0.018, 0.012, 0.72), true)
			var level_two_pulse := 0.82 + 0.18 * (0.5 + 0.5 * sin(ui_anim_time * 4.5))
			for tutorial_cell in level_two_highlight_cells:
				var highlight_rect := Rect2(rect.position + Vector2(tutorial_cell) * cell + Vector2(4.0, 4.0), Vector2.ONE * (cell - 8.0))
				var is_move_source := tutorial_cell == LEVEL_TWO_TUTORIAL_FROM
				var highlight_color := Color(1.0, 0.84, 0.42, level_two_pulse) if is_move_source else Color(0.70, 1.0, 0.76, level_two_pulse)
				if tutorial_leaf_highlight != null:
					draw_texture_rect(tutorial_leaf_highlight, highlight_rect.grow(3.0), false, highlight_color)
				else:
					draw_rect(highlight_rect, highlight_color, false, 4.0, true)
			var level_two_move_from_center := rect.position + (Vector2(LEVEL_TWO_TUTORIAL_FROM) + Vector2.ONE * 0.5) * cell
			var level_two_move_to_center := rect.position + (Vector2(LEVEL_TWO_TUTORIAL_TO) + Vector2.ONE * 0.5) * cell
			draw_line(level_two_move_from_center, level_two_move_to_center, Color(0.30, 0.95, 0.66, 0.58), 2.0, true)
			var level_two_arrow_progress := 0.5 - 0.5 * cos(ui_anim_time * 2.4)
			var level_two_arrow_center := level_two_move_from_center.lerp(level_two_move_to_center, level_two_arrow_progress)
			if tutorial_leaf_arrow != null:
				var level_two_arrow_size := Vector2(cell * 0.55, cell * 1.05)
				draw_texture_rect(tutorial_leaf_arrow, Rect2(level_two_arrow_center - level_two_arrow_size * 0.5, level_two_arrow_size), false, Color(1.0, 1.0, 1.0, level_two_pulse))
			else:
				draw_circle(level_two_move_to_center, cell * 0.14, Color("#ffe27d"), false, 3.0, true)
		elif player_opening.tutorial_moves == 1:
			for row in BOARD_SIZE:
				for col in BOARD_SIZE:
					if int(special_tiles[row][col]) == 1:
						var new_special_rect := Rect2(rect.position + Vector2(col, row) * cell + Vector2(3.0, 3.0), Vector2.ONE * (cell - 6.0))
						draw_rect(new_special_rect, Color("#ffe27d"), false, 4.0, true)
	if touch_start.x >= 0 and drag_current_cell.x >= 0 and drag_current_cell != touch_start and not animation_busy and not enemy_turn_active and not player_cascade_active:
		var drag_source := rect.position + (Vector2(touch_start) + Vector2.ONE * 0.5) * cell
		var drag_target := rect.position + (Vector2(drag_current_cell) + Vector2.ONE * 0.5) * cell
		draw_line(drag_source, drag_target, Color("#36dca1"), 4.0, true)
		draw_circle(drag_target, cell * 0.16, Color("#36dca1"), false, 3.0, true)

	for effect_cell in removal_effects:
		var effect_progress: float = clampf(float(removal_effects[effect_cell]) / 0.34, 0.0, 1.0)
		var effect_center := rect.position + Vector2((effect_cell.x + 0.5) * cell, (effect_cell.y + 0.5) * cell)
		if tile_remove_burst != null:
			var burst_size := cell * (0.82 + effect_progress * 0.72)
			draw_texture_rect(tile_remove_burst, Rect2(effect_center - Vector2.ONE * burst_size * 0.5, Vector2.ONE * burst_size), false, Color(1, 1, 1, 1.0 - effect_progress))
		draw_circle(effect_center, cell * (0.16 + effect_progress * 0.32), Color(1.0, 0.86, 0.35, 1.0 - effect_progress), false, 3.0)
		for spark in 6:
			var angle := float(spark) * TAU / 6.0
			var spark_pos := effect_center + Vector2(cos(angle), sin(angle)) * cell * (0.12 + effect_progress * 0.28)
			draw_circle(spark_pos, 2.5 * (1.0 - effect_progress), Color(1.0, 0.95, 0.65, 1.0 - effect_progress))
	# W czasie ruchu wroga znaczniki pokazują dwa kafelki wybrane do najlepszej zamiany.
	if enemy_action_phase == 1 and not enemy_action_cells.is_empty():
		for action_cell in enemy_action_cells:
			var action_center := rect.position + Vector2((action_cell.x + 0.5) * cell, (action_cell.y + 0.5) * cell)
			draw_circle(action_center, cell * 0.48, Color(0.9, 0.57, 0.16, 0.25), false, 3.0)
			var source := action_center + Vector2(0, -cell * 0.62)
			draw_line(source, action_center - Vector2(0, cell * 0.18), Color("#f6c76d"), 3.0, true)
			draw_line(action_center - Vector2(7, cell * 0.30), action_center - Vector2(0, cell * 0.18), Color("#f6c76d"), 3.0, true)
			draw_line(action_center + Vector2(7, -cell * 0.30), action_center - Vector2(0, cell * 0.18), Color("#f6c76d"), 3.0, true)
		draw_string(font, Vector2(0, rect.position.y - 10), "WRÓG PRZEKŁADA KAFELKI", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 15, Color("#f6c76d"))
	if board_shuffle_time > 0.0:
		var alpha := minf(0.72, board_shuffle_time * 0.65)
		draw_rect(rect, Color(0.06, 0.24, 0.18, alpha))
		draw_string(font, Vector2(rect.position.x, rect.get_center().y - 8), "PRZETASOWANIE GAJU", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Color("#ffe19a"))
		draw_string(font, Vector2(rect.position.x, rect.get_center().y + 17), "Powstaje nowa ścieżka kombinacji", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Color("#e3efc9"))
	# Popup rysujemy nad planszą, żeby większa rama nie była przez nią zasłaniana.
	if defender_help_open and not enemies.is_empty():
		draw_enemy_guard_help()
	# Wybrany cel jest podświetlany przy postaci; nie powielamy go tekstem nad bohaterami.
	if player_opening.tutorial_active(self):
		player_opening.draw_tutorial(self)
	elif not message.begins_with("Cel:"):
		var status_text := move_preview_text if selected_cell.x >= 0 and move_preview_text != "" else message
		if status_text == move_preview_text:
			draw_multiline_string(font, Vector2(24, 767), status_text, HORIZONTAL_ALIGNMENT_CENTER, screen.x - 48, 12, 15, Color("#ffe39a"))
		else:
			draw_string(font, Vector2(28, 775), status_text, HORIZONTAL_ALIGNMENT_CENTER, screen.x - 56, 13, Color("#d9e4bd"))
	# Rozbudowana podstawa korzeni jest tłem dla aktywnej drużyny.
	if booster_roots_pedestal != null:
		draw_texture_rect(booster_roots_pedestal, Rect2(16, 844, screen.x - 32, 174), false)
	# Bohaterowie są rysowani bez paneli: portret, nazwa, zdrowie i moc.
	for index in active_heroes.size():
		var hero_id: String = active_heroes[index]
		var battle_card := hero_battle_rect(index)
		var accent_texture: Texture2D = hero_accent_textures.get(hero_id, null)
		if portrait_backdrop_oak != null:
			var hero_backdrop_size := 92.0 if current_turn_hero() == hero_id else 86.0
			draw_texture_rect(portrait_backdrop_oak, Rect2(battle_card.position + Vector2(30, 31) - Vector2(hero_backdrop_size, hero_backdrop_size) / 2.0, Vector2(hero_backdrop_size, hero_backdrop_size)), false, Color(1, 1, 1, 0.88 if current_turn_hero() == hero_id else 0.58))
		if accent_texture != null:
			var accent_size := (88.0 + sin(ui_anim_time * 4.0) * 3.0) if current_turn_hero() == hero_id else 80.0
			draw_texture_rect(accent_texture, Rect2(battle_card.position + Vector2(30, 31) - Vector2(accent_size, accent_size) / 2.0, Vector2(accent_size, accent_size)), false, Color(1, 1, 1, 0.85 if current_turn_hero() == hero_id else 0.5))
		# Nazwa i liczba zdrowia mają osobne wiersze — wcześniej tekst HP
		# nachodził na nazwę bohatera przy węższych kartach.
		draw_string(font, Vector2(battle_card.position.x + 90, battle_card.position.y + 20), HERO_NAMES[HERO_IDS.find(hero_id)], HORIZONTAL_ALIGNMENT_LEFT, 86, 13, Color("#fff0c7"))
		if hero_portraits.has(hero_id) and hero_portraits[hero_id] != null:
			var hero_portrait_size := 72.0 + (sin(ui_anim_time * 4.0) * 2.0 if current_turn_hero() == hero_id else 0.0)
			var hero_portrait_position := battle_card.position + Vector2(30, 31) - Vector2(hero_portrait_size, hero_portrait_size) / 2.0
			var hero_portrait_rect := texture_aspect_fit_rect(hero_portraits[hero_id], Rect2(hero_portrait_position, Vector2(hero_portrait_size, hero_portrait_size)))
			draw_texture_rect(hero_portraits[hero_id], hero_portrait_rect, false)
		if active_heroes.has(hero_id):
			draw_string(font, Vector2(battle_card.position.x + 90, battle_card.position.y + 35), "%d/%d" % [hero_health[hero_id], hero_max_health[hero_id]], HORIZONTAL_ALIGNMENT_LEFT, 82, 11, Color("#fff0c7"))
		var hero_ratio := float(displayed_hero_health.get(hero_id, hero_health[hero_id])) / float(maxi(1, hero_max_health[hero_id]))
		var hero_bar := Rect2(battle_card.position.x + 78, battle_card.position.y + 37, 94.0, 38.0)
		if healthbar_fill != null:
			draw_texture_rect(healthbar_fill, Rect2(hero_bar.position + Vector2(2, 3), Vector2((hero_bar.size.x - 4) * hero_ratio, hero_bar.size.y - 6)), false)
		if healthbar_frame != null:
			draw_texture_rect(healthbar_frame, hero_bar, false)
		else:
			draw_style_box(make_panel(Color("#2a2524dd"), Color("#8e6b45")), hero_bar)
		if damage_popup_time > 0.0 and current_turn_hero() == hero_id:
			var popup_alpha := damage_popup_time / 0.8
			draw_string(font, battle_card.position + Vector2(62, -8.0 - (0.8 - damage_popup_time) * 22.0), "-%d" % damage_popup_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1.0, 0.35, 0.25, popup_alpha))
	var skill_hero := current_turn_hero()
	var skill_charge := int(hero_active_charge.get(skill_hero, 0))
	var skill_energy_icons := [fire_tile_icon, water_tile_icon, leaf_tile_icon, amber_tile_icon, rune_tile_icon]
	var skill_energy_icon := skill_energy_icons[SkillTree.element(skill_hero)] as Texture2D
	for branch in 3:
		var skill_rect := hero_active_skill_rect(branch)
		var skill_rank := hero_active_skill_rank(skill_hero, branch)
		var skill_cost := hero_active_skill_cost(branch)
		var skill_unlocked := skill_rank > 0
		var skill_ready := skill_unlocked and skill_charge >= skill_cost and not enemy_turn_active and not animation_busy and not player_cascade_active
		draw_skill_node_icon(Vector2(skill_rect.get_center().x, skill_rect.position.y + 17.0), skill_hero, branch, 0, skill_unlocked, maxi(1, skill_rank))
		var skill_label := SkillTree.branch_name(skill_hero, branch).to_upper()
		draw_string(font, Vector2(skill_rect.position.x + 3.0, skill_rect.position.y + 49.0), skill_label, HORIZONTAL_ALIGNMENT_CENTER, skill_rect.size.x - 6.0, 11, Color("#fff0c7") if skill_unlocked else Color("#aeb8ae"))
		var charge_label := "%d/%d" % [skill_charge, skill_cost] if skill_unlocked else "ZABLOKOWANA"
		if skill_unlocked and skill_energy_icon != null:
			var charge_font_size := 11
			var charge_text_width := font.get_string_size(charge_label, HORIZONTAL_ALIGNMENT_LEFT, -1, charge_font_size).x
			var charge_content_width := 15.0 + 4.0 + charge_text_width
			var charge_x := skill_rect.get_center().x - charge_content_width * 0.5
			draw_texture_rect(skill_energy_icon, Rect2(charge_x, skill_rect.position.y + 52.0, 15.0, 15.0), false)
			draw_string(font, Vector2(charge_x + 19.0, skill_rect.position.y + 65.0), charge_label, HORIZONTAL_ALIGNMENT_LEFT, charge_text_width + 2.0, charge_font_size, Color("#bff3ca") if skill_ready else Color("#c4cbb6"))
		else:
			draw_string(font, Vector2(skill_rect.position.x + 3.0, skill_rect.position.y + 65.0), charge_label, HORIZONTAL_ALIGNMENT_CENTER, skill_rect.size.x - 6.0, 10, Color("#aeb5a5"))
	if held_tooltip != "":
		var is_hero_tooltip := held_tooltip_hero_id != ""
		# Panel bohatera jest wyższy, żeby opis i współczynniki miały własną przestrzeń.
		var tooltip_rect := Rect2(16, 742 if is_hero_tooltip else 812, screen.x - 32, 200 if is_hero_tooltip else 98)
		if tutorial_tooltip_banner != null:
			draw_texture_rect(tutorial_tooltip_banner, tooltip_rect, false)
		elif turn_banner_oak != null:
			draw_texture_rect(turn_banner_oak, tooltip_rect, false, Color(0.92, 0.98, 0.9, 1.0))
		else:
			draw_style_box(make_panel(Color("#193d38f2"), Color("#f0d57a")), tooltip_rect)
		if held_tooltip_icon != null and not is_hero_tooltip:
			var portrait_rect := Rect2(tooltip_rect.position + Vector2(14, 13), Vector2(52, 52))
			draw_texture_rect(held_tooltip_icon, portrait_rect, false)
		if is_hero_tooltip:
			# Nazwa bohatera jest teraz wyśrodkowana i odsunięta 25 px niżej.
			var title_rect := Rect2(tooltip_rect.position.x + 18.0, tooltip_rect.position.y + 47.0, tooltip_rect.size.x - 36.0, 31.0)
			draw_string(font, Vector2(title_rect.position.x, title_rect.position.y + 14.0), held_tooltip, HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, 15, Color("#fff0c7"))
			var coefficients := hero_damage_coefficients(held_tooltip_hero_id)
			var run_names := ["Ogień", "Woda", "Liście", "Bursztyn", "Runy"]
			var run_icons := [fire_tile_icon, water_tile_icon, leaf_tile_icon, amber_tile_icon, rune_tile_icon]
			var item_width := tooltip_rect.size.x / 5.0
			for run_index in coefficients.size():
				var item_x := tooltip_rect.position.x + item_width * run_index
				var icon: Texture2D = run_icons[run_index]
				if icon != null:
					draw_texture_rect(icon, Rect2(item_x + item_width * 0.5 - 17.0, tooltip_rect.position.y + 69.0, 34.0, 34.0), false)
				draw_string(font, Vector2(item_x, tooltip_rect.position.y + 132.0), "%s  ×%d" % [run_names[run_index], coefficients[run_index]], HORIZONTAL_ALIGNMENT_CENTER, item_width, 13, Color("#ffe7a3"))
			draw_string(font, Vector2(tooltip_rect.position.x, tooltip_rect.position.y + 147.0), "Obrażenia za znak • czwórki, piątki i kaskady dodają premie", HORIZONTAL_ALIGNMENT_CENTER, tooltip_rect.size.x, 12, Color("#cfe1c2"))
		else:
			draw_multiline_string(font, Vector2(tooltip_rect.position.x + 76, tooltip_rect.position.y + 41), held_tooltip, HORIZONTAL_ALIGNMENT_LEFT, tooltip_rect.size.x - 90, 12, 17, Color("#fff0c7"))
	if state != "playing" and not main_menu_open:
		# Modal przejmuje uwagę — przygaszamy całą bitwę pod nim.
		if state == "lost" and defeat_background != null:
			draw_texture_rect(defeat_background, Rect2(Vector2.ZERO, screen), false)
		draw_rect(Rect2(Vector2.ZERO, screen), Color(0.035, 0.055, 0.05, 0.52))
		var title := "POZIOM UKOŃCZONY" if state == "won" else "NIEUDANA WYPRAWA"
		var overlay := result_modal_rect()
		# Korzenna tablica jest wspólną oprawą wyniku: zwycięstwo ma tę samą
		# tożsamość świata gry co porażka, a środek zostawia miejsce na nagrody.
		if defeat_modal_oak != null:
			draw_texture_rect(defeat_modal_oak, overlay, false, Color.WHITE if state == "won" else Color(0.82, 0.88, 0.82, 1.0))
		else:
			draw_style_box(make_panel(Color("#183b39e8"), Color("#f0c96e")), overlay)
		var title_y := overlay.position.y + 158.0
		draw_string(font, Vector2(overlay.position.x, title_y), title, HORIZONTAL_ALIGNMENT_CENTER, overlay.size.x, 24, Color("#ffe7a3"))
		draw_string(font, Vector2(overlay.position.x, title_y + 22.0), "Wynik: %d" % score, HORIZONTAL_ALIGNMENT_CENTER, overlay.size.x, 18, Color.WHITE)
		if state == "won":
			var reward_y := title_y + 34.0
			var reward_widths := [
				resource_amount_width(int(last_reward.get("coins", 0)), 32.0, 18),
				resource_amount_width(int(last_reward.get("wood", 0)), 32.0, 18),
				resource_amount_width(int(last_reward.get("experience", 0)), 32.0, 18),
				resource_amount_width(int(last_reward.get("sparks", 0)), 32.0, 18)
			]
			var rewards_total := float(reward_widths[0] + reward_widths[1] + reward_widths[2] + reward_widths[3]) + 42.0
			var reward_x := overlay.get_center().x - rewards_total * 0.5
			reward_x += draw_resource_amount(Vector2(reward_x, reward_y), "coins", int(last_reward.get("coins", 0)), 32.0, 18, Color("#c6dcba")) + 14.0
			reward_x += draw_resource_amount(Vector2(reward_x, reward_y), "wood", int(last_reward.get("wood", 0)), 32.0, 18, Color("#c6dcba")) + 14.0
			reward_x += draw_resource_amount(Vector2(reward_x, reward_y), "experience", int(last_reward.get("experience", 0)), 32.0, 18, Color("#c6dcba")) + 14.0
			draw_resource_amount(Vector2(reward_x, reward_y), "sparks", int(last_reward.get("sparks", 0)), 32.0, 18, Color("#ffe39a"))
			draw_star_rating(Vector2(overlay.get_center().x, title_y + 86.0), last_stars, 42.0)
		else:
			draw_string(font, Vector2(overlay.position.x, title_y + 46.0), "Drużyna potrzebuje chwili, by odzyskać siły.", HORIZONTAL_ALIGNMENT_CENTER, overlay.size.x, 14, Color("#c6dcba"))
		if state == "won":
			if campaign_ads_unlocked() and ad_bonus_available_today() and ads_manager != null and ads_manager.rewarded_ready:
				draw_button(rewarded_coin_bonus_rect(), "OBEJRZYJ • +50% MONET", true, 13)
			draw_button(restart_rect(), "WRÓĆ DO WYPRAW" if bool(current_battle.get("expedition", false)) else "WRÓĆ DO MENU", true, 15)
			var can_continue := training_mode or level_index + 1 < levels.size()
			draw_button(defeat_training_rect(), "POWTÓRZ WYPRAWĘ" if bool(current_battle.get("expedition", false)) else ("POWTÓRZ TRENING" if training_mode else ("NASTĘPNY POZIOM" if can_continue else "KAMPANIA UKOŃCZONA")), can_continue, 14)
		else:
			draw_button(restart_rect(), "ZAGRAJ PONOWNIE", true, 16)
			if not training_mode:
				draw_button(defeat_training_rect(), "ULEPSZ BOHATERA", true, 15)
	if roster_open:
		draw_roster_overlay(screen)
		if skill_tree_open:
			draw_skill_tree_overlay(screen)
			if talent_tutorial_active():
				draw_skill_tree_tutorial(screen)
		if roster_upgrade_tutorial_hero_id() != "":
			draw_roster_upgrade_tutorial(screen)
		elif talent_roster_tutorial_active():
			draw_roster_talent_tutorial(screen)
	if village_open:
		draw_village_overlay(screen)
	if map_open:
		if map_transition_time < MAP_TRANSITION_DURATION:
			var progress := clampf(map_transition_time / MAP_TRANSITION_DURATION, 0.0, 1.0)
			var eased_progress := progress * progress * (3.0 - 2.0 * progress)
			var target_page := map_page
			draw_map_background_transition(screen, eased_progress)
			draw_map_overlay(screen, false, true, false)
			map_page = map_transition_from_page
			draw_set_transform(Vector2(0.0, -map_transition_direction * screen.y * eased_progress), 0.0, Vector2.ONE)
			draw_map_overlay(screen, false, false, true)
			map_page = target_page
			draw_set_transform(Vector2(0.0, map_transition_direction * screen.y * (1.0 - eased_progress)), 0.0, Vector2.ONE)
			draw_map_overlay(screen, false, false, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_map_overlay(screen)
	if booster_open:
		draw_booster_overlay(screen)
	if training_open:
		draw_training_overlay(screen)
	if main_menu_open:
		draw_main_menu(screen)
		if player_opening.home_tutorial_step != "":
			draw_home_tutorial(screen)
	if daily_reward_popup_open:
		draw_daily_reward_popup(screen)
	if help_open:
		draw_help_overlay(screen)
	if bestiary_open:
		draw_bestiary_overlay(screen)
	if missions_open:
		draw_missions_overlay(screen)
	if region_intro_open:
		if not active_story_dialogue.is_empty():
			draw_campaign_story_dialogue(screen)
		else:
			if story_dialogue_background != null:
				draw_texture_rect(story_dialogue_background, Rect2(Vector2.ZERO, screen), false)
			elif oak_borderland_background != null:
				draw_texture_rect(oak_borderland_background, Rect2(Vector2.ZERO, screen), false)
			else:
				draw_rect(Rect2(Vector2.ZERO, screen), Color("#10261d"))
			draw_rect(Rect2(Vector2.ZERO, screen), Color(0.015, 0.035, 0.025, 0.34))
			player_opening.draw_background_fireflies(self, screen, [Rect2(20.0, screen.y * 0.42, screen.x - 40.0, screen.y * 0.24)])
			var intro: Array = active_region_intro if not active_region_intro.is_empty() else ["NOWA KRAINA", "Droga prowadzi dalej."]
			draw_string(font, Vector2(28.0, screen.y * 0.46), str(intro[0]), HORIZONTAL_ALIGNMENT_CENTER, screen.x - 56.0, 26, Color("#ffe7a3"))
			draw_multiline_string(font, Vector2(38.0, screen.y * 0.51), str(intro[1]), HORIZONTAL_ALIGNMENT_CENTER, screen.x - 76.0, 17, 24, Color("#f0ecd9"))
			draw_string(font, Vector2(0.0, screen.y * 0.63), "DOTKNIJ, ABY WYRUSZYĆ", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 14, Color("#f5d36f"))
	if victory_screen_open:
		draw_victory_screen(screen)
	if not main_menu_open and not roster_open and not village_open and not map_open and not booster_open and not training_open and not region_intro_open:
		if pause_button_oak != null:
			draw_texture_rect(pause_button_oak, pause_rect(), false)
		else:
			draw_button(pause_rect(), "II", true, 14)

func draw_victory_screen(screen: Vector2) -> void:
	var fade := clampf(ui_anim_time - victory_open_time, 0.0, 1.0)
	if victory_background != null:
		draw_texture_rect(victory_background, Rect2(Vector2.ZERO, screen), false, Color(1.0, 1.0, 1.0, fade))
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.012, 0.035, 0.025, 0.46 * fade))
	player_opening.draw_background_fireflies(self, screen, [Rect2(24.0, 185.0, screen.x - 48.0, 450.0), Rect2(20.0, 700.0, screen.x - 40.0, screen.y - 700.0)], fade)
	var pulse := 1.0 + sin(ui_anim_time * 2.4) * 0.018
	var crest_bounds := Rect2(0.0, 214.0 + sin(ui_anim_time * 1.6) * 4.0, screen.x, 370.0)
	var crest_size := crest_bounds.size * pulse
	var crest_rect := Rect2(crest_bounds.get_center() - crest_size * 0.5, crest_size)
	if victory_crest != null:
		draw_texture_rect(victory_crest, texture_aspect_fit_rect(victory_crest, crest_rect), false, Color(1.0, 1.0, 1.0, fade))
	else:
		draw_style_box(make_panel(Color("#14372ded"), Color("#d8b45e")), Rect2(22.0, 210.0, screen.x - 44.0, 420.0))
	draw_star_rating(Vector2(screen.x * 0.5, 350.0), last_stars, 36.0)
	draw_string(font, Vector2(0.0, 410.0), "ZWYCIĘSTWO!", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 34, Color("#ffe7a3"))
	draw_string(font, Vector2(0.0, 214.0), "POWRACA NADZIEJA", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 13, Color("#d8e2bd"))
	draw_string(font, Vector2(35.0, 730.0), "ZDOBYTE NAGRODY", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 70.0, 18, Color("#ffe7a3"))
	var reward_kinds: Array[String] = ["coins", "wood", "experience"]
	var reward_values: Array[int] = [int(last_reward.get("coins", 0)), int(last_reward.get("wood", 0)), int(last_reward.get("experience", 0))]
	if int(last_reward.get("sparks", 0)) > 0:
		reward_kinds.append("sparks")
		reward_values.append(int(last_reward.get("sparks", 0)))
	if int(last_reward.get("event_marks", 0)) > 0:
		reward_kinds.append("marks")
		reward_values.append(int(last_reward.get("event_marks", 0)))
	var slot_width := (screen.x - 52.0) / float(reward_kinds.size())
	for reward_index in reward_kinds.size():
		var slot := Rect2(26.0 + slot_width * reward_index, 744.0, slot_width - 8.0, 76.0)
		var amount_width := resource_amount_width(reward_values[reward_index], 34.0, 20)
		draw_resource_amount(Vector2(slot.get_center().x - amount_width * 0.5, slot.position.y + 20.0), reward_kinds[reward_index], reward_values[reward_index], 34.0, 20, Color("#fff0c7"))
	var message_y := 838.0
	draw_multiline_string(font, Vector2(52.0, message_y), message, HORIZONTAL_ALIGNMENT_CENTER, screen.x - 104.0, 15, 21, Color("#e1e8d3"))
	draw_button(victory_continue_rect(), "DALEJ", true, 20)

func draw_campaign_story_dialogue(screen: Vector2) -> void:
	var panel := Rect2(18.0, (screen.y - 440.0) * 0.5, screen.x - 36.0, 440.0)
	if story_dialogue_background != null:
		draw_texture_rect(story_dialogue_background, Rect2(Vector2.ZERO, screen), false)
	elif oak_borderland_background != null:
		draw_texture_rect(oak_borderland_background, Rect2(Vector2.ZERO, screen), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, screen), Color("#10261d"))
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.01, 0.025, 0.018, 0.36))
	player_opening.draw_background_fireflies(self, screen, [panel, story_dialogue_skip_rect(screen), story_dialogue_continue_rect(screen)])
	var label_y := panel.position.y + 27.0
	draw_string(font, Vector2(66.0, label_y), "OPOWIEŚĆ  •  %d / %d" % [story_dialogue_page + 1, active_story_dialogue.size()], HORIZONTAL_ALIGNMENT_LEFT, screen.x - 200.0, 12, Color("#e2d2a9"))
	var skip_rect := story_dialogue_skip_rect(screen)
	draw_string(font, Vector2(skip_rect.position.x, skip_rect.position.y + 27.0), "POMIŃ", HORIZONTAL_ALIGNMENT_CENTER, skip_rect.size.x, 13, Color("#f5d998"))
	var page: Dictionary = active_story_dialogue[story_dialogue_page]
	var portrait_id := str(page.get("portrait", "lada"))
	var speaker := str(page.get("speaker", ""))
	var portrait: Texture2D = null
	if portrait_id == "enemy" or (not HERO_NAMES.has(speaker) and portrait_id != "unknown"):
		portrait = boss_portrait_for(speaker)
	elif portrait_id != "unknown":
		portrait = hero_portraits.get(portrait_id, null)
	var portrait_rect := Rect2(Vector2(screen.x * 0.5 - 62.0, panel.position.y + 34.0), Vector2(124.0, 124.0))
	if portrait != null:
		draw_texture_rect(portrait, texture_aspect_fit_rect(portrait, portrait_rect), false)
	draw_string(font, Vector2(24.0, panel.position.y + 194.0), str(page.get("speaker", "Opowieść")), HORIZONTAL_ALIGNMENT_CENTER, screen.x - 48.0, 21, Color("#ffe5a1"))
	var text_width := screen.x * 0.6
	var text_position := Vector2((screen.x - text_width) * 0.5, panel.position.y + 226.0)
	draw_multiline_string(font, text_position, str(page.get("text", "")), HORIZONTAL_ALIGNMENT_CENTER, text_width, 17, 24, Color("#f0ecd9"))
	var final_label := "ROZPOCZNIJ WYPRAWĘ" if int(current_battle.get("id", 0)) == 1 else "DO WALKI"
	var next_label := final_label if story_dialogue_page + 1 >= active_story_dialogue.size() else "DALEJ"
	var continue_rect := story_dialogue_continue_rect(screen)
	draw_string(font, Vector2(continue_rect.position.x, continue_rect.position.y + 30.0), next_label, HORIZONTAL_ALIGNMENT_CENTER, continue_rect.size.x, 16, Color("#f5d36f"))

func draw_roster_overlay(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#071610"))
	var roster_background_hero := selected_roster_hero_id()
	if not skill_tree_backgrounds.has(roster_background_hero):
		skill_tree_backgrounds[roster_background_hero] = load("res://art/skill_backgrounds/skill_tree_%s.png" % roster_background_hero) as Texture2D
	var roster_background: Texture2D = skill_tree_backgrounds[roster_background_hero]
	var transition_t := clampf(roster_transition_time / ROSTER_TRANSITION_DURATION, 0.0, 1.0)
	var eased_t := 1.0 - pow(1.0 - transition_t, 3.0)
	if roster_transition_from_id != "" and roster_transition_from_id != roster_background_hero and skill_tree_backgrounds.has(roster_transition_from_id):
		var old_background: Texture2D = skill_tree_backgrounds[roster_transition_from_id]
		if old_background != null:
			draw_texture_rect(old_background, Rect2(Vector2.ZERO, screen), false, Color(1, 1, 1, 1.0 - eased_t))
	if roster_background != null:
		draw_texture_rect(roster_background, Rect2(Vector2.ZERO, screen), false, Color(1, 1, 1, eased_t if roster_transition_from_id != "" else 1.0))
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#05120e88"))
	draw_menu_fireflies(screen)
	draw_game_logo(Vector2(screen.x / 2.0, 72), Vector2(205, 110))
	# Portfel rekrutacji jest stale widoczny w prawym górnym rogu.
	# Pokazuje dokładnie trzy waluty używane przy zakupie bohaterów.
	var recruitment_wallet := Rect2(screen.x - 158.0, 12.0, 144.0, 112.0)
	var recruitment_resources := [
		{"kind": "coins", "amount": coins, "color": Color("#ffe5a8")},
		{"kind": "sparks", "amount": perun_sparks, "color": Color("#8fe8df")},
		{"kind": "marks", "amount": event_marks, "color": Color("#f6d779")}
	]
	for wallet_index in recruitment_resources.size():
		var wallet_entry: Dictionary = recruitment_resources[wallet_index]
		var wallet_amount := int(wallet_entry["amount"])
		var wallet_width := resource_amount_width(wallet_amount, 30.0, 16)
		var wallet_x := recruitment_wallet.end.x - wallet_width - 8.0
		draw_resource_amount(Vector2(wallet_x, recruitment_wallet.position.y + 2.0 + wallet_index * 33.0), str(wallet_entry["kind"]), wallet_amount, 30.0, 16, wallet_entry["color"])
	var panel_rect := roster_detail_rect()
	# Karta jest otwarta: przyciemnione tło gry daje kontekst, a sama postać
	# i informacje nie są zamykane w kolejnym zielonym panelu.
	if roster_section_header != null:
		draw_texture_rect(roster_section_header, Rect2((screen.x - 276.0) * 0.5, 121, 276, 78), false)
	draw_string(font, Vector2(panel_rect.position.x, 145), "KRĄG BOHATERÓW", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 22, Color("#f5d998"))
	var filters := ["all", "ZWYKŁA", "PREMIUM", "LEGENDA"]
	for filter_index in filters.size():
		var filter_id := str(filters[filter_index])
		var filter_rect := roster_filter_rect(filter_index)
		if roster_filter == filter_id and roster_tabs_active_v04 != null:
			var source_size := roster_tabs_active_v04.get_size()
			draw_texture_rect_region(roster_tabs_active_v04, Rect2(filter_rect.position + Vector2(-9, -10), Vector2(filter_rect.size.x + 18.0, filter_rect.size.y + 8.0)), Rect2(Vector2.ZERO, Vector2(source_size.x, source_size.y * 0.86)))
		elif roster_filter != filter_id:
			if roster_tabs_inactive_v04 != null:
				draw_texture_rect(roster_tabs_inactive_v04, filter_rect.grow(2.0), false)
			else:
				draw_style_box(make_panel(Color("#102a2290"), Color("#42614f")), filter_rect)
		draw_string(font, Vector2(filter_rect.position.x, filter_rect.position.y + 34), roster_filter_label(filter_id), HORIZONTAL_ALIGNMENT_CENTER, filter_rect.size.x, 12, Color("#fff0c7") if roster_filter == filter_id else Color("#c8d2c0"))
	var hero_id := selected_roster_hero_id()
	var content_offset := 0.0
	if roster_transition_from_id != "" and roster_transition_from_id != hero_id:
		content_offset = lerpf(92.0 * roster_transition_direction, 0.0, eased_t)
	draw_set_transform(Vector2(content_offset, 0.0), 0.0, Vector2.ONE)
	var owned := bool(owned_heroes[hero_id])
	var in_party := active_heroes.has(hero_id)
	# Portret nie dostaje własnego tła, panelu ani ozdobnej ramy — sylwetka
	# pozostaje czytelna i nie konkuruje z informacjami po prawej stronie.
	var portrait_rect := Rect2(24, 300, 246, 300)
	if hero_portraits.has(hero_id) and hero_portraits[hero_id] != null:
		var roster_portrait_rect := texture_aspect_fit_rect(hero_portraits[hero_id], portrait_rect)
		# Portret jest gotowym półpiersiem z własnym obrysem stroju i alfą.
		# Rysujemy całą grafikę, aby zachować naturalny dół i boki sylwetki.
		draw_texture_rect(hero_portraits[hero_id], roster_portrait_rect, false, Color.WHITE if owned else Color(0.58, 0.62, 0.58, 1.0))
	# Prawa kolumna zostawia wyraźny oddech między opisem a sylwetką bohatera.
	var info_x := 292.0
	var tier_name := roster_filter_label(str(HERO_CLASSES[hero_id]))
	var hero_accent: Texture2D = hero_accent_textures.get(hero_id, null)
	if hero_accent != null:
		draw_texture_rect(hero_accent, Rect2(info_x - 34.0, 306.0, 28.0, 28.0), false, Color(1, 1, 1, 0.9))
	else:
		var element_icons := [fire_tile_icon, water_tile_icon, leaf_tile_icon, amber_tile_icon, rune_tile_icon]
		var fallback_icon: Texture2D = element_icons[clampi(SkillTree.element(hero_id), 0, element_icons.size() - 1)]
		if fallback_icon != null:
			draw_texture_rect(fallback_icon, Rect2(info_x - 34.0, 306.0, 28.0, 28.0), false, Color.WHITE)
		else:
			draw_circle(Vector2(info_x - 20.0, 320.0), 11.0, Color("#d9a93e"))
	draw_string(font, Vector2(info_x, 332), hero_name(hero_id).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, 200, 35, Color("#ffe2a0"))
	draw_string(font, Vector2(info_x, 351), tier_name, HORIZONTAL_ALIGNMENT_LEFT, 200, 15, Color("#f0d487"))
	draw_string(font, Vector2(info_x, 384), "POZIOM %d / %d" % [hero_levels[hero_id], MAX_HERO_LEVEL], HORIZONTAL_ALIGNMENT_LEFT, 200, 18, Color("#d8efe1"))
	var experience_ratio := clampf(float(hero_experience[hero_id]) / float(maxi(1, hero_experience_to_next_level(hero_id))), 0.0, 1.0)
	var experience_bar := Rect2(info_x - 9.0, 424.0, 215.0, 59.0)
	var fill_rect := Rect2(experience_bar.position + Vector2(21, 23), Vector2((experience_bar.size.x - 42) * experience_ratio, 12))
	draw_rect(Rect2(experience_bar.position + Vector2(21, 23), Vector2(experience_bar.size.x - 42, 12)), Color("#08271f"))
	if fill_rect.size.x > 0.0:
		for gradient_row in range(int(fill_rect.size.y)):
			var t := float(gradient_row) / float(maxi(1, int(fill_rect.size.y) - 1))
			var fill_color := Color("#baffdf").lerp(Color("#159f86"), t)
			draw_line(Vector2(fill_rect.position.x, fill_rect.position.y + gradient_row), Vector2(fill_rect.end.x, fill_rect.position.y + gradient_row), fill_color, 1.0)
	if experience_bar_frame != null:
		draw_texture_rect(experience_bar_frame, experience_bar, false)
	else:
		draw_rect(experience_bar, Color("#d9af52"), false, 2.0)
	draw_string(font, Vector2(info_x - 5, 418), "%d / %d PD" % [hero_experience[hero_id], hero_experience_to_next_level(hero_id)], HORIZONTAL_ALIGNMENT_CENTER, 200, 15, Color("#bdf9e6"))
	# Zdolność pozostaje czytelna, a współpraca pokazuje twarze partnerów.
	draw_string(font, Vector2(info_x, 502), "ZDOLNOŚĆ", HORIZONTAL_ALIGNMENT_LEFT, 190, 16, Color("#f4d06d"))
	draw_multiline_string(font, Vector2(info_x, 531), HERO_SKILLS[hero_id], HORIZONTAL_ALIGNMENT_LEFT, 192, 16, 21, Color("#e8f0d8"))
	var tree_points := SkillTree.points_left(hero_trees.get(hero_id, {}), int(hero_levels[hero_id])) if owned else 0
	if not talent_roster_tutorial_active():
		draw_roster_action_button(roster_skill_tree_rect(), "TALENTY  •  %d" % tree_points, true)
	draw_string(font, Vector2(info_x, 596), "WSPÓŁPRACA", HORIZONTAL_ALIGNMENT_LEFT, 190, 16, Color("#f4d06d"))
	var partners := synergy_portrait_ids(hero_id)
	var portrait_size := 54.0
	var portrait_gap := 26.0
	var portraits_width := partners.size() * portrait_size + maxi(0, partners.size() - 1) * portrait_gap
	var portraits_x := info_x + (200.0 - portraits_width) * 0.5
	for partner_index in partners.size():
		var partner_id: String = partners[partner_index]
		var thumb := Rect2(portraits_x + partner_index * (portrait_size + portrait_gap), 602.0, portrait_size, portrait_size)
		var partner_owned := bool(owned_heroes.get(partner_id, false))
		var portrait: Texture2D = hero_portraits.get(partner_id, null)
		if portrait != null:
			var source_size := portrait.get_size()
			var crop_size := minf(source_size.x, source_size.y)
			var source_rect := Rect2((source_size.x - crop_size) * 0.5, 0.0, crop_size, crop_size)
			draw_texture_rect_region(portrait, thumb, source_rect, Color.WHITE if partner_owned else Color(0.52, 0.60, 0.56, 1.0))
		draw_string(font, Vector2(thumb.position.x - 10.0, thumb.end.y + 15.0), hero_name(partner_id), HORIZONTAL_ALIGNMENT_CENTER, thumb.size.x + 20.0, 11, Color("#fff0c7") if partner_owned else Color("#aeb9a9"))
	var team_button := roster_team_toggle_rect()
	if owned and in_party:
		if roster_team_leafy_button != null:
			draw_texture_rect(roster_team_leafy_button, team_button, false)
		else:
			draw_style_box(make_panel(Color("#237158"), Color("#f4d06d")), team_button)
		draw_string(font, Vector2(team_button.position.x, team_button.position.y + 42), "W SKŁADZIE", HORIZONTAL_ALIGNMENT_CENTER, team_button.size.x, 17, Color("#f4ffd7"))
	elif owned:
		if roster_team_leafy_button != null:
			draw_texture_rect(roster_team_leafy_button, team_button, false)
			draw_string(font, Vector2(team_button.position.x, team_button.position.y + 42), "+ DODAJ DO SKŁADU", HORIZONTAL_ALIGNMENT_CENTER, team_button.size.x, 15, Color("#f4ffd7"))
		else:
			draw_button(team_button, "+ DODAJ DO SKŁADU", true, 13)
	else:
		draw_string(font, Vector2(team_button.position.x, team_button.position.y + 31), "NIEZREKRUTOWANY", HORIZONTAL_ALIGNMENT_CENTER, team_button.size.x, 14, Color("#bac6b7"))
	var max_level := owned and int(hero_levels[hero_id]) >= MAX_HERO_LEVEL
	var currency := hero_recruit_currency(hero_id)
	var action_label := "MAKS. POZIOM" if max_level else ("ULEPSZ" if owned else "REKRUTUJ")
	var action_cost := upgrade_cost(hero_id) if owned else int(HERO_RECRUIT_COSTS.get(hero_id, 0))
	var available := coins if owned or currency == "coins" else (perun_sparks if currency == "sparks" else event_marks)
	var action_rect := roster_upgrade_rect()
	var enough_experience := owned and int(hero_experience[hero_id]) >= hero_experience_to_next_level(hero_id)
	var action_enabled := not max_level and (not owned or (available >= action_cost and enough_experience))
	draw_roster_action_button(action_rect, action_label if max_level else "", action_enabled)
	if not max_level:
		var icon_kind := "coins" if owned or currency == "coins" else ("sparks" if currency == "sparks" else "marks")
		var icon := resource_icon(icon_kind)
		var label_size := 18
		var cost_size := 17
		var label_width := font.get_string_size(action_label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size).x
		var cost_width := font.get_string_size(str(action_cost), HORIZONTAL_ALIGNMENT_LEFT, -1, cost_size).x
		var content_width := label_width + 5.0 + 23.0 + 2.0 + cost_width
		var content_x := action_rect.get_center().x - content_width * 0.5
		var text_color := Color("#fff1bd") if action_enabled else Color("#a7a99d")
		draw_string(font, Vector2(content_x, action_rect.get_center().y + 6), action_label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, text_color)
		if icon != null:
			draw_texture_rect(icon, Rect2(content_x + label_width + 5.0, action_rect.get_center().y - 13.0, 23.0, 23.0), false)
		else:
			draw_circle(Vector2(content_x + label_width + 16.5, action_rect.get_center().y - 1.5), 10.0, Color("#d8b25c"))
		draw_string(font, Vector2(content_x + label_width + 30.0, action_rect.get_center().y + 6), str(action_cost), HORIZONTAL_ALIGNMENT_LEFT, -1, cost_size, text_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var filtered := roster_filter_ids()
	if roster_arrow_left != null:
		draw_texture_rect(roster_arrow_left, roster_previous_page_rect(), false, Color.WHITE if filtered.size() > 1 else Color(0.42, 0.44, 0.40, 0.75))
	else:
		draw_button(roster_previous_page_rect(), "◀", filtered.size() > 1, 18)
	draw_string(font, Vector2(0, 819), "%d / %d" % [roster_hero_index + 1, filtered.size()], HORIZONTAL_ALIGNMENT_CENTER, screen.x, 16, Color("#f5d998"))
	if roster_arrow_right != null:
		draw_texture_rect(roster_arrow_right, roster_next_page_rect(), false, Color.WHITE if filtered.size() > 1 else Color(0.42, 0.44, 0.40, 0.75))
	else:
		draw_button(roster_next_page_rect(), "▶", filtered.size() > 1, 18)
	draw_roster_action_button(roster_close_rect(), "WRÓĆ", true)
	if roster_swap_open:
		draw_roster_swap_popup(screen)

func roster_swap_choice_rect(index: int) -> Rect2:
	return Rect2(15.0 + index * 172.0, 272.0, 166.0, 300.0)

func roster_swap_cancel_rect() -> Rect2:
	return Rect2(175.0, 690.0, 190.0, 48.0)

func draw_roster_swap_popup(screen: Vector2) -> void:
	# Pełne tło zasłania poprzedni ekran kolekcji i jego przyciski.
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#071712"))
	if roster_swap_panel != null:
		var source_size := roster_swap_panel.get_size()
		var cover_scale := maxf(screen.x / source_size.x, screen.y / source_size.y)
		var cover_size := source_size * cover_scale
		draw_texture_rect(roster_swap_panel, Rect2((screen - cover_size) * 0.5, cover_size), false)
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.01, 0.04, 0.03, 0.25))
	draw_string(font, Vector2(0, 197), "SKŁAD JEST PEŁNY", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 34, Color("#ffe5a4"))
	# Ozdobnik znajduje się w całości pod tytułem.
	if roster_section_header != null:
		draw_texture_rect(roster_section_header, Rect2(62.0, 205.0, screen.x - 124.0, 25.0), false, Color.WHITE)
	draw_string(font, Vector2(20, 253), "Wybierz bohatera do wymiany:", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 40, 19, Color("#f0e6c4"))
	for index in active_heroes.size():
		var hero_id: String = active_heroes[index]
		var choice_rect := roster_swap_choice_rect(index)
		# Ciemne liście wewnątrz oprawy oddzielają postać od jasnego krajobrazu.
		if roster_swap_card_backdrop != null:
			draw_texture_rect(roster_swap_card_backdrop, choice_rect, false, Color.WHITE)
		var portrait: Texture2D = hero_portraits.get(hero_id, null)
		if portrait != null:
			var swap_portrait_rect := texture_aspect_fit_rect(portrait, Rect2(choice_rect.position + Vector2(12, 20), Vector2(142, 174)))
			draw_texture_rect(portrait, swap_portrait_rect, false)
		# Jedna nowa grafika zawiera złotą oprawę, podpis i przycisk.
		if roster_swap_card_frame != null:
			draw_texture_rect(roster_swap_card_frame, choice_rect, false, Color.WHITE)
		draw_string(font, Vector2(choice_rect.position.x + 12, choice_rect.position.y + 236), hero_name(hero_id), HORIZONTAL_ALIGNMENT_CENTER, choice_rect.size.x - 24, 18, Color("#fff4c8"))
		draw_string(font, Vector2(choice_rect.position.x + 12, choice_rect.position.y + 263), "WYMIEŃ", HORIZONTAL_ALIGNMENT_CENTER, choice_rect.size.x - 24, 17, Color("#fff4c8"))
	draw_roster_action_button(roster_swap_cancel_rect(), "ANULUJ", true)

func draw_skill_node_icon(center: Vector2, hero_id: String, branch: int, tier: int, unlocked: bool, rank: int) -> void:
	var icon_rank := clampi(rank, 1, SkillTree.RANK_CAPS[tier])
	# Czwarty poziom każdej kolumny korzysta z trzech osobnych ikon mistrzostwa.
	# Dzięki temu nie próbujemy ładować nieistniejących plików moc_3/opieka_3/splot_3.
	var icon_branch: String = "master" if tier == 3 else str(SkillTree.BRANCHES[branch])
	var icon_tier: int = branch if tier == 3 else tier
	var key := "%s_%s_%d_r%d" % [hero_id, icon_branch, icon_tier, icon_rank]
	if not skill_icons.has(key):
		var icon_path := "res://art/skills/skill_%s.png" % key
		var loaded_icon := load_image_texture(icon_path)
		# Rangi są opcjonalnymi wariantami — jeśli dana gałąź ma mniej rang,
		# użyj czystej ikony bazowej zamiast wracać do starego placeholdera.
		if loaded_icon == null:
			loaded_icon = load_image_texture("res://art/skills/skill_%s_%s_%d.png" % [hero_id, icon_branch, icon_tier])
		skill_icons[key] = loaded_icon
	var icon: Texture2D = skill_icons[key]
	if icon != null:
		draw_texture_rect(icon, Rect2(center - Vector2(31, 31), Vector2(62, 62)), false, Color.WHITE if unlocked else Color(0.43, 0.49, 0.45, 0.85))
		return
	var glow := Color("#d6a545") if unlocked else Color("#56665c")
	var inside := Color("#153d34") if unlocked else Color("#1b2725")
	draw_circle(center, 25.0, glow)
	draw_circle(center, 22.0, inside)
	match branch:
		0:
			draw_line(center + Vector2(-15, 12), center + Vector2(12, -15), glow, 3.0, true)
			draw_line(center + Vector2(-12, -14), center + Vector2(14, 12), glow, 3.0, true)
		1:
			var shield := PackedVector2Array([center + Vector2(0, -19), center + Vector2(16, -10), center + Vector2(12, 10), center + Vector2(0, 19), center + Vector2(-12, 10), center + Vector2(-16, -10)])
			draw_colored_polygon(shield, Color("#2a5d4b") if unlocked else Color("#29312e"))
			for point_index in shield.size():
				draw_line(shield[point_index], shield[(point_index + 1) % shield.size()], glow, 2.0, true)
		2:
			for arm in 4:
				var direction := Vector2.RIGHT.rotated(TAU * arm / 4.0)
				draw_line(center + direction * 10.0, center + direction * 18.0, glow, 2.5, true)
	var element_icons := [fire_tile_icon, water_tile_icon, leaf_tile_icon, amber_tile_icon, rune_tile_icon]
	var core: Texture2D = element_icons[SkillTree.element(hero_id)]
	if core != null:
		draw_texture_rect(core, Rect2(center - Vector2(13, 13), Vector2(26, 26)), false, Color.WHITE if unlocked else Color(0.45, 0.5, 0.48, 1.0))
	# Pięć runicznych nacięć koduje numer bohatera. Dzięki temu nawet postacie
	# tego samego żywiołu mają własny znak, a ikony skalują się bez osobnych PNG.
	var hero_mark := maxi(0, HERO_IDS.find(hero_id)) + 1
	for notch in 5:
		if (hero_mark & (1 << notch)) == 0:
			continue
		var angle := PI * (1.1 + float(notch) * 0.2)
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(center + direction * 18.0, center + direction * 23.0, Color("#fff0b6") if unlocked else Color("#859087"), 2.0, true)
	for pip in tier + 1:
		var pip_x := center.x - float(tier) * 5.0 + pip * 10.0
		draw_circle(Vector2(pip_x, center.y + 28.0), 2.5, glow)

func draw_skill_tree_overlay(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#071610"))
	var hero_id := selected_roster_hero_id()
	var background_key := hero_id
	if not skill_tree_backgrounds.has(background_key):
		skill_tree_backgrounds[background_key] = load("res://art/skill_backgrounds/skill_tree_%s.png" % hero_id) as Texture2D
	var background: Texture2D = skill_tree_backgrounds[background_key]
	if background != null:
		draw_texture_rect(background, Rect2(Vector2.ZERO, screen), false, Color.WHITE)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#07161088"))
	var owned := bool(owned_heroes.get(hero_id, false))
	var level := int(hero_levels[hero_id])
	var tree: Dictionary = hero_trees.get(hero_id, {})
	draw_string(font, Vector2(0, 22), "DRZEWKO UMIEJĘTNOŚCI", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 24, Color("#ffe3a0"))
	draw_string(font, Vector2(0, 53), "%s  •  POZIOM %d" % [hero_name(hero_id).to_upper(), level], HORIZONTAL_ALIGNMENT_CENTER, screen.x, 17, Color("#d9efca"))
	draw_string(font, Vector2(0, 80), "WOLNE PUNKTY: %d  •  DOTKNIJ TALENTU" % (SkillTree.points_left(tree, level) if owned else 0), HORIZONTAL_ALIGNMENT_CENTER, screen.x, 14, Color("#a9e9cf"))
	# Delikatne, szerokie przyciemnienie pod każdą ścieżką poprawia kontrast ikon
	# bez zasłaniania indywidualnego tła bohatera.
	for branch in SkillTree.BRANCHES.size():
		var shade_rect := Rect2(12.0 + branch * 168.0, 154.0, 164.0, 570.0)
		draw_rect(shade_rect, Color(0.01, 0.06, 0.05, 0.38))
	for branch in SkillTree.BRANCHES.size():
		var branch_x := 24.0 + branch * 168.0
		if branch < skill_branch_headers.size() and skill_branch_headers[branch] != null:
			draw_texture_rect(skill_branch_headers[branch], Rect2(branch_x - 14.0, 102.0, 184.0, 154.0), false, Color.WHITE)
		draw_string(font, Vector2(branch_x, 187), SkillTree.branch_name(hero_id, branch).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 156.0, 12, Color("#f0cb76"))
		for tier in SkillTree.RANK_CAPS.size():
			var card := skill_tree_node_rect(branch, tier)
			var rank := SkillTree.ranks(tree, branch, tier)
			var can_buy := owned and SkillTree.can_invest(tree, level, branch, tier)
			var selected := skill_tree_selected_branch == branch and skill_tree_selected_tier == tier
			var unlocked := rank > 0 or can_buy
			if tier > 0:
				var previous := skill_tree_node_rect(branch, tier - 1)
				var connector_color := Color("#d5af62") if SkillTree.ranks(tree, branch, tier - 1) == SkillTree.RANK_CAPS[tier - 1] else Color("#536253")
				var connector_top := Vector2(card.get_center().x, card.end.y + 4.0)
				var connector_bottom := Vector2(card.get_center().x, previous.position.y - 8.0)
				if skill_tree_connector_arrow != null:
					var arrow_slot := Rect2(Vector2(card.get_center().x - 27.0, connector_top.y), Vector2(54.0, connector_bottom.y - connector_top.y))
					var arrow_rect := texture_aspect_fit_rect(skill_tree_connector_arrow, arrow_slot)
					draw_texture_rect(skill_tree_connector_arrow, arrow_rect, false, Color.WHITE if connector_color == Color("#d5af62") else Color(0.58, 0.64, 0.59, 0.85))
				else:
					draw_line(connector_top, connector_bottom, connector_color, 2.5, true)
					var arrow := PackedVector2Array([Vector2(connector_bottom.x - 7.0, connector_bottom.y - 10.0), Vector2(connector_bottom.x + 7.0, connector_bottom.y - 10.0), Vector2(connector_bottom.x, connector_bottom.y)])
					draw_colored_polygon(arrow, connector_color)
			# Węzeł pozostaje bez karty i ramki: czytelność zapewniają sama ikona,
			# podpis oraz delikatna linia zależności między progami.
			var node_center := card.position + Vector2(card.size.x * 0.5, 35)
			if talent_tutorial_active() and not talent_tutorial_node_selected and branch == 0 and tier == 0:
				var node_scale := 1.0 + 0.045 * (0.5 + 0.5 * sin(ui_anim_time * 3.2))
				draw_set_transform(node_center * (1.0 - node_scale), 0.0, Vector2.ONE * node_scale)
				draw_skill_node_icon(node_center, hero_id, branch, tier, unlocked, rank)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				draw_skill_node_icon(node_center, hero_id, branch, tier, unlocked, rank)
			var skill_label := SkillTree.branch_name(hero_id, branch).to_upper()
			draw_string(font, Vector2(card.position.x + 5, card.position.y + 82), skill_label, HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 10, 10, Color("#fff0c7") if unlocked else Color("#aab5a8"))
			draw_string(font, Vector2(card.position.x + 5, card.position.y + 97), "%d / %d  •  POZ. %d" % [rank, SkillTree.RANK_CAPS[tier], SkillTree.LEVEL_GATES[tier]], HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 10, 10, Color("#b8e8bf") if can_buy else Color("#a7ae9c"))
	var selected_branch := skill_tree_selected_branch
	var selected_tier := skill_tree_selected_tier
	var selected_title := SkillTree.node_name(hero_id, selected_branch, selected_tier)
	var selected_rank := SkillTree.ranks(tree, selected_branch, selected_tier)
	var details := SkillTree.node_details(hero_id, selected_branch, selected_tier)
	if skill_description_parchment != null:
		draw_texture_rect(skill_description_parchment, Rect2(8.0, 704.0, screen.x - 16.0, 234.0), false, Color.WHITE)
	draw_skill_node_icon(Vector2(426, 812), hero_id, selected_branch, selected_tier, selected_rank > 0, selected_rank)
	draw_string(font, Vector2(134, 783), "%s  •  %d/%d" % [selected_title, selected_rank, SkillTree.RANK_CAPS[selected_tier]], HORIZONTAL_ALIGNMENT_LEFT, 330, 16, Color("#4b321b"))
	draw_string(font, Vector2(134, 805), details[0], HORIZONTAL_ALIGNMENT_LEFT, 330, 13, Color("#5b4327"))
	draw_string(font, Vector2(134, 823), details[1], HORIZONTAL_ALIGNMENT_LEFT, 330, 13, Color("#5b4327"))
	var can_buy := owned and SkillTree.can_invest(tree, level, selected_branch, selected_tier)
	var blocker := SkillTree.invest_blocker(tree, level, selected_branch, selected_tier) if owned else "Najpierw zdobądź tego bohatera."
	draw_string(font, Vector2(24, 843), blocker, HORIZONTAL_ALIGNMENT_CENTER, screen.x - 48, 12, Color("#3f714e") if can_buy else Color("#7c3d2f"))
	if not (talent_tutorial_active() and talent_tutorial_node_selected):
		draw_roster_action_button(skill_tree_upgrade_rect(), "ODBLOKUJ  •  1 PUNKT" if selected_rank == 0 else "ULEPSZ  •  1 PUNKT", can_buy)
	var back_rect := skill_tree_back_rect()
	draw_roster_action_button(back_rect, "POWRÓT", true)

func draw_skill_tree_tutorial(screen: Vector2) -> void:
	var target := skill_tree_upgrade_rect() if talent_tutorial_node_selected else skill_tree_node_rect(0, 0)
	if talent_tutorial_node_selected:
		var scale_factor := 1.0 + 0.014 * (0.5 + 0.5 * sin(ui_anim_time * 3.4))
		var center := target.get_center()
		draw_set_transform(center * (1.0 - scale_factor), 0.0, Vector2.ONE * scale_factor)
		draw_roster_action_button(target, "ODBLOKUJ  •  1 PUNKT", true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var panel := Rect2(24.0, 86.0, screen.x - 48.0, 92.0)
	if tutorial_tooltip_banner != null:
		draw_texture_rect(tutorial_tooltip_banner, panel, false)
	else:
		draw_style_box(make_panel(Color("#10271ff5"), Color("#d9b75e")), panel)
	draw_string(font, Vector2(panel.position.x + 10.0, panel.position.y + 35.0), "SAMOUCZEK  •  KROK 2/2", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 20.0, 15, Color("#f5d998"))
	var instruction := "Teraz dodaj umiejętność: dotknij ODBLOKUJ • 1 PUNKT." if talent_tutorial_node_selected else "Wybierz pulsujący talent Lady, aby zobaczyć jego działanie."
	draw_multiline_string(font, Vector2(panel.position.x + 16.0, panel.position.y + 61.0), instruction, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 32.0, 13, 17, Color("#fff0c7"))

func draw_roster_action_button(rect: Rect2, label: String, enabled: bool) -> void:
	if roster_action_button != null:
		draw_texture_rect(roster_action_button, rect, false, Color.WHITE if enabled else Color(0.35, 0.4, 0.38, 0.9))
	else:
		draw_button(rect, label, enabled, 16)
		return
	var label_size := 17 if rect.size.y >= 70.0 else 14
	# Baseline is offset by the font's visual ascent so the label sits in the
	# optical vertical center of the decorative button.
	var label_y := rect.get_center().y + label_size * 0.36
	draw_string(font, Vector2(rect.position.x, label_y), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, label_size, Color("#fff1bd") if enabled else Color("#a7a99d"))

func draw_village_overlay(screen: Vector2) -> void:
	if village_layout != null:
		draw_texture_rect(village_layout, Rect2(Vector2.ZERO, screen), false)
	elif village_background != null:
		draw_texture_rect(village_background, Rect2(Vector2.ZERO, screen), false)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#07130d20"))
	var protected_buildings: Array[Rect2] = [Rect2(0, 0, screen.x, 160), Rect2(0, screen.y - 160, screen.x, 160)]
	for building_id in BUILDING_IDS:
		protected_buildings.append(village_building_rect(building_id))
		protected_buildings.append(village_building_label_rect(building_id))
	protected_buildings.append(village_sawmill_stock_rect())
	if village_selected_id != "":
		protected_buildings.append(village_inspector_rect())
	player_opening.draw_background_fireflies(self, screen, protected_buildings)
	for building_id in BUILDING_IDS:
		draw_village_building(building_id)
	if int(building_levels.get("tartak", 0)) > 0:
		var stock_rect := village_sawmill_stock_rect()
		draw_button(stock_rect, "", true)
		var amount_width := resource_amount_width(sawmill_stored_wood, 26.0, 15)
		draw_resource_amount(Vector2(stock_rect.get_center().x - amount_width * 0.5, stock_rect.get_center().y - 13.0), "wood", sawmill_stored_wood, 26.0, 15, Color("#fff1c8"))
	if map_ui_frames != null:
		var frame_size := map_ui_frames.get_size()
		var header_source := Rect2(0.0, frame_size.y * 0.10, frame_size.x, frame_size.y * 0.40)
		draw_texture_rect_region(map_ui_frames, Rect2(8.0, -16.0, screen.x - 16.0, 170.0), header_source, Color.WHITE)
	else:
		draw_style_box(make_panel(Color("#10271ff0"), Color("#bc9659")), Rect2(5.0, 4.0, screen.x - 10.0, 96.0))
	if not (village_tutorial_active() and player_opening.home_tutorial_step == "sawmill_built"):
		draw_button(village_close_rect(), "POWRÓT", true, 16)
	var title := "OSADA DĘBOWEGO POGRANICZA"
	if screen.x < 430.0:
		draw_string(font, Vector2(76.0, 55.0), "OSADA DĘBOWEGO", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 84.0, 17, Color("#ffe0a0"))
		draw_string(font, Vector2(76.0, 74.0), "POGRANICZA", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 84.0, 17, Color("#ffe0a0"))
	else:
		var title_size := 19
		while title_size > 14 and font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x > screen.x - 90.0:
			title_size -= 1
		draw_string(font, Vector2(78.0, 62.0), title, HORIZONTAL_ALIGNMENT_CENTER, screen.x - 88.0, title_size, Color("#ffe0a0"))
	var resource_size := 16
	var resource_width := resource_amount_width(coins, 27.0, resource_size) + 32.0 + resource_amount_width(wood, 27.0, resource_size)
	var resource_x := maxf(82.0, (screen.x - resource_width) * 0.5)
	resource_x += draw_resource_amount(Vector2(resource_x, 80.0), "coins", coins, 27.0, resource_size, Color("#ffe5a8")) + 32.0
	draw_resource_amount(Vector2(resource_x, 80.0), "wood", wood, 27.0, resource_size, Color("#e2eac7"))
	if village_selected_id == "" and not village_tutorial_active():
		var goal_rect := village_next_goal_rect()
		if village_goal_plaque != null:
			draw_texture_rect(village_goal_plaque, goal_rect, false)
		var goal_lines := village_next_goal_text().split("\n")
		var goal_width := goal_rect.size.x - 64.0
		var goal_y := goal_rect.position.y + 39.0 * goal_rect.size.y / 81.0 + 7.0
		for line_index in goal_lines.size():
			var goal_size := 12 if line_index == 0 else 11
			while goal_size > 9 and font.get_string_size(goal_lines[line_index], HORIZONTAL_ALIGNMENT_LEFT, -1, goal_size).x > goal_width:
				goal_size -= 1
			draw_string(font, Vector2(goal_rect.position.x + 32.0, goal_y + line_index * 15.0), goal_lines[line_index], HORIZONTAL_ALIGNMENT_CENTER, goal_width, goal_size, Color("#fff0c7"))
		draw_button(village_expeditions_rect(), "WYPRAWY LEŚNE", true, 14)
		var mastered := mastery_claims.size()
		var mastery_width := minf(440.0, screen.x - 28.0)
		var mastery_panel := Rect2((screen.x - mastery_width) * 0.5, screen.y - 143.0, mastery_width, 65.0)
		if village_mastery_plaque != null:
			draw_texture_rect(village_mastery_plaque, mastery_panel, false)
		var medallion := Rect2(mastery_panel.position + Vector2(8.0, 5.0), Vector2(55.0, 55.0))
		var mastery_text_x := mastery_panel.position.x + 69.0
		var mastery_text_width := mastery_width - 109.0
		if mastered >= 5:
			var rank_name := "Wieniec Dębu" if mastered < 20 else ("Sztandar Gaju" if mastered < 50 else "Pieczęć Peruna")
			if village_mastery_badges != null:
				var badge_index := 0 if mastered < 20 else (1 if mastered < 50 else 2)
				var cell_width := village_mastery_badges.get_width() / 3.0
				var badge_region := Rect2(badge_index * cell_width, 0.0, cell_width, village_mastery_badges.get_height())
				draw_texture_rect_region(village_mastery_badges, medallion, badge_region)
			draw_string(font, Vector2(mastery_text_x, mastery_panel.position.y + 29.0), rank_name, HORIZONTAL_ALIGNMENT_CENTER, mastery_text_width, 13, Color("#ffe5a8"))
			draw_string(font, Vector2(mastery_text_x, mastery_panel.position.y + 45.0), "%d mistrzostw" % mastered, HORIZONTAL_ALIGNMENT_CENTER, mastery_text_width, 11, Color("#eee0bd"))
		else:
			draw_string(font, Vector2(medallion.position.x + 15.0, medallion.get_center().y + 3.0), "%d/5" % mastered, HORIZONTAL_ALIGNMENT_CENTER, medallion.size.x, 14, Color("#ffe5a8"))
			draw_string(font, Vector2(mastery_text_x, mastery_panel.position.y + 29.0), "MISTRZOSTWA", HORIZONTAL_ALIGNMENT_CENTER, mastery_text_width, 12, Color("#ffe5a8"))
			draw_string(font, Vector2(mastery_text_x, mastery_panel.position.y + 45.0), "Nagroda: Wieniec Dębu", HORIZONTAL_ALIGNMENT_CENTER, mastery_text_width, 11, Color("#eee0bd"))
	if village_selected_id != "":
		draw_village_inspector()
	if village_tutorial_active():
		draw_village_tutorial(screen)

func village_illustration(building_id: String, level: int) -> Texture2D:
	if building_id == "tartak" and village_sawmill_stages.size() == 3:
		return village_sawmill_stages[0 if level <= 6 else (1 if level < 26 else 2)]
	if building_id in ["domostwa", "swiety_gaj", "wieza_peruna", "kuznia", "chata_zielarki", "spichlerz"]:
		var bright_key := "bright_%s_%02d" % [building_id, clampi(level, 0, MAX_BUILDING_LEVEL)]
		if not village_level_illustrations.has(bright_key):
			var bright_path := "res://art/environments/building_levels_bright/%s/building_%s_level_%02d.png" % [building_id, building_id, clampi(level, 0, MAX_BUILDING_LEVEL)]
			village_level_illustrations[bright_key] = load_image_texture(bright_path)
		var bright_illustration := village_level_illustrations.get(bright_key, null) as Texture2D
		if bright_illustration != null:
			return bright_illustration
	if level > 0:
		var exact_level := clampi(level, 1, MAX_BUILDING_LEVEL)
		var cache_key := "%s_%02d" % [building_id, exact_level]
		if not village_level_illustrations.has(cache_key):
			var exact_path := "res://art/environments/building_levels/%s/building_%s_level_%02d.png" % [building_id, building_id, exact_level]
			village_level_illustrations[cache_key] = load_image_texture(exact_path)
		var exact_illustration := village_level_illustrations.get(cache_key, null) as Texture2D
		if exact_illustration != null:
			return exact_illustration
	if level <= 6:
		var starting := village_starting_illustrations.get(building_id, null) as Texture2D
		if starting != null:
			return starting
	if level >= 26:
		var upgraded := village_upgraded_illustrations.get(building_id, null) as Texture2D
		if upgraded != null:
			return upgraded
	match building_id:
		"domostwa": return domostwa_illustration
		"kuznia": return kuznia_illustration
		"chata_zielarki": return chata_zielarki_illustration
		"swiety_gaj": return swiety_gaj_illustration
		"spichlerz": return spichlerz_illustration
		"wieza_peruna": return wieza_peruna_illustration
		"tartak": return village_starting_illustrations.get("tartak", null) as Texture2D
		"dwor_wiecowy": return village_starting_illustrations.get("dwor_wiecowy", null) as Texture2D
	return null

func village_art_rect(rect: Rect2, level: int) -> Rect2:
	var building_id := village_art_id_for_offset(rect)
	if building_id != "":
		# Stała podstawa na polanie; rozwój nie wypycha budynku na ścieżkę.
		var plot_scale := 0.92 + clampf(float(level), 0.0, 10.0) * 0.008
		var plot_size := rect.size * plot_scale
		var label_top := village_building_label_rect(building_id).position.y
		return Rect2(Vector2(rect.get_center().x - plot_size.x * 0.5, label_top - plot_size.y + 8.0), plot_size)
	# Podglądy TERAZ/DALEJ mieszczą się w swoim kadrze na każdym poziomie.
	return rect

func village_art_id_for_offset(rect: Rect2) -> String:
	for building_id in BUILDING_IDS:
		if village_building_rect(building_id).position.distance_to(rect.position) < 1.0:
			return building_id
	return ""

func draw_village_construction(rect: Rect2, progress: float) -> void:
	if village_upgrade_vfx_frames != null:
		var frame_index := clampi(int(floor(progress * 10.0)), 0, 9)
		var frame_width := village_upgrade_vfx_frames.get_width() / 10.0
		var effect_source := Rect2(frame_index * frame_width, 0.0, frame_width, village_upgrade_vfx_frames.get_height())
		var effect_size := Vector2(rect.size.x * 1.55, rect.size.y * 1.65)
		var source_aspect := effect_source.size.x / effect_source.size.y
		var contain_size := effect_size
		if contain_size.x / contain_size.y > source_aspect:
			contain_size.x = contain_size.y * source_aspect
		else:
			contain_size.y = contain_size.x / source_aspect
		var effect_rect := Rect2(Vector2(rect.get_center().x - contain_size.x * 0.5, rect.end.y - contain_size.y + rect.size.y * 0.12), contain_size)
		draw_texture_rect_region(village_upgrade_vfx_frames, effect_rect, effect_source, Color(1.0, 1.0, 1.0, 0.92))

func draw_village_building(building_id: String) -> void:
	var rect := village_building_rect(building_id)
	var level := int(building_levels[building_id])
	var animating := village_upgrade_id == building_id and village_upgrade_time > 0.0
	var progress := 1.0 - village_upgrade_time / VILLAGE_UPGRADE_DURATION if animating else 1.0
	if animating and progress < 0.52:
		level = village_upgrade_from_level
	var sprite := village_illustration(building_id, level)
	var upgrade_ready := not animating and building_upgrade_available(building_id)
	if upgrade_ready and building_id != "domostwa":
		draw_village_upgrade_alert(building_id, rect)
	if not animating and sprite != null:
		var display_rect := village_art_rect(rect, level)
		draw_texture_rect(sprite, display_rect, false)
	if upgrade_ready and building_id == "domostwa":
		# Domostwa mają niższy znacznik, rysowany na wierzchu ich ilustracji.
		draw_village_upgrade_alert(building_id, rect)
	if animating:
		draw_village_construction(village_art_rect(rect, level), progress)
	if animating:
		return
	var label_rect := village_building_label_rect(building_id)
	if map_mission_nameplate != null:
		draw_texture_rect(map_mission_nameplate, label_rect, false, Color("#ffe0a1") if village_selected_id == building_id else Color.WHITE)
	else:
		draw_style_box(make_panel(Color("#10261ddc"), Color("#c59d5d")), label_rect)
	var index := BUILDING_IDS.find(building_id)
	var label: String = BUILDING_NAMES[index]
	var label_size := 12
	while label_size > 9 and font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size).x > label_rect.size.x - 18.0:
		label_size -= 1
	draw_string(font, Vector2(label_rect.position.x, label_rect.position.y + 22.0), label, HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x, label_size, Color("#fff1c8"))
	if upgrade_ready:
		if home_party_add_plus != null:
			draw_texture_rect(home_party_add_plus, Rect2(label_rect.get_center() - Vector2(11.0, 11.0) + Vector2(0.0, -13.0), Vector2(22.0, 22.0)), false, Color.WHITE)
		else:
			draw_circle(label_rect.get_center() + Vector2(0.0, -13.0), 9.0, Color("#1f7048"))
			draw_line(label_rect.get_center() + Vector2(-5.0, -13.0), label_rect.get_center() + Vector2(5.0, -13.0), Color("#ffe08a"), 2.0, true)
			draw_line(label_rect.get_center() + Vector2(0.0, -18.0), label_rect.get_center() + Vector2(0.0, -8.0), Color("#ffe08a"), 2.0, true)

func draw_village_upgrade_alert(building_id: String, rect: Rect2) -> void:
	var pulse := 0.5 + sin(ui_anim_time * 2.2) * 0.5
	var vertical_offset := rect.size.y * 0.08 if building_id == "domostwa" else -rect.size.y * 0.30
	if building_id == "swiety_gaj":
		vertical_offset += 60.0
	var hint_center := rect.get_center() + Vector2(rect.size.x * 0.30, vertical_offset)
	var icon_size := 42.0 + pulse * 3.0
	if village_upgrade_alert_icon != null:
		draw_texture_rect(village_upgrade_alert_icon, Rect2(hint_center - Vector2.ONE * icon_size * 0.5, Vector2.ONE * icon_size), false, Color(1.0, 1.0, 1.0, 0.88 + pulse * 0.12))

func building_upgrade_available(building_id: String) -> bool:
	if not building_levels.has(building_id):
		return false
	var level := int(building_levels[building_id])
	if level >= MAX_BUILDING_LEVEL or not building_requirement_text(building_id).is_empty():
		return false
	var cost := building_cost(building_id)
	return coins >= int(cost["coins"]) and wood >= int(cost["wood"])

func village_bonus_label(building_id: String) -> String:
	match building_id:
		"domostwa": return "+8 HP wszystkim / poziom"
		"kuznia": return "+1% obrażeń drużyny / poz."
		"chata_zielarki": return "+4 HP, +2% leczenia / poz."
		"swiety_gaj": return "+1 tarczy z liści"
		"spichlerz": return "+10 monet za wygraną"
		"wieza_peruna": return "+2% mocy zdolności / poz."
		"tartak": return "+%d drewna / godz." % int(round(float(maxi(1, int(building_levels.get("tartak", 0)))) * SAWMILL_WOOD_PER_HOUR_PER_LEVEL))
		"dwor_wiecowy": return "Limit budynków: %d" % maxi(1, int(building_levels.get("dwor_wiecowy", 0)))
	return ""

func draw_village_tutorial(screen: Vector2) -> void:
	var buy_step: bool = player_opening.home_tutorial_step == "buy_sawmill"
	var panel := Rect2(18.0, 132.0, screen.x - 36.0, 142.0)
	if tutorial_tooltip_banner != null:
		draw_texture_rect(tutorial_tooltip_banner, panel, false)
	else:
		draw_style_box(make_panel(Color("#10271ff5"), Color("#d9b75e")), panel)
	draw_string(font, Vector2(panel.position.x + 14.0, panel.position.y + 50.0), "TARTAK — ŹRÓDŁO DREWNA" if buy_step else "TARTAK JUŻ PRACUJE", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 28.0, 16, Color("#ffe5a4"))
	var hint := "Postaw tartak — jest darmowy. Będzie wytwarzał 20 drewna na godzinę. Kliknij ZBUDUJ poniżej. Drewno posłuży do ulepszania pozostałych budynków."
	var target := village_upgrade_rect()
	if not buy_step:
		var rate := int(round(float(building_levels.get("tartak", 0)) * SAWMILL_WOOD_PER_HOUR_PER_LEVEL))
		hint = "Tartak produkuje %d drewna na godzinę. Zapas czeka w budynku: użyj ODBIERZ DREWNO. Zamknij okno przyciskiem X lub dotknij POWRÓT, aby kontynuować." % rate
		target = village_close_rect()
	draw_multiline_string(font, Vector2(panel.position.x + 18.0, panel.position.y + 73.0), hint, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 36.0, 12, 16, Color("#f0ecd9"))
	var button_scale := 1.0 + 0.022 * (0.5 + 0.5 * sin(ui_anim_time * 3.2))
	var button_center := target.get_center()
	draw_set_transform(button_center * (1.0 - button_scale), 0.0, Vector2.ONE * button_scale)
	draw_button(target, "ZBUDUJ" if buy_step else "POWRÓT", true, 16)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_village_inspector() -> void:
	var panel := village_inspector_rect()
	if village_inspector_frame != null:
		draw_texture_rect(village_inspector_frame, panel, false)
	else:
		draw_style_box(make_panel(Color("#102b20f5"), Color("#d9b56c")), panel)
	var building_id := village_selected_id
	var index := BUILDING_IDS.find(building_id)
	if index < 0:
		return
	var level := int(building_levels[building_id])
	var max_level := level >= MAX_BUILDING_LEVEL
	var requirements := building_requirement_text(building_id)
	var progression_locked := not max_level and not requirements.is_empty()
	var title: String = BUILDING_NAMES[index].to_upper()
	var title_size := 18
	while title_size > 13 and font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x > panel.size.x - 110.0:
		title_size -= 1
	draw_string(font, Vector2(panel.position.x + 48.0, panel.position.y + 83.0), title, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 96.0, title_size, Color("#ffe2a3"))
	if village_popup_close_button != null:
		draw_texture_rect(village_popup_close_button, village_inspector_close_rect(), false)
	else:
		draw_button(village_inspector_close_rect(), "X", true, 16)
	var level_text := "POZIOM %d" % level if max_level else "POZIOM %d  →  %d" % [level, level + 1]
	draw_string(font, Vector2(panel.position.x + 48.0, panel.position.y + 107.0), level_text, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 96.0, 16, Color("#e3d4ab"))
	var preview_size := minf(96.0, minf((panel.size.x - 108.0) * 0.5, panel.size.y - 280.0))
	var preview_y := panel.position.y + 105.0
	var current_rect := Rect2(panel.position.x + 52.0, preview_y, preview_size, preview_size)
	var next_rect := Rect2(panel.end.x - 52.0 - preview_size, preview_y, preview_size, preview_size)
	var current_art := village_illustration(building_id, level)
	if current_art != null:
		var current_art_rect := village_art_rect(current_rect, level)
		draw_texture_rect(current_art, current_art_rect, false)
	if not max_level:
		var next_art := village_illustration(building_id, level + 1)
		if next_art != null:
			var next_art_rect := village_art_rect(next_rect, level + 1)
			draw_texture_rect(next_art, next_art_rect, false, Color("#8f9b8c") if progression_locked else Color.WHITE)
		draw_string(font, Vector2(panel.get_center().x - 18.0, preview_y + preview_size * 0.64), "→", HORIZONTAL_ALIGNMENT_CENTER, 36.0, 25, Color("#f9cd7c"))
	draw_string(font, Vector2(current_rect.position.x, preview_y + preview_size + 17.0), "TERAZ", HORIZONTAL_ALIGNMENT_CENTER, preview_size, 12, Color("#c9d9b8"))
	if not max_level:
		draw_string(font, Vector2(next_rect.position.x, preview_y + preview_size + 17.0), "DALEJ", HORIZONTAL_ALIGNMENT_CENTER, preview_size, 12, Color("#f5d18c"))
	if building_id == "tartak" and level > 0:
		var can_collect := sawmill_stored_wood > 0 and wood < 999999999 and village_upgrade_time <= 0.0
		draw_button(village_collect_wood_rect(), "ODBIERZ DREWNO • %d" % sawmill_stored_wood, can_collect, 14)
	draw_line(Vector2(panel.position.x + 44.0, panel.end.y - 152.0), Vector2(panel.end.x - 44.0, panel.end.y - 152.0), Color("#a98851"), 1.0)
	draw_string(font, Vector2(panel.position.x + 48.0, panel.end.y - 126.0), "PREMIA: %s" % village_bonus_label(building_id), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 96.0, 14, Color("#e5edcb"))
	if max_level:
		draw_string(font, Vector2(panel.position.x + 48.0, panel.end.y - 96.0), "Budynek w pełni rozbudowany", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 96.0, 13, Color("#f5d18c"))
		draw_button(village_upgrade_rect(), "MAKS. POZIOM", false, 13)
		return
	if progression_locked:
		var lock_message := "WYMAGANIA: " + requirements
		draw_multiline_string(font, Vector2(panel.position.x + 35.0, panel.end.y - 112.0), lock_message, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 70.0, 11, 14, Color("#f5d18c"))
		draw_button(village_upgrade_rect(), "ZABLOKOWANE", false, 13)
		return
	var cost := building_cost(building_id)
	if (building_id == "tartak" and level == 0) or first_building_upgrade_free():
		var free_action_label := "PIERWSZY BUDYNEK — BEZPŁATNY" if level == 0 else "PIERWSZA ROZBUDOWA — BEZPŁATNA"
		draw_string(font, Vector2(panel.position.x + 48.0, panel.end.y - 94.0), free_action_label, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 96.0, 13, Color("#b9f0c5"))
	else:
		draw_string(font, Vector2(panel.position.x + 48.0, panel.end.y - 101.0), "KOSZT", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 96.0, 12, Color("#c7d9b7"))
		var coin_width := resource_amount_width(int(cost["coins"]), 25.0, 15)
		var wood_width := resource_amount_width(int(cost["wood"]), 25.0, 15)
		var cost_x := panel.get_center().x - (coin_width + 24.0 + wood_width) * 0.5
		draw_resource_amount(Vector2(cost_x, panel.end.y - 94.0), "coins", int(cost["coins"]), 25.0, 15, Color("#ffe5a8") if coins >= int(cost["coins"]) else Color("#f29a86"))
		draw_resource_amount(Vector2(cost_x + coin_width + 24.0, panel.end.y - 94.0), "wood", int(cost["wood"]), 25.0, 15, Color("#d9eac1") if wood >= int(cost["wood"]) else Color("#f29a86"))
	var affordable := coins >= int(cost["coins"]) and wood >= int(cost["wood"])
	var action_label := "ZBUDUJ" if level == 0 else "ROZBUDUJ"
	if not (village_tutorial_active() and player_opening.home_tutorial_step == "buy_sawmill"):
		draw_button(village_upgrade_rect(), "ROZBUDOWA..." if village_upgrade_time > 0.0 else (action_label if affordable else "BRAK SUROWCÓW"), affordable and village_upgrade_time <= 0.0, 16 if affordable else 14)

func draw_map_overlay(screen: Vector2, include_background := true, include_chrome := true, include_missions := true) -> void:
	if include_background:
		draw_map_background(screen, map_page)
	var protected_missions: Array[Rect2] = [Rect2(0, 0, screen.x, 170), Rect2(0, screen.y - 150, screen.x, 150)]
	for slot in 5:
		protected_missions.append(map_level_rect(slot).grow(20.0))
	player_opening.draw_background_fireflies(self, screen, protected_missions)
	if include_missions:
		var visible_level_count := mini(5, maxi(0, unlocked_level - map_page * 5))
		var path_points: Array[Vector2] = []
		for slot in visible_level_count:
			path_points.append(map_level_rect(slot).get_center())
		draw_map_route(path_points)
	if include_chrome:
		if map_ui_frames != null:
			var frame_size := map_ui_frames.get_size()
			var header_source := Rect2(0.0, frame_size.y * 0.10, frame_size.x, frame_size.y * 0.40)
			draw_texture_rect_region(map_ui_frames, Rect2(8.0, -6.0, screen.x - 16.0, 200.0), header_source, Color.WHITE)
		else:
			draw_style_box(make_panel(Color("#18241fdc"), Color("#d2ad62")), Rect2(18.0, 4.0, screen.x - 36.0, 182.0))
		draw_string(font, Vector2(0, 95), "MAPA ŚWIATA", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 22, Color("#ffe2a4"))
		var focus_index := clampi(map_page * 5, 0, levels.size() - 1)
		var focus_level: Dictionary = levels[focus_index] if not levels.is_empty() else {}
		draw_string(font, Vector2(0, 114), region_display_name(str(focus_level.get("region", "debowepogranicze"))).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, screen.x, 14, Color("#fff0cf"))
		draw_string(font, Vector2(0, 131), "SZLAK %d" % [map_page + 1], HORIZONTAL_ALIGNMENT_CENTER, screen.x, 11, Color("#e8d5ad"))
		var frontier := campaign_frontier_count()
		if frontier < unlocked_level and frontier < levels.size() and is_boss_level(levels[frontier]):
			var gate := boss_star_gate_status(frontier)
			draw_string(font, Vector2(18.0, 151.0), "UKOŃCZ WCZEŚNIEJSZE ETAPY  •  GWIAZDKI: %d / %d" % [int(gate.get("earned", 0)), int(gate.get("required", 0))], HORIZONTAL_ALIGNMENT_CENTER, screen.x - 36.0, 10, Color("#ffd27a"))
		if map_page > 0:
			draw_button(map_previous_page_rect(), "POPRZEDNI", true, 12)
		if map_has_unlocked_next_page():
			draw_button(map_next_page_rect(), "NASTĘPNY", true, 12)
	if include_missions:
		for slot in 5:
			var index := map_page * 5 + slot
			if index >= levels.size() or index >= unlocked_level:
				continue
			var unlocked := campaign_level_is_accessible(index)
			var node_rect := map_level_rect(slot)
			var center := node_rect.get_center()
			var level: Dictionary = levels[index]
			var boss_mission := is_boss_level(level)
			draw_map_mission_icon(center, level, boss_mission, unlocked)
			var number_rect := Rect2(center + Vector2(-29.0, 52.0 if boss_mission else 32.0), Vector2(58.0, 28.0))
			if map_level_number_plate != null:
				draw_texture_rect(map_level_number_plate, number_rect, false, Color.WHITE if unlocked else Color(0.55, 0.58, 0.55, 0.85))
			else:
				draw_style_box(make_panel(Color("#17231fe8"), Color("#d8b765" if unlocked else "#82795f")), number_rect)
			var number := str(int(level.get("id", index + 1)))
			var number_size := 12
			while number_size > 8 and font.get_string_size(number, HORIZONTAL_ALIGNMENT_LEFT, -1, number_size).x > number_rect.size.x - 18.0:
				number_size -= 1
			draw_string(font, Vector2(number_rect.position.x, number_rect.get_center().y + number_size * 0.36), number, HORIZONTAL_ALIGNMENT_CENTER, number_rect.size.x, number_size, Color("#fff1d0") if unlocked else Color("#b5b0a1"))
			var text_width := minf(190.0, screen.x * 0.36)
			var text_gap := 72.0 if boss_mission else 54.0
			var text_x := center.x + text_gap if center.x < screen.x * 0.43 else center.x - text_width - text_gap
			text_x = clampf(text_x, 12.0, screen.x - text_width - 12.0)
			var nameplate_rect := Rect2(text_x - 10.0, center.y - 36.0, text_width + 20.0, 84.0)
			if map_mission_nameplate != null:
				draw_texture_rect(map_mission_nameplate, nameplate_rect, false, Color.WHITE if unlocked else Color(0.65, 0.69, 0.65, 0.85))
			else:
				draw_style_box(make_panel(Color("#10221df2"), Color("#a88446")), nameplate_rect)
			var title_color := Color("#fff0cc") if unlocked else Color("#c0c0b2")
			if boss_mission:
				title_color = Color("#ffd17c") if unlocked else Color("#aa9272")
			var mission_name := str(level.get("name", "Wyprawa"))
			var title_size := 13
			while title_size > 9 and font.get_string_size(mission_name, HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x > text_width - 16.0:
				title_size -= 1
			draw_string(font, Vector2(text_x, center.y - 7.0), mission_name, HORIZONTAL_ALIGNMENT_CENTER, text_width, title_size, title_color)
			var mission_kind := "BOSS" if boss_mission else level_kind_label(level)
			if boss_mission and not unlocked and index < unlocked_level:
				var gate_status := boss_star_gate_status(index)
				mission_kind = "GWIAZDKI %d / %d" % [int(gate_status.get("earned", 0)), int(gate_status.get("required", 0))]
			var kind_color := Color("#ffd27a") if boss_mission else (level_kind_color(level) if unlocked else Color("#96978c"))
			draw_string(font, Vector2(text_x, center.y + 5.0), mission_kind, HORIZONTAL_ALIGNMENT_CENTER, text_width, 10, kind_color)
			var stars := int(level_stars.get(int(level.id), 0))
			draw_star_rating(Vector2(text_x + text_width * 0.5, center.y + 20.0), stars, 21.0)
	if include_chrome:
		var close_rect := map_close_rect()
		if map_ui_frames != null:
			var frame_size := map_ui_frames.get_size()
			var button_source := Rect2(frame_size.x * 0.12, frame_size.y * 0.57, frame_size.x * 0.76, frame_size.y * 0.25)
			draw_texture_rect_region(map_ui_frames, close_rect, button_source, Color.WHITE)
		else:
			draw_style_box(make_panel(Color("#1b2b22f0"), Color("#d7b363")), close_rect)
		draw_string(font, Vector2(close_rect.position.x, close_rect.position.y + 39.0), "Wróć do menu", HORIZONTAL_ALIGNMENT_CENTER, close_rect.size.x, 18, Color("#fff0c8"))

func draw_map_background_transition(screen: Vector2, progress: float) -> void:
	var blur_in := clampf(progress / 0.24, 0.0, 1.0)
	blur_in = blur_in * blur_in * (3.0 - 2.0 * blur_in)
	var target_sharp := clampf((progress - 0.64) / 0.36, 0.0, 1.0)
	target_sharp = target_sharp * target_sharp * (3.0 - 2.0 * target_sharp)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#09201d"))
	draw_map_background(screen, map_transition_from_page, null, 1.0 - progress, false)
	draw_map_background(screen, map_transition_from_page, map_transition_from_blur, blur_in * (1.0 - progress), false)
	draw_map_background(screen, map_page, map_transition_to_blur, progress, false)
	draw_map_background(screen, map_page, null, target_sharp, false)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#07191648"))

func draw_map_background(screen: Vector2, page: int, texture_override: Texture2D = null, opacity := 1.0, draw_shade := true) -> void:
	var focus_index := clampi(page * 5, 0, levels.size() - 1)
	var focus_level: Dictionary = levels[focus_index] if not levels.is_empty() else {}
	var region_id := str(focus_level.get("region", "debowepogranicze"))
	var map_background: Texture2D = texture_override if texture_override != null else map_region_backgrounds.get(region_id, oak_borderland_background)
	if map_background != null:
		var atlas_size := map_background.get_size()
		var region_range: Vector2i = MAP_REGION_RANGES.get(region_id, Vector2i(1, 20))
		var first_region_page := int(floor(float(region_range.x - 1) / 5.0))
		var region_page_count := maxi(1, int(ceili(float(region_range.y - region_range.x + 1) / 5.0)))
		var region_page := clampi(page - first_region_page, 0, region_page_count - 1)
		var page_progress := 0.5
		if region_page_count > 1:
			page_progress = float(region_page) / float(region_page_count - 1)
		var source_height := atlas_size.y * 0.84
		var source_width := minf(atlas_size.x, source_height * screen.x / screen.y)
		var source_y := (atlas_size.y - source_height) * page_progress
		var source := Rect2(Vector2((atlas_size.x - source_width) * 0.5, source_y), Vector2(source_width, source_height))
		draw_texture_rect_region(map_background, Rect2(Vector2.ZERO, screen), source, Color(1.0, 1.0, 1.0, opacity))
	if draw_shade:
		draw_rect(Rect2(Vector2.ZERO, screen), Color("#07191648"))
func draw_map_route(points: Array[Vector2]) -> void:
	for segment in range(points.size() - 1):
		var start: Vector2 = points[segment]
		var finish: Vector2 = points[segment + 1]
		var direction := (finish - start).normalized()
		var bend := Vector2(-direction.y, direction.x) * (24.0 if segment % 2 == 0 else -24.0)
		var control := (start + finish) * 0.5 + bend
		var route := PackedVector2Array()
		var vertices := PackedVector2Array()
		var uvs := PackedVector2Array()
		for step in 25:
			var t := float(step) / 24.0
			var inverse := 1.0 - t
			var point := inverse * inverse * start + 2.0 * inverse * t * control + t * t * finish
			var tangent := (2.0 * inverse * (control - start) + 2.0 * t * (finish - control)).normalized()
			var normal := Vector2(-tangent.y, tangent.x) * 10.0
			route.append(point)
			vertices.append(point - normal)
			uvs.append(Vector2(t, 0.0))
		for step in range(24, -1, -1):
			var t := float(step) / 24.0
			var inverse := 1.0 - t
			var tangent := (2.0 * inverse * (control - start) + 2.0 * t * (finish - control)).normalized()
			vertices.append(route[step] + Vector2(-tangent.y, tangent.x) * 10.0)
			uvs.append(Vector2(t, 1.0))
		if map_route_connector != null:
			draw_polygon(vertices, PackedColorArray([Color.WHITE]), uvs, map_route_connector)
		else:
			draw_polyline(route, Color("#10120ee8"), 20.0, true)
			draw_polyline(route, Color("#d7b363"), 8.0, true)

func draw_map_mission_icon(center: Vector2, level: Dictionary, boss_mission: bool, unlocked: bool) -> void:
	var radius := 60.0 if boss_mission else 39.0
	if map_mission_icon_atlas == null:
		draw_circle(center, radius - 4.0, Color("#183327e8"))
		draw_arc(center, radius - 5.0, 0.0, TAU, 40, Color("#d7b363"), 3.0, true)
		return
	var atlas_size := map_mission_icon_atlas.get_size()
	var cell_size := Vector2(atlas_size.x / 4.0, atlas_size.y / 2.0)
	var icon_index := 7 if boss_mission else map_mission_region_index(str(level.get("region", "debowepogranicze")))
	var source_position := Vector2(float(icon_index % 4) * cell_size.x, float(icon_index / 4) * cell_size.y)
	var source := Rect2(source_position, cell_size)
	var tint := Color(1.0, 1.0, 1.0, 1.0 if unlocked else 0.48)
	draw_texture_rect_region(map_mission_icon_atlas, Rect2(center - Vector2.ONE * radius, Vector2.ONE * radius * 2.0), source, tint)

func map_mission_region_index(region_id: String) -> int:
	match region_id:
		"debowepogranicze": return 0
		"swiety_gaj": return 1
		"bagna_welesa": return 2
		"gory_peruna": return 3
		"nawia": return 4
		"prawia": return 5
		"grzmotne_szczyty": return 6
		"jeziora_rusalek": return 2
		"ziemie_marzanny": return 4
		"kraina_zmijow": return 3
		"korona_drzewa": return 1
		_: return 0

func draw_booster_overlay(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#0b1b1ad9"))
	draw_game_logo(Vector2(screen.x / 2.0, 98), Vector2(190, 130))
	var panel_rect := Rect2(42, 184, screen.x - 84, 470)
	draw_style_box(make_panel(Color("#193d38"), Color("#e1bd6a")), panel_rect)
	draw_string(font, Vector2(panel_rect.position.x, 226), "BOOSTERY", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 22, Color("#f5d998"))
	var names: Array[String] = ["Młot bursztynowy", "Grom Peruna", "Wiatr Gaju"]
	var descriptions: Array[String] = ["Niszczy wybrany obszar 3×3", "Niszczy wybrany rząd", "Niszczy wszystkie znaki wybranego typu"]
	var counts: Array[int] = [hammer_count, bolt_count, gale_count]
	for index in 3:
		var card := booster_choice_rect(index)
		draw_style_box(make_panel(Color("#285149"), Color("#719a78")), card)
		draw_string(font, Vector2(card.position.x + 16, card.position.y + 29), "%s  × %d" % [names[index], counts[index]], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#fff0c7"))
		draw_string(font, Vector2(card.position.x + 16, card.position.y + 55), descriptions[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c7ddba"))
		if counts[index] <= 0:
			draw_rect(card, Color("#152724a8"))
	draw_button(booster_close_rect(), "Wróć do menu", true, 14)

func main_menu_focus_level() -> Dictionary:
	if levels.is_empty():
		return {}
	var index := clampi(unlocked_level - 1, 0, levels.size() - 1)
	return levels[index]

func main_menu_region_id() -> String:
	var focus_level := main_menu_focus_level()
	return str(focus_level.get("region", "debowepogranicze"))

func draw_main_menu_background(screen: Vector2) -> void:
	var region_id := main_menu_region_id()
	var background: Texture2D = map_region_backgrounds.get(region_id, village_background)
	if background == null:
		background = oak_borderland_background
	if background == null:
		draw_rect(Rect2(Vector2.ZERO, screen), Color("#122b2a"))
		return
	var texture_size := background.get_size()
	var region_progress := 0.5
	if not levels.is_empty():
		var focus_index := clampi(unlocked_level - 1, 0, levels.size() - 1)
		var region_first := focus_index
		var region_last := focus_index
		while region_first > 0 and str(levels[region_first - 1].get("region", "")) == region_id:
			region_first -= 1
		while region_last + 1 < levels.size() and str(levels[region_last + 1].get("region", "")) == region_id:
			region_last += 1
		if region_last > region_first:
			region_progress = float(focus_index - region_first) / float(region_last - region_first)
	var source_height := texture_size.y * 0.82
	var source_width := source_height * screen.x / screen.y
	if source_width > texture_size.x:
		source_width = texture_size.x
		source_height = source_width * screen.y / screen.x
	var source_position := Vector2((texture_size.x - source_width) * 0.5, (texture_size.y - source_height) * (1.0 - region_progress))
	draw_texture_rect_region(background, Rect2(Vector2.ZERO, screen), Rect2(source_position, Vector2(source_width, source_height)), Color.WHITE)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#07100e70"))
	# Płynny cień skupia uwagę na przycisku i nagrodach, zachowując widoczność mapy.
	for strip in 24:
		var y := 480.0 + strip * 20.0
		var darkness := 0.68 * pow(float(strip) / 23.0, 1.3)
		draw_rect(Rect2(0.0, y, screen.x, minf(20.0, screen.y - y)), Color(0.027, 0.063, 0.055, darkness))

func draw_menu_fireflies(screen: Vector2) -> void:
	player_opening.draw_background_fireflies(self, screen, [
		Rect2(0, 0, screen.x, 145),
		Rect2(75, 145, screen.x - 150, screen.y - 285),
		Rect2(0, screen.y - 140, screen.x, 140),
	])

func draw_home_nav_icon(index: int, center: Vector2) -> void:
	if home_navigation_icons == null:
		return
	var atlas_size := home_navigation_icons.get_size()
	var cell_size := Vector2(atlas_size.x / 3.0, atlas_size.y / 2.0)
	var source := Rect2(Vector2((index % 3) * cell_size.x, int(index / 3) * cell_size.y), cell_size)
	draw_texture_rect_region(home_navigation_icons, Rect2(center - Vector2(26.0, 26.0), Vector2(52.0, 52.0)), source, Color.WHITE)

func draw_home_navigation(screen: Vector2) -> void:
	draw_rect(Rect2(0.0, 835.0, screen.x, screen.y - 835.0), Color("#06110eee"))
	var nav_panel := Rect2(0.0, 838.0, screen.x, 114.0)
	if home_navigation_frame != null:
		draw_texture_rect(home_navigation_frame, nav_panel, false)
	else:
		draw_style_box(make_panel(Color("#071310e8"), Color("#8b6a3d")), nav_panel)
	var labels := ["MAPA", "DRUŻYNA", "OSADA", "TRENING", "SKLEP", "MISJE"]
	var icon_indices := [0, 1, 2, 4, 3]
	for index in labels.size():
		if (index == 0 and unlocked_level < 2) or (index == 2 and unlocked_level < 3) or (index == 4 and unlocked_level < 2):
			continue
		var item_rect := main_menu_nav_rect(index)
		var training_locked := index == 3 and unlocked_level < 5
		if index == 4:
			grove_shop.load_assets(self)
			if grove_shop.icon != null:
				draw_texture_rect(grove_shop.icon, Rect2(item_rect.get_center().x - 26.0, 868.0, 52.0, 52.0), false)
		elif index == 5:
			var mission_icon_rect := Rect2(item_rect.get_center().x - 28.0, 866.0, 56.0, 56.0)
			if home_missions_icon != null:
				draw_texture_rect(home_missions_icon, mission_icon_rect, false)
			else:
				var mission_center := mission_icon_rect.get_center()
				draw_circle(mission_center, 24.0, Color("#173b2c"))
				draw_arc(mission_center, 24.0, 0.0, TAU, 40, Color("#d5aa55"), 2.0, true)
				draw_string(font, Vector2(mission_center.x - 20.0, mission_center.y + 9.0), "✦", HORIZONTAL_ALIGNMENT_CENTER, 40.0, 26, Color("#ffe08a"))
		else:
			draw_home_nav_icon(icon_indices[index], Vector2(item_rect.get_center().x, 894.0))
		if training_locked:
			draw_string(font, Vector2(item_rect.position.x, 933.0), labels[index], HORIZONTAL_ALIGNMENT_CENTER, item_rect.size.x, 8, Color("#a99b78"))
			draw_string(font, Vector2(item_rect.position.x, 945.0), "POZ. 5", HORIZONTAL_ALIGNMENT_CENTER, item_rect.size.x, 7, Color("#d0b56e"))
		else:
			draw_string(font, Vector2(item_rect.position.x, 937.0), labels[index], HORIZONTAL_ALIGNMENT_CENTER, item_rect.size.x, 9, Color("#f0dfba"))
	var unclaimed := mission_ready_count()
	if unclaimed > 0:
		var badge_center := main_menu_missions_rect().get_center() + Vector2(25.0, -23.0)
		var badge_rect := Rect2(badge_center - Vector2(18.0, 18.0), Vector2(36.0, 36.0))
		if mission_counter_badge != null:
			draw_mission_ui_art(mission_counter_badge, badge_rect)
		draw_string(font, Vector2(badge_rect.position.x, badge_center.y + 5.0), str(mini(unclaimed, 99)), HORIZONTAL_ALIGNMENT_CENTER, badge_rect.size.x, 14, Color("#fff4d4"))

func draw_home_tutorial(screen: Vector2) -> void:
	var target := main_menu_play_rect()
	var hint := ""
	var forced_upgrade_hero_id := home_upgrade_tutorial_hero_id()
	if forced_upgrade_hero_id != "":
		target = main_menu_roster_rect()
		var hero_xp := int(hero_experience.get(forced_upgrade_hero_id, 0))
		var hero_xp_required := hero_experience_to_next_level(forced_upgrade_hero_id)
		draw_rect(Rect2(Vector2.ZERO, screen), Color(0.01, 0.025, 0.018, 0.48))
		var tutorial_panel := Rect2(24.0, 656.0, screen.x - 48.0, 154.0)
		if tutorial_tooltip_banner != null:
			draw_texture_rect(tutorial_tooltip_banner, tutorial_panel, false)
		else:
			draw_style_box(make_panel(Color("#10271ff5"), Color("#d9b75e")), tutorial_panel)
		draw_string(font, Vector2(tutorial_panel.position.x + 16.0, tutorial_panel.position.y + 58.0), "CZAS ROZWIJAĆ BOHATERA", HORIZONTAL_ALIGNMENT_CENTER, tutorial_panel.size.x - 32.0, 18, Color("#ffe5a4"))
		draw_multiline_string(font, Vector2(tutorial_panel.position.x + 20.0, tutorial_panel.position.y + 83.0), "%s ma %d / %d PD. Dotknij DRUŻYNA, aby otworzyć bohaterów i ulepszyć wybraną postać." % [hero_name(forced_upgrade_hero_id), hero_xp, hero_xp_required], HORIZONTAL_ALIGNMENT_CENTER, tutorial_panel.size.x - 40.0, 14, 19, Color("#f0ecd9"))
		var target_center := target.get_center()
		var icon_center := Vector2(target_center.x, 894.0)
		var icon_scale := 1.0 + 0.035 * sin(ui_anim_time * 3.2)
		draw_set_transform(icon_center * (1.0 - icon_scale), 0.0, Vector2.ONE * icon_scale)
		draw_home_nav_icon(1, icon_center)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_string(font, Vector2(target.position.x, 937.0), "DRUŻYNA", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 9, Color("#fff0c7"))
		return
	match player_opening.home_tutorial_step:
		"play_next":
			hint = "Świetnie! Talent wzmacnia bohatera. Dotknij GRAJ, by ruszyć dalej."
		"talent_lada_roster":
			target = roster_skill_tree_rect()
			hint = "Świetnie! Bohater awansował. Dotknij TALENTY, aby dodać umiejętność."
		"village_unlocked":
			target = main_menu_village_rect()
			hint = "Odblokowano OSADĘ. Dotknij jej, aby rozwijać budynki i drużynę."
		"buy_sawmill":
			target = main_menu_village_rect()
			hint = "W osadzie postaw darmowy tartak. Będzie produkował drewno potrzebne do ulepszania budynków."
		"sawmill_built":
			target = main_menu_village_rect()
			hint = "Tartak produkuje drewno, którego użyjesz do rozbudowy pozostałych budynków. Wróć do osady, aby zobaczyć szczegóły."
		"third_companion_unlocked":
			target = main_menu_roster_rect()
			hint = "Mięta dołączyła do wyprawy! Dotknij DRUŻYNA, aby ustawić skład."
	if hint.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.008, 0.018, 0.014, 0.34))
	var pulse := 0.5 + 0.5 * sin(ui_anim_time * 3.4)
	if home_tutorial_glow_style == null:
		home_tutorial_glow_style = StyleBoxFlat.new()
		home_tutorial_glow_style.set_corner_radius_all(34)
	home_tutorial_glow_style.bg_color = Color(0.78, 0.59, 0.20, 0.025 + pulse * 0.035)
	home_tutorial_glow_style.shadow_color = Color(0.94, 0.66, 0.18, 0.18 + pulse * 0.18)
	home_tutorial_glow_style.shadow_size = 12 + roundi(pulse * 7.0)
	var tutorial_without_glow: bool = player_opening.home_tutorial_step in ["play_next", "village_unlocked", "buy_sawmill", "sawmill_built", "third_companion_unlocked"]
	if not tutorial_without_glow:
		draw_style_box(home_tutorial_glow_style, target.grow(5.0))
	var target_scale := 1.0 + 0.035 * pulse
	var transform_offset := target.get_center() * (1.0 - target_scale)
	var scaled_left := target.position.x * target_scale + transform_offset.x
	var scaled_right := target.end.x * target_scale + transform_offset.x
	var scaled_top := target.position.y * target_scale + transform_offset.y
	var scaled_bottom := target.end.y * target_scale + transform_offset.y
	if scaled_left < 0.0:
		transform_offset.x -= scaled_left
	elif scaled_right > screen.x:
		transform_offset.x -= scaled_right - screen.x
	if scaled_top < 0.0:
		transform_offset.y -= scaled_top
	elif scaled_bottom > screen.y:
		transform_offset.y -= scaled_bottom - screen.y
	draw_set_transform(transform_offset, 0.0, Vector2.ONE * target_scale)
	match player_opening.home_tutorial_step:
		"play_next":
			draw_button(target, "GRAJ  •  dalsza wyprawa", true, 19, -3.0)
		"village_unlocked", "buy_sawmill", "sawmill_built":
			draw_home_nav_icon(2, Vector2(target.get_center().x, 894.0))
			draw_string(font, Vector2(target.position.x, 937.0), "OSADA", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 9, Color("#fff0c7"))
		"third_companion_unlocked":
			draw_home_nav_icon(1, Vector2(target.get_center().x, 894.0))
			draw_string(font, Vector2(target.position.x, 937.0), "DRUŻYNA", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 9, Color("#fff0c7"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var bubble := Rect2(18.0, 758.0, screen.x - 36.0, 70.0)
	if tutorial_tooltip_banner != null:
		draw_texture_rect(tutorial_tooltip_banner, bubble, false)
	else:
		draw_style_box(make_panel(Color("#10271ff2"), Color("#d9b75e")), bubble)
	var hint_baseline := bubble.position.y + bubble.size.y * 0.5 + 6.0
	draw_multiline_string(font, Vector2(bubble.position.x + 12.0, hint_baseline), hint, HORIZONTAL_ALIGNMENT_CENTER, bubble.size.x - 24.0, 14, 18, Color("#fff0c7"))

func draw_roster_upgrade_tutorial(screen: Vector2) -> void:
	var target := roster_upgrade_rect()
	var hero_id := roster_upgrade_tutorial_hero_id()
	if hero_id == "":
		return
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.008, 0.018, 0.014, 0.72))
	var button_scale := 1.0 + 0.02 * (0.5 + 0.5 * sin(ui_anim_time * 3.2))
	var target_center := target.get_center()
	var transform_offset := target_center * (1.0 - button_scale)
	var scaled_left := target.position.x * button_scale + transform_offset.x
	var scaled_right := target.end.x * button_scale + transform_offset.x
	if scaled_left < 0.0:
		transform_offset.x -= scaled_left
	elif scaled_right > screen.x:
		transform_offset.x -= scaled_right - screen.x
	draw_set_transform(transform_offset, 0.0, Vector2.ONE * button_scale)
	draw_roster_action_button(target, "", true)
	var action_label := "ULEPSZ"
	var action_cost := upgrade_cost(hero_id)
	var label_size := 18
	var cost_size := 17
	var label_width := font.get_string_size(action_label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size).x
	var cost_width := font.get_string_size(str(action_cost), HORIZONTAL_ALIGNMENT_LEFT, -1, cost_size).x
	var content_width := label_width + 5.0 + 23.0 + 2.0 + cost_width
	var content_x := target.get_center().x - content_width * 0.5
	draw_string(font, Vector2(content_x, target.get_center().y + 6.0), action_label, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, Color("#fff1bd"))
	var coin_icon := resource_icon("coins")
	if coin_icon != null:
		draw_texture_rect(coin_icon, Rect2(content_x + label_width + 5.0, target.get_center().y - 13.0, 23.0, 23.0), false)
	draw_string(font, Vector2(content_x + label_width + 30.0, target.get_center().y + 6.0), str(action_cost), HORIZONTAL_ALIGNMENT_LEFT, -1, cost_size, Color("#fff1bd"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var plaque := Rect2(24.0, 800.0, screen.x - 48.0, 78.0)
	if tutorial_tooltip_banner != null:
		draw_texture_rect(tutorial_tooltip_banner, plaque, false)
	else:
		draw_style_box(make_panel(Color("#10271ff5"), Color("#d9b75e")), plaque)
	draw_string(font, Vector2(plaque.position.x + 8.0, plaque.position.y + 30.0), "%s ma %d / %d PD" % [hero_name(hero_id), int(hero_experience.get(hero_id, 0)), hero_experience_to_next_level(hero_id)], HORIZONTAL_ALIGNMENT_CENTER, plaque.size.x - 16.0, 13, Color("#f5d998"))
	var instruction := "DOTKNIJ ULEPSZ — PIERWSZY AWANS JEST DARMOWY" if action_cost == 0 else "DOTKNIJ ULEPSZ, ABY ROZWINĄĆ BOHATERA"
	draw_string(font, Vector2(plaque.position.x + 8.0, plaque.position.y + 49.0), instruction, HORIZONTAL_ALIGNMENT_CENTER, plaque.size.x - 16.0, 11, Color("#fff0c7"))

func draw_roster_talent_tutorial(screen: Vector2) -> void:
	var target := roster_skill_tree_rect()
	var button_scale := 1.0 + 0.018 * (0.5 + 0.5 * sin(ui_anim_time * 3.2))
	var center := target.get_center()
	draw_set_transform(center * (1.0 - button_scale), 0.0, Vector2.ONE * button_scale)
	draw_roster_action_button(target, "TALENTY  •  %d" % SkillTree.points_left(hero_trees.get("lada", {}), int(hero_levels.get("lada", 1))), true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var plaque := Rect2(24.0, 800.0, screen.x - 48.0, 78.0)
	if tutorial_tooltip_banner != null:
		draw_texture_rect(tutorial_tooltip_banner, plaque, false)
	else:
		draw_style_box(make_panel(Color("#10271ff5"), Color("#d9b75e")), plaque)
	draw_multiline_string(font, Vector2(plaque.position.x + 12.0, plaque.position.y + 45.0), "Świetnie! Bohater awansował. Dotknij TALENTY, aby dodać umiejętność.", HORIZONTAL_ALIGNMENT_CENTER, plaque.size.x - 24.0, 13, 17, Color("#fff0c7"))

func hero_face_source(hero_id: String, portrait: Texture2D) -> Rect2:
	var size := portrait.get_size()
	# Kwadratowe portrety v06 mają już duże twarze. Szerszy kadr pokazuje
	# również ramiona i strój, zamiast powiększać samą twarz w medalionie.
	var crop_width := 0.68
	var crop_top := 0.035
	var crop_center_x := 0.5
	match hero_id:
		"lada":
			crop_center_x = 0.52
		"mieta":
			crop_center_x = 0.51
		"wszebor":
			crop_top = 0.10
			crop_center_x = 0.52
	var crop_size := minf(size.x * crop_width, size.y * crop_width)
	return Rect2(clampf(size.x * crop_center_x - crop_size * 0.5, 0.0, size.x - crop_size), size.y * crop_top, crop_size, crop_size)

func home_face_portrait(hero_id: String) -> Texture2D:
	if home_face_portraits.has(hero_id):
		return home_face_portraits[hero_id]
	var portrait: Texture2D = hero_portraits.get(hero_id, null)
	if portrait == null:
		return null
	var source_rect := hero_face_source(hero_id, portrait)
	var image := portrait.get_image().get_region(Rect2i(Vector2i(source_rect.position), Vector2i(source_rect.size)))
	image.resize(256, 256, Image.INTERPOLATE_LANCZOS)
	image.convert(Image.FORMAT_RGBA8)
	for y in 256:
		for x in 256:
			var distance := Vector2(x - 127.5, y - 127.5).length() / 127.5
			var pixel := image.get_pixel(x, y)
			pixel.a *= clampf((1.0 - distance) / 0.035, 0.0, 1.0)
			image.set_pixel(x, y, pixel)
	var circular_portrait := ImageTexture.create_from_image(image)
	home_face_portraits[hero_id] = circular_portrait
	return circular_portrait

func draw_home_party(screen: Vector2) -> void:
	var card := main_menu_party_rect()
	if home_party_panel != null:
		draw_texture_rect(home_party_panel, card, false)
	else:
		draw_style_box(make_panel(Color("#071712e8"), Color("#8b6b3a")), card)
	draw_string(font, Vector2(45.0, 406.0), "WYBRANA DRUŻYNA", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 90.0, 13, Color("#f0dfba"))
	var spacing := 115.0
	for index in 3:
		var center := Vector2(screen.x * 0.5 + spacing * float(index - 1), 472.0)
		# Otwór w grafice obręczy jest poziomo rozciągnięty; węższy prostokąt
		# przywraca mu okrągłą perspektywę bez zniekształcania portretu.
		var ring_rect := Rect2(center - Vector2(48.0, 54.0), Vector2(96.0, 108.0))
		if index >= active_heroes.size():
			draw_circle(center, 42.0, Color("#0b211bc8"))
			if home_party_portrait_ring != null:
				draw_texture_rect(home_party_portrait_ring, ring_rect, false, Color(0.8, 0.85, 0.78, 0.48))
			if home_party_add_plus != null:
				draw_texture_rect(home_party_add_plus, Rect2(center - Vector2(22.5, 22.5), Vector2(45.0, 45.0)), false)
			else:
				draw_string(font, Vector2(center.x - 24.0, center.y + 11.0), "+", HORIZONTAL_ALIGNMENT_CENTER, 48.0, 30, Color("#d6bd84"))
			draw_string(font, Vector2(center.x - 54.0, 540.0), "DODAJ", HORIZONTAL_ALIGNMENT_CENTER, 108.0, 11, Color("#b8c8aa"))
			continue
		var hero_id: String = active_heroes[index]
		var face := home_face_portrait(hero_id)
		if face != null:
			draw_circle(center, 42.0, Color("#0b211bc8"))
			var face_center := center + Vector2(1.0, 1.0)
			draw_texture_rect(face, Rect2(face_center - Vector2(41.0, 41.0), Vector2(82.0, 82.0)), false)
		else:
			draw_circle(center, 42.0, Color("#604a34"))
		if home_party_portrait_ring != null:
			draw_texture_rect(home_party_portrait_ring, ring_rect, false)
		else:
			draw_arc(center, 48.0, 0.0, TAU, 48, Color("#d4ac64"), 3.0, true)
		draw_string(font, Vector2(center.x - 54.0, 540.0), hero_name(hero_id).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 108.0, 12, Color("#f2e0b7"))

func draw_home_reward_shelf() -> void:
	var chest_rect := daily_reward_rect()
	var animated_chests_ready := home_reward_panel != null and home_reward_coin_frames != null and home_reward_wood_frames != null and home_reward_xp_frames != null
	if animated_chests_ready:
		draw_texture_rect(home_reward_panel, chest_rect, false, Color.WHITE)
		var chest_frames: Array[Texture2D] = [home_reward_coin_frames, home_reward_wood_frames, home_reward_xp_frames]
		var slot_width := chest_rect.size.x / 4.0
		for index in chest_frames.size():
			var frames := chest_frames[index]
			var frame_index := 0
			if not daily_reward_available():
				frame_index = 28
				if daily_reward_open_time >= 0.0:
					frame_index = clampi(roundi((daily_reward_open_time - index * 0.08) / 0.72 * 28.0), 0, 28)
			var frame_width := frames.get_width() / 29.0
			var source := Rect2(frame_index * frame_width, 0.0, frame_width, frames.get_height())
			var center_x := chest_rect.position.x + slot_width * (index + 0.5)
			var target := Rect2(center_x - 53.0, chest_rect.position.y - 11.0, 106.0, 94.0)
			draw_texture_rect_region(frames, target, source, Color.WHITE)
	elif home_reward_chests != null:
		var source := Rect2(0.0, 0.0, home_reward_chests.get_width(), home_reward_chests.get_height())
		draw_texture_rect_region(home_reward_chests, chest_rect, source, Color.WHITE)
	else:
		draw_style_box(make_panel(Color("#101a17e8"), Color("#967544")), chest_rect)
	var slot_width := chest_rect.size.x / 4.0
	var premium_slot := daily_reward_premium_rect()
	var premium_center := premium_slot.get_center()
	if home_reward_premium_chest != null:
		if ad_bonus_available_today():
			var premium_pulse := 0.5 + sin(ui_anim_time * 1.8) * 0.5
			draw_circle(premium_center + Vector2(0, -3), 38.0, Color(0.16, 0.76, 0.65, 0.08 + premium_pulse * 0.06))
		var premium_tint := Color.WHITE if ad_bonus_available_today() else Color(0.58, 0.64, 0.59, 0.82)
		draw_texture_rect(home_reward_premium_chest, Rect2(premium_center.x - 47.0, chest_rect.position.y - 4.0, 94.0, 94.0), false, premium_tint)
	else:
		draw_circle(premium_center + Vector2(0, -2), 32.0, Color("#163d35"))
		draw_arc(premium_center + Vector2(0, -2), 32.0, 0.0, TAU, 40, Color("#d5aa55"), 2.0, true)
		draw_string(font, Vector2(premium_center.x - 24, premium_center.y + 8), "✦", HORIZONTAL_ALIGNMENT_CENTER, 48, 25, Color("#75eee0"))
	var labels := ["MONETY", "DREWNO", "PD", "PREMIUM"]
	for index in labels.size():
		var slot := Rect2(chest_rect.position.x + index * slot_width, chest_rect.position.y, slot_width, chest_rect.size.y)
		var label_color := Color("#8fe9df") if index == 3 and ad_bonus_available_today() else Color("#dbcba9")
		draw_string(font, Vector2(slot.position.x, slot.end.y - (25.0 if index == 3 else 18.0)), labels[index], HORIZONTAL_ALIGNMENT_CENTER, slot.size.x, 10, label_color)
		if index == 3:
			draw_string(font, Vector2(slot.position.x, slot.end.y - 9.0), "REKLAMA", HORIZONTAL_ALIGNMENT_CENTER, slot.size.x, 8, label_color)

func draw_main_menu(screen: Vector2) -> void:
	draw_main_menu_background(screen)
	draw_menu_fireflies(screen)
	var focus_level := main_menu_focus_level()
	var focus_level_id := int(focus_level.get("id", unlocked_level))
	var active_hero_id: String = player_opening.avatar_id
	var active_portrait: Texture2D = player_opening.avatar_catalog.portrait(self, active_hero_id)
	draw_circle(Vector2(77.0, 61.0), 57.5, Color("#08261bcf"))
	if active_portrait != null:
		var active_face := active_portrait
		if active_face != null:
			draw_texture_rect(active_face, Rect2(37.5, 15.5, 95.0, 95.0), false)
	else:
		draw_circle(Vector2(77.0, 61.0), 42.0, Color("#604a34"))
	if home_status_header != null:
		draw_texture_rect(home_status_header, Rect2(5.0, 4.0, screen.x - 10.0, 120.0), false)
	else:
		draw_style_box(make_panel(Color("#101b19ef"), Color("#b38b4d")), Rect2(10.0, 8.0, screen.x - 20.0, 104.0))
	draw_string(font, Vector2(144.0, 50.0), player_opening.player_name, HORIZONTAL_ALIGNMENT_LEFT, 150.0, 16, Color("#fff0c7"))
	draw_string(font, Vector2(144.0, 66.0), "Poziom %d  •  Drużyna %d/%d" % [unlocked_level, party_health, party_max_health], HORIZONTAL_ALIGNMENT_LEFT, 150.0, 11, Color("#c7ddba"))
	draw_resource_amount(Vector2(317.0, 33.0), "coins", coins, 27.0, 12, Color("#f4d69a"))
	draw_resource_amount(Vector2(417.0, 33.0), "wood", wood, 27.0, 12, Color("#c7ddba"))
	draw_resource_amount(Vector2(317.0, 71.0), "experience", experience, 27.0, 12, Color("#8fe8df"))
	draw_resource_amount(Vector2(417.0, 71.0), "sparks", perun_sparks, 27.0, 12, Color("#f6d779"))
	draw_game_logo(Vector2(screen.x / 2.0, 184.0), Vector2(190.0, 125.0))
	draw_button(settings_button_rect(), "USTAWIENIA", true, 13)
	if unlocked_level >= 2:
		draw_bestiary_button()
	if home_help_icon != null:
		draw_texture_rect(home_help_icon, texture_aspect_fit_rect(home_help_icon, help_button_rect()), false)
	else:
		var help_center := help_button_rect().get_center()
		draw_circle(help_center, 20.0, Color("#0b211bcf"))
		draw_arc(help_center, 20.0, 0.0, TAU, 36, Color("#a58249"), 1.5, true)
		draw_string(font, Vector2(help_button_rect().position.x, help_button_rect().position.y + 41.0), "?", HORIZONTAL_ALIGNMENT_CENTER, help_button_rect().size.x, 30, Color("#f7dfa8"))
	var region_name := region_display_name(main_menu_region_id()).to_upper()
	var region_panel := Rect2(13.0, 252.0, screen.x - 26.0, 130.0)
	if map_ui_frames != null:
		var frame_size := map_ui_frames.get_size()
		var header_source := Rect2(0.0, frame_size.y * 0.10, frame_size.x, frame_size.y * 0.40)
		draw_texture_rect_region(map_ui_frames, region_panel, header_source, Color.WHITE)
	else:
		draw_style_box(make_panel(Color("#111a17df"), Color("#997441")), region_panel)
	draw_string(font, Vector2(region_panel.position.x + 15.0, 326.0), region_name, HORIZONTAL_ALIGNMENT_CENTER, region_panel.size.x - 30.0, 21, Color("#f0dfba"))
	draw_string(font, Vector2(region_panel.position.x + 15.0, 338.0), "SZLAK %d  •  POZIOM %d" % [int((focus_level_id - 1) / 5) + 1, focus_level_id], HORIZONTAL_ALIGNMENT_CENTER, region_panel.size.x - 30.0, 12, Color("#c5b99e"))
	if state == "lost":
		draw_string(font, Vector2(region_panel.position.x + 10.0, 365.0), "WYPRAWA PRZERWANA  •  DOTKNIJ GRAJ, ABY SPRÓBOWAĆ PONOWNIE", HORIZONTAL_ALIGNMENT_CENTER, region_panel.size.x - 20.0, 10, Color("#eed6a0"))
	draw_home_party(screen)
	draw_button(main_menu_play_rect(), "GRAJ  •  dalsza wyprawa", true, 19, -3.0)
	draw_home_reward_shelf()
	var reward_ready := daily_reward_available()
	var reward_panel := Rect2(106.0, 662.0, screen.x - 212.0, 80.0)
	if map_ui_frames != null:
		var reward_frame_size := map_ui_frames.get_size()
		var reward_source := Rect2(reward_frame_size.x * 0.12, reward_frame_size.y * 0.57, reward_frame_size.x * 0.76, reward_frame_size.y * 0.25)
		draw_texture_rect_region(map_ui_frames, reward_panel, reward_source, Color.WHITE)
	else:
		draw_style_box(make_panel(Color("#101e18ee"), Color("#ad8449")), reward_panel)
	# Klikalny pasek pozostaje bez jaskrawego obramowania. Przed odebraniem
	# delikatnie pulsuje, a po odebraniu jest statyczny i wyszarzony.
	var reward_action_rect := daily_reward_banner_rect().grow(-5.0)
	if reward_ready:
		var pulse := 0.5 + sin(ui_anim_time * 2.0) * 0.5
		draw_rect(reward_action_rect, Color(0.12, 0.30, 0.20, 0.08 + pulse * 0.05))
	var reward_title_color := Color("#f0dfba")
	var reward_state_color := Color("#bdbdb0") if not reward_ready else Color("#baffc2")
	draw_string(font, Vector2(reward_panel.position.x + 20.0, 705.0), "DZIENNY DAR GAJU", HORIZONTAL_ALIGNMENT_CENTER, reward_panel.size.x - 40.0, 14, reward_title_color)
	draw_string(font, Vector2(reward_panel.position.x + 20.0, 718.0), "ODBIERZ" if reward_ready else "ODEBRANO", HORIZONTAL_ALIGNMENT_CENTER, reward_panel.size.x - 40.0, 11, reward_state_color)
	draw_home_navigation(screen)

func draw_help_overlay(screen: Vector2) -> void:
	if settings_open:
		draw_audio_settings(screen)
		return
	# Spokojne, pionowe tło zostawia ciemną polanę pośrodku na czytelny tekst.
	if oak_borderland_background != null:
		draw_texture_rect(oak_borderland_background, Rect2(Vector2.ZERO, screen), false, Color(0.72, 0.82, 0.76, 1.0))
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#061511b8"))
	# Tekst leży bezpośrednio na grafice; nie dodajemy osobnej tafli ani ramki.
	var content := Rect2((screen.x - 430.0) * 0.5, 22, 430, 650)
	draw_string(font, Vector2(content.position.x, content.position.y + 30), "JAK GRAĆ", HORIZONTAL_ALIGNMENT_CENTER, content.size.x, 30, Color("#ffe6a4"))
	var guide := [
		["1. ŁĄCZ KAFELKI", "Trójki zadają bazowe obrażenia. Czwórka: +20 obrażeń i kafelek wybuchowy (kliknij: pole 5×5, 1,2× obrażeń i punktów). Piątka: +60 obrażeń i kafelek globalny (usuwa żywioł, 2× obrażeń i punktów). Czwórka i piątka dają dodatkowy ruch. Kwadrat 2×2: +35 obrażeń."],
		["2. WYKORZYSTAJ ŻYWIOŁY", "Każde dopasowanie zadaje obrażenia. Ogień, bursztyn i runy wzmacniają atak; woda leczy, a liście dają tarczę."],
		["3. WYBIERAJ CELE", "Dotknij karty wroga, by go wybrać. Obrońcy osłaniają pozostałych wrogów — pokonaj ich jako pierwszych."],
		["4. ŁADUJ UMIEJĘTNOŚCI", "Każdy bohater zbiera energię ze swoich znaków żywiołu, także poza swoją turą. Dotknij jego umiejętności, gdy będzie gotowa."],
		["5. ROZWIJAJ DRUŻYNĘ", "Walki i trening dają PD. Misje dzienne i tygodniowe nagradzają monetami. W DRUŻYNA rozwijaj bohaterów."],
		["6. MAPA ŚWIATA", "Zwycięstwo wystarcza, by iść dalej. Trzy gwiazdki: cały skład, minimum 70% zdrowia i cel dodatkowy. Pierwsze mistrzostwo daje monety i Znak Wyprawy."],
		["7. OSADA", "Dwór wyznacza limit budynków; jego awans wymaga rozwoju wybranych obiektów. Drewno: tartak i wyprawy leśne. Dotknij celu osady, by zobaczyć następny krok."],
		["8. BOHATEROWIE", "W DRUŻYNA zmieniaj aktywny skład. W walce dotknij portretu bohatera, by podejrzeć jego umiejętność."]
	]
	var icon_indices := [0, 4, 2, 1, 5, 6, 3, 7]
	var icon_cell := Vector2.ZERO
	if map_mission_icon_atlas != null:
		icon_cell = Vector2(map_mission_icon_atlas.get_width() / 4.0, map_mission_icon_atlas.get_height() / 2.0)
	var row_top := content.position.y + 48.0
	for index in guide.size():
		var item: Array = guide[index]
		var icon_rect := Rect2(content.position + Vector2(0, row_top - content.position.y), Vector2(48, 48))
		if map_mission_icon_atlas != null:
			var icon_index: int = icon_indices[index]
			var source := Rect2(Vector2(icon_index % 4, icon_index / 4) * icon_cell, icon_cell)
			draw_texture_rect_region(map_mission_icon_atlas, icon_rect, source)
		else:
			draw_circle(icon_rect.get_center(), 14, Color("#a8782e"))
		var text_x := content.position.x + 62.0
		var text_width := content.size.x - 70.0
		draw_string(font, Vector2(text_x, row_top + 15), str(item[0]), HORIZONTAL_ALIGNMENT_LEFT, text_width, 14, Color("#fff0c7"))
		draw_multiline_string(font, Vector2(text_x, row_top + 38), str(item[1]), HORIZONTAL_ALIGNMENT_LEFT, text_width, 13, 16, Color("#cfe1c2"))
		row_top += 136.0 if index == 0 else 70.0
	draw_button(sound_toggle_rect(), "USTAWIENIA", true, 14)
	draw_button(help_close_rect(), "ROZUMIEM", true, 16)

func draw_audio_settings(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#081b15f5"))
	var panel := Rect2(20.0, screen.y * .5 - 210.0, screen.x - 40.0, 460.0)
	draw_style_box(make_panel(Color("#102b23"), Color("#ac8a50")), panel)
	draw_string(font, Vector2(20.0, screen.y * .5 - 152.0), "USTAWIENIA", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 40.0, 28, Color("#ffe6a4"))
	draw_button(sound_toggle_rect(), "DŹWIĘKI: WŁĄCZONE" if sfx_enabled else "DŹWIĘKI: WYŁĄCZONE", true, 16)
	draw_button(music_toggle_rect(), "MUZYKA: WŁĄCZONA" if music_enabled else "MUZYKA: WYŁĄCZONA", true, 16)
	draw_button(vibration_toggle_rect(), "WIBRACJE: WŁĄCZONE" if vibration_enabled else "WIBRACJE: WYŁĄCZONE", true, 16)
	draw_multiline_string(font, Vector2(40.0, screen.y * .5 + 88.0), "Krótka wibracja przy połączeniu, które nie tworzy dopasowania.", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 80.0, 12, 16, Color("#cfe1c2"))
	draw_button(settings_guide_rect(), "PORADNIK", true, 15)
	draw_button(help_close_rect(), "GOTOWE", true, 16)

func draw_bestiary_button() -> void:
	var button := bestiary_button_rect()
	var center := button.get_center()
	if bestiary_icon != null:
		var icon_bounds := Rect2(button.position + Vector2(1.0, -2.0), Vector2(button.size.x - 2.0, button.size.y - 18.0))
		draw_texture_rect(bestiary_icon, texture_aspect_fit_rect(bestiary_icon, icon_bounds), false)
	else:
		draw_string(font, Vector2(button.position.x, center.y + 8.0), "✧", HORIZONTAL_ALIGNMENT_CENTER, button.size.x, 32, Color("#ffe29a"))

func draw_bestiary_overlay(screen: Vector2) -> void:
	if bestiary_background != null:
		draw_texture_rect(bestiary_background, Rect2(Vector2.ZERO, screen), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, screen), Color("#061512"))
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.01, 0.05, 0.04, 0.18))
	draw_string(font, Vector2(24.0, 72.0), "DZIENNIK BESTII", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 48.0, 24, Color("#111b15"))
	draw_string(font, Vector2(23.0, 70.0), "DZIENNIK BESTII", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 48.0, 24, Color("#ffe5a2"))
	var region_id := bestiary_current_region()
	var enemy_names := bestiary_enemy_names(region_id)
	var found_count := bestiary_region_found_count(region_id)
	var reward_claimed := bool(claimed_bestiary_regions.get(region_id, false))
	if bestiary_regions.size() > 1:
		if roster_arrow_left != null:
			draw_texture_rect(roster_arrow_left, bestiary_region_previous_rect(), false, Color.WHITE if bestiary_region_index > 0 else Color(0.42, 0.44, 0.40, 0.75))
		else:
			draw_button(bestiary_region_previous_rect(), "◀", bestiary_region_index > 0, 18)
		if roster_arrow_right != null:
			draw_texture_rect(roster_arrow_right, bestiary_region_next_rect(), false, Color.WHITE if bestiary_region_index + 1 < bestiary_regions.size() else Color(0.42, 0.44, 0.40, 0.75))
		else:
			draw_button(bestiary_region_next_rect(), "▶", bestiary_region_index + 1 < bestiary_regions.size(), 18)
	draw_string(font, Vector2(78.0, 145.0), region_display_name(region_id).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, screen.x - 156.0, 17, Color("#fff0c7"))
	var status_label := "NAGRODA ODEBRANA" if reward_claimed else "KOMPLET:"
	var status_text := "ODKRYTO %d / %d  •  %s" % [found_count, enemy_names.size(), status_label]
	var status_width := font.get_string_size(status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
	if reward_claimed:
		draw_string(font, Vector2((screen.x - status_width) * 0.5, 166.0), status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#c6e4c2"))
	else:
		var coin_text_width := font.get_string_size("+250", HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		var full_status_width := status_width + 6.0 + 15.0 + 3.0 + coin_text_width
		var status_x := (screen.x - full_status_width) * 0.5
		draw_string(font, Vector2(status_x, 166.0), status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#c6e4c2"))
		var coin_icon := resource_icon("coins")
		var coin_pos := Vector2(status_x + status_width + 6.0, 153.0)
		if coin_icon != null:
			draw_texture_rect(coin_icon, Rect2(coin_pos, Vector2(15.0, 15.0)), false)
		else:
			draw_circle(coin_pos + Vector2(7.5, 7.5), 6.0, Color("#e7b74c"))
		draw_string(font, Vector2(coin_pos.x + 18.0, 166.0), "+250", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f3d784"))
	for row in 6:
		var entry_index := bestiary_page * 6 + row
		if entry_index >= enemy_names.size():
			break
		var enemy_name: String = enemy_names[entry_index]
		var discovered := bool(bestiary_seen.get(enemy_name, false))
		var entry := Rect2(31.0, 190.0 + row * 89.0, screen.x - 62.0, 81.0)
		var portrait := boss_portrait_for(enemy_name)
		if portrait != null:
			draw_texture_rect(portrait, Rect2(entry.position + Vector2(6.0, 6.0), Vector2(69.0, 69.0)), false, Color.WHITE if discovered else Color(0.34, 0.40, 0.34, 0.88))
		else:
			draw_circle(entry.position + Vector2(40.0, 40.0), 25.0, Color("#26332c"))
		var title := enemy_name if discovered else "Nieodkryty przeciwnik"
		draw_string(font, entry.position + Vector2(86.0, 33.0), title, HORIZONTAL_ALIGNMENT_LEFT, entry.size.x - 96.0, 13, Color("#ffe8ad") if discovered else Color("#b1b6a7"))
		if discovered:
			var role := enemy_role_label({"role": ENEMY_ROLES.get(enemy_name, "attacker")})
			var kills := int(bestiary_kills.get(enemy_name, 0))
			draw_string(font, entry.position + Vector2(86.0, 54.0), "%s  •  pokonano: %d" % [role, kills], HORIZONTAL_ALIGNMENT_LEFT, entry.size.x - 98.0, 10, Color("#c8dbc1"))
	var page_count := bestiary_page_count(region_id)
	if page_count > 1:
		if roster_arrow_left != null:
			draw_texture_rect(roster_arrow_left, bestiary_page_previous_rect(), false, Color.WHITE if bestiary_page > 0 else Color(0.42, 0.44, 0.40, 0.75))
		else:
			draw_button(bestiary_page_previous_rect(), "◀", bestiary_page > 0, 18)
		draw_string(font, Vector2(214.0, 780.0), "%d / %d" % [bestiary_page + 1, page_count], HORIZONTAL_ALIGNMENT_CENTER, screen.x - 428.0, 12, Color("#f5e1ae"))
		if roster_arrow_right != null:
			draw_texture_rect(roster_arrow_right, bestiary_page_next_rect(), false, Color.WHITE if bestiary_page + 1 < page_count else Color(0.42, 0.44, 0.40, 0.75))
		else:
			draw_button(bestiary_page_next_rect(), "▶", bestiary_page + 1 < page_count, 18)
	else:
		draw_string(font, Vector2(24.0, 781.0), "Wpisy pokazują poznanych przeciwników i liczbę zwycięstw.", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 48.0, 11, Color("#d5ddc8"))
	draw_button(bestiary_close_rect(), "WRÓĆ", true, 15)

func draw_training_overlay(screen: Vector2) -> void:
	if forest_catalog_open:
		draw_forest_expeditions_overlay(screen)
		return
	if oak_borderland_background != null:
		draw_texture_rect(oak_borderland_background, Rect2(Vector2.ZERO, screen), false, Color(0.62, 0.72, 0.68, 1.0))
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#061511d8"))
	var content_width := screen.x - 48.0
	draw_string(font, Vector2(24, 92), "KRĄG TRENINGOWY", HORIZONTAL_ALIGNMENT_CENTER, content_width, 27, Color("#f5d998"))
	draw_string(font, Vector2(36, 120), "Ćwicz bez energii i bez ryzyka utraty postępu.", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 72.0, 14, Color("#d4e2c5"))
	for slot in TRAINING_BATTLES.size():
		var training: Dictionary = TRAINING_BATTLES[slot]
		var card := training_choice_rect(slot)
		if card.end.y < 154.0 or card.position.y > 870.0:
			continue
		var enemy: Dictionary = training["enemies"][0]
		var locked := int(training.get("required_level", 1)) > unlocked_level
		if locked:
			draw_string(font, Vector2(card.position.x, card.position.y + 49), "ZABLOKOWANE", HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 18, Color("#c5b991"))
			draw_string(font, Vector2(card.position.x, card.position.y + 76), "Ukończ poziom %d" % int(training.get("required_level", 1)), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 13, Color("#aebca8"))
			continue
		var portrait := boss_portrait_for(str(enemy["name"]))
		var medal := Rect2(card.position + Vector2(8, 22), Vector2(82, 82))
		if portrait_backdrop_oak != null:
			draw_texture_rect(portrait_backdrop_oak, medal, false)
		else:
			draw_circle(medal.get_center(), 40, Color("#193c32"))
		if portrait != null:
			draw_texture_rect(portrait, Rect2(card.position + Vector2(15, 29), Vector2(68, 68)), false)
		draw_string(font, Vector2(card.position.x + 92, card.position.y + 29), str(training["name"]), HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 210, 17, Color("#fff0c7"))
		draw_string(font, Vector2(card.position.x + 92, card.position.y + 52), "Wróg: %s  •  %d zdrowia  •  atak %d" % [str(enemy["name"]), int(enemy["health"]), int(enemy["attack"])], HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 108, 11, Color("#d2e4cb"))
		draw_string(font, Vector2(card.position.x + 92, card.position.y + 75), str(training.get("mechanic", "Próba bojowa")), HORIZONTAL_ALIGNMENT_LEFT, card.size.x - 108, 11, Color("#f2d48d"))
		var reward: Dictionary = training["rewards"]
		draw_string(font, Vector2(card.position.x + 92, card.position.y + 106), "NAGRODA", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f5d998"))
		var training_reward_x := card.position.x + 154.0
		training_reward_x += draw_resource_amount(Vector2(training_reward_x, card.position.y + 90), "experience", int(reward["experience"]), 18.0, 11, Color("#f5d998")) + 10.0
		draw_resource_amount(Vector2(training_reward_x, card.position.y + 90), "coins", int(reward["coins"]), 18.0, 11, Color("#f5d998"))
		draw_button(Rect2(card.end.x - 112, card.position.y + 82, 96, 28), "WALCZ", true, 11)
	draw_button(training_close_rect(), "Wróć do menu", true, 14)

func draw_forest_expeditions_overlay(screen: Vector2) -> void:
	forest_expeditions_view.draw(self, screen)

func load_reward_claims(data: ConfigFile) -> void:
	for level in levels:
		var level_id := int(level.get("id", 0))
		claimed_boss_sparks[level_id] = bool(data.get_value("bosses", "spark_%d" % level_id, false))
		if level_id % 5 == 0:
			claimed_boss_sparks[-level_id] = bool(data.get_value("bosses", "spark_%d" % -level_id, false))

func load_progress() -> void:
	var data := ConfigFile.new()
	if data.load("user://progress.cfg") == OK:
		expedition_bonus_claims = data.get_value("expeditions", "bonus_claims", {})
		mastery_claims = data.get_value("mastery", "claims", {})
		balance_stats = data.get_value("balance", "stats", {})
		unlocked_level = clampi(int(data.get_value("progress", "unlocked_level", 1)), 1, levels.size())
		coins = int(data.get_value("wallet", "coins", 0))
		wood = int(data.get_value("wallet", "wood", 0))
		sawmill_production_progress = clampf(float(data.get_value("village", "sawmill_production_progress", 0.0)), 0.0, 0.9999)
		sawmill_stored_wood = clampi(int(data.get_value("village", "sawmill_stored_wood", 0)), 0, 999999999)
		last_wood_production_unix = maxi(0, int(data.get_value("village", "wood_production_timestamp", 0)))
		experience = int(data.get_value("wallet", "experience", 0))
		perun_sparks = int(data.get_value("wallet", "perun_sparks", 0))
		event_marks = int(data.get_value("wallet", "event_marks", 0))
		daily_reward_day = str(data.get_value("progress", "daily_reward_day", ""))
		ad_quota_day = str(data.get_value("ads", "quota_day", ""))
		ad_interstitials_today = int(data.get_value("ads", "interstitials_today", 0))
		campaign_wins_since_interstitial = int(data.get_value("ads", "wins_since_interstitial", 0))
		daily_ad_bonus_day = str(data.get_value("ads", "bonus_claimed_day", ""))
		var saved_bestiary_seen: Variant = data.get_value("bestiary", "seen", {})
		var saved_bestiary_kills: Variant = data.get_value("bestiary", "kills", {})
		var saved_bestiary_regions: Variant = data.get_value("bestiary", "claimed_regions", {})
		var saved_side_objectives: Variant = data.get_value("side_objectives", "claimed", {})
		var saved_daily_history: Variant = data.get_value("missions", "daily_history", [])
		var saved_weekly_history: Variant = data.get_value("missions", "weekly_history", [])
		daily_mission_history = saved_daily_history if saved_daily_history is Array else []
		weekly_mission_history = saved_weekly_history if saved_weekly_history is Array else []
		mission_day_key = str(data.get_value("missions", "day_key", ""))
		mission_week_key = str(data.get_value("missions", "week_key", ""))
		var saved_daily_missions: Variant = data.get_value("missions", "daily", [])
		var saved_weekly_missions: Variant = data.get_value("missions", "weekly", [])
		daily_missions = saved_daily_missions if saved_daily_missions is Array else []
		weekly_missions = saved_weekly_missions if saved_weekly_missions is Array else []
		bestiary_seen = saved_bestiary_seen if saved_bestiary_seen is Dictionary else {}
		bestiary_kills = saved_bestiary_kills if saved_bestiary_kills is Dictionary else {}
		claimed_bestiary_regions = saved_bestiary_regions if saved_bestiary_regions is Dictionary else {}
		claimed_side_objectives = saved_side_objectives if saved_side_objectives is Dictionary else {}
		load_audio_settings(data)
		load_reward_claims(data)
		tutorial_completed = bool(data.get_value("progress", "tutorial_completed", false))
		for intro_level_id in REGION_INTROS:
			seen_region_intros[intro_level_id] = bool(data.get_value("region_intros", "level_%d" % int(intro_level_id), false))
		for chapter_id in REGION_CHAPTERS:
			seen_region_chapters[chapter_id] = bool(data.get_value("region_intros", "chapter_%s" % chapter_id, false))
		for scene_id in CAMPAIGN_STORY:
			seen_campaign_scenes[scene_id] = bool(data.get_value("campaign_story", "scene_%d" % int(scene_id), false))
		for hero_id in HERO_IDS:
			var is_owned := bool(data.get_value("heroes", "%s_owned" % hero_id, hero_id == "lada"))
			owned_heroes[hero_id] = is_owned
			hero_levels[hero_id] = maxi(1, int(data.get_value("heroes", "%s_level" % hero_id, 1))) if is_owned else 0
			hero_experience[hero_id] = maxi(0, int(data.get_value("heroes", "%s_experience" % hero_id, 0))) if is_owned else 0
			var saved_tree: Variant = data.get_value("talents", hero_id, {})
			hero_trees[hero_id] = saved_tree if saved_tree is Dictionary else {}
		active_heroes.clear()
		for hero_id in HERO_IDS:
			if bool(data.get_value("heroes", "%s_active" % hero_id, hero_id == "lada")) and bool(owned_heroes[hero_id]):
				active_heroes.append(hero_id)
		if active_heroes.is_empty():
			active_heroes.append("lada")
		load_village_progress(data)
		for level in levels:
			var level_id := int(level.get("id", 0))
			level_stars[level_id] = clampi(int(data.get_value("stars", "level_%d" % level_id, 0)), 0, 3)
	# Zapis może pochodzić ze starszej wersji gry albo zostać przerwany w trakcie
	# zamykania aplikacji. Zawsze doprowadzamy go do bezpiecznego stanu przed startem.
	sanitize_progress()
	player_opening.load_profile(data, self)

func load_village_progress(data: ConfigFile) -> void:
	for building_id in BUILDING_IDS:
		building_levels[building_id] = clampi(int(data.get_value("village", "%s_level" % building_id, 0)), 0, MAX_BUILDING_LEVEL)
	if not data.has_section_key("village", "dwor_wiecowy_level"):
		building_levels["dwor_wiecowy"] = VillageProgression.legacy_hall_level(building_levels)

func sanitize_progress() -> void:
	var max_level_index := maxi(1, levels.size())
	unlocked_level = clampi(unlocked_level, 1, max_level_index)
	coins = clampi(coins, 0, 999999999)
	wood = clampi(wood, 0, 999999999)
	experience = clampi(experience, 0, 999999999)
	perun_sparks = clampi(perun_sparks, 0, 999999)
	event_marks = clampi(event_marks, 0, 999999)
	ad_interstitials_today = clampi(ad_interstitials_today, 0, MAX_INTERSTITIALS_PER_DAY)
	campaign_wins_since_interstitial = clampi(campaign_wins_since_interstitial, 0, WINS_BETWEEN_INTERSTITIALS)
	# Lada jest bohaterką startową — jej brak w starym/uszkodzonym zapisie
	# nigdy nie może odebrać graczowi możliwości rozpoczęcia pojedynku.
	owned_heroes["lada"] = true
	for hero_id in HERO_IDS:
		var owned := bool(owned_heroes.get(hero_id, false))
		owned_heroes[hero_id] = owned
		hero_levels[hero_id] = clampi(int(hero_levels.get(hero_id, 0)), 1, MAX_HERO_LEVEL) if owned else 0
		hero_experience[hero_id] = clampi(int(hero_experience.get(hero_id, 0)), 0, 9999999) if owned else 0
		var raw_tree: Variant = hero_trees.get(hero_id, {})
		hero_trees[hero_id] = SkillTree.sanitize(raw_tree if raw_tree is Dictionary else {}, int(hero_levels[hero_id])) if owned else {}
	var valid_active: Array[String] = []
	for hero_id in HERO_IDS:
		if bool(owned_heroes.get(hero_id, false)) and active_heroes.has(hero_id) and valid_active.size() < 3:
			valid_active.append(hero_id)
	if valid_active.is_empty():
		valid_active.append("lada")
	active_heroes = valid_active
	for building_id in BUILDING_IDS:
		building_levels[building_id] = clampi(int(building_levels.get(building_id, 0)), 0, MAX_BUILDING_LEVEL)

func save_progress() -> void:
	var data := ConfigFile.new()
	data.set_value("expeditions", "bonus_claims", expedition_bonus_claims)
	data.set_value("mastery", "claims", mastery_claims)
	data.set_value("balance", "stats", balance_stats)
	last_wood_production_unix = int(Time.get_unix_time_from_system())
	player_opening.save_profile(data)
	data.set_value("progress", "unlocked_level", unlocked_level)
	data.set_value("progress", "tutorial_completed", tutorial_completed)
	data.set_value("progress", "daily_reward_day", daily_reward_day)
	data.set_value("ads", "quota_day", ad_quota_day)
	data.set_value("ads", "interstitials_today", ad_interstitials_today)
	data.set_value("ads", "wins_since_interstitial", campaign_wins_since_interstitial)
	data.set_value("ads", "bonus_claimed_day", daily_ad_bonus_day)
	data.set_value("bestiary", "seen", bestiary_seen)
	data.set_value("bestiary", "kills", bestiary_kills)
	data.set_value("bestiary", "claimed_regions", claimed_bestiary_regions)
	data.set_value("side_objectives", "claimed", claimed_side_objectives)
	data.set_value("missions", "day_key", mission_day_key)
	data.set_value("missions", "week_key", mission_week_key)
	data.set_value("missions", "daily", daily_missions)
	data.set_value("missions", "weekly", weekly_missions)
	data.set_value("missions", "daily_history", daily_mission_history)
	data.set_value("missions", "weekly_history", weekly_mission_history)
	for intro_level_id in REGION_INTROS:
		data.set_value("region_intros", "level_%d" % int(intro_level_id), bool(seen_region_intros.get(intro_level_id, false)))
	for chapter_id in REGION_CHAPTERS:
		data.set_value("region_intros", "chapter_%s" % chapter_id, bool(seen_region_chapters.get(chapter_id, false)))
	for scene_id in CAMPAIGN_STORY:
		data.set_value("campaign_story", "scene_%d" % int(scene_id), bool(seen_campaign_scenes.get(scene_id, false)))
	data.set_value("wallet", "coins", coins)
	data.set_value("wallet", "wood", wood)
	data.set_value("village", "sawmill_production_progress", sawmill_production_progress)
	data.set_value("village", "sawmill_stored_wood", sawmill_stored_wood)
	data.set_value("village", "wood_production_timestamp", last_wood_production_unix)
	data.set_value("wallet", "experience", experience)
	data.set_value("wallet", "perun_sparks", perun_sparks)
	data.set_value("wallet", "event_marks", event_marks)
	save_audio_settings(data)
	for level_id in claimed_boss_sparks:
		data.set_value("bosses", "spark_%d" % level_id, claimed_boss_sparks[level_id])
	for hero_id in HERO_IDS:
		data.set_value("heroes", "%s_level" % hero_id, hero_levels[hero_id])
		data.set_value("heroes", "%s_experience" % hero_id, hero_experience[hero_id])
		data.set_value("heroes", "%s_owned" % hero_id, owned_heroes[hero_id])
		data.set_value("heroes", "%s_active" % hero_id, active_heroes.has(hero_id))
		data.set_value("talents", hero_id, hero_trees.get(hero_id, {}))
	for building_id in BUILDING_IDS:
		data.set_value("village", "%s_level" % building_id, building_levels[building_id])
	for level in levels:
		var level_id := int(level.get("id", 0))
		data.set_value("stars", "level_%d" % level_id, level_stars.get(level_id, 0))
	data.save("user://progress.cfg")

func load_levels() -> Array:
	var file := FileAccess.open("res://data/levels.json", FileAccess.READ)
	if file == null:
		push_warning("Nie znaleziono danych poziomów; używam konfiguracji awaryjnej.")
		return normalize_combat_levels(DEFAULT_LEVELS.duplicate(true))
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array and not parsed.is_empty():
		return normalize_combat_levels(append_generated_levels(parsed))
	push_warning("Dane poziomów są nieprawidłowe; używam konfiguracji awaryjnej.")
	return normalize_combat_levels(DEFAULT_LEVELS.duplicate(true))

func normalize_combat_levels(source: Array) -> Array:
	var result: Array = source.duplicate(true)
	for index in result.size():
		var level: Dictionary = result[index]
		var level_id := int(level.get("id", index + 1))
		# Kampania składa się wyłącznie z walk — cele zbierania i oczyszczania
		# zostają zastąpione pokonaniem przeciwników.
		level["goal_type"] = "defeat_enemy"
		level.erase("goal_value")
		level.erase("target")
		var configured: Array = level.get("enemies", [])
		if configured.is_empty():
			var fallback_name := "Korzeniowy strażnik" if level_id % 3 == 0 else ("Cień mchu" if level_id % 3 == 1 else "Strażnik totemu")
			configured = [{"name": fallback_name, "health": 80 + level_id * 5, "attack": 4 + int(level_id / 8)}]
		# Pierwszy rozdział ma nauczyć podstaw bez muru zdrowia większego od
		# startowego bohatera. Od poziomu 6 wracamy do normalnego tempa wzrostu.
		var beginner := level_id <= 5
		var transition := clampf(float(level_id - 5) / 15.0, 0.0, 1.0)
		var health_floor := 28 + level_id * 4 if beginner else int(round(lerpf(48.0, 170.0, transition))) if level_id < 20 else 120 + int(float(level_id) * 2.5)
		var health_multiplier := 0.72 + float(level_id - 1) * 0.03 if beginner else lerpf(0.84, 1.37, transition) if level_id < 20 else 1.25 + minf(float(level_id) * 0.006, 0.75)
		for enemy_index in configured.size():
			var enemy: Dictionary = configured[enemy_index]
			var original_health := int(enemy.get("health", 60))
			var scaled_health := maxi(health_floor, int(round(float(original_health) * health_multiplier)))
			enemy["health"] = scaled_health
			enemy["max_health"] = scaled_health
			enemy["attack"] = maxi(int(enemy.get("attack", 2)), 2) if beginner else maxi(int(enemy.get("attack", 4)), 4 + int(level_id / 7))
			configured[enemy_index] = enemy
		level["enemies"] = configured
		result[index] = level
	return result

func append_generated_levels(handcrafted_levels: Array) -> Array:
	var result: Array = handcrafted_levels.duplicate(true)
	# Po ręcznie zaprojektowanym prologu kampania przechodzi przez nowe krainy
	# całymi rozdziałami, zamiast zapętlać cztery znane lokacje.
	var regions := ["jeziora_rusalek", "ziemie_marzanny", "kraina_zmijow", "nawia", "prawia", "korona_drzewa"]
	var region_names := {"jeziora_rusalek": "Jezior Rusałek", "ziemie_marzanny": "Ziem Marzanny", "kraina_zmijow": "Krainy Żmijów", "nawia": "Nawii", "prawia": "Prawii", "korona_drzewa": "Korony Drzewa Świata"}
	# Każda kraina otrzymuje własny zestaw spotkań. To sprawia, że wejście
	# w nowy rozdział jest zauważalne również w zwykłych walkach, a nie tylko w tle.
	var regional_enemy_pools := {
		"jeziora_rusalek": ["Utopiec z trzcin", "Mgielna rusałka", "Wodny chochlik", "Strażnik wiru", "Topielny krab"],
		"ziemie_marzanny": ["Lodowy wid", "Zamrożona wrona", "Córka zamieci", "Srebrny upiór", "Strażnik szronu"],
		"kraina_zmijow": ["Żmijowy zwiadowca", "Jaskiniowy duch", "Strażnik skarbca", "Jadowity bazyliszek", "Wężowy skryba"],
		"nawia": ["Kościany kurhanek", "Cień pamięci", "Widmo przewoźnika", "Nawijski strażnik", "Kruczy rycerz"],
		"prawia": ["Złoty posłaniec", "Strażnik równowagi", "Świetlisty woj", "Runiczna sowa", "Opiekun przysięgi"],
		"korona_drzewa": ["Korzeniowy strażnik", "Duch dębu", "Cierniowy wilk", "Strażnik totemu", "Dąbrowy drwal widmo"]
	}
	var regional_grand_bosses := {
		"jeziora_rusalek": ["Król Topielców", "Pani Głębin"],
		"ziemie_marzanny": ["Pani Zimy", "Marzannowy Herold"],
		"kraina_zmijow": ["Matka Żmijów", "Wąż Wiślany"],
		"nawia": ["Przewoźnik", "Królowa Kurhanów"],
		"prawia": ["Strażnik Równowagi", "Władca Kruczych Znaków"],
		"korona_drzewa": ["Czarny Bóg Przesmyku", "Serce Starego Dębu"]
	}
	for level_id in range(101, 2001):
		# Każdy kolejny etap podnosi rangę trudności; nie stosujemy miękkiego limitu
		# po 1000 poziomie, bo kampania trwa dalej do poziomu 2000.
		var tier := level_id - 100
		var region: String = regions[int((level_id - 101) / 25) % regions.size()]
		var enemy_pool: Array = regional_enemy_pools.get(region, [])
		var grand_bosses: Array = regional_grand_bosses.get(region, [])
		var enemies: Array = []
		# Statystyki rosną przez całą kampanię, ale wolniej niż ranga poziomu:
		# drużyna rozwija się do maksymalnego poziomu, więc 2000 ma być wymagające,
		# a nie wymagać nieskończonego wzrostu obrażeń.
		var base_health := 520 + int(float(tier) * 0.6)
		var base_attack := 13 + int(tier / 200)
		if level_id % 50 == 0:
			enemies.append({"name": enemy_pool[level_id % enemy_pool.size()], "health": base_health, "attack": base_attack})
			enemies.append({"name": grand_bosses[int(level_id / 50) % grand_bosses.size()], "health": base_health * 2, "attack": base_attack + 10})
		elif level_id % 25 == 0:
			enemies.append({"name": enemy_pool[level_id % enemy_pool.size()], "health": base_health, "attack": base_attack})
			enemies.append({"name": grand_bosses[int(level_id / 25) % grand_bosses.size()], "health": int(base_health * 1.7), "attack": base_attack + 7})
		elif level_id % 10 == 0:
			enemies.append({"name": enemy_pool[level_id % enemy_pool.size()], "health": base_health, "attack": base_attack})
			enemies.append({"name": "Strażnik totemu", "health": base_health * 2, "attack": base_attack + 7})
		else:
			var enemy_count := 2 if level_id % 3 else 3
			for offset in enemy_count:
				enemies.append({"name": enemy_pool[(level_id + offset * 3) % enemy_pool.size()], "health": base_health + offset * 35, "attack": base_attack + offset * 2})
		var prefix := "Próba" if level_id % 10 else "Warta"
		var name := "%s %d — szlak %s" % [prefix, level_id, str(region_names[region])]
		if level_id % 50 == 0:
			name = "Wielki boss %d — %s" % [level_id, str(grand_bosses[int(level_id / 50) % grand_bosses.size()])]
		elif level_id % 25 == 0:
			name = "Strażnik krainy %d — %s" % [level_id, str(grand_bosses[int(level_id / 25) % grand_bosses.size()])]
		var obstacle_profile := {"root": 5 + int(tier / 120), "stone": 4 + int(tier / 140), "curse": 3 + int(tier / 170)}
		if level_id % 10 == 0:
			obstacle_profile["curse"] = int(obstacle_profile["curse"]) + 2
		var is_chapter_boss := level_id % 25 == 0
		var is_survival_stage := level_id % 40 == 0 and level_id % 50 != 0
		# Oczyszczenia pozostają spokojniejszymi poziomami między bossami,
		# dzięki czemu kampania nie zamienia się w ciągłą serię pojedynków.
		var is_cleansing_stage := level_id % 20 == 0 and not is_chapter_boss and not is_survival_stage
		var is_collection_stage := level_id % 15 == 0 and not is_cleansing_stage and not is_survival_stage and level_id % 50 != 0
		var is_score_stage := level_id % 35 == 0 and not is_cleansing_stage and not is_survival_stage and not is_collection_stage and level_id % 50 != 0
		if is_chapter_boss:
			obstacle_profile = {"root": 6 + int(tier / 160), "stone": 5 + int(tier / 190), "curse": 4 + int(tier / 230)}
			var boss_reward_multiplier := 2 if level_id % 50 == 0 else 1
			result.append({"id": level_id, "region": region, "name": name, "goal_type": "defeat_enemy", "enemies": enemies, "obstacles": obstacle_profile, "rewards": {"coins": 11200 + tier * 52 * boss_reward_multiplier, "wood": 1850 + tier * 10 * boss_reward_multiplier, "experience": 2300 + tier * 13 * boss_reward_multiplier}})
		elif is_survival_stage:
			var survival_target := 6 + int(tier / 200)
			name = "Przetrwanie %d — szlak %s" % [level_id, str(region_names[region])]
			enemies = [{"name": enemy_pool[level_id % enemy_pool.size()], "health": base_health * 3, "attack": base_attack + 6}]
			obstacle_profile = {"root": 5 + int(tier / 180), "stone": 4 + int(tier / 220), "curse": 2 + int(tier / 250)}
			result.append({"id": level_id, "region": region, "name": name, "goal_type": "survive", "goal_value": survival_target, "enemies": enemies, "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 45, "wood": 1550 + tier * 9, "experience": 1850 + tier * 11}})
		elif is_cleansing_stage:
			name = "Oczyszczenie %d — szlak %s" % [level_id, str(region_names[region])]
			obstacle_profile = {"root": 8 + int(tier / 150), "stone": 6 + int(tier / 180), "curse": 5 + int(tier / 220)}
			var cleansing_target := 11 + int(tier / 95)
			result.append({"id": level_id, "region": region, "name": name, "goal_type": "clear_obstacles", "goal_value": cleansing_target, "enemies": [], "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 42, "wood": 1550 + tier * 8, "experience": 1850 + tier * 10}})
		elif is_collection_stage:
			var collect_runes := level_id % 30 == 0
			var collection_target := 11 + int(tier / 140)
			name = ("Zbieranie run %d" if collect_runes else "Zbieranie bursztynu %d") % level_id
			obstacle_profile = {"root": 4 + int(tier / 220), "stone": 3 + int(tier / 260), "curse": 2}
			result.append({"id": level_id, "region": region, "name": name, "goal_type": "collect_rune" if collect_runes else "collect_amber", "goal_value": collection_target, "enemies": [], "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 40, "wood": 1550 + tier * 8, "experience": 1850 + tier * 10}})
		elif is_score_stage:
			name = "Echo reliktu %d" % level_id
			var score_target := 1500 + tier * 2
			obstacle_profile = {"root": 3 + int(tier / 300), "stone": 2 + int(tier / 360), "curse": 1}
			result.append({"id": level_id, "region": region, "name": name, "goal_type": "score", "target": score_target, "enemies": [], "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 41, "wood": 1550 + tier * 8, "experience": 1850 + tier * 10}})
		else:
			result.append({"id": level_id, "region": region, "name": name, "goal_type": "defeat_enemy", "enemies": enemies, "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 38, "wood": 1550 + tier * 7, "experience": 1850 + tier * 9}})
	return result
