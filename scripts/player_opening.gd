extends RefCounted

## Profil jest kosmetyczny; wybór portretu nie rekrutuje bohatera.
const AvatarCatalog = preload("res://scripts/avatar_catalog.gd")
const AVATARS = AvatarCatalog.IDS
const AVATAR_NAMES = AvatarCatalog.NAMES
const AVATARS_PER_PAGE := 10
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
		var width := (panel.size.x - 48) * 0.5
		return Rect2(panel.position + Vector2((panel.size.x - width) * 0.5, 560), Vector2(width, 64))
	return Rect2(panel.position + Vector2(24, 560), Vector2(panel.size.x - 48, 64))

func secondary_rect(game) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	if stage in ["avatar", "avatar_edit"]:
		var width := (panel.size.x - 48) * 0.5
		return Rect2(panel.position + Vector2((panel.size.x - width) * 0.5, 632), Vector2(width, 48))
	return Rect2(panel.position + Vector2(24, 632), Vector2(panel.size.x - 48, 48))

func choice_rect(game, index: int) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	if stage in ["avatar", "avatar_edit"]:
		var slot := index % AVATARS_PER_PAGE
		var spacing := (panel.size.x - 40) / 5.0
		var diameter := minf(86.0, spacing - 6.0)
		var center := panel.position + Vector2(20 + spacing * (slot % 5 + 0.5), 320 + int(slot / 5) * 104)
		return Rect2(center - Vector2.ONE * diameter * 0.5, Vector2.ONE * diameter)
	var width := (panel.size.x - 60) / 2.0
	var row := int(index / 2)
	return Rect2(panel.position + Vector2(24 + (index % 2) * (width + 12), 170 + row * 178), Vector2(width, 166))

func avatar_page_rect(game, direction: int) -> Rect2:
	var panel: Rect2 = panel_rect(game)
	return Rect2(panel.position + Vector2(42 if direction < 0 else panel.size.x - 86, 489), Vector2(44, 44))

func handle_input(game, position: Vector2) -> void:
	if stage == "intro":
		if primary_rect(game).has_point(position) or secondary_rect(game).has_point(position):
			stage = "avatar"
	elif stage in ["avatar", "avatar_edit"]:
		for direction in [-1, 1]:
			if avatar_page_rect(game, direction).has_point(position):
				avatar_page = posmod(avatar_page + direction, 3)
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

