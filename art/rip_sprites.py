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
import time
import json
import argparse
import pathlib
import shutil
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


def is_already_transparent(img: Image.Image, threshold: float = 0.3) -> bool:
    """Check if an image already has significant transparency (>threshold fraction).

    Used to skip images that have already been processed or were generated
    with transparent backgrounds. Returns True if more than threshold fraction
    of pixels are fully transparent (alpha == 0).
    """
    w, h = img.size
    total_pixels = w * h
    if total_pixels == 0:
        return False

    if HAS_NUMPY:
        arr = np.array(img)
        transparent_pixels = int(np.sum(arr[:, :, 3] == 0))
        return (transparent_pixels / total_pixels) > threshold

    # Pillow fallback
    pixels = img.load()
    transparent_count = 0
    for y in range(h):
        for x in range(w):
            if pixels[x, y][3] == 0:
                transparent_count += 1
    return (transparent_count / total_pixels) > threshold


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


def _resolve_output_path(image_path: Path, args: argparse.Namespace) -> Path:
    """Resolve the output path for a processed sprite.

    If --output-dir is set, maps the image path into the output directory,
    preserving the directory structure relative to the processing root.
    Otherwise returns the original image_path (overwrite in place).
    """
    output_dir = getattr(args, "output_dir", None)
    if output_dir is None:
        return image_path

    output_dir_path = Path(output_dir)
    processing_root = getattr(args, "_processing_root", None)

    if processing_root is not None:
        try:
            relative = image_path.relative_to(processing_root)
        except ValueError:
            # Image is outside the processing root — use just the filename
            relative = Path(image_path.name)
    else:
        # Single file mode — use just the filename
        relative = Path(image_path.name)

    return output_dir_path / relative


def _backup_original(image_path: Path) -> bool:
    """Copy the original file to _originals/ subdirectory before overwriting.

    Uses shutil.copy2 to preserve file metadata. Creates _originals/
    directory if it doesn't exist. Returns True on success, False on error.
    """
    backup_dir = image_path.parent / "_originals"
    try:
        backup_dir.mkdir(parents=True, exist_ok=True)
        shutil.copy2(image_path, backup_dir / image_path.name)
        return True
    except (PermissionError, OSError) as e:
        print(f"  ERROR: Failed to backup {image_path.name}: {e}")
        return False


def dry_run_file(
    image_path: Path,
    args: argparse.Namespace,
    report_entries: Optional[list] = None,
) -> str:
    """Inspect a single file without modifying it (--dry-run mode).

    Opens the image, detects background color and confidence, checks if
    already transparent. Returns a status string describing what would
    happen to this file during a real run.
    When report_entries is provided, appends a dict with per-file metadata.
    """
    entry: Optional[dict] = None
    if report_entries is not None:
        entry = {
            "input_path": str(image_path),
            "output_path": None,
            "status": None,
            "background_color": None,
            "confidence": None,
            "pixels_removed": None,
            "removal_percentage": None,
            "crop_dimensions": None,
            "split_frame_count": None,
            "warnings": [],
            "errors": [],
        }

    try:
        img = Image.open(image_path).convert("RGBA")
    except PermissionError:
        if entry is not None:
            entry["status"] = "error"
            entry["errors"].append("Permission denied")
            report_entries.append(entry)
        return "ERROR: Permission denied"
    except Exception as e:
        if entry is not None:
            entry["status"] = "error"
            entry["errors"].append(str(e))
            report_entries.append(entry)
        return f"ERROR: Cannot open — {e}"

    w, h = img.size

    # Check already transparent
    if is_already_transparent(img):
        if entry is not None:
            entry["status"] = "skip"
            entry["warnings"].append("already transparent")
            report_entries.append(entry)
        return f"SKIP: already transparent ({w}x{h})"

    # Detect background
    bg_color, confidence = detect_background_color(img)

    r, g, b = bg_color
    confidence_str = f"{confidence:.0%}"
    if confidence < 0.3:
        confidence_str += " LOW"

    if entry is not None:
        entry["status"] = "would_process"
        entry["background_color"] = [r, g, b]
        entry["confidence"] = round(confidence, 4)
        report_entries.append(entry)

    return f"WOULD PROCESS: {w}x{h} — BG rgb({r},{g},{b}) ({confidence_str})"


