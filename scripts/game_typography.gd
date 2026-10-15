extends RefCounted

# Jedna typografia dla wszystkich ekranów: dodatkowy odstęp dotyczy tylko
# spacji, więc słowa pozostają zwarte, a odstępy i pomiary tekstu są zgodne.
static func create_font() -> Font:
	var base: Font = ThemeDB.fallback_font
	var alegreya := FontFile.new()
	if alegreya.load_dynamic_font("res://art/fonts/AlegreyaSans-Bold.ttf") == OK:
		base = alegreya
	var spaced := FontVariation.new()
	spaced.base_font = base
	spaced.spacing_space = 3
	return spaced
