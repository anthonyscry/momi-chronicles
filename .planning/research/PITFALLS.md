# Common Pitfalls & Solutions

## Godot 4.x Specific

### 1. Physics vs Process
**Pitfall**: Using `_process()` for movement
**Solution**: Always use `_physics_process()` for CharacterBody2D movement
```gdscript
# Bad
func _process(delta):
    velocity = direction * speed
    move_and_slide()

# Good
func _physics_process(delta):
    velocity = direction * speed
    move_and_slide()
```

### 2. Texture Filtering
**Pitfall**: Blurry pixel art
**Solution**: Set in Project Settings AND on individual textures
- Project Settings > Rendering > Textures > Default Texture Filter = Nearest
- For imported textures: Import tab > Filter = Nearest

### 3. Integer Scaling
**Pitfall**: Pixel distortion at non-integer scales
**Solution**: Use viewport stretch mode with integer scaling
```ini
window/stretch/mode="viewport"
window/stretch/aspect="keep"
```

### 4. Signal Connections in Editor
**Pitfall**: Signals connected in editor break when scenes are instanced
**Solution**: Connect signals in `_ready()` for dynamic scenes
```gdscript
func _ready():
    health_component.died.connect(_on_health_component_died)
```

## State Machine Pitfalls

### 1. State Initialization Order
**Pitfall**: States try to access player before player is ready
**Solution**: Initialize state machine in player's `_ready()`, pass player reference
```gdscript
# Player._ready()
func _ready():
    state_machine.init(self)

# StateMachine.init()
func init(player: CharacterBody2D) -> void:
    for state in get_children():
        state.player = player
        state.state_machine = self
```

### 2. Stuck States
**Pitfall**: Animation finishes but state doesn't transition
**Solution**: Use animation_finished signal or timers for timed states
```gdscript
# AttackState
func enter() -> void:
    player.animation_player.play("attack")
    player.animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
    player.animation_player.animation_finished.disconnect(_on_animation_finished)
    state_machine.transition_to("idle")
```

### 3. Input During Transitions
**Pitfall**: Input accepted during state transitions causes bugs
**Solution**: Clear input state on transitions, use state's `can_handle_input`
```gdscript
func transition_to(state_name: String) -> void:
    if state_name == current_state.name:
        return
    current_state.exit()
    current_state = states[state_name]
    current_state.enter()
```

## Combat Pitfalls

### 1. Multiple Damage Triggers
**Pitfall**: Hitbox triggers damage multiple times per attack
**Solution**: Disable hitbox after first hit, or track hit targets
```gdscript
var hit_targets: Array = []

func _on_hitbox_area_entered(area: Area2D) -> void:
    if area.owner in hit_targets:
        return
    hit_targets.append(area.owner)
    # Deal damage

func reset_hitbox() -> void:
    hit_targets.clear()
```

### 2. Self-Damage
**Pitfall**: Player's hitbox hits player's hurtbox
**Solution**: Proper collision layer setup - hitbox doesn't mask own hurtbox layer

### 3. I-Frame Bypass
**Pitfall**: Rapid attacks bypass invincibility
**Solution**: Check i-frame state in hurtbox, not in attacker
```gdscript
# HurtboxComponent
func _on_area_entered(hitbox: Area2D) -> void:
    if is_invincible:
        return
    take_damage(hitbox.damage)
```

## Performance Pitfalls

### 1. String Comparisons in _process
**Pitfall**: Comparing state names as strings every frame
**Solution**: Use enums or direct state references
```gdscript
# Instead of
if current_state.name == "idle":

# Use
if current_state == idle_state:
```

### 2. Creating Objects in _process
**Pitfall**: Instantiating scenes every frame
**Solution**: Pool objects or instantiate in advance

### 3. Unnecessary Signal Emissions
**Pitfall**: Emitting signals every frame
**Solution**: Only emit on actual changes
```gdscript
func set_health(value: int) -> void:
    if value == current_health:
        return
    current_health = value
    health_changed.emit(current_health, max_health)
```

## Animation Pitfalls

### 1. Animation Not Found
**Pitfall**: Wrong animation name causes silent failure
**Solution**: Check animation exists, use constants
```gdscript
const ANIM_IDLE_DOWN = "idle_down"

if animation_player.has_animation(ANIM_IDLE_DOWN):
    animation_player.play(ANIM_IDLE_DOWN)
```

### 2. Flip vs Separate Sprites
**Pitfall**: Inconsistent sprite flipping logic
**Solution**: Use `flip_h` for left/right, separate sprites for up/down
```gdscript
func update_facing(direction: Vector2) -> void:
    if direction.x != 0:
        sprite.flip_h = direction.x < 0
```

### 3. Animation Speed Reset
**Pitfall**: Animation speed not reset after slow-mo effects
**Solution**: Store and restore original speed, or use animation speed property
