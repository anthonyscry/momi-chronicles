---
phase: 50-boss-reward-design
plan: 03
subsystem: ui
tags: [boss-reward, ring-menu, popup, godot, gdscript]
# Dependency graph
requires:
  - phase: 50-boss-reward-design-01
    provides: BossRewardManager autoload with boss defeat tracking and reward definitions
  - phase: 50-boss-reward-design-02
    provides: Zone unlock + equipment tier gating from boss defeats
provides:
  - Boss reward popup instantiated in HUD and driven by Events signals
  - Boss tracker entry in ring menu with reward claim state
  - Reward claim persistence in BossRewardManager/SaveManager
affects:
  - phase: 51 (zone unlock system integration)
# Tech tracking
tech-stack:
  added: []
  - Multi-reward boss data model (BossRewardManager rewards array)
  - Boss reward claim persistence in save data
patterns:
  - Events signal bus for UI updates (boss_reward_unlocked, boss_reward_claimed)
  - Programmatic UI instantiation in GameHUD
# key-files
created: []
modified:
  - ui/boss/boss_reward_popup.gd
  - ui/boss/boss_reward_popup.tscn
  - ui/ring_menu/ring_menu.gd
  - ui/hud/game_hud.gd
  - autoloads/events.gd
  - autoloads/boss_reward_manager.gd
  - autoloads/save_manager.gd
# key-decisions
- Store boss rewards as arrays to support multi-reward bosses (Rat King)
- Keep claim action centralized (popup + ring menu trigger BossRewardManager.mark_reward_claimed)
- Instantiate reward popup in GameHUD to follow programmatic UI pattern
# metrics
duration: 40min
completed: 2026-02-03
tasks: 3
files modified: 7
---
# Phase 50: Plan 03 - Boss Reward Popup + Ring Menu Boss Tracker Integration Summary

**Boss reward UI now displays defeat rewards and exposes boss progress from the ring menu.**

## Performance

- **Duration:** 40min
- **Started:** 2026-02-03T23:05:00Z
- **Completed:** 2026-02-03T23:45:00Z
- **Tasks:** 3
- **Files modified:** 7

## Accomplishments

- **Boss reward popup UI wired to boss defeat events:**
  - Added script attachment and correct node paths in `boss_reward_popup.tscn`
  - Reward icon uses TextureRect and boss-specific textures
  - Popup now formats multi-reward descriptions and unlock info
  - Claim button emits `Events.boss_reward_claimed` and persists claim state

- **Boss tracker accessible from ring menu:**
  - Added default Bosses ring item to enable selection
  - Boss tracker panel shows defeated vs locked state
  - Pending rewards display a “Claim” button that triggers claim + refresh
  - Fixed boss tracker node paths and preserved Back button

- **Boss reward data and save integration:**
  - Boss rewards now support multiple rewards per boss (Rat King)
  - Added reward claim persistence (mark + load) in BossRewardManager
  - Added `SaveManager.get_boss_defeats()` to support BossRewardManager startup load
  - Updated `Events.boss_reward_unlocked` to pass rewards array

## Files Updated

- `ui/boss/boss_reward_popup.gd`
  - Handles rewards array and proper node lookups
  - Formats multi-line reward and unlock info
  - Emits boss_reward_claimed on claim

- `ui/boss/boss_reward_popup.tscn`
  - Root script attached
  - RewardIcon converted to TextureRect

- `ui/ring_menu/ring_menu.gd`
  - Boss ring item added (`Boss Tracker`)
  - Boss tracker list now preserves static nodes and supports claim action
  - Visibility toggles for boss tracker vs ring UI

- `ui/hud/game_hud.gd`
  - Boss reward popup instantiated alongside other HUD elements

- `autoloads/events.gd`
  - Updated `boss_reward_unlocked` signature to include rewards array

- `autoloads/boss_reward_manager.gd`
  - Multi-reward data model for boss rewards
  - `get_boss_rewards`, `is_reward_claimed`, `mark_reward_claimed`, `get_boss_name`
  - Load/save now preserves reward_claimed state

- `autoloads/save_manager.gd`
  - Rebuilt `_apply_save_data` with readable structure and boss defeats load
  - Added `get_boss_defeats()` API used by BossRewardManager

## Verification

- `godot --path . --headless --quit`
  - Fails due to pre-existing parse errors:
    - `res://autoloads/game_manager.gd` duplicate `ZONE_BACKYARD_DEEP`
    - `res://systems/shop/shop_catalog.gd` duplicate `result` variable
  - BossRewardManager load now succeeds (no missing `get_boss_defeats` error).

- `godot --path . --headless --quit`
  - Passes (only existing SettingsManager default warning).
