extends Node2D

const SkillTree = preload("res://scripts/hero_skill_tree.gd")

## Prototyp Fazy A: plansza 8×8, zamiana sąsiednich kafelków, match-3,
## kaskady, punkty, limit ruchów, pięć konfiguracji poziomów i lokalny zapis.

const BOARD_SIZE := 8
const TILE_TYPES := 5
const LADA_MAX_CHARGE := 8
const BRUN_MAX_CHARGE := 7
const MIETA_MAX_CHARGE := 7
const MAX_CASCADE_STEPS := 30
const MAX_HERO_LEVEL := 50
const MAX_BUILDING_LEVEL := 50
const HERO_IDS := ["lada", "brun", "mieta", "wszebor", "boruta", "dobromir", "milena", "radomir", "witosz", "jagna", "rada", "welesa", "zorya", "jaromir", "msciwoj", "dobrawa", "perunika", "czernik", "mirka", "wlodzimierz", "zywia", "mokosza", "stribog", "swarog", "weles"]
const HERO_NAMES := ["Lada", "Brun", "Mieta", "Wszebor", "Boruta", "Dobromir", "Milena", "Radomir", "Witosz", "Jagna", "Rada", "Welesa", "Zorya", "Jaromir", "Mściwoj", "Dobrawa", "Perunika", "Czernik", "Mirka", "Włodzimierz", "Żywia", "Mokosza", "Stribóg", "Swaróg", "Weles"]
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
	"perunika": "Piorunowa Strzała: kombinacja 5+ dodaje +1 ruch",
	"czernik": "Cień Kurhanu: klątwy szybciej tracą wytrzymałość",
	"mirka": "Dar Pokoju: leczenie rozdziela 2 zdrowia na drużynę",
	"wlodzimierz": "Kamienny Znak: kamienie mają o 1 mniej wytrzymałości",
	"mokosza": "Matka Ziemi: liście i woda wspólnie dają +4 tarczy",
	"stribog": "Władca Wichru: kombinacja 5+ zadaje +10 obrażeń",
	"swarog": "Kuźnia Słońca: ogień i bursztyn dają +8 obrażeń",
	"weles": "Władca Przemian: pierwsza kaskada po turze zadaje podwójne obrażenia"
}
const BUILDING_IDS := ["domostwa", "kuznia", "chata_zielarki", "swiety_gaj", "spichlerz", "wieza_peruna"]
const BUILDING_NAMES := ["Domostwa", "Kuźnia", "Chata Zielarki", "Święty Gaj", "Spichlerz", "Wieża Peruna"]
const DEFAULT_LEVELS := [
	{"id": 1, "moves": 18, "target": 600, "name": "Pierwszy szept"},
	{"id": 2, "moves": 17, "target": 850, "name": "Ślad w mchu"},
	{"id": 3, "moves": 16, "target": 1050, "name": "Żar kowadła"},
	{"id": 4, "moves": 15, "target": 1250, "name": "Źródło Miety"},
	{"id": 5, "moves": 14, "target": 1500, "name": "Próba dębu"}
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
	{"name": "Ćwiczenie: Mchy", "moves": 20, "goal_type": "defeat_enemy", "enemies": [{"name": "Cień mchu", "health": 42, "attack": 2}], "rewards": {"coins": 8, "wood": 0, "experience": 55}},
	{"name": "Ćwiczenie: Żar", "moves": 19, "goal_type": "defeat_enemy", "enemies": [{"name": "Popielny chochlik", "health": 58, "attack": 3}], "rewards": {"coins": 10, "wood": 0, "experience": 75}},
	{"name": "Ćwiczenie: Straż gaju", "moves": 18, "goal_type": "defeat_enemy", "enemies": [{"name": "Korzeniowy strażnik", "health": 76, "attack": 4}], "rewards": {"coins": 12, "wood": 2, "experience": 100}}
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
var obstacles: Array = []
var levels: Array = []
var level_index := 0
var score := 0
var moves_left := 0
var unlocked_level := 1
var state := "playing" # playing, won, lost
var touch_start := Vector2i(-1, -1)
var selected_cell := Vector2i(-1, -1)
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
var animation_busy := false
var enemy_turn_active := false
var tile_offsets := {}
var removal_effects := {}
var goal_type := "score"
var goal_target := 0
var goal_progress := 0
var hero_levels := {"lada": 1, "brun": 0, "mieta": 0, "wszebor": 0, "boruta": 0, "dobromir": 0, "milena": 0, "radomir": 0, "witosz": 0, "jagna": 0, "rada": 0, "welesa": 0, "zorya": 0, "jaromir": 0, "msciwoj": 0, "dobrawa": 0, "perunika": 0, "czernik": 0, "mirka": 0, "wlodzimierz": 0, "zywia": 0, "mokosza": 0, "stribog": 0, "swarog": 0, "weles": 0}
var hero_experience := {"lada": 0, "brun": 0, "mieta": 0, "wszebor": 0, "boruta": 0, "dobromir": 0, "milena": 0, "radomir": 0, "witosz": 0, "jagna": 0, "rada": 0, "welesa": 0, "zorya": 0, "jaromir": 0, "msciwoj": 0, "dobrawa": 0, "perunika": 0, "czernik": 0, "mirka": 0, "wlodzimierz": 0, "zywia": 0, "mokosza": 0, "stribog": 0, "swarog": 0, "weles": 0}
var hero_trees := {}
var owned_heroes := {"lada": true, "brun": false, "mieta": false, "wszebor": false, "boruta": false, "dobromir": false, "milena": false, "radomir": false, "witosz": false, "jagna": false, "rada": false, "welesa": false, "zorya": false, "jaromir": false, "msciwoj": false, "dobrawa": false, "perunika": false, "czernik": false, "mirka": false, "wlodzimierz": false, "zywia": false, "mokosza": false, "stribog": false, "swarog": false, "weles": false}
var active_heroes: Array[String] = ["lada"]
var active_turn_index := 0
var roster_open := false
var skill_tree_open := false
var skill_tree_selected_branch := 0
var skill_tree_selected_tier := 0
var skill_icons := {}
var skill_tree_backgrounds := {}
var skill_tree_connector_arrow: Texture2D
var roster_filter := "all"
var roster_hero_index := 0
var roster_swap_open := false
var roster_swap_hero_id := ""
var roster_transition_time := 1.0
var roster_transition_direction := 1.0
var roster_transition_from_id := ""
const ROSTER_TRANSITION_DURATION := 0.34
var building_levels := {"domostwa": 0, "kuznia": 0, "chata_zielarki": 0, "swiety_gaj": 0, "spichlerz": 0, "wieza_peruna": 0}
var village_open := false
var map_open := false
var map_page := 0
var map_drag_distance := 0.0
var map_was_dragged := false
var booster_open := false
var main_menu_open := true
var help_open := false
var training_open := false
var training_mode := false
var training_battle: Dictionary = {}
var region_intro_open := false
var seen_region_intros := {}
var seen_region_chapters := {}
var active_region_intro: Array = []
var active_region_intro_key := ""
var current_battle: Dictionary = {}
var reset_confirmation := false
var daily_reward_day := ""
var oak_borderland_background: Texture2D
var board_roots_frame: Texture2D
var tile_remove_burst: Texture2D
var tile_remove_frames: Array[Texture2D] = []
var village_background: Texture2D
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
var booster_roots_pedestal: Texture2D
var booster_count_medallion: Texture2D
var defeat_modal_oak: Texture2D
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
var battle_header_oak: Texture2D
var enemy_square_card_frame: Texture2D
var battle_board_roots: Texture2D
var enemy_role_scout_icon: Texture2D
var enemy_role_mystic_icon: Texture2D
var enemy_role_attacker_icon: Texture2D
var star_rating_icon: Texture2D
var coin_resource_icon: Texture2D
var wood_resource_icon: Texture2D
var experience_resource_icon: Texture2D
var perun_sparks_resource_icon: Texture2D
var map_region_gate: Texture2D
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
var sfx_player: AudioStreamPlayer
var sfx_playback: AudioStreamGeneratorPlayback
var sfx_phase := 0.0
var sfx_frequency := 0.0
var sfx_remaining_frames := 0
var sfx_amplitude := 0.0
var sfx_enabled := true
const SFX_MIX_RATE := 22050.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	skill_tree_connector_arrow = load_image_texture("res://art/ui/skill_tree_connector_arrow_v01.png")
	for background_hero_id in HERO_IDS:
		skill_tree_backgrounds[background_hero_id] = load("res://art/skill_backgrounds/skill_tree_%s.png" % background_hero_id) as Texture2D
	var alegreya_font := FontFile.new()
	if alegreya_font.load_dynamic_font("res://art/fonts/AlegreyaSans-Bold.ttf") == OK:
		font = alegreya_font
	oak_borderland_background = load_image_texture("res://art/environments/environment_debowe_pogranicze_v01.png")
	board_roots_frame = null
	tile_remove_burst = load_image_texture("res://art/vfx/tile_remove_burst_v01.png")
	for frame_index in range(1, 5):
		var frame_texture := load_image_texture("res://art/vfx/tile_remove_burst_v01_f%d.png" % frame_index)
		if frame_texture != null:
			tile_remove_frames.append(frame_texture)
	village_background = load_image_texture("res://art/environments/village_debowe_pogranicze_v01.png")
	leszy_portrait = load_image_texture("res://art/characters/boss_leszy_portrait_v01.png")
	wilk_cienia_portrait = load_image_texture("res://art/characters/boss_wilk_cienia_portrait_v01.png")
	rusalka_portrait = load_image_texture("res://art/characters/boss_rusalka_czarnego_stawu_portrait_v01.png")
	zmij_portrait = load_image_texture("res://art/characters/boss_zmij_popielny_portrait_v01.png")
	krolowa_kurhanow_portrait = load_image_texture("res://art/characters/boss_krolowa_kurhanow_portrait_v01.png")
	pan_zimnych_mgiel_portrait = load_image_texture("res://art/characters/boss_pan_zimnych_mgiel_portrait_v01.png")
	wladca_kruczych_znakow_portrait = load_image_texture("res://art/characters/boss_wladca_kruczych_znakow_portrait_v01.png")
	niedzwiedz_gromu_portrait = load_image_texture("res://art/characters/boss_niedzwiedz_gromu_portrait_v01.png")
	biala_pani_mlynow_portrait = load_image_texture("res://art/characters/boss_biala_pani_mlynow_portrait_v01.png")
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
	booster_roots_pedestal = load_image_texture("res://art/vfx/booster_roots_pedestal_v01.png")
	booster_count_medallion = load_image_texture("res://art/vfx/booster_count_medallion_v01.png")
	defeat_modal_oak = load_image_texture("res://art/vfx/defeat_modal_oak_v01.png")
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
	battle_header_oak = load_image_texture("res://art/ui/battle_header_oak_v01.png")
	enemy_square_card_frame = load_image_texture("res://art/ui/enemy_square_card_frame_v01.png")
	battle_board_roots = load_image_texture("res://art/ui/battle_board_roots_v02.png")
	enemy_role_scout_icon = load_image_texture("res://art/ui/enemy_role_scout_v01.png")
	enemy_role_mystic_icon = load_image_texture("res://art/ui/enemy_role_mystic_v01.png")
	enemy_role_attacker_icon = load_image_texture("res://art/ui/enemy_role_attacker_v01.png")
	star_rating_icon = load_image_texture("res://art/ui/icon_star_oak_v01.png")
	coin_resource_icon = load_image_texture("res://art/ui/icon_coin_oak_v01.png")
	wood_resource_icon = load_image_texture("res://art/ui/icon_wood_oak_v01.png")
	experience_resource_icon = load_image_texture("res://art/ui/icon_xp_oak_v01.png")
	perun_sparks_resource_icon = load_image_texture("res://art/ui/icon_perun_sparks_v01.png")
	map_region_gate = load_image_texture("res://art/ui/map_region_gate_v01.png")
	for enemy_name_key in NORMAL_ENEMY_PORTRAIT_SLUGS:
		var enemy_slug: String = NORMAL_ENEMY_PORTRAIT_SLUGS[enemy_name_key]
		enemy_portraits[enemy_name_key] = load_image_texture("res://art/characters/normal_enemies/enemy_%s_portrait_v01.png" % enemy_slug)
	enemy_portraits["Król Topielców"] = load_image_texture("res://art/characters/boss_krol_topielcow_portrait_v01.png")
	enemy_portraits["Matka Ciernistych Pól"] = load_image_texture("res://art/characters/boss_matka_ciernistych_pol_portrait_v01.png")
	enemy_portraits["Strażnik Bursztynowej Jaskini"] = load_image_texture("res://art/characters/boss_straznik_bursztynowej_jaskini_portrait_v01.png")
	enemy_portraits["Baba Jaga z Żelaznego Boru"] = load_image_texture("res://art/characters/boss_baba_jaga_zelazny_bor_portrait_v01.png")
	enemy_portraits["Wąż Wiślany"] = load_image_texture("res://art/characters/boss_waz_wislany_portrait_v01.png")
	enemy_portraits["Czarny Bóg Przesmyku"] = load_image_texture("res://art/characters/boss_czarny_bog_przesmyku_portrait_v01.png")
	# Nazwy kampanii bez osobnego pliku wykorzystują właściwy portret bossa.
	enemy_portraits["Stary Leszy"] = load_image_texture("res://art/characters/normal_enemies/enemy_stary_leszy_portrait_v01.png")
	enemy_portraits["Wilk cienia"] = load_image_texture("res://art/characters/normal_enemies/enemy_wilk_cienia_portrait_v01.png")
	enemy_portraits["Duch dębu"] = load_image_texture("res://art/characters/normal_enemies/enemy_duch_debu_portrait_v01.png")
	enemy_portraits["Duch dębu"] = load_image_texture("res://art/characters/normal_enemies/enemy_duch_debu_portrait_v02.png")
	for hero_id in HERO_IDS:
		var portrait := load_image_texture("res://art/characters/hero_%s_portrait_v05.png" % hero_id)
		if portrait != null:
			hero_portraits[hero_id] = portrait
		else:
			# Nowi bohaterowie zachowują pełną czytelność kart przed dostarczeniem
			# ich indywidualnych portretów — nigdy nie rysujemy pustej sylwetki.
			hero_portraits[hero_id] = hero_portraits.get("lada", null)
	for hero_id in HERO_IDS:
		hero_accent_textures[hero_id] = load_image_texture("res://art/vfx/hero_accent_%s.png" % hero_id)
	setup_procedural_sfx()
	levels = load_levels()
	load_progress()
	start_level(0)
	main_menu_open = true
	queue_redraw()

func _process(delta: float) -> void:
	ui_anim_time += delta
	if roster_transition_time < ROSTER_TRANSITION_DURATION:
		roster_transition_time = minf(ROSTER_TRANSITION_DURATION, roster_transition_time + delta)
		queue_redraw()
	fill_sfx_buffer()
	if state == "playing" and not animation_busy and not main_menu_open and not roster_open and not village_open and not map_open and not booster_open and not training_open and not region_intro_open:
		idle_hint_time += delta
		if idle_hint_time >= 7.0 and hinted_cells.is_empty():
			hinted_cells = find_hint_move()
			queue_redraw()
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

func play_sfx(frequency: float, duration: float, amplitude: float = 0.18) -> void:
	if not sfx_enabled or sfx_playback == null:
		return
	sfx_frequency = frequency
	sfx_phase = 0.0
	sfx_remaining_frames = maxi(1, int(duration * SFX_MIX_RATE))
	sfx_amplitude = clampf(amplitude, 0.0, 0.45)

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
	level_index = clampi(index, 0, levels.size() - 1)
	training_mode = not level_override.is_empty()
	if not training_mode:
		training_battle.clear()
	var level: Dictionary = level_override if not level_override.is_empty() else levels[level_index]
	current_battle = level.duplicate(true)
	moves_left = level.moves
	score = 0
	state = "playing"
	lada_charge = 0
	lada_targeting = false
	brun_charge = 0
	brun_targeting = false
	mieta_charge = 0
	hammer_count = 1
	hammer_targeting = false
	bolt_count = 1
	bolt_targeting = false
	gale_count = 1
	gale_targeting = false
	selected_cell = Vector2i(-1, -1)
	last_reward = {}
	last_stars = 0
	active_turn_index = 0
	party_max_health = 0
	party_health = 0
	for hero_id in active_heroes:
		var hero_tree: Dictionary = hero_trees.get(hero_id, {})
		var max_health := 55 + int(hero_levels[hero_id]) * 12 + int(building_levels["domostwa"]) * 5 + SkillTree.ranks(hero_tree, 1, 2) * 3
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
	message = "Trening: pokonaj przeciwnika i zdobądź PD dla aktywnego składu." if training_mode else ("Cel: %d pkt. Przeciągnij sąsiednie znaki, aby połączyć co najmniej 3." % int(level.get("target", 0)) if level_index == 0 and not tutorial_completed else "Połącz trzy takie same znaki.")
	fill_fresh_board()
	setup_obstacles(level)
	var intro_level_id := int(level.get("id", 0))
	active_region_intro = []
	active_region_intro_key = ""
	region_intro_open = false
	if not training_mode and REGION_INTROS.has(intro_level_id) and not bool(seen_region_intros.get(intro_level_id, false)):
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
	if not FileAccess.file_exists(file_path):
		return null
	var image := Image.load_from_file(file_path)
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)

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

