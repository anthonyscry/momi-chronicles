# Phase 20: Mini-Boss System - Research

**Researched:** 2026-01-28
**Domain:** Godot 4.5 enemy AI / boss encounter design / component architecture
**Confidence:** HIGH (all findings verified against codebase — no external library dependencies)

## Summary

The mini-boss system builds directly on two mature, well-understood patterns in the codebase: the **EnemyBase** extension pattern (used by 5+ enemies) and the **BossRaccoonKing** pattern (3 attack states, enrage mechanic, health bar). Mini-bosses sit between these — they extend EnemyBase, use the same state machine, but add boss-like features (attack patterns, special health bar, one-time defeat tracking, unique loot).

The codebase already provides every building block needed:
- `EnemyBase` with drop_table, health bar, state machine, hitbox/hurtbox
- `BossRaccoonKing` with attack pattern cycling, enrage, summoning, death sequence
- `HealthComponent` with poison DoT
- `ToxicPuddle` as AoE hazard template
- `ShadowBolt` as projectile template
- `BossHealthBar` with damage flash, shake, animated fill
- `SaveManager` with `boss_defeated` flag pattern
- `EquipmentDatabase` with slot/stat definitions
- Zone `_build_enemies()` pattern for programmatic enemy placement

**Primary recommendation:** Create a `MiniBossBase` class extending EnemyBase (path-based extend), add 2 attack states per mini-boss, adapt the existing BossHealthBar for mid-size display, extend SaveManager with per-mini-boss defeat flags, and add new rare equipment to EquipmentDatabase.

## 1. Existing Boss System Analysis

### What Exists (BossRaccoonKing)

| Component | Implementation | Reusable? |
|-----------|---------------|-----------|
| Boss class | `extends EnemyBase`, `class_name BossRaccoonKing` | Pattern reusable, but mini-bosses should NOT extend BossRaccoonKing |
| Stats override | Constants + override in `_ready()` before `super._ready()` | **YES** — same pattern |
| Attack patterns | `enum AttackPattern`, `attack_pattern_order` array, cycling index | **YES** — simplified to 2 patterns |
| Enrage mechanic | `check_enrage()` at HP threshold, speed/damage boost | **PARTIALLY** — Rat King splits instead of enraging |
| Boss health bar | `BossHealthBar` Control, signal-driven via `Events.boss_spawned/defeated/enraged` | **ADAPT** — need mid-size variant |
| Boss arena | `BossArena` scene with locked doors, spawn point | **NOT REUSED** — mini-bosses spawn in regular zones |
| Death sequence | Custom `_play_death_sequence()` with flash/particles | **YES** — can simplify for mini-bosses |
| Summoning | `BossAttackSummon` loads raccoon scene, spawns near boss | **YES** — Alpha Raccoon and Crow Matriarch both summon |
| Drop table | Override `_init_default_drops()` | **YES** — extend for equipment drops |

### Boss State Architecture

The boss uses 4 dedicated state scripts:
- `BossIdle` — waits, then calls `enemy.get_attack_state_name()` to pick next attack
- `BossAttackSwipe` — 3-phase (WINDUP → SWIPE → RECOVERY), scales hitbox, visual rotation
- `BossAttackCharge` — 3-phase (TELEGRAPH → CHARGE → RECOVERY), linear movement, hitbox on/off
- `BossAttackSummon` — loads scene, spawns near boss, particle effects

**Key pattern:** Each attack state has a timer-driven phase enum (`Phase { WINDUP, ACTIVE, RECOVERY }`), enables/disables hitbox at precise moments, and transitions back to idle state on completion. **Mini-boss attack states MUST follow this same pattern.**

### What to Reuse vs Build New

| Feature | Reuse | Build New |
|---------|-------|-----------|
| Attack state phase pattern (WINDUP→ACTIVE→RECOVERY) | Reuse pattern | New state scripts per mini-boss |
| BossHealthBar | Adapt for mid-size | New `MiniBossHealthBar` |
| Events.boss_spawned/defeated | Reuse OR add mini_boss signals | Add `mini_boss_spawned/defeated` signals |
| Drop table system | Extend | Add equipment drop entries |
| Save tracking | Extend | Add per-boss defeat flags |
| Arena/locking | Skip | Area2D trigger zones |

## 2. Enemy Extension Pattern

### How Enemies Extend EnemyBase

All enemies use **path-based extends** (not `class_name` reference):
```gdscript
extends "res://characters/enemies/enemy_base.gd"
class_name SewerRat
```

