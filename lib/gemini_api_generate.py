#!/usr/bin/env python3
"""
Gemini Image Generator — Momi's Adventure (REST API)
=====================================================
Generates all game sprites using the Gemini REST API directly via httpx.
No google-genai SDK required — just httpx and Pillow.

Models (Nano Banana family):
    gemini-2.5-flash-image          Free tier, 1024px, up to 3 ref images
    gemini-3-pro-image-preview      Pro tier, up to 4K, up to 14 ref images

Usage:
    python gemini_api_generate.py                              # Generate all sprites
    python gemini_api_generate.py --category characters        # One category only
    python gemini_api_generate.py --single 5                   # One prompt by index
    python gemini_api_generate.py --list                       # Show all prompts
    python gemini_api_generate.py --reference-dir art/reference  # Use reference images
    python gemini_api_generate.py --model gemini-3-pro-image-preview  # Use Pro model

Requirements:
    pip install httpx Pillow
    Set GEMINI_API_KEY (or GOOGLE_API_KEY) environment variable or pass --api-key

API Key:
    Get one free at https://aistudio.google.com/apikey
"""

import json
import os
import sys
import time
import argparse
import pathlib
import base64
import io
from typing import Optional

# Load .env if possible
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

import httpx
from PIL import Image

# ── Paths ──────────────────────────────────────────────────────────────
SCRIPT_DIR = pathlib.Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
PROMPTS_FILE = PROJECT_ROOT / "art" / "prompts_v2_pixel_art.json"
GENERATED_DIR = PROJECT_ROOT / "art" / "generated"
STYLE_CONTEXT_FILE = PROJECT_ROOT / "art" / "style_context.txt"

# ── API Config ─────────────────────────────────────────────────────────
API_BASE = "https://generativelanguage.googleapis.com/v1beta/models"
DEFAULT_MODEL = "gemini-3-pro-image-preview"
RATE_LIMIT_DELAY = 5.0   # seconds between requests
RETRY_DELAY = 30.0       # seconds to wait on rate limit error
MAX_RETRIES = 3
MAX_REFERENCE_IMAGES = 14  # Pro supports up to 14; Flash up to 3

# Aspect ratios: "1:1","2:3","3:2","3:4","4:3","4:5","5:4","9:16","16:9","21:9"
DEFAULT_ASPECT_RATIO = "1:1"
# Image sizes (Pro only): "1K", "2K", "4K"  — must be uppercase K
DEFAULT_IMAGE_SIZE = "1K"


def load_style_context() -> str:
    """Load the style context prefix from art/style_context.txt."""
    if STYLE_CONTEXT_FILE.exists():
        with open(STYLE_CONTEXT_FILE, "r", encoding="utf-8") as f:
            return f.read().strip()
    return ""


def image_to_base64(img: Image.Image, fmt: str = "PNG") -> str:
    """Convert a PIL Image to base64 string."""
    buf = io.BytesIO()
    img.save(buf, format=fmt)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def _load_image_as_part(img_file: pathlib.Path) -> Optional[dict]:
    """Load a single image file as a base64 API part. Returns None on failure."""
    try:
        img = Image.open(img_file)
        if img.mode == 'RGBA':
            background = Image.new('RGB', img.size, (255, 255, 255))
            background.paste(img, mask=img.split()[3])
            img = background
        elif img.mode != 'RGB':
            img = img.convert('RGB')
        if max(img.size) > 1024:
            ratio = 1024 / max(img.size)
            new_size = (int(img.size[0] * ratio), int(img.size[1] * ratio))
            img = img.resize(new_size, Image.LANCZOS)

        mime = "image/jpeg" if img_file.suffix.lower() in ('.jpg', '.jpeg') else "image/png"
        fmt = "JPEG" if "jpeg" in mime else "PNG"
        b64 = image_to_base64(img, fmt)
        return {"inlineData": {"mimeType": mime, "data": b64}}
    except Exception as e:
        print(f"  WARN: Could not load {img_file.name}: {e}")
        return None