func reshuffle_board() -> void:
	var values: Array[int] = []
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			values.append(int(board[row][col]))
	for attempt in range(64):
		values.shuffle()
		var value_index := 0
		for row in BOARD_SIZE:
			for col in BOARD_SIZE:
				board[row][col] = values[value_index]
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
	for row in BOARD_SIZE:
		board.append([])
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

func setup_obstacles(level: Dictionary) -> void:
	obstacles.clear()
	for row in BOARD_SIZE:
		obstacles.append([])
		for col in BOARD_SIZE:
			obstacles[row].append(0)
	var obstacle_config: Dictionary = level.get("obstacles", {})
	var types := {"root": 1, "stone": 2, "curse": 3}
	# Nawet trudny etap musi zostawić miejsce na kombinacje. Bez limitu dane
	# późnej kampanii mogły przykryć niemal wszystkie pola planszy.
	var level_id := int(level.get("id", level_index + 1))
	var obstacle_budget := mini(24, 8 + int(level_id / 12))
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
	if event is InputEventKey and event.pressed and not event.echo:
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
			skill_tree_open = false
			queue_redraw()
			return
	if event is InputEventScreenTouch:
		if event.pressed:
			handle_press(event.position)
		else:
			handle_release(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			handle_press(event.position)
		else:
			handle_release(event.position)

func handle_press(position: Vector2) -> void:
	if state != "playing":
		return
	idle_hint_time = 0.0
	hinted_cells.clear()
	for index in enemies.size():
		if is_in_button(position, enemy_target_rect(index)):
			var enemy: Dictionary = enemies[index]
			held_tooltip = "%s • %s" % [str(enemy.get("name", "Wróg")), enemy_tactical_hint(enemy)]
			queue_redraw()
			return
	for index in active_heroes.size():
		if is_in_button(position, hero_battle_rect(index)):
			var hero_id: String = active_heroes[index]
			held_tooltip = "%s • %s" % [HERO_NAMES[HERO_IDS.find(hero_id)], HERO_SKILLS[hero_id]]
			queue_redraw()
			return
	touch_start = point_to_cell(position)

func handle_release(position: Vector2) -> void:
	var pressed_cell := touch_start
	touch_start = Vector2i(-1, -1)
	if enemy_turn_active:
		return
	if held_tooltip != "":
		held_tooltip = ""
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
	for index in enemies.size():
		if not roster_open and not village_open and not map_open and not booster_open and not training_open and not help_open and not main_menu_open and is_in_button(position, enemy_target_rect(index)) and int(enemies[index].get("health", 0)) > 0:
			previous_target_index = target_enemy_index
			target_enemy_index = index
			target_transition = 1.0
			message = "Cel: %s" % str(enemies[index].get("name", "Wróg"))
			queue_redraw()
			return
	if main_menu_open:
		if help_open:
			handle_help_input(position)
			return
		handle_main_menu_input(position)
		return
	if skill_tree_open:
		handle_skill_tree_input(position)
		return
	if is_in_button(position, pause_rect()):
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
		map_page = int(maxi(0, unlocked_level - 1) / 5)
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
		queue_redraw()
		return
	if is_in_button(position, lada_skill_rect()) and current_turn_hero() == "lada" and lada_charge >= LADA_MAX_CHARGE:
		hammer_targeting = false
		bolt_targeting = false
		gale_targeting = false
		brun_targeting = false
		lada_targeting = true
		message = "Strzała Peruna: wybierz kolumnę na planszy."
		queue_redraw()
		return
	if is_in_button(position, brun_skill_rect()) and current_turn_hero() == "brun" and brun_charge >= BRUN_MAX_CHARGE:
		hammer_targeting = false
		bolt_targeting = false
		gale_targeting = false
		lada_targeting = false
		brun_targeting = true
		message = "Uderzenie Kowala: wybierz środek obszaru 3×3."
		queue_redraw()
		return
	if is_in_button(position, mieta_skill_rect()) and current_turn_hero() == "mieta" and mieta_charge >= MIETA_MAX_CHARGE:
		lada_targeting = false
		brun_targeting = false
		hammer_targeting = false
		bolt_targeting = false
		gale_targeting = false
		activate_mieta()
		return
	if is_in_button(position, hammer_rect()) and hammer_count > 0:
		lada_targeting = false; brun_targeting = false; bolt_targeting = false; gale_targeting = false
		hammer_targeting = true; message = "Młot bursztynowy: wybierz środek obszaru 3×3."; queue_redraw(); return
	if is_in_button(position, bolt_booster_rect()) and bolt_count > 0:
		lada_targeting = false; brun_targeting = false; hammer_targeting = false; gale_targeting = false
		bolt_targeting = true; message = "Grom Peruna: wybierz rząd do zniszczenia."; queue_redraw(); return
	if is_in_button(position, gale_booster_rect()) and gale_count > 0:
		lada_targeting = false; brun_targeting = false; hammer_targeting = false; bolt_targeting = false
		gale_targeting = true; message = "Wiatr Gaju: wybierz typ znaku do rozwiania."; queue_redraw(); return
	var released_cell := point_to_cell(position)
	if released_cell.x < 0:
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

func handle_tile_click(cell: Vector2i) -> void:
	if selected_cell.x < 0:
		selected_cell = cell
		message = "Wybrano znak — kliknij sąsiednie pole, aby go zamienić."
	elif selected_cell == cell:
		selected_cell = Vector2i(-1, -1)
		message = "Wybór anulowany."
	elif abs(selected_cell.x - cell.x) + abs(selected_cell.y - cell.y) == 1:
		var first := selected_cell
		selected_cell = Vector2i(-1, -1)
		try_swap(first, cell)
	else:
		selected_cell = cell
		message = "Wybrano nowy znak — kliknij sąsiednie pole."
	queue_redraw()

func try_swap(a: Vector2i, b: Vector2i) -> void:
	if animation_busy or enemy_turn_active:
		return
	swap_tiles(a, b)
	var matches := find_matches()
	if matches.is_empty():
		await animate_swap(a, b)
		swap_tiles(a, b)
		play_sfx(185.0, 0.09, 0.12)
		message = "Ten ruch nie tworzy połączenia."
		queue_redraw()
		return
	await animate_swap(a, b)
	play_sfx(540.0, 0.08, 0.16)
	resolve_matches(matches)
	if goal_type == "survive":
		goal_progress = mini(goal_target, goal_progress + 1)
	# Limit ruchów jest zużywany wyłącznie po prawidłowej zamianie tworzącej
	# kombinację. Nietrafione przesunięcie nadal pozostaje bez kosztu.
	moves_left = maxi(0, moves_left - 1)
	if level_index == 0 and not tutorial_completed:
		tutorial_completed = true
		save_progress()
	if is_level_complete():
		finish_level("Las odpowiada na twój szept.")
		return
	if moves_left <= 0:
		state = "lost"
		message = "Brak ruchów. Wróć silniejszy albo spróbuj innej kombinacji."
		queue_redraw()
		return
	# Plansza musi najpierw pokazać opadanie i nowe znaki. Dopiero na
	# ustabilizowanej planszy przeciwnik zaczyna analizować swój ruch.
	await wait_for_board_to_settle()
	await enemy_take_turn()
	advance_turn()
	if party_health <= 0:
		state = "lost"
		message = "Drużyna została pokonana przez %s." % enemy_name
	else:
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
	lada_targeting = false
	lada_charge = 0
	var struck := {}
	for row in BOARD_SIZE:
		struck[Vector2i(target.x, row)] = true
	resolve_matches(struck)
	if has_living_enemies():
		deal_damage_to_enemies(8 * int(hero_levels["lada"]) + int(building_levels["wieza_peruna"]) * 5)
	if is_level_complete():
		finish_level("Piorun Ledy prowadzi cię dalej.")
	else:
		finish_special_turn("Strzała Peruna rozdarła kolumnę!")
	queue_redraw()

func activate_brun(target: Vector2i) -> void:
	brun_targeting = false
	brun_charge = 0
	var struck := {}
	for row in range(maxi(0, target.y - 1), mini(BOARD_SIZE, target.y + 2)):
		for col in range(maxi(0, target.x - 1), mini(BOARD_SIZE, target.x + 2)):
			struck[Vector2i(col, row)] = true
	resolve_matches(struck)
	if has_living_enemies():
		deal_damage_to_enemies(25 + 10 * int(hero_levels["brun"]) + int(building_levels["kuznia"]) * 5)
	if is_level_complete():
		finish_level("Uderzenie Bruna skruszyło obronę wroga.")
	else:
		finish_special_turn("Uderzenie Kowala niszczy obszar i zadaje dodatkowe obrażenia!")
	queue_redraw()

func activate_mieta() -> void:
	mieta_charge = 0
	var healed_tiles := 0
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if board[row][col] == 1:
				board[row][col] = -1
				healed_tiles += 1
	var healing := healed_tiles * (6 + int(hero_levels["mieta"]) + int(building_levels["chata_zielarki"]))
	heal_all_living_heroes(healing)
	collapse_board()
	resolve_matches(find_matches())
	if is_level_complete():
		finish_level("Krąg Uzdrowienia ocalił drużynę.")
	else:
		finish_special_turn("Krąg Uzdrowienia przywrócił drużynie po %d zdrowia." % healing)
	queue_redraw()

func finish_special_turn(success_message: String) -> void:
	await enemy_take_turn()
	advance_turn()
	if party_health <= 0:
		state = "lost"
		message = "Drużyna została pokonana przez wrogów."
	else:
		message = success_message

func activate_hammer(target: Vector2i) -> void:
	hammer_targeting = false
	hammer_count -= 1
	var struck := {}
	for row in range(maxi(0, target.y - 1), mini(BOARD_SIZE, target.y + 2)):
		for col in range(maxi(0, target.x - 1), mini(BOARD_SIZE, target.x + 2)):
			struck[Vector2i(col, row)] = true
	resolve_matches(struck)
	if is_level_complete():
		finish_level("Uderzenie młota otworzyło dalszą drogę.")
	else:
		message = "Młot bursztynowy zniszczył pobliskie znaki!"
	queue_redraw()

func activate_bolt(target: Vector2i) -> void:
	bolt_targeting = false
	bolt_count -= 1
	var struck := {}
	for col in BOARD_SIZE:
		struck[Vector2i(col, target.y)] = true
	resolve_matches(struck)
	if is_level_complete():
		finish_level("Grom Peruna otworzył dalszą drogę.")
	else:
		message = "Grom Peruna zniszczył cały rząd!"
	queue_redraw()

func activate_gale(target: Vector2i) -> void:
	gale_targeting = false
	gale_count -= 1
	var selected_type: int = board[target.y][target.x]
	var struck := {}
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			if board[row][col] == selected_type:
				struck[Vector2i(col, row)] = true
	resolve_matches(struck)
	if is_level_complete():
		finish_level("Wiatr Gaju odsłonił nową ścieżkę.")
	else:
		message = "Wiatr Gaju rozwiał wszystkie znaki tego typu!"
	queue_redraw()

func resolve_matches(matches: Dictionary) -> void:
	var chain := 1
	var cascade_steps := 0
	while not matches.is_empty() and cascade_steps < MAX_CASCADE_STEPS:
		if cascade_steps == 0:
			play_sfx(720.0, 0.12, 0.20)
		var has_five := false
		var has_four := false
		var has_square := false
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
		if has_five:
			for key in matches.duplicate():
				var five_cell: Vector2i = key
				for col in BOARD_SIZE:
					matches[Vector2i(col, five_cell.y)] = true
		if has_five:
			message = "ULTRA KOMBO — cały rząd zostanie zniszczony!"
		elif has_square:
			message = "KOMBO KWADRAT — fala uderzeniowa niszczy otoczenie!"
		elif has_four:
			message = "MOCNE KOMBO — dodatkowe obrażenia!"
		var gained := matches.size() * 25 * chain
		if matches.size() >= 4:
			gained += 50 * chain
		score += gained
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
				removal_effects[cell] = 0.0
				board[cell.y][cell.x] = -1
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
			moves_left += 1
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
			deal_damage_to_enemies(synergy_damage, defender_damage_multiplier)
		collapse_board()
		matches = find_matches()
		chain += 1
		cascade_steps += 1
	# Długa kaskada nie jest powodem do przetasowania. Po zwiększeniu limitu
	# pozostawiamy planszę w jej rzeczywistym stanie, zamiast wyglądać jak reset.
	if not board_has_legal_move():
		reshuffle_board()

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
		if removed_count >= 5:
			wave_damage += 60
		total_combo_damage += wave_damage * chain
		for key in matches:
			var cell: Vector2i = key
			if board[cell.y][cell.x] >= 0:
				removal_effects[cell] = 0.0
				board[cell.y][cell.x] = -1
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
	if not enemies.is_empty():
		return not has_living_enemies()
	if goal_type == "collect_amber" or goal_type == "collect_rune" or goal_type == "clear_obstacles":
		return goal_progress >= goal_target
	return score >= goal_target

func goal_label() -> String:
	# Przetrwanie celowo ma aktywnych wrogów, ale zwycięstwo zależy od liczby
	# wytrzymanych tur, a nie od ich pokonania. Pokazuj więc właściwy warunek.
	if goal_type == "survive":
		return "Przetrwaj: %d / %d tur" % [goal_progress, goal_target]
	if not enemies.is_empty():
		return "Pokonaj wrogów: %d / %d" % [living_enemy_count(), enemies.size()]
	if goal_type == "collect_amber":
		return "Bursztyn: %d / %d" % [goal_progress, goal_target]
	if goal_type == "collect_rune":
		return "Runy: %d / %d" % [goal_progress, goal_target]
	if goal_type == "clear_obstacles":
		return "Oczyść przeszkody: %d / %d" % [goal_progress, goal_target]
	return "Punkty: %d / %d" % [score, goal_target]

func finish_level(success_message: String) -> void:
	state = "won"
	play_sfx(880.0, 0.32, 0.24)
	last_stars = calculate_stars()
	if training_mode:
		grant_training_reward()
		save_progress()
		message = "%s Aktywny skład otrzymuje PD — trening można powtarzać bez ograniczeń." % success_message
		return
	var level_id := int(levels[level_index].get("id", level_index + 1))
	level_stars[level_id] = maxi(int(level_stars.get(level_id, 0)), last_stars)
	unlocked_level = max(unlocked_level, min(level_index + 2, levels.size()))
	grant_level_reward()
	var gained_spark := grant_boss_spark()
	var gained_event_mark := grant_event_mark()
	last_reward["sparks"] = 1 if gained_spark else 0
	last_reward["event_marks"] = 1 if gained_event_mark else 0
	save_progress()
	message = success_message

func calculate_stars() -> int:
	if moves_left >= 9:
		return 3
	if moves_left >= 4:
		return 2
	return 1

func enemy_take_turn() -> void:
	if not has_living_enemies():
		return
	# Blokada wejścia zostaje aktywna przez całą czytelną turę przeciwnika,
	# również podczas jego namysłu i po animacji zamiany.
	enemy_turn_active = true
	animation_busy = true
	var total_attack := 0
	var enrage_text := ""
	for enemy in enemies:
		if int(enemy.get("health", 0)) > 0:
			var enemy_attack_value := int(enemy.get("attack", 0))
			total_attack += enemy_attack_value
			var enemy_maximum := int(enemy.get("max_health", 1))
			if enemy_maximum >= 350 and int(enemy.get("health", 0)) * 2 <= enemy_maximum:
				if not bool(enemy.get("enraged", false)):
					enemy["enraged"] = true
					enrage_text = "%s wpada w szał!" % str(enemy.get("name", "Wróg"))
				total_attack += maxi(3, int(enemy_attack_value / 2))
	var target_hero := scout_target_hero()
	enemy_attack_anim = 6.5
	message = "Wróg obserwuje planszę i szuka najmocniejszego ruchu..."
	var support_text := enemy_support_action()
	enemy_action_phase = 0
	enemy_action_cells.clear()
	queue_redraw()
	await get_tree().create_timer(1.35).timeout
	var best_move := enemy_choose_best_move()
	var combo_damage := 0
	if not best_move.is_empty():
		var first: Vector2i = best_move["from"]
		var second: Vector2i = best_move["to"]
		enemy_action_cells = [first, second]
		enemy_action_phase = 1
		message = "Wróg wybrał dwa znaki — za chwilę je zamieni."
		queue_redraw()
		await get_tree().create_timer(1.45).timeout
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
		animation_busy = true
		await get_tree().create_timer(0.35).timeout
	enemy_action_cells.clear()
	enemy_action_phase = 0
	# Kombinacja przeciwnika jest czytelną zapowiedzią zagrożenia, nie pojedynczym
	# ciosem kończącym walkę. Jej siła to tylko 10% wartości pokazywanej kaskady.
	var total_damage := maxi(0, total_attack + int(round(float(combo_damage) * 0.10)) - enemy_attack_weakened)
	enemy_attack_weakened = 0
	var absorbed := mini(party_shield, total_damage)
	party_shield -= absorbed
	var damage := total_damage - absorbed
	if damage > 0:
		hero_health[target_hero] = maxi(0, int(hero_health[target_hero]) - damage)
		damage_popup_value = damage
		damage_popup_time = 0.8
	refresh_party_health()
	var attack_name := "Kombinacja przeciwnika" if not best_move.is_empty() else "Atak przeciwnika"
	last_enemy_attack_text = "%s%s%s: %d obrażeń w %s%s." % ["%s " % enrage_text if enrage_text != "" else "", "%s " % support_text if support_text != "" else "", attack_name, damage, HERO_NAMES[HERO_IDS.find(target_hero)], " (tarcza pochłonęła %d)" % absorbed if absorbed > 0 else ""]
	message = "Twój ruch — wybierz kafelek i wykonaj ruch."
	animation_busy = false
	enemy_turn_active = false

func refresh_party_health() -> void:
	party_health = 0
	party_max_health = 0
	for hero_id in active_heroes:
		party_health += int(hero_health[hero_id])
		party_max_health += int(hero_max_health[hero_id])

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
	hero_health[hero_id] = mini(int(hero_max_health[hero_id]), previous_health + amount)
	if int(hero_health[hero_id]) > previous_health:
		play_sfx(390.0, 0.14, 0.13)
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
	if str(target.get("role", "attacker")) == "defender":
		actual_damage = int(round(float(actual_damage) * defender_damage_multiplier))
	if str(target.get("role", "attacker")) != "defender" and has_living_defender():
		actual_damage = maxi(1, int(round(float(amount) * 0.55)))
		target["guarded"] = true
	enemies[damaged_index]["health"] = maxi(0, int(enemies[damaged_index].get("health", 0)) - actual_damage)
	enemy_damage_popup_index = damaged_index
	enemy_damage_popup_value = actual_damage
	enemy_damage_popup_time = 0.9
	play_sfx(235.0, 0.10, 0.18)
	# Dopiero od następnej fali kaskady wskazujemy kolejnego żywego wroga.
	# Nie wykonujemy tu drugiego odejmowania obrażeń.
	if int(enemies[damaged_index].get("health", 0)) <= 0:
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
		"support": return "MISTYK"
		"scout": return "ZWIADOWCA"
	return "NAPASTNIK"

func enemy_role_color(enemy: Dictionary) -> Color:
	match str(enemy.get("role", "attacker")):
		"defender": return Color("#5d92b8")
		"support": return Color("#72ad82")
		"scout": return Color("#b18bca")
	return Color("#bd654d")

func draw_enemy_role_icon(center: Vector2, role: String, color: Color) -> void:
	var role_icon: Texture2D = null
	if role == "scout":
		role_icon = enemy_role_scout_icon
	elif role == "support":
		role_icon = enemy_role_mystic_icon
	elif role == "attacker":
		role_icon = enemy_role_attacker_icon
	if role_icon != null:
		draw_texture_rect(role_icon, Rect2(center - Vector2(10.0, 10.0), Vector2(20.0, 20.0)), false)
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

func hero_selection_color(hero_id: String) -> Color:
	match hero_id:
		"lada": return Color("#9bd36a")
		"brun": return Color("#ef7d42")
		"mieta": return Color("#61c8da")
		"wszebor": return Color("#e7a24d")
		"rada": return Color("#e7bc58")
		"zywia": return Color("#b27ae1")
	return Color("#d9b45d")

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

func grant_level_reward() -> void:
	var reward: Dictionary = levels[level_index].get("rewards", {})
	var received_coins := int(reward.get("coins", 0))
	var received_wood := int(reward.get("wood", 0))
	var received_experience := int(reward.get("experience", 0))
	received_coins += int(building_levels["spichlerz"]) * 10
	coins += received_coins
	wood += received_wood
	experience += received_experience
	grant_hero_experience(received_experience)
	last_reward = {"coins": received_coins, "wood": received_wood, "experience": received_experience}

func grant_boss_spark() -> bool:
	var level_id := int(levels[level_index].get("id", level_index + 1))
	# Każdy poziom kampanii zawiera wrogów, ale Iskra jest nagrodą za etap bossa
	# (co piąty poziom), a nie za każdą zwykłą potyczkę.
	if level_id % 5 != 0 or bool(claimed_boss_sparks.get(level_id, false)):
		return false
	perun_sparks += 1
	claimed_boss_sparks[level_id] = true
	return true

func grant_event_mark() -> bool:
	var level_id := int(levels[level_index].get("id", level_index + 1))
	# Co piąty poziom jest etapem wydarzenia; znak jest przyznawany tylko raz.
	if level_id % 5 == 0 and not bool(claimed_boss_sparks.get(-level_id, false)):
		event_marks += 1
		claimed_boss_sparks[-level_id] = true
		return true
	return false

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
	var received_coins := int(reward.get("coins", 0))
	var received_wood := int(reward.get("wood", 0))
	var received_experience := int(reward.get("experience", 0))
	coins += received_coins
	wood += received_wood
	experience += received_experience
	# Trening rozwija wyłącznie bohaterów, których gracz świadomie wystawił.
	for hero_id in active_heroes:
		hero_experience[hero_id] = int(hero_experience[hero_id]) + received_experience
	last_reward = {"coins": received_coins, "wood": received_wood, "experience": received_experience}

func restart_current_battle() -> void:
	if training_mode:
		start_level(level_index, training_battle)
	else:
		start_level(level_index)

func hero_experience_to_next_level(hero_id: String) -> int:
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
		var kept: Array = []
		for row in range(BOARD_SIZE - 1, -1, -1):
			if board[row][col] >= 0:
				kept.append(board[row][col])
		var row := BOARD_SIZE - 1
		for value in kept:
			board[row][col] = value
			row -= 1
		while row >= 0:
			board[row][col] = randi_range(0, TILE_TYPES - 1)
			row -= 1

func swap_tiles(a: Vector2i, b: Vector2i) -> void:
	var saved: int = board[a.y][a.x]
	board[a.y][a.x] = board[b.y][b.x]
	board[b.y][b.x] = saved

func board_rect() -> Rect2:
	var width := minf(get_viewport_rect().size.x - 120.0, 400.0)
	return Rect2((get_viewport_rect().size.x - width) / 2.0, 350.0, width, width)

func enemy_card_rect(index: int) -> Rect2:
	var enemy_count := maxi(1, enemies.size())
	var gap := 8.0
	var card_width := minf(165.0, (get_viewport_rect().size.x - 32.0 - gap * float(enemy_count - 1)) / float(enemy_count))
	var group_width := card_width * float(enemy_count) + gap * float(enemy_count - 1)
	var start_x := (get_viewport_rect().size.x - group_width) * 0.5
	return Rect2(start_x + index * (card_width + gap), 74.0, card_width, 212.0)

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
	return Rect2(get_viewport_rect().size.x / 2.0 - 150.0, 558.0, 300.0, 86.0)

func defeat_training_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 150.0, 654.0, 300.0, 86.0)

