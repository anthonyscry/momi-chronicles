# Research Summary

## Quick Reference

### Project Settings
- Viewport: 384x216
- Window: 1152x648 (3x scale for dev)
- Stretch Mode: viewport
- Texture Filter: Nearest (0)

### Architecture
- Component-based design
- Node-based state machine
- Events autoload for cross-system signals
- "Call down, signal up" pattern

### Key Systems

| System | Approach |
|--------|----------|
| Movement | CharacterBody2D + move_and_slide() in _physics_process |
| States | Node children of StateMachine, lifecycle methods |
| Combat | Hitbox/Hurtbox Areas, collision layers |
| Health | Component with signals |
| Animation | AnimationPlayer, state-driven |
| Camera | Camera2D with smoothing and limits |

### File Locations

| What | Where |
|------|-------|
| Autoloads | `autoloads/` |
| State Machine | `components/state_machine/` |
| Player | `characters/player/` |
| Player States | `characters/player/states/` |
| Enemies | `characters/enemies/` |
| Zones | `world/zones/` |
| UI | `ui/` |

### Collision Layers Quick Reference
1. World
2. Player
3. Enemy
4. PlayerHurtbox
5. EnemyHurtbox
6. PlayerHitbox
7. EnemyHitbox
8. Trigger

### Input Actions
- Movement: move_up, move_down, move_left, move_right
- Combat: attack, dodge
- Other: run, interact, pause

## Implementation Order (Phase 1)

1. **project.godot** - Settings, inputs, autoloads
2. **State Machine** - Base system in components/
3. **Player Foundation** - Basic scene with movement
4. **Player States** - Idle, Walk, Run
5. **Camera** - Following with smoothing
6. **Test Zone** - Simple scene to verify everything

## Critical Settings

```ini
# project.godot essentials
[display]
window/size/viewport_width=384
window/size/viewport_height=216
window/stretch/mode="viewport"

[rendering]
textures/canvas_textures/default_texture_filter=0

[input]
move_up, move_down, move_left, move_right
attack, dodge, run, interact, pause

[autoload]
Events="*res://autoloads/events.gd"
GameManager="*res://autoloads/game_manager.gd"
```