def load_reference_images(ref_dir: str, max_images: int = MAX_REFERENCE_IMAGES) -> list[dict]:
    """Load reference images as base64 parts for the REST API.

    Returns list of dicts: {"inlineData": {"mimeType": "image/png", "data": "<b64>"}}
    """
    ref_path = pathlib.Path(ref_dir)
    if not ref_path.exists():
        print(f"WARN: Reference directory {ref_dir} not found, continuing without references")
        return []

    image_files = sorted(
        [f for f in ref_path.iterdir()
         if f.suffix.lower() in ('.png', '.jpg', '.jpeg')
         and f.stat().st_size < 10_000_000],
        key=lambda f: f.name
    )[:max_images]

    if not image_files:
        print(f"WARN: No valid images found in {ref_dir}")
        return []

    parts = []
    for img_file in image_files:
        part = _load_image_as_part(img_file)
        if part:
            parts.append(part)
            print(f"  REF: Loaded {img_file.name}")

    print(f"  REF: {len(parts)} reference image(s) loaded")
    return parts


def load_character_references(ref_dir: str) -> dict[str, list[dict]]:
    """Load per-character reference images from subdirectories.

    Expected structure:
        art/reference/momi/momi_idle.png
        art/reference/cinnamon/cinnamon_idle.png
        art/reference/philo/philo_idle.png
        art/reference/shared/style_ref.png       (applied to ALL prompts)

    Returns dict: {"momi": [parts...], "cinnamon": [parts...], "shared": [parts...], ...}
    """
    ref_path = pathlib.Path(ref_dir)
    if not ref_path.exists():
        print(f"WARN: Character reference directory {ref_dir} not found")
        return {}

    char_refs: dict[str, list[dict]] = {}

    for subdir in sorted(ref_path.iterdir()):
        if not subdir.is_dir():
            # Also load loose files in root as "shared"
            if subdir.suffix.lower() in ('.png', '.jpg', '.jpeg'):
                part = _load_image_as_part(subdir)
                if part:
                    char_refs.setdefault("shared", []).append(part)
                    print(f"  REF: Loaded shared/{subdir.name}")
            continue

        char_name = subdir.name.lower()
        image_files = sorted(
            [f for f in subdir.iterdir()
             if f.suffix.lower() in ('.png', '.jpg', '.jpeg')
             and f.stat().st_size < 10_000_000],
            key=lambda f: f.name
        )[:MAX_REFERENCE_IMAGES]

        parts = []
        for img_file in image_files:
            part = _load_image_as_part(img_file)
            if part:
                parts.append(part)
                print(f"  REF: Loaded {char_name}/{img_file.name}")

        if parts:
            char_refs[char_name] = parts
            print(f"  REF: {char_name} — {len(parts)} reference(s)")

    total = sum(len(v) for v in char_refs.values())
    print(f"  REF: {total} total character reference(s) across {len(char_refs)} group(s)")
    return char_refs


def load_prompts() -> dict:
    """Load prompts from art/prompts_v2_pixel_art.json or fall back to art/prompts.json."""
    if PROMPTS_FILE.exists():
        with open(PROMPTS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)

    fallback = PROJECT_ROOT / "art" / "prompts.json"
    if fallback.exists():
        print(f"INFO: {PROMPTS_FILE} not found, using fallback {fallback}")
        with open(fallback, "r", encoding="utf-8") as f:
            return json.load(f)

    print(f"ERROR: No prompts file found at {PROMPTS_FILE} or {fallback}!")
    sys.exit(1)