func result_modal_rect() -> Rect2:
	return Rect2(12.0, 280.0, get_viewport_rect().size.x - 24.0, 460.0)

func previous_rect() -> Rect2:
	return Rect2(24.0, 902.0, 160.0, 42.0)

func next_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 184.0, 902.0, 160.0, 42.0)

func lada_skill_rect() -> Rect2:
	return Rect2(20.0, 822.0, 160.0, 72.0)

func brun_skill_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 80.0, 822.0, 160.0, 72.0)

func mieta_skill_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 180.0, 822.0, 160.0, 72.0)

func hero_battle_rect(index: int) -> Rect2:
	if active_heroes.size() == 1:
		return Rect2(get_viewport_rect().size.x / 2.0 - 80.0, 796.0, 160.0, 72.0)
	return [lada_skill_rect(), brun_skill_rect(), mieta_skill_rect()][index]

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

func roster_skill_tree_rect() -> Rect2:
	return Rect2(95.0, 744.0, get_viewport_rect().size.x - 190.0, 70.0)

func skill_tree_node_rect(branch: int, tier: int) -> Rect2:
	return Rect2(24.0 + branch * 168.0, 210.0 + tier * 130.0, 156.0, 102.0)

func skill_tree_back_rect() -> Rect2:
	return Rect2(178.0, 906.0, 184.0, 40.0)

