extends RefCounted

## Profil jest kosmetyczny; wybór portretu nie rekrutuje bohatera.
const AvatarCatalog = preload("res://scripts/avatar_catalog.gd")
const AVATARS = AvatarCatalog.IDS
const AVATAR_NAMES = AvatarCatalog.NAMES
const AVATARS_PER_PAGE := 6
var avatar_catalog = AvatarCatalog.new()
var avatar_page := 0
var avatar_id := "lada"
var pending_avatar := "lada"
var player_name := "Wędrowiec"
var name_input: LineEdit
var intro_completed := false
var companion_claimed := false
var starter_companion := ""
var stage := ""
var selected_companion := ""
var home_tutorial_step := ""
var tutorial_moves := 0
var tutorial_popup_open := true
var companion_background: Texture2D
var village_tutorial_background: Texture2D

func reset_profile() -> void:
	if name_input != null:
		name_input.visible = false
	avatar_id = "lada"
	pending_avatar = "lada"
	player_name = "Wędrowiec"
	avatar_page = 0
	intro_completed = false
	companion_claimed = false
	starter_companion = ""
	selected_companion = ""
	home_tutorial_step = ""
	tutorial_moves = 0
	tutorial_popup_open = true
	stage = "intro"

func load_profile(data: ConfigFile, game) -> void:
	avatar_id = str(data.get_value("profile", "avatar", "lada"))
	player_name = sanitize_player_name(str(data.get_value("profile", "player_name", "Wędrowiec")))
	if not AVATARS.has(avatar_id):
		avatar_id = "lada"
	pending_avatar = avatar_id
	avatar_page = int(AVATARS.find(avatar_id) / AVATARS_PER_PAGE)
	# Starsze zapisy z postępem kontynuują grę bez powtarzania wprowadzenia.
	intro_completed = bool(data.get_value("profile", "intro_completed", game.tutorial_completed or game.unlocked_level > 1))
	companion_claimed = bool(data.get_value("profile", "companion_claimed", game.unlocked_level > 1))
	starter_companion = str(data.get_value("profile", "starter_companion", ""))
	home_tutorial_step = str(data.get_value("profile", "home_tutorial_step", ""))
	if starter_companion not in ["brun", "mieta"]:
		starter_companion = ""
	var migrated_profile := false
	if game.unlocked_level > 1 and not companion_claimed:
		grant_hero(game, "brun")
		starter_companion = "brun"
		companion_claimed = true
		migrated_profile = true
	if game.unlocked_level == 2 and int(game.hero_levels.get("lada", 1)) == 1 and int(game.level_stars.get(1, 0)) > 0:
		var missing_xp := maxi(0, game.hero_experience_to_next_level("lada") - int(game.hero_experience.get("lada", 0)))
		if missing_xp > 0:
			game.hero_experience["lada"] = int(game.hero_experience.get("lada", 0)) + missing_xp
			game.experience += missing_xp
		migrated_profile = true
		if home_tutorial_step == "":
			home_tutorial_step = "upgrade_lada"
	stage = "intro" if not intro_completed else ""
	if migrated_profile:
		game.save_progress()

func save_profile(data: ConfigFile) -> void:
	data.set_value("profile", "avatar", avatar_id)
	data.set_value("profile", "player_name", player_name)
	data.set_value("profile", "intro_completed", intro_completed)
	data.set_value("profile", "companion_claimed", companion_claimed)
	data.set_value("profile", "starter_companion", starter_companion)
	data.set_value("profile", "home_tutorial_step", home_tutorial_step)

func edit_avatar(game) -> void:
	pending_avatar = avatar_id
	avatar_page = int(AVATARS.find(avatar_id) / AVATARS_PER_PAGE)
	stage = "avatar_edit"
	ensure_name_input(game)
	name_input.text = player_name
	name_input.deselect()
	name_input.caret_column = name_input.text.length()
	name_input.visible = true

func sanitize_player_name(value: String) -> String:
	var cleaned := value.replace("\n", " ").replace("\r", " ").replace("\t", " ").strip_edges()
	cleaned = cleaned.substr(0, 18)
	return cleaned if cleaned != "" else "Wędrowiec"

func name_input_rect(game) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	return Rect2(panel.position + Vector2(40.0, 288.0), Vector2(panel.size.x - 80.0, 42.0))