Pattern for every enemy:
1. Set stat overrides in `_ready()` BEFORE calling `super._ready()`
2. Call `super._ready()` (sets up state machine, health bar, hitbox, groups)
3. Override appearance (sprite.color, sprite.polygon, optional child nodes)
4. Override `_init_default_drops()` for custom drop table

### MiniBossBase Design

Create an intermediate class between EnemyBase and specific mini-bosses:

```gdscript
# characters/enemies/mini_boss_base.gd
extends "res://characters/enemies/enemy_base.gd"
class_name MiniBossBase

## Mini-boss configuration
@export var boss_name: String = "Mini-Boss"
@export var is_defeated_key: String = ""  # Save key for one-time defeat

## Attack pattern system (like BossRaccoonKing)
var attack_patterns: Array[String] = []  # State names
var current_attack_index: int = 0

## Mini-boss state
var is_mini_boss: bool = true
var defeat_tracked: bool = false

func _ready() -> void:
    super._ready()
    add_to_group("mini_bosses")
    # Remove small enemy health bar (will use HUD bar instead)
    if health_bar:
        health_bar.queue_free()
        health_bar = null
    # Emit spawn event
    Events.mini_boss_spawned.emit(self, boss_name)

func get_next_attack_state() -> String:
    if attack_patterns.is_empty():
        return "Idle"
    var state = attack_patterns[current_attack_index]
    current_attack_index = (current_attack_index + 1) % attack_patterns.size()
    return state

func _on_died() -> void:
    Events.mini_boss_defeated.emit(self, is_defeated_key)
    _spawn_drops()
    _play_mini_boss_death()
```

### Node Structure (per mini-boss .tscn)

```
AlphaRaccoon (CharacterBody2D) — script: alpha_raccoon.gd
├── Sprite2D (Polygon2D) — programmatic visual
├── AnimationPlayer
├── StateMachine
│   ├── Idle (EnemyIdle or custom MiniBossIdle)
│   ├── Chase (EnemyChase)
│   ├── Hurt (EnemyHurt)
│   ├── Death (EnemyDeath)
│   ├── AlphaSlam (custom attack state 1)
│   └── AlphaSummon (custom attack state 2)
├── Hitbox
├── Hurtbox
├── HealthComponent
├── DetectionArea (Area2D)
└── CollisionShape2D
```

## 3. Attack Pattern Implementations

### Pattern: Ground Slam AoE (Alpha Raccoon)

Based on the existing charge attack pattern + shockwave from ground pound effects:

```gdscript
# Attack state: AlphaSlam
# Phase: TELEGRAPH (0.5s) → LEAP (0.3s) → IMPACT (0.1s) → RECOVERY (0.6s)
# TELEGRAPH: shake sprite, warning indicator on ground
# LEAP: move upward slightly (visual only)
# IMPACT: create AoE damage zone (Area2D circle), screen shake
# RECOVERY: idle briefly

# AoE implementation: temporary Area2D with CircleShape2D
# - collision_mask = 2 (Player layer)
# - on body_entered → deal damage via hitbox or direct health.take_damage()
# - Visual: expanding circle Polygon2D that fades
# Existing reference: EffectsManager._create_shockwave() for visual pattern
```

### Pattern: Summon Reinforcements (Alpha Raccoon, Crow Matriarch)

Direct reuse of `BossAttackSummon._do_summon()`:

```gdscript
# Load scene, instantiate, position near boss, add to parent
var raccoon_scene = load("res://characters/enemies/raccoon.tscn")
var raccoon = raccoon_scene.instantiate()
raccoon.global_position = enemy.global_position + offset
enemy.get_parent().add_child(raccoon)
```

**Cap spawned reinforcements** (max 3-4 alive at once) — check `get_tree().get_nodes_in_group("enemies")` count or track spawned array.

### Pattern: Dive Bomb Attack (Crow Matriarch)

Based on BossAttackCharge pattern — telegraph, then fast linear movement with hitbox:

```gdscript
# Phase: ASCEND (0.4s) → TELEGRAPH (0.3s) → DIVE (0.4s) → RECOVERY (0.5s)
# ASCEND: fly up (y -= 40, scale slightly), become invulnerable
# TELEGRAPH: lock target position, show ground indicator
# DIVE: move to target at high speed (250+ px/s), enable hitbox
# RECOVERY: land, re-enable hurtbox
```

### Pattern: Crow Swarm Summon (Crow Matriarch)

Spawn 3-5 crow enemies in formation:

```gdscript
var crow_scene = load("res://characters/enemies/crow.tscn")
for i in range(crow_count):
    var crow = crow_scene.instantiate()
    var angle = i * TAU / crow_count
    crow.global_position = self.global_position + Vector2(cos(angle), sin(angle)) * 25
    get_parent().add_child(crow)
```