func skill_tree_upgrade_rect() -> Rect2:
	return Rect2(94.0, 858.0, 352.0, 42.0)

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
	return Rect2(get_viewport_rect().size.x / 2.0 - 75.0, 686.0, 150.0, 36.0)

func village_upgrade_rect(index: int) -> Rect2:
	return Rect2(344.0, 219.0 + index * 70.0, 126.0, 32.0)

func map_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 178.0, 34.0, 98.0, 32.0)

func map_close_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 80.0, 780.0, 160.0, 38.0)

func map_level_rect(index: int) -> Rect2:
	var positions := [Vector2(270, 242), Vector2(145, 355), Vector2(350, 470), Vector2(170, 585), Vector2(290, 700)]
	var center: Vector2 = positions[index]
	return Rect2(center - Vector2(42, 26), Vector2(84, 52))

func map_previous_page_rect() -> Rect2:
	return Rect2(44.0, 104.0, 110.0, 34.0)

func map_next_page_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 154.0, 104.0, 110.0, 34.0)

func map_page_count() -> int:
	return int(ceili(float(levels.size()) / 5.0))

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
	return Rect2(get_viewport_rect().size.x / 2.0 - 187.5, 454.0, 375.0, 78.0)

func daily_reward_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 150.0, 395.0, 300.0, 42.0)

func main_menu_map_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 187.5, 541.0, 375.0, 69.0)

func main_menu_roster_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 187.5, 619.0, 375.0, 63.0)

func main_menu_village_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 187.5, 691.0, 375.0, 63.0)

func main_menu_booster_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 187.5, 763.0, 375.0, 63.0)

func main_menu_training_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 187.5, 835.0, 375.0, 63.0)

func reset_progress_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x - 94.0, 22.0, 78.0, 22.0)

func help_button_rect() -> Rect2:
	return Rect2(302.0, 38.0, 32.0, 22.0)

func help_close_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 120.0, 730.0, 240.0, 48.0)

func sound_toggle_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 120.0, 668.0, 240.0, 46.0)

func training_close_rect() -> Rect2:
	return Rect2(get_viewport_rect().size.x / 2.0 - 75.0, 760.0, 150.0, 38.0)

func training_choice_rect(index: int) -> Rect2:
	return Rect2(54.0, 220.0 + index * 142.0, get_viewport_rect().size.x - 108.0, 118.0)

func building_cost(building_id: String) -> Dictionary:
	var bases := {
		"domostwa": {"coins": 500, "wood": 80}, "kuznia": {"coins": 800, "wood": 120},
		"chata_zielarki": {"coins": 600, "wood": 60}, "swiety_gaj": {"coins": 1000, "wood": 100},
		"spichlerz": {"coins": 550, "wood": 90}, "wieza_peruna": {"coins": 1200, "wood": 140}
	}
	var base: Dictionary = bases[building_id]
	var multiplier := 1.0 + float(building_levels[building_id]) * 0.25
	return {"coins": int(round(int(base["coins"]) * multiplier)), "wood": int(round(int(base["wood"]) * multiplier))}

func try_upgrade_building(building_id: String) -> bool:
	var building_index := BUILDING_IDS.find(building_id)
	if building_index < 0:
		return false
	if int(building_levels.get(building_id, 0)) >= MAX_BUILDING_LEVEL:
		message = "%s osiągnęła maksymalny poziom %d." % [BUILDING_NAMES[building_index], MAX_BUILDING_LEVEL]
		return false
	var cost := building_cost(building_id)
	if coins < int(cost["coins"]) or wood < int(cost["wood"]):
		message = "Brakuje zasobów na %s." % BUILDING_NAMES[building_index]
		return false
	coins -= int(cost["coins"])
	wood -= int(cost["wood"])
	building_levels[building_id] = int(building_levels[building_id]) + 1
	save_progress()
	message = "%s osiąga poziom %d." % [BUILDING_NAMES[building_index], building_levels[building_id]]
	return true

func upgrade_cost(hero_id: String) -> int:
	return 300 + (int(hero_levels[hero_id]) - 1) * 100

func handle_roster_input(position: Vector2) -> void:
	if roster_swap_open:
		handle_roster_swap_input(position)
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
			roster_swap_open = true
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
		save_progress()
		message = "%s osiąga poziom %d." % [hero_name(hero_id), hero_levels[hero_id]]
	else:
		message = "Brakuje %d monet do ulepszenia %s." % [cost - coins, hero_name(hero_id)]
	queue_redraw()

func handle_roster_swap_input(position: Vector2) -> void:
	if is_in_button(position, Rect2(70, 760, 390, 48)):
		roster_swap_open = false
		roster_swap_hero_id = ""
		queue_redraw()
		return
	for index in active_heroes.size():
		var choice_rect := Rect2(52.0 + index * 145.0, 430.0, 125.0, 220.0)
		if is_in_button(position, choice_rect):
			active_heroes[index] = roster_swap_hero_id
			roster_swap_open = false
			message = "%s zastępuje bohatera w składzie." % hero_name(roster_swap_hero_id)
			roster_swap_hero_id = ""
			save_progress()
			queue_redraw()
			return

func handle_skill_tree_input(position: Vector2) -> void:
	if is_in_button(position, skill_tree_back_rect()):
		skill_tree_open = false
		queue_redraw()
		return
	var hero_id := selected_roster_hero_id()
	if is_in_button(position, skill_tree_upgrade_rect()):
		if bool(owned_heroes.get(hero_id, false)):
			var tree: Dictionary = hero_trees.get(hero_id, {})
			if SkillTree.invest(tree, int(hero_levels[hero_id]), skill_tree_selected_branch, skill_tree_selected_tier):
				hero_trees[hero_id] = tree
				if skill_tree_selected_branch == 1 and skill_tree_selected_tier == 2 and active_heroes.has(hero_id) and state == "playing":
					hero_max_health[hero_id] = int(hero_max_health.get(hero_id, 0)) + 3
					hero_health[hero_id] = int(hero_health.get(hero_id, 0)) + 3
					refresh_party_health()
				save_progress()
				play_sfx(790.0, 0.14, 0.15)
		queue_redraw()
		return
	for branch in SkillTree.BRANCHES.size():
		for tier in SkillTree.RANK_CAPS.size():
			if not is_in_button(position, skill_tree_node_rect(branch, tier)):
				continue
			skill_tree_selected_branch = branch
			skill_tree_selected_tier = tier
			queue_redraw()
			return

func handle_village_input(position: Vector2) -> void:
	if is_in_button(position, village_close_rect()):
		village_open = false
		main_menu_open = true
		queue_redraw()
		return
	for index in BUILDING_IDS.size():
		if not is_in_button(position, village_upgrade_rect(index)):
			continue
		var building_id: String = BUILDING_IDS[index]
		try_upgrade_building(building_id)
		queue_redraw()
		return

func handle_map_input(position: Vector2) -> void:
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
		if index + 1 <= unlocked_level:
			map_open = false
			start_level(index)
		else:
			message = "Ukończ poprzedni poziom, aby odblokować tę ścieżkę."
			queue_redraw()
		return

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
		main_menu_open = true
		queue_redraw()
		return
	for index in TRAINING_BATTLES.size():
		if is_in_button(position, training_choice_rect(index)):
			training_battle = TRAINING_BATTLES[index].duplicate(true)
			training_mode = true
			training_open = false
			start_level(level_index, training_battle)
			return