func ensure_name_input(game) -> void:
	if name_input != null:
		name_input.position = name_input_rect(game).position
		name_input.size = name_input_rect(game).size
		return
	name_input = LineEdit.new()
	name_input.name = "PlayerNameInput"
	name_input.position = name_input_rect(game).position
	name_input.size = name_input_rect(game).size
	name_input.max_length = 18
	name_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_input.placeholder_text = "Wpisz swoją nazwę"
	name_input.virtual_keyboard_enabled = true
	name_input.add_theme_font_size_override("font_size", 19)
	name_input.add_theme_color_override("font_color", Color("#fff0c7"))
	name_input.add_theme_color_override("font_placeholder_color", Color("#9eae9d"))
	name_input.add_theme_color_override("caret_color", Color("#f0c96e"))
	var field_style := StyleBoxFlat.new()
	field_style.bg_color = Color("#09241fee")
	field_style.border_color = Color("#d9b66c")
	field_style.set_border_width_all(2)
	field_style.set_corner_radius_all(13)
	field_style.shadow_color = Color(0.0, 0.0, 0.0, 0.48)
	field_style.shadow_size = 5
	field_style.shadow_offset = Vector2(0.0, 3.0)
	field_style.content_margin_left = 14.0
	field_style.content_margin_right = 14.0
	name_input.add_theme_stylebox_override("normal", field_style)
	var focus_style := field_style.duplicate() as StyleBoxFlat
	focus_style.border_color = Color("#f0c96e")
	focus_style.shadow_color = Color(0.85, 0.58, 0.16, 0.32)
	focus_style.shadow_size = 7
	name_input.add_theme_stylebox_override("focus", focus_style)
	name_input.text = player_name
	name_input.visible = false
	game.add_child(name_input)

func grant_hero(game, hero_id: String) -> void:
	game.owned_heroes[hero_id] = true
	game.hero_levels[hero_id] = maxi(1, int(game.hero_levels.get(hero_id, 0)))
	if not game.active_heroes.has(hero_id) and game.active_heroes.size() < 3:
		game.active_heroes.append(hero_id)
	game.sync_party_battle_health()

func on_victory(game, level_id: int, first_clear := true) -> void:
	if level_id == 1:
		game.tutorial_completed = true
		if not companion_claimed:
			# Pierwsze zwycięstwo od razu odblokowuje Bruna. Mięta dołączy
			# później, dzięki czemu drużyna rośnie razem z kampanią.
			grant_hero(game, "brun")
			starter_companion = "brun"
			companion_claimed = true
		if first_clear:
			home_tutorial_step = "upgrade_lada"
	elif level_id == 2 and first_clear:
		home_tutorial_step = "village_unlocked"
	# Towarzysze i nowe tryby pojawiają się w miarę postępu, bez przerywania
	# powrotu do głównego ekranu po ukończonej walce.
	if level_id == 5 and first_clear and starter_companion != "":
		var joining_hero := "mieta" if starter_companion == "brun" else "brun"
		var newly_joined := not bool(game.owned_heroes.get(joining_hero, false))
		grant_hero(game, joining_hero)
		if newly_joined:
			home_tutorial_step = "third_companion_unlocked"

func panel_rect(game) -> Rect2:
	var screen: Vector2 = game.get_viewport_rect().size
	return Rect2(Vector2(20, maxf(20, (screen.y - 700) * 0.5)), Vector2(screen.x - 40, 700))

func primary_rect(game) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	if stage in ["avatar", "avatar_edit"]:
		var width := minf(260.0, panel.size.x - 24.0)
		return Rect2(panel.position + Vector2((panel.size.x - width) * 0.5, 630), Vector2(width, 84))
	var width := minf(350.0, panel.size.x - 48.0)
	var y := 640.0 if stage == "intro" else (600.0 if stage == "upgrade_village" else 560.0)
	return Rect2(Vector2((game.get_viewport_rect().size.x - width) * 0.5, panel.position.y + y), Vector2(width, 102))

func secondary_rect(game) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	if stage in ["avatar", "avatar_edit"]:
		var width := (panel.size.x - 48) * 0.5
		return Rect2(panel.position + Vector2((panel.size.x - width) * 0.5, 712), Vector2(width, 48))
	var width := minf(320.0, panel.size.x - 48.0)
	var y := 740.0 if stage == "intro" else 632.0
	return Rect2(Vector2((game.get_viewport_rect().size.x - width) * 0.5, panel.position.y + y), Vector2(width, 72))

func choice_rect(game, index: int) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	if stage in ["avatar", "avatar_edit"]:
		var slot := index % AVATARS_PER_PAGE
		var spacing := (panel.size.x - 48) / 3.0
		var diameter := minf(88.0, spacing - 10.0)
		var center := panel.position + Vector2(24 + spacing * (slot % 3 + 0.5), 382 + int(slot / 3) * 130)
		return Rect2(center - Vector2.ONE * diameter * 0.5, Vector2.ONE * diameter)
	if stage == "companion":
		var diameter := minf(176.0, (panel.size.x - 88.0) * 0.5)
		var gap := panel.size.x - diameter * 2.0
		var x := panel.position.x + gap * 0.34 + index * (diameter + gap * 0.32)
		return Rect2(Vector2(x, panel.position.y + 166), Vector2(diameter, diameter + 34))
	var width := (panel.size.x - 60) / 2.0
	var row := int(index / 2)
	return Rect2(panel.position + Vector2(24 + (index % 2) * (width + 12), 170 + row * 178), Vector2(width, 166))

