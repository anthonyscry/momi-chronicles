---
phase: 20-mini-bosses
plan: 03
subsystem: enemies
tags: [mini-boss, crow-matriarch, dive-bomb, swarm-summon, backyard, gdscript]

# Dependency graph
requires:
  - phase: 20-01
    provides: "MiniBossBase class, Events signals, SaveManager v2, EquipmentDatabase crow_feather_coat"
provides:
  - "CrowMatriarch mini-boss class (80 HP, fast, aerial)"
  - "CrowDiveBomb attack state with 4-phase aerial dive"
  - "CrowSwarmSummon attack state spawning crow minions"
  - "Backyard zone mini-boss trigger at center"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "4-phase attack state (ASCEND->TELEGRAPH->DIVE->RECOVERY) with invulnerability window"
    - "Circular minion spawn formation with alive count cap"
    - "Zone-level mini-boss trigger with defeat persistence check"

key-files:
  created:
    - "characters/enemies/crow_matriarch.gd"
    - "characters/enemies/crow_matriarch.tscn"
    - "characters/enemies/states/crow_dive_bomb.gd"
    - "characters/enemies/states/crow_swarm_summon.gd"
  modified:
    - "world/zones/backyard.gd"

key-decisions:
  - "4-phase dive bomb (ASCEND->TELEGRAPH->DIVE->RECOVERY) gives clear dodge window"
  - "Invulnerable during ascend only, vulnerable during recovery — rewards patience"
  - "Crow swarm cap at 4 alive minions prevents overwhelming spawns"
  - "Trigger at backyard center (192, 108) with 70x50 area — compact for confined zone"
  - "Boss spawns at (192, 90) slightly above center for visual clarity"

patterns-established:
  - "Zone-level _build_mini_boss_trigger() with preloaded scene + defeat check"
  - "Warning decor polygon on ground as visual hint before trigger"
  - "Trigger cleanup: queue_free trigger, fade-out warning on boss spawn"

# Metrics
duration: 3min
completed: 2026-01-29
---

# Phase 20 Plan 03: Crow Matriarch (Backyard Mini-Boss) Summary

**CrowMatriarch with aerial dive bomb (4-phase invulnerability), crow swarm summon (3-4 circular spawn), and Backyard zone trigger at center with defeat persistence**

## Performance

- **Duration:** 3 min
- **Started:** 2026-01-29T03:06:30Z
- **Completed:** 2026-01-29T03:09:15Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- CrowMatriarch class: 80 HP, chase_speed=90, attack_damage=15, drops Crow Feather Coat, cycles CrowDiveBomb and CrowSwarmSummon
- CrowDiveBomb state: 4-phase (ASCEND 0.4s → TELEGRAPH 0.3s → DIVE 0.4s → RECOVERY 0.5s), invulnerable during ascend, 1.5x damage (22) on dive, red target indicator, screen shake on impact
- CrowSwarmSummon state: spawns 3-4 crows in circular formation, caps at 4 alive minions via spawned_minions tracking, feather poof VFX per spawn
- CrowMatriarch scene: StateMachine with MiniBossIdle, CrowDiveBomb, CrowSwarmSummon, Chase, Hurt, Death; smaller collision shapes (8 radius body, 130 detection, 16x14 hitbox, 10/24 hurtbox)
- Backyard zone trigger: preloaded scene, _build_mini_boss_trigger() at (192, 108), defeat persistence check, warning decor polygon, boss music on spawn

## Task Commits

Each task was committed atomically:

1. **Task 1 + Task 2: Crow Matriarch class, states, scene, and Backyard trigger** - `3ef50a2` (feat)

## Files Created/Modified
- `characters/enemies/crow_matriarch.gd` — CrowMatriarch class extending MiniBossBase (NEW)
- `characters/enemies/crow_matriarch.tscn` — Crow Matriarch scene with all states (NEW)
- `characters/enemies/states/crow_dive_bomb.gd` — CrowDiveBomb 4-phase aerial attack state (NEW)
- `characters/enemies/states/crow_swarm_summon.gd` — CrowSwarmSummon circular minion spawner (NEW)
- `world/zones/backyard.gd` — Added CROW_MATRIARCH_SCENE preload, _build_mini_boss_trigger(), trigger callback

## Decisions Made
- 4-phase dive bomb gives clear visual telegraph (red circle) and dodge window during recovery
- Invulnerable only during ascend phase — vulnerable in telegraph, dive (moving fast), and recovery
- Crow swarm cap at 4 alive minions prevents spiral of unlimited spawns
- Compact 70x50 trigger area for backyard's confined space (vs 100x70 for neighborhood)
- Boss spawns at (192, 90), slightly above center, for visual separation from trigger point

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None — no external service configuration required.

## Next Phase Readiness
- Crow Matriarch fully functional in Backyard zone
- Pattern established for zone-level mini-boss triggers (reusable for Plan 20-04 Rat King in Sewers)
- All 3 mini-boss equipment items now have corresponding bosses (raccoon_crown → 20-02, crow_feather_coat → 20-03, rat_king_collar → 20-04)

---
*Phase: 20-mini-bosses*
*Completed: 2026-01-29*
