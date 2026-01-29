#!/usr/bin/env python3
"""
Gemini API Image Generator — Momi's Adventure
===============================================
Generates all game sprites from art/prompts.json using the Google Gemini API
(Imagen model). Fully automated — no browser needed.

Usage:
    python gemini_api_generate.py                      # Generate all 96 sprites
    python gemini_api_generate.py --category characters # One category only
    python gemini_api_generate.py --single 5            # One prompt by index
    python gemini_api_generate.py --list                # Show all prompts
    python gemini_api_generate.py --model gemini-2.5-flash-image   # Use Gemini 2.5 Flash

Requirements:
    pip install google-genai Pillow
    Set GOOGLE_API_KEY environment variable or pass --api-key

API Key:
    Get one free at https://aistudio.google.com/apikey
"""

import json
import os
import sys
import time
import argparse
import pathlib
from typing import Optional

try:
    from google import genai
    from google.genai import types
except ImportError:
    print("google-genai not installed. Run:")
    print("  pip install google-genai")
    sys.exit(1)

# Paths
SCRIPT_DIR = pathlib.Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
PROMPTS_FILE = PROJECT_ROOT / "art" / "prompts.json"
GENERATED_DIR = PROJECT_ROOT / "art" / "generated"

# Defaults
# Image generation models (in preference order):
#   gemini-2.0-flash-exp-image-generation  - uses TEXT+IMAGE modalities
#   gemini-2.5-flash-image                 - uses IMAGE modality
#   gemini-3-pro-image-preview             - uses IMAGE modality
DEFAULT_MODEL = "gemini-2.0-flash-exp-image-generation"
RATE_LIMIT_DELAY = 6.0   # seconds between requests (free tier: ~10/min for image gen)
RETRY_DELAY = 40.0       # seconds to wait on rate limit error
MAX_RETRIES = 3