func avatar_page_rect(game, direction: int) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	return Rect2(panel.position + Vector2(18 if direction < 0 else panel.size.x - 64, 603), Vector2(46, 48))

func handle_input(game, position: Vector2) -> void:
	if stage == "intro":
		if primary_rect(game).has_point(position) or secondary_rect(game).has_point(position):
			stage = "avatar"
			ensure_name_input(game)
			name_input.text = player_name
			name_input.deselect()
			name_input.caret_column = name_input.text.length()
			name_input.visible = true
	elif stage in ["avatar", "avatar_edit"]:
		for direction in [-1, 1]:
			if avatar_page_rect(game, direction).has_point(position):
				avatar_page = posmod(avatar_page + direction, int(ceil(float(AVATARS.size()) / AVATARS_PER_PAGE)))
				game.queue_redraw()
				return
		for index in range(avatar_page * AVATARS_PER_PAGE, (avatar_page + 1) * AVATARS_PER_PAGE):
			var rect := choice_rect(game, index)
			if position.distance_to(rect.get_center()) <= rect.size.x * 0.5:
				pending_avatar = AVATARS[index]
		if primary_rect(game).has_point(position):
			var begin_game := stage == "avatar"
			avatar_id = pending_avatar
			player_name = sanitize_player_name(name_input.text) if name_input != null else player_name
			intro_completed = true
			stage = ""
			if name_input != null:
				name_input.visible = false
			game.save_progress()
			if begin_game:
				game.main_menu_open = false
				game.start_level(0)
		elif stage == "avatar_edit" and secondary_rect(game).has_point(position):
			stage = ""
			if name_input != null:
				name_input.visible = false
	elif stage == "companion":
		for index in 2:
			if choice_rect(game, index).has_point(position):
				selected_companion = "brun" if index == 0 else "mieta"
		if primary_rect(game).has_point(position) and selected_companion != "" and not companion_claimed:
			grant_hero(game, selected_companion)
			starter_companion = selected_companion
			companion_claimed = true
			game.save_progress()
			stage = "ready"
	elif stage == "ready" and primary_rect(game).has_point(position):
		stage = ""
		game.main_menu_open = false
		game.start_level(1)
	elif stage == "third_companion" and primary_rect(game).has_point(position):
		stage = ""
		game.main_menu_open = false
		game.start_level(5)
	elif stage == "upgrade_lada" and primary_rect(game).has_point(position):
		stage = ""
		game.main_menu_open = false
		game.roster_open = true
		game.roster_hero_index = maxi(0, game.HERO_IDS.find("lada"))
	elif stage == "upgrade_village" and primary_rect(game).has_point(position):
		stage = ""
		game.main_menu_open = false
		game.village_open = true
		game.village_selected_id = ""
	game.queue_redraw()

func line(game, text: String, y: float, text_size := 18) -> void:
	var panel: Rect2 = panel_rect(game)
	game.draw_string(game.font, panel.position + Vector2(24, y), text, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 48, text_size, Color("#f5e5be"))

func line_spaced(game, text: String, y: float, text_size := 18) -> void:
	line(game, text, y, text_size)

func avatar_instrumental_name(avatar: String) -> String:
	var forms := {
		"Wędrowniczka": "Wędrowniczką", "Kowal": "Kowalem", "Zielarka": "Zielarką", "Strażnik": "Strażnikiem",
		"Wilk": "Wilkiem", "Lis": "Lisem", "Kruk": "Krukiem", "Sowa": "Sową", "Jeleń": "Jeleniem",
		"Ryś": "Rysiem", "Niedźwiedź": "Niedźwiedziem", "Dzik": "Dzikiem", "Żubr": "Żubrem", "Zając": "Zającem",
		"Borsuk": "Borsukiem", "Leszy": "Leszym", "Rusałka": "Rusałką", "Żmij": "Żmijem", "Płomyk": "Płomykiem",
		"Duch dębu": "Duchem dębu", "Kapłanka": "Kapłanką", "Łowczyni": "Łowczynią", "Wojownik": "Wojownikiem",
		"Wędrowiec": "Wędrowcem", "Tkaczka": "Tkaczką", "Bartnik": "Bartnikiem", "Wieszczka": "Wieszczką",
		"Guślarz": "Guślarzem", "Strzyga": "Strzygą", "Zorza": "Zorzą"
	}
	return str(forms.get(avatar, avatar))

