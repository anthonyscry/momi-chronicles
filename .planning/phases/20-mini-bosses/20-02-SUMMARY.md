---
phase: 20-mini-bosses
plan: 02
subsystem: enemies
tags: [mini-boss, alpha-raccoon, neighborhood, aoe-attack, summon, gdscript, tscn]

# Dependency graph
requires:
  - phase: 20-01
    provides: "MiniBossBase class, MiniBossIdle state, Events signals, SaveManager v2, GameManager tracking, EquipmentDatabase items, BossHealthBar"
provides:
  - "AlphaRaccoon mini-boss class (120 HP, ground slam + summon)"
  - "AlphaSlam AoE attack state with telegraph/leap/impact/recovery phases"
  - "AlphaSummon raccoon reinforcement state with minion cap"
  - "Alpha Raccoon scene file with full state machine"
  - "Neighborhood zone trigger for mini-boss encounter"
affects: [20-03-crow-matriarch, 20-04-rat-king]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "AoE damage via distance check (not hitbox) for ground slam"
    - "Sprite shake telegraph for attack windup"
    - "Polygon2D expanding shockwave visual effect"
    - "Programmatic zone trigger (Area2D + body_entered) for boss spawning"
    - "One-time spawn guard via defeated flag + zone-load flag"

key-files:
  created:
    - "characters/enemies/alpha_raccoon.gd"
    - "characters/enemies/alpha_raccoon.tscn"
    - "characters/enemies/states/alpha_slam.gd"
    - "characters/enemies/states/alpha_summon.gd"
  modified:
    - "world/zones/neighborhood.gd"

key-decisions:
  - "AoE slam uses distance check to player/companions, not hitbox collision - cleaner for circular area"
  - "Summon cap of 3 alive minions prevents raccoon flood"
  - "Trigger at park_center (150, 480) - open space suitable for fight"
  - "Boss spawns at (150, 460) slightly north of trigger so player sees it appear"
  - "Warning octagon ground decor fades out on spawn - telegraphs danger zone"

patterns-established:
  - "Mini-boss AoE: Phase enum (TELEGRAPH/LEAP/IMPACT/RECOVERY) with phase timers"
  - "Mini-boss summon: alive count check → spawn_count = mini(max, cap - alive)"
  - "Zone trigger pattern: preload scene const + _build_trigger() + defeated check + spawned guard"

# Metrics
duration: 2.5min
completed: 2026-01-29
---

# Phase 20 Plan 02: Alpha Raccoon (Neighborhood Mini-Boss) Summary

**AlphaRaccoon mini-boss with ground slam AoE and raccoon reinforcement summon, spawned via Neighborhood zone area trigger at park center**

## Performance

- **Duration:** 2.5 min
- **Started:** 2026-01-29T03:06:11Z
- **Completed:** 2026-01-29T03:08:39Z
- **Tasks:** 2
- **Files created:** 4
- **Files modified:** 1

## Accomplishments
- AlphaRaccoon class extends MiniBossBase: 120 HP, 20 damage, cycles AlphaSlam/AlphaSummon, drops Raccoon Crown
- AlphaSlam state: 4-phase AoE attack (0.5s telegraph with sprite shake, 0.3s leap, 0.1s impact with screen shake + expanding orange shockwave, 0.6s recovery). Damages player and companions within 40px radius
- AlphaSummon state: 3-phase summon (0.6s charge with purple glow, instant summon of 1-2 raccoons capped at 3 alive, 0.8s recovery). Tracks minions in spawned_minions for boss death cleanup
- Alpha Raccoon scene (alpha_raccoon.tscn): CharacterBody2D with Polygon2D sprite, StateMachine (MiniBossIdle/AlphaSlam/AlphaSummon/Chase/Hurt/Death), DetectionArea, Hitbox, Hurtbox, HealthComponent
- Neighborhood zone trigger: preloaded scene, programmatic Area2D at park_center (150,480), checks GameManager.mini_bosses_defeated before building, spawns boss on player entry, removes trigger + fades warning, plays boss music
- Visual identity: 1.8x scale dark purple-grey body, gold crown polygon, face scar detail

## Task Commits

1. **feat(20-02): add Alpha Raccoon mini-boss with slam and summon attacks** - `6b4e433`
   - AlphaRaccoon class, AlphaSlam state, AlphaSummon state, scene file, neighborhood trigger

## Files Created/Modified
- `characters/enemies/alpha_raccoon.gd` - AlphaRaccoon class extending MiniBossBase (NEW)
- `characters/enemies/alpha_raccoon.tscn` - Scene with full node tree and state machine (NEW)
- `characters/enemies/states/alpha_slam.gd` - Ground slam AoE attack state (NEW)
- `characters/enemies/states/alpha_summon.gd` - Raccoon reinforcement summon state (NEW)
- `world/zones/neighborhood.gd` - Added ALPHA_RACCOON_SCENE preload, _build_mini_boss_trigger(), trigger callback

## Decisions Made
- AoE slam uses distance check to player/companions rather than hitbox collision for clean circular area
- Summon cap of 3 alive minions prevents overwhelming the player with raccoons
- Trigger placed at park_center (150, 480) - existing open area in Neighborhood zone
- Boss spawns at (150, 460) slightly north of trigger center so player sees appearance
- Warning ground marking (faint red octagon) telegraphs danger zone, fades on spawn

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Alpha Raccoon pattern established for Plans 03 (Crow Matriarch) and 04 (Rat King)
- Zone trigger pattern reusable: preload scene + _build_trigger + defeated check + spawned guard
- AoE and summon state patterns serve as templates for future mini-boss attack states
- All integration points verified: MiniBossBase → Events → GameManager → SaveManager → BossHealthBar

---
*Phase: 20-mini-bosses*
*Completed: 2026-01-29*
