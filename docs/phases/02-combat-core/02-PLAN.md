# Plan 02: Health Component

## Metadata
```yaml
phase: 02-combat-core
plan: 02
wave: 1
depends_on: []
files_modified: 2
autonomous: true
must_haves:
  truths:
    - "Health tracks current and max HP"
    - "Taking damage reduces health"
    - "Death signal emitted at 0 HP"
  artifacts:
    - path: "components/health/health_component.gd"
      provides: "Health management"
      min_lines: 40
    - path: "components/health/health_component.tscn"
      provides: "Health scene"
  key_links:
    - from: "health_component.gd"
      to: "Events.player_health_changed"
      via: "signal emission"
```

## Objective
Create reusable health component for damage tracking.

## Tasks

<task type="auto">
  <name>Task 1: Create Health component</name>
  <files>components/health/health_component.gd, components/health/health_component.tscn</files>
  <action>
    Create health_component.gd:
    - extends Node, class_name HealthComponent
    - signal health_changed(current, max_health)
    - signal died
    - signal damage_taken(amount)
    - @export var max_health: int = 100
    - var current_health: int
    - func _ready(): current_health = max_health
    - func take_damage(amount): Reduce health, emit signals, check death
    - func heal(amount): Increase health up to max
    - func is_dead() -> bool
    
    Create health_component.tscn:
    - HealthComponent (Node) with script
  </action>
  <verify>Health decreases on damage, dies at 0</verify>
  <done>Health component with full lifecycle</done>
</task>

## Success Criteria
- [ ] Health starts at max_health
- [ ] take_damage reduces current_health
- [ ] died signal emits at 0 HP
- [ ] heal increases health (capped at max)
