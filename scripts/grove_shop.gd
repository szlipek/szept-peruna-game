extends RefCounted

# Oferty premium są katalogiem do podłączenia do płatności platformy.
# Ten widok nigdy nie przyznaje płatnych pakietów bez potwierdzonego zakupu.
const PREMIUM := [
	{"id": "first_journey", "title": "PIERWSZA WYPRAWA", "description": "Dobry początek przygody", "price": "9,99 zł", "art": "chest", "rewards": {"coins": 1500, "wood": 150, "experience": 300}},
	{"id": "amber_treasure", "title": "SKARB BURSZTYNU", "description": "Zapas na rozwój osady", "price": "19,99 zł", "art": "coins", "rewards": {"coins": 5000, "wood": 400}},
	{"id": "perun_power", "title": "MOC PERUNA", "description": "Iskry i doświadczenie", "price": "24,99 zł", "art": "sparks", "rewards": {"sparks": 8, "experience": 600}},
	{"id": "remove_ads", "title": "SPOKÓJ GAJU", "description": "Wyłączenie reklam przerywających grę", "price": "19,99 zł", "art": "leaf", "rewards": {}, "entitlement": "remove_ads"}
]
const SUPPLIES := [
	{"id": "wood_small", "title": "WIĄZKA DREWNA", "description": "Materiały do rozbudowy", "cost": 200, "art": "wood", "rewards": {"wood": 80}},
	{"id": "experience_small", "title": "NAUKA PRZODKÓW", "description": "PD dla wybranej drużyny", "cost": 250, "art": "experience", "rewards": {"experience": 100}},
	{"id": "wood_large", "title": "ZAPASY OSADY", "description": "Duży zapas materiałów", "cost": 550, "art": "wood", "rewards": {"wood": 250}},
	{"id": "experience_large", "title": "MĄDROŚĆ GAJU", "description": "PD dla wybranej drużyny", "cost": 800, "art": "experience", "rewards": {"experience": 400}}
]
var opened := false
var tab := 0
var pending_index := -1
var notice := ""
var icon: Texture2D
var first_journey_art: Texture2D
var art_bounds := {}

func visible_art_bounds(texture: Texture2D) -> Rect2:
	var key := texture.get_instance_id()
	if not art_bounds.has(key):
		var used := texture.get_image().get_used_rect()
		art_bounds[key] = Rect2(used) if used.has_area() else Rect2(Vector2.ZERO, texture.get_size())
	return art_bounds[key]

func draw_offer_art(game, texture: Texture2D, target: Rect2) -> void:
	var source := visible_art_bounds(texture)
	var scale := minf(target.size.x / source.size.x, target.size.y / source.size.y)
	var size := source.size * scale
	game.draw_texture_rect_region(texture, Rect2(target.get_center() - size * 0.5, size), source)

func load_assets(game) -> void:
	if icon == null:
		icon = game.load_image_texture("res://art/ui/shop_navigation_icon_v01.png")
	if first_journey_art == null:
		first_journey_art = game.load_image_texture("res://art/ui/shop_first_journey_v01.png")

func open(game) -> void:
	load_assets(game)
	opened = true
	tab = 0
	pending_index = -1
	notice = ""
	game.main_menu_open = false
	game.queue_redraw()

func close(game) -> void:
	opened = false
	pending_index = -1
	game.main_menu_open = true
	game.queue_redraw()

func tab_rect(game, index: int) -> Rect2:
	var width: float = (game.get_viewport_rect().size.x - 64.0) * 0.5
	return Rect2(26.0 + index * (width + 12.0), 193.0, width, 55.0)

func card_rect(game, index: int) -> Rect2:
	var width: float = (game.get_viewport_rect().size.x - 58.0) * 0.5
	return Rect2(22.0 + (index % 2) * (width + 14.0), 245.0 + int(index / 2) * 288.0, width, 278.0)

func buy_rect(game, index: int) -> Rect2:
	var card := card_rect(game, index)
	return Rect2(card.position.x + 17.0, card.end.y - 63.0, card.size.x - 34.0, 54.0)

func back_rect(game) -> Rect2:
	var screen: Vector2 = game.get_viewport_rect().size
	return Rect2(screen.x * 0.5 - 115.0, screen.y - 86.0, 230.0, 62.0)

func confirm_panel(game) -> Rect2:
	var screen: Vector2 = game.get_viewport_rect().size
	return Rect2(24.0, screen.y * 0.5 - 170.0, screen.x - 48.0, 340.0)

