## Mały interfejs do natywnego dostawcy Analytics. Bez dostawcy nie wysyła danych.
extends RefCounted

var provider: Object
var enabled := false

func initialize(native_provider: Object, consent: bool) -> void:
	provider = native_provider
	set_enabled(consent)

func set_enabled(value: bool) -> void:
	enabled = value
	if provider != null and provider.has_method("setAnalyticsEnabled"):
		provider.setAnalyticsEnabled(value)

func event(name: String, parameters: Dictionary) -> void:
	if not enabled or provider == null or not provider.has_method("logGameEvent"):
		return
	provider.logGameEvent(name, JSON.stringify(parameters))
