extends Node

const MUSIC_PATHS := {
	"menu": "res://art/audio/music/menu_grove_acestep_v01.ogg",
	"battle": "res://art/audio/music/battle_acestep_v01.ogg",
}
const PREVIEW_ROOT := "res://art/audio/generated_complete/sfx-preview/"
const EFFECT_NAMES := ["ui_click", "ui_confirm", "ui_back", "tile_swap", "match_3", "match_4_5", "hero_attack", "enemy_attack", "hit_impact", "heal", "skill_thunder", "resource_coin"]
const FADE_SECONDS := 0.8
const VOICES := 8
const CATALOG_PATH := "res://art/audio/music/catalog.json"

var music_streams := {}
var effects := {}
var effect_groups := {}
var sting_streams := {}
var last_variant := {}
var duck_remaining := 0.0
var pending_effects: Array[Dictionary] = []
var music_players: Array[AudioStreamPlayer] = []
var effect_players: Array[AudioStreamPlayer] = []
var gains: Array[float] = [0.0, 0.0]
var active_player := -1
var current_music := ""
var enabled := true
var music_enabled := true
var last_played := {}
var next_voice := 0
var variation := RandomNumberGenerator.new()

func setup(allow_preview_effects := true) -> void:
	variation.randomize()
	var catalog := {}
	if FileAccess.file_exists(CATALOG_PATH):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
		if parsed is Dictionary:
			catalog = parsed
	var music_paths: Dictionary = catalog.get("music", MUSIC_PATHS)
	for key in music_paths:
		var stream := load(music_paths[key]) as AudioStreamOggVorbis
		if stream != null:
			stream.loop = true
			music_streams[key] = stream
	for key in catalog.get("stings", {}):
		var stream := load(catalog["stings"][key]) as AudioStreamOggVorbis
		if stream != null:
			stream.loop = false
			sting_streams[key] = stream
	for ignored in 2:
		var player := AudioStreamPlayer.new()
		player.volume_db = -80.0
		add_child(player)
		music_players.append(player)
	for ignored in VOICES:
		var player := AudioStreamPlayer.new()
		player.volume_db = -10.0
		add_child(player)
		effect_players.append(player)
	# AudioLDM CC BY-NC-SA: raw preview files remain under .gdignore.
	# Exported templates cannot enable this path, including debug APKs.
	if allow_preview_effects and OS.has_feature("editor"):
		effect_groups = catalog.get("effect_groups", {})
		var files: Dictionary = catalog.get("effect_files", {})
		if files.is_empty():
			for effect_name in EFFECT_NAMES:
				files[effect_name] = PREVIEW_ROOT + effect_name + ".wav"
		for effect_name in files:
			var path := ProjectSettings.globalize_path(str(files[effect_name]))
			if FileAccess.file_exists(path):
				var stream := AudioStreamWAV.load_from_file(path)
				if stream != null:
					effects[effect_name] = stream

func update_context(in_battle: bool, audio_enabled: bool, background_music_enabled := true) -> void:
	if enabled != audio_enabled:
		enabled = audio_enabled
		if not enabled:
			for player in effect_players:
				player.stop()
			duck_remaining = 0.0
			pending_effects.clear()
		last_played.clear()
	if music_enabled != background_music_enabled:
		music_enabled = background_music_enabled
		if not music_enabled:
			for player in music_players:
				player.stop()
			gains = [0.0, 0.0]
			active_player = -1
			current_music = ""
	if not music_enabled or music_players.size() != 2:
		return
	var desired := "battle" if in_battle else "menu"
	if desired == current_music or not music_streams.has(desired):
		return
	var target := 0 if active_player < 0 else 1 - active_player
	# Reuse an outgoing track when the user quickly returns to its screen.
	for index in music_players.size():
		if music_players[index].playing and music_players[index].stream == music_streams[desired]:
			target = index
			break
	if not music_players[target].playing or music_players[target].stream != music_streams[desired]:
		music_players[target].stream = music_streams[desired]
		gains[target] = 0.0
		music_players[target].volume_db = -80.0
		music_players[target].play()
	active_player = target
	current_music = desired

