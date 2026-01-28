# Technology Stack Research

## Engine: Godot 4.5

### Why Godot 4.5
- Native 2D engine (not 3D with 2D mode)
- GDScript is Python-like, fast iteration
- Built-in animation, physics, UI systems
- Open source, no royalties
- Excellent pixel art support

### Key 4.x Features We'll Use
- CharacterBody2D with move_and_slide()
- AnimationPlayer + AnimationTree
- TileMap with TileSet resources
- Area2D for hitboxes/hurtboxes
- Signals for decoupled communication

## Architecture Patterns

### Component-Based Design
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── AnimationPlayer
├── StateMachine
│   ├── IdleState
│   ├── WalkState
│   └── RunState
├── HitboxComponent
├── HurtboxComponent
└── HealthComponent
```

### Autoload Strategy
Only use autoloads for truly global systems:
- **Events** - Signal bus for decoupled communication
- **GameManager** - Game state (paused, etc.)

NOT autoloads (use composition instead):
- Player reference (pass via signals/methods)
- Combat calculations
- UI updates

### Signal Pattern: "Call Down, Signal Up"
- Parent nodes call methods on children
- Children emit signals to communicate up
- Siblings communicate via Events autoload

## File Organization
```
momi-chronicles/
├── autoloads/           # Global singletons
├── components/          # Reusable components
│   ├── state_machine/
│   ├── hitbox/
│   └── health/
├── characters/
│   ├── player/
│   └── enemies/
├── world/
│   ├── zones/
│   └── tilesets/
├── ui/
├── assets/
│   ├── sprites/
│   └── audio/
└── gemini_images/       # AI-generated source art
```

## Pixel Art Settings

### Viewport
- Base resolution: 384x216 (16:9)
- Scales well to 1080p (5x), 1440p (6.67x), 4K (10x)
- Integer scaling for pixel-perfect rendering

### Texture Settings
- Filter: Nearest (no interpolation)
- Repeat: Disabled
- Mipmaps: Disabled

### project.godot Settings
```ini
[display]
window/size/viewport_width=384
window/size/viewport_height=216
window/size/window_width_override=1152
window/size/window_height_override=648
window/stretch/mode="viewport"
window/stretch/aspect="keep"

[rendering]
textures/canvas_textures/default_texture_filter=0
```
