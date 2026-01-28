---
phase: 13-items-pickups
plan: 02
subsystem: items
tags: [pickups, coins, economy, drops, gdscript]

# Dependency graph
requires:
  - phase: 13-01
    provides: Magnet pickup pattern and pickup_collected signal
provides:
  - CoinPickup class with magnet collection
  - Configurable enemy drop table system
  - Per-enemy drop rates (Raccoon, Crow, Boss)
  - GameManager coin tracking
affects: [13-03, ui-hud, save-system]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Drop table: Array of {scene, chance, min, max} dictionaries"
    - "Currency tracking: GameManager.add_coins(), spend_coins(), coins_changed signal"

key-files:
  created:
    - components/pickup/coin_pickup.gd
    - components/pickup/coin_pickup.tscn
    - assets/audio/sfx/coin.wav
  modified:
    - autoloads/game_manager.gd
    - autoloads/events.gd
    - autoloads/audio_manager.gd
    - characters/enemies/enemy_base.gd
    - characters/enemies/raccoon.gd
    - characters/enemies/crow.gd
    - characters/enemies/boss_raccoon_king.gd

key-decisions:
  - "Coins have larger magnet (50px) and faster speed (200px/s) than health"
  - "Coins last 60s vs health's 15s lifetime"
  - "Drop table uses override method pattern for subclass customization"
  - "Drops spread with random offset to prevent stacking"

patterns-established:
  - "Drop table pattern: _init_default_drops() for subclass override"
  - "Coin tracking: GameManager.coins with add_coins/spend_coins/get_coins"

# Metrics
duration: 3min
completed: 2026-01-28
---

# Phase 13 Plan 02: Coin Pickup and Drop Tables Summary

**CoinPickup with gold shimmer and 50px magnet, plus configurable enemy drop table system with per-enemy rates**

## Performance

- **Duration:** 3 min
- **Started:** 2026-01-28T04:38:49Z
- **Completed:** 2026-01-28T04:41:40Z
- **Tasks:** 3/3
- **Files modified:** 10

## Accomplishments

- CoinPickup class with gold shimmer animation and larger magnet (50px range, 200px/s speed)
- GameManager coin tracking with add_coins(), spend_coins(), get_coins()
- coins_changed signal for HUD integration
- Configurable drop_table system in EnemyBase replacing hardcoded health drops
- Per-enemy drop rates: Raccoon (80% coins, 25% health), Crow (90% coins, 15% health), Boss (100% both)
- Drops spread out with random offset to prevent stacking
- High-pitched coin sound effect (C6-E6-G6 arpeggio)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create CoinPickup and coin infrastructure** - `2aa9f0d` (feat)
2. **Task 2: Refactor enemy drop system to use drop tables** - `6732526` (feat)
3. **Task 3: Configure per-enemy drop tables** - `281ca5b` (feat)

## Files Created/Modified

- `components/pickup/coin_pickup.gd` - CoinPickup class with magnet, shimmer, collection
- `components/pickup/coin_pickup.tscn` - Gold octagon visual, collision setup
- `assets/audio/sfx/coin.wav` - High-pitched coin collection sound
- `autoloads/game_manager.gd` - Added coins variable, add_coins(), spend_coins(), get_coins()
- `autoloads/events.gd` - Added coins_changed(total) signal
- `autoloads/audio_manager.gd` - Registered "coin" SFX
- `characters/enemies/enemy_base.gd` - Added drop_table, _init_default_drops(), _spawn_drops(), _spawn_single_drop()
- `characters/enemies/raccoon.gd` - Override _init_default_drops() with raccoon rates
- `characters/enemies/crow.gd` - Override _init_default_drops() with crow rates
- `characters/enemies/boss_raccoon_king.gd` - Override _init_default_drops() with boss rates, call _spawn_drops() in _on_died()

## Decisions Made

- Coins have 50px magnet range (vs health's 40px) for satisfying collection feel
- Coins move at 200px/s (vs health's 150px/s) for quick pickup
- Coins last 60 seconds (vs health's 15s) to allow backtracking
- Drop table uses method override pattern (_init_default_drops) for clean subclass customization
- Drops get random -8 to +8 pixel offset to spread out visually
- Boss calls _spawn_drops() before death sequence so loot appears during explosion

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Coin and health pickup systems complete
- Drop table pattern established for future item types (keys, power-ups, etc.)
- Ready for 13-03: HUD coin display integration
- coins_changed signal available for UI binding

---
*Phase: 13-items-pickups*
*Completed: 2026-01-28*
