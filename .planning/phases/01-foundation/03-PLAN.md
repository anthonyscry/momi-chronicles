# Plan 03: Player Foundation

## Metadata
```yaml
phase: 01-foundation
plan: 03
wave: 2
depends_on: ["01", "02"]
files_modified: 4
autonomous: true
must_haves:
  truths:
    - "Player scene can be instanced in zones"
    - "Player has physics collision"
    - "Player has sprite visible"
    - "Player has state machine ready for states"
  artifacts:
    - path: "characters/player/player.gd"
      provides: "Player script with movement helpers"
      min_lines: 40
    - path: "characters/player/player.tscn"
      provides: "Player scene with all nodes"
      min_lines: 30
    - path: "autoloads/events.gd"
      provides: "Global signal bus"
      min_lines: 20
    - path: "autoloads/game_manager.gd"
      provides: "Game state management"
      min_lines: 30
  key_links:
    - from: "player.tscn"
      to: "player.gd"
      via: "script attachment"
    - from: "player.tscn"
      to: "state_machine.tscn"
      via: "scene instance"
```

## Objective
Create player scene with script, sprite, collision, and state machine ready for states.

## Tasks

<task type="auto">
  <name>Task 1: Create Events autoload</name>
  <files>autoloads/events.gd</files>
  <action>
    Create events.gd with:
    - extends Node
    - Player signals: player_damaged(amount), player_died, player_healed(amount)
    - Combat signals: enemy_damaged(enemy, amount), enemy_defeated(enemy)
    - Zone signals: zone_entered(zone_name), zone_exited(zone_name)
    - Game signals: game_paused, game_resumed
  </action>
  <verify>File has all signal declarations</verify>
  <done>Events autoload with categorized signals</done>
</task>

<task type="auto">
  <name>Task 2: Create GameManager autoload</name>
  <files>autoloads/game_manager.gd</files>
  <action>
    Create game_manager.gd with:
    - extends Node
    - var is_paused: bool = false
    - var current_zone: String = ""
    - func pause_game(): Set pause, emit Events.game_paused
    - func resume_game(): Unset pause, emit Events.game_resumed
    - func _ready(): Connect to pause input or process mode
  </action>
  <verify>File has pause/resume functionality</verify>
  <done>GameManager with pause state management</done>
</task>

<task type="auto">
  <name>Task 3: Create Player script</name>
  <files>characters/player/player.gd</files>
  <action>
    Create player.gd with:
    - extends CharacterBody2D
    - class_name Player
    - Constants: WALK_SPEED = 80.0, RUN_SPEED = 140.0
    - @onready var sprite: Sprite2D
    - @onready var animation_player: AnimationPlayer
    - @onready var state_machine: StateMachine
    - @onready var camera: Camera2D
    - var facing_direction: String = "down"
    - func get_input_direction() -> Vector2
    - func is_running() -> bool
    - func update_facing(direction: Vector2)
    - func set_camera_limits(rect: Rect2)
  </action>
  <verify>File has movement constants and helper functions</verify>
  <done>Player script with movement infrastructure</done>
</task>

<task type="auto">
  <name>Task 4: Create Player scene</name>
  <files>characters/player/player.tscn</files>
  <action>
    Create player.tscn with structure:
    - Player (CharacterBody2D with player.gd)
      - Sprite2D (placeholder texture or empty)
      - CollisionShape2D (CapsuleShape2D, ~8x12 pixels)
      - AnimationPlayer (empty, will add animations later)
      - Camera2D (smoothing enabled, speed 5.0)
      - StateMachine (instance of state_machine.tscn)
    Set appropriate node references in script
  </action>
  <verify>Scene opens without errors, all nodes present</verify>
  <done>Player.tscn with complete node hierarchy</done>
</task>

## Success Criteria
- [ ] Events autoload accessible globally
- [ ] GameManager autoload accessible globally
- [ ] Player scene instances without errors
- [ ] Player has visible collision shape in editor