def flatten_prompts(data: dict, category_filter: Optional[str] = None) -> list[dict]:
    """Flatten all prompts into a list with category info attached.

    Composes full_prompt as: style_context + character_identity + prompt + global_suffix.
    Character identity is injected RIGHT BEFORE the prompt so Gemini doesn't lose
    track of colors/markings buried at the top of a long style context.
    """
    style_ctx = load_style_context()
    global_suffix = data.get("global_suffix", "")

    # Character appearance blocks — injected adjacent to each prompt
    # so the AI never loses track of colors/markings
    CHARACTER_APPEARANCE = {
        "momi": (
            "[CHARACTER APPEARANCE — MOMI]\n"
            "Momi is a French Bulldog. Her coat is PRIMARILY BLACK with brown/dark brown brindle streaks mixed in — "
            "she is a DARK dog, NOT a brown dog. The black dominates, the brown brindle is subtle secondary striping. "
            "Use stippling/dithering to show the brindle texture. Her face is ALL BLACK — no tan, no brown, no light "
            "patches on forehead or cheeks. Only white on her face is a small patch of white on her CHIN. She has a "
            "white tuxedo chest patch. BIG, round, adorable BROWN EYES — her most important feature. Her eyes must be "
            "large, shiny, ultra-expressive with visible highlights/catchlights. Think Puss in Boots cute energy. "
            "They MUST stand out against the dark face as the clear focal point of every sprite. Classic dark "
            "rounded bat ears. Compact sturdy body. NO TAIL — just a very short nub (tiny bump, barely visible). "
            "NO COLLAR, NO ACCESSORIES — she is unequipped by default.\n"
            "IMPORTANT: Momi reads as a BLACK dog from a distance. The brown brindle is only visible up close. "
            "Do NOT make her look brown or tan overall.\n"
            "Key colors: Body #1a1a1a (black, DOMINANT), brindle streaks #3d2b1a (dark brown, SUBTLE), "
            "chin white #ffffff, chest white #ffffff, eyes brown #8B4513."
        ),
        "cinnamon": (
            "[CHARACTER APPEARANCE — CINNAMON]\n"
            "Cinnamon is an English Bulldog with BLACK AND TAN coloring (dark black base coat with tan/brown points "
            "on her eyebrows, cheeks, legs, and chest). She has a white blaze on her face and chest. Wrinkly face "
            "with a pronounced underbite showing bottom teeth. Stocky TANK BUILD with a wide barrel chest and short "
            "bowed legs. NO HARNESS, NO VEST, NO ACCESSORIES — she is unequipped by default.\n"
            "Key colors: Base coat #1a1a1a (black), tan points #C49A5C, white blaze #ffffff, "
            "eyes brown #8B4513."
        ),
        "philo": (
            "[CHARACTER APPEARANCE — PHILO]\n"
            "Philo is a senior Boston Terrier with a classic BLACK AND WHITE TUXEDO pattern (black/dark grey body, "
            "white chest, white blaze on face). He has a GREY MUZZLE showing his age. Wise patient eyes. Pointed ears "
            "(one often slightly more perked than the other). Slim compact build. "
            "NO BANDANA, NO ACCESSORIES — he is unequipped by default.\n"
            "Key colors: Body #4D4D59 (dark grey), white markings #ffffff, grey muzzle #808080, "
            "eyes brown #8B4513."
        ),
    }

    prompts = []
    for cat in data.get("categories", []):
        cat_name = cat["name"]
        cat_folder = cat["folder"]
        if category_filter and cat_name != category_filter:
            continue
        for p in cat["prompts"]:
            full_prompt = ""
            if style_ctx:
                full_prompt += f"{style_ctx}\n\n"

            # Inject character appearance RIGHT BEFORE the sprite request
            prompt_id = p["id"]
            for char_prefix, appearance in CHARACTER_APPEARANCE.items():
                if prompt_id.startswith(char_prefix + "_"):
                    full_prompt += f"{appearance}\n\n"
                    break

            full_prompt += f"[GENERATE THIS SPRITE]\n{p['prompt']}"

            if global_suffix:
                full_prompt += f"\n\nStyle requirements: {global_suffix}"

            prompts.append({
                "id": p["id"],
                "filename": p["filename"],
                "prompt": p["prompt"],
                "full_prompt": full_prompt,
                "category": cat_name,
                "folder": cat_folder,
                "output_path": GENERATED_DIR / cat_folder / p["filename"],
            })
    return prompts


