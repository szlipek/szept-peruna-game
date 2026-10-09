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
var intro_completed := false
var companion_claimed := false
var starter_companion := ""
var stage := ""
var selected_companion := ""
var tutorial_moves := 0
var companion_background: Texture2D

func reset_profile() -> void:
	avatar_id = "lada"
	pending_avatar = "lada"
	avatar_page = 0
	intro_completed = false
	companion_claimed = false
	starter_companion = ""
	selected_companion = ""
	tutorial_moves = 0
	stage = "intro"

func load_profile(data: ConfigFile, game) -> void:
	avatar_id = str(data.get_value("profile", "avatar", "lada"))
	if not AVATARS.has(avatar_id):
		avatar_id = "lada"
	pending_avatar = avatar_id
	avatar_page = int(AVATARS.find(avatar_id) / AVATARS_PER_PAGE)
	# Starsze zapisy z postępem kontynuują grę bez powtarzania wprowadzenia.
	intro_completed = bool(data.get_value("profile", "intro_completed", game.tutorial_completed or game.unlocked_level > 1))
	companion_claimed = bool(data.get_value("profile", "companion_claimed", game.unlocked_level > 1))
	starter_companion = str(data.get_value("profile", "starter_companion", ""))
	if starter_companion not in ["brun", "mieta"]:
		starter_companion = ""
	stage = "intro" if not intro_completed else ("companion" if game.unlocked_level > 1 and not companion_claimed else "")

func save_profile(data: ConfigFile) -> void:
	data.set_value("profile", "avatar", avatar_id)
	data.set_value("profile", "intro_completed", intro_completed)
	data.set_value("profile", "companion_claimed", companion_claimed)
	data.set_value("profile", "starter_companion", starter_companion)

func edit_avatar() -> void:
	pending_avatar = avatar_id
	avatar_page = int(AVATARS.find(avatar_id) / AVATARS_PER_PAGE)
	stage = "avatar_edit"

func grant_hero(game, hero_id: String) -> void:
	game.owned_heroes[hero_id] = true
	game.hero_levels[hero_id] = maxi(1, int(game.hero_levels.get(hero_id, 0)))
	if not game.active_heroes.has(hero_id) and game.active_heroes.size() < 3:
		game.active_heroes.append(hero_id)

func on_victory(game, level_id: int) -> void:
	if level_id == 1:
		game.tutorial_completed = true
		if not companion_claimed:
			selected_companion = ""
			stage = "companion"
	# Wybór pierwszego towarzysza nie blokuje zdobycia drugiego.
	if level_id == 5 and starter_companion != "":
		grant_hero(game, "mieta" if starter_companion == "brun" else "brun")

func panel_rect(game) -> Rect2:
	var screen: Vector2 = game.get_viewport_rect().size
	return Rect2(Vector2(20, maxf(20, (screen.y - 700) * 0.5)), Vector2(screen.x - 40, 700))

func primary_rect(game) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	if stage in ["avatar", "avatar_edit"]:
		var width := minf(260.0, panel.size.x - 24.0)
		return Rect2(panel.position + Vector2((panel.size.x - width) * 0.5, 590), Vector2(width, 84))
	var width := minf(350.0, panel.size.x - 48.0)
	var y := 640.0 if stage == "intro" else 560.0
	return Rect2(Vector2((game.get_viewport_rect().size.x - width) * 0.5, panel.position.y + y), Vector2(width, 102))

func secondary_rect(game) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	if stage in ["avatar", "avatar_edit"]:
		var width := (panel.size.x - 48) * 0.5
		return Rect2(panel.position + Vector2((panel.size.x - width) * 0.5, 672), Vector2(width, 48))
	var width := minf(320.0, panel.size.x - 48.0)
	var y := 740.0 if stage == "intro" else 632.0
	return Rect2(Vector2((game.get_viewport_rect().size.x - width) * 0.5, panel.position.y + y), Vector2(width, 72))

func choice_rect(game, index: int) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	if stage in ["avatar", "avatar_edit"]:
		var slot := index % AVATARS_PER_PAGE
		var spacing := (panel.size.x - 48) / 3.0
		var diameter := minf(104.0, spacing - 10.0)
		var center := panel.position + Vector2(24 + spacing * (slot % 3 + 0.5), 318 + int(slot / 3) * 148)
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
	return Rect2(panel.position + Vector2(18 if direction < 0 else panel.size.x - 64, 563), Vector2(46, 48))

func handle_input(game, position: Vector2) -> void:
	if stage == "intro":
		if primary_rect(game).has_point(position) or secondary_rect(game).has_point(position):
			stage = "avatar"
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
			intro_completed = true
			stage = ""
			game.save_progress()
			if begin_game:
				game.main_menu_open = false
				game.start_level(0)
		elif stage == "avatar_edit" and secondary_rect(game).has_point(position):
			stage = ""
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
	game.queue_redraw()