def load_prompts() -> dict:
    """Load prompts from art/prompts.json."""
    if not PROMPTS_FILE.exists():
        print(f"ERROR: {PROMPTS_FILE} not found!")
        sys.exit(1)
    with open(PROMPTS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def flatten_prompts(data: dict, category_filter: Optional[str] = None) -> list[dict]:
    """Flatten all prompts into a list with category info attached."""
    global_suffix = data.get("global_suffix", "")
    prompts = []
    for cat in data.get("categories", []):
        cat_name = cat["name"]
        cat_folder = cat["folder"]
        if category_filter and cat_name != category_filter:
            continue
        for p in cat["prompts"]:
            prompts.append({
                "id": p["id"],
                "filename": p["filename"],
                "prompt": p["prompt"],
                "full_prompt": f"{p['prompt']}. {global_suffix}" if global_suffix else p["prompt"],
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
    global_suffix = data.get("global_suffix", "")
    print("\n" + "=" * 70)
    print("MOMI'S ADVENTURE - ART PROMPT LIST (API Mode)")
    print("=" * 70)
    print(f"\nGlobal suffix: \"{global_suffix[:80]}...\"")

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
            print(f"  {mark} {idx:>3}  {p['id']:<35} → {p['filename']}")
            idx += 1
            total += 1

    print(f"\n{'=' * 70}")
    print(f"Total: {total} prompts across {len(data.get('categories', []))} categories")
    print(f"Existing: {existing} / {total}")
    print(f"Remaining: {total - existing}")
    print(f"{'=' * 70}")


def generate_image(
    client: genai.Client,
    prompt: str,
    output_path: pathlib.Path,
    model: str = DEFAULT_MODEL,
) -> bool:
    """Generate a single image via the Gemini API and save to disk.
    
    Uses generate_content with response_modalities=['IMAGE'] for Gemini models.
    Returns True on success, False on failure.
    """
    # Determine response modalities based on model
    if "exp" in model or "2.0-flash" in model:
        modalities = ["TEXT", "IMAGE"]
    else:
        modalities = ["IMAGE"]

    for attempt in range(MAX_RETRIES):
        try:
            # Use generate_content API with IMAGE modality
            response = client.models.generate_content(
                model=model,
                contents=f"Generate an image: {prompt}. Output only the image, no text.",
                config=types.GenerateContentConfig(
                    response_modalities=modalities,
                ),
            )

            # Extract image from response parts
            if response.candidates and response.candidates[0].content.parts:
                for part in response.candidates[0].content.parts:
                    if part.inline_data is not None:
                        img_data = part.inline_data.data
                        output_path.parent.mkdir(parents=True, exist_ok=True)
                        output_path.write_bytes(img_data)
                        return True

            print(f"    ! No image returned (may be blocked by safety filter)")
            return False

        except Exception as e:
            err_str = str(e).lower()
            if "429" in err_str or "rate" in err_str or "quota" in err_str or "resource_exhausted" in err_str:
                wait = RETRY_DELAY * (attempt + 1)
                print(f"    ... Rate limited - waiting {wait:.0f}s (attempt {attempt+1}/{MAX_RETRIES})")
                time.sleep(wait)
                continue
            elif "blocked" in err_str or "safety" in err_str:
                print(f"    ! Blocked by safety filter: {e}")
                return False
            else:
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
) -> dict:
    """Run image generation for all prompts.
    
    Returns stats dict with generated/skipped/failed counts.
    """
    client = genai.Client(api_key=api_key)

    stats = {"generated": 0, "skipped": 0, "failed": 0, "blocked": 0, "total": len(prompts)}
    failed_prompts = []

    print("\n" + "=" * 70)
    print("MOMI'S ADVENTURE - GEMINI API IMAGE GENERATOR")
    print("=" * 70)
    print(f"\nModel: {model}")
    print(f"Prompts: {len(prompts)}")
    print(f"Skip existing: {skip_existing}")
    print(f"Output: {GENERATED_DIR}/")
    print(f"Rate limit delay: {delay}s between requests")
    if dry_run:
        print("DRY RUN - no images will be generated")
    print("=" * 70)

    for i, p in enumerate(prompts):
        prefix = f"[{i+1}/{len(prompts)}]"
        name = f"{p['category']}/{p['id']}"
        out = p["output_path"]

        # Skip existing
        if skip_existing and out.exists():
            print(f"  {prefix} SKIP {name} (already exists)")
            stats["skipped"] += 1
            continue

        print(f"  {prefix} {name} -> {p['folder']}/{p['filename']}")

        if dry_run:
            stats["generated"] += 1
            continue

        # Generate
        success = generate_image(client, p["full_prompt"], out, model)

        if success:
            size = out.stat().st_size
            print(f"    OK Saved ({size:,} bytes)")
            stats["generated"] += 1
        else:
            stats["failed"] += 1
            failed_prompts.append(p)

        # Rate limit delay
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
    parser = argparse.ArgumentParser(
        description="Generate Momi's Adventure sprites via Gemini API (Imagen)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python gemini_api_generate.py --list              List all 96 prompts
  python gemini_api_generate.py                     Generate all (skip existing)
  python gemini_api_generate.py --category enemies  Generate only enemy sprites
  python gemini_api_generate.py --single 5          Generate prompt index 5
  python gemini_api_generate.py --dry-run           Preview without generating
  python gemini_api_generate.py --model gemini-2.5-flash-image   Use Gemini 2.5 Flash
        """,
    )
    parser.add_argument("--list", "-l", action="store_true",
                        help="List all available prompts grouped by category")
    parser.add_argument("--category", "-c",
                        choices=["characters", "enemies", "bosses", "npcs",
                                 "items", "equipment", "effects", "zones"],
                        help="Generate only prompts from one category")
    parser.add_argument("--single", "-s", type=int, metavar="INDEX",
                        help="Generate a single prompt by global index (see --list)")
    parser.add_argument("--api-key", "-k",
                        help="Google API key (or set GOOGLE_API_KEY env var)")
    parser.add_argument("--model", "-m", default=DEFAULT_MODEL,
                        help=f"Gemini model to use (default: {DEFAULT_MODEL})")
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

    # List mode
    if args.list:
        list_prompts(data)
        return

    # Resolve API key
    api_key = args.api_key or os.environ.get("GOOGLE_API_KEY") or os.environ.get("GEMINI_API_KEY")
    if not api_key and not args.dry_run:
        print("ERROR: No API key provided!")
        print("")
        print("Get a free key at: https://aistudio.google.com/apikey")
        print("")
        print("Then either:")
        print("  export GOOGLE_API_KEY=your_key_here")
        print("  python gemini_api_generate.py --api-key your_key_here")
        sys.exit(1)

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
        )
    except KeyboardInterrupt:
        print("\n\nInterrupted by user. Partial progress saved.")
        print("Re-run to continue (skip-existing will resume where you left off).")
        sys.exit(0)


if __name__ == "__main__":
    main()
