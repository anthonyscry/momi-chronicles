# Feature Enemies Implementation Plan

## Goal
Add a new stationary turret enemy for the Rooftops zone (Garden Gnome) that uses the existing EnemyBase + StateMachine patterns, throws explosive bombs with a fuse, and integrates with Events and rooftop spawners.

## Scope
In scope:
- New enemy script and scene (Garden Gnome)
- New state scripts for idle, telegraph, throw, cooldown, hurt, death
- New projectile scene and script for bomb arc + AOE explosion
- Events signals for gnome interactions
- Spawner integration in rooftop zone (discover actual spawner file)
- Sprite assets and SpriteFrames hookup
- Manual verification steps and minimal test harness updates

Out of scope:
- New combat systems or rework of EnemyBase
- New autoloads or global architecture changes
- Large art pipeline changes

## Acceptance Criteria
- [ ] Gnome is stationary (no movement states)
- [ ] Telegraph shows orange pulsing "!" for 0.8s before throw
- [ ] Bomb arcs to the target position and rotates in flight
- [ ] Bomb explodes on impact or fuse timeout (1.5s)
- [ ] AOE explosion damages player within 64px radius
- [ ] Cooldown prevents rapid attack loops
- [ ] Hurt interrupts telegraph/throw and hides telegraph sprite
- [ ] Death fades out and removes enemy from scene
- [ ] Events signals for gnome actions exist and are emitted
- [ ] Rooftop spawner can place gnomes at fixed positions
- [ ] No console errors when running rooftop encounter

## Architecture Diagram (ASCII)

Player
  ^
  | (takes damage)
Hurtbox <- Hitbox (projectile)
  ^                 |
  |                 v
EnemyBase <---- GnomeBomb (Area2D)
  |                      |
  v                      v
StateMachine -> GnomeIdle/Telegraph/Throw/Cooldown/Hurt/Death
  |
  v
Events (gnome_threw_bomb, gnome_bomb_exploded, gnome_died)

## Implementation Steps (file by file)

1) Enemy script
- Create `characters/enemies/gnome.gd`
  - Extend EnemyBase
  - Define stats and constants (range, damage, cooldown, fuse)
  - Override _update_animation to map gnome states
  - Add telegraph helper methods (show/hide/pulse)

2) Enemy scene
- Create `characters/enemies/gnome.tscn`
  - CharacterBody2D root with AnimatedSprite2D
  - CollisionShape2D for body
  - DetectionArea + shape (200px radius)
  - Hurtbox + Hitbox nodes
  - TelegraphSprite node with Sprite2D child
  - StateMachine with gnome state nodes

3) States
- Create state scripts in `characters/enemies/states/`
  - gnome_idle.gd: scan detection area every 0.5s
  - gnome_telegraph.gd: show orange pulsing "!" for 0.8s
  - gnome_throw.gd: spawn bomb on animation frame 2
  - gnome_cooldown.gd: wait 2.0s, re-check range
  - gnome_hurt.gd: interrupt actions, short pause
  - gnome_death.gd: fade out and queue_free

4) Projectile
- Create `characters/enemies/projectiles/gnome_bomb.gd`
  - Arc trajectory using time-based parabola
  - Fuse timer -> explosion
  - Impact detection -> explosion
  - AOE damage within radius
- Create `characters/enemies/projectiles/gnome_bomb.tscn`
  - Area2D root, collision shape, sprite, hitbox

5) Events
- Update `autoloads/events.gd`
  - Add gnome signals: threw_bomb, bomb_exploded, died, hurt
  - Ensure signatures match usage in states/projectile

6) Spawner integration
- Discover actual rooftop spawn file (search for existing spawners)
- Add gnome spawn hook (fixed position) with Events.gnome_spawned if needed
- Ensure gnome scene is loadable from rooftop zone

7) Art and SpriteFrames
- Add sprite sheets under `art/generated/enemies/`
  - gnome_idle, gnome_telegraph, gnome_throw, gnome_hurt, gnome_death
  - gnome_bomb, gnome_explosion
- Configure SpriteFrames in `gnome.tscn` for animations

8) Tests and verification
- Update or add a test scene under `tests/` to spawn gnome
- Manual checklist: run rooftop area and verify all behaviors

## Task List and Dependencies
1. Discovery: locate rooftop spawner integration point
2. Create gnome script and constants
3. Create gnome scene with nodes
4. Implement gnome states
5. Implement gnome bomb projectile
6. Add Events signals for gnome
7. Integrate gnome into rooftop spawner/scene
8. Add sprite sheets and wire SpriteFrames
9. Add test scene and manual verification notes

Dependencies:
- 2 depends on 1 (confirm target integration)
- 3 depends on 2
- 4 depends on 2 and 3
- 5 depends on 2
- 6 depends on 2 and 5
- 7 depends on 3 and 6
- 8 depends on 3
- 9 depends on 7 and 8

## Test Matrix (cases x layers)

| Case | Unit | Integration | Manual |
|------|------|-------------|--------|
| Telegraph duration 0.8s | - | State transition timing | Visual check
| Bomb arc trajectory | - | Projectile path | Visual check
| Fuse timeout explosion | - | Bomb timer | Visual check
| Impact explosion | - | Bomb collision | Visual check
| AOE damage radius | - | Damage + distance | Manual verify
| Cooldown gating | - | State loop timing | Manual verify
| Hurt interrupts | - | State transition | Manual verify
| Death fade | - | Animation + queue_free | Manual verify
| Events emitted | - | Signals in Events | Manual check logs

## Rollout Plan
- Add gnome spawns to a single rooftop encounter first
- Verify behaviors and performance in editor
- Expand spawn usage after validation

## Rollback Plan
- Remove gnome spawn references from rooftop scenes/spawner
- Keep gnome files but disable usage until revisited

## Open Questions
- Where is the current rooftop spawner entry point (file not found in repo)?
- Is DamageEvent defined elsewhere or required for gnome bomb damage?
- Do we need a dedicated VFX scene for explosion or reuse existing effects?

## Progress Log
- 2026-02-01: EN-1 discovery pass found no rooftop zone or spawner scripts under `world/`; integration deferred until Phase 37 or until rooftop zone files land.
- 2026-02-01: EN-2/EN-3 completed - `characters/enemies/gnome.gd` + `characters/enemies/gnome.tscn` aligned to EnemyBase + StateMachine patterns with SpriteFrames.
- 2026-02-01: EN-4 completed - gnome idle/telegraph/throw/cooldown/hurt/death states implemented and wired.
- 2026-02-01: EN-5 completed - gnome bomb projectile uses Hitbox/Hurtbox pipeline (no DamageEvent dependency) and gnome explosion sprite.
- 2026-02-01: EN-6 completed - gnome events signals present and emitted.
- 2026-02-01: EN-7 blocked - rooftop spawner integration deferred pending rooftop zone/spawner files.
- 2026-02-01: EN-8 completed - gnome sprite sheets referenced in SpriteFrames for gnome + bomb.
- 2026-02-01: EN-9 completed - added `tests/test_gnome.tscn` and updated test docs (executed despite EN-7 block; manual testing uses test scene).