def ensure_directories(data: dict) -> None:
    """Create all category subdirectories under art/generated/."""
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    for cat in data.get("categories", []):
        (GENERATED_DIR / cat["folder"]).mkdir(exist_ok=True)


def list_prompts(data: dict) -> None:
    """Display all available prompts grouped by category."""
    style_ctx = load_style_context()
    print("\n" + "=" * 70)
    print("MOMI'S ADVENTURE - ART PROMPT LIST")
    print("=" * 70)
    if style_ctx:
        preview = style_ctx.replace('\n', ' ')[:80]
        print(f"\nStyle context: \"{preview}...\"")
    else:
        print("\nStyle context: (none — create art/style_context.txt)")

    idx = 0
    total = 0
    existing = 0
    for cat in data.get("categories", []):
        cat_prompts = cat["prompts"]
        print(f"\n-- {cat['name'].upper()} ({cat['folder']}/) - {len(cat_prompts)} prompts --")
        for p in cat_prompts:
            out = GENERATED_DIR / cat["folder"] / p["filename"]
            exists = out.exists()
            mark = "[x]" if exists else "[ ]"
            if exists:
                existing += 1
            print(f"  {mark} {idx:>3}  {p['id']:<35} -> {p['filename']}")
            idx += 1
            total += 1

    print(f"\n{'=' * 70}")
    print(f"Total: {total} prompts across {len(data.get('categories', []))} categories")
    print(f"Existing: {existing} / {total}")
    print(f"Remaining: {total - existing}")
    print(f"{'=' * 70}")


def generate_image(
    api_key: str,
    prompt: str,
    output_path: pathlib.Path,
    model: str = DEFAULT_MODEL,
    reference_parts: Optional[list[dict]] = None,
    aspect_ratio: str = DEFAULT_ASPECT_RATIO,
    image_size: str = DEFAULT_IMAGE_SIZE,
) -> bool:
    """Generate a single image via Gemini REST API and save to disk.

    POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent
    """
    url = f"{API_BASE}/{model}:generateContent"
    headers = {
        "Content-Type": "application/json",
        "x-goog-api-key": api_key,
    }

    # Build parts: reference images first, then text prompt
    parts = []
    if reference_parts:
        parts.extend(reference_parts)
    parts.append({"text": prompt})

    # Build generation config
    generation_config: dict = {
        "responseModalities": ["IMAGE"],
    }

    # imageConfig for aspect ratio and size
    image_config: dict = {}
    if aspect_ratio:
        image_config["aspectRatio"] = aspect_ratio
    if image_size and "pro" in model.lower():
        image_config["imageSize"] = image_size
    if image_config:
        generation_config["imageConfig"] = image_config

    body = {
        "contents": [{"parts": parts}],
        "generationConfig": generation_config,
    }

    for attempt in range(MAX_RETRIES):
        try:
            resp = httpx.post(url, headers=headers, json=body, timeout=120.0)

            if resp.status_code == 429:
                wait = RETRY_DELAY * (attempt + 1)
                print(f"    ... Rate limited (429) — waiting {wait:.0f}s (attempt {attempt+1}/{MAX_RETRIES})")
                time.sleep(wait)
                continue

            if resp.status_code != 200:
                error_msg = resp.text[:200]
                print(f"    X HTTP {resp.status_code}: {error_msg}")
                if attempt < MAX_RETRIES - 1:
                    time.sleep(RETRY_DELAY)
                    continue
                return False

            data = resp.json()

            # Check for prompt feedback / blocking
            if "promptFeedback" in data:
                feedback = data["promptFeedback"]
                if "blockReason" in feedback:
                    print(f"    ! Blocked by safety filter: {feedback['blockReason']}")
                    return False

            # Extract image from candidates → content → parts → inlineData
            candidates = data.get("candidates", [])
            if not candidates:
                print(f"    ! No candidates in response")
                if "error" in data:
                    print(f"    ! Error: {data['error'].get('message', data['error'])}")
                return False

            content = candidates[0].get("content", {})
            resp_parts = content.get("parts", [])

            for part in resp_parts:
                inline = part.get("inlineData")
                if inline and "data" in inline:
                    # Decode base64 image data
                    img_bytes = base64.b64decode(inline["data"])
                    output_path.parent.mkdir(parents=True, exist_ok=True)

                    # Save raw bytes first
                    with open(output_path, "wb") as f:
                        f.write(img_bytes)

                    # Verify it's a valid image
                    try:
                        img = Image.open(output_path)
                        img.verify()
                    except Exception as ve:
                        print(f"    ! Image verification failed: {ve}")
                        output_path.unlink(missing_ok=True)
                        return False

                    return True

                # Also check for text parts (thinking/explanation)
                if "text" in part:
                    pass  # Ignore text parts, we only want images

            print(f"    ! No image data found in response parts")
            return False

        except httpx.TimeoutException:
            print(f"    ... Timeout — waiting {RETRY_DELAY:.0f}s (attempt {attempt+1}/{MAX_RETRIES})")
            time.sleep(RETRY_DELAY)
            continue
        except Exception as e:
            print(f"    X Error: {e}")
            if attempt < MAX_RETRIES - 1:
                time.sleep(RETRY_DELAY)
                continue
            return False

    print(f"    X Failed after {MAX_RETRIES} retries")
    return False


