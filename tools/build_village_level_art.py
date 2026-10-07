"""Build 50 distinct transparent level sprites for every village building."""

from pathlib import Path

import numpy as np
from PIL import Image, ImageEnhance, ImageOps
from scipy import ndimage


ROOT = Path(__file__).resolve().parents[1]
ENV = ROOT / "art" / "environments"
SOURCES = ENV / "level_sources"
OUTPUT = ENV / "building_levels"
BUILDINGS = [
    "domostwa",
    "kuznia",
    "chata_zielarki",
    "swiety_gaj",
    "spichlerz",
    "wieza_peruna",
]
CANVAS = 512
BASELINE = 486
STAGE_COUNT = 5
LEVELS_PER_STAGE = 10


def cells(image: Image.Image, count: int) -> list[Image.Image]:
    result: list[Image.Image] = []
    for index in range(count):
        left = round(index * image.width / count)
        right = round((index + 1) * image.width / count)
        result.append(image.crop((left, 0, right, image.height)))
    return result


def trim(image: Image.Image, padding: int = 8) -> Image.Image:
    alpha = image.getchannel("A")
    bounds = alpha.getbbox()
    if bounds is None:
        raise ValueError("Generated cell is empty")
    left, top, right, bottom = bounds
    left = max(0, left - padding)
    top = max(0, top - padding)
    right = min(image.width, right + padding)
    bottom = min(image.height, bottom + padding)
    return image.crop((left, top, right, bottom))


def contain(image: Image.Image, maximum: tuple[int, int]) -> Image.Image:
    copy = image.copy()
    copy.thumbnail(maximum, Image.Resampling.LANCZOS)
    return copy


def isolate_building(image: Image.Image) -> Image.Image:
    """Remove fragments of neighbouring cells left by a generated sheet."""
    pixels = np.array(image)
    # Ignore faint antialiasing bridges between generated cells while finding
    # the actual opaque building body. The original soft edge is retained.
    labels, component_count = ndimage.label(pixels[:, :, 3] > 20)
    if component_count <= 1:
        return image
    sizes = np.bincount(labels.ravel())
    sizes[0] = 0
    building_component = int(sizes.argmax())
    keep = ndimage.binary_dilation(labels == building_component, iterations=2)
    pixels[:, :, 3] = np.where(keep, pixels[:, :, 3], 0)
    return Image.fromarray(pixels, "RGBA")


def paste_grounded(canvas: Image.Image, sprite: Image.Image, center_x: int, baseline: int) -> None:
    canvas.alpha_composite(sprite, (center_x - sprite.width // 2, baseline - sprite.height))


def prop_variant(prop: Image.Image, level_in_stage: int, index: int) -> Image.Image:
    size = 38 + (index % 3) * 5 + level_in_stage
    sprite = contain(prop, (size, size))
    if index % 2:
        sprite = ImageOps.mirror(sprite)
    brightness = 0.88 + (index % 4) * 0.05
    return ImageEnhance.Brightness(sprite).enhance(brightness)


def build_building(building_id: str, building_index: int, prop: Image.Image) -> None:
    sheet_path = SOURCES / f"building_{building_id}_progression_sheet_v01.png"
    if not sheet_path.exists():
        raise FileNotFoundError(sheet_path)
    sheet = Image.open(sheet_path).convert("RGBA")
    stages = [trim(isolate_building(cell)) for cell in cells(sheet, STAGE_COUNT)]
    destination = OUTPUT / building_id
    destination.mkdir(parents=True, exist_ok=True)

    positions = [
        (72, 482), (440, 482), (116, 496), (396, 496), (164, 486),
        (348, 486), (92, 445), (420, 445), (142, 452), (370, 452),
    ]
    for level in range(1, 51):
        stage_index = min(STAGE_COUNT - 1, (level - 1) // LEVELS_PER_STAGE)
        level_in_stage = (level - 1) % LEVELS_PER_STAGE + 1
        # A small steady growth inside a ten-level chapter keeps adjacent
        # levels visibly different even before the next major construction.
        growth = 0.82 + stage_index * 0.035 + level_in_stage * 0.006
        max_width = min(470, round(430 * growth))
        max_height = min(466, round(420 * growth))
        building = contain(stages[stage_index], (max_width, max_height))
        canvas = Image.new("RGBA", (CANVAS, CANVAS))
        paste_grounded(canvas, building, CANVAS // 2, BASELINE)

        # Each level permanently adds one more themed element around the base.
        # Major stages replace the building body with a new room/floor/silhouette.
        for prop_index in range(level_in_stage):
            detail = prop_variant(prop, level_in_stage, prop_index)
            x, y = positions[prop_index]
            paste_grounded(canvas, detail, x, y)

        output_path = destination / f"building_{building_id}_level_{level:02d}.png"
        canvas.save(output_path, optimize=True)

    print(f"{building_id}: 50 level sprites")


def main() -> None:
    prop_sheet_path = ENV / "village_growth_props_v01.png"
    prop_sheet = Image.open(prop_sheet_path).convert("RGBA")
    props = [trim(cell, 2) for cell in cells(prop_sheet, len(BUILDINGS))]
    for index, building_id in enumerate(BUILDINGS):
        build_building(building_id, index, props[index])


if __name__ == "__main__":
    main()