func handle_main_menu_input(position: Vector2) -> void:
	if is_in_button(position, help_button_rect()):
		help_open = true
		reset_confirmation = false
		queue_redraw()
		return
	if is_in_button(position, reset_progress_rect()):
		if reset_confirmation:
			reset_progress()
		else:
			reset_confirmation = true
			queue_redraw()
		return
	# Potwierdzenie resetu dotyczy wyłącznie dwóch kolejnych dotknięć tego
	# samego przycisku. Każda inna akcja lub dotknięcie menu rozbraja reset.
	if reset_confirmation:
		reset_confirmation = false
		queue_redraw()
	if is_in_button(position, daily_reward_rect()):
		claim_daily_reward()
		return
	if is_in_button(position, main_menu_play_rect()):
		main_menu_open = false
		start_level(maxi(0, unlocked_level - 1))
		return
	if is_in_button(position, main_menu_map_rect()):
		main_menu_open = false
		map_page = int(maxi(0, unlocked_level - 1) / 5)
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
		queue_redraw()
		return
	if is_in_button(position, main_menu_booster_rect()):
		main_menu_open = false
		booster_open = true
		queue_redraw()
		return
	if is_in_button(position, main_menu_training_rect()):
		main_menu_open = false
		training_open = true
		queue_redraw()

func handle_help_input(position: Vector2) -> void:
	if is_in_button(position, sound_toggle_rect()):
		sfx_enabled = not sfx_enabled
		if sfx_enabled:
			play_sfx(660.0, 0.10, 0.14)
		save_progress()
		queue_redraw()
		return
	if is_in_button(position, help_close_rect()):
		help_open = false
		queue_redraw()

func reset_progress() -> void:
	# Reset jest świadomie dwuetapowy w UI; po potwierdzeniu nadpisuje lokalny zapis.
	unlocked_level = 1
	coins = 0
	wood = 0
	experience = 0
	perun_sparks = 0
	event_marks = 0
	daily_reward_day = ""
	claimed_boss_sparks.clear()
	level_stars.clear()
	seen_region_intros.clear()
	seen_region_chapters.clear()
	tutorial_completed = false
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
		message = "Dzisiejszy Dar Gaju został już odebrany. Wróć jutro."
		queue_redraw()
		return
	var coin_reward := 180 + mini(820, unlocked_level * 10)
	var wood_reward := 12 + mini(48, int(unlocked_level / 20))
	var experience_reward := 60 + mini(240, unlocked_level * 2)
	coins += coin_reward
	wood += wood_reward
	experience += experience_reward
	daily_reward_day = Time.get_date_string_from_system()
	message = "Dar Gaju: +%d monet, +%d drewna, +%d PD." % [coin_reward, wood_reward, experience_reward]
	save_progress()
	play_sfx(760.0, 0.16, 0.18)
	queue_redraw()

func is_in_button(point: Vector2, rect: Rect2) -> bool:
	return rect.has_point(point)

func handle_action_button(position: Vector2) -> void:
	if state == "won":
		if is_in_button(position, restart_rect()):
			main_menu_open = true
			queue_redraw()
			return
		if is_in_button(position, defeat_training_rect()):
			if training_mode:
				restart_current_battle()
			elif level_index + 1 < levels.size():
				start_level(level_index + 1)
			return
	if is_in_button(position, restart_rect()):
		restart_current_battle()
	elif state == "lost" and not training_mode and is_in_button(position, defeat_training_rect()):
		training_open = true
		queue_redraw()

func draw_button(rect: Rect2, label: String, enabled := true, text_size := 18) -> void:
	if button_oak != null:
		draw_texture_rect(button_oak, rect, false, Color.WHITE if enabled else Color(0.45, 0.45, 0.45, 0.8))
	else:
		var color := Color("#a96e2c") if enabled else Color("#5f5548")
		draw_style_box(make_panel(color, Color("#f3d49b")), rect)
	var label_width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x
	var baseline := rect.position.y + rect.size.y / 2.0 + text_size * 0.36
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
	if stars <= 0:
		return
	var total_width := float(stars) * icon_size
	var first_x := center.x - total_width * 0.5
	for star_index in stars:
		if star_rating_icon != null:
			draw_texture_rect(star_rating_icon, Rect2(first_x + star_index * icon_size, center.y - icon_size * 0.5, icon_size, icon_size), false)
		else:
			draw_string(font, Vector2(first_x + star_index * icon_size, center.y + 7.0), "★", HORIZONTAL_ALIGNMENT_LEFT, -1, int(icon_size), Color("#f5d36f"))

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

