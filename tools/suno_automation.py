#!/usr/bin/env python3
"""
Suno AI Music Generation Automation
====================================
Automates pasting prompts into Suno.com to generate game music.

Usage:
    python suno_automation.py              # Run all essential prompts
    python suno_automation.py --category character_themes
    python suno_automation.py --list       # Show all available prompts
    python suno_automation.py --single 0   # Run just the first prompt

Requirements:
    pip install playwright
    playwright install chromium
"""

import json
import time
import argparse
from pathlib import Path

try:
    from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
except ImportError:
    print("Playwright not installed. Run:")
    print("  pip install playwright")
    print("  playwright install chromium")
    exit(1)


# Load prompts from JSON
SCRIPT_DIR = Path(__file__).parent
PROMPTS_FILE = SCRIPT_DIR / "suno_prompts.json"


def load_prompts():
    """Load prompts from JSON file."""
    if not PROMPTS_FILE.exists():
        print(f"Error: {PROMPTS_FILE} not found!")
        exit(1)
    
    with open(PROMPTS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def list_prompts(prompts_data):
    """Display all available prompts."""
    print("\n" + "=" * 60)
    print("AVAILABLE SUNO PROMPTS FOR MOMI'S ADVENTURE")
    print("=" * 60)
    
    for category, prompts in prompts_data.items():
        print(f"\n[{category.upper()}]")
        for i, p in enumerate(prompts):
            print(f"  {i}: {p['name']}")
    
    print("\n" + "=" * 60)


def run_automation(prompts_to_run, headless=False, auto_create=False):
    """
    Run Suno automation for the given prompts.
    
    Args:
        prompts_to_run: List of {"name": str, "prompt": str} dicts
        headless: Run browser in headless mode (not recommended for Suno)
        auto_create: Automatically click Create button (requires being logged in)
    """
    print("\n" + "=" * 60)
    print("SUNO AUTOMATION - Momi's Adventure Music Generator")
    print("=" * 60)
    print(f"\nPrompts to generate: {len(prompts_to_run)}")
    print("\nInstructions:")
    print("  1. Browser will open to Suno.com")
    print("  2. LOG IN if not already logged in")
    print("  3. For each prompt, the style will be auto-filled")
    print("  4. Click 'Create' to generate (or wait if auto-create enabled)")
    print("  5. WAIT for generation to complete before pressing Enter")
    print("  6. Press Enter in this terminal to load next prompt")
    print("\nPress Ctrl+C at any time to stop.")
    print("=" * 60)
    
    input("\nPress Enter to start...")
    
    with sync_playwright() as p:
        # Launch browser (visible so user can interact)
        browser = p.chromium.launch(
            headless=headless,
            args=["--start-maximized"]
        )
        context = browser.new_context(
            viewport={"width": 1280, "height": 900},
            # Use persistent storage so login is remembered
            # storage_state="suno_auth.json" if Path("suno_auth.json").exists() else None
        )
        page = context.new_page()
        
        # Navigate to Suno Advanced mode
        print("\n>> Opening Suno.com...")
        page.goto("https://suno.com/create", wait_until="networkidle", timeout=30000)
        
        # Wait a moment for page to fully load
        time.sleep(2)
        
        # Click Advanced button if visible
        try:
            advanced_btn = page.locator("button:has-text('Advanced')")
            if advanced_btn.is_visible(timeout=3000):
                advanced_btn.click()
                print(">> Clicked Advanced mode")
                time.sleep(1)
        except:
            pass
        
        # Check if user needs to sign in
        try:
            sign_in_btn = page.locator("button:has-text('Sign In')")
            if sign_in_btn.is_visible(timeout=2000):
                print("\n" + "!" * 60)
                print("! You need to SIGN IN to Suno first!")
                print("! Click 'Sign In' in the browser, then press Enter here")
                print("!" * 60)
                input("\nPress Enter after signing in...")
                time.sleep(2)
        except:
            pass
        
        # Process each prompt
        for idx, prompt_data in enumerate(prompts_to_run):
            name = prompt_data["name"]
            prompt = prompt_data["prompt"]
            
            print(f"\n{'=' * 60}")
            print(f"[{idx + 1}/{len(prompts_to_run)}] {name}")
            print(f"{'=' * 60}")
            print(f"\nStyle prompt:\n{prompt[:100]}...")
            
            # Find and fill the styles textbox
            try:
                # Try to find styles input
                styles_input = page.locator("input[placeholder*='style'], textarea[placeholder*='style']").first
                if not styles_input.is_visible(timeout=3000):
                    # Try alternate selector
                    styles_input = page.locator("[placeholder='Enter style tags']").first
                
                # Clear existing content and type new prompt
                styles_input.click()
                styles_input.fill("")  # Clear
                time.sleep(0.3)
                styles_input.fill(prompt)
                print(">> Style prompt filled!")
                
            except Exception as e:
                print(f"!! Could not find styles input: {e}")
                print("!! Please manually paste this prompt into the Styles field:")
                print(f"\n{prompt}\n")
            
            # Check instrumental toggle
            try:
                instrumental = page.locator("text=Instrumental").first
                if instrumental.is_visible(timeout=1000):
                    # Click to toggle if not already on
                    instrumental_toggle = page.locator("[aria-label*='Instrumental'], div:has-text('Instrumental')").first
                    if instrumental_toggle.is_visible():
                        instrumental_toggle.click()
                        print(">> Toggled Instrumental mode")
            except:
                pass
            
            if auto_create:
                # Auto-click Create button
                try:
                    create_btn = page.locator("button:has-text('Create')").first
                    if create_btn.is_enabled(timeout=2000):
                        create_btn.click()
                        print(">> Clicked Create!")
                        print(">> Waiting for generation (this takes ~30-60 seconds)...")
                        time.sleep(60)  # Wait for generation
                except Exception as e:
                    print(f"!! Could not auto-click Create: {e}")
            else:
                print("\n>> Click 'Create' in the browser to generate this track")
                print(">> After the song generates, come back here and press Enter")
            
            # Wait for user to continue (unless it's the last one)
            if idx < len(prompts_to_run) - 1:
                input(f"\nPress Enter to continue to next prompt ({idx + 2}/{len(prompts_to_run)})...")
                
                # Clear the styles input for next prompt
                try:
                    styles_input = page.locator("input[placeholder*='style'], [placeholder='Enter style tags']").first
                    styles_input.fill("")
                except:
                    pass
        
        print("\n" + "=" * 60)
        print("ALL PROMPTS COMPLETE!")
        print("=" * 60)
        print("\nYour generated tracks should be in your Suno library.")
        print("Download them and place in: assets/audio/music/")
        print("\nPress Enter to close browser...")
        input()
        
        # Optionally save auth state for next time
        # context.storage_state(path="suno_auth.json")
        
        browser.close()


def main():
    parser = argparse.ArgumentParser(
        description="Automate Suno AI music generation for Momi's Adventure"
    )
    parser.add_argument(
        "--category", "-c",
        choices=["essential", "character_themes", "zone_variations", "combat_variations", "all"],
        default="essential",
        help="Category of prompts to run (default: essential)"
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List all available prompts"
    )
    parser.add_argument(
        "--single", "-s",
        type=int,
        help="Run a single prompt by index (from --list)"
    )
    parser.add_argument(
        "--auto-create",
        action="store_true",
        help="Automatically click Create button (requires being logged in)"
    )
    parser.add_argument(
        "--headless",
        action="store_true",
        help="Run in headless mode (not recommended)"
    )
    
    args = parser.parse_args()
    
    # Load prompts
    prompts_data = load_prompts()
    
    if args.list:
        list_prompts(prompts_data)
        return
    
    # Build list of prompts to run
    prompts_to_run = []
    
    if args.single is not None:
        # Flatten all prompts and pick by index
        all_prompts = []
        for category, prompts in prompts_data.items():
            all_prompts.extend(prompts)
        
        if 0 <= args.single < len(all_prompts):
            prompts_to_run = [all_prompts[args.single]]
        else:
            print(f"Error: Index {args.single} out of range (0-{len(all_prompts)-1})")
            return
    
    elif args.category == "all":
        for category, prompts in prompts_data.items():
            prompts_to_run.extend(prompts)
    else:
        if args.category in prompts_data:
            prompts_to_run = prompts_data[args.category]
        else:
            print(f"Error: Unknown category '{args.category}'")
            return
    
    if not prompts_to_run:
        print("No prompts to run!")
        return
    
    # Run automation
    run_automation(
        prompts_to_run,
        headless=args.headless,
        auto_create=args.auto_create
    )


if __name__ == "__main__":
    main()
