# Pigeon Enemy Implementation Research

## Overview

Research findings for implementing a Pigeon enemy - an aerial flocking enemy for the Rooftops zone. The pigeon will be a lighter, faster flying enemy that moves in groups and harasses the player with hit-and-run attacks.

---

## 1. Collision Layers for Flying Enemies

### Reference: Crow Implementation (`characters/enemies/crow.gd`)

Flying enemies in this project use a specific collision layer strategy:

```gdscript
# Crow _ready() - disables World collision (layer 1) to fly over obstacles
set_collision_mask_value(1, false)
```

### Pigeon Collision Layer Configuration

| Layer/Mask | Value | Purpose | Pigeon Setting |
|------------|-------|---------|----------------|
| Collision Layer 1 (World) | 1 | Walls, obstacles | **DISABLED** (flies over) |
| Collision Layer 2 (Player) | 2 | Player detection | Keep enabled |
| Collision Layer 3 (Enemy) | 4 | Enemy-vs-enemy | Keep enabled |
| Collision Layer 4 (PlayerHurtbox) | 8 | Player attacks | Keep enabled |
| Collision Layer 5 (EnemyHurtbox) | 16 | Enemy vulnerability | Keep enabled |
| Collision Layer 6 (PlayerHitbox) | 32 | Player hitbox | Keep enabled |
| Collision Layer 7 (EnemyHitbox) | 64 | Enemy attacks | Keep enabled |
| Collision Layer 8 (Trigger) | 128 | Zone transitions | Keep enabled |

### Key Implementation

In `pigeon.gd`:
```gdscript
func _ready() -> void:
    super._ready()
    # Flying pigeon ignores world collision
    set_collision_mask_value(1, false)
```

---

## 2. Flocking Behavior Pattern

### Reference: Rat Swarm Chase (`characters/enemies/states/rat_swarm_chase.gd`)

The codebase uses a **swarm behavior pattern** with three key components:

#### A. Pack Cohesion
```gdscript
const PACK_COHESION: float = 0.25

# In physics_update:
var pack_center = _get_pack_center()
if pack_center != Vector2.ZERO:
    var to_center = (pack_center - player.global_position).normalized()
    base_velocity += to_center * player.chase_speed * PACK_COHESION
```

#### B. Separation Force (from `enemy_base.gd`)
The existing `get_separation_force()` method in enemy_base.gd can be reused for flocking enemies.

#### C. Erratic Jitter (for pigeon-specific behavior)
```gdscript
const JITTER_INTERVAL: float = 0.2  # Faster than rats
const JITTER_STRENGTH: float = 15.0
```

### Pigeon Flocking State: `pigeon_flock_chase.gd`

Create a new state that combines:
1. **Cohesion** - Gravitate toward flock center (weaker than rats: 0.15)
2. **Separation** - Use existing `get_separation_force()` with multiplier
3. **Alignment** - Match velocity direction with nearby pigeons
4. **Wandering** - Add small random offsets for natural flight

### Flocking Configuration Constants

```gdscript
extends State
class_name PigeonFlockChase

const FLOCK_COHESION: float = 0.15      # Pull toward flock center
const FLOCK_ALIGNMENT: float = 0.20     # Match nearby pigeon direction
const FLOCK_SEPARATION_MULT: float = 50.0  # Separation force multiplier
const FLOCK_NEIGHBOR_RADIUS: float = 60.0  # Range to consider "nearby"
const WANDER_INTERVAL: float = 0.4      # Random direction change
const WANDER_STRENGTH: float = 25.0
```

---

## 3. Pigeon Stats vs Raccoon

### Stat Comparison Table

| Stat | Raccoon (Ground) | Crow (Flying) | **Pigeon (Flocking)** |
|------|------------------|---------------|----------------------|
| Patrol Speed | 25.0 | 35.0 | **30.0** |
| Chase Speed | 55.0 | 75.0 | **65.0** |
| Detection Range | 70.0 | 90.0 | **80.0** |
| Attack Range | 18.0 | 15.0 | **20.0** (longer reach) |
| Attack Damage | 15 | 10 | **8** (weaker per hit) |
| Attack Cooldown | 1.2s | 0.8s | **0.6s** (faster attacks) |
| Knockback Force | 80.0 | 110.0 | **100.0** |
| Max Health | 40 | 25 | **20** (squishy) |
| EXP Value | 25 | 15 | **12** |
| Drop Rate (coins) | 80% | 90% | **95%** |

