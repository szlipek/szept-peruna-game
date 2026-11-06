"""Production catalogue mapped to every row of docs/audio-assets-lista.md."""

MUSIC = [
    {"name": "menu_grove_ambient", "group": "menu_grove_ambient", "label": "Menu i osada — Szept Gaju", "duration": 64.0, "range": [60, 90], "loop": True, "bpm": 75, "key": "D minor", "prompt": "Instrumental ancient Slavic woodland fantasy background music. Peaceful sacred oak grove, warm soft bowed strings, delicate gusli and wooden lyre, sparse tiny hand bells, breathy wooden flute and gentle forest wind texture. Calm welcoming mysterious atmosphere, very restrained melody, soft dynamics, no prominent drums, no voices, no modern synthesizers. Steady continuous arrangement suitable for a seamless game menu loop."},
    {"name": "battle_loop", "group": "battle_loop", "label": "Walka — Straż Peruna", "duration": 80.0, "range": [75, 120], "loop": True, "bpm": 108, "key": "D minor", "prompt": "Instrumental Slavic folk fantasy tactical battle background music, steady lively frame drums and deep hand drums, driving low bowed strings, sparse ancient gusli and wooden flute motif. Dark forest magic, brave tense atmosphere, moderate intensity with plenty of space for game sound effects. Natural acoustic instruments, continuous rhythmic arrangement suitable for looping, no vocals, no electric guitars, no electronic dance beat."},
    {"name": "victory_sting", "group": "victory_sting", "label": "Zwycięstwo", "duration": 4.0, "range": [3, 5], "loop": False, "bpm": 110, "key": "D major", "prompt": "Instrumental very short Slavic fantasy victory fanfare. One uplifting resolved major phrase played by warm bowed strings and a wooden lyre, one celebratory frame drum hit, ending in a bright clear hand bell. Brief triumphant game victory jingle with a natural final decay, no voices, no repeating groove, no modern synth."},
    {"name": "defeat_sting", "group": "defeat_sting", "label": "Porażka", "duration": 4.0, "range": [3, 5], "loop": False, "bpm": 72, "key": "D minor", "prompt": "Instrumental very short gentle Slavic fantasy defeat cue. A soft descending bowed string phrase and one low muted frame drum, a warm wooden lyre final note, calm reassuring ending with a natural decay. Mild disappointment without horror or despair, no vocals, no harsh impacts, no repeating rhythm."},
    {"name": "village_upgrade_sting", "group": "village_upgrade_sting", "label": "Rozbudowa osady", "duration": 3.0, "range": [2, 4], "loop": False, "bpm": 100, "key": "G major", "prompt": "Instrumental very short warm Slavic village building completion jingle. A dry wooden knock, a brief ascending wooden lyre and gusli flourish, warm strings and one small clear bell at the resolved ending. Hopeful uplifting acoustic fantasy reward cue, no vocals, no electronic synthesizer, no long drum rhythm."},
]

SFX = []


def add(name, group, label, duration, limits, prompt):
    SFX.append({"name": name, "group": group, "label": label, "duration": duration, "range": limits,
                "prompt": prompt + " Isolated dry close recording, one clear short event, quiet background, no music or speech."})


for i, word in enumerate(["small oak", "smooth beech", "hollow maple"], 1):
    add(f"ui_click_{i:02}", "ui_click", f"Klik przycisku {i}", .12 + i*.02, [.08, .2], f"One very short quiet {word} button tap with a delicate tiny metallic tick.")
add("ui_confirm", "ui_confirm", "Potwierdzenie", .55, [.3, .7], "Two bright gentle ascending plucked wooden lyre notes with a tiny soft hand bell.")
add("ui_back", "ui_back", "Powrót", .35, [.2, .5], "One short soft descending wooden flute and muted bell tone, gentle rounded attack.")
add("resource_coin", "resource_coin", "Monety", .65, [.4, .8], "Two or three small gold coins lightly clinking together and landing on wood, pleasant low metallic jingling without sharp high squealing.")
add("resource_wood", "resource_wood", "Drewno", .5, [.3, .7], "One small dry wooden log landing on another log, a light woody knock with a little leaf rustle.")
add("resource_perun", "resource_perun", "Iskra Peruna", .7, [.4, .9], "One bright small hand bell chime accompanied by a tiny controlled electrical spark crackle, short magical flash.")
add("chest_open", "chest_open", "Otwarcie skrzyni", 1.25, [.8, 1.5], "One small metal latch unlocking, a wooden chest lid briefly creaking open followed by a tiny bright shimmer, short restrained ending.")
add("reward_reveal_common", "reward_reveal", "Zwykła nagroda", .75, [.5, 1.2], "A short cheerful ascending wooden lyre flourish with a small warm bell ending.")
add("reward_reveal_rare", "reward_reveal", "Rzadka nagroda", 1.05, [.5, 1.2], "A short rich ascending cluster of small golden bells with a warm wooden lyre flourish, bright magical discovery ending.")
add("level_unlock", "level_unlock", "Odblokowanie etapu", 1.15, [.8, 1.5], "A small bell gently swelling into a bright resolved chime, brief warm magical discovery sound.")
for i, word in enumerate(["smooth river stone", "small polished amber stone", "small slate pebble"], 1):
    add(f"tile_select_{i:02}", "tile_select", f"Wybór kafelka {i}", .09 + i*.02, [.08, .18], f"One very quiet tiny dry click as a {word} is gently tapped.")