def run_generation(
    prompts: list[dict],
    api_key: str,
    model: str = DEFAULT_MODEL,
    skip_existing: bool = True,
    dry_run: bool = False,
    delay: float = RATE_LIMIT_DELAY,
    reference_parts: Optional[list[dict]] = None,
    character_refs: Optional[dict[str, list[dict]]] = None,
    aspect_ratio: str = DEFAULT_ASPECT_RATIO,
    image_size: str = DEFAULT_IMAGE_SIZE,
) -> dict:
    """Run image generation for all prompts. Returns stats dict.

    reference_parts: Global references applied to ALL prompts (--reference-dir)
    character_refs:  Per-character references (--character-refs)
                     Keys like "momi", "cinnamon", "philo", "shared"
                     "shared" refs are applied to ALL prompts alongside character-specific ones
    """
    global_ref_count = len(reference_parts) if reference_parts else 0
    char_ref_count = sum(len(v) for v in character_refs.values()) if character_refs else 0

    stats = {"generated": 0, "skipped": 0, "failed": 0, "total": len(prompts)}
    failed_prompts = []

    print("\n" + "=" * 70)
    print("MOMI'S ADVENTURE — GEMINI IMAGE GENERATOR (REST API)")
    print("=" * 70)
    print(f"\nModel: {model}")
    print(f"Prompts: {len(prompts)}")
    print(f"Global reference images: {global_ref_count}")
    if character_refs:
        print(f"Character references: {char_ref_count} across {len(character_refs)} group(s)")
        for cname, cparts in character_refs.items():
            print(f"  {cname}: {len(cparts)} ref(s)")
    print(f"Aspect ratio: {aspect_ratio}")
    if "pro" in model.lower():
        print(f"Image size: {image_size}")
    print(f"Style context: {'loaded' if load_style_context() else 'none'}")
    print(f"Skip existing: {skip_existing}")
    print(f"Output: {GENERATED_DIR}/")
    print(f"Rate limit delay: {delay}s between requests")
    if dry_run:
        print("DRY RUN — no images will be generated")
    print("=" * 70)

    # Known character prefixes for matching
    CHAR_PREFIXES = ["momi", "cinnamon", "philo"]

    for i, p in enumerate(prompts):
        prefix = f"[{i+1}/{len(prompts)}]"
        name = f"{p['category']}/{p['id']}"
        out = p["output_path"]

        if skip_existing and out.exists():
            print(f"  {prefix} SKIP {name} (already exists)")
            stats["skipped"] += 1
            continue

        # Build per-prompt reference list
        prompt_refs = list(reference_parts) if reference_parts else []

        if character_refs:
            # Add shared refs (apply to all)
            prompt_refs.extend(character_refs.get("shared", []))

            # Add character-specific refs
            prompt_id = p["id"]
            for char_prefix in CHAR_PREFIXES:
                if prompt_id.startswith(char_prefix + "_") and char_prefix in character_refs:
                    prompt_refs.extend(character_refs[char_prefix])
                    break

        ref_tag = f" (+{len(prompt_refs)} refs)" if prompt_refs else ""
        print(f"  {prefix} {name} -> {p['folder']}/{p['filename']}{ref_tag}")

        if dry_run:
            stats["generated"] += 1
            continue

        success = generate_image(
            api_key=api_key,
            prompt=p["full_prompt"],
            output_path=out,
            model=model,
            reference_parts=prompt_refs if prompt_refs else None,
            aspect_ratio=aspect_ratio,
            image_size=image_size,
        )

        if success:
            size = out.stat().st_size
            print(f"    OK Saved ({size:,} bytes)")
            stats["generated"] += 1
        else:
            stats["failed"] += 1
            failed_prompts.append(p)

        # Rate limit delay between requests
        if i < len(prompts) - 1:
            time.sleep(delay)

    # Summary
    print("\n" + "=" * 70)
    print("GENERATION COMPLETE")
    print("=" * 70)
    print(f"  Generated: {stats['generated']}")
    print(f"  Skipped:   {stats['skipped']}")
    print(f"  Failed:    {stats['failed']}")
    print(f"  Total:     {stats['total']}")

    if failed_prompts:
        print(f"\nFailed prompts:")
        for fp in failed_prompts:
            print(f"  - {fp['category']}/{fp['id']}: {fp['filename']}")
        print(f"\nRetry failed: python {__file__} --no-skip-existing --category <cat>")

    print(f"\nNext step: python art/rip_sprites.py")
    print("=" * 70)

    return stats