func draw(game) -> void:
	var screen: Vector2 = game.get_viewport_rect().size
	if stage in ["avatar", "avatar_edit"]:
		draw_avatar_picker(game)
		return
	game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#091e19"))
	var panel: Rect2 = panel_rect(game)
	game.draw_style_box(game.make_panel(Color("#18352e"), Color("#b38b4d")), panel)
	if stage == "intro":
		line(game, "SZEPT PERUNA", 60, 30)
		line(game, "Mgła ogarnia Dębowe Pogranicze.", 132)
		line(game, "Lada słyszy wołanie starego gaju.", 168)
		line(game, "Pomóż jej odnaleźć Leszego", 214)
		line(game, "i przywrócić światło osadzie.", 246)
		var portrait: Texture2D = game.hero_portraits.get("lada", null)
		if portrait != null:
			game.draw_texture_rect(portrait, game.texture_aspect_fit_rect(portrait, Rect2(panel.position + Vector2(panel.size.x / 2 - 90, 282), Vector2(180, 250))), false)
		game.draw_button(primary_rect(game), "ROZPOCZNIJ PRZYGODĘ", true)
		game.draw_button(secondary_rect(game), "POMIŃ WSTĘP", true, 14)
	elif stage == "companion":
		line(game, "PIERWSZE ZWYCIĘSTWO!", 60, 26)
		line(game, "Wybierz bezpłatnego towarzysza Lady.", 104, 17)
		line(game, "Dołączy od razu do Twojej drużyny.", 136, 16)
		draw_choice(game, 0, "brun", "Brun • ogień", selected_companion == "brun")
		draw_choice(game, 1, "mieta", "Mieta • woda", selected_companion == "mieta")
		line(game, "Brun rozbija kafelki obszarem 3×3.", 388, 17)
		line(game, "Mieta leczy drużynę mocą wody.", 422, 17)
		line(game, "Ich talenty rozwijasz wraz z poziomami.", 456, 16)
		line(game, "Drugi towarzysz dołączy po poziomie 5.", 494, 16)
		game.draw_button(primary_rect(game), "DOŁĄCZ DO DRUŻYNY", selected_companion != "")
	elif stage == "ready":
		line(game, "DRUŻYNA GOTOWA", 60, 26)
		line(game, "Lada i %s wyruszają razem." % ("Brun" if starter_companion == "brun" else "Mieta"), 156)
		line(game, "W menu DRUŻYNA zmienisz skład", 224)
		line(game, "i rozwiniesz talenty bohaterów.", 256)
		line(game, "Dalej: poziom 2 — Ślad w mchu.", 344)
		if not game.last_reward.is_empty():
			line(game, "Za pierwszą walkę otrzymujesz:", 420, 17)
			line(game, "%d monet • %d drewna • %d PD" % [int(game.last_reward.get("coins", 0)), int(game.last_reward.get("wood", 0)), int(game.last_reward.get("experience", 0))], 456, 17)
		else:
			line(game, "Nagrody za walkę są już w Twoim zapisie.", 420, 17)
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
		game.draw_circle(arrow_rect.get_center(), 20.0, Color("#102b24"))
		if avatar_catalog.selected_ring != null:
			game.draw_texture_rect(avatar_catalog.selected_ring, arrow_rect, false)
		game.draw_string(game.font, arrow_rect.position + Vector2(0, 30), "‹" if direction < 0 else "›", HORIZONTAL_ALIGNMENT_CENTER, arrow_rect.size.x, 28, Color("#ffe9ae"))
	line(game, "%d / 3" % (avatar_page + 1), 518, 16)
	line(game, "Portret możesz później zmienić w menu.", 548, 13)
	game.draw_button(primary_rect(game), "WYRUSZ Z LADĄ" if stage == "avatar" else "ZAPISZ AWATAR", true, 16)
	if stage == "avatar_edit":
		game.draw_button(secondary_rect(game), "ANULUJ", true, 14)

func draw_choice(game, index: int, hero_id: String, label: String, selected: bool) -> void:
	var rect: Rect2 = choice_rect(game, index)
	game.draw_style_box(game.make_panel(Color("#2d4937") if selected else Color("#10291f"), Color("#f0c96e") if selected else Color("#716342")), rect)
	var portrait: Texture2D = game.home_face_portrait(hero_id)
	if portrait != null:
		game.draw_texture_rect(portrait, Rect2(rect.get_center() - Vector2(52, 70), Vector2(104, 104)), false)
	game.draw_string(game.font, rect.position + Vector2(6, 138), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 12, 17, Color("#fff0c7"))
	if selected:
		game.draw_string(game.font, rect.position + Vector2(6, 158), "WYBRANO", HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 12, 11, Color("#f0c96e"))

func tutorial_active(game) -> bool:
	return stage == "" and not game.tutorial_completed and game.level_index == 0 and not game.training_mode and game.state == "playing"

func tutorial_text(game) -> String:
	if tutorial_moves == 0:
		return "Zamień podświetlone znaki, aby połączyć co najmniej 3."
	if tutorial_moves == 1:
		return "Ogień i runy atakują. Pokonaj Cień mchu, aby wygrać."
	if tutorial_moves == 2:
		return "Woda leczy, liście dają tarczę. Nietrafiony ruch nie wywołuje ataku."
	return "Zbieraj ogień i runy, by odebrać wrogowi całe zdrowie."

func draw_tutorial(game) -> void:
	var screen: Vector2 = game.get_viewport_rect().size
	game.draw_string(game.font, Vector2(28, 775), tutorial_text(game), HORIZONTAL_ALIGNMENT_CENTER, screen.x - 56, 13, Color("#ffe7a3"))