func draw(game) -> void:
	var screen: Vector2 = game.get_viewport_rect().size
	if stage in ["avatar", "avatar_edit"]:
		draw_avatar_picker(game)
		return
	var tutorial_background: Texture2D
	if stage == "upgrade_village":
		if village_tutorial_background == null:
			village_tutorial_background = game.load_image_texture("res://art/environments/tutorial_village_background_v01.png")
		tutorial_background = village_tutorial_background if village_tutorial_background != null else game.oak_borderland_background
	elif stage == "upgrade_lada":
		tutorial_background = game.oak_borderland_background
	if stage in ["upgrade_lada", "upgrade_village"]:
		if tutorial_background != null:
			game.draw_texture_rect(tutorial_background, Rect2(Vector2.ZERO, screen), false)
		else:
			game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#091e19"))
		game.draw_rect(Rect2(Vector2.ZERO, screen), Color(0.015, 0.025, 0.022, 0.30))
	elif stage == "companion":
		if companion_background == null:
			companion_background = game.load_image_texture("res://art/ui/companion_selection_background_v01.png")
		if companion_background != null:
			game.draw_texture_rect(companion_background, Rect2(Vector2.ZERO, screen), false)
		else:
			game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#091e19"))
		game.draw_rect(Rect2(Vector2.ZERO, screen), Color(0.02, 0.09, 0.07, 0.28))
	elif game.oak_borderland_background != null:
		game.draw_texture_rect(game.oak_borderland_background, Rect2(Vector2.ZERO, screen), false, Color(0.68, 0.78, 0.71, 1.0))
	else:
		game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#091e19"))
	if stage not in ["upgrade_lada", "upgrade_village"]:
		game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#061511b8"))
	var panel: Rect2 = panel_rect(game)
	if stage not in ["intro", "companion", "ready", "third_companion", "upgrade_lada", "upgrade_village"]:
		game.draw_style_box(game.make_panel(Color("#18352ee8"), Color("#b38b4d")), panel)
	# Teksty i portrety zajmują środek; światło pozostaje na obrzeżach sceny.
	draw_background_fireflies(game, screen, [
		Rect2(Vector2(64, panel.position.y), Vector2(screen.x - 128, panel.size.y)),
		Rect2(Vector2(screen.x * 0.5 - 110, 10), Vector2(220, 125)),
		primary_rect(game), secondary_rect(game),
	])
	if stage == "intro":
		game.draw_game_logo(Vector2(screen.x / 2.0, 72), Vector2(210, 125))
		line(game, "Mgła spowija Dębowe Pogranicze.", 132)
		line(game, "Lada słyszy wołanie starego gaju.", 168)
		line(game, "Pomóż jej odnaleźć Leszego", 214)
		line(game, "i przywróć światło osadzie.", 246)
		var portrait: Texture2D = game.hero_portraits.get("lada", null)
		if portrait != null:
			var portrait_slot := Rect2(panel.position + Vector2(panel.size.x / 2 - 158, 380), Vector2(316, 316))
			game.draw_texture_rect(portrait, game.texture_aspect_fit_rect(portrait, portrait_slot), false)
		game.draw_button(primary_rect(game), "DALEJ", true, 18, -2.0)
		game.draw_button(secondary_rect(game), "POMIŃ WSTĘP", true, 14)
	elif stage == "companion":
		line_spaced(game, "PIERWSZE ZWYCIĘSTWO!", 54, 28)
		line_spaced(game, "Wybierz pierwszego towarzysza dla Lady.", 114, 18)
		line_spaced(game, "Dołączy od razu do Twojej drużyny.", 144, 16)
		draw_choice(game, 0, "brun", "Brun • ogień", selected_companion == "brun")
		draw_choice(game, 1, "mieta", "Mięta • woda", selected_companion == "mieta")
		line_spaced(game, "Brun rozbija kafelki obszarem 3×3.", 408, 17)
		line_spaced(game, "Mięta leczy drużynę mocą wody.", 440, 17)
		line_spaced(game, "Ich talenty rozwijasz wraz z poziomami.", 472, 16)
		line_spaced(game, "Drugi towarzysz dołączy po poziomie 5.", 504, 16)
		game.draw_button(primary_rect(game), "DOŁĄCZ DO DRUŻYNY", selected_companion != "", 18, -2.0)
	elif stage == "ready":
		line(game, "DRUŻYNA GOTOWA", 46, 28)
		line(game, "Lada i wybrany towarzysz wyruszają razem.", 86, 17)
		avatar_catalog.load_decoration(game)
		var portrait_size := 136.0
		var portrait_y := panel.position.y + 122.0
		var lada_rect := Rect2(Vector2(screen.x * 0.27 - portrait_size * 0.5, portrait_y), Vector2.ONE * portrait_size)
		var companion_rect := Rect2(Vector2(screen.x * 0.73 - portrait_size * 0.5, portrait_y), Vector2.ONE * portrait_size)
		avatar_catalog.draw_portrait(game, "lada", lada_rect, true)
		avatar_catalog.draw_portrait(game, starter_companion if starter_companion != "" else "brun", companion_rect, true)
		game.draw_string(game.font, Vector2(lada_rect.position.x - 12, lada_rect.end.y + 24), "Lada", HORIZONTAL_ALIGNMENT_CENTER, lada_rect.size.x + 24, 17, Color("#fff0c7"))
		var companion_name := "Brun" if starter_companion == "brun" else "Mięta"
		game.draw_string(game.font, Vector2(companion_rect.position.x - 12, companion_rect.end.y + 24), companion_name, HORIZONTAL_ALIGNMENT_CENTER, companion_rect.size.x + 24, 17, Color("#fff0c7"))
		line(game, "W menu DRUŻYNA możesz zmienić skład i rozwijać talenty.", 326, 16)
		line(game, "NASTĘPNY SZLAK • POZIOM 2 — ŚLAD W MCHU", 366, 15)
		var enemy_portrait: Texture2D = game.enemy_portraits.get("Cień mchu", null)
		if enemy_portrait == null:
			enemy_portrait = game.boss_portrait_for("Cień mchu")
		if enemy_portrait != null:
			var enemy_rect := Rect2(Vector2(screen.x * 0.5 - 54, panel.position.y + 386), Vector2.ONE * 108)
			game.draw_circle(enemy_rect.get_center(), 53.0, Color("#081d18dd"))
			game.draw_texture_rect(enemy_portrait, enemy_rect, false)
			game.draw_string(game.font, Vector2(enemy_rect.position.x - 22, enemy_rect.end.y + 20), "Leśny cień", HORIZONTAL_ALIGNMENT_CENTER, enemy_rect.size.x + 44, 14, Color("#ffe7ad"))
		if not game.last_reward.is_empty():
			var reward_y := panel.position.y + 534.0
			var reward_values := [int(game.last_reward.get("coins", 0)), int(game.last_reward.get("wood", 0)), int(game.last_reward.get("experience", 0))]
			var reward_kinds := ["coins", "wood", "experience"]
			var reward_width := 0.0
			for reward_index in reward_values.size():
				reward_width += game.resource_amount_width(reward_values[reward_index], 28.0, 15)
				if reward_index < reward_values.size() - 1:
					reward_width += 20.0
			var reward_x := (screen.x - reward_width) * 0.5
			for reward_index in reward_values.size():
				reward_x += game.draw_resource_amount(Vector2(reward_x, reward_y), reward_kinds[reward_index], reward_values[reward_index], 28.0, 15, Color("#ffe7ad")) + 20.0
		else:
			line(game, "Nagrody za pierwszą walkę są już w Twoim zapisie.", 514, 15)
		game.draw_button(primary_rect(game), "GRAJ • POZIOM 2", true)
	elif stage == "upgrade_lada":
		line(game, "CZAS ROZWIJAĆ BOHATERA", 70, 26)
		var lada_portrait: Texture2D = game.hero_portraits.get("lada", null)
		var lada_rect := Rect2(Vector2(panel.get_center().x - 100.0, panel.position.y + 150.0), Vector2(200, 200))
		if lada_portrait != null:
			game.draw_texture_rect(lada_portrait, game.texture_aspect_fit_rect(lada_portrait, lada_rect.grow(-20.0)), false)
		game.draw_string(game.font, Vector2(panel.get_center().x - 90.0, lada_rect.end.y + 34.0), "LADA", HORIZONTAL_ALIGNMENT_CENTER, 180.0, 20, Color("#fff0c7"))
		line(game, "Poziom 2 odblokował rozwój drużyny.", 430, 17)
		line(game, "W menu DRUŻYNA wybierz Ladę i kliknij ulepszenie.", 476, 15)
		var lada_xp := int(game.hero_experience.get("lada", 0))
		var lada_xp_required: int = game.hero_experience_to_next_level("lada")
		line(game, "%d / %d PD Lady • pierwsze ulepszenie jest darmowe." % [lada_xp, lada_xp_required], 522, 15)
		game.draw_button(primary_rect(game), "ULEPSZ LADĘ", true, 18)
	elif stage == "upgrade_village":
		line(game, "CZAS ROZBUDOWAĆ OSADĘ", 70, 26)
		line(game, "PIERWSZA ROZBUDOWA OSADY", 400, 19)
		line(game, "Poziom 3 odblokował rozwój Osady.", 440, 17)
		line(game, "Wybierz budynek i kliknij przycisk ROZBUDUJ.", 482, 15)
		line(game, "Pierwsza rozbudowa jest bezpłatna.", 524, 15)
		game.draw_button(primary_rect(game), "ULEPSZ OSADĘ", true, 18)
	elif stage == "third_companion":
		var joining_name := "Mięta" if starter_companion == "brun" else "Brun"
		line(game, "TRZECI BOHATER DOŁĄCZA!", 50, 26)
		line(game, "%s dołącza do Twojej drużyny." % joining_name, 88, 17)
		line(game, "Od teraz możesz walczyć pełnym składem trzech bohaterów.", 116, 14)
		avatar_catalog.load_decoration(game)
		var portrait_size := 118.0
		var portrait_y := panel.position.y + 154.0
		var ids := ["lada", starter_companion, "mieta" if starter_companion == "brun" else "brun"]
		var names := ["Lada", "Brun" if starter_companion == "brun" else "Mięta", "Mięta" if starter_companion == "brun" else "Brun"]
		for hero_index in ids.size():
			var hero_rect := Rect2(Vector2(screen.x * (0.18 + hero_index * 0.32) - portrait_size * 0.5, portrait_y), Vector2.ONE * portrait_size)
			avatar_catalog.draw_portrait(game, ids[hero_index], hero_rect, true)
			game.draw_string(game.font, Vector2(hero_rect.position.x - 10, hero_rect.end.y + 22), names[hero_index], HORIZONTAL_ALIGNMENT_CENTER, hero_rect.size.x + 20, 15, Color("#fff0c7"))
		line(game, "Brun niszczy kafelki obszarem 3×3.", 408, 16)
		line(game, "Mięta leczy drużynę mocą wody.", 440, 16)
		line(game, "Skład możesz zmieniać później w menu DRUŻYNA.", 482, 15)
		line(game, "Następny szlak: poziom 6.", 522, 16)
		game.draw_button(primary_rect(game), "GRAJ • POZIOM 6", true)