def main():
    # Windows UTF-8 console support
    if sys.platform == "win32":
        try:
            sys.stdout.reconfigure(encoding="utf-8")
            sys.stderr.reconfigure(encoding="utf-8")
        except Exception:
            pass

    parser = argparse.ArgumentParser(
        description="Generate Momi's Adventure sprites via Gemini REST API",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
Models (Nano Banana family):
  gemini-2.5-flash-image           Free tier, 1024px max, up to 3 refs
  gemini-3-pro-image-preview       Pro tier, up to 4K, up to 14 refs

Examples:
  python gemini_api_generate.py --list                  List all prompts
  python gemini_api_generate.py                         Generate all (Pro)
  python gemini_api_generate.py --model gemini-2.5-flash-image     Use free tier
  python gemini_api_generate.py --category enemies      Generate only enemies
  python gemini_api_generate.py --single 5              Generate prompt index 5
  python gemini_api_generate.py --dry-run               Preview without generating
  python gemini_api_generate.py -r art/reference        Use reference images
        """,
    )
    parser.add_argument("--list", "-l", action="store_true",
                        help="List all available prompts grouped by category")
    parser.add_argument("--category", "-c",
                        choices=["characters", "enemies", "tiles"],
                        help="Generate only prompts from one category")
    parser.add_argument("--single", "-s", type=int, metavar="INDEX",
                        help="Generate a single prompt by global index (see --list)")
    parser.add_argument("--api-key", "-k",
                        help="Google API key (or set GEMINI_API_KEY / GOOGLE_API_KEY)")
    parser.add_argument("--model", "-m", default=DEFAULT_MODEL,
                        help=f"Gemini model to use (default: {DEFAULT_MODEL})")
    parser.add_argument("--reference-dir", "-r",
                        help="Directory of reference images applied to ALL prompts")
    parser.add_argument("--character-refs",
                        help="Directory with per-character subdirs (e.g. art/reference/momi/, art/reference/cinnamon/)")
    parser.add_argument("--max-refs", type=int, default=MAX_REFERENCE_IMAGES,
                        help=f"Maximum reference images to load (default: {MAX_REFERENCE_IMAGES})")
    parser.add_argument("--aspect-ratio", default=DEFAULT_ASPECT_RATIO,
                        choices=["1:1", "2:3", "3:2", "3:4", "4:3", "4:5", "5:4", "9:16", "16:9", "21:9"],
                        help=f"Output aspect ratio (default: {DEFAULT_ASPECT_RATIO})")
    parser.add_argument("--image-size", default=DEFAULT_IMAGE_SIZE,
                        choices=["1K", "2K", "4K"],
                        help=f"Output resolution, Pro model only (default: {DEFAULT_IMAGE_SIZE})")
    parser.add_argument("--skip-existing", action="store_true", default=True,
                        help="Skip prompts whose output file already exists (default)")
    parser.add_argument("--no-skip-existing", action="store_true",
                        help="Regenerate all prompts even if output exists")
    parser.add_argument("--dry-run", action="store_true",
                        help="Preview what would be generated without making API calls")
    parser.add_argument("--delay", type=float, default=RATE_LIMIT_DELAY,
                        help=f"Seconds between API calls (default: {RATE_LIMIT_DELAY})")

    args = parser.parse_args()

    # Load prompts
    data = load_prompts()
    ensure_directories(data)

    # List mode — no API key needed
    if args.list:
        list_prompts(data)
        return

    # Resolve API key
    api_key = args.api_key or os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key and not args.dry_run:
        print("ERROR: No API key provided!")
        print("")
        print("Get a free key at: https://aistudio.google.com/apikey")
        print("")
        print("Then either:")
        print("  set GEMINI_API_KEY=your_key_here       (Windows)")
        print("  export GEMINI_API_KEY=your_key_here     (Linux/Mac)")
        print("  python gemini_api_generate.py --api-key your_key_here")
        print("  echo GEMINI_API_KEY=your_key_here > .env")
        sys.exit(1)

    # Load reference images if provided
    ref_parts = []
    if args.reference_dir:
        print(f"\nLoading global reference images from: {args.reference_dir}")
        ref_parts = load_reference_images(args.reference_dir, max_images=args.max_refs)

    # Load per-character references if provided
    char_refs: dict[str, list[dict]] = {}
    if args.character_refs:
        print(f"\nLoading per-character references from: {args.character_refs}")
        char_refs = load_character_references(args.character_refs)

    # Build prompt list
    skip = args.skip_existing and not args.no_skip_existing

    if args.single is not None:
        all_prompts = flatten_prompts(data)
        if 0 <= args.single < len(all_prompts):
            prompts = [all_prompts[args.single]]
        else:
            print(f"ERROR: Index {args.single} out of range (0-{len(all_prompts)-1})")
            sys.exit(1)
    else:
        prompts = flatten_prompts(data, category_filter=args.category)

    if not prompts:
        print("No prompts to generate!")
        return

    # Run
    try:
        run_generation(
            prompts=prompts,
            api_key=api_key or "",
            model=args.model,
            skip_existing=skip,
            dry_run=args.dry_run,
            delay=args.delay,
            reference_parts=ref_parts,
            character_refs=char_refs if char_refs else None,
            aspect_ratio=args.aspect_ratio,
            image_size=args.image_size,
        )
    except KeyboardInterrupt:
        print("\n\nInterrupted by user. Partial progress saved.")
        print("Re-run to continue (skip-existing will resume where you left off).")
        sys.exit(0)


if __name__ == "__main__":
    main()
