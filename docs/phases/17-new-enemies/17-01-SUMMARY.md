---
phase: 17
plan: 01
subsystem: enemies
tags: [enemy, stealth, ambush, state-machine, cat]
dependency_graph:
  requires: [3, 4, 6]  # Enemy Foundation, Combat Polish, World Building
  provides: ["StrayCat enemy with stealth ambush behavior", "Cat stealth/pounce/retreat states"]
  affects: [20]  # Mini-bosses may reference new enemy patterns
tech_stack:
  added: []
  patterns: ["Stealth state with alpha modulation", "Pounce lunge attack with deceleration", "Retreat-to-stealth loop"]
file_tracking:
  created:
    - characters/enemies/stray_cat.gd
    - characters/enemies/stray_cat.tscn
    - characters/enemies/states/cat_stealth.gd
    - characters/enemies/states/cat_pounce.gd
    - characters/enemies/states/cat_retreat.gd
  modified:
    - world/zones/neighborhood.tscn
decisions:
  - decision: "Path-based extends for StrayCat"
    rationale: "Avoids autoload scope issues seen in Phase 16, consistent with Raccoon pattern"
  - decision: "CatStealth as initial state"
    rationale: "Cats must start hidden — defines the ambush identity"
  - decision: "0.3s pounce with 0.1-0.25 active frames"
    rationale: "Fast enough to feel dangerous, short enough window for skilled dodging"
metrics:
  duration: "~2 minutes"
  completed: "2026-01-28"
---

# Phase 17 Plan 01: Stray Cat Enemy Summary

**Stealthy ambush cat with alpha-based stealth, fast pounce lunge, and auto-retreat loop**

## What Was Built

The Stray Cat is a new enemy type that introduces stealth mechanics — a first for the enemy roster. Unlike Raccoons (patrol/chase) and Crows (fast/fly), cats are nearly invisible (15% alpha) until they pounce for high damage (20), then retreat and re-stealth.

### Behavior Loop
1. **CatStealth** — Sprite at 0.15 alpha, slowly stalks toward player at half patrol speed
2. **CatPounce** — Reveals fully, "!" telegraph, lunges at 200px/s with hitbox active 0.1-0.25s
3. **CatRetreat** — Flees away from player at chase_speed, fades back to stealth over 0.8s
4. **CatStealth** — Loop restarts

### Stats
| Stat | Value | Comparison |
|------|-------|------------|
| HP | 30 | Fragile (Raccoon: 40, Crow: 25) |
| Damage | 20 | Highest non-boss (Raccoon: 15, Crow: 10) |
| Pounce Speed | 200 | Faster than any enemy chase speed |
| Detection | 60 | Shorter range (Raccoon: 70) |
| EXP | 30 | Highest regular enemy |
| Cooldown | 2.5s | Long (Raccoon: 1.2) |

### Files Created
- `stray_cat.gd` — Extends enemy_base via path, cat-shaped polygon sprite (orange/ginger), custom drops
- `stray_cat.tscn` — Full scene with StateMachine (8 states), hitbox/hurtbox/health components
- `cat_stealth.gd` — Stealth state: alpha modulation, slow approach, 3s no-target timeout to Idle
- `cat_pounce.gd` — Pounce: reveal, lunge, hitbox frames, telegraph "!", squash-stretch juice
- `cat_retreat.gd` — Retreat: flee direction, velocity decay, alpha tween back to stealth

### Neighborhood Placement
- StrayCat1: Vector2(300, 400) — near the stores area
- StrayCat2: Vector2(550, 200) — near the road, between houses

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Path-based extends (`res://characters/enemies/enemy_base.gd`) | Avoids class_name autoload scope issues from Phase 16 |
| CatStealth as initial_state | Cat identity is defined by starting hidden |
| 0.3s pounce window (active 0.1-0.25s) | Dangerous but dodgeable — rewards alert players |
| 200px/s pounce_speed | Significantly faster than chase_speed for burst feel |
| 0.8s retreat with alpha tween | Enough time for player to counterattack before cat re-stealths |
| Orange/ginger cat color | Visually distinct from gray raccoons and black crows |

## Deviations from Plan

None — plan executed exactly as written.

## Commits

| Commit | Type | Description |
|--------|------|-------------|
| `282e333` | feat | Create Stray Cat enemy with stealth states (4 GDScript files) |
| `8246fcd` | feat | Create cat scene and place in neighborhood (tscn + zone update) |

## Next Phase Readiness

- **Phase 17-02 (Sewer Rat):** Can follow same pattern — extend enemy_base, create custom states, place in zone
- **Phase 20 (Mini-Bosses):** Cat stealth pattern could be referenced for stealth boss mechanics
- **No blockers** — StrayCat is self-contained and follows established enemy architecture