func line(game, text: String, y: float, text_size := 18) -> void:
	var panel: Rect2 = panel_rect(game)
	game.draw_string(game.font, panel.position + Vector2(24, y), text, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 48, text_size, Color("#f5e5be"))

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
	if stage == "companion":
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
	game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#061511b8"))
	var panel: Rect2 = panel_rect(game)
	if stage not in ["intro", "companion", "ready"]:
		game.draw_style_box(game.make_panel(Color("#18352ee8"), Color("#b38b4d")), panel)
	if stage == "intro":
		game.draw_game_logo(Vector2(screen.x / 2.0, 72), Vector2(210, 125))
		line(game, "Mgła ogarnia Dębowe Pogranicze.", 132)
		line(game, "Lada słyszy wołanie starego gaju.", 168)
		line(game, "Pomóż jej odnaleźć Leszego", 214)
		line(game, "i przywrócić światło osadzie.", 246)
		var portrait: Texture2D = game.hero_portraits.get("lada", null)
		if portrait != null:
			var portrait_slot := Rect2(panel.position + Vector2(panel.size.x / 2 - 158, 380), Vector2(316, 316))
			game.draw_texture_rect(portrait, game.texture_aspect_fit_rect(portrait, portrait_slot), false)
		game.draw_button(primary_rect(game), "ROZPOCZNIJ PRZYGODĘ", true)
		game.draw_button(secondary_rect(game), "POMIŃ WSTĘP", true, 14)
	elif stage == "companion":
		line(game, "PIERWSZE ZWYCIĘSTWO!", 54, 28)
		line(game, "Wybierz bezpłatnego towarzysza Lady.", 98, 18)
		line(game, "Dołączy od razu do Twojej drużyny.", 128, 16)
		draw_choice(game, 0, "brun", "Brun • ogień", selected_companion == "brun")
		draw_choice(game, 1, "mieta", "Mieta • woda", selected_companion == "mieta")
		line(game, "Brun rozbija kafelki obszarem 3×3.", 408, 17)
		line(game, "Mieta leczy drużynę mocą wody.", 440, 17)
		line(game, "Ich talenty rozwijasz wraz z poziomami.", 472, 16)
		line(game, "Drugi towarzysz dołączy po poziomie 5.", 504, 16)
		game.draw_button(primary_rect(game), "DOŁĄCZ DO DRUŻYNY", selected_companion != "")
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
		var companion_name := "Brun" if starter_companion == "brun" else "Mieta"
		game.draw_string(game.font, Vector2(companion_rect.position.x - 12, companion_rect.end.y + 24), companion_name, HORIZONTAL_ALIGNMENT_CENTER, companion_rect.size.x + 24, 17, Color("#fff0c7"))
		line(game, "W menu DRUŻYNA zmienisz skład i rozwiniesz talenty.", 326, 16)
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
			var reward_y := panel.position.y + 514.0
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

func draw_avatar_picker(game) -> void:
	var screen: Vector2 = game.get_viewport_rect().size
	var panel: Rect2 = panel_rect(game)
	avatar_catalog.load_decoration(game)
	game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#091e19"))
	if avatar_catalog.background != null:
		game.draw_texture_rect(avatar_catalog.background, Rect2(Vector2.ZERO, screen), false)
	line(game, "TWÓJ AWATAR", 42, 28)
	line(game, "Wybierz jeden z 30 portretów", 76, 17)
	var preview := Rect2(panel.position + Vector2(panel.size.x * 0.5 - 76, 94), Vector2(152, 152))
	avatar_catalog.draw_portrait(game, pending_avatar, preview, true)
	line(game, AVATAR_NAMES[AVATARS.find(pending_avatar)], 263, 20)
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
	line(game, "%d / 5" % (avatar_page + 1), 590, 16)
	line(game, "Portret możesz później zmienić w menu.", 548, 13)
	game.draw_button(primary_rect(game), "WYRUSZ W PRZYGODĘ" if stage == "avatar" else "ZAPISZ AWATAR", true, 16)
	if stage == "avatar_edit":
		game.draw_button(secondary_rect(game), "ANULUJ", true, 14)

func draw_choice(game, index: int, hero_id: String, label: String, selected: bool) -> void:
	var rect: Rect2 = choice_rect(game, index)
	if stage == "companion":
		var circle_rect := Rect2(rect.position, Vector2(rect.size.x, rect.size.x))
		game.draw_circle(circle_rect.get_center(), circle_rect.size.x * 0.49, Color("#071c17cc") if not selected else Color("#4d3b19dd"))
		avatar_catalog.draw_portrait(game, hero_id, circle_rect, selected)
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
	# Po pierwszym zwycięstwie pokazujemy jeszcze jedną, krótką podpowiedź
	# dotyczącą silniejszych kombinacji na poziomie 2.
	return (game.level_index == 0 and not game.tutorial_completed) or game.level_index == 1

func tutorial_text(game) -> String:
	if game.level_index == 1:
		return "Połącz 4 lub 5 znaków albo ułóż kwadrat, aby zadać przeciwnikowi więcej obrażeń."
	if tutorial_moves == 0:
		return "Zamień podświetlone znaki, aby połączyć co najmniej 3."
	if tutorial_moves == 1:
		return "Ogień i runy atakują. Pokonaj Cień mchu, aby wygrać."
	if tutorial_moves == 2:
		return "Woda leczy, liście dają tarczę. Nietrafiony ruch nie wywołuje ataku."
	return "Zbieraj ogień i runy, by odebrać wrogowi całe zdrowie."

func draw_tutorial(game) -> void:
	var screen: Vector2 = game.get_viewport_rect().size
	var panel := Rect2(20, 226, screen.x - 40, 114)
	if game.tutorial_tooltip_banner != null:
		game.draw_texture_rect(game.tutorial_tooltip_banner, panel, false)
	elif game.turn_banner_oak != null:
		game.draw_texture_rect(game.turn_banner_oak, panel, false, Color(0.92, 0.98, 0.9, 1.0))
	else:
		game.draw_style_box(game.make_panel(Color("#09251fd9"), Color("#d4ad5e")), panel)
	var heading := "PODPOWIEDŹ • POZIOM 2" if game.level_index == 1 else "SAMOUCZEK • KROK %d/4" % mini(tutorial_moves + 1, 4)
	game.draw_string(game.font, Vector2(panel.position.x, panel.position.y + 53), heading, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 13, Color("#f5d998"))
	game.draw_multiline_string(game.font, Vector2(panel.position.x + 12, panel.position.y + 71), tutorial_text(game), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 24, 14, 19, Color("#ffe7a3"))
