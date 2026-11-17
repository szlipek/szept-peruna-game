extends SceneTree

const Analytics = preload("res://scripts/game_analytics.gd")

class FakeProvider extends RefCounted:
	var enabled := false
	var events: Array = []
	func setAnalyticsEnabled(value: bool) -> void:
		enabled = value
	func logGameEvent(event_name: String, values: String) -> void:
		events.append([event_name, JSON.parse_string(values)])

func _initialize() -> void:
	var analytics = Analytics.new()
	var fake := FakeProvider.new()
	analytics.initialize(fake, false)
	analytics.event("level_start", {"level_name": "1"})
	assert(fake.events.is_empty() and not fake.enabled)
	analytics.set_enabled(true)
	analytics.event("level_start", {"level_name": "1"})
	assert(fake.enabled and fake.events.size() == 1 and fake.events[0][1]["level_name"] == "1")
	analytics.set_enabled(false)
	analytics.event("level_end", {})
	assert(not fake.enabled and fake.events.size() == 1)
	analytics.initialize(null, true)
	analytics.event("level_start", {})
	print("Game analytics consent adapter: OK")
	quit()
