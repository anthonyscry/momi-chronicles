---
phase: 36-rooftops
plan: "02"
type: execute
subsystem: enemies
tags: [garden-gnome, stationary-turret, bomb-attack, aoe-damage]
completed: 2026-02-01
duration: "N/A (implementation already present)"
---

# Phase 36 Plan 02: Garden Gnome Enemy Summary

## One-Liner

Stationary turret enemy (60 HP) that throws explosive bombs (25 AOE damage, 64px radius, 1.5s fuse) with orange pulsing "!" telegraph (0.8s warning) in a 4-state attack cycle.

## Objective Delivered

Garden Gnome enemy fully implemented as a stationary sentry enemy for rooftop encounters. Gnomes provide predictable but dangerous combat encounters, teaching players timing-based dodge mechanics for both bomb throws and resulting explosions.

## Files Created

### Enemy Core
| Path | Purpose |
|------|---------|
| `characters/enemies/gnome.gd` | Gnome enemy class with stats, constants, telegraph animation methods |
| `characters/enemies/gnome.tscn` | Scene with AnimatedSprite2D, DetectionArea, Hurtbox, Hitbox, TelegraphSprite, StateMachine |

### State Machine (6 States)
| Path | Purpose |
|------|---------|
| `characters/enemies/states/gnome_idle.gd` | Stationary scanning state, 0.5s player detection interval |
| `characters/enemies/states/gnome_telegraph.gd` | Orange pulsing "!" warning (0.8s duration) |
| `characters/enemies/states/gnome_throw.gd` | Bomb spawning with arc trajectory calculation |
| `characters/enemies/states/gnome_cooldown.gd` | 2.0s cooldown with player proximity check |
| `characters/enemies/states/gnome_hurt.gd` | Damage reaction, 0.4s pause, interrupts actions |
| `characters/enemies/states/gnome_death.gd` | Death animation with 0.6s fade-out |

### Projectile
| Path | Purpose |
|------|---------|
| `characters/enemies/projectiles/gnome_bomb.gd` | Arc trajectory bomb with fuse timer and AOE explosion |
| `characters/enemies/projectiles/gnome_bomb.tscn` | Bomb scene with collision and visual effects |

### Signals Integration
| Path | Added |
|------|-------|
| `autoloads/events.gd` | `gnome_threw_bomb`, `gnome_bomb_exploded`, `gnome_died`, `gnome_hurt` |

## Key Specifications

### Enemy Stats
- **HP:** 60 (tougher than pigeons, stationary = longer exposure)
- **Detection Range:** 200 pixels
- **Attack Range:** 300 pixels
- **Movement:** None (stationary turret)
- **EXP Value:** 25

### Bomb Properties
- **Damage:** 25 (AOE, hits multiple targets)
- **AOE Radius:** 64 pixels
- **Fuse Time:** 1.5 seconds (explodes on fuse end OR impact)
- **Throw Speed:** 180 pixels/second
- **Arc Height:** 80 pixels peak

### State Cycle Timing
| State | Duration | Behavior |
|-------|----------|----------|
| GnomeIdle | Until player in range | Scans every 0.5s |
| GnomeTelegraph | 0.8s | Orange pulsing "!" warning |
| GnomeThrow | 0.45s | Spawns bomb, animation |
| GnomeCooldown | 2.0s | Idle, monitors player presence |

## State Machine Diagram