func draw_avatar_fireflies(game, screen: Vector2, panel: Rect2) -> void:
	# Rysowane po tle, przed całym interfejsem. Margines wygasza również
	# poświatę przy portretach i kontrolkach, zamiast ucinać ją na krawędzi.
	var protected: Array[Rect2] = [
		Rect2(panel.position + Vector2(panel.size.x * 0.5 - 76, 69), Vector2(152, 152)),
		name_input_rect(game), primary_rect(game),
		avatar_page_rect(game, -1), avatar_page_rect(game, 1),
		Rect2(panel.position + Vector2(0, 0), Vector2(panel.size.x, 68)),
		Rect2(panel.position + Vector2(0, 220), Vector2(panel.size.x, 42)),
		Rect2(panel.position + Vector2(0, 571), Vector2(panel.size.x, 24)),
		Rect2(panel.position + Vector2(panel.size.x * 0.5 - 28, 609), Vector2(56, 25)),
	]
	for index in range(avatar_page * AVATARS_PER_PAGE, (avatar_page + 1) * AVATARS_PER_PAGE):
		var portrait_rect := choice_rect(game, index)
		protected.append(Rect2(portrait_rect.position, portrait_rect.size + Vector2(0, 20)))
	if stage == "avatar_edit":
		protected.append(secondary_rect(game))
	draw_background_fireflies(game, screen, protected)

