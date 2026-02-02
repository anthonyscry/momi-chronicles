# Roof Rat Enemy Implementation Research

## Overview

Research findings for implementing a **Roof Rat** enemy - a wall-running ambush predator for the Rooftops zone. The Roof Rat runs along vertical surfaces (walls, ledges, rooftops), drops down to ambush players walking below, and retreats when cornered. It combines the stealth ambush pattern from the Stray Cat with vertical movement inspired by the Pigeon's aerial attacks.

---

## 1. Core Concept & Behavior

### Enemy Concept

The Roof Rat is a nimble, wall-crawling enemy that:
- **Patrols walls and rooftops** using vertical surface traversal
- **Ambushes from above** when the player walks beneath its perch
- **Retreats when cornered**, escaping up walls to reposition
- **Quick and elusive**, harder to hit due to vertical movement

### Design Inspiration

| Behavior | Reference | Adaptation |
|----------|-----------|------------|
| Stealth/ambush | Stray Cat | Rat fades to semi-transparent while waiting, reveals on pounce |
| Vertical drop | Pigeon Swoop | Rat drops from wall/roof, damages on impact |
| Retreat pattern | Cat Retreat | Rat flees upward/backward after attack |
| Wall traversal | None existing | **NEW** - multi-surface movement |

---

## 2. Stealth & Ambush Pattern

### Reference: Stray Cat (`characters/enemies/stray_cat.gd`)

The Stray Cat provides the ambush pattern to adapt for the Roof Rat:

```gdscript
## Cat-specific stealth properties (lines 7-9)
var stealth_alpha: float = 0.15      # Transparency when stealthed
var is_stealthed: bool = true        # Starts in stealth
var pounce_speed: float = 200.0      # Lunge velocity during pounce
```

### Roof Rat Stealth Adaptation

```gdscript
## Roof Rat stealth properties
var stealth_alpha: float = 0.20              # Slightly more visible than cat
var is_stealthed: bool = true                # Starts in stealth on wall
var wall_squish_factor: float = 0.7          # Flatten against wall while stealthed
```

### Stealth State Pattern: `rat_wall_stealth.gd`

Create a new state following `cat_stealth.gd` pattern:

```gdscript
extends State
class_name RatWallStealth

var no_target_timer: float = 0.0
const NO_TARGET_TIMEOUT: float = 4.0

func enter() -> void:
    player.velocity = Vector2.ZERO
    player.is_stealthed = true
    no_target_timer = 0.0
    if player.sprite:
        player.sprite.play("wall_idle")
        # Flatten sprite against wall
        var tween = player.create_tween()
        tween.tween_property(player.sprite, "scale:y", player.wall_squish_factor, 0.2)
        tween.parallel().tween_property(player.sprite, "modulate:a", player.stealth_alpha, 0.3)

func physics_update(delta: float) -> void:
    # Can't act while stunned
    if not player.can_act():
        player.velocity = Vector2.ZERO
        player.move_and_slide()
        return
    
    # Target detected - activate ambush mode
    if player.target and player.is_target_in_detection_range():
        no_target_timer = 0.0
        var distance = player.get_distance_to_target()
        
        # Player directly below - initiate ambush drop
        if _is_player_below():
            state_machine.transition_to("WallAmbush")
            return
        
        # Player approaching - stay stealthed but track
        _track_target_approach(delta)
        return
    
    # No target - wait on wall
    no_target_timer += delta
    if no_target_timer >= NO_TARGET_TIMEOUT:
        state_machine.transition_to("WallPatrol")
        return
    
    player.velocity = Vector2.ZERO
    player.move_and_slide()

func _is_player_below() -> bool:
    if not player.target:
        return false
    var to_target = player.target.global_position - player.global_position
    # Target is below if Y difference is positive (down in Godot) and X is close
    return to_target.y > 0 and abs(to_target.x) < 40.0
```

---

## 3. Ambush Attack Pattern

