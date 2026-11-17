extends SceneTree

class Fixture:
	extends "res://scripts/puzzle_level.gd"
	func _ready() -> void:
		set_process(false)
		levels = load_levels()
	func _draw() -> void:
		pass
	func save_progress() -> void:
		pass
	func play_audio_event(_event: String, _frequency := 0.0, _duration := 0.0, _volume := 0.0) -> void:
		pass

class FakeAds:
	extends Node
	var rewarded_ready := true
	var interstitial_available := true
	var reward_requests := 0
	var interstitial_requests := 0
	func show_rewarded() -> bool:
		reward_requests += 1
		return rewarded_ready
	func show_interstitial() -> bool:
		interstitial_requests += 1
		return interstitial_available

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var privacy_ads := preload("res://scripts/game_ads.gd").new()
	privacy_ads.initialized = true
	privacy_ads.interstitial_ready = true
	privacy_ads.rewarded_ready = true
	privacy_ads.suspend_for_privacy()
	assert(not privacy_ads.show_interstitial() and not privacy_ads.show_rewarded())
	privacy_ads._on_interstitial_loaded(null, null)
	privacy_ads._on_rewarded_loaded(null, null)
	assert(not privacy_ads.interstitial_ready and not privacy_ads.rewarded_ready)
	privacy_ads.free()
	root.size = Vector2i(540, 960)
	var game := Fixture.new()
	root.add_child(game)
	var ads := FakeAds.new()
	game.add_child(ads)
	game.ads_manager = ads
	game.level_index = 5
	game.state = "won"
	game.victory_screen_open = true
	game.current_battle = {}
	game.last_reward = {"coins": 200}
	game.coins = 0
	game.handle_release(game.victory_reward_rect().get_center())
	assert(ads.reward_requests == 1 and game.pending_rewarded_bonus)
	game.handle_release(game.victory_continue_rect().get_center())
	assert(game.victory_screen_open)
	game._on_rewarded_ad_completed()
	assert(game.coins == 100 and int(game.last_reward["coins"]) == 300)
	game._on_rewarded_ad_completed()
	assert(game.coins == 100 and not game.victory_reward_available())
	game._on_rewarded_ad_closed()
	game.campaign_wins_since_interstitial = game.WINS_BETWEEN_INTERSTITIALS
	game.handle_release(game.victory_continue_rect().get_center())
	assert(not game.victory_screen_open and game.main_menu_open)
	assert(ads.interstitial_requests == 1 and game.ad_interstitials_today == 0)
	game._on_interstitial_closed()
	assert(game.ad_interstitials_today == 0 and game.campaign_wins_since_interstitial == game.WINS_BETWEEN_INTERSTITIALS)
	game.show_victory_interstitial()
	game._on_interstitial_shown()
	game._on_interstitial_shown()
	assert(game.ad_interstitials_today == 1 and game.campaign_wins_since_interstitial == 0)
	game.campaign_wins_since_interstitial = game.WINS_BETWEEN_INTERSTITIALS
	game.ad_interstitials_today = game.MAX_INTERSTITIALS_PER_DAY
	game.show_victory_interstitial()
	assert(ads.interstitial_requests == 2)
	game.training_mode = true
	game.daily_ad_bonus_day = ""
	assert(not game.victory_reward_available())
	game.victory_screen_open = true
	game.handle_release(game.victory_continue_rect().get_center())
	assert(ads.interstitial_requests == 2)
	game.training_mode = false
	game.victory_screen_open = true
	game.ad_interstitials_today = 0
	ads.rewarded_ready = true
	game.handle_release(game.victory_reward_rect().get_center())
	game._on_rewarded_ad_closed()
	assert(game.coins == 100 and not game.pending_rewarded_bonus)
	ads.interstitial_available = false
	game.handle_release(game.victory_continue_rect().get_center())
	assert(not game.pending_victory_interstitial and game.ad_interstitials_today == 0)
	game.queue_free()
	print("Ads flow tests passed")
	quit()