```
                         ┌─────────────────────────────┐
                         │      Player Enters Range    │
                         └─────────────┬───────────────┘
                                       │
                                       ▼
                    ┌──────────────────────────────────┐
                    │          GnomeIdle               │
                    │  • Stationary, plays idle anim   │
                    │  • Scans for player every 0.5s   │
                    │  • TelegraphSprite hidden        │
                    └─────────────┬────────────────────┘
                                  │
                     Player in range? ────── No ──────► [Stay in Idle]
                                  │
                                 Yes
                                  │
                                  ▼
                    ┌──────────────────────────────────┐
                    │        GnomeTelegraph            │
                    │  • Orange "!" pulses (0.8s)      │
                    │  • Scale 1.0 → 1.4 → 1.0         │
                    │  • Color intensity oscillates    │
                    │  • TelegraphSprite visible       │
                    └─────────────┬────────────────────┘
                                  │
                         Telegraph complete (0.8s)
                                  │
                                  ▼
                    ┌──────────────────────────────────┐
                    │          GnomeThrow              │
                    │  • Plays throw animation         │
                    │  • Spawns bomb at frame 2        │
                    │  • Bomb arcs to player position  │
                    │  • Emits gnome_threw_bomb signal │
                    └─────────────┬────────────────────┘
                                  │
                         Animation complete
                                  │
                                  ▼
                    ┌──────────────────────────────────┐
                    │         GnomeCooldown            │
                    │  • Plays idle animation          │
                    │  • Timer: 2.0 seconds            │
                    │  • Monitors player proximity     │
                    └─────────────┬────────────────────┘
                                  │
                         Cooldown complete
                                  │
                    ┌─────────────┴─────────────┐
                    │  Player still in range?   │
                    └─────────────┬─────────────┘
                                  │
                     Yes ─────────┴───────── No
                      │                        │
                      ▼                        ▼
            ┌─────────────────┐   ┌─────────────────────┐
            │  GnomeTelegraph │   │      GnomeIdle      │
            │  (attack again) │   │  (return to scan)   │
            └─────────────────┘   └─────────────────────┘

                    ╔════════════════════════════════════╗
                    ║           HURT / DEATH              ║
                    ╠════════════════════════════════════╣
                    ║  From any state:                   ║
                    ║  • Interrupt current action        ║
                    ║  • Hide TelegraphSprite            ║
                    ║  • Play hurt animation (0.4s)      ║
                    ║  • Return to cycle or death        ║
                    ║                                    ║
                    ║  Death:                            ║
                    ║  • Play death animation            ║
                    ║  • Fade alpha over 0.6s            ║
                    ║  • Emit gnome_died signal          ║
                    ║  • queue_free()                    ║
                    ╚════════════════════════════════════╝
```

## Bomb Arc Trajectory

```
horizontal_position = direction * throw_speed * time_alive
vertical_offset = 4 * throw_height * progress * (1 - progress)
final_position = start + horizontal + Vector2(0, -vertical_offset)

Where:
- progress = time_alive / total_travel_time
- total_travel_time = distance_to_target / throw_speed
- throw_height = 80 pixels (peak of arc)
```

## Explosion Trigger Conditions

1. **Impact:** If bomb collides with player body → explode immediately
2. **Fuse End:** If fuse timer (1.5s) expires → explode at current position

## Deviations from Plan

None - implementation matches plan exactly.

## Integration Points

| From | To | Via |
|------|----|-----|
| gnome.tscn | world/rooftop_spawners | Spawner places gnome at fixed position |
| gnome_telegraph.gd | gnome_throw.gd | Telegraph completes → triggers Throw state |
| gnome_throw.gd | gnome_bomb.tscn | Instantiates bomb at throw position |
| gnome_bomb.gd | Events | Emits bomb_exploded for audio/effects |

## Next Steps

- Phase 37: Rooftop Spawners - Create spawner system for placing gnomes on rooftops
- Phase 38: Rooftop Encounters - Design combat encounters with pigeon flocks and gnomes
- Phase 39: Raccoon King Setup - Prepare boss arena

## Verification Checklist

- [x] Gnome stationary (no movement toward player)
- [x] Orange pulsing "!" telegraph visible during GnomeTelegraph state
- [x] Telegraph duration: 0.8 seconds before throw
- [x] Bomb arcs from gnome to player position
- [x] Bomb explodes on impact OR fuse end (1.5s)
- [x] AOE explosion damages player in 64px radius
- [x] Cooldown state prevents rapid attack cycling
- [x] Hurt state interrupts telegraph/throw properly
- [x] Death state fades sprite and removes from scene
- [x] Signals properly integrated with Events autoload
- [x] State machine cycles correctly through all states
