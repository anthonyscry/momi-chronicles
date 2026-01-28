# Plan 01: Hitbox/Hurtbox Components

## Metadata
```yaml
phase: 02-combat-core
plan: 01
wave: 1
depends_on: []
files_modified: 4
autonomous: true
must_haves:
  truths:
    - "Hitbox can detect and damage hurtboxes"
    - "Hurtbox receives damage and notifies owner"
    - "Components work via collision layers"
  artifacts:
    - path: "components/hitbox/hitbox.gd"
      provides: "Damage-dealing component"
      min_lines: 30
    - path: "components/hitbox/hitbox.tscn"
      provides: "Hitbox scene"
    - path: "components/hurtbox/hurtbox.gd"
      provides: "Damage-receiving component"
      min_lines: 30
    - path: "components/hurtbox/hurtbox.tscn"
      provides: "Hurtbox scene"
  key_links:
    - from: "hitbox.gd"
      to: "hurtbox.gd"
      via: "area_entered signal"
```

## Objective
Create reusable hitbox and hurtbox components for combat detection.

## Tasks

<task type="auto">
  <name>Task 1: Create Hitbox component</name>
  <files>components/hitbox/hitbox.gd, components/hitbox/hitbox.tscn</files>
  <action>
    Create hitbox.gd:
    - extends Area2D, class_name Hitbox
    - @export var damage: int = 10
    - signal hit_landed(hurtbox)
    - Disabled by default (monitoring = false)
    - On area_entered, if area is Hurtbox, call hurtbox.take_hit(self)
    
    Create hitbox.tscn:
    - Hitbox (Area2D) with script
    - CollisionShape2D (disabled by default)
    - Layer 6 (PlayerHitbox), mask 5 (EnemyHurtbox)
  </action>
  <verify>Component exists with damage property and signal</verify>
  <done>Hitbox component ready for use</done>
</task>

<task type="auto">
  <name>Task 2: Create Hurtbox component</name>
  <files>components/hurtbox/hurtbox.gd, components/hurtbox/hurtbox.tscn</files>
  <action>
    Create hurtbox.gd:
    - extends Area2D, class_name Hurtbox
    - signal hurt(hitbox)
    - var is_invincible: bool = false
    - func take_hit(hitbox: Hitbox): If not invincible, emit hurt(hitbox)
    
    Create hurtbox.tscn:
    - Hurtbox (Area2D) with script
    - CollisionShape2D
    - Layer 4 (PlayerHurtbox), mask 7 (EnemyHitbox)
  </action>
  <verify>Component receives hits and emits signal</verify>
  <done>Hurtbox component ready for use</done>
</task>

## Success Criteria
- [ ] Hitbox can be enabled/disabled
- [ ] Hurtbox emits signal when hit
- [ ] Collision layers prevent self-damage
