---
phase: 36-rooftops
plan: 01
type: execute
subsystem: enemies
tags: [pigeon, flock, aerial, rooftop, enemy]
tech-stack:
  added: []
  patterns: [flock-coordination, aerial-combat, formation-flying]
---

# Phase 36 Plan 01: Pigeon Enemy Implementation Summary

## Objective
Created a flock-based pigeon enemy that spawns in groups of 3-6 and coordinates aerial swoop attacks from rooftops. Pigeons are weak individually but dangerous in groups, with coordinated attack patterns and group flee behavior when threatened.

## Key Files Created

| File | Purpose |
|------|---------|
| `characters/enemies/pigeon.gd` | Pigeon enemy with stats, flock state, and coordination logic |
| `characters/enemies/pigeon.tscn` | Scene with AnimatedSprite2D, hitbox, hurtbox, detection area, and state machine |
| `characters/enemies/states/pigeon_flock_idle.gd` | Formation hovering state, lead pigeon monitors for player |
| `characters/enemies/states/pigeon_flock_chase.gd` | Coordinated pursuit with formation flying and swoop timing |
| `characters/enemies/states/pigeon_swoop_attack.gd` | Three-phase aerial attack: dive → damage → return |
| `characters/enemies/states/pigeon_hurt.gd` | Brief pause with HP threshold flee check |
| `characters/enemies/states/pigeon_death.gd` | Fall and fade out, notifies flock |
| `art/generated/enemies/pigeon_*.png` | Placeholder sprite sheets for all animations |

## Key Files Modified

| File | Changes |
|------|---------|
| `autoloads/events.gd` | Added pigeon signals and flock management functions |
| `characters/enemies/enemy_base.gd` | Added flock management methods for flying enemies |

## Pigeon Stats

| Stat | Value |
|------|-------|
| HP | 30 (weak individually) |
| Damage | 15 (swoop attack) |
| Speed | 120 (fly), 180 (flee) |
| Detection Range | 256 pixels |
| Attack Range | 180 pixels (aerial) |
| Flee Threshold | 30% HP |
| Group Size | 3-6 pigeons |
| Swoop Delay | 0.3s between pigeons |

## Flock Behavior

### Spawn and Formation
1. Rooftop spawner creates 3-6 pigeons (random count)
2. First pigeon spawned becomes lead pigeon
3. All pigeons added to same flock group
4. Lead pigeon assigned perch position at spawn point
5. Other pigeons calculate formation offsets around lead (circular pattern)

### Attack Coordination
1. Lead pigeon detects player → emits `pigeon_detected_player`
2. All pigeons transition to `FlockChase`
3. Lead schedules immediate swoop (delay = 0)
4. Each subsequent pigeon schedules swoop with delay: `flock_position × 0.3s`
5. Pigeons swoop in sequence, not simultaneously
6. After swoop, all return to perch and resume `FlockIdle`

### Flee Behavior
1. Any pigeon taking damage checks HP threshold (30%)
2. If below threshold, `is_fleeing = true`
3. `pigeon_fled` signal emitted
4. All flock members transition to `FlockChase` with flee direction
5. Fleeing pigeons fly upward and away from threat

### Death Handling
1. When pigeon dies, `pigeon_death` state emits `pigeon_died`
2. Lead pigeon checks remaining flock size
3. If lead died, promote next pigeon to lead
4. Formation recalculates with remaining members

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Circular formation pattern | Natural-looking spacing, each pigeon gets unique angle |
| Lead pigeon coordinates detection | Avoids duplicate detection signals, clear responsibility |
| Sequential swoop attacks (0.3s delay) | Prevents overwhelming player, creates rhythm |
| Flee at 30% HP threshold | Gives player chance to thin flock before retreat |
| Three-phase swoop attack | Clear phases: dive (telegraph), damage (hitbox), return (reposition) |

## Deviations from Plan

None - plan executed exactly as written.

## Authentication Gates

None - no external services required.

## Dependencies

- **Requires:** `components/state_machine/state_machine.gd` (existing)
- **Requires:** `components/hitbox/hitbox.gd` (existing)
- **Requires:** `components/hurtbox/hurtbox.gd` (existing)
- **Requires:** `components/health/health_component.gd` (existing)

## Next Phase Readiness

- **Ready for:** Phase 36-02 Rooftop spawner integration
- **Ready for:** Phase 36-03 Rooftop zone encounters
- **Ready for:** Phase 36-04 Pigeon patrol routes

## Metrics

- **Duration:** Single session
- **Completed:** 2026-02-01
- **Files Created:** 12
- **Files Modified:** 2