add("tile_swap", "tile_swap", "Zamiana kafelków", .28, [.15, .35], "Two small smooth stones sliding past each other with a tiny airy magical rustle, soft quick swish.")
add("match_3", "match_3", "Trzy znaki", .6, [.35, .7], "Three tiny bright glass chimes in a quick ascending three note sequence, delicate satisfying magical sparkle.")
add("match_4_5", "match_4_5", "Duże dopasowanie", .85, [.5, 1], "A richer bright cluster of magical glass chimes, a short swelling shimmer and a soft rounded low wooden impact.")
for i, word in enumerate(["wooden beads", "tiny polished pebbles", "small glass beads", "small amber beads"], 1):
    add(f"tile_cascade_{i:02}", "tile_cascade", f"Kaskada {i}", .15 + i*.04, [.15, .4], f"A few {word} lightly tumbling and landing in a quick gentle cascade, tiny dry light taps.")
for name, label, prompt in [
    ("bow", "Łuk", "One wooden bowstring twanging followed by an arrow swiftly whooshing through the air."),
    ("hammer", "Młot", "One heavy blacksmith hammer swinging through the air and striking solid stone, a short deep rounded impact."),
    ("sword", "Ostrze", "One short clean sword slash through the air with a light metallic blade resonance."),
    ("magic", "Magia", "One brief airy magical pulse of shimmering natural glass and soft rushing wind, clear rounded attack."),
]:
    add(f"hero_attack_{name}", "hero_attack", f"Atak bohatera — {label}", .8, [.4, 1], prompt)
for name, label, prompt in [
    ("claw", "Pazury", "One heavy claw swipe through the air followed by a short dull organic impact."),
    ("beast", "Bestia", "One low short beast snort and a heavy rushing lunge with a muted thud, no prolonged roar."),
    ("spirit", "Duch", "One eerie low breathy ghostly gust swelling into a short soft hollow impact, no human speech."),
]:
    add(f"enemy_attack_{name}", "enemy_attack", f"Atak wroga — {label}", .85, [.4, 1], prompt)
for name, label, prompt in [
    ("body", "Ciało", "One short muted solid punch landing on padded cloth, soft low organic thud without gore."),
    ("armor", "Zbroja", "One short clear impact on a small iron breastplate, muted metal clank with a very short rattle."),
    ("shield", "Tarcza", "One short solid blow on an oak shield, dry wooden thud with a little muted metal rattle."),
]:
    add(f"hit_impact_{name}", "hit_impact", f"Trafienie — {label}", .32, [.15, .45], prompt)
add("hero_hurt", "hero_hurt", "Obrażenia bohatera", .4, [.25, .6], "One short muffled breath and low padded impact, restrained soft pain reaction, no scream or words.")
add("heal", "heal", "Leczenie", .9, [.5, 1], "A gentle little splash of clear spring water followed by warm tiny hand bell chimes, soothing short magical sparkle.")
for name, label, prompt in [
    ("thunder", "Piorun", "One sharp controlled lightning crack followed by a short low rolling thunder rumble."),
    ("roots", "Korzenie", "A brief organic creaking of small wooden roots unfurling through soil with soft leaf rustles."),
    ("wind", "Wiatr", "One clean brief rising and falling gust of wind swirling through dry leaves, soft airy whoosh."),
    ("water", "Woda", "A small clear spring water surge splashing and sparkling with a few gentle droplets."),
    ("fire", "Ogień", "One short low rushing flame burst with a crisp little fire crackle, controlled soft impact."),
    ("runes", "Runy", "One short mysterious low resonant stone hum with a few tiny clear hand bell overtones, ancient magic."),
    ("amber", "Bursztyn", "One short warm resonant glass chime with a gentle low stone impact and a few bright little sparks."),
]:
    add(f"skill_activate_{name}", "skill_activate", f"Umiejętność — {label}", 1.15, [.6, 1.5], prompt)
for name, label, prompt in [
    ("organic", "Leśny wróg", "A small heavy body softly collapsing onto leaves with a short dry rustle, no scream."),
    ("spirit", "Duch", "A short hollow ghostly breath gently dispersing into fading wind and tiny bell overtones, no voice."),
    ("stone", "Kamienny wróg", "A small pile of rough stones briefly crumbling and settling with a short dull rattle."),
]:
    add(f"enemy_defeated_{name}", "enemy_defeated", f"Pokonany wróg — {label}", .8, [.4, 1], prompt)
add("turn_start", "turn_start", "Początek tury", .3, [.2, .5], "One very gentle quiet wooden lyre pluck with a tiny soft bell overtone, subtle unobtrusive cue.")

ALL = MUSIC + SFX
GROUPS = {entry["group"] for entry in ALL}
