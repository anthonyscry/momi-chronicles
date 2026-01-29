#!/usr/bin/env python3
"""
Gemini AI Image Generation Automation
======================================
Automates submitting art prompts to Google Gemini for sprite generation.

Usage:
    python gemini_automation.py              # Run all prompts (skip existing)
    python gemini_automation.py --list       # Show all 96 prompts grouped by category
    python gemini_automation.py --category characters
    python gemini_automation.py --single 0   # Run just the first prompt
    python gemini_automation.py --site aistudio  # Use AI Studio instead of Gemini

Requirements:
    pip install playwright
    playwright install chromium
"""

import json
import time
import argparse
import sys
import os
from pathlib import Path
from typing import Optional

# Fix Windows console encoding for Unicode output
if sys.platform == "win32":
    os.environ.setdefault("PYTHONIOENCODING", "utf-8")
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

try:
    from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
except ImportError:
    print("Playwright not installed. Run:")
    print("  pip install playwright")
    print("  playwright install chromium")
    exit(1)


# === Paths ===
SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
PROMPTS_FILE = PROJECT_ROOT / "art" / "prompts.json"
GENERATED_DIR = PROJECT_ROOT / "art" / "generated"


# ─────────────────────────────────────────────
# Prompt Loading
# ─────────────────────────────────────────────

