# World map assets

Generated with the built-in ImageGen tool, transparent backgrounds.

## Connector

Saved as `art/ui/world_map_route_connector_v01.png`.

Use case: stylized-concept. Asset type: transparent game UI connector sprite. Primary request: a single straight horizontal ornamental connector linking mission medallions in a Slavic dark fantasy world map. Hand-painted detailed golden braided oak roots, slim antique gold edges, subtle teal enamel threading and tiny carved runic accents, luminous amber central strand. Composition: one continuous straight horizontal strip from left to right, perfectly horizontal centerline, length to thickness ratio 12:1, isolated centered on transparent canvas. No end medallions, no arrows, no text, no letters, no background, no separate objects, no shadow rectangle. The strip will be curved by a game renderer so keep a uniform width and straight centerline. Detailed bitmap, cohesive with gold oak leaf frames over dark green swamp map. Actual transparent alpha background.

## Mission nameplate

Saved as `art/ui/world_map_mission_nameplate_v01.png`.

Use case: stylized-concept. Asset type: transparent mission name and stars background sprite for Slavic dark fantasy game world map. One single compact horizontal nameplate, aspect ratio 2.7:1, front facing perfectly straight. Wide quiet opaque very dark forest-green almost black enamel center reserved for game-rendered mission name, mission type, and three stars on three rows. Thin ornate antique gold border of intertwined oak roots and restrained oak leaves only at ends and corners; small teal patina accents. Center must be flat dark and empty, taking 80% of width and height, readable behind cream text and gold stars. Hand-painted detailed bitmap matching ornate gilded oak UI over dark swamp. Entire object centered, minimal transparent margins. True transparent alpha outside the plaque. No text, no stars, no lettering, no runes in the center, no medallions, no scenery, no background, no watermark, no extra objects.

`tools/prepare_map_assets.gd` crops transparent margins and limits texture sizes for game use. The original generated images remain in the ImageGen output directory.