func confirm_rect(game) -> Rect2:
	var panel := confirm_panel(game)
	return Rect2(panel.get_center().x - 135.0, panel.end.y - 100.0, 270.0, 62.0)

func cancel_rect(game) -> Rect2:
	var panel := confirm_panel(game)
	return Rect2(panel.get_center().x - 95.0, panel.end.y - 43.0, 190.0, 35.0)

func handle_input(game, position: Vector2) -> void:
	if pending_index >= 0:
		if confirm_rect(game).has_point(position):
			purchase_supply(game, pending_index)
			pending_index = -1
		elif cancel_rect(game).has_point(position):
			pending_index = -1
		game.queue_redraw()
		return
	if back_rect(game).has_point(position):
		close(game)
		return
	for index in 2:
		if tab_rect(game, index).has_point(position):
			tab = index
			notice = ""
			game.queue_redraw()
			return
	for index in 4:
		if buy_rect(game, index).has_point(position):
			if tab == 0:
				notice = "Zakupy premium są jeszcze niedostępne."
			elif game.coins < int(SUPPLIES[index]["cost"]):
				notice = "Brakuje %d monet." % (int(SUPPLIES[index]["cost"]) - game.coins)
			else:
				pending_index = index
			game.queue_redraw()
			return

func purchase_supply(game, index: int) -> bool:
	if index < 0 or index >= SUPPLIES.size():
		return false
	var offer: Dictionary = SUPPLIES[index]
	var cost := int(offer["cost"])
	if game.coins < cost:
		notice = "Brakuje monet na ten zakup."
		return false
	var reward: Dictionary = offer["rewards"]
	game.coins -= cost
	game.wood += int(reward.get("wood", 0))
	var xp := int(reward.get("experience", 0))
	game.experience += xp
	if xp > 0:
		game.grant_hero_experience(xp)
	game.save_progress()
	game.play_sfx(760.0, 0.16, 0.18)
	notice = "Zakupiono: %s." % str(offer["title"]).to_lower()
	game.queue_redraw()
	return true