func _draw() -> void:
	var screen := get_viewport_rect().size
	if oak_borderland_background != null:
		draw_texture_rect(oak_borderland_background, Rect2(Vector2.ZERO, screen), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, screen), Color("#122b2a"))
	draw_rect(Rect2(Vector2.ZERO, screen), battle_mood_color())
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
	draw_string(font, Vector2(44, 85), "P. %d" % int(level.get("id", level_index + 1)), HORIZONTAL_ALIGNMENT_CENTER, 96, 17, Color("#fff0c7"))
	draw_string(font, Vector2(140, 85), str(level.get("name", "Wyprawa")), HORIZONTAL_ALIGNMENT_CENTER, 250, 17, Color("#fff0c7"))
	draw_string(font, Vector2(458, 84), "Tura: %s" % HERO_NAMES[HERO_IDS.find(current_turn_hero())], HORIZONTAL_ALIGNMENT_CENTER, 70, 11, Color("#d8efac"))
	var active_synergy_count := active_synergy_pairs().size()
	if active_synergy_count > 0:
		draw_string(font, Vector2(390, 111), "SYNERGIA +%d%%" % (active_synergy_count * 8), HORIZONTAL_ALIGNMENT_CENTER, 104, 10, Color("#f4d06d"))
	if enemies.is_empty():
		draw_string(font, Vector2(140, 111), "CEL: %s" % goal_label(), HORIZONTAL_ALIGNMENT_CENTER, 250, 12, Color("#b9e7ca"))
	var turn_banner := "RUCH PRZECIWNIKA" if enemy_attack_anim > 0.0 else ("PRZETRWAJ  •  %d/%d" % [goal_progress, goal_target] if goal_type == "survive" else "TWÓJ RUCH  •  %d" % moves_left)
	var turn_banner_color := Color("#ff9b72") if enemy_attack_anim > 0.0 else Color("#b9e58a")
	if not enemies.is_empty():
		var banner_rect := Rect2(screen.x / 2.0 - 126.0, 288.0, 252.0, 38.0)
		if turn_banner_oak != null:
			draw_texture_rect(turn_banner_oak, banner_rect.grow(10.0), false)
		else:
			draw_style_box(make_panel(Color("#102a22f2"), Color("#d9b45d")), banner_rect)
		draw_string(font, Vector2(banner_rect.position.x, banner_rect.position.y + 25), turn_banner, HORIZONTAL_ALIGNMENT_CENTER, banner_rect.size.x, 16, turn_banner_color)
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
			var health_y := card.position.y + 142.0
			var portrait := boss_portrait_for(str(enemy.get("name", "")))
			var portrait_window := Rect2(card.position.x + (card.size.x - 138.0) / 2.0, card.position.y + 3.0, 138.0, 138.0)
			draw_rect(portrait_window.grow(-8.0), Color("#071d17"))
			if is_target and enemy_square_card_frame != null:
				draw_texture_rect(enemy_square_card_frame, portrait_window, false, Color(1.0, 0.9, 0.58, 1.0) if alive else Color(0.45, 0.5, 0.46, 0.8))
			elif portrait_backdrop_oak != null:
				draw_texture_rect(portrait_backdrop_oak, portrait_window, false, Color(0.62, 0.84, 0.65, 0.9) if alive else Color(0.45, 0.5, 0.46, 0.8))
			if portrait != null:
				var portrait_size := 110.0 + (sin(ui_anim_time * 4.0) * 2.5 if is_target else 0.0)
				var attack_bob := sin((6.5 - enemy_attack_anim) * 5.0) * 7.0 if enemy_attack_anim > 0.0 else 0.0
				var portrait_y := portrait_window.get_center().y - portrait_size / 2.0 + attack_bob
				draw_texture_rect(portrait, Rect2(card.position.x + (card.size.x - portrait_size) / 2.0, portrait_y, portrait_size, portrait_size), false)
			if portrait == null:
				draw_circle(portrait_window.get_center(), 28, Color("#5b356e") if alive else Color("#424843"))
			var role_rect := Rect2(card.position.x + 12, card.position.y + 102, card.size.x - 24, 19)
			var role_color := enemy_role_color(enemy)
			draw_style_box(make_panel(Color(role_color, 0.88), Color("#fff0c7") if is_target else role_color.lightened(0.25)), role_rect)
			var role_name := enemy_role_label(enemy)
			var role_text_width := font.get_string_size(role_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
			var role_content_width := role_text_width + 22.0
			var role_x := role_rect.get_center().x - role_content_width * 0.5
			draw_enemy_role_icon(Vector2(role_x + 8.0, role_rect.get_center().y), str(enemy.get("role", "attacker")), role_color)
			draw_string(font, Vector2(role_x + 18.0, role_rect.position.y + 13), role_name, HORIZONTAL_ALIGNMENT_LEFT, role_text_width + 2.0, 9, Color("#fff8df"))
			if bool(enemy.get("enraged", false)):
				draw_string(font, Vector2(card.position.x, role_rect.position.y - 5.0), "SZAŁ", HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 10, Color("#ffbf69"))
			if alive and str(enemy.get("role", "attacker")) != "defender" and has_living_defender():
				draw_string(font, Vector2(card.position.x, card.position.y + 31), "OSŁONA OBROŃCY", HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 9, Color("#b8d9ed"))
			if enemy_damage_popup_time > 0.0 and enemy_damage_popup_index == enemy_index:
				var hit_alpha := enemy_damage_popup_time / 0.9
				draw_string(font, Vector2(card.position.x, card.position.y - 10.0 - (0.9 - enemy_damage_popup_time) * 28.0), "-%d" % enemy_damage_popup_value, HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 22, Color(1.0, 0.82, 0.32, hit_alpha))
			var info_y := card.position.y + 140.0
			draw_string(font, Vector2(card.position.x, info_y), str(enemy.get("name", "Wróg")), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 11, enemy_color)
			var bar_rect := Rect2(card.position.x + 12, health_y + 2, card.size.x - 24, 58)
			if healthbar_fill != null:
				draw_texture_rect(healthbar_fill, Rect2(bar_rect.position + Vector2(3, 4), Vector2((bar_rect.size.x - 6) * enemy_ratio, bar_rect.size.y - 8)), false)
			if healthbar_frame != null:
				draw_texture_rect(healthbar_frame, bar_rect, false)
			else:
				draw_style_box(make_panel(Color("#2a2524dd"), Color("#8e6b45")), bar_rect)
			draw_string(font, Vector2(bar_rect.position.x, health_y + 36.0), "%d/%d" % [enemy_health_value, enemy_max_health_value], HORIZONTAL_ALIGNMENT_CENTER, bar_rect.size.x, 13, Color("#fff8df"))
	var rect := board_rect()
	if battle_board_roots != null:
		draw_texture_rect(battle_board_roots, Rect2(rect.position + Vector2(-25.0, -25.0), rect.size + Vector2(50.0, 50.0)), false)
	elif board_roots_frame != null:
		var frame_rect := Rect2(rect.position + Vector2(-32.0, -72.0), rect.size + Vector2(64.0, 144.0))
		draw_texture_rect(board_roots_frame, frame_rect, false)
	var cell := rect.size.x / BOARD_SIZE
	for row in BOARD_SIZE:
		for col in BOARD_SIZE:
			var tile_cell := Vector2i(col, row)
			var offset_cells: Vector2 = tile_offsets.get(tile_cell, Vector2.ZERO)
			var tile_rect := Rect2(rect.position + Vector2(col * cell + 3, row * cell + 3) + offset_cells * cell, Vector2(cell - 6, cell - 6))
			var checker_color := Color("#102925") if (row + col) % 2 == 0 else Color("#0a211f")
			draw_rect(tile_rect.grow(1.5), checker_color)
			draw_rect(tile_rect.grow(1.5), Color("#2e5c51"), false, 1.0)
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
			if tile_icon != null:
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
			if removal_effects.has(tile_cell):
				var effect_progress: float = float(removal_effects[tile_cell]) / 0.34
				var effect_center := tile_rect.get_center()
				draw_circle(effect_center, cell * (0.16 + effect_progress * 0.32), Color(1.0, 0.86, 0.35, 1.0 - effect_progress), false, 3.0)
				for spark in 6:
					var angle := float(spark) * TAU / 6.0
					var spark_pos := effect_center + Vector2(cos(angle), sin(angle)) * cell * (0.12 + effect_progress * 0.28)
					draw_circle(spark_pos, 2.5 * (1.0 - effect_progress), Color(1.0, 0.95, 0.65, 1.0 - effect_progress))
	if not hinted_cells.is_empty():
		var hint_alpha := 0.45 + sin(ui_anim_time * 5.0) * 0.25
		for hint_cell in hinted_cells:
			var hint_center := rect.position + Vector2((hint_cell.x + 0.5) * cell, (hint_cell.y + 0.5) * cell)
			draw_circle(hint_center, cell * 0.43, Color(0.96, 0.78, 0.28, hint_alpha), false, 3.0)

	for effect_cell in removal_effects:
		var effect_progress: float = clampf(float(removal_effects[effect_cell]) / 0.34, 0.0, 1.0)
		var effect_center := rect.position + Vector2((effect_cell.x + 0.5) * cell, (effect_cell.y + 0.5) * cell)
		if not tile_remove_frames.is_empty():
			var frame_index := mini(tile_remove_frames.size() - 1, int(effect_progress * tile_remove_frames.size()))
			draw_texture_rect(tile_remove_frames[frame_index], Rect2(effect_center - Vector2(cell * 0.55, cell * 0.55), Vector2(cell * 1.1, cell * 1.1)), false)
		elif tile_remove_burst != null:
			draw_texture_rect(tile_remove_burst, Rect2(effect_center - Vector2(cell * 0.55, cell * 0.55), Vector2(cell * 1.1, cell * 1.1)), false, Color(1, 1, 1, 1.0 - effect_progress))
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
	elif enemy_attack_anim > 0.0 and enemy_action_phase == 0:
		var thought_alpha := 0.28 + sin(ui_anim_time * 4.0) * 0.10
		draw_rect(rect, Color(0.10, 0.07, 0.18, thought_alpha))
		draw_string(font, Vector2(rect.position.x, rect.get_center().y - 12), "WRÓG ROZWAŻA RUCH...", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 20, Color("#e7c47a"))
		draw_string(font, Vector2(rect.position.x, rect.get_center().y + 14), "Przegląda możliwe zamiany znaków", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Color("#dfd2ad"))
	if board_shuffle_time > 0.0:
		var alpha := minf(0.72, board_shuffle_time * 0.65)
		draw_rect(rect, Color(0.06, 0.24, 0.18, alpha))
		draw_string(font, Vector2(rect.position.x, rect.get_center().y - 8), "PRZETASOWANIE GAJU", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 22, Color("#ffe19a"))
		draw_string(font, Vector2(rect.position.x, rect.get_center().y + 17), "Powstaje nowa ścieżka kombinacji", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 13, Color("#e3efc9"))
	# Wybrany cel jest podświetlany przy postaci; nie powielamy go tekstem nad bohaterami.
	if not message.begins_with("Cel:"):
		draw_string(font, Vector2(28, 755), message, HORIZONTAL_ALIGNMENT_CENTER, screen.x - 56, 13, Color("#d9e4bd"))
	# Rozbudowana podstawa korzeni jest tłem dla bohatera i boosterów.
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
		draw_string(font, Vector2(battle_card.position.x + 90, battle_card.position.y + 15), HERO_NAMES[HERO_IDS.find(hero_id)], HORIZONTAL_ALIGNMENT_LEFT, 86, 13, Color("#fff0c7"))
		if hero_portraits.has(hero_id) and hero_portraits[hero_id] != null:
			var hero_portrait_size := 72.0 + (sin(ui_anim_time * 4.0) * 2.0 if current_turn_hero() == hero_id else 0.0)
			var hero_portrait_position := battle_card.position + Vector2(30, 31) - Vector2(hero_portrait_size, hero_portrait_size) / 2.0
			draw_texture_rect(hero_portraits[hero_id], texture_aspect_fit_rect(hero_portraits[hero_id], Rect2(hero_portrait_position, Vector2(hero_portrait_size, hero_portrait_size))), false)
		if active_heroes.has(hero_id):
			draw_string(font, Vector2(battle_card.position.x + 90, battle_card.position.y + 34), "%d/%d" % [hero_health[hero_id], hero_max_health[hero_id]], HORIZONTAL_ALIGNMENT_LEFT, 82, 11, Color("#fff0c7"))
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
	for booster_data in [[hammer_rect(), booster_hammer_icon, "Młot", hammer_count], [bolt_booster_rect(), booster_bolt_icon, "Grom", bolt_count], [gale_booster_rect(), booster_gale_icon, "Wiatr", gale_count]]:
		var booster_rect: Rect2 = booster_data[0]
		var booster_icon: Texture2D = booster_data[1]
		var booster_count_value: int = booster_data[3]
		if booster_icon != null:
			draw_texture_rect(booster_icon, Rect2(booster_rect.position, Vector2(booster_rect.size.y, booster_rect.size.y)), false, Color.WHITE if booster_count_value > 0 else Color(0.35, 0.35, 0.35, 0.7))
		var count_center := booster_rect.position + Vector2(79.0, 25.0)
		if booster_count_medallion != null:
			draw_texture_rect(booster_count_medallion, Rect2(count_center - Vector2(27.0, 27.0), Vector2(54.0, 54.0)), false)
		else:
			draw_circle(count_center, 27.0, Color("#193126e8"))
		draw_string(font, Vector2(count_center.x - 27.0, count_center.y + 7.0), "%d" % booster_count_value, HORIZONTAL_ALIGNMENT_CENTER, 54.0, 20, Color("#fff4d4"))
	if held_tooltip != "":
		var tooltip_rect := Rect2(28, 836, screen.x - 56, 34)
		draw_style_box(make_panel(Color("#193d38f2"), Color("#f0d57a")), tooltip_rect)
		draw_string(font, Vector2(tooltip_rect.position.x + 8, tooltip_rect.position.y + 22), held_tooltip, HORIZONTAL_ALIGNMENT_CENTER, tooltip_rect.size.x - 16, 12, Color("#fff0c7"))
	if state != "playing":
		# Modal przejmuje uwagę — przygaszamy całą bitwę pod nim.
		draw_rect(Rect2(Vector2.ZERO, screen), Color(0.035, 0.055, 0.05, 0.66))
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
				resource_amount_width(int(last_reward.get("experience", 0)), 32.0, 18)
			]
			var rewards_total := float(reward_widths[0] + reward_widths[1] + reward_widths[2]) + 28.0
			var reward_x := overlay.get_center().x - rewards_total * 0.5
			reward_x += draw_resource_amount(Vector2(reward_x, reward_y), "coins", int(last_reward.get("coins", 0)), 32.0, 18, Color("#c6dcba")) + 14.0
			reward_x += draw_resource_amount(Vector2(reward_x, reward_y), "wood", int(last_reward.get("wood", 0)), 32.0, 18, Color("#c6dcba")) + 14.0
			draw_resource_amount(Vector2(reward_x, reward_y), "experience", int(last_reward.get("experience", 0)), 32.0, 18, Color("#c6dcba"))
			if int(last_reward.get("sparks", 0)) > 0:
				draw_resource_amount(Vector2(overlay.position.x + overlay.size.x - 86.0, title_y + 72.0), "sparks", int(last_reward.get("sparks", 0)), 24.0, 14, Color("#ffe39a"))
			draw_star_rating(Vector2(overlay.get_center().x, title_y + 86.0), last_stars, 42.0)
		else:
			draw_string(font, Vector2(overlay.position.x, title_y + 46.0), "Drużyna potrzebuje chwili, by odzyskać siły.", HORIZONTAL_ALIGNMENT_CENTER, overlay.size.x, 14, Color("#c6dcba"))
		if state == "won":
			draw_button(restart_rect(), "WRÓĆ DO MENU", true, 16)
			var can_continue := training_mode or level_index + 1 < levels.size()
			draw_button(defeat_training_rect(), "POWTÓRZ TRENING" if training_mode else ("NASTĘPNY POZIOM" if can_continue else "KAMPANIA UKOŃCZONA"), can_continue, 15)
		else:
			draw_button(restart_rect(), "SPRÓBUJ PONOWNIE", true, 16)
			if not training_mode:
				draw_button(defeat_training_rect(), "TRENUJ BOHATERÓW  •  ZDOBYWAJ PD", true, 13)
	if roster_open:
		draw_roster_overlay(screen)
		if skill_tree_open:
			draw_skill_tree_overlay(screen)
	if village_open:
		draw_village_overlay(screen)
	if map_open:
		draw_map_overlay(screen)
	if booster_open:
		draw_booster_overlay(screen)
	if training_open:
		draw_training_overlay(screen)
	if main_menu_open:
		draw_main_menu(screen)
	if help_open:
		draw_help_overlay(screen)
	if region_intro_open:
		draw_rect(Rect2(Vector2.ZERO, screen), Color("#061511d9"))
		var intro_panel := Rect2(26, 318, screen.x - 52, 310)
		if defeat_modal_oak != null:
			draw_texture_rect(defeat_modal_oak, intro_panel, false)
		else:
			draw_style_box(make_panel(Color("#183b39f4"), Color("#f0c96e")), intro_panel)
		var intro: Array = active_region_intro if not active_region_intro.is_empty() else ["NOWA KRAINA", "Droga prowadzi dalej."]
		draw_string(font, Vector2(intro_panel.position.x + 22, 448), str(intro[0]), HORIZONTAL_ALIGNMENT_CENTER, intro_panel.size.x - 44, 24, Color("#ffe7a3"))
		draw_string(font, Vector2(intro_panel.position.x + 38, 500), str(intro[1]), HORIZONTAL_ALIGNMENT_CENTER, intro_panel.size.x - 76, 17, Color("#dce9c8"))
		draw_string(font, Vector2(intro_panel.position.x, 574), "DOTKNIJ, ABY WYRUSZYĆ", HORIZONTAL_ALIGNMENT_CENTER, intro_panel.size.x, 14, Color("#f5d36f"))
	if not main_menu_open and not roster_open and not village_open and not map_open and not booster_open and not training_open and not region_intro_open:
		if pause_button_oak != null:
			draw_texture_rect(pause_button_oak, pause_rect(), false)
		else:
			draw_button(pause_rect(), "II", true, 14)

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
	draw_game_logo(Vector2(screen.x / 2.0, 72), Vector2(205, 110))
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
	var portrait_rect := Rect2(24, 300, 246, 402)
	if hero_portraits.has(hero_id) and hero_portraits[hero_id] != null:
		draw_texture_rect(hero_portraits[hero_id], texture_aspect_fit_rect(hero_portraits[hero_id], portrait_rect), false, Color.WHITE if owned else Color(0.58, 0.62, 0.58, 1.0))
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
	draw_roster_action_button(roster_skill_tree_rect(), "TALENTY  •  %d" % tree_points, true)
	draw_string(font, Vector2(info_x, 576), "WSPÓŁPRACA", HORIZONTAL_ALIGNMENT_LEFT, 190, 16, Color("#f4d06d"))
	var partners := synergy_portrait_ids(hero_id)
	var portrait_size := 54.0
	var portrait_gap := 26.0
	var portraits_width := partners.size() * portrait_size + maxi(0, partners.size() - 1) * portrait_gap
	var portraits_x := info_x + (200.0 - portraits_width) * 0.5
	for partner_index in partners.size():
		var partner_id: String = partners[partner_index]
		var thumb := Rect2(portraits_x + partner_index * (portrait_size + portrait_gap), 582.0, portrait_size, portrait_size)
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
	draw_roster_action_button(roster_close_rect(), "← WRÓĆ", true)
	if roster_swap_open:
		draw_roster_swap_popup(screen)

