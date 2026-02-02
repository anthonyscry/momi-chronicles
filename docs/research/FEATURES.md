# Feature Implementation Research

## State Machine System

### Design Choice: Node-Based States
Each state is a Node with lifecycle methods:
- `enter()` - Called when entering state
- `exit()` - Called when leaving state  
- `update(delta)` - Called every _process
- `physics_update(delta)` - Called every _physics_process
- `handle_input(event)` - Optional input handling

### State Machine Node
- Holds reference to current state
- Manages transitions via `transition_to(state_name)`
- Emits signal on state change for debugging

### Why This Pattern
- States are visible in scene tree (debugging)
- Easy to add/remove states
- States can have child nodes (timers, etc.)
- Clear separation of concerns

## Movement System

### 8-Directional Input
```gdscript
func get_input_direction() -> Vector2:
    return Input.get_vector("move_left", "move_right", "move_up", "move_down")
```

### Speed Constants
- Walk speed: ~80 pixels/sec
- Run speed: ~140 pixels/sec
- Acceleration: Instant (arcade feel) or smoothed

### Facing Direction
Track last non-zero movement direction for:
- Sprite flipping
- Attack direction
- Animation selection

## Combat System

### Hitbox/Hurtbox Pattern
- **Hitbox**: Deals damage (player attack, enemy attack)
- **Hurtbox**: Receives damage (player body, enemy body)

Both are Area2D with specific collision layers:
- Layer 1: Player Hurtbox
- Layer 2: Enemy Hurtbox
- Layer 3: Player Hitbox
- Layer 4: Enemy Hitbox

Hitbox masks: What it can hit
Hurtbox layers: What it is

### Health Component
```gdscript
signal health_changed(current, max)
signal died

var max_health: int = 100
var current_health: int = max_health

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health, max_health)
    if current_health <= 0:
        died.emit()
```

### Invincibility Frames
- Timer-based (0.5-1.0 seconds)
- Visual feedback (sprite flashing)
- Skip damage during i-frames

## Animation System

### Sprite Organization
4-directional sprites:
- Down (front-facing, default)
- Up (back-facing)
- Left (side)
- Right (side, can flip left)

### Animation Naming Convention
- `idle_down`, `idle_up`, `idle_side`
- `walk_down`, `walk_up`, `walk_side`
- `run_down`, `run_up`, `run_side`
- `attack_down`, `attack_up`, `attack_side`

### Animation State Sync
State machine drives animations:
```gdscript
# In IdleState.enter()
player.animation_player.play("idle_" + player.facing_direction)
```

## Camera System

### Godot 4.x Camera2D
- `position_smoothing_enabled = true`
- `position_smoothing_speed = 5.0`
- Limit properties for zone boundaries

### Zone Limits
Camera limits set when entering zone:
```gdscript
func set_camera_limits(rect: Rect2) -> void:
    camera.limit_left = rect.position.x
    camera.limit_top = rect.position.y
    camera.limit_right = rect.end.x
    camera.limit_bottom = rect.end.y
```
