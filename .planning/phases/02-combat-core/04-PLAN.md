# Plan 04: Wire Combat to Player

## Metadata
```yaml
phase: 02-combat-core
plan: 04
wave: 3
depends_on: ["03"]
files_modified: 2
autonomous: true
must_haves:
  truths:
    - "Player has hitbox for attacks"
    - "Player has hurtbox for receiving damage"
    - "Player has health component"
    - "All combat components wired together"
  artifacts:
    - path: "characters/player/player.tscn"
      provides: "Updated player scene"
    - path: "characters/player/player.gd"
      provides: "Updated player script"
  key_links:
    - from: "player.gd"
      to: "hurtbox.hurt"
      via: "signal connection to trigger Hurt state"
    - from: "player.gd"
      to: "health_component.died"
      via: "signal connection for death"
```

## Objective
Integrate all combat components into player scene.

## Tasks

<task type="auto">
  <name>Task 1: Update player scene with combat nodes</name>
  <files>characters/player/player.tscn</files>
  <action>
    Add to player.tscn:
    - HealthComponent (instance)
    - Hurtbox (instance, layer 4, mask 7)
      - CollisionShape2D matching player size
    - Hitbox (instance, layer 6, mask 5)
      - CollisionShape2D positioned in front of player
      - Disabled by default
    - Attack state node under StateMachine
    - Hurt state node under StateMachine
  </action>
  <verify>Scene has all combat nodes</verify>
  <done>Player scene with full combat setup</done>
</task>

<task type="auto">
  <name>Task 2: Wire combat signals in player script</name>
  <files>characters/player/player.gd</files>
  <action>
    Update player.gd:
    - @onready var hitbox, hurtbox, health references
    - In _ready(): Connect hurtbox.hurt to _on_hurt
    - In _ready(): Connect health.died to _on_died
    - func _on_hurt(hitbox): Take damage, transition to Hurt
    - func _on_died(): Transition to Death (or handle game over)
    - func set_hitbox_direction(): Position hitbox based on facing
  </action>
  <verify>Taking damage triggers hurt state</verify>
  <done>Combat fully wired</done>
</task>

## Success Criteria
- [ ] Player scene has Hitbox, Hurtbox, HealthComponent
- [ ] Attack state enables hitbox
- [ ] Getting hit triggers Hurt state
- [ ] Health decreases on damage