func draw(game) -> void:
	var screen: Vector2 = game.get_viewport_rect().size
	game.draw_main_menu_background(screen)
	game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#061511b8"))
	if icon != null:
		game.draw_texture_rect(icon, Rect2(20.0, 14.0, 105.0, 105.0), false)
	var subtitle := "Zaopatrz drużynę przed kolejną wyprawą"
	var text_x: float = (screen.x - game.font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x) * 0.5
	game.draw_string(game.font, Vector2(text_x, 78.0), "SKLEP GAJU", HORIZONTAL_ALIGNMENT_LEFT, screen.x - text_x - 20.0, 29, Color("#ffe4a3"))
	game.draw_string(game.font, Vector2(text_x, 117.0), subtitle, HORIZONTAL_ALIGNMENT_LEFT, screen.x - text_x - 20.0, 16, Color("#dce6c8"))
	var wallet_kinds := ["coins", "wood", "experience", "sparks"]
	var wallet_values := [game.coins, game.wood, game.experience, game.perun_sparks]
	var wallet_width := 0.0
	for index in wallet_kinds.size():
		wallet_width += game.resource_amount_width(int(wallet_values[index]), 26.0, 16)
	wallet_width += 26.0 * (wallet_kinds.size() - 1)
	var wallet_x: float = (screen.x - wallet_width) * 0.5
	for index in wallet_kinds.size():
		wallet_x += game.draw_resource_amount(Vector2(wallet_x, 143.0), wallet_kinds[index], int(wallet_values[index]), 26.0, 16, Color("#ffe4a3")) + 26.0
	for index in 2:
		var target := tab_rect(game, index)
		var selected := tab == index
		var art_target := target
		if selected:
			art_target.position.y -= 2.0
		var tab_texture: Texture2D = game.roster_tabs_active_v04 if selected else game.roster_tabs_inactive_v04
		if tab_texture != null:
			# Obie ramki dostają ten sam widoczny obszar i wspólną oś pionową.
			game.draw_texture_rect_region(tab_texture, art_target, visible_art_bounds(tab_texture))
		else:
			game.draw_style_box(game.make_panel(Color("#946025") if selected else Color("#12372a"), Color("#dbb462")), art_target)
		var label_y := target.get_center().y + 7.0
		game.draw_string(game.font, Vector2(target.position.x, label_y), "PAKIETY PREMIUM" if index == 0 else "ZA MONETY", HORIZONTAL_ALIGNMENT_CENTER, target.size.x, 16, Color("#fff0c7") if selected else Color("#c8d2c0"))
	var offers: Array = PREMIUM if tab == 0 else SUPPLIES
	for index in offers.size():
		var offer: Dictionary = offers[index]
		var card := card_rect(game, index)
		if game.village_inspector_frame != null:
			game.draw_texture_rect(game.village_inspector_frame, card, false)
		else:
			game.draw_style_box(game.make_panel(Color("#102b23eb"), Color("#b68b4a")), card)
		var art_rect := Rect2(card.get_center().x - 35.0, card.position.y + 50.0, 70.0, 70.0)
		var art_key := str(offer["art"])
		if art_key == "chest" and first_journey_art != null:
			draw_offer_art(game, first_journey_art, art_rect)
		else:
			var texture: Texture2D = game.leaf_tile_icon if art_key == "leaf" else game.resource_icon(art_key)
			if texture != null:
				draw_offer_art(game, texture, art_rect)
		game.draw_string(game.font, Vector2(card.position.x + 20.0, card.position.y + 131.0), str(offer["title"]), HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 40.0, 16, Color("#ffe4a3"))
		var rewards: Dictionary = offer["rewards"]
		var reward_labels: Array[String] = []
		if rewards.has("coins"): reward_labels.append("%d monet" % int(rewards["coins"]))
		if rewards.has("wood"): reward_labels.append("%d drewna" % int(rewards["wood"]))
		if rewards.has("experience"): reward_labels.append("%d PD drużyny" % int(rewards["experience"]))
		if rewards.has("sparks"): reward_labels.append("%d Iskier Peruna" % int(rewards["sparks"]))
		var details := " • ".join(reward_labels) if not reward_labels.is_empty() else str(offer["description"])
		if str(offer["id"]) == "first_journey":
			details = "%d monet • %d drewna\n%d PD drużyny" % [int(rewards["coins"]), int(rewards["wood"]), int(rewards["experience"])]
		if str(offer["id"]) == "perun_power":
			details = "%d PD drużyny\n%d Iskier Peruna" % [int(rewards["experience"]), int(rewards["sparks"])]
		game.draw_multiline_string(game.font, Vector2(card.position.x + 18.0, card.position.y + 157.0), details, HORIZONTAL_ALIGNMENT_CENTER, card.size.x - 36.0, 14, 2, Color("#dce6c8"))
		if tab == 0:
			game.draw_string(game.font, Vector2(card.position.x, card.position.y + 203.0), "Planowana cena: %s" % str(offer["price"]), HORIZONTAL_ALIGNMENT_CENTER, card.size.x, 13, Color("#dec78e"))
			game.draw_button(buy_rect(game, index), "WKRÓTCE", false, 15)
		else:
			var affordable: bool = game.coins >= int(offer["cost"])
			game.draw_button(buy_rect(game, index), "KUP • %d MONET" % int(offer["cost"]), affordable, 15)
	var footer := notice if notice != "" else ("Zakupy premium są jeszcze niedostępne." if tab == 0 else "PD z zakupów trafiają do wybranej drużyny.")
	game.draw_multiline_string(game.font, Vector2(26.0, 844.0), footer, HORIZONTAL_ALIGNMENT_CENTER, screen.x - 52.0, 16, 20, Color("#e1d4ae"))
	game.draw_button(back_rect(game), "POWRÓT", true, 17)
	if pending_index >= 0:
		game.draw_rect(Rect2(Vector2.ZERO, screen), Color("#04100ddd"))
		var panel := confirm_panel(game)
		if game.home_party_panel != null:
			game.draw_texture_rect(game.home_party_panel, panel, false)
		var offer: Dictionary = SUPPLIES[pending_index]
		game.draw_string(game.font, Vector2(panel.position.x, panel.position.y + 65.0), "POTWIERDŹ ZAKUP", HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 24, Color("#ffe4a3"))
		game.draw_string(game.font, Vector2(panel.position.x, panel.position.y + 117.0), str(offer["title"]), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 20, Color("#e1ebd0"))
		game.draw_string(game.font, Vector2(panel.position.x, panel.position.y + 161.0), "Koszt: %d monet" % int(offer["cost"]), HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, 18, Color("#ffe4a3"))
		game.draw_button(confirm_rect(game), "KUP", true, 18)
		game.draw_button(cancel_rect(game), "ANULUJ", true, 15)
