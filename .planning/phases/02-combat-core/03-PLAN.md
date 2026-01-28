# Plan 03: Player Combat States

## Metadata
```yaml
phase: 02-combat-core
plan: 03
wave: 2
depends_on: ["01", "02"]
files_modified: 4
autonomous: true
must_haves:
  truths:
    - "Player can attack with action button"
    - "Attack has hitbox that deals damage"
    - "Player reacts to taking damage"
  artifacts:
    - path: "characters/player/states/player_attack.gd"
      provides: "Attack state"
      min_lines: 35
    - path: "characters/player/states/player_hurt.gd"
      provides: "Hurt state"
      min_lines: 25
  key_links:
    - from: "player_attack.gd"
      to: "hitbox"
      via: "enable/disable monitoring"
    - from: "player_hurt.gd"
      to: "hurtbox.hurt signal"
      via: "signal connection"
```

## Objective
Add Attack and Hurt states to player.

## Tasks

<task type="auto">
  <name>Task 1: Create Attack state</name>
  <files>characters/player/states/player_attack.gd</files>
  <action>
    Create player_attack.gd:
    - extends State, class_name PlayerAttack
    - var attack_duration: float = 0.3
    - var attack_timer: float = 0.0
    - func enter(): Stop velocity, enable hitbox, reset timer
    - func exit(): Disable hitbox, clear hit targets
    - func physics_update(delta): Count timer, transition to Idle when done
    - Handle hitbox enabling based on facing direction
  </action>
  <verify>Attack state enables hitbox, returns to idle</verify>
  <done>Attack state with timed hitbox</done>
</task>

<task type="auto">
  <name>Task 2: Create Hurt state</name>
  <files>characters/player/states/player_hurt.gd</files>
  <action>
    Create player_hurt.gd:
    - extends State, class_name PlayerHurt
    - var hurt_duration: float = 0.3
    - var hurt_timer: float = 0.0
    - func enter(): Stop velocity, start invincibility, flash sprite
    - func exit(): Stop flash
    - func physics_update(delta): Count timer, return to Idle
  </action>
  <verify>Hurt state plays, returns to idle</verify>
  <done>Hurt state with invincibility</done>
</task>

<task type="auto">
  <name>Task 3: Add attack input to movement states</name>
  <files>characters/player/states/player_idle.gd, characters/player/states/player_walk.gd, characters/player/states/player_run.gd</files>
  <action>
    Update all movement states to check for attack input:
    - In physics_update or handle_input
    - If Input.is_action_just_pressed("attack"): transition_to("Attack")
  </action>
  <verify>Player can attack from idle, walk, or run</verify>
  <done>Attack accessible from all movement states</done>
</task>

## Success Criteria
- [ ] Press attack button triggers Attack state
- [ ] Attack state lasts ~0.3 seconds
- [ ] Hurt state triggers on damage
- [ ] Player flashes during hurt
