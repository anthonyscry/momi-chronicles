---
phase: 28
plan: 01
subsystem: inventory, combat, zones
tags: [bug-fix, preload, item-effects, revival, antidote, scene-caching]
requires: []
provides:
  - Working REVIVE item effect (Revival Bone)
  - Working CURE_STATUS item effect (Antidote)
  - Preloaded boss summon scene
  - Cached enemy respawn scenes
affects:
  - Phase 29 (signal integrity — builds on working item system)
tech-stack:
  added: []
  patterns:
    - "preload() for all scene references in hot paths"
    - "scene_resource caching in spawn data dictionaries"
key-files:
  created: []
  modified:
    - systems/inventory/inventory.gd
    - characters/enemies/states/boss_attack_summon.gd
    - world/zones/base_zone.gd
decisions:
  - id: DEC-2801-01
    description: "Use party_manager.knocked_out.keys()[0] for first-come-first-revived ordering"
    rationale: "Simple, deterministic — revives the companion who was knocked out first"
  - id: DEC-2801-02
    description: "Cache scenes with load() at zone _ready() init, not preload()"
    rationale: "Enemy scene_file_path is dynamic per-instance, can't use preload(); load() at init is equivalent to preload() for performance (runs once, cached by ResourceLoader)"
metrics:
  duration: ~5 min
  completed: 2026-01-29
---

# Phase 28 Plan 01: Critical Bug Fixes & Preload Optimization Summary

**One-liner:** Fix Revival Bone/Antidote item effects and eliminate runtime load() stutter in boss summon and enemy respawn.

## What Was Done

### Task 1: Fix Revival Bone and Antidote item effects
**Commit:** `52f868c`

**BUG-01 — Revival Bone:**
- Replaced the REVIVE stub (which always returned `true` without doing anything) with working implementation
- Accesses `GameManager.party_manager.knocked_out` to find first knocked-out companion
- Calls `revive_companion(companion_id, value)` where value is the item's heal percent (0.5 = 50% HP)
- Returns `false` when no companion is knocked out — item is NOT consumed
- Spawns gold glow effect on revival

**BUG-02 — Antidote:**
- Renamed `cure_poison()` → `clear_poison()` to match `HealthComponent.clear_poison()` (line 178 of health_component.gd)
- Both the `has_method()` check and the method call updated

### Task 2: Fix preload issues in boss summon and enemy respawn
**Commit:** `1a09586`

**BUG-03 — Boss Summon:**
- Added `const RACCOON_SCENE: PackedScene = preload("res://characters/enemies/raccoon.tscn")` at file top
- Replaced runtime `load()` call in `_do_summon()` with `RACCOON_SCENE` const reference
- Zero frame stutter when Raccoon King summons minions during combat

**DEBT-01 — Enemy Respawn:**
- Added `"scene_resource": load(enemy.scene_file_path)` in `_capture_enemy_spawn_data()` (runs once at zone init)
- Propagated `scene_resource` through `_on_enemy_died()` → spawn_entry dict
- Propagated `scene_resource` through `_on_respawned_enemy_died()` → re-death cycle
- Replaced runtime `load(scene_path)` in `_respawn_enemy()` with `spawn_entry.get("scene_resource")`
- Added fallback lookup in `original_enemy_configs` for cache misses
- No runtime `load()` calls remain in hot paths

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed CURE_STATUS indentation bug**
- **Found during:** Task 1
- **Issue:** `hp.has_method("clear_poison")` and `hp.clear_poison()` were indented at the wrong level — outside the `if target.has_node("HealthComponent"):` block, meaning `hp` variable was referenced outside its declaring scope
- **Fix:** Corrected indentation to place both lines inside the `if` block
- **Files modified:** systems/inventory/inventory.gd
- **Commit:** `52f868c` (included in Task 1 commit)

## Requirements Covered

| Requirement | Status | Evidence |
|-------------|--------|----------|
| BUG-01 | ✅ Fixed | `revive_companion()` called in REVIVE branch |
| BUG-02 | ✅ Fixed | `clear_poison()` matches health_component.gd |
| BUG-03 | ✅ Fixed | `const RACCOON_SCENE = preload(...)` at file top |
| DEBT-01 | ✅ Fixed | `scene_resource` cached at zone init, used in respawn |

## Verification Results

| Check | Result |
|-------|--------|
| `cure_poison` in inventory.gd | 0 matches ✅ |
| `clear_poison` in inventory.gd | 2 matches ✅ |
| `revive_companion` in inventory.gd | 1 match ✅ |
| `= load(` in boss_attack_summon.gd | 0 matches ✅ |
| `preload` in boss_attack_summon.gd | RACCOON_SCENE const ✅ |
| `scene_resource` in base_zone.gd | 5 matches ✅ |
| `= load(` in base_zone.gd respawn | 0 matches (only in init) ✅ |

## Next Phase Readiness

No blockers for Phase 29 (Signal Integrity & Polish). All item effects now work correctly, providing a stable foundation for signal wiring and cleanup work.