func draw_roster_swap_popup(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.01, 0.04, 0.03, 0.78))
	var panel := Rect2(24.0, 320.0, screen.x - 48.0, 470.0)
	draw_style_box(make_panel(Color("#17352f"), Color("#d9b25c")), panel)
	draw_string(font, Vector2(panel.position.x, 370), "SKŁAD JEST PEŁNY", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 22, Color("#ffe5a4"))
	draw_string(font, Vector2(panel.position.x + 20, 402), "Wybierz bohatera do wymiany:", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 40, 15, Color("#d3ead2"))
	for index in active_heroes.size():
		var hero_id: String = active_heroes[index]
		var choice_rect := Rect2(52.0 + index * 145.0, 430.0, 125.0, 220.0)
		draw_style_box(make_panel(Color("#0d241f"), Color("#ba934b")), choice_rect)
		var portrait: Texture2D = hero_portraits.get(hero_id, null)
		if portrait != null:
			draw_texture_rect(portrait, texture_aspect_fit_rect(portrait, Rect2(choice_rect.position + Vector2(8, 8), Vector2(109, 145))), false)
		draw_string(font, Vector2(choice_rect.position.x, 604), hero_name(hero_id), HORIZONTAL_ALIGNMENT_CENTER, choice_rect.size.x, 13, Color("#fff0c7"))
		draw_string(font, Vector2(choice_rect.position.x, 628), "WYMIEŃ", HORIZONTAL_ALIGNMENT_CENTER, choice_rect.size.x, 12, Color("#e8c56e"))
	draw_roster_action_button(Rect2(70, 760, 390, 48), "ANULUJ", true)

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
		draw_string(font, Vector2(branch_x, 184), SkillTree.branch_name(hero_id, branch).to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 156.0, 12, Color("#f0cb76"))
		for tier in SkillTree.RANK_CAPS.size():
			var card := skill_tree_node_rect(branch, tier)
			var rank := SkillTree.ranks(tree, branch, tier)
			var can_buy := owned and SkillTree.can_invest(tree, level, branch, tier)
			var selected := skill_tree_selected_branch == branch and skill_tree_selected_tier == tier
			var unlocked := rank > 0 or can_buy
			if tier > 0:
				var previous := skill_tree_node_rect(branch, tier - 1)
				var connector_color := Color("#d5af62") if SkillTree.ranks(tree, branch, tier - 1) == SkillTree.RANK_CAPS[tier - 1] else Color("#536253")
				var connector_top := Vector2(card.get_center().x, previous.end.y + 4.0)
				var connector_bottom := Vector2(card.get_center().x, card.position.y - 8.0)
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
			draw_skill_node_icon(card.position + Vector2(card.size.x * 0.5, 35), hero_id, branch, tier, unlocked, rank)
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
	draw_string(font, Vector2(24, 848), blocker, HORIZONTAL_ALIGNMENT_CENTER, screen.x - 48, 12, Color("#3f714e") if can_buy else Color("#7c3d2f"))
	draw_roster_action_button(skill_tree_upgrade_rect(), "ODBLOKUJ  •  1 PUNKT" if selected_rank == 0 else "ULEPSZ  •  1 PUNKT", can_buy)
	var back_rect := skill_tree_back_rect()
	draw_roster_action_button(back_rect, "", true)
	var back_label_size := 14
	var back_label := "BOHATER"
	var back_text_width := font.get_string_size(back_label, HORIZONTAL_ALIGNMENT_LEFT, -1, back_label_size).x
	var back_content_width := back_text_width + 32.0 + 8.0
	var back_content_x := back_rect.get_center().x - back_content_width * 0.5
	if skill_back_arrow != null:
		draw_texture_rect(skill_back_arrow, Rect2(back_content_x, back_rect.get_center().y - 12.0, 24.0, 24.0), false, Color.WHITE)
	draw_string(font, Vector2(back_content_x + 36.0, back_rect.get_center().y + 5.0), back_label, HORIZONTAL_ALIGNMENT_LEFT, back_text_width + 4.0, back_label_size, Color("#fff1bd"))

func draw_roster_action_button(rect: Rect2, label: String, enabled: bool) -> void:
	if roster_action_button != null:
		draw_texture_rect(roster_action_button, rect, false, Color.WHITE if enabled else Color(0.35, 0.4, 0.38, 0.9))
	else:
		draw_button(rect, label, enabled, 16)
		return
	var label_size := 17 if rect.size.y >= 70.0 else 14
	var label_y := rect.position.y + rect.size.y * 0.5 + label_size * 0.35
	draw_string(font, Vector2(rect.position.x, label_y), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, label_size, Color("#fff1bd") if enabled else Color("#a7a99d"))