### Pigeon Stat Rationale

- **Lower HP** - Exposed in air, easy to hit
- **Lower damage per hit** - Compensated by flock attacks
- **Faster attack cooldown** - Multiple pigeons attack in succession
- **Higher chase speed** - Keep up with player on rooftops
- **Lower EXP** - Weaker enemy, more common

---

## 4. State Machine Pattern

### Reference: State Machine Architecture

States are located in `characters/enemies/states/` and follow this pattern:

```
State Machine Structure:
├── Idle (enemy_idle.gd)
├── Patrol (enemy_patrol.gd)
├── Chase (enemy_chase.gd) OR PigeonFlockChase (NEW)
├── Attack (enemy_attack.gd)
├── Hurt (enemy_hurt.gd)
└── Death (enemy_death.gd)
```

### Adding New States

1. **Create state file**: `characters/enemies/states/pigeon_flock_chase.gd`
2. **Extend State class**: `extends State`
3. **Implement required methods**:
   - `func enter() -> void:`
   - `func exit() -> void:`
   - `func physics_update(delta: float) -> void:`
4. **Add to scene**: Include in `pigeon.tscn` StateMachine node

### State File Template

```gdscript
extends State
class_name PigeonFlockChase

## Pigeon flock chase state - coordinated aerial group movement.

func enter() -> void:
    player.velocity = Vector2.ZERO
    if player.sprite:
        player.sprite.play("fly")

func physics_update(delta: float) -> void:
    # Chase logic here
    pass

func exit() -> void:
    pass
```

### State Transitions for Pigeon

```
Idle -> Patrol (no target, has patrol points)
Idle -> FlockChase (target detected)
Patrol -> FlockChase (target detected)
FlockChase -> Attack (in range)
FlockChase -> Idle (lost target)
Attack -> FlockChase (post-attack, target still there)
Hurt -> FlockChase (recovered, target still there)
Any -> Death (health <= 0)
```

---

## 5. Sprite Frames Animations

### Reference: Crow SpriteFrames (`characters/enemies/crow.tscn`)

```gdscript
# Crow animations (simple, 1-frame each)
animations = [{
    "frames": [{"texture": "res://art/generated/enemies/crow_idle.png"}],
    "loop": true,
    "name": "idle"
}, {
    "frames": [{"texture": "res://art/generated/enemies/crow_dive.png"}],
    "loop": false,
    "name": "attack"
}, {
    "frames": [{"texture": "res://art/generated/enemies/crow_idle.png"}],
    "loop": true,
    "name": "walk"
}, {
    "frames": [{"texture": "res://art/generated/enemies/crow_idle.png"}],
    "loop": true,
    "name": "hurt"
}, {
    "frames": [{"texture": "res://art/generated/enemies/crow_idle.png"}],
    "loop": false,
    "name": "death"
}]
```

### Required Pigeon Animations

| Animation | Frames | Loop | Purpose |
|-----------|--------|------|---------|
| **idle** | 2-4 | Yes | Hovering in place, slight bob |
| **fly** | 3-4 | Yes | Wings flapping during movement |
| **attack** | 2-3 | No | Peck or wing slap |
| **hurt** | 2 | Yes | Flailing, stunned pose |
| **death** | 4-5 | No | Falling down, feathers |

### Animation Specifications

- **Frame rate**: 8-10 FPS (pigeon wings beat faster than crow)
- **Directional**: Flip sprite horizontally for left/right (handled by `update_facing()`)
- **Visual distinction**: Pigeons should look different from crows (gray/brown vs black)

### Sprite Assets Needed

```
art/generated/enemies/
├── pigeon_idle.png        # 16x16 or 32x32, gray/blue pigeon
├── pigeon_fly1.png        # Wing up
├── pigeon_fly2.png        # Wing down
├── pigeon_fly3.png        # Wing up (if 3 frames)
├── pigeon_attack.png      # Pecking pose
├── pigeon_hurt.png        # Injured pose
└── pigeon_death.png       # Falling animation frames
```

### Alternative: Use Existing Crow Assets Temporarily

The crow sprites can be used as placeholders until pigeon sprites are generated.

---

## 6. Implementation Checklist

### Files to Create

1. `characters/enemies/pigeon.gd` - Enemy class
2. `characters/enemies/states/pigeon_flock_chase.gd` - Flocking behavior state
3. `characters/enemies/pigeon.tscn` - Enemy scene
4. `art/generated/enemies/pigeon_*.png` - Sprite assets (deferred to art phase)

