#!/usr/bin/env python3
"""
Generate 4 batches of character sprites with reference images for consistency.
Each batch goes to art/generated/batch_N/characters/.
Uses per-character references from art/reference/ to maintain style consistency.
"""

import json
import os
import sys
import time
import pathlib

SCRIPT_DIR = pathlib.Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
sys.path.insert(0, str(SCRIPT_DIR))

from gemini_api_generate import (
    load_prompts, flatten_prompts, generate_image, load_style_context,
    load_character_references,
    GENERATED_DIR, RATE_LIMIT_DELAY, DEFAULT_MODEL, DEFAULT_ASPECT_RATIO,
    DEFAULT_IMAGE_SIZE
)

# Load .env
try:
    from dotenv import load_dotenv
    load_dotenv(PROJECT_ROOT / ".env")
except ImportError:
    pass


def get_character_name(prompt_id: str) -> str:
    """Extract character name from prompt ID (e.g. 'momi_idle' -> 'momi')."""
    for name in ["momi", "cinnamon", "philo"]:
        if prompt_id.startswith(name):
            return name
    return ""


def main():
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        print("ERROR: No API key found in environment or .env")
        sys.exit(1)

    data = load_prompts()
    prompts = flatten_prompts(data, category_filter="characters")

    if not prompts:
        print("No character prompts found!")
        sys.exit(1)

    # Load per-character reference images
    ref_dir = str(PROJECT_ROOT / "art" / "reference")
    print(f"Loading character references from: {ref_dir}")
    char_refs = load_character_references(ref_dir)

    print(f"Found {len(prompts)} character prompts")
    print(f"Generating 4 batches = {len(prompts) * 4} total images")
    print(f"Estimated time: ~{len(prompts) * 4 * 8 / 60:.0f} minutes")
    print()

    total_generated = 0
    total_failed = 0

    for batch_num in range(1, 5):
        batch_dir = GENERATED_DIR / f"batch_{batch_num}" / "characters"
        batch_dir.mkdir(parents=True, exist_ok=True)

        print(f"\n{'='*60}")
        print(f"BATCH {batch_num}/4")
        print(f"Output: {batch_dir}")
        print(f"{'='*60}")

        for i, p in enumerate(prompts):
            filename = p["filename"]
            output_path = batch_dir / filename

            # Skip existing files from prior runs
            if output_path.exists():
                print(f"  [{i+1}/{len(prompts)}] SKIP {p['id']} (exists)")
                continue

            # Build reference parts for this specific character
            char_name = get_character_name(p["id"])
            prompt_refs = []
            # Add shared references if any
            if "shared" in char_refs:
                prompt_refs.extend(char_refs["shared"])
            # Add character-specific references
            if char_name and char_name in char_refs:
                prompt_refs.extend(char_refs[char_name])

            ref_label = f" [+{len(prompt_refs)} refs]" if prompt_refs else ""
            print(f"  [{i+1}/{len(prompts)}] {p['id']} -> {filename}{ref_label}")

            success = generate_image(
                api_key=api_key,
                prompt=p["full_prompt"],
                output_path=output_path,
                model=DEFAULT_MODEL,
                reference_parts=prompt_refs if prompt_refs else None,
                aspect_ratio=DEFAULT_ASPECT_RATIO,
                image_size=DEFAULT_IMAGE_SIZE,
            )

            if success:
                size = output_path.stat().st_size
                print(f"    OK ({size:,} bytes)")
                total_generated += 1
            else:
                print(f"    FAILED")
                total_failed += 1

            # Rate limit
            time.sleep(RATE_LIMIT_DELAY)

    print(f"\n{'='*60}")
    print(f"ALL BATCHES COMPLETE")
    print(f"{'='*60}")
    print(f"  Generated: {total_generated}")
    print(f"  Failed:    {total_failed}")
    print(f"\nNext: Open art/generated/compare.html to pick favorites")


if __name__ == "__main__":
    main()
