---
phase: 20-mini-bosses
plan: 04
subsystem: enemies
tags: [mini-boss, rat-king, poison-cloud, split-mechanic, sewers, aoe, gdscript]

# Dependency graph
requires:
  - phase: 20-01
    provides: "MiniBossBase, MiniBossIdle, Events signals, GameManager tracking, Equipment IDs"
  - phase: 17-02
    provides: "Sewer Rat enemy (spawned during split)"
  - phase: 19-02
    provides: "Sewers zone layout with corridor segments"
provides:
  - "RatKing mini-boss class with 50% HP split mechanic"
  - "RatKingPoisonCloud AoE attack state"
  - "Rat King scene (rat_king.tscn) with 5 states"
  - "Sewers zone mini-boss trigger in lower corridor"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "50% HP split: boolean-guarded _on_hurt() override spawns minions once"
    - "Persistent AoE cloud: Area2D + tween pulse + timer auto-despawn"
    - "Zone mini-boss trigger: Area2D + defeat flag check + spawn callback"

key-files:
  created:
    - "characters/enemies/rat_king.gd"
    - "characters/enemies/rat_king.tscn"
    - "characters/enemies/states/rat_king_poison_cloud.gd"
  modified:
    - "world/zones/sewers.gd"

key-decisions:
  - "Split in _on_hurt() override (not a state) — boss continues fighting after splitting"
  - "has_split boolean guard prevents infinite rat spawning on repeated hits"
  - "Post-split: sprite shrinks (2.0→1.7) + speed increases (55→70) — wounded desperation feel"
  - "Attack pattern: PoisonCloud → MiniBossIdle — simple 2-pattern cycle with clear player windows"
  - "Trigger at (325,445) in lower horizontal corridor — wide enough for mini-boss fight"

patterns-established:
  - "Mini-boss _on_hurt() override for mid-fight mechanic triggers"
  - "Programmatic poison cloud with pulse tween + timed auto-despawn"

# Metrics
duration: 2.5min
completed: 2026-01-29
---

# Phase 20 Plan 04: Rat King (Sewers Mini-Boss) Summary

**RatKing class with 150 HP, poison AoE cloud attack, dramatic 50% HP split spawning 4 sewer rats, and sewers zone trigger in lower corridor**

## Performance

- **Duration:** 2.5 min
- **Started:** 2026-01-29T03:07:12Z
- **Completed:** 2026-01-29T03:09:41Z
- **Tasks:** 2
- **Files created:** 3
- **Files modified:** 1

## Accomplishments
- RatKing class (150 HP, 18 dmg, 120 knockback) extends MiniBossBase with unique split mechanic
- RatKingPoisonCloud state creates Area2D AoE poison zone at player position with 4s duration
- Poison cloud applies DoT via HealthComponent.apply_poison(), has pulse animation and fade-out despawn
- 50% HP split mechanic guarded by has_split boolean — spawns exactly 4 sewer rats in circle
- Post-split visual transformation: sprite shrinks (2.0→1.7), chase speed increases (55→70)
- Split includes screen shake, green flash, and per-rat spawn poof particles
- Rat King scene with 5 states: MiniBossIdle, RatKingPoisonCloud, Chase, Hurt, Death
- Programmatic appearance: dirty brown body, 3-nub crown, toxic green eyes, curved tail
- Sewers zone trigger at (325, 445) with sickly green warning decor and defeat flag check
- Trigger spawns boss, removes itself, fades warning, and plays boss music
- Drops Rat King's Collar equipment + 8-15 coins + 3-5 health pickups on defeat

## Task Commits

Each task was committed atomically:

1. **Task 1 + Task 2: Rat King class, poison cloud state, scene, and sewers trigger** - `fee96d6` (feat)

## Files Created/Modified
- `characters/enemies/rat_king.gd` - RatKing class with split mechanic, 150 HP (NEW)
- `characters/enemies/rat_king.tscn` - Scene with 5 states, larger body/hurtbox (NEW)
- `characters/enemies/states/rat_king_poison_cloud.gd` - AoE poison cloud attack state (NEW)
- `world/zones/sewers.gd` - RAT_KING_SCENE preload, _build_mini_boss_trigger(), trigger callback

## Decisions Made
- Split mechanic lives in `_on_hurt()` override (not a state) — boss continues fighting after splitting
- `has_split` boolean guard prevents infinite rat spawning on repeated hits below 50% HP
- Post-split visual feedback: sprite shrinks + speed increases for wounded desperation feel
- 2-attack cycle (PoisonCloud → MiniBossIdle) gives clear player windows between AoE attacks
- Trigger placed at (325, 445) in lower horizontal corridor — 250px wide, plenty of room for fight
- Trigger fires `_build_mini_boss_trigger()` BEFORE `_build_background()` — early setup per plan spec

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None — no external service configuration required.

## Next Phase Readiness
- All 3 mini-bosses (Plans 02-04) can be completed independently from foundation (Plan 01)
- Rat King is the final zone-specific mini-boss, completing the sewers encounter set
- Mini-boss system fully functional: spawn triggers, health bars, defeat tracking, loot drops

---
*Phase: 20-mini-bosses*
*Completed: 2026-01-29*
