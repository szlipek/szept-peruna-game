extends SceneTree

const GameAudio = preload("res://scripts/game_audio.gd")

class Fixture:
	extends "res://scripts/puzzle_level.gd"
	func _ready() -> void:
		set_process(false)
	func _draw() -> void:
		pass
	func save_progress() -> void:
		pass

class FeedbackFixture:
	extends Fixture
	var pulses: Array[int] = []
	var snapshot := ConfigFile.new()
	func save_progress() -> void:
		save_audio_settings(snapshot)
	func send_handheld_vibration(duration_ms: int) -> void:
		pulses.append(duration_ms)
	func animate_swap(_a: Vector2i, _b: Vector2i) -> void:
		pass
	func find_matches() -> Dictionary:
		return {}

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var game := Fixture.new()
	root.add_child(game)
	var audio := GameAudio.new()
	game.add_child(audio)
	game.game_audio = audio
	audio.setup()
	assert(audio.music_streams.size() == 2)
	assert(audio.effects.size() == 45 if OS.has_feature("editor") else audio.effects.is_empty())
	assert(audio.sting_streams.size() == 3)
	assert(absf(audio.music_streams["menu"].get_length() - 64.0) < .05)
	assert(absf(audio.music_streams["battle"].get_length() - 80.0) < .05)
	for stream in audio.music_streams.values():
		assert(stream.loop)
	for stream in audio.sting_streams.values():
		assert(not stream.loop and stream.get_length() >= 2.0 and stream.get_length() <= 5.05)
	game.main_menu_open = true
	game.update_game_audio()
	assert(audio.current_music == "menu")
	audio._process(1.0)
	assert(audio.music_players[audio.active_player].playing)
	var menu_player: int = audio.active_player
	game.update_game_audio()
	assert(audio.active_player == menu_player)
	game.main_menu_open = false
	game.state = "playing"
	game.player_opening.stage = ""
	game.update_game_audio()
	assert(audio.current_music == "battle" and audio.active_player != menu_player)
	audio._process(1.0)
	assert(not audio.music_players[menu_player].playing)
	game.village_open = true
	game.update_game_audio()
	assert(audio.current_music == "menu")
	game.village_open = false
	game.victory_screen_open = true
	game.update_game_audio()
	assert(audio.current_music == "menu")
	game.victory_screen_open = false
	if not audio.effects.is_empty():
		for effect_name in audio.effects:
			assert(audio.play_effect(effect_name))
			assert(audio.effects[effect_name].mix_rate == 44100)
		for hero_id in game.HERO_IDS:
			assert(audio.can_play_effect(audio.hero_attack_event(hero_id)))
			assert(audio.can_play_effect(game.hero_skill_audio_event(hero_id)))
		assert(audio.effect_groups["tile_cascade"].size() == 4)
		assert(audio.effect_groups["hero_attack"].size() == 4)
		assert(audio.effect_groups["hit_impact"].size() == 3)
		audio.play_effect("tile_cascade")
		var first_variant: int = audio.last_variant["tile_cascade"]
		audio.last_played.erase("tile_cascade")
		audio.play_effect("tile_cascade")
		assert(int(audio.last_variant["tile_cascade"]) != first_variant)
		assert(audio.effect_players.size() == 8)
		assert(audio.play_effect("heal")) # Cooldown consumes the duplicate.
	assert(audio.play_effect("victory_sting"))
	assert(audio.duck_remaining > 3.9)
	audio.queue_effect("resource_coin", 1.3)
	assert(audio.pending_effects.size() == 1)
	game.sfx_enabled = false
	game.update_game_audio()
	assert(audio.music_players[audio.active_player].playing)
	for player in audio.effect_players:
		assert(not player.playing)
	assert(not audio.play_effect("ui_click"))
	assert(audio.pending_effects.is_empty() and audio.duck_remaining == 0.0)
	game.music_enabled = false
	game.sfx_enabled = true
	game.update_game_audio()
	for player in audio.music_players:
		assert(not player.playing)
	assert(audio.play_effect("victory_sting"))
	game.sfx_enabled = false
	game.update_game_audio()
	for player in audio.music_players + audio.effect_players:
		assert(not player.playing)
	game.music_enabled = true
	game.sfx_enabled = true
	game.update_game_audio()
	assert(audio.current_music == "battle")
	assert(not audio.play_effect("missing"))
	# Same music + procedural fallback when preview effects are unavailable.
	var release_audio := GameAudio.new()
	game.add_child(release_audio)
	release_audio.setup(false)
	assert(release_audio.effects.is_empty() and release_audio.music_streams.size() == 2)
	assert(release_audio.sting_streams.size() == 3)
	assert(release_audio.play_effect("defeat_sting"))
	game.game_audio = release_audio
	game.setup_procedural_sfx()
	game.play_audio_event("hit_impact", 235.0, 0.1, 0.18)
	assert(game.sfx_remaining_frames > 0)
	game.sfx_remaining_frames = 0
	game.sfx_enabled = false
	game.play_audio_event("hit_impact", 235.0, 0.1, 0.18)
	assert(game.sfx_remaining_frames == 0)
	var preset := ConfigFile.new()
	assert(preset.load("res://export_presets.cfg") == OK)
	assert(str(preset.get_value("preset.0", "exclude_filter")).contains("art/audio/generated_preview/*"))
	assert(str(preset.get_value("preset.0", "exclude_filter")).contains("art/audio/generated_complete/*"))
	var feedback := FeedbackFixture.new()
	root.add_child(feedback)
	feedback.handle_main_menu_input(feedback.settings_button_rect().get_center())
	assert(feedback.help_open and feedback.settings_open)
	feedback.settings_open = false
	feedback.help_open = true
	feedback.handle_help_input(feedback.sound_toggle_rect().get_center())
	assert(feedback.settings_open)
	feedback.handle_help_input(feedback.music_toggle_rect().get_center())
	assert(not feedback.music_enabled and feedback.sfx_enabled)
	feedback.handle_help_input(feedback.sound_toggle_rect().get_center())
	assert(not feedback.sfx_enabled and not feedback.music_enabled)
	feedback.handle_help_input(feedback.vibration_toggle_rect().get_center())
	assert(not feedback.vibration_enabled)
	var saved := Fixture.new()
	root.add_child(saved)
	saved.load_audio_settings(feedback.snapshot)
	assert(not saved.sfx_enabled and not saved.music_enabled and not saved.vibration_enabled)
	var legacy := ConfigFile.new()
	legacy.set_value("settings", "sfx_enabled", false)
	saved.load_audio_settings(legacy)
	assert(not saved.music_enabled and not saved.sfx_enabled and saved.vibration_enabled)
	for viewport_size in [Vector2i(540, 960), Vector2i(390, 844), Vector2i(360, 640)]:
		root.size = viewport_size
		root.content_scale_size = viewport_size
		await process_frame
		var screen := Rect2(Vector2.ZERO, Vector2(viewport_size))
		var controls := [feedback.sound_toggle_rect(), feedback.music_toggle_rect(), feedback.vibration_toggle_rect(), feedback.settings_guide_rect(), feedback.help_close_rect()]
		for index in controls.size():
			assert(screen.encloses(controls[index]))
			for other in range(index + 1, controls.size()):
				assert(not controls[index].intersects(controls[other]))
	feedback.board = []
	feedback.special_tiles = []
	for row in 8:
		feedback.board.append([])
		feedback.special_tiles.append([])
		for col in 8:
			feedback.board[row].append((row + col) % 5)
			feedback.special_tiles[row].append(0)
	var before: Array = feedback.board.duplicate(true)
	await feedback.try_swap(Vector2i(0, 0), Vector2i(1, 0))
	assert(feedback.pulses.is_empty())
	feedback.vibration_enabled = true
	await feedback.try_swap(Vector2i(0, 0), Vector2i(1, 0))
	assert(feedback.pulses == [55] and feedback.board == before and feedback.battle_moves == 0)
	feedback.vibrate_invalid_move()
	assert(feedback.pulses.size() == 1)
	saved.free()
	feedback.free()
	audio.update_context(false, false, false)
	release_audio.update_context(false, false, false)
	game.sfx_player.stop()
	game.queue_free()
	await process_frame
	await process_frame
	await create_timer(0.1).timeout # Let the audio mixer release stopped playbacks.
	print("PASS: audio assets and routing; independent sound/music/vibration switches; persisted settings and legacy migration; three viewport layouts; invalid-swap 55 ms haptic, cooldown and disabled haptics.")
	quit()
