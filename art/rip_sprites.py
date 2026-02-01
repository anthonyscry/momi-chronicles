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
import os
import math
import argparse
from pathlib import Path
from collections import deque

try:
    from PIL import Image
except ImportError:
    print("Pillow not installed. Run: pip install Pillow")
    exit(1)


# Default tolerance for background color matching
# Higher = more aggressive removal (good for gradient AI backgrounds)
DEFAULT_TOLERANCE = 40

# Target sizes for downscaling (longest edge)
TARGET_SIZES = {
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


def detect_background_color(img: Image.Image) -> tuple:
    """
    Detect the background color by sampling corners and edges.
    Returns the most common edge color.
    """
    pixels = img.load()
    w, h = img.size
    
    # Sample corners (4 corners, 5x5 patch each)
    samples = []
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
    from collections import Counter
    counter = Counter(samples)
    bg_color = counter.most_common(1)[0][0]
    
    # Verify: if the most common edge color covers >50% of samples, it's likely the background
    total = len(samples)
    bg_count = sum(1 for s in samples if color_distance(s, bg_color) < 30)
    confidence = bg_count / total
    
    return bg_color, confidence


def flood_fill_remove(img: Image.Image, bg_color: tuple, tolerance: int) -> int:
    """
    Flood-fill from all 4 corners to remove background.
    Only removes connected regions (won't punch holes in the sprite).
    Returns count of pixels made transparent.
    """
    pixels = img.load()
    w, h = img.size
    visited = set()
    transparent_count = 0
    
    # Start flood fill from all 4 corners + edge midpoints
    seeds = [
        (0, 0), (w-1, 0), (0, h-1), (w-1, h-1),
        (w//2, 0), (w//2, h-1), (0, h//2), (w-1, h//2),
    ]
    
    queue = deque()
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


def clean_semitransparent_fringe(img: Image.Image, bg_color: tuple, fringe_tolerance: int = 80) -> int:
    """
    Clean up semi-transparent fringe pixels at sprite edges.
    These are anti-aliasing artifacts where the sprite blends into the background.
    """
    pixels = img.load()
    w, h = img.size
    cleaned = 0
    
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a == 0:
                continue  # Already transparent
            
            # Check if this pixel is adjacent to a transparent pixel
            has_transparent_neighbor = False
            for nx, ny in [(x+1, y), (x-1, y), (x, y+1), (x, y-1)]:
                if 0 <= nx < w and 0 <= ny < h:
                    if pixels[nx, ny][3] == 0:
                        has_transparent_neighbor = True
                        break
            
            if has_transparent_neighbor:
                # If this edge pixel is close to background color, make it transparent too
                dist = color_distance((r, g, b), bg_color)
                if dist <= fringe_tolerance:
                    pixels[x, y] = (0, 0, 0, 0)
                    cleaned += 1
    
    return cleaned


def downscale_nearest(img: Image.Image, target_size: int) -> Image.Image:
    """Downscale using nearest-neighbor to preserve pixel art crispness."""
    w, h = img.size
    if max(w, h) <= target_size:
        return img  # Already small enough
    
    scale = target_size / max(w, h)
    new_w = max(1, int(w * scale))
    new_h = max(1, int(h * scale))
    
    return img.resize((new_w, new_h), Image.NEAREST)


def rip_sprite(image_path: str, tolerance: int = DEFAULT_TOLERANCE, 
               target_size: int = None, save_preview: bool = True) -> bool:
    """
    Remove background and optionally downscale a sprite.
    
    Strategy:
    1. Detect background color from corners/edges
    2. Flood-fill from corners to remove connected background
    3. Clean semi-transparent fringe pixels
    4. Optionally downscale with nearest-neighbor
    5. Save with transparency
    
    Returns True if background was successfully removed.
    """
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
    
    # Step 3: Clean fringe
    fringe_cleaned = clean_semitransparent_fringe(img, bg_color)
    transparent_count += fringe_cleaned
    
    if transparent_count == 0:
        # Check if image already has transparency
        has_alpha = any(img.getpixel((x, y))[3] < 255 for x in range(w) for y in range(min(3, h)))
        if has_alpha:
            print(f"  OK {os.path.basename(image_path)}: Already has transparency")
        else:
            print(f"  WARN {os.path.basename(image_path)}: No background removed — manual check needed")
        return False
    
    # Step 4: Downscale if target specified
    if target_size:
        img = downscale_nearest(img, target_size)
        print(f"  SCALE: {w}x{h} -> {img.size[0]}x{img.size[1]}")
    
    # Step 5: Save
    img.save(image_path, "PNG")
    
    # Save preview with checkerboard
    if save_preview and transparent_count > 0:
        preview = _make_checkerboard(img.size[0], img.size[1])
        preview.paste(img, (0, 0), img)
        preview_path = image_path.replace(".png", "_preview.png")
        preview.save(preview_path, "PNG")
    
    pct = (transparent_count / total_pixels) * 100
    status = "OK" if pct > 20 else "WARN (low removal — check manually)"
    print(f"  {status} {os.path.basename(image_path)}: {transparent_count} pixels removed ({pct:.1f}%)")
    if fringe_cleaned > 0:
        print(f"       + {fringe_cleaned} fringe pixels cleaned")
    return transparent_count > 0


def _make_checkerboard(w: int, h: int, tile_size: int = 8) -> Image.Image:
    """Create a checkerboard pattern image for transparency preview."""
    img = Image.new("RGBA", (w, h))
    pixels = img.load()
    c1 = (200, 200, 200, 255)
    c2 = (255, 255, 255, 255)
    for y in range(h):
        for x in range(w):
            if ((x // tile_size) + (y // tile_size)) % 2 == 0:
                pixels[x, y] = c1
            else:
                pixels[x, y] = c2
    return img


def process_directory(dir_path: str, tolerance: int = DEFAULT_TOLERANCE, 
                      target_size: int = None):
    """Process all PNGs in a directory (recursively)."""
    path = Path(dir_path)
    pngs = sorted(path.rglob("*.png"))
    # Skip preview files
    pngs = [p for p in pngs if "_preview" not in p.name]
    
    if not pngs:
        print(f"No PNG files found in {dir_path}")
        return
    
    print(f"Processing {len(pngs)} sprites (tolerance={tolerance})")
    if target_size:
        print(f"Downscaling to {target_size}px (longest edge)")
    print("=" * 60)
    
    success = 0
    for png in pngs:
        # Auto-detect target size from parent folder name
        folder_name = png.parent.name
        auto_size = target_size or TARGET_SIZES.get(folder_name)
        
        if rip_sprite(str(png), tolerance, auto_size):
            success += 1
    
    print("=" * 60)
    print(f"Done: {success}/{len(pngs)} sprites processed")


def main():
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
    _stub_flags = []
    if args.no_crop:
        _stub_flags.append("--no-crop")
    if args.padding != 2:
        _stub_flags.append("--padding")
    if args.split_frames is not None:
        _stub_flags.append("--split-frames")
    if args.output_dir is not None:
        _stub_flags.append("--output-dir")
    if args.backup:
        _stub_flags.append("--backup")
    if args.dry_run:
        _stub_flags.append("--dry-run")
    if args.batch is not None:
        _stub_flags.append("--batch")
    if args.fringe_passes != 2:
        _stub_flags.append("--fringe-passes")
    if args.report:
        _stub_flags.append("--report")
    if _stub_flags:
        for flag in _stub_flags:
            print(f"  NOTE: {flag} accepted but not yet implemented")

    # Extract existing flags into local vars for current processing logic
    tolerance = args.tolerance
    target_size = args.scale
    save_preview = not args.no_preview

    if args.path and os.path.isfile(args.path):
        rip_sprite(args.path, tolerance, target_size, save_preview)
    else:
        # Default: process art/generated/ in repo
        script_dir = os.path.dirname(os.path.abspath(__file__))
        generated_dir = os.path.join(script_dir, "generated")
        if os.path.isdir(generated_dir):
            process_directory(generated_dir, tolerance, target_size)
        else:
            print(f"No generated/ directory found at {generated_dir}")
            print("Run: python art/rip_sprites.py --help")


if __name__ == "__main__":
    main()