### Pattern: Split at 50% HP (Rat King)

Unique mechanic — when health reaches 50%, spawn smaller rats and optionally shrink or transform:

```gdscript
# In _on_hurt() override:
func _on_hurt(attacking_hitbox: Hitbox) -> void:
    super._on_hurt(attacking_hitbox)
    if not has_split and health.get_health_percent() <= 0.5:
        _split_into_rats()

func _split_into_rats():
    has_split = true
    # Spawn 3-4 sewer rats nearby
    var rat_scene = load("res://characters/enemies/sewer_rat.tscn")
    for i in range(4):
        var rat = rat_scene.instantiate()
        var angle = i * TAU / 4
        rat.global_position = global_position + Vector2(cos(angle), sin(angle)) * 20
        get_parent().add_child(rat)
    # Visual: poof particles, screen shake
    # Rat King continues fighting (doesn't die)
    # Optional: shrink sprite slightly, speed up
```

### Pattern: Poison AoE Cloud (Rat King)

Based on ToxicPuddle pattern — Area2D with timed poison application:

```gdscript
# Create a temporary Area2D poison cloud
func _spawn_poison_cloud(pos: Vector2) -> void:
    var cloud = Area2D.new()
    cloud.collision_layer = 0
    cloud.collision_mask = 2  # Player layer
    cloud.global_position = pos
    
    var shape = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 30.0
    shape.shape = circle
    cloud.add_child(shape)
    
    # Visual: green-purple circle, pulsing
    var visual = Polygon2D.new()
    # ... circle polygon points ...
    visual.color = Color(0.4, 0.7, 0.2, 0.4)
    cloud.add_child(visual)
    
    # Poison on contact
    cloud.body_entered.connect(func(body):
        if body.is_in_group("player"):
            var hc = body.get_node_or_null("HealthComponent")
            if hc: hc.apply_poison(3, 3.0)
    )
    
    get_parent().add_child(cloud)
    
    # Auto-despawn after duration
    var timer = get_tree().create_timer(4.0)
    timer.timeout.connect(cloud.queue_free)
```

## 4. Save System Integration

### Current Save Structure

```gdscript
# SaveManager._get_default_data()
{
    "version": 1,
    "level": 1,
    "total_exp": 0,
    "coins": 0,
    "current_zone": "neighborhood",
    "boss_defeated": false,  # Single boolean for Raccoon King
    "timestamp": ...
}
```

### Required Changes

Add a `mini_bosses_defeated` dictionary:

```gdscript
# In _get_default_data():
"mini_bosses_defeated": {
    "alpha_raccoon": false,
    "crow_matriarch": false,
    "rat_king": false,
}

# In _gather_save_data():
data.mini_bosses_defeated = GameManager.mini_bosses_defeated

# In _apply_save_data():
GameManager.mini_bosses_defeated = data.get("mini_bosses_defeated", {
    "alpha_raccoon": false,
    "crow_matriarch": false,
    "rat_king": false,
})
```

### GameManager Changes

```gdscript
# Add to GameManager:
var mini_bosses_defeated: Dictionary = {
    "alpha_raccoon": false,
    "crow_matriarch": false,
    "rat_king": false,
}

func _ready():
    # ... existing connections ...
    Events.mini_boss_defeated.connect(_on_mini_boss_defeated)

func _on_mini_boss_defeated(_boss: Node, boss_key: String) -> void:
    if mini_bosses_defeated.has(boss_key):
        mini_bosses_defeated[boss_key] = true
    # Auto-save after mini-boss defeat
    await get_tree().create_timer(2.0).timeout
    SaveManager.save_game()
```

### Save Version Migration

Increment `SAVE_VERSION` to 2 and add migration:
```gdscript
# In _apply_save_data():
if data.version == 1:
    # Migrate: add mini_bosses_defeated
    data.mini_bosses_defeated = {"alpha_raccoon": false, ...}
    data.version = 2
```

**Confidence: HIGH** — direct extension of existing SaveManager pattern.

## 5. Zone Spawn Triggers

### Current Zone Enemy Placement

Zones place enemies programmatically in `_build_enemies()` (see sewers.gd):
```gdscript
func _build_enemies() -> void:
    var enemies_cont = $Enemies  # or create Node2D container
    var rat = SEWER_RAT_SCENE.instantiate()
    rat.position = Vector2(x, y)
    enemies_cont.add_child(rat)
```

### Mini-Boss Spawn Trigger Design

Mini-bosses are **optional** encounters — not spawned at zone load. Instead, use an Area2D trigger zone:

