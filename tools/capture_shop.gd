extends SceneTree

class Preview:
	extends "res://scripts/puzzle_level.gd"

	func _ready() -> void:
		font = preload("res://scripts/game_typography.gd").create_font()
		oak_borderland_background = load_image_texture("res://art/environments/environment_debowe_pogranicze_v01.png")
		village_inspector_frame = load_image_texture("res://art/ui/village_inspector_frame_v01.png")
		home_party_panel = load_image_texture("res://art/ui/home_party_panel_v01.png")
		home_navigation_frame = load_image_texture("res://art/ui/home_navigation_frame_v02.png")
		home_navigation_icons = load_image_texture("res://art/ui/home_navigation_icons_v01.png")
		battle_header_oak = load_image_texture("res://art/ui/battle_header_oak_v01.png")
		roster_action_button = load_image_texture("res://art/ui/roster_action_button_v01.png")
		roster_tabs_active_v04 = load_image_texture("res://art/ui/roster_tabs_active_v04.png")
		roster_tabs_inactive_v04 = load_image_texture("res://art/ui/roster_tabs_inactive_v04.png")
		button_oak = load_image_texture("res://art/vfx/button_oak_v01.png")
		home_reward_chests = load_image_texture("res://art/ui/home_reward_chests_v01.png")
		coin_resource_icon = load_image_texture("res://art/ui/icon_coin_oak_v01.png")
		wood_resource_icon = load_image_texture("res://art/ui/icon_wood_oak_v01.png")
		experience_resource_icon = load_image_texture("res://art/ui/icon_xp_oak_v01.png")
		perun_sparks_resource_icon = load_image_texture("res://art/ui/icon_perun_sparks_v01.png")
		leaf_tile_icon = load_image_texture("res://art/tiles/tile_leaf_v01.png")
		coins = 1250
		wood = 180
		sfx_enabled = false
		player_opening.stage = ""
		grove_shop.open(self)
		set_process(false)
		set_process_unhandled_input(false)

	func save_progress() -> void:
		pass

	func _draw() -> void:
		if grove_shop.opened:
			grove_shop.draw(self)
		else:
			draw_main_menu(get_viewport_rect().size)

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(540, 960)
	var game := Preview.new()
	root.add_child(game)
	for page in 3:
		game.grove_shop.tab = mini(page, 1)
		game.grove_shop.pending_index = 0 if page == 2 else -1
		game.queue_redraw()
		for frame in 3:
			await process_frame
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://.godot/shop-preview-%d.png" % page)
	game.grove_shop.pending_index = -1
	game.grove_shop.opened = false
	game.main_menu_open = true
	game.queue_redraw()
	for frame in 3:
		await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://.godot/shop-menu-preview.png")
	# Zakup za monety i brak środków: kontrolujemy portfel wyłącznie w pamięci.
	assert(game.grove_shop.purchase_supply(game, 0))
	assert(game.coins == 1050 and game.wood == 260)
	assert(game.grove_shop.purchase_supply(game, 1))
	assert(game.coins == 800 and game.hero_experience["lada"] == 100)
	game.coins = 0
	var previous_wood: int = game.wood
	assert(not game.grove_shop.purchase_supply(game, 0))
	assert(game.coins == 0 and game.wood == previous_wood)
	game.grove_shop.tab = 0
	game.grove_shop.handle_input(game, game.grove_shop.buy_rect(game, 0).get_center())
	assert(game.coins == 0 and game.grove_shop.pending_index == -1)
	print("Podglądy sklepu zapisane. Zakupy za monety i blokada premium: OK.")
	quit(0)
