---
phase: 30
plan: 01
subsystem: tooling
tags: [playwright, automation, gemini, art-pipeline, sprites]
dependency-graph:
  requires: []
  provides: [gemini-automation, art-pipeline-tooling]
  affects: [31-art-generation-checkpoint, 32-player-sprite-integration]
tech-stack:
  added: []
  patterns: [playwright-browser-automation, 3-tier-download-fallback, skip-existing-resume]
key-files:
  created:
    - tools/gemini_automation.py
  modified: []
decisions:
  - id: D30-01-01
    choice: "Model after suno_automation.py pattern for consistency"
    rationale: "Same Playwright sync API pattern, argparse CLI, try/except import guard"
  - id: D30-01-02
    choice: "3-tier download fallback (blob extraction, JS fetch, manual save)"
    rationale: "Gemini's DOM structure varies; graceful degradation prevents crashes"
  - id: D30-01-03
    choice: "Support both gemini.google.com and aistudio.google.com via --site flag"
    rationale: "User can switch generation backend without code changes"
  - id: D30-01-04
    choice: "Windows UTF-8 console reconfigure at startup"
    rationale: "Windows cp1252 encoding breaks Unicode box-drawing and checkmark chars"
metrics:
  duration: ~15 minutes
  completed: 2026-01-29
---

# Phase 30 Plan 01: Gemini Art Automation Tool Summary

**One-liner:** Playwright browser automation for Gemini image generation with 96 prompts, 3-tier download fallback, and skip-existing resume

## What Was Built

### Task 1: tools/gemini_automation.py (821 lines)
Complete CLI tool for automated art prompt submission to Google Gemini:

- **Prompt Loading:** Reads `art/prompts.json`, composes each prompt with `global_suffix`
- **CLI Interface:** `--list`, `--category`, `--single`, `--auto-submit`, `--headless`, `--site`, `--skip-existing/--no-skip-existing`
- **Browser Automation:** Playwright sync API, launches Chromium, navigates to Gemini/AI Studio, fills and submits prompts
- **Image Download:** 3-tier fallback (blob/data URL extraction → JS fetch → manual save instruction)
- **Resume Logic:** Checks `art/generated/{category}/{filename}` existence before each prompt
- **Error Handling:** Per-prompt try/except, never crashes on individual failure, Ctrl+C graceful exit with stats
- **Progress Tracking:** Banner, per-prompt progress, session summary (generated/skipped/failed)

### Task 2: Pipeline Completeness Verification
Cross-referenced all game entities against `art/prompts.json`:

| Category | Game Entities | Prompts | Status |
|----------|-------------|---------|--------|
| Items | 13 items | 15 prompts (+ 2 pickups) | Complete |
| Equipment | 19 equipment | 19 prompts | Complete |
| Enemies | 5 types | 11 prompts (idle + attack) | Complete |
| Bosses | 4 bosses | 9 prompts (normal + abilities) | Complete |
| NPCs | 1 (Nutkin) | 2 prompts | Complete |
| Effects | 3 core + 4 extra | 7 prompts | Complete |
| Characters | 3 (Momi, Cinnamon, Philo) | 19 prompts | Complete |
| Zones | 4 zones | 14 prompts | Complete |

- `rip_sprites.py` TARGET_SIZES: All 8 keys match prompts.json category folders exactly
- `art/generated/` directories: All 8 category subdirectories exist
- Zero missing mappings between game code and art prompts

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Windows console encoding crash on Unicode characters**
- **Found during:** Task 1 verification (`--list`)
- **Issue:** `UnicodeEncodeError: 'charmap' codec can't encode` — Windows cp1252 default encoding can't handle em-dash (—) and box-drawing characters (──)
- **Fix:** Added `sys.stdout.reconfigure(encoding="utf-8")` at script startup for Windows
- **Files modified:** tools/gemini_automation.py
- **Commit:** 6d81868

## Commits

| Hash | Message |
|------|---------|
| 6d81868 | feat(30-01): create Gemini art automation tool |

## Pipeline Status

Full art pipeline ready for use:
1. `python tools/gemini_automation.py --list` → View all 96 prompts
2. `python tools/gemini_automation.py` → Generate images via Gemini
3. `python art/rip_sprites.py` → Remove backgrounds, downscale to target sizes
4. Move approved sprites to `assets/sprites/` for Godot import

## Next Phase Readiness

- **Phase 31 (Art Generation Checkpoint):** Ready — user can now run gemini_automation.py to batch-generate all sprites
- **No blockers** — all tooling, prompts, and directory structure in place