```gdscript
# In zone's _setup_zone() or _build_mini_boss_trigger():
func _build_mini_boss_trigger() -> void:
    # Check if already defeated
    if GameManager.mini_bosses_defeated.get("alpha_raccoon", false):
        return  # Don't spawn trigger
    
    var trigger = Area2D.new()
    trigger.name = "MiniBossTrigger"
    trigger.collision_layer = 0
    trigger.collision_mask = 2  # Player layer
    trigger.position = MINI_BOSS_ARENA_CENTER
    
    var shape = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = Vector2(80, 60)  # Arena size trigger
    shape.shape = rect
    trigger.add_child(shape)
    
    trigger.body_entered.connect(_on_mini_boss_trigger_entered)
    add_child(trigger)
    
    # Optional: visual warning (skull icon, different ground color)
    _build_mini_boss_warning_decor(MINI_BOSS_ARENA_CENTER)

func _on_mini_boss_trigger_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):
        return
    # Spawn mini-boss
    var boss = ALPHA_RACCOON_SCENE.instantiate()
    boss.global_position = MINI_BOSS_SPAWN_POINT
    add_child(boss)
    # Remove trigger (one-time activation per zone visit)
    $MiniBossTrigger.queue_free()
```

### Zone Placement

| Mini-Boss | Zone | Suggested Location |
|-----------|------|-------------------|
| Alpha Raccoon | Neighborhood | Park area (~150, 480) — open space |
| Crow Matriarch | Backyard | Center area (~192, 108) — fits the zone |
| Rat King | Sewers | Side room or corridor junction |

**No locked doors needed** — player can flee. Mini-bosses have large `lose_interest_range` but won't follow into zone exits.

## 6. HUD / Health Bar

### Current BossHealthBar

- `Control` node anchored top-center
- 200px wide, 12px tall bar
- Label for boss name (14pt font)
- Fill bar with damage flash overlay
- Shake on damage, animated fill
- Connected via Events: `boss_spawned`, `boss_enraged`, `boss_defeated`
- Hardcoded "RACCOON KING" name

### MiniBossHealthBar Design

Create a **separate, smaller** health bar OR **adapt BossHealthBar to be configurable**:

**Option A (Recommended): Adapt BossHealthBar**

Make BossHealthBar generic enough to handle both:

```gdscript
# Modify BossHealthBar to accept mini-boss signals too:
func _ready() -> void:
    visible = false
    Events.boss_spawned.connect(_on_boss_spawned)
    Events.boss_enraged.connect(_on_boss_enraged)
    Events.boss_defeated.connect(_on_boss_defeated)
    # NEW: mini-boss signals
    Events.mini_boss_spawned.connect(_on_mini_boss_spawned)
    Events.mini_boss_defeated.connect(_on_mini_boss_defeated)

func _on_mini_boss_spawned(boss: Node, boss_name_text: String) -> void:
    boss_ref = boss
    boss_name_label.text = boss_name_text
    # Smaller bar for mini-boss
    _set_bar_size(150.0, 10.0)  # Narrower, slightly shorter
    boss_name_label.add_theme_font_size_override("font_size", 11)
    # ... show bar
```

**Option B: New MiniBossHealthBar**

Duplicate BossHealthBar scene/script, adjust dimensions:
- 150px wide, 10px tall
- Font size 11 (not 14)
- Different color scheme (e.g., orange fill vs red)
- Same damage flash/shake behavior

**Recommendation: Option A** — less code duplication, same UX pattern. The BossHealthBar just needs parameterization.

## 7. Loot / Drop System

### Current Drop System

EnemyBase has:
```gdscript
var drop_table: Array[Dictionary] = []
# Format: {"scene": PackedScene, "chance": 0.0-1.0, "min": int, "max": int}
```

Currently only drops health pickups and coins. Equipment uses `EquipmentManager.add_equipment(equip_id)` — there's no equipment pickup scene.

### Mini-Boss Equipment Drops

**Two approaches:**

**A) Direct equipment grant (simpler):**
```gdscript
# In mini-boss _on_died() override:
func _on_died() -> void:
    # Grant equipment directly
    if GameManager.equipment_manager:
        GameManager.equipment_manager.add_equipment(loot_equipment_id)
    # Show loot notification
    Events.mini_boss_defeated.emit(self, is_defeated_key)
    super._on_died()
```

**B) Equipment pickup entity (full system):**
Create an `equipment_pickup.gd` similar to `health_pickup.gd`:
```gdscript
extends Area2D
var equipment_id: String = ""
func _on_body_entered(body):
    if body.is_in_group("player"):
        GameManager.equipment_manager.add_equipment(equipment_id)
        Events.pickup_collected.emit("equipment", 1)
        queue_free()
```