def rip_sprite(
    image_path: Path,
    args: argparse.Namespace,
    progress_prefix: str = "",
    report_entries: Optional[list] = None,
) -> str:
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

    Returns status string: "processed", "skipped", or "failed".
    When report_entries is provided, appends a dict with per-file metadata.
    """
    tolerance: int = args.tolerance
    target_size: Optional[int] = args.scale
    save_preview: bool = not args.no_preview
    indent = "       " if progress_prefix else "  "

    # Report entry — populated incrementally during processing
    entry: Optional[dict] = None
    if report_entries is not None:
        entry = {
            "input_path": str(image_path),
            "output_path": None,
            "status": None,
            "background_color": None,
            "confidence": None,
            "pixels_removed": None,
            "removal_percentage": None,
            "crop_dimensions": None,
            "split_frame_count": None,
            "warnings": [],
            "errors": [],
        }

    try:
        img = Image.open(image_path).convert("RGBA")
    except Exception as e:
        if progress_prefix:
            print(f"{progress_prefix} ERROR — {e}")
        else:
            print(f"  ERROR {image_path}: {e}")
        if entry is not None:
            entry["status"] = "failed"
            entry["errors"].append(str(e))
            report_entries.append(entry)
        return "failed"

    w, h = img.size
    total_pixels = w * h

    # Check if image is already mostly transparent — skip processing
    if is_already_transparent(img):
        if progress_prefix:
            print(f"{progress_prefix} SKIP — already transparent")
        else:
            print(f"  SKIP: already transparent — {image_path.name}")
        if entry is not None:
            entry["status"] = "skipped"
            entry["warnings"].append("already transparent")
            report_entries.append(entry)
        return "skipped"

    # Step 1: Detect background
    bg_color, confidence = detect_background_color(img)
    r, g, b = bg_color
    conf_str = f"{confidence:.0%}"
    if confidence < 0.3:
        conf_str += " LOW"

    if entry is not None:
        entry["background_color"] = [r, g, b]
        entry["confidence"] = round(confidence, 4)

    # Step 2: Flood-fill remove from edges
    transparent_count = flood_fill_remove(img, bg_color, tolerance)

    # Step 3: Clean fringe (multi-pass)
    fringe_passes: int = getattr(args, "fringe_passes", 2)
    fringe_cleaned = clean_semitransparent_fringe(img, bg_color, passes=fringe_passes)
    transparent_count += fringe_cleaned

    if transparent_count == 0:
        # Check if image already has transparency
        has_alpha = any(img.getpixel((x, y))[3] < 255 for x in range(w) for y in range(min(3, h)))
        if progress_prefix:
            if has_alpha:
                print(f"{progress_prefix} SKIP — already has transparency")
            else:
                print(f"{progress_prefix} BG rgb({r},{g},{b}) ({conf_str}) → 0 removed (0.0%)")
        else:
            if has_alpha:
                print(f"  OK {image_path.name}: Already has transparency")
            else:
                print(f"  WARN {image_path.name}: No background removed — manual check needed")
        if entry is not None:
            entry["status"] = "skipped"
            entry["pixels_removed"] = 0
            entry["removal_percentage"] = 0.0
            if has_alpha:
                entry["warnings"].append("already has transparency")
            else:
                entry["warnings"].append("no background removed — manual check needed")
            report_entries.append(entry)
        return "skipped"

    # Print main progress line
    pct = (transparent_count / total_pixels) * 100
    if progress_prefix:
        print(f"{progress_prefix} BG rgb({r},{g},{b}) ({conf_str}) → {transparent_count} removed ({pct:.1f}%)")
    else:
        status = "OK" if pct > 20 else "WARN (low removal — check manually)"
        print(f"  {status} {image_path.name}: {transparent_count} pixels removed ({pct:.1f}%)")
    if fringe_cleaned > 0:
        print(f"{indent}+ {fringe_cleaned} fringe pixels cleaned")

    if entry is not None:
        entry["pixels_removed"] = transparent_count
        entry["removal_percentage"] = round(pct, 2)
        if pct <= 20:
            entry["warnings"].append("low removal percentage — check manually")

    # Step 4: Crop to content bounding box
    do_crop: bool = getattr(args, "crop", True)
    padding: int = getattr(args, "padding", 2)
    if do_crop:
        pre_crop_size = img.size
        img = crop_to_content(img, padding)
        if img.size != pre_crop_size:
            print(f"{indent}CROP: {pre_crop_size[0]}x{pre_crop_size[1]} → {img.size[0]}x{img.size[1]} (padding={padding})")
            if entry is not None:
                entry["crop_dimensions"] = {
                    "before": [pre_crop_size[0], pre_crop_size[1]],
                    "after": [img.size[0], img.size[1]],
                }

    # Step 5: Downscale if target specified
    if target_size:
        pre_scale_size = img.size
        img = downscale_nearest(img, target_size)
        print(f"{indent}SCALE: {pre_scale_size[0]}x{pre_scale_size[1]} → {img.size[0]}x{img.size[1]}")

    # Determine output path (--output-dir or overwrite in place)
    output_path = _resolve_output_path(image_path, args)

    if entry is not None:
        entry["output_path"] = str(output_path)

    # Create output directory if needed (--output-dir)
    if output_path != image_path:
        try:
            output_path.parent.mkdir(parents=True, exist_ok=True)
        except (PermissionError, OSError) as e:
            print(f"{indent}ERROR: Cannot create output directory {output_path.parent}: {e}")
            if entry is not None:
                entry["status"] = "failed"
                entry["errors"].append(f"Cannot create output directory: {e}")
                report_entries.append(entry)
            return "failed"

    # Backup original before overwriting (only when not using --output-dir)
    if getattr(args, "backup", False) and output_path == image_path:
        _backup_original(image_path)

    # Step 6: Split into individual frames (if --split-frames N specified)
    num_frames: Optional[int] = getattr(args, "split_frames", None)
    if num_frames is not None:
        frames = split_frames(img, num_frames)
        if frames is not None:
            stem = image_path.stem
            parent = output_path.parent
            for idx, frame in enumerate(frames, start=1):
                frame_name = f"{stem}_frame_{idx:02d}.png"
                frame_path = parent / frame_name
                try:
                    frame.save(frame_path, "PNG")
                except (PermissionError, OSError) as e:
                    print(f"{indent}ERROR: Failed to save frame {frame_path}: {e}")
                    if entry is not None:
                        entry["errors"].append(f"Failed to save frame {frame_name}: {e}")
            print(f"{indent}SPLIT: {len(frames)} frames ({frames[0].size[0]}x{frames[0].size[1]} each)")
            if entry is not None:
                entry["split_frame_count"] = len(frames)
        else:
            if entry is not None:
                entry["warnings"].append(f"split-frames {num_frames} skipped — validation failed")

    # Step 7: Save
    try:
        img.save(output_path, "PNG")
    except (PermissionError, OSError) as e:
        print(f"{indent}ERROR: Failed to save {output_path}: {e}")
        if entry is not None:
            entry["status"] = "failed"
            entry["errors"].append(f"Failed to save: {e}")
            report_entries.append(entry)
        return "failed"

    # Save preview with checkerboard
    if save_preview and transparent_count > 0:
        preview = _make_checkerboard(img.size[0], img.size[1])
        preview.paste(img, (0, 0), img)
        preview_path = output_path.with_name(output_path.stem + "_preview.png")
        try:
            preview.save(preview_path, "PNG")
        except (PermissionError, OSError) as e:
            print(f"{indent}ERROR: Failed to save preview {preview_path}: {e}")

    if entry is not None:
        entry["status"] = "processed"
        report_entries.append(entry)

    return "processed"


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


def _print_banner(args: argparse.Namespace, file_count: int, dry_run: bool = False) -> None:
    """Print config banner matching gemini_api_generate.py style."""
    print("\n" + "=" * 70)
    print("MOMI'S ADVENTURE — SPRITE RIPPER")
    print("=" * 70)
    print(f"\nTolerance: {args.tolerance}")
    crop_on = getattr(args, "crop", True)
    padding = getattr(args, "padding", 2)
    print(f"Crop: {'on' if crop_on else 'off'} (padding={padding})")
    fringe_passes = getattr(args, "fringe_passes", 2)
    print(f"Fringe passes: {fringe_passes}")
    print(f"Files: {file_count}")
    output_dir = getattr(args, "output_dir", None)
    if output_dir:
        print(f"Output: {output_dir}")
    else:
        print(f"Output: overwrite in-place")
    if args.scale:
        print(f"Scale: {args.scale}px (longest edge)")
    if getattr(args, "backup", False):
        print("Backup: on")
    split_frames_n = getattr(args, "split_frames", None)
    if split_frames_n:
        print(f"Split frames: {split_frames_n}")
    if getattr(args, "report", False):
        print("Report: _rip_report.json")
    if dry_run:
        print("\nMode: DRY RUN — no files will be modified")
    print("=" * 70)


def _write_report(
    report_path: Path,
    file_results: list[dict],
    summary: dict,
) -> None:
    """Write _rip_report.json with per-file results and summary stats.

    Uses json.dump with indent=2 for human-readable output. Converts
    Path objects to POSIX strings for JSON serialization.
    """
    report = {
        "summary": summary,
        "files": file_results,
    }
    try:
        report_path.parent.mkdir(parents=True, exist_ok=True)
        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        print(f"  Report: {report_path}")
    except (PermissionError, OSError) as e:
        print(f"  ERROR: Failed to write report {report_path}: {e}")


def process_directory(dir_path: Path, args: argparse.Namespace) -> None:
    """Process all PNGs in a directory (recursively)."""
    pngs = sorted(dir_path.rglob("*.png"))
    # Skip preview files, frame files from previous splits, and backup originals
    pngs = [p for p in pngs
            if "_preview" not in p.name
            and "_frame_" not in p.name
            and "_originals" not in p.parts]

    if not pngs:
        print(f"No PNG files found in {dir_path}")
        print("  Check the directory path and ensure it contains .png files.")
        return

    is_dry_run = getattr(args, "dry_run", False)
    is_report = getattr(args, "report", False)

    # Print config banner
    _print_banner(args, len(pngs), dry_run=is_dry_run)

    start_time = time.time()

    # Report collection — only when --report is active
    report_entries: Optional[list] = [] if is_report else None

    # Dry-run mode: discover and report without modifying files
    if is_dry_run:
        skipped = 0
        would_process = 0
        errors = 0
        for i, png in enumerate(pngs):
            result = dry_run_file(png, args, report_entries=report_entries)
            print(f"  [{i+1}/{len(pngs)}] {png.name}: {result}")
            if "SKIP" in result:
                skipped += 1
            elif "ERROR" in result:
                errors += 1
            else:
                would_process += 1

        elapsed = time.time() - start_time
        print("\n" + "=" * 70)
        print("DRY RUN COMPLETE")
        print("=" * 70)
        print(f"  Would process: {would_process}")
        print(f"  Would skip:    {skipped}")
        if errors:
            print(f"  Errors:        {errors}")
        print(f"  Total files:   {len(pngs)}")
        print(f"  Elapsed:       {elapsed:.1f}s")
        print("=" * 70)
        print("  No files were modified.")

        # Write report if requested
        if is_report and report_entries is not None:
            output_dir = getattr(args, "output_dir", None)
            report_root = Path(output_dir) if output_dir else dir_path
            report_path = report_root / "_rip_report.json"
            summary = {
                "mode": "dry_run",
                "total": len(pngs),
                "would_process": would_process,
                "skipped": skipped,
                "errors": errors,
                "elapsed_seconds": round(elapsed, 2),
            }
            _write_report(report_path, report_entries, summary)
        return

    processed = 0
    skipped = 0
    failed = 0

    for i, png in enumerate(pngs):
        # Auto-detect target size from parent folder name
        folder_name = png.parent.name
        auto_size = args.scale or TARGET_SIZES.get(folder_name)

        # Create per-file args with auto-detected scale
        file_args = argparse.Namespace(**vars(args))
        file_args.scale = auto_size

        prefix = f"  [{i+1}/{len(pngs)}] {png.name}:"

        try:
            result = rip_sprite(
                png, file_args, progress_prefix=prefix,
                report_entries=report_entries,
            )
            if result == "processed":
                processed += 1
            elif result == "failed":
                failed += 1
            else:
                skipped += 1
        except PermissionError as e:
            print(f"{prefix} ERROR — Permission denied: {e}")
            failed += 1
            if report_entries is not None:
                report_entries.append({
                    "input_path": str(png),
                    "output_path": None,
                    "status": "failed",
                    "background_color": None,
                    "confidence": None,
                    "pixels_removed": None,
                    "removal_percentage": None,
                    "crop_dimensions": None,
                    "split_frame_count": None,
                    "warnings": [],
                    "errors": [f"Permission denied: {e}"],
                })

    elapsed = time.time() - start_time

    print("\n" + "=" * 70)
    print("PROCESSING COMPLETE")
    print("=" * 70)
    print(f"  Processed: {processed}")
    print(f"  Skipped:   {skipped}")
    print(f"  Failed:    {failed}")
    print(f"  Total:     {len(pngs)}")
    print(f"  Elapsed:   {elapsed:.1f}s")
    print("=" * 70)

    # Write report if requested
    if is_report and report_entries is not None:
        output_dir = getattr(args, "output_dir", None)
        report_root = Path(output_dir) if output_dir else dir_path
        report_path = report_root / "_rip_report.json"
        summary = {
            "mode": "normal",
            "total": len(pngs),
            "processed": processed,
            "skipped": skipped,
            "failed": failed,
            "elapsed_seconds": round(elapsed, 2),
        }
        _write_report(report_path, report_entries, summary)


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

    # Additional processing flags
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

    # Resolve processing directory (--batch overrides default)
    if args.batch is not None:
        batch_dir = GENERATED_DIR / f"batch_{args.batch}"
        if not batch_dir.is_dir():
            print(f"ERROR: Batch directory not found: {batch_dir}")
            print(f"  Expected path: {batch_dir.resolve()}")
            print(f"  Available batches in {GENERATED_DIR}:")
            # List existing batch directories for helpful feedback
            batch_dirs = sorted(GENERATED_DIR.glob("batch_*")) if GENERATED_DIR.is_dir() else []
            if batch_dirs:
                for bd in batch_dirs:
                    print(f"    {bd.name}")
            else:
                print("    (none found)")
            sys.exit(1)
        target_dir = batch_dir
    else:
        target_dir = GENERATED_DIR

    if args.path and Path(args.path).is_file():
        image_path = Path(args.path)
        args._processing_root = image_path.parent
        is_report = getattr(args, "report", False)
        report_entries: Optional[list] = [] if is_report else None

        start_time = time.time()
        if args.dry_run:
            result = dry_run_file(image_path, args, report_entries=report_entries)
            print(f"  {image_path.name}: {result}")
        else:
            rip_sprite(image_path, args, report_entries=report_entries)
        elapsed = time.time() - start_time

        # Write report for single-file mode
        if is_report and report_entries is not None:
            output_dir = getattr(args, "output_dir", None)
            report_root = Path(output_dir) if output_dir else image_path.parent
            report_path = report_root / "_rip_report.json"
            # Derive counts from report entries
            statuses = [e.get("status", "") for e in report_entries]
            summary = {
                "mode": "dry_run" if args.dry_run else "normal",
                "total": len(report_entries),
                "processed": statuses.count("processed") + statuses.count("would_process"),
                "skipped": statuses.count("skipped") + statuses.count("skip"),
                "failed": statuses.count("failed") + statuses.count("error"),
                "elapsed_seconds": round(elapsed, 2),
            }
            _write_report(report_path, report_entries, summary)
    else:
        # Default: process target directory recursively
        if target_dir.is_dir():
            args._processing_root = target_dir
            process_directory(target_dir, args)
        else:
            print(f"No generated/ directory found at {target_dir}")
            print("Run: python art/rip_sprites.py --help")


if __name__ == "__main__":
    main()