def load_prompts() -> dict:
    """Load prompts from art/prompts.json."""
    if not PROMPTS_FILE.exists():
        print(f"Error: {PROMPTS_FILE} not found!")
        exit(1)

    with open(PROMPTS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def get_all_prompts(prompts_data: dict) -> list[dict]:
    """
    Flatten all prompts into a single list with category info attached.

    Each entry has: id, filename, prompt (composed with global_suffix),
    category_name, category_folder, global_index.
    """
    global_suffix = prompts_data.get("global_suffix", "")
    all_prompts = []
    idx = 0

    for category in prompts_data["categories"]:
        for prompt in category["prompts"]:
            composed = f"{prompt['prompt']}. {global_suffix}" if global_suffix else prompt["prompt"]
            all_prompts.append({
                "global_index": idx,
                "id": prompt["id"],
                "filename": prompt["filename"],
                "prompt": composed,
                "category_name": category["name"],
                "category_folder": category["folder"],
            })
            idx += 1

    return all_prompts


def output_path_for(prompt_entry: dict) -> Path:
    """Return the expected output file path for a prompt entry."""
    return GENERATED_DIR / prompt_entry["category_folder"] / prompt_entry["filename"]


# ─────────────────────────────────────────────
# Directory Setup
# ─────────────────────────────────────────────

def ensure_output_directories(prompts_data: dict) -> None:
    """Create all category subdirectories under art/generated/."""
    for category in prompts_data["categories"]:
        folder = GENERATED_DIR / category["folder"]
        folder.mkdir(parents=True, exist_ok=True)


# ─────────────────────────────────────────────
# CLI: --list
# ─────────────────────────────────────────────

def list_prompts(prompts_data: dict) -> None:
    """Display all prompts grouped by category with global index numbers."""
    global_suffix = prompts_data.get("global_suffix", "")

    print("\n" + "=" * 70)
    print("MOMI'S ADVENTURE — ART PROMPT LIST")
    print("=" * 70)
    print(f"\nGlobal suffix (appended to every prompt):")
    print(f"  \"{global_suffix}\"")

    idx = 0
    total = 0
    for category in prompts_data["categories"]:
        cat_count = len(category["prompts"])
        total += cat_count
        print(f"\n── {category['name'].upper()} ({category['folder']}/) — {cat_count} prompts ──")
        for prompt in category["prompts"]:
            out_path = GENERATED_DIR / category["folder"] / prompt["filename"]
            exists = "✓" if out_path.exists() else " "
            print(f"  [{exists}] {idx:3d}  {prompt['id']:30s}  → {prompt['filename']}")
            idx += 1

    print(f"\n{'=' * 70}")
    print(f"Total: {total} prompts across {len(prompts_data['categories'])} categories")
    existing = sum(
        1 for cat in prompts_data["categories"]
        for p in cat["prompts"]
        if (GENERATED_DIR / cat["folder"] / p["filename"]).exists()
    )
    print(f"Existing: {existing} / {total}")
    print("=" * 70)


# ─────────────────────────────────────────────
# Image Download Helpers
# ─────────────────────────────────────────────

def try_download_image(page, save_path: Path) -> bool:
    """
    Attempt to download the most recent generated image from the page.

    Strategy (3-tier fallback):
      1. Extract image blob/data URL from the DOM and save via Python
      2. Try right-click context menu → Save Image As
      3. Fall back to manual instruction

    Returns True if download succeeded.
    """
    # Strategy 1: Extract image src from DOM
    try:
        # Look for images in the latest response area
        selectors = [
            "img[src^='blob:']",
            "img[src^='data:image']",
            "img[src*='generated']",
            "img[src*='lh3.googleusercontent']",
            "img[src*='googleusercontent']",
            # Gemini often wraps images in specific containers
            "[data-test-id='response'] img",
            ".response-container img",
            "model-response img",
            ".message-content img",
            # Generic: last img that isn't an avatar/icon
            "img[alt]:not([width='24']):not([width='32'])",
        ]

        for selector in selectors:
            try:
                images = page.locator(selector)
                count = images.count()
                if count > 0:
                    # Take the last (most recent) image
                    last_img = images.nth(count - 1)
                    src = last_img.get_attribute("src", timeout=3000)
                    if src and _download_from_src(page, src, save_path):
                        return True
            except Exception:
                continue

    except Exception as e:
        print(f"    [Download Strategy 1 failed: {e}]")

    # Strategy 2: Try to trigger download via page evaluate (blob fetch)
    try:
        result = page.evaluate("""() => {
            const images = document.querySelectorAll('img');
            const candidates = Array.from(images).filter(img => {
                const w = img.naturalWidth || img.width;
                const h = img.naturalHeight || img.height;
                return w > 100 && h > 100;
            });
            if (candidates.length === 0) return null;
            const last = candidates[candidates.length - 1];
            return last.src;
        }""")
        if result and _download_from_src(page, result, save_path):
            return True
    except Exception as e:
        print(f"    [Download Strategy 2 failed: {e}]")

    return False


def _download_from_src(page, src: str, save_path: Path) -> bool:
    """Download an image from a src URL (blob:, data:, or http)."""
    try:
        if src.startswith("data:image"):
            # Data URL — decode base64
            import base64
            header, data = src.split(",", 1)
            image_bytes = base64.b64decode(data)
            save_path.parent.mkdir(parents=True, exist_ok=True)
            save_path.write_bytes(image_bytes)
            return True

        elif src.startswith("blob:"):
            # Blob URL — use page.evaluate to fetch as data URL then decode
            data_url = page.evaluate("""(blobUrl) => {
                return new Promise((resolve, reject) => {
                    fetch(blobUrl)
                        .then(r => r.blob())
                        .then(blob => {
                            const reader = new FileReader();
                            reader.onload = () => resolve(reader.result);
                            reader.onerror = reject;
                            reader.readAsDataURL(blob);
                        })
                        .catch(reject);
                });
            }""", src)
            if data_url and data_url.startswith("data:image"):
                import base64
                _, data = data_url.split(",", 1)
                image_bytes = base64.b64decode(data)
                save_path.parent.mkdir(parents=True, exist_ok=True)
                save_path.write_bytes(image_bytes)
                return True

        elif src.startswith("http"):
            # Regular URL — fetch via page and save
            import base64
            data_url = page.evaluate("""(url) => {
                return new Promise((resolve, reject) => {
                    fetch(url)
                        .then(r => r.blob())
                        .then(blob => {
                            const reader = new FileReader();
                            reader.onload = () => resolve(reader.result);
                            reader.onerror = reject;
                            reader.readAsDataURL(blob);
                        })
                        .catch(reject);
                });
            }""", src)
            if data_url and data_url.startswith("data:image"):
                _, data = data_url.split(",", 1)
                image_bytes = base64.b64decode(data)
                save_path.parent.mkdir(parents=True, exist_ok=True)
                save_path.write_bytes(image_bytes)
                return True

    except Exception as e:
        print(f"    [_download_from_src error: {e}]")

    return False


# ─────────────────────────────────────────────
# Browser Automation: Gemini
# ─────────────────────────────────────────────

def submit_prompt_gemini(page, prompt_text: str, auto_submit: bool) -> bool:
    """
    Submit a prompt to gemini.google.com chat interface.
    Returns True if the prompt was submitted successfully.
    """
    # Find the chat input — Gemini uses various input selectors
    input_selectors = [
        "div[contenteditable='true']",
        "rich-textarea div[contenteditable='true']",
        "textarea",
        "[aria-label*='prompt' i]",
        "[aria-label*='Enter' i]",
        ".ql-editor",
        "p[data-placeholder]",
    ]

    input_el = None
    for selector in input_selectors:
        try:
            el = page.locator(selector).first
            if el.is_visible(timeout=2000):
                input_el = el
                break
        except Exception:
            continue

    if not input_el:
        print("    !! Could not find prompt input field")
        return False

    try:
        input_el.click()
        time.sleep(0.3)

        # Clear existing content
        page.keyboard.press("Control+a")
        page.keyboard.press("Delete")
        time.sleep(0.2)

        # Type the prompt (using keyboard for contenteditable divs)
        input_el.fill(prompt_text)
        time.sleep(0.3)

        # Verify it was filled (contenteditable can be tricky)
        try:
            text = input_el.inner_text()
            if len(text) < 10:
                # fill() might not work on contenteditable; use type()
                input_el.click()
                page.keyboard.press("Control+a")
                page.keyboard.press("Delete")
                time.sleep(0.1)
                page.keyboard.type(prompt_text, delay=5)
                time.sleep(0.3)
        except Exception:
            pass

        print("    >> Prompt filled")

    except Exception as e:
        print(f"    !! Error filling prompt: {e}")
        print(f"    !! Please paste manually:\n{prompt_text[:120]}...")
        return False

    if auto_submit:
        try:
            # Try clicking the send button
            send_selectors = [
                "button[aria-label*='Send' i]",
                "button[aria-label*='submit' i]",
                "button.send-button",
                "[data-testid='send-button']",
                "button mat-icon-button[aria-label*='Send']",
            ]
            sent = False
            for selector in send_selectors:
                try:
                    btn = page.locator(selector).first
                    if btn.is_visible(timeout=1500):
                        btn.click()
                        sent = True
                        print("    >> Submitted via send button")
                        break
                except Exception:
                    continue

            if not sent:
                # Fallback: press Enter
                page.keyboard.press("Enter")
                print("    >> Submitted via Enter key")

        except Exception as e:
            print(f"    !! Auto-submit failed: {e}")
            print("    !! Please click Send manually")

    return True


def wait_for_image_gemini(page, timeout_seconds: int = 180) -> bool:
    """
    Wait for Gemini to generate an image in the response.
    Returns True if an image appeared.
    """
    print(f"    >> Waiting for image generation (up to {timeout_seconds}s)...")
    start = time.time()
    check_interval = 5  # Check every 5 seconds

    # Get initial image count to detect new images
    try:
        initial_count = page.evaluate("""() => {
            return document.querySelectorAll('img').length;
        }""")
    except Exception:
        initial_count = 0

    while time.time() - start < timeout_seconds:
        try:
            current_count = page.evaluate("""() => {
                const imgs = document.querySelectorAll('img');
                let large = 0;
                imgs.forEach(img => {
                    const w = img.naturalWidth || img.width;
                    const h = img.naturalHeight || img.height;
                    if (w > 100 && h > 100) large++;
                });
                return large;
            }""")
            if current_count > 0:
                # Check for loading indicators being gone
                try:
                    loading = page.locator("[role='progressbar'], .loading, .generating").first
                    if not loading.is_visible(timeout=1000):
                        print(f"    >> Image detected ({int(time.time() - start)}s)")
                        time.sleep(3)  # Extra wait for full render
                        return True
                except Exception:
                    print(f"    >> Image detected ({int(time.time() - start)}s)")
                    time.sleep(3)
                    return True
        except Exception:
            pass

        time.sleep(check_interval)

    print(f"    !! Timeout waiting for image after {timeout_seconds}s")
    return False


# ─────────────────────────────────────────────
# Browser Automation: AI Studio
# ─────────────────────────────────────────────

def submit_prompt_aistudio(page, prompt_text: str, auto_submit: bool) -> bool:
    """
    Submit a prompt to aistudio.google.com chat interface.
    Returns True if the prompt was submitted successfully.
    """
    input_selectors = [
        "textarea",
        "div[contenteditable='true']",
        "[aria-label*='Type' i]",
        "[aria-label*='prompt' i]",
        "[placeholder*='Type' i]",
    ]

    input_el = None
    for selector in input_selectors:
        try:
            el = page.locator(selector).first
            if el.is_visible(timeout=2000):
                input_el = el
                break
        except Exception:
            continue

    if not input_el:
        print("    !! Could not find prompt input field")
        return False

    try:
        input_el.click()
        time.sleep(0.3)
        page.keyboard.press("Control+a")
        page.keyboard.press("Delete")
        time.sleep(0.2)
        input_el.fill(prompt_text)
        time.sleep(0.3)
        print("    >> Prompt filled")
    except Exception as e:
        print(f"    !! Error filling prompt: {e}")
        return False

    if auto_submit:
        try:
            send_selectors = [
                "button[aria-label*='Run' i]",
                "button[aria-label*='Send' i]",
                "button:has-text('Run')",
                "button:has-text('Send')",
            ]
            sent = False
            for selector in send_selectors:
                try:
                    btn = page.locator(selector).first
                    if btn.is_visible(timeout=1500):
                        btn.click()
                        sent = True
                        print("    >> Submitted via button")
                        break
                except Exception:
                    continue
            if not sent:
                page.keyboard.press("Enter")
                print("    >> Submitted via Enter key")
        except Exception as e:
            print(f"    !! Auto-submit failed: {e}")

    return True


# ─────────────────────────────────────────────
# Main Automation Loop
# ─────────────────────────────────────────────

def run_automation(
    prompts_to_run: list[dict],
    headless: bool = False,
    auto_submit: bool = False,
    skip_existing: bool = True,
    site: str = "gemini",
) -> None:
    """
    Run browser automation for the given prompts.

    Args:
        prompts_to_run: List of prompt entries from get_all_prompts()
        headless: Run browser headless (not recommended for interactive sites)
        auto_submit: Automatically submit prompts (press Send)
        skip_existing: Skip prompts whose output file already exists
        site: Target site — "gemini" or "aistudio"
    """
    # Stats
    generated = 0
    skipped = 0
    failed = 0
    total = len(prompts_to_run)

    # Filter out existing if skip enabled
    if skip_existing:
        filtered = []
        for p in prompts_to_run:
            out = output_path_for(p)
            if out.exists():
                print(f"  SKIP {p['id']} (already exists: {out.name})")
                skipped += 1
            else:
                filtered.append(p)
        prompts_to_run = filtered
        if not prompts_to_run:
            print("\nAll prompts already have output files! Nothing to do.")
            print(f"  Skipped: {skipped}/{total}")
            return

    # Banner
    site_name = "Google Gemini" if site == "gemini" else "Google AI Studio"
    site_url = "https://gemini.google.com" if site == "gemini" else "https://aistudio.google.com"

    print("\n" + "=" * 70)
    print(f"GEMINI ART AUTOMATION — Momi's Adventure Sprite Generator")
    print("=" * 70)
    print(f"\n  Target: {site_name} ({site_url})")
    print(f"  Prompts to process: {len(prompts_to_run)} (skipped {skipped} existing)")
    print(f"  Auto-submit: {'ON' if auto_submit else 'OFF (manual send)'}")
    print(f"  Headless: {'ON' if headless else 'OFF (visible browser)'}")
    print(f"\nInstructions:")
    print(f"  1. Browser will open to {site_name}")
    print(f"  2. SIGN IN if not already logged in")
    print(f"  3. Each prompt will be filled into the chat input")
    if auto_submit:
        print(f"  4. Prompts will be auto-submitted")
        print(f"  5. Script will attempt to download generated images")
    else:
        print(f"  4. Click 'Send' to submit each prompt")
        print(f"  5. Press Enter in this terminal when ready for next prompt")
    print(f"\n  Press Ctrl+C at any time to stop.")
    print("=" * 70)

    input("\nPress Enter to launch browser...")

    try:
        with sync_playwright() as pw:
            browser = pw.chromium.launch(
                headless=headless,
                args=["--start-maximized"],
            )
            context = browser.new_context(
                viewport={"width": 1400, "height": 900},
            )
            page = context.new_page()

            # Navigate to site
            print(f"\n>> Opening {site_name}...")
            try:
                page.goto(site_url, wait_until="domcontentloaded", timeout=30000)
            except PlaywrightTimeout:
                print("!! Page load timed out — continuing anyway")

            time.sleep(3)

            # Check for sign-in
            try:
                sign_in = page.locator(
                    "a:has-text('Sign in'), button:has-text('Sign in'), "
                    "a:has-text('Log in'), button:has-text('Log in')"
                ).first
                if sign_in.is_visible(timeout=3000):
                    print("\n" + "!" * 60)
                    print("! You need to SIGN IN first!")
                    print("! Complete sign-in in the browser, then press Enter here.")
                    print("!" * 60)
                    input("\nPress Enter after signing in...")
                    time.sleep(2)
            except Exception:
                pass  # No sign-in prompt found — probably already logged in

            # Process prompts
            submit_fn = submit_prompt_gemini if site == "gemini" else submit_prompt_aistudio
            remaining = len(prompts_to_run)

            for i, prompt_entry in enumerate(prompts_to_run):
                pid = prompt_entry["id"]
                cat = prompt_entry["category_name"]
                fname = prompt_entry["filename"]
                text = prompt_entry["prompt"]
                save_path = output_path_for(prompt_entry)

                print(f"\n{'─' * 70}")
                print(f"[{i + 1}/{remaining}] {cat}/{pid}")
                print(f"  Output: {save_path}")
                print(f"  Prompt: {text[:100]}...")

                try:
                    # Submit the prompt
                    submitted = submit_fn(page, text, auto_submit)

                    if not submitted:
                        print(f"    !! FAILED to submit — skipping {pid}")
                        failed += 1
                        continue

                    if auto_submit:
                        # Wait for image generation
                        image_appeared = wait_for_image_gemini(page)

                        if image_appeared:
                            # Attempt download
                            downloaded = try_download_image(page, save_path)
                            if downloaded:
                                print(f"    ✓ SAVED: {save_path.name}")
                                generated += 1
                            else:
                                print(f"    !! Could not auto-download image.")
                                print(f"    !! Please manually save as: {save_path}")
                                input("    Press Enter after saving (or to skip)...")
                                if save_path.exists():
                                    print(f"    ✓ File found: {save_path.name}")
                                    generated += 1
                                else:
                                    print(f"    ✗ File not found — marking as failed")
                                    failed += 1
                        else:
                            print(f"    !! No image generated — skipping {pid}")
                            failed += 1
                    else:
                        # Manual mode: wait for user
                        print(f"\n    >> Click Send in the browser to generate")
                        print(f"    >> Save the generated image as: {save_path}")
                        if i < remaining - 1:
                            input(f"    Press Enter for next prompt ({i + 2}/{remaining})...")
                        else:
                            input(f"    Press Enter to finish...")

                        if save_path.exists():
                            print(f"    ✓ File found: {save_path.name}")
                            generated += 1
                        else:
                            print(f"    (Image not detected at expected path)")
                            failed += 1

                except PlaywrightTimeout as e:
                    print(f"    !! Timeout on {pid}: {e}")
                    failed += 1
                    continue
                except Exception as e:
                    print(f"    !! Error on {pid}: {e}")
                    failed += 1
                    continue

            # Summary
            print(f"\n{'=' * 70}")
            print("SESSION COMPLETE")
            print(f"{'=' * 70}")
            print(f"  Generated: {generated}")
            print(f"  Skipped:   {skipped}")
            print(f"  Failed:    {failed}")
            print(f"  Total:     {total}")
            print(f"\nGenerated images: {GENERATED_DIR}/")
            print(f"Next step: python art/rip_sprites.py")
            print(f"\nPress Enter to close browser...")
            input()

            browser.close()

    except KeyboardInterrupt:
        print(f"\n\n{'=' * 70}")
        print("INTERRUPTED BY USER")
        print(f"{'=' * 70}")
        print(f"  Generated so far: {generated}")
        print(f"  Skipped:          {skipped}")
        print(f"  Failed:           {failed}")
        print(f"  Remaining:        {total - generated - skipped - failed}")
        print(f"\nRe-run with --skip-existing to resume where you left off.")
    except Exception as e:
        print(f"\n!! Unexpected error: {e}")
        print(f"  Generated so far: {generated}")
        print(f"  Re-run with --skip-existing to resume.")


# ─────────────────────────────────────────────
# CLI Entry Point
# ─────────────────────────────────────────────

def main() -> None:
    """Parse CLI arguments and run the appropriate mode."""
    parser = argparse.ArgumentParser(
        description="Automate Google Gemini image generation for Momi's Adventure sprites",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python gemini_automation.py --list              List all 96 prompts
  python gemini_automation.py                     Run all (skip existing)
  python gemini_automation.py --category enemies  Run only enemy prompts
  python gemini_automation.py --single 5          Run prompt index 5
  python gemini_automation.py --auto-submit       Auto-send prompts
  python gemini_automation.py --site aistudio     Use AI Studio
        """,
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List all available prompts grouped by category",
    )
    parser.add_argument(
        "--category", "-c",
        choices=["characters", "enemies", "bosses", "npcs", "items", "equipment", "effects", "zones"],
        help="Run only prompts from one category",
    )
    parser.add_argument(
        "--single", "-s",
        type=int,
        metavar="INDEX",
        help="Run a single prompt by global index (see --list)",
    )
    parser.add_argument(
        "--auto-submit",
        action="store_true",
        help="Automatically press Send after filling prompt (default: wait for user)",
    )
    parser.add_argument(
        "--headless",
        action="store_true",
        help="Run browser in headless mode (not recommended for interactive sites)",
    )
    parser.add_argument(
        "--site",
        choices=["gemini", "aistudio"],
        default="gemini",
        help="Target site: gemini (default) or aistudio",
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        default=True,
        dest="skip_existing",
        help="Skip prompts whose output file already exists (default: enabled)",
    )
    parser.add_argument(
        "--no-skip-existing",
        action="store_false",
        dest="skip_existing",
        help="Process all prompts even if output file exists",
    )

    args = parser.parse_args()

    # Load prompts
    prompts_data = load_prompts()

    # Ensure directories exist
    ensure_output_directories(prompts_data)

    if args.list:
        list_prompts(prompts_data)
        return

    # Build prompt list
    all_prompts = get_all_prompts(prompts_data)

    if args.single is not None:
        if 0 <= args.single < len(all_prompts):
            prompts_to_run = [all_prompts[args.single]]
        else:
            print(f"Error: Index {args.single} out of range (0-{len(all_prompts) - 1})")
            sys.exit(1)
    elif args.category:
        prompts_to_run = [p for p in all_prompts if p["category_name"] == args.category]
        if not prompts_to_run:
            print(f"Error: No prompts found for category '{args.category}'")
            sys.exit(1)
    else:
        prompts_to_run = all_prompts

    if not prompts_to_run:
        print("No prompts to run!")
        return

    # Run automation
    run_automation(
        prompts_to_run,
        headless=args.headless,
        auto_submit=args.auto_submit,
        skip_existing=args.skip_existing,
        site=args.site,
    )


if __name__ == "__main__":
    main()
