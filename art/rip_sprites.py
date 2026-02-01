#!/usr/bin/env python3
"""
Sprite Ripper — Removes white/solid backgrounds and downscales AI-generated sprites.

Strategy: Flood-fill from corners (AI generators produce near-white backgrounds reliably).
Falls back to edge-walk if corners aren't uniform. Handles gradient backgrounds by
tolerance-based flood fill.

Usage:
    python rip_sprites.py                        # Process all PNGs in art/generated/
    python rip_sprites.py path/to/image.png      # Process a single file
    python rip_sprites.py --tolerance 30         # Adjust color match tolerance (default: 40)
    python rip_sprites.py --scale 32             # Downscale to 32px (longest edge)
    python rip_sprites.py --no-preview           # Skip checkerboard preview

Output: Overwrites originals with transparent versions + saves _preview.png with checkerboard.
"""

import sys
import math
import argparse
import pathlib
from collections import Counter, deque
from pathlib import Path
from typing import Optional

# Windows UTF-8 stdout
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

try:
    from PIL import Image
except ImportError:
    print("Pillow not installed. Run: pip install Pillow")
    sys.exit(1)

try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    np = None  # type: ignore[assignment]
    HAS_NUMPY = False

# Paths
SCRIPT_DIR = pathlib.Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
GENERATED_DIR = SCRIPT_DIR / "generated"

# Default tolerance for background color matching
# Higher = more aggressive removal (good for gradient AI backgrounds)
DEFAULT_TOLERANCE = 40

# Target sizes for downscaling (longest edge)
TARGET_SIZES: dict[str, int] = {
    "characters": 256,   # 32x32 sprites at 8 frames = 256px wide sheet
    "enemies": 192,
    "bosses": 256,
    "npcs": 128,
    "items": 64,
    "equipment": 64,
    "effects": 128,
    "zones": 128,
}