func draw_background_fireflies(game, screen: Vector2, protected: Array[Rect2] = [], opacity := 1.0) -> void:
	# Wspólna animacja dla spokojnych ekranów; wywoływana przed treścią UI.
	var time: float = game.ui_anim_time
	for index in 60:
		# Stałe fazy nie korzystają z losowości rozgrywki i nie przeskakują po kliknięciu.
		var seed_value := float(index)
		var phase := seed_value * 2.399963
		var speed := 3.0 + fposmod(seed_value * 1.73, 4.0)
		var position := Vector2(
			screen.x * (0.07 + fposmod(seed_value * 0.618034, 0.86)) + sin(time * 0.24 + phase) * 14.0,
			fposmod(screen.y * fposmod(seed_value * 0.381966, 1.0) - time * speed, screen.y)
		)
		position.y += sin(time * 0.37 + phase) * 6.0
		var visibility := 1.0
		for rect in protected:
			var nearest := position.clamp(rect.position, rect.end)
			visibility = minf(visibility, smoothstep(5.0, 20.0, position.distance_to(nearest)))
		visibility *= smoothstep(0.0, 28.0, minf(position.y, screen.y - position.y))
		if visibility <= 0.001:
			continue
		var pulse := 0.25 + 0.75 * pow((sin(time * 0.8 + phase) + 1.0) * 0.5, 2.0)
		var alpha := visibility * pulse * opacity
		var radius := 0.7 + fposmod(seed_value * 0.37, 0.65)
		game.draw_circle(position, radius * 5.0, Color(1.0, 0.64, 0.18, alpha * 0.025), true, -1.0, true)
		game.draw_circle(position, radius * 3.0, Color(1.0, 0.74, 0.27, alpha * 0.07), true, -1.0, true)
		game.draw_circle(position, radius * 1.7, Color(1.0, 0.84, 0.42, alpha * 0.18), true, -1.0, true)
		game.draw_circle(position, radius, Color(1.0, 0.93, 0.65, alpha * 0.7), true, -1.0, true)