**Recommendation: Option A (direct grant)** for simplicity. Mini-bosses are one-time defeats — the player is guaranteed the drop. A floating notification label ("Got Spiked Crown!") provides feedback.

### New Equipment Items

Add 3 rare items to `EquipmentDatabase.EQUIPMENT`:

| Equipment ID | Name | Slot | Stats | Mini-Boss Source |
|-------------|------|------|-------|-----------------|
| `raccoon_crown` | Raccoon Crown | HAT | +15 Max HP, +5 Attack | Alpha Raccoon |
| `crow_feather_coat` | Crow Feather Coat | COAT | +10 Speed, +10% Defense | Crow Matriarch |
| `rat_king_collar` | Rat King's Collar | COLLAR | +8 Attack, +5% Guard Regen | Rat King |

These should be meaningfully stronger than shop items to reward the optional challenge.

## 8. Events System Integration

### New Signals Needed

Add to `autoloads/events.gd`:

```gdscript
# =============================================================================
# MINI-BOSS SIGNALS
# =============================================================================

## Emitted when a mini-boss spawns
signal mini_boss_spawned(boss: Node, boss_name: String)

## Emitted when a mini-boss is defeated
signal mini_boss_defeated(boss: Node, boss_key: String)
```

### Signal Flow

```
Player enters trigger area
  → Zone spawns mini-boss
    → MiniBossBase._ready() emits Events.mini_boss_spawned
      → MiniBossHealthBar shows
      → EffectsManager intro effects (lighter than full boss)
      
Mini-boss health reaches 0
  → MiniBossBase._on_died() emits Events.mini_boss_defeated
    → MiniBossHealthBar hides
    → GameManager marks defeated + auto-saves
    → Equipment granted to player
    → EffectsManager victory effects
```

## 9. Standard Stack

### Core (All from existing codebase)

| Component | Source | Purpose |
|-----------|--------|---------|
| EnemyBase | `characters/enemies/enemy_base.gd` | Base class for all enemies |
| State/StateMachine | `components/state_machine/` | AI state management |
| HealthComponent | `components/health/health_component.gd` | HP, poison, damage |
| Hitbox/Hurtbox | `components/hitbox/`, `components/hurtbox/` | Damage dealing/receiving |
| Events | `autoloads/events.gd` | Signal bus |
| SaveManager | `autoloads/save_manager.gd` | Persistence |
| GameManager | `autoloads/game_manager.gd` | Game state |
| EquipmentDatabase | `systems/equipment/equipment_database.gd` | Item definitions |
| EquipmentManager | `systems/equipment/equipment_manager.gd` | Inventory/equip |
| EffectsManager | `autoloads/effects_manager.gd` | VFX, screen shake |
| BossHealthBar | `ui/hud/boss_health_bar.gd` | Boss HP display |

### No New Dependencies

Everything is built with Godot core classes. No plugins, addons, or external tools.

## 10. Architecture Patterns

### Recommended File Structure

```
characters/enemies/
├── mini_boss_base.gd              # MiniBossBase extends EnemyBase
├── alpha_raccoon.gd               # Alpha Raccoon extends MiniBossBase
├── alpha_raccoon.tscn
├── crow_matriarch.gd              # Crow Matriarch extends MiniBossBase
├── crow_matriarch.tscn
├── rat_king.gd                    # Rat King extends MiniBossBase
├── rat_king.tscn
└── states/
    ├── mini_boss_idle.gd          # MiniBossIdle (like BossIdle)
    ├── alpha_slam.gd              # Ground slam AoE
    ├── alpha_summon.gd            # Raccoon reinforcements
    ├── crow_dive_bomb.gd          # Dive bomb attack
    ├── crow_swarm_summon.gd       # Crow swarm summon
    ├── rat_king_poison_cloud.gd   # Poison AoE cloud
    └── rat_king_split.gd          # Split into smaller rats (triggered by HP threshold, not a state)
```

### Pattern: MiniBossIdle State

Reuse the BossIdle pattern — wait briefly, then pick next attack:

```gdscript
extends State
class_name MiniBossIdle

var idle_timer: float = 0.0
@export var idle_duration: float = 1.5

func enter() -> void:
    idle_timer = 0.0
    player.velocity = Vector2.ZERO

func physics_update(delta: float) -> void:
    if not player.can_act():
        return
    
    # Face target
    if player.target:
        player.update_facing(player.get_direction_to_target())
    
    # No target — chase behavior instead
    if not player.target:
        state_machine.transition_to("Chase")
        return
    
    idle_timer += delta
    if idle_timer >= idle_duration:
        if player.has_method("get_next_attack_state"):
            state_machine.transition_to(player.get_next_attack_state())
```