def color_distance(c1: tuple, c2: tuple) -> float:
    """Euclidean distance between two RGB colors."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(c1[:3], c2[:3])))


def detect_background_color(img: Image.Image) -> tuple[tuple, float]:
    """
    Detect the background color by sampling corners and edges.
    Returns (bg_color, confidence) tuple.
    """
    pixels = img.load()
    w, h = img.size

    # Sample corners (4 corners, 5x5 patch each)
    samples: list[tuple] = []
    patch = 5
    for cy, cx in [(0, 0), (0, w-1), (h-1, 0), (h-1, w-1)]:
        for dy in range(patch):
            for dx in range(patch):
                sy = min(max(cy + dy - patch//2, 0), h - 1)
                sx = min(max(cx + dx - patch//2, 0), w - 1)
                samples.append(pixels[sx, sy][:3])

    # Sample edges (every 10th pixel along all 4 edges)
    step = max(1, min(w, h) // 20)
    for x in range(0, w, step):
        samples.append(pixels[x, 0][:3])
        samples.append(pixels[x, h-1][:3])
    for y in range(0, h, step):
        samples.append(pixels[0, y][:3])
        samples.append(pixels[w-1, y][:3])

    # Find the most common color among edge samples
    counter = Counter(samples)
    bg_color = counter.most_common(1)[0][0]

    # Verify: if the most common edge color covers >50% of samples, it's likely the background
    total = len(samples)
    bg_count = sum(1 for s in samples if color_distance(s, bg_color) < 30)
    confidence = bg_count / total

    return bg_color, confidence


def _flood_fill_remove_pillow(img: Image.Image, bg_color: tuple, tolerance: int) -> int:
    """
    Pure-Pillow flood-fill fallback (used when numpy is not available).
    Flood-fill from all 4 corners + edge midpoints to remove background.
    Only removes connected regions (won't punch holes in the sprite).
    Returns count of pixels made transparent.
    """
    pixels = img.load()
    w, h = img.size
    visited: set[tuple[int, int]] = set()
    transparent_count = 0

    # Start flood fill from all 4 corners + edge midpoints
    seeds = [
        (0, 0), (w-1, 0), (0, h-1), (w-1, h-1),
        (w//2, 0), (w//2, h-1), (0, h//2), (w-1, h//2),
    ]

    queue: deque[tuple[int, int]] = deque()
    for seed in seeds:
        if seed not in visited:
            queue.append(seed)

    while queue:
        x, y = queue.popleft()

        if (x, y) in visited:
            continue
        if x < 0 or x >= w or y < 0 or y >= h:
            continue

        visited.add((x, y))

        r, g, b, a = pixels[x, y]
        if color_distance((r, g, b), bg_color) <= tolerance:
            pixels[x, y] = (0, 0, 0, 0)
            transparent_count += 1

            # Add neighbors (4-connected for cleaner edges)
            for nx, ny in [(x+1, y), (x-1, y), (x, y+1), (x, y-1)]:
                if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in visited:
                    queue.append((nx, ny))

    return transparent_count


def _flood_fill_remove_numpy(img: Image.Image, bg_color: tuple, tolerance: int) -> int:
    """
    Numpy-optimized flood-fill from all 4 corners + edge midpoints.
    Uses numpy boolean array for O(1) visited tracking and numpy array
    indexing for pixel color comparisons. Only removes connected regions.
    Returns count of pixels made transparent.
    """
    w, h = img.size
    # Convert image to numpy array (h, w, 4) for fast pixel access
    arr = np.array(img, dtype=np.int16)
    bg_arr = np.array(bg_color[:3], dtype=np.int16)
    tolerance_sq = tolerance * tolerance

    # Numpy boolean array for O(1) visited lookup (replaces Python set())
    visited = np.zeros((h, w), dtype=bool)
    transparent_count = 0

    # Start flood fill from all 4 corners + edge midpoints
    seeds = [
        (0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1),
        (w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2),
    ]

    queue: deque[tuple[int, int]] = deque()
    for sx, sy in seeds:
        if not visited[sy, sx]:
            queue.append((sx, sy))
            visited[sy, sx] = True

    while queue:
        x, y = queue.popleft()

        # Color distance check using squared distance (avoids sqrt)
        diff = arr[y, x, :3] - bg_arr
        dist_sq = int(diff[0]) * int(diff[0]) + int(diff[1]) * int(diff[1]) + int(diff[2]) * int(diff[2])

        if dist_sq <= tolerance_sq:
            arr[y, x] = (0, 0, 0, 0)
            transparent_count += 1

            # Add unvisited neighbors (4-connected for cleaner edges)
            if x + 1 < w and not visited[y, x + 1]:
                visited[y, x + 1] = True
                queue.append((x + 1, y))
            if x - 1 >= 0 and not visited[y, x - 1]:
                visited[y, x - 1] = True
                queue.append((x - 1, y))
            if y + 1 < h and not visited[y + 1, x]:
                visited[y + 1, x] = True
                queue.append((x, y + 1))
            if y - 1 >= 0 and not visited[y - 1, x]:
                visited[y - 1, x] = True
                queue.append((x, y - 1))

    # Write numpy array back to the image in-place
    result = Image.fromarray(arr.astype(np.uint8), "RGBA")
    img.paste(result)

    return transparent_count


def flood_fill_remove(img: Image.Image, bg_color: tuple, tolerance: int) -> int:
    """
    Flood-fill from all 4 corners to remove background.
    Only removes connected regions (won't punch holes in the sprite).
    Returns count of pixels made transparent.

    Uses numpy-optimized implementation when available, falls back to
    pure-Pillow implementation otherwise.
    """
    if HAS_NUMPY:
        return _flood_fill_remove_numpy(img, bg_color, tolerance)
    return _flood_fill_remove_pillow(img, bg_color, tolerance)


def _clean_fringe_pillow(
    img: Image.Image, bg_color: tuple, fringe_tolerance: int = 80, passes: int = 2
) -> int:
    """
    Pure-Pillow fringe cleaning fallback (used when numpy is not available).
    Runs multiple passes — each pass expands the transparent boundary found
    in the previous pass, catching deeper anti-aliasing artifacts.
    Returns total count of pixels cleaned across all passes.
    """
    pixels = img.load()
    w, h = img.size
    total_cleaned = 0

    for _pass in range(passes):
        cleaned = 0
        for y in range(h):
            for x in range(w):
                r, g, b, a = pixels[x, y]
                if a == 0:
                    continue  # Already transparent

                # Check if this pixel is adjacent to a transparent pixel
                has_transparent_neighbor = False
                for nx, ny in [(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)]:
                    if 0 <= nx < w and 0 <= ny < h:
                        if pixels[nx, ny][3] == 0:
                            has_transparent_neighbor = True
                            break

                if has_transparent_neighbor:
                    dist = color_distance((r, g, b), bg_color)
                    if dist <= fringe_tolerance:
                        pixels[x, y] = (0, 0, 0, 0)
                        cleaned += 1

        total_cleaned += cleaned
        if cleaned == 0:
            break  # No more fringe pixels to clean

    return total_cleaned


def _clean_fringe_numpy(
    img: Image.Image, bg_color: tuple, fringe_tolerance: int = 80, passes: int = 2
) -> int:
    """
    Numpy-optimized fringe cleaning with multi-pass support.
    Uses numpy array shifts to find all pixels adjacent to transparent regions,
    then batch-computes color distances to decide which to remove.
    Each pass expands the transparent boundary found in the previous pass.
    Returns total count of pixels cleaned across all passes.
    """
    # Use int32 to avoid overflow when squaring color differences (255^2 = 65025 > int16 max)
    arr = np.array(img, dtype=np.int32)
    bg_arr = np.array(bg_color[:3], dtype=np.int32)
    tolerance_sq = fringe_tolerance * fringe_tolerance
    total_cleaned = 0
    h, w = arr.shape[:2]

    for _pass in range(passes):
        # Find transparent pixels (alpha == 0)
        transparent = arr[:, :, 3] == 0

        # Find pixels adjacent to transparent regions using array shifts
        # Each shift checks one direction: up, down, left, right
        has_transparent_neighbor = np.zeros((h, w), dtype=bool)

        # Neighbor above is transparent (shift transparent down by 1)
        has_transparent_neighbor[1:, :] |= transparent[:-1, :]
        # Neighbor below is transparent (shift transparent up by 1)
        has_transparent_neighbor[:-1, :] |= transparent[1:, :]
        # Neighbor to the left is transparent (shift transparent right by 1)
        has_transparent_neighbor[:, 1:] |= transparent[:, :-1]
        # Neighbor to the right is transparent (shift transparent left by 1)
        has_transparent_neighbor[:, :-1] |= transparent[:, 1:]

        # Only consider non-transparent pixels that have a transparent neighbor
        candidates = has_transparent_neighbor & ~transparent

        if not np.any(candidates):
            break

        # Batch-compute squared color distance for all candidate pixels
        diff = arr[:, :, :3] - bg_arr
        dist_sq = np.sum(diff * diff, axis=2)

        # Pixels to clean: candidates close to background color
        to_clean = candidates & (dist_sq <= tolerance_sq)

        cleaned_count = int(np.sum(to_clean))
        if cleaned_count == 0:
            break

        # Make cleaned pixels fully transparent
        arr[to_clean] = [0, 0, 0, 0]
        total_cleaned += cleaned_count

    # Write numpy array back to the image in-place
    result = Image.fromarray(arr.astype(np.uint8), "RGBA")
    img.paste(result)

    return total_cleaned


def clean_semitransparent_fringe(
    img: Image.Image, bg_color: tuple, fringe_tolerance: int = 80, passes: int = 2
) -> int:
    """
    Clean up semi-transparent fringe pixels at sprite edges.
    These are anti-aliasing artifacts where the sprite blends into the background.

    Runs multiple passes (default 2) — each pass expands the transparent boundary
    found in the previous pass, catching deeper anti-aliasing artifacts.

    Uses numpy-optimized implementation when available, falls back to
    pure-Pillow implementation otherwise.
    """
    if HAS_NUMPY:
        return _clean_fringe_numpy(img, bg_color, fringe_tolerance, passes)
    return _clean_fringe_pillow(img, bg_color, fringe_tolerance, passes)


def crop_to_content(img: Image.Image, padding: int = 2) -> Image.Image:
    """
    Crop image to the bounding box of non-transparent pixels plus padding.

    Uses PIL's Image.getbbox() for efficient bounding-box detection.
    Returns the original image unchanged if it's already smaller than 16x16
    or if no non-transparent content is found.
    """
    w, h = img.size

    # Don't crop if image is already smaller than 16x16
    if w < 16 or h < 16:
        return img

    # Get bounding box of non-transparent pixels (alpha > 0)
    bbox = img.getbbox()
    if bbox is None:
        # Fully transparent image — return as-is
        return img

    # Add padding around the bounding box
    left = max(0, bbox[0] - padding)
    upper = max(0, bbox[1] - padding)
    right = min(w, bbox[2] + padding)
    lower = min(h, bbox[3] + padding)

    # Don't crop if result would be same size or larger
    if left == 0 and upper == 0 and right == w and lower == h:
        return img

    return img.crop((left, upper, right, lower))


def split_frames(img: Image.Image, num_frames: int) -> Optional[list[Image.Image]]:
    """
    Split a horizontal sprite strip into N equal-width individual frames.

    Validates that the image width is evenly divisible by num_frames and
    that each resulting frame is at least 4px wide. Returns None with a
    warning if validation fails.

    Returns a list of N cropped frame Images, or None on validation failure.
    """
    w, h = img.size
    frame_width = w // num_frames

    # Validate: image width must be evenly divisible by N
    if w % num_frames != 0:
        print(f"  WARN: Image width {w} not evenly divisible by {num_frames} — skipping split")
        return None

    # Validate: result frames must be >= 4px wide
    if frame_width < 4:
        print(f"  WARN: Frame width {frame_width}px too small (min 4px) — skipping split")
        return None

    frames: list[Image.Image] = []
    for i in range(num_frames):
        left = i * frame_width
        right = left + frame_width
        frame = img.crop((left, 0, right, h))
        frames.append(frame)

    return frames


def downscale_nearest(img: Image.Image, target_size: int) -> Image.Image:
    """Downscale using nearest-neighbor to preserve pixel art crispness."""
    w, h = img.size
    if max(w, h) <= target_size:
        return img  # Already small enough

    scale = target_size / max(w, h)
    new_w = max(1, int(w * scale))
    new_h = max(1, int(h * scale))

    return img.resize((new_w, new_h), Image.NEAREST)


def rip_sprite(image_path: Path, args: argparse.Namespace) -> bool:
    """
    Remove background and optionally downscale a sprite.

    Strategy:
    1. Detect background color from corners/edges
    2. Flood-fill from corners to remove connected background
    3. Clean semi-transparent fringe pixels
    4. Crop to content bounding box (if --crop enabled)
    5. Optionally downscale with nearest-neighbor
    6. Split into individual frames (if --split-frames N specified)
    7. Save with transparency

    Returns True if background was successfully removed.
    """
    tolerance: int = args.tolerance
    target_size: Optional[int] = args.scale
    save_preview: bool = not args.no_preview

    try:
        img = Image.open(image_path).convert("RGBA")
    except Exception as e:
        print(f"  SKIP {image_path}: {e}")
        return False

    w, h = img.size
    total_pixels = w * h

    # Step 1: Detect background
    bg_color, confidence = detect_background_color(img)
    print(f"  BG detected: rgb{bg_color} (confidence: {confidence:.0%})")

    if confidence < 0.3:
        print(f"  WARN: Low confidence background detection — may be transparent already or complex scene")

    # Step 2: Flood-fill remove from edges
    transparent_count = flood_fill_remove(img, bg_color, tolerance)

    # Step 3: Clean fringe (multi-pass)
    fringe_passes: int = getattr(args, "fringe_passes", 2)
    fringe_cleaned = clean_semitransparent_fringe(img, bg_color, passes=fringe_passes)
    transparent_count += fringe_cleaned

    if transparent_count == 0:
        # Check if image already has transparency
        has_alpha = any(img.getpixel((x, y))[3] < 255 for x in range(w) for y in range(min(3, h)))
        if has_alpha:
            print(f"  OK {image_path.name}: Already has transparency")
        else:
            print(f"  WARN {image_path.name}: No background removed — manual check needed")
        return False

    # Step 4: Crop to content bounding box
    do_crop: bool = getattr(args, "crop", True)
    padding: int = getattr(args, "padding", 2)
    if do_crop:
        pre_crop_size = img.size
        img = crop_to_content(img, padding)
        if img.size != pre_crop_size:
            print(f"  CROP: {pre_crop_size[0]}x{pre_crop_size[1]} -> {img.size[0]}x{img.size[1]} (padding={padding})")

    # Step 5: Downscale if target specified
    if target_size:
        img = downscale_nearest(img, target_size)
        print(f"  SCALE: {w}x{h} -> {img.size[0]}x{img.size[1]}")

    # Step 6: Split into individual frames (if --split-frames N specified)
    num_frames: Optional[int] = getattr(args, "split_frames", None)
    if num_frames is not None:
        frames = split_frames(img, num_frames)
        if frames is not None:
            stem = image_path.stem
            parent = image_path.parent
            for idx, frame in enumerate(frames, start=1):
                frame_name = f"{stem}_frame_{idx:02d}.png"
                frame_path = parent / frame_name
                frame.save(frame_path, "PNG")
            print(f"  SPLIT: {len(frames)} frames ({frames[0].size[0]}x{frames[0].size[1]} each)")

    # Step 7: Save
    img.save(image_path, "PNG")

    # Save preview with checkerboard
    if save_preview and transparent_count > 0:
        preview = _make_checkerboard(img.size[0], img.size[1])
        preview.paste(img, (0, 0), img)
        preview_path = image_path.with_name(image_path.stem + "_preview.png")
        preview.save(preview_path, "PNG")

    pct = (transparent_count / total_pixels) * 100
    status = "OK" if pct > 20 else "WARN (low removal — check manually)"
    print(f"  {status} {image_path.name}: {transparent_count} pixels removed ({pct:.1f}%)")
    if fringe_cleaned > 0:
        print(f"       + {fringe_cleaned} fringe pixels cleaned")
    return transparent_count > 0


def _make_checkerboard(w: int, h: int, tile_size: int = 8) -> Image.Image:
    """Create a checkerboard pattern image for transparency preview.

    Uses numpy array broadcasting when available for fastest generation.
    Falls back to PIL tile+paste which is still much faster than per-pixel.
    """
    c1 = (200, 200, 200, 255)
    c2 = (255, 255, 255, 255)

    if HAS_NUMPY:
        # Numpy broadcasting: build entire checkerboard in one vectorized operation
        y_idx = np.arange(h) // tile_size
        x_idx = np.arange(w) // tile_size
        # (h,1) + (1,w) broadcasts to (h,w) checkerboard mask
        checker = (y_idx[:, np.newaxis] + x_idx[np.newaxis, :]) % 2
        # Build RGBA array: where checker==0 -> c1, checker==1 -> c2
        arr = np.empty((h, w, 4), dtype=np.uint8)
        arr[checker == 0] = c1
        arr[checker == 1] = c2
        return Image.fromarray(arr, "RGBA")

    # PIL fallback: create a single 2x2 tile and paste it across the image
    tile_w = tile_size * 2
    tile_h = tile_size * 2
    tile = Image.new("RGBA", (tile_w, tile_h))
    tile.paste(Image.new("RGBA", (tile_size, tile_size), c1), (0, 0))
    tile.paste(Image.new("RGBA", (tile_size, tile_size), c2), (tile_size, 0))
    tile.paste(Image.new("RGBA", (tile_size, tile_size), c2), (0, tile_size))
    tile.paste(Image.new("RGBA", (tile_size, tile_size), c1), (tile_size, tile_size))

    img = Image.new("RGBA", (w, h))
    for y in range(0, h, tile_h):
        for x in range(0, w, tile_w):
            img.paste(tile, (x, y))
    return img


def process_directory(dir_path: Path, args: argparse.Namespace) -> None:
    """Process all PNGs in a directory (recursively)."""
    pngs = sorted(dir_path.rglob("*.png"))
    # Skip preview files
    pngs = [p for p in pngs if "_preview" not in p.name]

    if not pngs:
        print(f"No PNG files found in {dir_path}")
        return

    print(f"Processing {len(pngs)} sprites (tolerance={args.tolerance})")
    if args.scale:
        print(f"Downscaling to {args.scale}px (longest edge)")
    print("=" * 60)

    success = 0
    for png in pngs:
        # Auto-detect target size from parent folder name
        folder_name = png.parent.name
        auto_size = args.scale or TARGET_SIZES.get(folder_name)

        # Create per-file args with auto-detected scale
        file_args = argparse.Namespace(**vars(args))
        file_args.scale = auto_size

        if rip_sprite(png, file_args):
            success += 1

    print("=" * 60)
    print(f"Done: {success}/{len(pngs)} sprites processed")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Remove backgrounds and process AI-generated sprites",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python art/rip_sprites.py                          Process all PNGs in art/generated/
  python art/rip_sprites.py path/to/image.png        Process a single file
  python art/rip_sprites.py --tolerance 30           Adjust color match tolerance
  python art/rip_sprites.py --scale 64               Downscale to 64px (longest edge)
  python art/rip_sprites.py --no-preview             Skip checkerboard preview
  python art/rip_sprites.py --crop --split-frames 8  Crop and split into 8 frames
  python art/rip_sprites.py --batch 1                Process batch_1/ only
  python art/rip_sprites.py --output-dir out/        Write to separate directory
  python art/rip_sprites.py --backup                 Save originals before overwriting
  python art/rip_sprites.py --dry-run                Preview without making changes
  python art/rip_sprites.py --report                 Generate _rip_report.json
        """,
    )

    # Existing flags (preserved from original CLI)
    parser.add_argument("path", nargs="?", default=None,
                        help="Path to a single PNG file to process (default: all in art/generated/)")
    parser.add_argument("--tolerance", "-t", type=int, default=DEFAULT_TOLERANCE,
                        help=f"Color match tolerance for background detection (default: {DEFAULT_TOLERANCE})")
    parser.add_argument("--scale", "-s", type=int, default=None, metavar="N",
                        help="Downscale to N pixels on the longest edge (default: auto from folder name)")
    parser.add_argument("--no-preview", action="store_true",
                        help="Skip generating checkerboard preview images")

    # New flags (stubs for future implementation)
    parser.add_argument("--crop", action="store_true", default=True,
                        help="Crop to content bounding box after background removal (default: on)")
    parser.add_argument("--no-crop", action="store_true",
                        help="Disable crop-to-content")
    parser.add_argument("--padding", type=int, default=2, metavar="N",
                        help="Padding pixels around content when cropping (default: 2)")
    parser.add_argument("--split-frames", type=int, default=None, metavar="N",
                        help="Split horizontal sprite sheet into N individual frame PNGs")
    parser.add_argument("--output-dir", type=str, default=None, metavar="PATH",
                        help="Write processed sprites to a separate directory instead of overwriting")
    parser.add_argument("--backup", action="store_true",
                        help="Save originals to _originals/ subdirectory before overwriting")
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview what would be processed without making changes")
    parser.add_argument("--batch", type=int, default=None, metavar="N",
                        help="Process only batch_N/ directory (e.g., --batch 1 for art/generated/batch_1/)")
    parser.add_argument("--fringe-passes", type=int, default=2, metavar="N",
                        help="Number of fringe-cleaning passes (default: 2)")
    parser.add_argument("--report", action="store_true",
                        help="Generate _rip_report.json with per-file processing results")

    args = parser.parse_args()

    # Resolve crop flag (--no-crop overrides --crop default)
    if args.no_crop:
        args.crop = False

    # Warn about not-yet-implemented flags (only when user explicitly sets them)
    _stub_flags: list[str] = []
    if args.output_dir is not None:
        _stub_flags.append("--output-dir")
    if args.backup:
        _stub_flags.append("--backup")
    if args.dry_run:
        _stub_flags.append("--dry-run")
    if args.batch is not None:
        _stub_flags.append("--batch")
    if args.report:
        _stub_flags.append("--report")
    if _stub_flags:
        for flag in _stub_flags:
            print(f"  NOTE: {flag} accepted but not yet implemented")

    if args.path and Path(args.path).is_file():
        rip_sprite(Path(args.path), args)
    else:
        # Default: process art/generated/ in repo
        if GENERATED_DIR.is_dir():
            process_directory(GENERATED_DIR, args)
        else:
            print(f"No generated/ directory found at {GENERATED_DIR}")
            print("Run: python art/rip_sprites.py --help")


if __name__ == "__main__":
    main()
