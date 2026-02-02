#!/usr/bin/env python3
"""
Generate 4 batches of enemy sprites for comparison.
Each batch goes to art/generated/batch_N/enemies/.
Runs the same prompts 4 times — AI naturally produces variety.
"""

import json
import os
import sys
import time
import pathlib
import shutil

# Add project root so we can import the generator
SCRIPT_DIR = pathlib.Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
sys.path.insert(0, str(SCRIPT_DIR))

from gemini_api_generate import (
    load_prompts, flatten_prompts, generate_image, load_style_context,
    GENERATED_DIR, RATE_LIMIT_DELAY, DEFAULT_MODEL, DEFAULT_ASPECT_RATIO,
    DEFAULT_IMAGE_SIZE
)

# Load .env
try:
    from dotenv import load_dotenv
    load_dotenv(PROJECT_ROOT / ".env")
except ImportError:
    pass


def main():
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        print("ERROR: No API key found in environment or .env")
        sys.exit(1)

    data = load_prompts()
    prompts = flatten_prompts(data, category_filter="enemies")

    if not prompts:
        print("No enemy prompts found!")
        sys.exit(1)

    print(f"Found {len(prompts)} enemy prompts")
    print(f"Generating 4 batches = {len(prompts) * 4} total images")
    print(f"Estimated time: ~{len(prompts) * 4 * 8 / 60:.0f} minutes")
    print()

    total_generated = 0
    total_failed = 0

    for batch_num in range(1, 5):
        batch_dir = GENERATED_DIR / f"batch_{batch_num}" / "enemies"
        batch_dir.mkdir(parents=True, exist_ok=True)

        print(f"\n{'='*60}")
        print(f"BATCH {batch_num}/4")
        print(f"Output: {batch_dir}")
        print(f"{'='*60}")

        for i, p in enumerate(prompts):
            filename = p["filename"]
            output_path = batch_dir / filename

            if output_path.exists():
                print(f"  [{i+1}/{len(prompts)}] SKIP {p['id']} (exists)")
                continue

            print(f"  [{i+1}/{len(prompts)}] {p['id']} -> {filename}")

            success = generate_image(
                api_key=api_key,
                prompt=p["full_prompt"],
                output_path=output_path,
                model=DEFAULT_MODEL,
                reference_parts=None,
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
    print(f"Then: python art/rip_sprites.py")


if __name__ == "__main__":
    main()
