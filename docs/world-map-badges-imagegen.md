# World map objective badges and level numbers

Generated with the built-in ImageGen tool.

## Objective badges

Source: `art/ui/world_map_objective_badges_source_v01.png`.
Transparent source: `art/ui/world_map_objective_badges_alpha_v01.png`.
Game assets: `art/ui/world_map_objective_{defeat_enemy,survive,collect_amber,collect_rune,clear_obstacles,score}_v01.png`.

Prompt:

Use case: stylized-concept. Asset type: production game UI sprite atlas, transparent PNG. Create exactly SIX circular mission-objective badges arranged in a precisely spaced 3-column by 2-row grid, identical square cells, each badge centered in its own cell with ample transparent gutter. All badges same diameter, straight front view, polished hand-painted Slavic fantasy style, thin antique-gold oak-root rim, dark emerald enamel face, simple bold highly legible central pictogram occupying 65% of badge. Read clearly at 32px size. Top row left to right: 1 two unmistakable silver SWORDS crossed, with gold hilts, for combat; 2 a silver and teal SHIELD for survival; 3 one orange AMBER CRYSTAL for collection. Bottom row left to right: 4 teal glowing carved RUNESTONE for rune collection; 5 gold and iron PICKAXE breaking a small gray rock for clearing obstacles; 6 one gold FIVE POINT STAR for score. No extra badges or objects. Actual transparent alpha outside each circular badge. No letters, no numbers, no text, no labels, no grid lines, no background. Consistent size, rim and lighting across all six. Pixel-exact regular grid placement so atlas can be split into equal cells.

Transparency edit prompt:

undefined

## Level number plaque

Source: `art/ui/world_map_level_number_source_v01.png`.
Game asset: `art/ui/world_map_level_number_v01.png`.

Prompt:

Use case: stylized-concept. Asset type: one transparent Slavic fantasy game UI plaque for displaying a level number. Single compact horizontal oval antique gold medal plaque, width-to-height ratio 2.1:1, perfectly front facing, centered, symmetrical. A clearly EMPTY dark green nearly-black opaque enamel center occupying at least 65% of width, sized for 2 to 5 digits which the game renderer adds later. Fine detailed polished antique-gold border of braided oak roots, tiny oak leaf accents at left and right ends, subtle teal patina. Clean rim and wide high-contrast central space, usable at 58px wide and 28px tall. Hand-painted bitmap matching ornate gold oak mission medallions over a dark green fantasy world map. Exactly one single number plaque. Minimal transparent margins, true transparent alpha outside object. No numbers, no text, no symbols, no gems in the center, no other objects, no background, no shadow rectangle, no watermark.

`tools/prepare_map_badges.gd` splits the six atlas cells, crops transparent margins, and sizes the assets for use in the game. The game draws the level number over the empty plaque.
