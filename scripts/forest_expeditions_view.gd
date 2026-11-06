extends RefCounted

const IDS := ["polana", "obrona", "karawana", "korzenie", "straz", "noc"]
const LIST_TOP := 182.0
const CARD_HEIGHT := 108.0
const CARD_STEP := 116.0
const FOOTER_SPACE := 82.0

var illustrations: Array[Texture2D] = []
var card_frame: Texture2D
var lock_icon: Texture2D

func load_art(loader: Callable) -> void:
	for id in IDS:
		illustrations.append(loader.call("res://art/environments/expeditions/expedition_%s_v01.png" % id))
	card_frame = loader.call("res://art/ui/tutorial_tooltip_banner_v01.png")
	lock_icon = loader.call("res://art/ui/expedition_lock_icon_v01.png")

func card_rect(screen: Vector2, index: int, scroll: float) -> Rect2:
	return Rect2(20.0, LIST_TOP + index * CARD_STEP - scroll, screen.x - 40.0, CARD_HEIGHT)

func scroll_max(screen: Vector2, count: int) -> float:
	return maxf(0.0, count * CARD_STEP - 8.0 - (screen.y - FOOTER_SPACE - LIST_TOP))

func card_visible(screen: Vector2, card: Rect2) -> bool:
	return card.position.y >= LIST_TOP - 0.5 and card.end.y <= screen.y - FOOTER_SPACE + 0.5

func draw(game: Node2D, screen: Vector2) -> void:
	var backdrop: Texture2D = game.oak_borderland_background
	if backdrop != null:
		game.draw_texture_rect(backdrop, Rect2(Vector2.ZERO, screen), false)
	game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#071b13a0"))
	var heading := Rect2(12.0, 5.0, screen.x - 24.0, 106.0)
	if game.village_goal_plaque != null:
		game.draw_texture_rect(game.village_goal_plaque, heading, false)
	game.draw_string(game.font, Vector2(24.0, 67.0), "WYPRAWY LEŚNE", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 48.0, 25 if screen.x >= 430.0 else 22, Color("#ffe3a0"))
	game.draw_string(game.font, Vector2(20.0, 116.0), "Drewno dla osady · bez energii · bez limitu prób", HORIZONTAL_ALIGNMENT_CENTER, screen.x - 40.0, 12 if screen.x >= 430.0 else 11, Color("#f0ead3"))
	var bonus_width := minf(448.0, screen.x - 32.0)
	var bonus := Rect2((screen.x - bonus_width) * 0.5, 123.0, bonus_width, 48.0)
	if game.village_mastery_plaque != null:
		var bonus_art := Rect2(bonus.position - Vector2(0.0, 10.0), bonus.size + Vector2(0.0, 20.0))
		game.draw_texture_rect(game.village_mastery_plaque, bonus_art, false)
	game.draw_string(game.font, bonus.position + Vector2(29.0, 28.0), "×2", HORIZONTAL_ALIGNMENT_CENTER, 48.0, 19, Color("#ffe49d"))
	game.draw_string(game.font, bonus.position + Vector2(68.0, 23.0), "DZIENNY BONUS DREWNA", HORIZONTAL_ALIGNMENT_CENTER, bonus_width - 104.0, 11, Color("#ffe5a8"))
	game.draw_string(game.font, bonus.position + Vector2(68.0, 37.0), "Pierwsze zwycięstwo w każdej wyprawie", HORIZONTAL_ALIGNMENT_CENTER, bonus_width - 104.0, 11 if screen.x >= 430.0 else 9, Color("#e8d9b7"))
	var catalog: Array = game.training_catalog()
	for index in catalog.size():
		var card := card_rect(screen, index, game.training_scroll)
		if card_visible(screen, card):
			draw_card(game, card, catalog[index], index)
	var maximum := scroll_max(screen, catalog.size())
	if maximum > 0.0:
		var track := Rect2(screen.x - 10.0, LIST_TOP + 7.0, 3.0, screen.y - FOOTER_SPACE - LIST_TOP - 14.0)
		game.draw_style_box(game.make_panel(Color("#07170bb0"), Color("#766035")), track)
		var thumb_height := track.size.y * (screen.y - FOOTER_SPACE - LIST_TOP) / (catalog.size() * CARD_STEP - 8.0)
		var thumb_y := track.position.y + (track.size.y - thumb_height) * clampf(game.training_scroll / maximum, 0.0, 1.0)
		game.draw_style_box(game.make_panel(Color("#d3ae60"), Color("#e8cf91")), Rect2(track.position.x - 1.0, thumb_y, 5.0, thumb_height))
	game.draw_roster_action_button(game.training_close_rect(), "WRÓĆ DO OSADY", true)

