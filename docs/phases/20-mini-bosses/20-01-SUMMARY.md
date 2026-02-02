---
phase: 20-mini-bosses
plan: 01
subsystem: enemies
tags: [mini-boss, attack-patterns, events, save-migration, equipment, health-bar, gdscript]

# Dependency graph
requires:
  - phase: 11-boss
    provides: "BossHealthBar, boss signal pattern, EnemyBase"
  - phase: 14-save
    provides: "SaveManager with version-based save/load"
  - phase: 16-ring-menu
    provides: "EquipmentDatabase, EquipmentManager, Inventory"
provides:
  - "MiniBossBase class extending EnemyBase with attack pattern cycling"
  - "MiniBossIdle state for mini-boss AI"
  - "Events.mini_boss_spawned and Events.mini_boss_defeated signals"
  - "SaveManager v2 with mini_bosses_defeated persistence"
  - "GameManager mini-boss defeat tracking and auto-save"
  - "3 rare mini-boss equipment items (raccoon_crown, crow_feather_coat, rat_king_collar)"
  - "BossHealthBar mini-boss support with orange fill color"
affects: [20-02-alpha-raccoon, 20-03-crow-matriarch, 20-04-rat-king]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Path-based extends for MiniBossBase (res://characters/enemies/enemy_base.gd)"
    - "Attack pattern cycling via array + index modulo"
    - "Save version migration with .get() defaults"

key-files:
  created:
    - "characters/enemies/mini_boss_base.gd"
    - "characters/enemies/states/mini_boss_idle.gd"
  modified:
    - "autoloads/events.gd"
    - "autoloads/save_manager.gd"
    - "autoloads/game_manager.gd"
    - "systems/equipment/equipment_database.gd"
    - "ui/hud/boss_health_bar.gd"

key-decisions:
  - "MiniBossIdle uses player. convention (not enemy.) matching State base class and 10+ regular enemy states"
  - "Save version bumped 1→2 with graceful v1 migration via .get() defaults"
  - "Mini-boss signals separate from boss signals (mini_boss_spawned vs boss_spawned)"
  - "Orange health bar color (0.9, 0.6, 0.2) distinguishes mini-boss from red boss bar"
  - "2s auto-save delay after mini-boss defeat (vs 3s for full boss)"

patterns-established:
  - "MiniBossBase: attack_patterns array + current_attack_index cycling"
  - "Spawned minions tracking array for death cleanup"
  - "Mini-boss death sequence: 3 flashes + 12 particles (lighter than boss 5 flashes + 20 particles)"

# Metrics
duration: 3min
completed: 2026-01-29
---

# Phase 20 Plan 01: Mini-Boss Foundation Summary

**MiniBossBase class with attack pattern cycling, Events signals, SaveManager v2 migration, GameManager tracking, 3 rare equipment items, and BossHealthBar orange mini-boss support**

## Performance

- **Duration:** 3 min
- **Started:** 2026-01-29T02:58:40Z
- **Completed:** 2026-01-29T03:01:52Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- MiniBossBase extends EnemyBase with attack pattern cycling, loot granting, minion cleanup, and death sequence
- MiniBossIdle state waits idle_duration, faces target, cycles to next attack via get_attack_state_name()
- Events bus extended with mini_boss_spawned and mini_boss_defeated signals
- SaveManager upgraded v1→v2 with mini_bosses_defeated dictionary and graceful v1 migration
- GameManager tracks mini-boss defeats and auto-saves with 2s delay
- EquipmentDatabase gains 3 rare items: raccoon_crown (+15HP +5ATK), crow_feather_coat (+10SPD +10DEF), rat_king_collar (+8ATK +5Guard)
- BossHealthBar adapted with orange fill color, 11pt font, mini-boss signal connections

## Task Commits

Each task was committed atomically:

1. **Task 1: MiniBossBase class, MiniBossIdle state, and Events signals** - `bedfdb8` (feat)
2. **Task 2: SaveManager, GameManager, EquipmentDatabase, and BossHealthBar integration** - `290370b` (feat)

## Files Created/Modified
- `characters/enemies/mini_boss_base.gd` - MiniBossBase class extending EnemyBase (NEW)
- `characters/enemies/states/mini_boss_idle.gd` - MiniBossIdle state with attack cycling (NEW)
- `autoloads/events.gd` - Added mini_boss_spawned and mini_boss_defeated signals
- `autoloads/save_manager.gd` - SAVE_VERSION 2, mini_bosses_defeated in default/gather/apply
- `autoloads/game_manager.gd` - mini_bosses_defeated dict, defeat handler, auto-save
- `systems/equipment/equipment_database.gd` - 3 rare mini-boss loot items
- `ui/hud/boss_health_bar.gd` - Mini-boss signal handlers, orange fill, flash color fix

## Decisions Made
- MiniBossIdle uses `player.` convention matching State base class (not `enemy.` legacy)
- Save version bumped 1→2 with graceful v1 migration via `.get()` defaults
- Mini-boss signals are separate from boss signals to avoid conflicts
- Orange health bar (0.9, 0.6, 0.2) visually distinguishes mini-bosses from red full boss
- 2s auto-save delay after mini-boss defeat (shorter than 3s boss delay)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- MiniBossBase ready for Plans 02-04 to extend with specific mini-bosses
- Attack patterns array + cycling system ready for boss-specific states
- All signal wiring in place: spawn → HUD bar, defeat → GameManager → SaveManager
- Equipment loot IDs registered and ready for assignment to specific mini-bosses

---
*Phase: 20-mini-bosses*
*Completed: 2026-01-29*
