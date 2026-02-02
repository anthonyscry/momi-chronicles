---
phase: 39-raccoon-king-setup
plan: 01
status: complete
files_modified: [world/zones/sewers.gd]
subsystem: world/zones
affects: [boss_arena]
decisions:
  - MINI_BOSSES_REQUIRED = 2 (any 2 of 4 mini-bosses)
  - Gate prevents ZoneExit creation, not just visual block
  - Door color darkens when locked, brightens when unlocked
---

## Summary

Added boss door progression gating to the Sewers zone. Players must defeat at least 2 of 4 mini-bosses before the boss arena entrance becomes accessible.

### Changes

**world/zones/sewers.gd:**
- Added `MINI_BOSSES_REQUIRED = 2` constant
- Added `_count_mini_bosses_defeated()` helper that counts `true` values in `GameManager.mini_bosses_defeated`
- Modified `_build_boss_door()` to show status label: "X/2 BOSSES" (orange) when locked, "ENTER..." (green) when unlocked
- Door visual changes color: dark (locked) vs slightly brighter (unlocked)
- Modified `_build_zone_exits()` to only create the ToBossRoom ZoneExit when `_count_mini_bosses_defeated() >= MINI_BOSSES_REQUIRED`
- When requirements aren't met, the exit simply doesn't exist — player sees the door but can't interact

### Key Design

The gate reads from `GameManager.mini_bosses_defeated` dictionary which tracks: alpha_raccoon, crow_matriarch, rat_king, pigeon_king. Any 2 of these 4 unlocks the boss door. This encourages exploration across zones (Neighborhood, Backyard, Sewers, Rooftops) without requiring 100% completion.