func draw_card(game: Node2D, card: Rect2, mission: Dictionary, index: int) -> void:
	var locked: bool = game.training_choice_locked(mission)
	if card_frame != null:
		# Reuse the battle/tutorial oak vines and forest-green surface.
		var source := Rect2(card_frame.get_size() * Vector2(0.0, 0.11), card_frame.get_size() * Vector2(1.0, 0.76))
		game.draw_texture_rect_region(card_frame, card, source, Color("#c2c0a9") if locked else Color.WHITE)
	else:
		game.draw_style_box(game.make_panel(Color("#10271f"), Color("#b78e4c")), card)
	var picture := Rect2(card.position + Vector2(card.size.x * 0.032, 14.0), Vector2(card.size.x * 0.228, card.size.y - 28.0))
	if index < illustrations.size() and illustrations[index] != null:
		var art := illustrations[index]
		var source_size := art.get_size()
		var crop_size := source_size
		var aspect := picture.size.x / picture.size.y
		if source_size.x / source_size.y > aspect:
			crop_size.x = source_size.y * aspect
		else:
			crop_size.y = source_size.x / aspect
		game.draw_texture_rect_region(art, picture, Rect2((source_size - crop_size) * 0.5, crop_size), Color("#a3b0a0") if locked else Color.WHITE)
	var text_x := card.position.x + card.size.x * 0.29 + 9.0
	var text_width := card.end.x - text_x - 19.0
	var title_size := 18
	while title_size > 14 and game.font.get_string_size(str(mission["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, title_size).x > text_width:
		title_size -= 1
	game.draw_string(game.font, Vector2(text_x, card.position.y + 33.0), str(mission["name"]), HORIZONTAL_ALIGNMENT_LEFT, text_width, title_size, Color("#ddd0b0") if locked else Color("#ffe3a7"))
	draw_wrapped(game, str(mission["mechanic"]), Vector2(text_x, card.position.y + 51.0), text_width, 11, Color("#bdbca5") if locked else Color("#e9e0c7"))
	if locked:
		draw_lock(game, Vector2(text_x + 8.0, card.end.y - 29.0))
		game.draw_string(game.font, Vector2(text_x + 29.0, card.end.y - 22.0), "Dwór Wiecowy · poziom %d" % int(mission["hall"]), HORIZONTAL_ALIGNMENT_LEFT, text_width - 29.0, 12 if text_width > 225.0 else 11, Color("#d6bb7b"))
		return
	var bonus_available: bool = str(game.expedition_bonus_claims.get(str(mission["id"]), "")) != Time.get_date_string_from_system()
	var reward: Dictionary = game.ForestExpeditions.effective_reward(mission, bonus_available)
	var reward_x: float = text_x
	var amount_width: float = game.draw_resource_amount(Vector2(reward_x, card.end.y - 39.0), "wood", int(reward["wood"]), 26.0, 15, Color("#ffe3a0"))
	if bonus_available:
		game.draw_string(game.font, Vector2(reward_x + amount_width + 5.0, card.end.y - 20.0), "×2", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#e4c776"))
	var button_width := clampf(text_width - 94.0, 128.0, 154.0)
	var action := Rect2(card.end.x - button_width - 13.0, card.end.y - 54.0, button_width, 50.0)
	if game.roster_action_button != null:
		game.draw_texture_rect(game.roster_action_button, action, false)
		game.draw_string(game.font, Vector2(action.position.x, action.get_center().y + 6.0), "WYRUSZ", HORIZONTAL_ALIGNMENT_CENTER, action.size.x, 16, Color("#fff1bd"))
	else:
		game.draw_button(action, "WYRUSZ", true, 16)

func draw_wrapped(game: Node2D, text: String, position: Vector2, width: float, size: int, color: Color) -> void:
	var line := ""
	var row := 0
	for word in text.split(" "):
		var candidate := word if line.is_empty() else line + " " + word
		if not line.is_empty() and game.font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width:
			game.draw_string(game.font, position + Vector2(0.0, row * 14.0), line, HORIZONTAL_ALIGNMENT_LEFT, width, size, color)
			line = word
			row += 1
		else:
			line = candidate
	game.draw_string(game.font, position + Vector2(0.0, row * 14.0), line, HORIZONTAL_ALIGNMENT_LEFT, width, size, color)

func draw_lock(game: Node2D, center: Vector2) -> void:
	if lock_icon != null:
		game.draw_texture_rect(lock_icon, Rect2(center - Vector2(16.0, 16.0), Vector2(32.0, 32.0)), false)
