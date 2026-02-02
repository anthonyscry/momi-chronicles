# Architecture Decisions

## Core Principles

### 1. Composition Over Inheritance
Instead of deep inheritance hierarchies:
```
Entity
└── Character
    ├── Player
    └── Enemy
        ├── Raccoon
        └── Crow
```

Use composition:
```
Player (CharacterBody2D)
├── HealthComponent
├── HurtboxComponent
├── StateMachine
└── [player-specific nodes]

Enemy (CharacterBody2D)
├── HealthComponent
├── HurtboxComponent
├── StateMachine
└── [enemy-specific nodes]
```

### 2. Signals for Decoupling
Components don't know about each other:
```gdscript
# HealthComponent emits
signal died

# Parent connects
health_component.died.connect(_on_died)
```

### 3. Events Bus for Cross-System Communication
Global events for things that multiple systems care about:
```gdscript
# Events autoload
signal player_damaged(amount)
signal enemy_defeated(enemy)
signal zone_entered(zone_name)
```

## Scene Structure

### Player Scene
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D (physics)
├── AnimationPlayer
├── Camera2D
└── StateMachine (Node)
    ├── Idle (Node - state.gd)
    ├── Walk (Node - state.gd)
    ├── Run (Node - state.gd)
    ├── Attack (Node - state.gd)
    ├── Hurt (Node - state.gd)
    ├── Dodge (Node - state.gd)
    └── Death (Node - state.gd)
```

### Enemy Scene
```
Enemy (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D (physics)
├── AnimationPlayer
├── HurtboxComponent (Area2D)
├── HealthComponent (Node)
├── DetectionArea (Area2D) - for player detection
└── StateMachine
    ├── Idle
    ├── Patrol
    ├── Chase
    ├── Attack
    ├── Hurt
    └── Death
```

### Zone Scene
```
Zone (Node2D)
├── TileMap (ground, walls)
├── Entities (Node2D)
│   ├── Player (instance)
│   └── Enemies (Node2D)
│       ├── Raccoon1
│       └── Raccoon2
├── Triggers (Node2D)
│   └── ZoneExit (Area2D)
└── CameraLimits (Node2D) - marker for camera bounds
```

## Collision Layers

| Layer | Name | Used By |
|-------|------|---------|
| 1 | World | Walls, obstacles |
| 2 | Player | Player CharacterBody2D |
| 3 | Enemy | Enemy CharacterBody2D |
| 4 | PlayerHurtbox | Player's hurtbox |
| 5 | EnemyHurtbox | Enemy hurtboxes |
| 6 | PlayerHitbox | Player attack hitboxes |
| 7 | EnemyHitbox | Enemy attack hitboxes |
| 8 | Trigger | Zone transitions, pickups |

## Input Actions

| Action | Default Key | Purpose |
|--------|-------------|---------|
| move_up | W, Up | Movement |
| move_down | S, Down | Movement |
| move_left | A, Left | Movement |
| move_right | D, Right | Movement |
| run | Shift | Hold to run |
| attack | Space, Z | Basic attack |
| dodge | X, LShift | Dodge roll |
| interact | E, Enter | Interact with objects |
| pause | Escape | Pause menu |

## Data Flow

### Damage Flow
1. Player attack state activates hitbox
2. Hitbox enters enemy hurtbox
3. Hurtbox calls `take_damage()` on enemy's HealthComponent
4. HealthComponent emits `health_changed`
5. Enemy state machine transitions to Hurt state
6. If health <= 0, HealthComponent emits `died`
7. Enemy transitions to Death state
8. Events.enemy_defeated emitted for scoring/UI

### State Transition Flow
1. Current state's `update()` detects transition condition
2. State calls `state_machine.transition_to("new_state")`
3. State machine calls `current_state.exit()`
4. State machine sets `current_state = new_state`
5. State machine calls `new_state.enter()`
6. State machine emits `state_changed` signal