### Reference: Cat Pounce (`characters/enemies/states/cat_pounce.gd`)

The Cat Pounce provides the ambush attack timing pattern:

```gdscript
## Attack timing (lines 5-7)
const POUNCE_DURATION: float = 0.3
const HITBOX_START: float = 0.1
const HITBOX_END: float = 0.25
```

Key patterns to adapt:
1. Telegraph with "!" above enemy (lines 39-43)
2. Squash-stretch animation for weight feel (lines 116-127)
3. Direction calculation and velocity application (lines 21-29)
4. Hitbox positioning (lines 82-88)

### Roof Rat Ambush Adaptation: `rat_wall_ambush.gd`

```gdscript
extends State
class_name RatWallAmbush

## Wall ambush settings
const AMBUSH_DURATION: float = 0.4              # Slightly longer than cat for drop
const HITBOX_START: float = 0.15                # Hit when near player
const HITBOX_END: float = 0.30
const DROP_HEIGHT: float = 64.0                 # Max drop distance

var ambush_timer: float = 0.0
var hitbox_active: bool = false
var ambush_start_y: float = 0.0
var target_y: float = 0.0

func enter() -> void:
    ambush_timer = 0.0
    hitbox_active = false
    player.is_stealthed = false
    ambush_start_y = player.global_position.y
    
    if player.target:
        target_y = player.target.global_position.y
        # Target is typically at ground level, use player Y as reference
        if player.target.has_node("CollisionShape2D"):
            var shape = player.target.get_node("CollisionShape2D")
            target_y = player.target.global_position.y + shape.shape.size.y / 2
    
    if player.sprite:
        player.sprite.play("wall_ambush")
        # Restore full scale
        var tween = player.create_tween()
        tween.tween_property(player.sprite, "scale:y", 1.0, 0.1)
        tween.parallel().tween_property(player.sprite, "modulate:a", 1.0, 0.1)
    
    # Telegraph with "!" warning
    _show_telegraph()
    
    # Prepare hitbox
    if player.hitbox:
        player.hitbox.reset()
        player.hitbox.disable()

func physics_update(delta: float) -> void:
    # Cancel if stunned
    if not player.can_act():
        if player.hitbox:
            player.hitbox.disable()
        state_machine.transition_to("WallStealth")
        return
    
    ambush_timer += delta
    var progress = ambush_timer / AMBUSH_DURATION
    
    # Calculate vertical drop
    var y_offset = progress * (target_y - ambush_start_y)
    player.global_position.y = ambush_start_y + y_offset
    
    # Enable hitbox during active frames
    if progress >= HITBOX_START and progress < HITBOX_END:
        if not hitbox_active and player.hitbox:
            player.hitbox.enable()
            hitbox_active = true
    elif progress >= HITBOX_END:
        if hitbox_active and player.hitbox:
            player.hitbox.disable()
            hitbox_active = false
    
    # Slow horizontal movement toward target
    if player.target:
        var direction = (player.target.global_position - player.global_position).normalized()
        direction.y = 0  # Keep horizontal only
        player.velocity = direction * (player.patrol_speed * 0.5)
    else:
        player.velocity = Vector2.ZERO
    
    player.move_and_slide()
    
    # Ambush finished - transition to retreat
    if ambush_timer >= AMBUSH_DURATION:
        state_machine.transition_to("WallRetreat")

func _show_telegraph() -> void:
    # Similar to cat_pounce telegraph but positioned differently
    var label = Label.new()
    label.text = "!"
    label.add_theme_font_size_override("font_size", 10)
    label.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
    label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
    label.add_theme_constant_override("outline_size", 2)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.position = Vector2(-3, -20)  # Lower since dropping from above
    label.z_index = 90
    label.scale = Vector2(0.5, 0.5)
    label.pivot_offset = Vector2(3, 8)
    player.add_child(label)
    
    # Pop-in animation
    var tween = player.create_tween()
    tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.05)\
        .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    tween.tween_property(label, "scale", Vector2(1.0, 