func draw_avatar_picker(game) -> void:
	var screen: Vector2 = game.get_viewport_rect().size
	var panel: Rect2 = panel_rect(game)
	avatar_catalog.load_decoration(game)
	game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#091e19"))
	if avatar_catalog.background != null:
		game.draw_texture_rect(avatar_catalog.background, Rect2(Vector2.ZERO, screen), false)
	draw_avatar_fireflies(game, screen, panel)
	line(game, "TWÓJ AWATAR", 28, 28)
	line(game, "Wybierz jeden z 30 portretów", 62, 17)
	var preview := Rect2(panel.position + Vector2(panel.size.x * 0.5 - 76, 69), Vector2(152, 152))
	avatar_catalog.draw_portrait(game, pending_avatar, preview, true)
	line(game, AVATAR_NAMES[AVATARS.find(pending_avatar)], 238, 20)
	line(game, "NAZWA GRACZA", 255, 13)
	for index in range(avatar_page * AVATARS_PER_PAGE, (avatar_page + 1) * AVATARS_PER_PAGE):
		var rect := choice_rect(game, index)
		var selected: bool = pending_avatar == AVATARS[index]
		avatar_catalog.draw_portrait(game, AVATARS[index], rect, selected)
		game.draw_string(game.font, Vector2(rect.get_center().x - 48, rect.end.y + 14), AVATAR_NAMES[index], HORIZONTAL_ALIGNMENT_CENTER, 96, 11, Color("#ffe9ae") if selected else Color("#d1dfc9"))
	for direction in [-1, 1]:
		var arrow_rect := avatar_page_rect(game, direction)
		if avatar_catalog.page_arrow != null:
			# Plik strzałki wskazuje w prawo. Lewa kontrolka dostaje obrót,
			# prawa pozostaje w oryginalnej orientacji; obsługa kliknięć się nie zmienia.
			if direction < 0:
				game.draw_set_transform(arrow_rect.get_center(), PI, Vector2.ONE)
				game.draw_texture_rect(avatar_catalog.page_arrow, Rect2(-arrow_rect.size * 0.5, arrow_rect.size), false)
				game.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				game.draw_texture_rect(avatar_catalog.page_arrow, arrow_rect, false)
	line(game, "%d / 5" % (avatar_page + 1), 630, 16)
	line(game, "Nazwę i portret później zmienisz w menu.", 588, 13)
	game.draw_button(primary_rect(game), "WYRUSZ W PRZYGODĘ" if stage == "avatar" else "ZAPISZ AWATAR", true, 16)
	if stage == "avatar_edit":
		game.draw_button(secondary_rect(game), "ANULUJ", true, 14)

func draw_choice(game, index: int, hero_id: String, label: String, selected: bool) -> void:
	var rect: Rect2 = choice_rect(game, index)
	if stage == "companion":
		var circle_rect := Rect2(rect.position, Vector2(rect.size.x, rect.size.x))
		game.draw_circle(circle_rect.get_center(), circle_rect.size.x * 0.49, Color("#071c17cc") if not selected else Color("#4d3b19dd"))
		avatar_catalog.draw_portrait(game, hero_id, circle_rect, selected, false)
		game.draw_string(game.font, Vector2(rect.position.x - 8, rect.position.y + rect.size.x + 24), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x + 16, 17, Color("#fff0c7"))
		if selected:
			game.draw_string(game.font, Vector2(rect.position.x - 8, rect.position.y + rect.size.x + 44), "WYBRANO", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x + 16, 11, Color("#f4d477"))
		return
	game.draw_style_box(game.make_panel(Color("#2d4937") if selected else Color("#10291f"), Color("#f0c96e") if selected else Color("#716342")), rect)
	var portrait: Texture2D = game.home_face_portrait(hero_id)
	if portrait != null:
		game.draw_texture_rect(portrait, Rect2(rect.get_center() - Vector2(52, 70), Vector2(104, 104)), false)
	game.draw_string(game.font, rect.position + Vector2(6, 138), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 12, 17, Color("#fff0c7"))
	if selected:
		game.draw_string(game.font, rect.position + Vector2(6, 158), "WYBRANO", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 12, 11, Color("#f0c96e"))