**Critical note:** State scripts access the entity via `player` variable (set by StateMachine.init). Despite the confusing name, for enemy states, `player` refers to the enemy entity. All regular enemy states (EnemyIdle, RatSwarmChase, etc.) use `player.velocity`, `player.target`, etc. Mini-boss states MUST follow this same convention.

### Anti-Patterns to Avoid

- **Don't extend BossRaccoonKing** — it has Raccoon-King-specific logic (crown visual, hardcoded enrage). Extend EnemyBase instead.
- **Don't use class_name for extends** — use path-based extends as established: `extends "res://characters/enemies/enemy_base.gd"` or `extends "res://characters/enemies/mini_boss_base.gd"`
- **Don't hand-roll poison** — use `HealthComponent.apply_poison()` which already handles ticks, duration, visual tinting, and cleanup.
- **Don't create separate collision layers** — use existing layers (3=Enemy, 4-7=Hitbox/Hurtbox). Mini-bosses are still enemies.
- **Don't skip super._ready()** — EnemyBase._ready() sets up the state machine, health bar, hitbox, groups, and drop table.

## 11. Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Poison DoT | Custom timer/damage system | `HealthComponent.apply_poison()` | Handles ticks, cleanup, visual, signals |
| AoE damage zone | Custom collision detection | `Area2D` + `body_entered` signal + `HealthComponent.take_damage()` | Godot handles detection, shape flexibility |
| Screen shake | Camera manipulation | `EffectsManager.screen_shake()` | Handles overlap, decay, accessibility toggle |
| Particle effects | Complex particle system | `ColorRect` + tween patterns (used everywhere) | Consistent with entire codebase |
| State machine | Custom AI loop | Existing `StateMachine` + `State` components | Battle-tested, supports transitions, debug logging |
| Drop system | Custom loot code | `EnemyBase.drop_table` + `_spawn_drops()` | Already handles chance, count, offset, spawning |
| Health bar | Build from scratch | Adapt `BossHealthBar` | Already has damage flash, shake, animated fill, signal-driven |
| Save persistence | Custom file I/O | Extend `SaveManager._get_default_data()` | Atomic writes, backup, validation already working |
| Equipment grant | Custom inventory code | `EquipmentManager.add_equipment()` | Handles uniqueness, slot management, signals |

## 12. Common Pitfalls

### Pitfall 1: State Variable Naming Convention
**What goes wrong:** Boss states in codebase reference `enemy.` (e.g., `enemy.velocity`) but `State` base class only defines `var player`.
**Why it happens:** The `State.player` variable is confusingly named — it holds ANY entity (player or enemy). Boss states seem to use `enemy` which is inconsistent.
**How to avoid:** In ALL mini-boss states, use `player.` to access the entity (matching regular enemy states like `RatSwarmChase`, `EnemyIdle`, etc.). Do NOT use `enemy.` — stick with what the base State class provides.
**Warning signs:** Runtime errors about undefined variable `enemy`.

### Pitfall 2: Forgetting super._ready() Call Order
**What goes wrong:** Stats don't take effect, or health is wrong.
**Why it happens:** `EnemyBase._ready()` initializes health from `HealthComponent.max_health`. If you override stats AFTER `super._ready()`, health bar shows wrong values.
**How to avoid:** Set stat overrides (patrol_speed, chase_speed, attack_damage, etc.) BEFORE `super._ready()`. Then override health AFTER super (like BossRaccoonKing does).
**Warning signs:** Enemy has wrong HP, wrong damage, or default stats.

### Pitfall 3: One-Time Defeat Not Persisting
**What goes wrong:** Mini-boss respawns after save/load.
**Why it happens:** Forgetting to add mini-boss flags to save data, or not checking flags before spawning triggers.
**How to avoid:** 
1. Add flags to `_get_default_data()` 
2. Gather in `_gather_save_data()` 
3. Apply in `_apply_save_data()` 
4. Check in zone `_setup_zone()` before building triggers
**Warning signs:** Mini-boss appears again after reloading.

### Pitfall 4: Spawned Reinforcements Persisting After Boss Death
**What goes wrong:** Summoned raccoons/crows keep attacking after mini-boss dies.
**Why it happens:** Spawned enemies are independent — killing the boss doesn't clean them up.
**How to avoid:** Track spawned minions in an array. On mini-boss death, queue_free() all tracked minions (or let them fade naturally — they're regular enemies, they'll die on their own). Consider adding a `cleanup_minions()` call in the death handler.
**Warning signs:** Phantom enemies still chasing player after "mini-boss defeated" shows.