### Files to Modify

None - pigeon is a new enemy, follows existing patterns.

### Scene Setup (pigeon.tscn)

```
Node2D (CharacterBody2D)
├── Sprite2D (AnimatedSprite2D)
├── CollisionShape2D (Capsule, smaller than crow: radius 4, height 10)
├── AnimationPlayer
├── StateMachine
│   ├── Idle (enemy_id
le_idle.gd)
│   │   ├── Patrol (enemy_patrol.gd)
│   │   ├── FlockChase (pigeon_flock_chase.gd) - NEW
│   │   ├── Attack (enemy_attack.gd)
│   │   ├── Hurt (enemy_hurt.gd)
│   │   └── Death (enemy_death.gd)
│   ├── DetectionArea (Area2D) - radius 80
│   ├── Hitbox (Area2D) - smaller damage area
│   ├── Hurtbox (Area2D)
│   └── HealthComponent - max_health 20
```

### Drop Table for Pigeon

```gdscript
func _init_default_drops() -> void:
    drop_table = [
        {"scene": COIN_PICKUP_SCENE, "chance": 0.95, "min": 1, "max": 2},
        {"scene": HEALTH_PICKUP_SCENE, "chance": 0.10, "min": 1, "max": 1},
        {"item_id": "bread_crumb", "chance": 0.15, "min": 1, "max": 3},
    ]
```

---

## 7. Recommended Pigeon Behavior (Design Notes)

### Single Pigeon vs Flock

- **Single pigeon**: Uses standard `enemy_chase.gd`, behaves like weak crow
- **Flock (2+)**: Uses `pigeon_flock_chase.gd` with cohesion/alignment

### Flock Spawn Logic

The flock should spawn together or be spawned by a trigger:
```gdscript
# Example: Spawn 3-5 pigeons in formation
for i in range(count):
    var pigeon = pigeon_scene.instantiate()
    var offset = Vector2(cos(angle), sin(angle)) * 30 * (i + 1)
    pigeon.global_position = spawn_point + offset
    get_parent().add_child(pigeon)
```

### Attack Behavior

Pigeons don't have complex attacks - they harass by:
1. Flying past the player (brief contact damage)
2. Using standard `enemy_attack.gd` for a quick peck
3. Rapid attack cooldowns allow multiple hits per pass

### Despawn Logic

Pigeons should despawn if too far from their flock anchor:
```gdscript
# In pigeon_flock_chase.gd
var flock_anchor: Vector2 = Vector2.ZERO  # Set on spawn
func _check_flock_integrity() -> void:
    if global_position.distance_to(flock_anchor) > 200.0:
        queue_free()  # Fly away if separated from flock
```

---

## 8. References Summary

| File | Purpose |
|------|---------|
| `characters/enemies/enemy_base.gd` | Base class with stats, signals, drop system |
| `characters/enemies/crow.gd` | Flying enemy reference (is_flying = true) |
| `characters/enemies/pigeon.gd` | **TO CREATE** - Pigeon-specific stats |
| `characters/enemies/states/enemy_idle.gd` | Base idle state |
| `characters/enemies/states/enemy_patrol.gd` | Base patrol state |
| `characters/enemies/states/enemy_chase.gd` | Base chase with separation |
| `characters/enemies/states/rat_swarm_chase.gd` | Swarm behavior reference |
| `characters/enemies/states/pigeon_flock_chase.gd` | **TO CREATE** - Flocking AI |
| `characters/enemies/crow.tscn` | Flying enemy scene structure |
| `characters/enemies/pigeon.tscn` | **TO CREATE** - Pigeon scene |
| `project.godot` | Collision layer definitions |

---

## 9. Open Questions / Decisions Needed

1. **Sprite size**: Crow uses 16x16 (likely). Should pigeon be same size?
2. **Pigeon-specific attack**: Create `pigeon_peck.gd` or reuse `enemy_attack.gd`?
3. **Flock minimum**: At what count does flock behavior activate? (2? 3?)
4. **Flock persistence**: Do pigeons die individually or as a group?
5. **Coop behavior**: Can player companion scare/attract pigeons?
6. **Drop item**: Should "bread_crumb" be a new item or use existing?

---

*Research completed: 2026-02-01*
*Milestone: v1.6 Visual Polish - Rooftops Zone*
