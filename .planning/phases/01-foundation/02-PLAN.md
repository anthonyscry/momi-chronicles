# Plan 02: State Machine System

## Metadata
```yaml
phase: 01-foundation
plan: 02
wave: 1
depends_on: []
files_modified: 3
autonomous: true
must_haves:
  truths:
    - "State base class provides lifecycle methods"
    - "State machine manages state transitions"
    - "States are Node children visible in scene tree"
  artifacts:
    - path: "components/state_machine/state.gd"
      provides: "Base State class"
      min_lines: 25
    - path: "components/state_machine/state_machine.gd"
      provides: "StateMachine controller"
      min_lines: 40
    - path: "components/state_machine/state_machine.tscn"
      provides: "Reusable scene"
      min_lines: 5
  key_links:
    - from: "state_machine.gd"
      to: "state.gd"
      via: "iterates child State nodes"
```

## Objective
Create reusable state machine system with base State class and StateMachine controller.

## Tasks

<task type="auto">
  <name>Task 1: Create State base class</name>
  <files>components/state_machine/state.gd</files>
  <action>
    Create state.gd with:
    - class_name State extends Node
    - var player: CharacterBody2D reference
    - var state_machine: StateMachine reference
    - func enter() -> void: pass (virtual)
    - func exit() -> void: pass (virtual)
    - func update(delta: float) -> void: pass (virtual)
    - func physics_update(delta: float) -> void: pass (virtual)
    - func handle_input(event: InputEvent) -> void: pass (virtual)
  </action>
  <verify>File exists with all methods</verify>
  <done>State class with 5 lifecycle methods</done>
</task>

<task type="auto">
  <name>Task 2: Create StateMachine controller</name>
  <files>components/state_machine/state_machine.gd</files>
  <action>
    Create state_machine.gd with:
    - class_name StateMachine extends Node
    - signal state_changed(old_state, new_state)
    - @export var initial_state: State
    - var current_state: State
    - var states: Dictionary = {}
    - func _ready(): Initialize states dict from children, set initial state
    - func init(player: CharacterBody2D): Pass player ref to all states
    - func _process(delta): Call current_state.update(delta)
    - func _physics_process(delta): Call current_state.physics_update(delta)
    - func _unhandled_input(event): Call current_state.handle_input(event)
    - func transition_to(state_name: String): Exit current, enter new, emit signal
  </action>
  <verify>File exists with init, transition_to, and lifecycle forwarding</verify>
  <done>StateMachine with state management and signal</done>
</task>

<task type="auto">
  <name>Task 3: Create StateMachine scene</name>
  <files>components/state_machine/state_machine.tscn</files>
  <action>
    Create state_machine.tscn:
    - Root node: StateMachine (Node with state_machine.gd attached)
    - This scene will be instanced and states added as children
  </action>
  <verify>Scene file exists and references state_machine.gd</verify>
  <done>Reusable StateMachine.tscn scene</done>
</task>

## Success Criteria
- [ ] state.gd has class_name State
- [ ] state_machine.gd has class_name StateMachine
- [ ] StateMachine can transition between states
- [ ] state_changed signal emits on transition