### Pitfall 5: Rat King Split Creating Infinite Rats
**What goes wrong:** If split logic triggers multiple times, spawns exponentially.
**Why it happens:** `_on_hurt()` fires on every hit — if the check isn't guarded with a `has_split` flag, it triggers repeatedly.
**How to avoid:** Use a boolean `has_split = false` flag, set to `true` immediately in `_split_into_rats()`, check it before executing split logic.
**Warning signs:** Massive lag, dozens of rats spawning.

### Pitfall 6: Health Bar Conflicts Between Boss and Mini-Boss
**What goes wrong:** Both BossHealthBar and MiniBossHealthBar try to show simultaneously.
**Why it happens:** If boss and mini-boss signals aren't properly separated, or if a mini-boss is fought in the boss arena zone.
**How to avoid:** Use separate signals (`mini_boss_spawned` vs `boss_spawned`). BossHealthBar ignores mini-boss signals and vice versa. OR make BossHealthBar smart enough to switch between targets.
**Warning signs:** Health bar shows wrong name, wrong HP, or flickers between two bosses.

### Pitfall 7: Save Version Migration
**What goes wrong:** Old save files crash or lose data when loading with new save structure.
**Why it happens:** New fields (`mini_bosses_defeated`) don't exist in old save files.
**How to avoid:** Increment `SAVE_VERSION`, add migration logic in `_apply_save_data()`, use `.get()` with defaults for new fields.
**Warning signs:** Save corrupted error on load, or mini-boss flags always `false`.

## 13. Code Examples

### Example: Complete Mini-Boss (Alpha Raccoon)

```gdscript
extends "res://characters/enemies/mini_boss_base.gd"
class_name AlphaRaccoon

const RACCOON_SCENE = preload("res://characters/enemies/raccoon.tscn")

func _ready() -> void:
    # Stats
    patrol_speed = 35.0
    chase_speed = 70.0
    detection_range = 120.0
    attack_range = 30.0
    attack_damage = 20
    attack_cooldown = 1.5
    knockback_force = 100.0
    exp_value = 100
    
    # Mini-boss config
    boss_name = "ALPHA RACCOON"
    is_defeated_key = "alpha_raccoon"
    attack_patterns = ["AlphaSlam", "AlphaSummon"]
    
    super._ready()
    
    # Override health
    if health:
        health.max_health = 120
        health.current_health = 120
    
    # Bigger raccoon
    if sprite:
        sprite.scale = Vector2(1.8, 1.8)
        sprite.color = Color(0.35, 0.3, 0.4)
    
    _setup_alpha_appearance()

func _init_default_drops() -> void:
    drop_table = [
        {"scene": COIN_PICKUP_SCENE, "chance": 1.0, "min": 5, "max": 10},
        {"scene": HEALTH_PICKUP_SCENE, "chance": 1.0, "min": 2, "max": 3},
    ]
```

### Example: AoE Attack State

```gdscript
extends State
class_name AlphaSlam

const TELEGRAPH: float = 0.5
const LEAP: float = 0.3
const IMPACT: float = 0.1
const RECOVERY: float = 0.6
const AOE_RADIUS: float = 40.0

var timer: float = 0.0
enum Phase { TELEGRAPH, LEAP, IMPACT, RECOVERY }
var current_phase: Phase = Phase.TELEGRAPH

func enter() -> void:
    timer = 0.0
    current_phase = Phase.TELEGRAPH
    player.velocity = Vector2.ZERO
    # Warning visual
    if player.sprite:
        player.sprite.modulate = Color(1.3, 0.9, 0.8)

func exit() -> void:
    if player.hitbox:
        player.hitbox.disable()
    if player.sprite:
        player.sprite.modulate = Color.WHITE

func physics_update(delta: float) -> void:
    timer += delta
    match current_phase:
        Phase.TELEGRAPH:
            # Shake sprite
            if player.sprite:
                player.sprite.position.x = randf_range(-2, 2)
            if timer >= TELEGRAPH:
                current_phase = Phase.LEAP
                timer = 0.0
                _start_leap()
        Phase.LEAP:
            if timer >= LEAP:
                current_phase = Phase.IMPACT
                timer = 0.0
                _do_impact()
        Phase.IMPACT:
            if timer >= IMPACT:
                current_phase = Phase.RECOVERY
                timer = 0.0
        Phase.RECOVERY:
            if timer >= RECOVERY:
                state_machine.transition_to("MiniBossIdle")

func _start_leap() -> void:
    if player.sprite:
        player.sprite.position = Vector2.ZERO
        var tween = create_tween()
        tween.tween_property(player.sprite, "position:y", -12.0, LEAP * 0.5)
        tween.tween_property(player.sprite, "position:y", 0.0, LEAP * 0.5)

func _do_impact() -> void:
    EffectsManager.screen_shake(8.0, 0.3)
    # Damage all players in range
    var player_node = player.get_tree().get_first_node_in_group("player")
    if player_node:
        var dist = player.global_position.distance_to(player_node.global_position)
        if dist <= AOE_RADIUS:
            var hc = player_node.get_node_or_null("HealthComponent")
            if hc:
                hc.take_damage(player.attack_damage)
    # Visual shockwave
    _spawn_slam_visual()
```