func tutorial_active(game) -> bool:
	if stage != "" or game.training_mode or game.state != "playing":
		return false
	# Po kolejnych zwycięstwach prowadzimy gracza przez rozwój bohatera
	# i pierwszą rozbudowę osady.
	return (game.level_index == 0 and not game.tutorial_completed) or game.level_index == 1

func tutorial_text(game) -> String:
	if game.level_index == 1:
		if tutorial_moves == 0:
			return "W 7. rzędzie od góry przeciągnij 3. kafelek o jedno pole w górę. Połączenie 4 tworzy wybuchowy znak: kliknij go, by uderzyć w pole 5×5 za 1,2× punktów. Połączenie 5 tworzy znak globalny: usuwa wszystkie znaki tego rodzaju za 2× punktów. Oba połączenia dają dodatkowy ruch."
		return "Świetnie! Powstał kafelek wybuchowy. Kliknij go, by zniszczyć znaki w promieniu 2 pól (obszar 5×5). Połączenie 5 znaków tworzy kafelek globalny, który usuwa wszystkie znaki jego rodzaju i daje 2× punktów. Oba połączenia dają dodatkowy ruch."
	if tutorial_moves == 0:
		return "Przeciągnij zielony liść do góry na złote pole. Jasne kafelki utworzą trójkę; reszta planszy jest zablokowana. Liście wzmacniają atak Lady."
	if tutorial_moves == 1:
		return "Ogień i runy atakują. Pokonaj Cień mchu, aby wygrać."
	if tutorial_moves == 2:
		return "Woda leczy, liście dają tarczę. Nietrafiony ruch nie wywołuje ataku."
	return "Zbieraj ogień i runy, by odebrać wrogowi całe zdrowie."

func draw_tutorial(game) -> void:
	if not tutorial_popup_open:
		return
	var screen: Vector2 = game.get_viewport_rect().size
	# Samouczek przykrywa cały górny pasek gry, tak aby nie konkurował z nim
	# przycisk pauzy ani oznaczenie poziomu.
	# Przesunięcie samej ozdobnej planszy zostawia więcej miejsca nad polem walki.
	var panel_height := 282.0 if game.level_index == 1 else 190.0
	var panel := Rect2(38, 2, screen.x - 76, panel_height)
	var panel_background := panel
	panel_background.position.y += 10.0
	if game.tutorial_tooltip_banner != null:
		game.draw_texture_rect(game.tutorial_tooltip_banner, panel_background, false)
	elif game.turn_banner_oak != null:
		game.draw_texture_rect(game.turn_banner_oak, panel_background, false, Color(0.92, 0.98, 0.9, 1.0))
	else:
		game.draw_style_box(game.make_panel(Color("#09251fd9"), Color("#d4ad5e")), panel_background)
	var heading := "SAMOUCZEK • POZIOM 2" if game.level_index == 1 else ("PODPOWIEDŹ • POZIOM %d" % (game.level_index + 1) if game.level_index > 0 else "SAMOUCZEK • KROK %d/4" % mini(tutorial_moves + 1, 4))
	var text_offset_y := 20.0 if game.level_index == 1 else 0.0
	game.draw_string(game.font, Vector2(panel.position.x + 12, panel.position.y + 78 + text_offset_y), heading, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 64, 17, Color("#f5d998"))
	game.draw_multiline_string(game.font, Vector2(panel.position.x + 18, panel.position.y + 108 + text_offset_y), tutorial_text(game), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 36, 17, 24, Color("#ffe7a3"))
	var close_rect := tutorial_close_rect(game)
	if game.village_popup_close_button != null:
		game.draw_texture_rect(game.village_popup_close_button, close_rect, false)
	else:
		game.draw_style_box(game.make_panel(Color("#173b2edc"), Color("#d7b46a")), close_rect)
		game.draw_string(game.font, Vector2(close_rect.position.x, close_rect.position.y + 27), "×", HORIZONTAL_ALIGNMENT_CENTER, close_rect.size.x, 22, Color("#fff0c7"))

func tutorial_close_rect(game) -> Rect2:
	var screen: Vector2 = game.get_viewport_rect().size
	return Rect2(screen.x - 72.0, 58.0, 34.0, 34.0)
