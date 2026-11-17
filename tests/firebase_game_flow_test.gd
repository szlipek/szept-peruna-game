extends SceneTree

class Provider extends RefCounted:
	var analytics_on := false
	var crashes_on := false
	var privacy_required := true
	var privacy_opened := false
	var events: Array = []
	func setAnalyticsEnabled(value: bool) -> void:
		analytics_on = value
	func setCrashReportingEnabled(value: bool) -> void:
		crashes_on = value
	func isAdPrivacyOptionsRequired() -> bool:
		return privacy_required
	func showAdPrivacyOptions() -> void:
		privacy_opened = true
	func logGameEvent(event_name: String, payload: String) -> void:
		events.append([event_name, JSON.parse_string(payload)])

class Fixture extends "res://scripts/puzzle_level.gd":
	func _ready() -> void:
		set_process(false)
		levels = load_levels()
	func save_progress() -> void:
		pass
	func _draw() -> void:
		pass

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	root.size = Vector2i(540, 960)
	var game := Fixture.new()
	root.add_child(game)
	var provider := Provider.new()
	game.firebase_provider = provider
	game.game_analytics.initialize(provider, false)
	game.settings_open = true
	game.handle_help_input(game.analytics_toggle_rect().get_center())
	game.handle_help_input(game.crash_toggle_rect().get_center())
	assert(provider.analytics_on and provider.crashes_on)
	game.analytics_ready = true
	game.start_level(0)
	assert(provider.events.size() == 1 and provider.events[0][0] == "level_start")
	game.track_battle_end(false)
	assert(provider.events[1][0] == "level_end" and provider.events[1][1]["success"] == 0)
	game.handle_help_input(game.analytics_toggle_rect().get_center())
	game.track_battle_end(true)
	assert(not provider.analytics_on and provider.events.size() == 2)
	game.handle_help_input(game.crash_toggle_rect().get_center())
	assert(not provider.crashes_on)
	var ads = preload("res://scripts/game_ads.gd").new()
	game.add_child(ads)
	game.ads_manager = ads
	ads.initialized = true
	ads.rewarded_ready = true
	game.handle_help_input(game.ad_privacy_rect().get_center())
	assert(provider.privacy_opened and ads.suspended_for_privacy and not ads.rewarded_ready)
	for size in [Vector2i(540, 960), Vector2i(390, 844)]:
		root.size = size
		await process_frame
		assert(not game.crash_toggle_rect().intersects(game.settings_guide_rect()))
		assert(not game.settings_guide_rect().intersects(game.help_close_rect()))
		assert(not game.ad_privacy_rect().intersects(game.help_close_rect()))
	game.queue_free()
	print("Firebase game flow: OK")
	quit()