## 14. State of the Art

| Area | Current Project State | What Phase 20 Adds |
|------|----------------------|-------------------|
| Boss encounters | 1 full boss (Raccoon King) with arena | 3 mini-bosses in open zones |
| Enemy variety | 5 enemy types (raccoon, crow, cat, rat, shadow) | 3 unique mini-boss variants |
| Health bars | Small (enemies), Large (boss) | Mid-size (mini-boss) |
| Save system | Single `boss_defeated` boolean | Dictionary of mini-boss defeat flags |
| Equipment | 15 items, all from shop/starting | 3 rare items as mini-boss loot |
| Zone content | Enemies + hazards + boss door | + mini-boss trigger areas |

## Open Questions

1. **Mini-boss music?** Should mini-boss encounters play boss_fight music, a lighter variant, or keep zone music? The boss arena plays `boss_fight` via `AudioManager.play_music("boss_fight")`. Recommendation: play boss_fight_b (second boss track exists) during mini-boss fights, revert to zone music on defeat.

2. **Respawn behavior:** Mini-bosses are one-time defeats per save. But what about within a single play session before saving? If player enters the trigger zone, fights the mini-boss, dies, and respawns — should the mini-boss reappear? Recommendation: mini-boss spawns once per zone load. If player dies and respawns in the same zone, the mini-boss doesn't re-trigger until zone is re-entered.

3. **Equipment notification UI:** When rare equipment is granted, how is the player notified? Options: floating text popup (like EXP), or a brief modal. Recommendation: floating text popup with equipment name and brief stat summary (reuse EffectsManager text pattern).

## Sources

### Primary (HIGH confidence)
All findings derived from direct codebase analysis:
- `characters/enemies/enemy_base.gd` — enemy extension pattern, drops, health bar
- `characters/enemies/boss_raccoon_king.gd` — boss pattern, attack cycling, enrage
- `characters/enemies/states/boss_*.gd` — boss attack state architecture
- `characters/enemies/sewer_rat.gd`, `shadow_creature.gd`, `stray_cat.gd`, `crow.gd` — enemy extension examples
- `characters/enemies/states/rat_*.gd` — swarm/poison patterns
- `components/health/health_component.gd` — poison DoT system
- `components/hazards/toxic_puddle.gd` — AoE hazard pattern
- `components/projectile/shadow_bolt.gd` — projectile pattern
- `components/hitbox/hitbox.gd`, `components/hurtbox/hurtbox.gd` — damage system
- `components/state_machine/state.gd`, `state_machine.gd` — state architecture
- `ui/hud/boss_health_bar.gd` + `.tscn` — boss health bar implementation
- `autoloads/save_manager.gd` — save system structure
- `autoloads/game_manager.gd` — game state, zone transitions, boss tracking
- `autoloads/events.gd` — signal definitions
- `autoloads/effects_manager.gd` — VFX patterns, boss intro/victory
- `systems/equipment/equipment_database.gd` — equipment data format
- `systems/equipment/equipment_manager.gd` — equipment inventory/equipping
- `world/zones/base_zone.gd` — zone structure, enemy placement, respawn system
- `world/zones/neighborhood.gd`, `backyard.gd`, `sewers.gd` — zone-specific setup
- `world/zones/boss_arena.gd` — boss arena pattern

### No External Sources Needed
This phase is entirely internal — no new libraries, frameworks, or Godot features beyond what's already used.

## Metadata

**Confidence breakdown:**
- Standard stack: **HIGH** — all components exist and are verified in codebase
- Architecture: **HIGH** — follows established patterns (EnemyBase extension, state machine, signal bus)
- Attack patterns: **HIGH** — based on existing BossAttackSwipe/Charge/Summon + ToxicPuddle
- Save integration: **HIGH** — direct extension of existing SaveManager pattern
- Pitfalls: **HIGH** — identified from actual code analysis (state variable naming, _ready() order, save version)

**Research date:** 2026-01-28
**Valid until:** Indefinite (codebase-specific research, no external dependency freshness concerns)