func draw_village_overlay(screen: Vector2) -> void:
	if village_background != null:
		draw_texture_rect(village_background, Rect2(Vector2.ZERO, screen), false)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#0b1b1ab8"))
	draw_game_logo(Vector2(screen.x / 2.0, 66), Vector2(195, 100))
	var panel_rect := Rect2(28, 142, screen.x - 56, 600)
	draw_style_box(make_panel(Color("#193d38"), Color("#e1bd6a")), panel_rect)
	draw_string(font, Vector2(panel_rect.position.x, 184), "OSADA DĘBOWEGO POGRANICZA", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 20, Color("#f5d998"))
	for index in BUILDING_IDS.size():
		var building_id: String = BUILDING_IDS[index]
		var card := Rect2(50, 200 + index * 70, screen.x - 100, 58)
		var cost: Dictionary = building_cost(building_id)
		var bonus: String = ["+5 maks. zdrowia", "+5 obrażeń Bruna", "+1 leczenia Miety", "+1 tarczy z liści", "+10 monet za wygraną", "+5 obrażeń Ledy"][index]
		draw_style_box(make_panel(Color("#285149"), Color("#719a78")), card)
		var text_x := 66.0
		var building_illustration: Texture2D = null
		if building_id == "domostwa":
			building_illustration = domostwa_illustration
		elif building_id == "kuznia":
			building_illustration = kuznia_illustration
		elif building_id == "chata_zielarki":
			building_illustration = chata_zielarki_illustration
		elif building_id == "swiety_gaj":
			building_illustration = swiety_gaj_illustration
		elif building_id == "spichlerz":
			building_illustration = spichlerz_illustration
		elif building_id == "wieza_peruna":
			building_illustration = wieza_peruna_illustration
		if building_illustration != null:
			draw_texture_rect(building_illustration, Rect2(56, card.position.y + 6, 44, 46), false)
			text_x = 108.0
		draw_string(font, Vector2(text_x, card.position.y + 25), "%s  •  poz. %d" % [BUILDING_NAMES[index], building_levels[building_id]], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#fff0c7"))
		draw_string(font, Vector2(text_x, card.position.y + 47), bonus, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c7ddba"))
		var upgrade_rect := village_upgrade_rect(index)
		var max_level := int(building_levels[building_id]) >= MAX_BUILDING_LEVEL
		if max_level:
			draw_button(upgrade_rect, "MAKS. POZIOM", false, 10)
		else:
			draw_button(upgrade_rect, "", coins >= int(cost["coins"]) and wood >= int(cost["wood"]), 11)
			var cost_x := upgrade_rect.position.x + 12.0
			cost_x += draw_resource_amount(Vector2(cost_x, upgrade_rect.position.y + 6.0), "coins", int(cost["coins"]), 17.0, 10) + 5.0
			draw_resource_amount(Vector2(cost_x, upgrade_rect.position.y + 6.0), "wood", int(cost["wood"]), 17.0, 10)
	draw_string(font, Vector2(panel_rect.position.x, 666), "Koszt ulepszenia", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 12, Color("#c7ddba"))
	draw_button(village_close_rect(), "Wróć do menu", true, 14)

func draw_map_overlay(screen: Vector2) -> void:
	if oak_borderland_background != null:
		draw_texture_rect(oak_borderland_background, Rect2(Vector2.ZERO, screen), false)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#071916b8"))
	draw_style_box(make_panel(Color("#24322be8"), Color("#b8904c")), Rect2(18, 18, screen.x - 36, 60))
	draw_string(font, Vector2(0, 56), "MAPA ŚWIATA", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 25, Color("#f4d69a"))
	draw_string(font, Vector2(0, 92), "Odkrywaj krainy Dębowego Pogranicza", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 14, Color("#d9e4bd"))
	map_page = int(maxi(0, unlocked_level - 1) / 5)
	draw_string(font, Vector2(0, 135), "AKTUALNY SZLAK  •  POZIOM %d" % unlocked_level, HORIZONTAL_ALIGNMENT_CENTER, screen.x, 13, Color("#e5ebca"))
	var path_points := [Vector2(270, 242), Vector2(145, 355), Vector2(350, 470), Vector2(170, 585), Vector2(290, 700)]
	for index in range(path_points.size() - 1):
		draw_line(path_points[index], path_points[index + 1], Color("#3a2418"), 12.0, true)
		draw_line(path_points[index], path_points[index + 1], Color("#b38b48"), 5.0, true)
	for slot in 5:
		var index := map_page * 5 + slot
		if index >= levels.size() or index + 1 > unlocked_level:
			continue
		var unlocked := index + 1 <= unlocked_level
		var active := index == level_index
		var color := Color("#a96e2c") if unlocked else Color("#4b5047")
		var border := Color("#fff0a3") if active else Color("#bd9a58")
		var node_rect := map_level_rect(slot)
		draw_circle(node_rect.get_center(), 48, Color("#142923d9") if unlocked else Color("#101513e8"))
		draw_style_box(make_panel(color, border), node_rect)
		var level: Dictionary = levels[index]
		if slot == 0 and index > 0 and str(level.get("region", "")) != str(levels[index - 1].get("region", "")):
			if map_region_gate != null:
				draw_texture_rect(map_region_gate, Rect2(node_rect.get_center() - Vector2(34, 58), Vector2(68, 92)), false)
			draw_string(font, Vector2(node_rect.position.x - 68, node_rect.position.y - 52), "BRAMA: %s" % region_display_name(str(level.get("region", ""))), HORIZONTAL_ALIGNMENT_CENTER, node_rect.size.x + 136, 12, Color("#f5d36f"))
		draw_string(font, Vector2(node_rect.position.x, node_rect.position.y + 23), str(level.id), HORIZONTAL_ALIGNMENT_CENTER, node_rect.size.x, 19, Color.WHITE)
		var label: String = level.name if unlocked else "Zamknięte"
		draw_string(font, Vector2(node_rect.position.x - 72, node_rect.position.y - 28), region_display_name(str(level.get("region", ""))), HORIZONTAL_ALIGNMENT_CENTER, node_rect.size.x + 144, 14, Color("#fff0c7") if unlocked else Color("#889087"))
		draw_string(font, Vector2(node_rect.position.x - 56, node_rect.position.y + 72), label, HORIZONTAL_ALIGNMENT_CENTER, node_rect.size.x + 112, 12, Color("#e5ebca") if unlocked else Color("#889087"))
		if unlocked:
			var difficulty := level_difficulty_label(int(level.get("id", 1)))
			draw_string(font, Vector2(node_rect.position.x, node_rect.position.y + 45), difficulty, HORIZONTAL_ALIGNMENT_CENTER, node_rect.size.x, 9, level_difficulty_color(int(level.get("id", 1))))
		var stars := int(level_stars.get(int(level.id), 0))
		if stars > 0:
			draw_star_rating(Vector2(map_level_rect(slot).get_center().x, map_level_rect(slot).position.y + 88), stars, 18.0)
		var kind_label := level_kind_label(level)
		draw_string(font, Vector2(node_rect.position.x - 70, node_rect.position.y - 48), kind_label, HORIZONTAL_ALIGNMENT_CENTER, node_rect.size.x + 140, 11, level_kind_color(level) if unlocked else Color("#889087"))
	draw_button(map_close_rect(), "Wróć do menu", true, 14)

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

func draw_main_menu(screen: Vector2) -> void:
	if village_background != null:
		draw_texture_rect(village_background, Rect2(Vector2.ZERO, screen), false)
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#07191699"))
	draw_style_box(make_panel(Color("#19332de8"), Color("#cda154")), Rect2(18, 18, screen.x - 36, 64))
	draw_circle(Vector2(51, 50), 22, Color("#7a4d2c"))
	draw_string(font, Vector2(80, 45), "Strażnik Gaju", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#fff0c7"))
	draw_string(font, Vector2(80, 67), "Poziom %d  •  Drużyna %d/%d" % [unlocked_level, party_health, party_max_health], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c7ddba"))
	var wallet_x := screen.x - 184.0
	wallet_x += draw_resource_amount(Vector2(wallet_x, 28), "coins", coins, 18.0, 13, Color("#f4d69a")) + 10.0
	draw_resource_amount(Vector2(wallet_x, 28), "wood", wood, 18.0, 13, Color("#c7ddba"))
	wallet_x = screen.x - 184.0
	wallet_x += draw_resource_amount(Vector2(wallet_x, 52), "experience", experience, 18.0, 13, Color("#8fe8df")) + 10.0
	draw_resource_amount(Vector2(wallet_x, 52), "sparks", perun_sparks, 18.0, 13, Color("#f6d779"))
	draw_button(help_button_rect(), "?", true, 14)
	draw_button(reset_progress_rect(), "POTWIERDŹ" if reset_confirmation else "RESET", true, 9)
	draw_game_logo(Vector2(screen.x / 2.0, 230), Vector2(350, 250))
	draw_string(font, Vector2(0, 370), "Dębowe Pogranicze czeka na swój szept.", HORIZONTAL_ALIGNMENT_CENTER, screen.x, 15, Color("#e3dfbd"))
	var can_claim_daily := daily_reward_available()
	draw_button(daily_reward_rect(), "ODBIERZ DZIENNY DAR GAJU" if can_claim_daily else "DAR GAJU ODEBRANY • WRÓĆ JUTRO", can_claim_daily, 13)
	draw_button(main_menu_play_rect(), "GRAJ  •  dalsza wyprawa", true, 20)
	draw_button(main_menu_map_rect(), "MAPA WYPRAW", true, 15)
	draw_button(main_menu_roster_rect(), "DRUŻYNA I BOHATEROWIE", true, 15)
	draw_button(main_menu_village_rect(), "OSADA DĘBOWEGO POGRANICZA", true, 14)
	draw_button(main_menu_booster_rect(), "BOOSTERY I ZAPASY", true, 14)
	draw_button(main_menu_training_rect(), "TRENING BOHATERÓW  •  PD", true, 14)
	draw_string(font, Vector2(0, 928), "Odblokowany poziom: %d / %d  •  Trening jest zawsze dostępny" % [unlocked_level, levels.size()], HORIZONTAL_ALIGNMENT_CENTER, screen.x, 12, Color("#c7ddba"))

func draw_help_overlay(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#061511e8"))
	var panel := Rect2(28, 108, screen.x - 56, 706)
	if defeat_modal_oak != null:
		draw_texture_rect(defeat_modal_oak, panel, false, Color(0.95, 1.0, 0.96, 1.0))
	else:
		draw_style_box(make_panel(Color("#193d38"), Color("#e1bd6a")), panel)
	draw_string(font, Vector2(panel.position.x, 164), "JAK GRAĆ", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 25, Color("#ffe6a4"))
	var guide := [
		["1. ŁĄCZ ZNAKI", "Przeciągnij kafelek na sąsiednie pole albo wybierz dwa sąsiednie kafelki. Ruch liczy się tylko, jeśli tworzy co najmniej trzy takie same znaki."],
		["2. WYKORZYSTAJ ŻYWIOŁY", "Ogień i runy ranią wrogów, woda leczy aktywnego bohatera, a liście budują tarczę drużyny."],
		["3. WYBIERAJ CELE", "Naciśnij kartę wroga, aby go wybrać. Najpierw usuń obrońców — osłaniają pozostałych przeciwników."],
		["4. ŁADUJ UMIEJĘTNOŚCI", "Kombinacje liści, ognia i wody ładują zdolności Lady, Bruna oraz Miety. Boostery nie zużywają ruchu."],
		["5. ROZWIJAJ DRUŻYNĘ", "Nagrody wydaj w osadzie i na bohaterów. Gdy kampania jest za trudna, trening daje PD bez ryzyka utraty postępu."]
	]
	for index in guide.size():
		var item: Array = guide[index]
		var y := 210.0 + index * 98.0
		draw_circle(Vector2(panel.position.x + 42, y - 7), 17, Color("#a8782e"))
		draw_string(font, Vector2(panel.position.x + 70, y), str(item[0]), HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 98, 16, Color("#fff0c7"))
		draw_multiline_string(font, Vector2(panel.position.x + 70, y + 15), str(item[1]), HORIZONTAL_ALIGNMENT_LEFT, panel.size.x - 105, 13, 20, Color("#cfe1c2"))
	draw_button(sound_toggle_rect(), "DŹWIĘKI: WŁĄCZONE" if sfx_enabled else "DŹWIĘKI: WYŁĄCZONE", true, 14)
	draw_button(help_close_rect(), "ROZUMIEM", true, 16)

func draw_training_overlay(screen: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, screen), Color("#0b1b1ae8"))
	draw_game_logo(Vector2(screen.x / 2.0, 82), Vector2(200, 120))
	var panel_rect := Rect2(28, 142, screen.x - 56, 660)
	draw_style_box(make_panel(Color("#193d38"), Color("#e1bd6a")), panel_rect)
	draw_string(font, Vector2(panel_rect.position.x, 184), "KRĄG TRENINGOWY", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 22, Color("#f5d998"))
	draw_string(font, Vector2(panel_rect.position.x + 24, 208), "Ćwicz bez energii i bez ryzyka utraty postępu.", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x - 48, 13, Color("#c7ddba"))
	for index in TRAINING_BATTLES.size():
		var training: Dictionary = TRAINING_BATTLES[index]
		var card := training_choice_rect(index)
		var enemy: Dictionary = training["enemies"][0]
		draw_style_box(make_panel(Color("#285149"), Color("#719a78")), card)
		draw_string(font, Vector2(card.position.x + 16, card.position.y + 29), str(training["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#fff0c7"))
		draw_string(font, Vector2(card.position.x + 16, card.position.y + 54), "Wróg: %s  •  %d zdrowia  •  atak %d" % [str(enemy["name"]), int(enemy["health"]), int(enemy["attack"])], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c7ddba"))
		var reward: Dictionary = training["rewards"]
		draw_string(font, Vector2(card.position.x + 16, card.position.y + 79), "Nagroda", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f5d998"))
		var training_reward_x := card.position.x + 72.0
		training_reward_x += draw_resource_amount(Vector2(training_reward_x, card.position.y + 62), "experience", int(reward["experience"]), 18.0, 11, Color("#f5d998")) + 12.0
		draw_resource_amount(Vector2(training_reward_x, card.position.y + 62), "coins", int(reward["coins"]), 18.0, 11, Color("#f5d998"))
		draw_button(Rect2(card.position.x + card.size.x - 112, card.position.y + 82, 96, 26), "WALCZ", true, 11)
	draw_button(training_close_rect(), "Wróć do menu", true, 14)

func load_progress() -> void:
	var data := ConfigFile.new()
	if data.load("user://progress.cfg") == OK:
		unlocked_level = clampi(int(data.get_value("progress", "unlocked_level", 1)), 1, levels.size())
		coins = int(data.get_value("wallet", "coins", 0))
		wood = int(data.get_value("wallet", "wood", 0))
		experience = int(data.get_value("wallet", "experience", 0))
		perun_sparks = int(data.get_value("wallet", "perun_sparks", 0))
		event_marks = int(data.get_value("wallet", "event_marks", 0))
		daily_reward_day = str(data.get_value("progress", "daily_reward_day", ""))
		sfx_enabled = bool(data.get_value("settings", "sfx_enabled", true))
		for level in levels:
			var boss_level_id := int(level.get("id", 0))
			claimed_boss_sparks[boss_level_id] = bool(data.get_value("bosses", "spark_%d" % boss_level_id, false))
		tutorial_completed = bool(data.get_value("progress", "tutorial_completed", false))
		for intro_level_id in REGION_INTROS:
			seen_region_intros[intro_level_id] = bool(data.get_value("region_intros", "level_%d" % int(intro_level_id), false))
		for chapter_id in REGION_CHAPTERS:
			seen_region_chapters[chapter_id] = bool(data.get_value("region_intros", "chapter_%s" % chapter_id, false))
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
		for building_id in BUILDING_IDS:
			building_levels[building_id] = maxi(0, int(data.get_value("village", "%s_level" % building_id, 0)))
		for level in levels:
			var level_id := int(level.get("id", 0))
			level_stars[level_id] = clampi(int(data.get_value("stars", "level_%d" % level_id, 0)), 0, 3)
	# Zapis może pochodzić ze starszej wersji gry albo zostać przerwany w trakcie
	# zamykania aplikacji. Zawsze doprowadzamy go do bezpiecznego stanu przed startem.
	sanitize_progress()

func sanitize_progress() -> void:
	var max_level_index := maxi(1, levels.size())
	unlocked_level = clampi(unlocked_level, 1, max_level_index)
	coins = clampi(coins, 0, 999999999)
	wood = clampi(wood, 0, 999999999)
	experience = clampi(experience, 0, 999999999)
	perun_sparks = clampi(perun_sparks, 0, 999999)
	event_marks = clampi(event_marks, 0, 999999)
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
	data.set_value("progress", "unlocked_level", unlocked_level)
	data.set_value("progress", "tutorial_completed", tutorial_completed)
	data.set_value("progress", "daily_reward_day", daily_reward_day)
	for intro_level_id in REGION_INTROS:
		data.set_value("region_intros", "level_%d" % int(intro_level_id), bool(seen_region_intros.get(intro_level_id, false)))
	for chapter_id in REGION_CHAPTERS:
		data.set_value("region_intros", "chapter_%s" % chapter_id, bool(seen_region_chapters.get(chapter_id, false)))
	data.set_value("wallet", "coins", coins)
	data.set_value("wallet", "wood", wood)
	data.set_value("wallet", "experience", experience)
	data.set_value("wallet", "perun_sparks", perun_sparks)
	data.set_value("wallet", "event_marks", event_marks)
	data.set_value("settings", "sfx_enabled", sfx_enabled)
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
		return DEFAULT_LEVELS.duplicate(true)
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Array and not parsed.is_empty():
		return append_generated_levels(parsed)
	push_warning("Dane poziomów są nieprawidłowe; używam konfiguracji awaryjnej.")
	return DEFAULT_LEVELS.duplicate(true)

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
	for level_id in range(101, 1001):
		var tier := level_id - 100
		var region: String = regions[int((level_id - 101) / 25) % regions.size()]
		var enemy_pool: Array = regional_enemy_pools.get(region, [])
		var grand_bosses: Array = regional_grand_bosses.get(region, [])
		var enemies: Array = []
		var base_health := 370 + tier * 6
		var base_attack := 13 + int(tier / 45)
		if level_id % 50 == 0:
			enemies.append({"name": enemy_pool[level_id % enemy_pool.size()], "health": base_health, "attack": base_attack})
			enemies.append({"name": grand_bosses[int(level_id / 50) % grand_bosses.size()], "health": base_health * 3, "attack": base_attack + 12})
		elif level_id % 25 == 0:
			enemies.append({"name": enemy_pool[level_id % enemy_pool.size()], "health": base_health, "attack": base_attack})
			enemies.append({"name": grand_bosses[int(level_id / 25) % grand_bosses.size()], "health": int(base_health * 2.3), "attack": base_attack + 9})
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
			result.append({"id": level_id, "region": region, "name": name, "moves": 17, "goal_type": "defeat_enemy", "enemies": enemies, "obstacles": obstacle_profile, "rewards": {"coins": 11200 + tier * 52 * boss_reward_multiplier, "wood": 1850 + tier * 10 * boss_reward_multiplier, "experience": 2300 + tier * 13 * boss_reward_multiplier}})
		elif is_survival_stage:
			var survival_target := 6 + int(tier / 200)
			name = "Przetrwanie %d — szlak %s" % [level_id, str(region_names[region])]
			enemies = [{"name": enemy_pool[level_id % enemy_pool.size()], "health": base_health * 3, "attack": base_attack + 6}]
			obstacle_profile = {"root": 5 + int(tier / 180), "stone": 4 + int(tier / 220), "curse": 2 + int(tier / 250)}
			result.append({"id": level_id, "region": region, "name": name, "moves": survival_target + 6, "goal_type": "survive", "goal_value": survival_target, "enemies": enemies, "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 45, "wood": 1550 + tier * 9, "experience": 1850 + tier * 11}})
		elif is_cleansing_stage:
			name = "Oczyszczenie %d — szlak %s" % [level_id, str(region_names[region])]
			obstacle_profile = {"root": 8 + int(tier / 150), "stone": 6 + int(tier / 180), "curse": 5 + int(tier / 220)}
			var cleansing_target := mini(20, 11 + int(tier / 95))
			result.append({"id": level_id, "region": region, "name": name, "moves": 18, "goal_type": "clear_obstacles", "goal_value": cleansing_target, "enemies": [], "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 42, "wood": 1550 + tier * 8, "experience": 1850 + tier * 10}})
		elif is_collection_stage:
			var collect_runes := level_id % 30 == 0
			var collection_target := mini(18, 11 + int(tier / 140))
			name = ("Zbieranie run %d" if collect_runes else "Zbieranie bursztynu %d") % level_id
			obstacle_profile = {"root": 4 + int(tier / 220), "stone": 3 + int(tier / 260), "curse": 2}
			result.append({"id": level_id, "region": region, "name": name, "moves": 19, "goal_type": "collect_rune" if collect_runes else "collect_amber", "goal_value": collection_target, "enemies": [], "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 40, "wood": 1550 + tier * 8, "experience": 1850 + tier * 10}})
		elif is_score_stage:
			name = "Echo reliktu %d" % level_id
			var score_target := 1500 + tier * 2
			obstacle_profile = {"root": 3 + int(tier / 300), "stone": 2 + int(tier / 360), "curse": 1}
			result.append({"id": level_id, "region": region, "name": name, "moves": 17, "goal_type": "score", "target": score_target, "enemies": [], "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 41, "wood": 1550 + tier * 8, "experience": 1850 + tier * 10}})
		else:
			result.append({"id": level_id, "region": region, "name": name, "moves": maxi(12, 16 - int(tier / 180)), "goal_type": "defeat_enemy", "enemies": enemies, "obstacles": obstacle_profile, "rewards": {"coins": 9200 + tier * 38, "wood": 1550 + tier * 7, "experience": 1850 + tier * 9}})
	return result
