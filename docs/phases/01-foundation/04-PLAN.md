# Plan 04: Player States

## Metadata
```yaml
phase: 01-foundation
plan: 04
wave: 3
depends_on: ["03"]
files_modified: 4
autonomous: true
must_haves:
  truths:
    - "Player stands still in Idle state"
    - "Player moves at walk speed in Walk state"
    - "Player moves faster in Run state"
    - "States transition correctly based on input"
  artifacts:
    - path: "characters/player/states/player_idle.gd"
      provides: "Idle state"
      min_lines: 20
    - path: "characters/player/states/player_walk.gd"
      provides: "Walk state"
      min_lines: 25
    - path: "characters/player/states/player_run.gd"
      provides: "Run state"
      min_lines: 25
  key_links:
    - from: "player_idle.gd"
      to: "state_machine"
      via: "transition_to on input"
    - from: "player_walk.gd"
      to: "player_run.gd"
      via: "transition when shift held"
```

## Objective
Create Idle, Walk, and Run states for player movement.

## Tasks

<task type="auto">
  <name>Task 1: Create Idle state</name>
  <files>characters/player/states/player_idle.gd</files>
  <action>
    Create player_idle.gd:
    - extends State
    - class_name PlayerIdle
    - func enter(): Stop velocity, play idle animation (when available)
    - func physics_update(delta):
      - Get input direction
      - If direction != Vector2.ZERO:
        - If running: transition_to("Run")
        - Else: transition_to("Walk")
  </action>
  <verify>State transitions to Walk/Run when input detected</verify>
  <done>Idle state with movement detection</done>
</task>

<task type="auto">
  <name>Task 2: Create Walk state</name>
  <files>characters/player/states/player_walk.gd</files>
  <action>
    Create player_walk.gd:
    - extends State
    - class_name PlayerWalk
    - func enter(): Play walk animation (when available)
    - func physics_update(delta):
      - Get input direction
      - If direction == Vector2.ZERO: transition_to("Idle")
      - Elif player.is_running(): transition_to("Run")
      - Else:
        - player.velocity = direction * player.WALK_SPEED
        - player.update_facing(direction)
        - player.move_and_slide()
  </action>
  <verify>Player moves at WALK_SPEED, transitions on input change</verify>
  <done>Walk state with movement and transitions</done>
</task>

<task type="auto">
  <name>Task 3: Create Run state</name>
  <files>characters/player/states/player_run.gd</files>
  <action>
    Create player_run.gd:
    - extends State
    - class_name PlayerRun
    - func enter(): Play run animation (when available)
    - func physics_update(delta):
      - Get input direction
      - If direction == Vector2.ZERO: transition_to("Idle")
      - Elif not player.is_running(): transition_to("Walk")
      - Else:
        - player.velocity = direction * player.RUN_SPEED
        - player.update_facing(direction)
        - player.move_and_slide()
  </action>
  <verify>Player moves at RUN_SPEED when shift held</verify>
  <done>Run state with faster movement</done>
</task>

<task type="auto">
  <name>Task 4: Add states to Player scene</name>
  <files>characters/player/player.tscn</files>
  <action>
    Update player.tscn:
    - Add Idle node (Node) as child of StateMachine, attach player_idle.gd
    - Add Walk node (Node) as child of StateMachine, attach player_walk.gd
    - Add Run node (Node) as child of StateMachine, attach player_run.gd
    - Set StateMachine.initial_state to Idle node
  </action>
  <verify>Scene tree shows StateMachine with 3 state children</verify>
  <done>Player scene with movement states configured</done>
</task>

## Success Criteria
- [ ] Player starts in Idle state
- [ ] WASD moves player at walk speed
- [ ] Shift + WASD moves player at run speed
- [ ] Releasing keys returns to Idle
