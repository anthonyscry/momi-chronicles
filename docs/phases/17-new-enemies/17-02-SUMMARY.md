---
phase: 17
plan: 02
subsystem: enemies
tags: [enemy, swarm, poison, dot, health-component, sewer-rat]
dependency-graph:
  requires: [03-enemy-foundation]
  provides: [sewer-rat-enemy, poison-dot-system]
  affects: [19-sewers-zone]
tech-stack:
  added: []
  patterns: [swarm-ai, pack-cohesion, damage-over-time, status-effect]
file-tracking:
  key-files:
    created:
      - characters/enemies/sewer_rat.gd
      - characters/enemies/sewer_rat.tscn
      - characters/enemies/states/rat_swarm_chase.gd
      - characters/enemies/states/rat_poison_attack.gd
    modified:
      - components/health/health_component.gd
      - world/zones/backyard.tscn
decisions:
  - id: poison-on-healthcomponent
    choice: "Poison DoT as reusable HealthComponent methods"
    rationale: "Any enemy/hazard can apply poison — not rat-specific"
  - id: pack-cohesion-approach
    choice: "Pack center averaging with jitter for swarm feel"
    rationale: "Simple yet effective — rats cluster while still feeling erratic"
  - id: poison-via-hit-targets
    choice: "Apply poison by checking hitbox.hit_targets after active frames"
    rationale: "Leverages existing hit tracking; no extra collision needed"
metrics:
  completed: 2026-01-29
  tasks: 2/2
---

# Phase 17 Plan 02: Sewer Rat Enemy Summary

**Sewer Rat swarm enemy with pack AI and poison bite DoT on reusable HealthComponent**

## What Was Built

### Poison DoT System (HealthComponent)
Added reusable poison damage-over-time to `HealthComponent`:
- `apply_poison(damage_per_tick, duration)` — starts/refreshes poison
- `clear_poison()` — removes poison and restores visuals
- `_process()` ticks poison damage at configurable intervals (0.5s default)
- Green sprite tint while poisoned, auto-clears on expiry
- Signals: `poison_started`, `poison_ended` for UI/effects

### Sewer Rat Enemy (SewerRat)
New enemy extending `enemy_base.gd`:
- **Stats**: 15 HP, 65 chase speed, 5 damage, 0.8s cooldown
- **Poison**: 3 damage/tick for 3 seconds on bite
- **Pack system**: `pack_id` groups rats for coordinated movement
- **Visual**: Small dark brown polygon (0.8x scale)
- **Drops**: 60% coin, 10% health pickup

### Swarm Chase State (RatSwarmChase)
Pack-aware chase replacing standard EnemyChase:
- Rats move toward player with pack cohesion (25% pull toward pack center)
- Erratic jitter (re-rolled every 0.3s) for scurrying movement
- Respects separation force to prevent stacking
- Transitions to RatPoisonAttack when in range

### Poison Attack State (RatPoisonAttack)
Fast bite attack (0.3s duration):
- Green "!" telegraph (shorter than standard enemy)
- Hitbox active from 33% to 83% of attack duration
- Applies poison via `health_component.apply_poison()` on hit
- Checks `hitbox.hit_targets` to find damaged nodes

### Scene & Placement
- `sewer_rat.tscn` — full scene with all components, no standard Chase/Attack states
- Pack of 4 rats placed near the shed in backyard zone (~280, 85 area)

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Poison DoT on HealthComponent | Reusable by any enemy/hazard — not rat-specific code |
| Pack cohesion via position averaging | Simple swarm behavior without navigation agents |
| Poison application via hit_targets array | Leverages existing hitbox tracking system |
| Green tint for poison visual | Distinct from stun (blue) and damage (red) |

## Deviations from Plan

None — plan executed exactly as written.

## Next Phase Readiness

- **Poison system ready** for reuse by Sewers zone (Phase 19) hazards
- **Pack AI pattern** can be extended for other swarm enemies
- **No blockers** for Phase 17 Plan 03 (Shadow enemy)
