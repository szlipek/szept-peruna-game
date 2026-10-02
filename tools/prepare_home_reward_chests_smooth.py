"""Build stationary, densely sampled reward chest animations from the painted poses."""

from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
UI = ROOT / "art" / "ui"
CELL_WIDTH = 280
CELL_HEIGHT = 340
BASELINE = 325
INBETWEENS_PER_PAIR = 3

# The generated paintings have uneven gutters. These cuts keep neighboring
# chests out of each pose before each body is registered to a common anchor.
CHESTS = (
    ("coin", "v02", "v03", (0, 297, 563, 829, 1092, 1355, 1619, 1881, 2172)),
    ("wood", "v03", "v04", (0, 286, 554, 821, 1087, 1353, 1621, 1889, 2172)),
    ("xp", "v02", "v03", (0, 279, 550, 819, 1088, 1357, 1627, 1900, 2172)),
)


def painted_poses(name: str, source_version: str, cuts: tuple[int, ...]) -> list[np.ndarray]:
    image = Image.open(UI / f"home_reward_{name}_chest_source_{source_version}.png").convert("RGBA")
    pixels = np.asarray(image)
    poses: list[np.ndarray] = []
    for index in range(8):
        left, right = cuts[index : index + 2]
        segment = pixels[:, left:right]
        opaque = segment[:, :, 3] > 20
        body_y, body_x = np.where(opaque[390:640])
        all_y, _ = np.where(opaque)
        if len(body_x) == 0 or len(all_y) == 0:
            raise ValueError(f"Empty pose: {name} {index}")
        body_center = (body_x.min() + body_x.max()) / 2
        body_bottom = int(all_y.max())
        canvas = Image.new("RGBA", (CELL_WIDTH, CELL_HEIGHT))
        canvas.alpha_composite(
            Image.fromarray(segment),
            (round(CELL_WIDTH / 2 - body_center), BASELINE - body_bottom),
        )
        poses.append(np.asarray(canvas).copy())
    return poses


def premultiplied(pixels: np.ndarray) -> np.ndarray:
    result = pixels.astype(np.float32) / 255.0
    result[:, :, :3] *= result[:, :, 3:4]
    return result


def to_rgba(pixels: np.ndarray) -> Image.Image:
    alpha = pixels[:, :, 3:4]
    straight = np.concatenate(
        (np.divide(pixels[:, :, :3], alpha, out=np.zeros_like(pixels[:, :, :3]), where=alpha > 0.001), alpha),
        axis=2,
    )
    return Image.fromarray(np.uint8(np.clip(straight * 255.0 + 0.5, 0, 255)), "RGBA")


def build(name: str, source_version: str, output_version: str, cuts: tuple[int, ...]) -> None:
    poses = [premultiplied(pose) for pose in painted_poses(name, source_version, cuts)]
    # Keep the entire lower body identical. The blend band hides the seam at
    # the upper edge while the lid and contents remain free to animate.
    body_weight = np.clip((np.arange(CELL_HEIGHT, dtype=np.float32) - 243.0) / 24.0, 0.0, 1.0)
    body_weight = (body_weight * body_weight * (3.0 - 2.0 * body_weight))[:, None, None]
    stable_body = poses[0]
    poses = [pose * (1.0 - body_weight) + stable_body * body_weight for pose in poses]

    frame_count = (len(poses) - 1) * (INBETWEENS_PER_PAIR + 1) + 1
    atlas = Image.new("RGBA", (CELL_WIDTH * frame_count, CELL_HEIGHT))
    for frame in range(frame_count):
        position = frame / (INBETWEENS_PER_PAIR + 1)
        first = min(int(position), len(poses) - 1)
        second = min(first + 1, len(poses) - 1)
        fraction = position - first
        blended = poses[first] * (1.0 - fraction) + poses[second] * fraction
        atlas.paste(to_rgba(blended), (frame * CELL_WIDTH, 0))

    output = UI / f"home_reward_{name}_chest_frames_{output_version}.png"
    atlas.save(output, optimize=True)
    print(f"{output.name}: {frame_count} frames, {atlas.width} x {atlas.height}")


if __name__ == "__main__":
    for chest in CHESTS:
        build(*chest)
