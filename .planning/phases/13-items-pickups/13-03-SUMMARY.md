---
phase: 13-items-pickups
plan: 03
subsystem: ui
tags: [hud, coins, particles, effects, feedback]

# Dependency graph
requires:
  - phase: 13-02
    provides: "CoinPickup, GameManager.add_coins, Events.coins_changed"
provides:
  - "CoinCounter HUD component"
  - "spawn_pickup_effect for particle bursts"
  - "flash_pickup for collection emphasis"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Smooth counting animation with delta-based step"
    - "ColorRect particles for simple visual effects"

key-files:
  created:
    - ui/hud/coin_counter.gd
    - ui/hud/coin_counter.tscn
  modified:
    - ui/hud/game_hud.tscn
    - autoloads/effects_manager.gd
    - components/health/health_pickup.gd
    - components/pickup/coin_pickup.gd

key-decisions:
  - "Coin counter positioned top-right, separate from health bar area"
  - "Smooth counting animation instead of instant number change"
  - "ColorRect-based particles for consistent visual style"

patterns-established:
  - "Pickup effects: spawn_pickup_effect + flash_pickup combo"
  - "HUD counter animation: display_coins vs target_coins delta interpolation"

# Metrics
duration: 1min
completed: 2026-01-28
---

# Phase 13 Plan 03: HUD Coin Counter & Collection Effects Summary

**Coin counter in HUD with pop animation on collect, gold/pink particle burst effects for satisfying pickup feedback**

## Performance

- **Duration:** 1 min
- **Started:** 2026-01-28T04:44:36Z
- **Completed:** 2026-01-28T04:45:58Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- CoinCounter component displays current coin count in HUD top-right
- Smooth counting animation (doesn't jump to new value)
- Pop animation when coins gained
- Gold particle burst and flash on coin collection
- Pink particle burst and flash on health pickup collection

## Task Commits

Each task was committed atomically:

1. **Task 1: Create coin counter UI** - `8762104` (feat)
2. **Task 2: Add collection visual effects** - `b753b97` (feat)

## Files Created/Modified
- `ui/hud/coin_counter.gd` - CoinCounter class with smooth animation
- `ui/hud/coin_counter.tscn` - Scene with HBoxContainer, icon, label
- `ui/hud/game_hud.tscn` - Added CoinCounter instance top-right
- `autoloads/effects_manager.gd` - Added spawn_pickup_effect, flash_pickup
- `components/health/health_pickup.gd` - Added pink visual effects
- `components/pickup/coin_pickup.gd` - Added gold visual effects

## Decisions Made
- Positioned coin counter top-right, offset from edge by 8px
- Used delta-based step calculation for smooth counting (10x speed factor)
- Pop animation scales to 1.3x over 0.08s, returns over 0.12s
- Particle burst uses 5-8 particles with random outward directions
- Flash effect scales to 1.5x while fading for emphasis

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## Next Phase Readiness
- Phase 13 Items & Pickups COMPLETE
- Health pickups with magnet effect
- Coin pickups with gold shimmer
- Per-enemy drop tables (different loot per enemy type)
- HUD coin counter with animations
- Collection visual effects for satisfying feedback
- Ready for Phase 14: Save System

---
*Phase: 13-items-pickups*
*Completed: 2026-01-28*