func _process(delta: float) -> void:
	duck_remaining = maxf(0.0, duck_remaining - delta)
	for index in range(pending_effects.size() - 1, -1, -1):
		pending_effects[index]["remaining"] = float(pending_effects[index]["remaining"]) - delta
		if float(pending_effects[index]["remaining"]) <= 0.0:
			var event_name: String = pending_effects[index]["name"]
			pending_effects.remove_at(index)
			play_effect(event_name)
	if not music_enabled:
		return
	for index in music_players.size():
		gains[index] = move_toward(gains[index], 1.0 if index == active_player else 0.0, delta / FADE_SECONDS)
		music_players[index].volume_db = (-12.0 if duck_remaining > 0.0 else -4.0) + linear_to_db(maxf(0.0001, gains[index]))
		if gains[index] <= 0.0 and index != active_player:
			music_players[index].stop()

func play_effect(effect_name: String) -> bool:
	if not enabled or effect_players.is_empty():
		return false
	var is_sting := sting_streams.has(effect_name)
	var selected_name := effect_name
	if not is_sting and effect_groups.has(effect_name):
		var variants: Array = effect_groups[effect_name]
		if variants.is_empty():
			return false
		var index := variation.randi_range(0, variants.size() - 1)
		if variants.size() > 1 and index == int(last_variant.get(effect_name, -1)):
			index = (index + 1) % variants.size()
		selected_name = str(variants[index])
		last_variant[effect_name] = index
	if not is_sting and not effects.has(selected_name):
		return false
	var now := Time.get_ticks_msec()
	var cooldown := 180 if effect_name == "heal" else 75
	if now - int(last_played.get(effect_name, -10000)) < cooldown:
		return true # Already audible: do not add the procedural fallback.
	last_played[effect_name] = now
	var voice := next_voice
	for index in effect_players.size():
		if not effect_players[index].playing:
			voice = index
			break
	var player := effect_players[voice]
	player.stream = sting_streams[effect_name] if is_sting else effects[selected_name]
	player.volume_db = -2.0 if is_sting else (-17.0 if effect_name in ["turn_start", "tile_select", "tile_cascade", "ui_click"] else -10.0)
	player.pitch_scale = 1.0 if is_sting else variation.randf_range(0.98, 1.02)
	if is_sting:
		duck_remaining = maxf(duck_remaining, player.stream.get_length())
	player.play()
	next_voice = (voice + 1) % effect_players.size()
	return true

func can_play_effect(effect_name: String) -> bool:
	return sting_streams.has(effect_name) or effects.has(effect_name) or effect_groups.has(effect_name)

func queue_effect(effect_name: String, delay: float) -> void:
	if enabled:
		pending_effects.append({"name": effect_name, "remaining": maxf(0.0, delay)})

func hero_attack_event(hero_id: String) -> String:
	if hero_id in ["lada", "witosz", "perunika"]:
		return "hero_attack_bow"
	if hero_id in ["brun", "boruta", "wlodzimierz", "swarog"]:
		return "hero_attack_hammer"
	if hero_id in ["wszebor", "jaromir", "msciwoj", "radomir"]:
		return "hero_attack_sword"
	return "hero_attack_magic"

func enemy_sound_family(enemy_name: String) -> String:
	var name_lower := enemy_name.to_lower()
	for word in ["duch", "widmo", "cień", "cien", "mgł", "mgl", "naw", "szept", "upiór", "upior"]:
		if name_lower.contains(word):
			return "spirit"
	for word in ["kamien", "kamień", "gąsienicz", "totem", "korze", "skał", "skal"]:
		if name_lower.contains(word):
			return "stone"
	return "organic"

func enemy_attack_event(enemy_name: String) -> String:
	if enemy_sound_family(enemy_name) == "spirit":
		return "enemy_attack_spirit"
	var name_lower := enemy_name.to_lower()
	return "enemy_attack_beast" if name_lower.contains("wilk") or name_lower.contains("żmij") or name_lower.contains("zmij") else "enemy_attack_claw"
