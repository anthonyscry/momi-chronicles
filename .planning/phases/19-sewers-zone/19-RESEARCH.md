# Phase 19: The Sewers Zone - Research

**Researched:** 2026-01-28
**Domain:** Godot 4.5 zone construction, 2D lighting/darkness, environmental hazards, dungeon level design
**Confidence:** HIGH

## Summary

This phase creates a new dungeon zone (sewers) accessible from the Neighborhood via a manhole cover. The research focused on five domains: (1) how the existing zone system works and how to extend it for the sewers, (2) how to implement darkness/limited visibility using Godot's 2D lighting system, (3) how to create environmental hazard areas (toxic puddles) reusing the existing poison DoT system, (4) how to add a new ambient particle style for sewer atmosphere, and (5) how to integrate zone transitions (manhole entry in Neighborhood + exit back).

The codebase has an extremely well-established zone pattern: BaseZone handles camera limits, enemy spawn capture, respawn, companion spawning, and grass. Zone scripts (`neighborhood.gd`, `backyard.gd`) extend BaseZone with spawn_points dictionaries and `_setup_zone()` overrides. Zone scenes (`.tscn`) are self-contained with Player, Enemies container, ZoneExits, UI nodes, and visual elements built from ColorRect/StaticBody2D/Polygon2D primitives (no imported art assets). The sewers zone follows this exact pattern but with dark blue-purple palette, CanvasModulate darkness + PointLight2D on player, and toxic puddle Area2D hazards.

**Primary recommendation:** Follow the existing zone architecture exactly (BaseZone extension, .tscn with all visuals as ColorRect/Polygon2D nodes, ZoneExit components for transitions, enemy instances in Enemies container). Add darkness via CanvasModulate + PointLight2D on player. Add toxic puddles as Area2D nodes that call the existing `HealthComponent.apply_poison()`. Add a new SEWER_DRIPS ambient particle style. Zone size ~1152x648 (3x backyard's 384x216).

## Standard Stack

This phase uses **zero external libraries** — everything is built with Godot 4.5 built-in nodes and the project's existing component architecture.

### Core (Existing Systems to Reuse)
| System | Location | Purpose | How It's Used |
|--------|----------|---------|---------------|
| BaseZone | `world/zones/base_zone.gd` | Zone base class | Extend for sewers_zone.gd — handles camera, respawn, companions, grass |
| ZoneExit | `components/zone_exit/zone_exit.gd` | Zone transitions | Two instances: one in Neighborhood (manhole→sewers), one in Sewers (exit→neighborhood) |
| HealthComponent.apply_poison() | `components/health/health_component.gd` | Poison DoT | Toxic puddles call this on player contact — exact same system sewer rats use |
| AmbientParticles | `components/effects/ambient_particles.gd` | Zone atmosphere | Add new SEWER_DRIPS style (dripping water particles, slow downward drift) |
| GameManager.zone_scenes | `autoloads/game_manager.gd` | Zone registry | Add "sewers" entry pointing to sewers.tscn |
| AudioManager._get_zone_track() | `autoloads/audio_manager.gd` | Zone music | Add "sewers" case returning sewer ambient music track |
| EffectsManager._on_zone_entered_particles() | `autoloads/effects_manager.gd` | Auto-particle spawn | AmbientParticles.set_style_for_zone() needs "sewers" case |

### New Components to Build
| Component | Purpose | Complexity |
|-----------|---------|------------|
| ToxicPuddle (Area2D) | Environmental hazard — applies poison DoT on overlap | Low — reuses HealthComponent.apply_poison() |
| SewerDarknessManager (Node2D) | CanvasModulate + PointLight2D on player for dark areas | Low — 2 built-in Godot nodes |
| ManholeInteractable (Area2D) | Manhole cover in Neighborhood — press E to enter sewers | Low — follows ShopNPC/ZoneExit pattern |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| CanvasModulate + PointLight2D | Shader-based darkness (canvas_item shader) | Shaders are more flexible but project avoids shaders — use built-in 2D lighting |
| Static toxic puddle positions | Procedural puddle generation | Static is simpler, more controllable, fits hand-crafted dungeon design |
| TileMap-based level | ColorRect/Polygon2D programmatic layout | Project pattern is programmatic visuals — no TileMaps used for visuals in existing zones |

## Architecture Patterns

### Recommended Project Structure
```
world/zones/
├── sewers.gd              # Extends BaseZone — zone script
├── sewers.tscn            # Zone scene (all nodes)
components/hazards/
├── toxic_puddle.gd        # Area2D environmental hazard
├── toxic_puddle.tscn      # Toxic puddle scene
```

### Pattern 1: Zone Script Structure (Follow Existing Pattern)
**What:** Every zone extends BaseZone with spawn_points dict and _setup_zone() override
**When to use:** Always — this is the established pattern
**Example:**
```gdscript
# Source: Verified from neighborhood.gd and backyard.gd in codebase
extends BaseZone

var spawn_points: Dictionary = {
    "default": Vector2(60, 324),           # Manhole entrance position
    "from_neighborhood": Vector2(60, 324), # Coming from neighborhood
}

func _setup_zone() -> void:
    zone_id = "sewers"
    
    var pending_spawn = GameManager.get_pending_spawn()
    if not pending_spawn.is_empty() and spawn_points.has(pending_spawn):
        spawn_player_at(spawn_points[pending_spawn])
    elif spawn_points.has("default"):
        spawn_player_at(spawn_points["default"])
```

### Pattern 2: CanvasModulate + PointLight2D for Darkness
**What:** CanvasModulate darkens entire scene to near-black; PointLight2D on player provides a light radius revealing nearby area
**When to use:** Dark areas — the standard Godot 2D approach for limited visibility
**Example:**
```gdscript
# Source: Godot 4.5 official docs + community best practices (verified via Context7 + web search)
# CanvasModulate as child of zone root — darkens everything
var darkness = CanvasModulate.new()
darkness.color = Color(0.08, 0.06, 0.12)  # Very dark blue-purple

# PointLight2D as child of Player — illuminates around player
var player_light = PointLight2D.new()
player_light.texture = # radial gradient texture (created programmatically or preloaded)
player_light.texture_scale = 3.0  # ~48px radius light
player_light.energy = 1.2
player_light.color = Color(0.7, 0.75, 0.9)  # Cool blue-white
```

**Critical detail:** PointLight2D requires a texture to function. Use a preloaded radial gradient texture (white center → transparent edge). This can be created as a GradientTexture2D resource or a simple white circle PNG.

### Pattern 3: Toxic Puddle as Area2D (Reuse Poison DoT)
**What:** Area2D that detects player, applies poison via existing HealthComponent.apply_poison()
**When to use:** Environmental hazards
**Example:**
```gdscript
# Source: Matches rat_poison_attack.gd pattern for applying poison
extends Area2D
class_name ToxicPuddle

@export var poison_damage: int = 2
@export var poison_duration: float = 3.0
@export var reapply_interval: float = 1.5  # Re-poison if still standing in it
@export var is_camouflaged: bool = false    # Obvious vs hidden puddle

var _reapply_timer: float = 0.0
var _player_in_puddle: bool = false

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2  # Player layer
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_puddle = true
        _apply_poison(body)

func _apply_poison(body: Node2D) -> void:
    var health_comp = body.get_node_or_null("HealthComponent")
    if health_comp and health_comp.has_method("apply_poison"):
        health_comp.apply_poison(poison_damage, poison_duration)
```

### Pattern 4: Zone Exit with require_interaction (Manhole Cover)
**What:** ZoneExit with `require_interaction = true` — player presses E to enter
**When to use:** The manhole cover entrance in Neighborhood
**Example:**
```gdscript
# Source: zone_exit.gd already supports require_interaction
# In neighborhood.tscn, add a ZoneExit instance:
# position = Vector2(300, 350)  # Wherever the manhole goes
# exit_id = "to_sewers"
# target_zone = "sewers"
# target_spawn = "from_neighborhood"
# require_interaction = true
```

### Pattern 5: Scene File (.tscn) Structure
**What:** All zone visuals are built from ColorRect, Polygon2D, StaticBody2D nodes — no imported art
**When to use:** Always — this is the project's established programmatic visual style
**Example structure for sewers.tscn:**
```
Sewers (Node2D) [script: sewers.gd]
├── Background (ColorRect)              # Dark blue-purple base
├── Darkness (CanvasModulate)           # Near-black modulation
├── Corridors (Node2D)                  # ColorRect floor tiles
│   ├── MainCorridor1 (ColorRect)
│   ├── MainCorridor2 (ColorRect)
│   └── ...
├── Walls (Node2D)                      # StaticBody2D + ColorRect for walls
│   ├── Wall1 (StaticBody2D)
│   └── ...
├── WaterChannels (Node2D)              # Flowing water ColorRects
├── SideRooms (Node2D)                  # Alcoves/chambers
├── Hazards (Node2D)                    # Toxic puddles
│   ├── ToxicPuddle1 (instance)
│   └── ...
├── Decorations (Node2D)                # Pipes, grates, bones, etc.
├── Boundaries (StaticBody2D)           # Invisible zone boundary walls
├── Player (instance)
├── Enemies (Node2D)                    # Enemy instances
├── ZoneExits (Node2D)
│   ├── ToNeighborhood (ZoneExit)       # Exit back
│   └── ToBossRoom (ZoneExit)           # Locked door to Phase 20
├── PreBossArea (Node2D)                # Warning signs, health pickup
└── UI (Node)
    ├── GameHUD
    ├── PauseMenu
    └── GameOver
```

### Anti-Patterns to Avoid
- **Don't use TileMap for level layout:** Existing zones use ColorRect/StaticBody2D nodes — maintain consistency
- **Don't create a new poison system:** The existing `HealthComponent.apply_poison()` is exactly what toxic puddles need
- **Don't use shaders for darkness:** CanvasModulate + PointLight2D is the standard Godot approach and matches the project's no-shader philosophy
- **Don't make the zone procedurally generated:** This is a hand-crafted dungeon with specific layout decisions from CONTEXT.md
- **Don't forget to override `_spawn_grass()`:** Sewers shouldn't have grass — override to spawn nothing or spawn moss/fungi instead
- **Don't forget to register zone in GameManager:** `zone_scenes` dict needs the "sewers" entry or transitions will fail

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Poison damage-over-time | Custom DoT timer system | `HealthComponent.apply_poison(damage, duration)` | Already handles ticking, visual tint, cleanup, signals |
| Zone transitions | Custom scene loading | `Events.zone_transition_requested.emit()` + GameManager | Handles fade, scene loading, spawn points, auto-save |
| Enemy respawning | Custom respawn logic | BaseZone's built-in respawn system | Already captures spawn data, timers, off-camera checks |
| Camera limits | Manual camera clamping | `BaseZone._setup_camera()` via `zone_size` export | Automatic from BaseZone |
| Ambient particles | Custom particle spawning | Extend AmbientParticles with new style | Auto-spawned by EffectsManager on zone entry |
| Player detection | Custom raycasting | `Area2D.collision_mask = 2` (Player layer) | Standard project pattern for ZoneExit, ShopNPC, etc. |
| Audio for zone | Custom audio handling | AudioManager._get_zone_track() + zone_entered signal | Automatic music switching on zone entry |

**Key insight:** The project has excellent infrastructure for zones. The sewers zone is 90% reuse of existing patterns — the only genuinely new things are the toxic puddle component, the darkness system (CanvasModulate + PointLight2D), the sewer ambient particle style, and the physical layout itself.

## Common Pitfalls

### Pitfall 1: PointLight2D Without Texture
**What goes wrong:** PointLight2D is added but nothing visible happens — area stays dark
**Why it happens:** Unlike 3D lights, PointLight2D in Godot requires a texture (a radial gradient image). Without it, no light is emitted.
**How to avoid:** Create or preload a radial gradient texture (white center → transparent edges). Can use GradientTexture2D with RadialGradient or a simple white circle PNG.
**Warning signs:** CanvasModulate makes everything dark but player light doesn't show up.

### Pitfall 2: Forgetting GameManager Zone Registration
**What goes wrong:** Zone transition crashes with "Unknown zone: sewers"
**Why it happens:** `GameManager.zone_scenes` dictionary doesn't have the "sewers" entry
**How to avoid:** Add `"sewers": "res://world/zones/sewers.tscn"` to GameManager.zone_scenes in `_ready()` or as initialization
**Warning signs:** Zone transition requested but nothing happens or error in console.

### Pitfall 3: Zone Size Mismatch with Layout
**What goes wrong:** Camera shows areas beyond the zone boundary; enemies spawn outside walkable area
**Why it happens:** `zone_size` export doesn't match the actual visual/physics layout
**How to avoid:** Set `zone_size` to exactly match the zone's total dimensions. Backyard is 384x216 (1 viewport). Sewers should be ~1152x648 (3x backyard = roughly 3 viewports wide, 3 tall) to achieve 5-7 min exploration time.
**Warning signs:** Camera pans past the edge of the visible zone into empty space.

### Pitfall 4: Toxic Puddle Poison Stacking
**What goes wrong:** Standing in a toxic puddle keeps refreshing poison infinitely, or multiple puddles cause stacking damage
**Why it happens:** `apply_poison()` refreshes duration — if called every frame, poison never wears off
**How to avoid:** Use a reapply timer (e.g., every 1.5s while standing in puddle). The HealthComponent already refreshes duration on re-apply, so multiple puddles just reset the timer — no stacking issue.
**Warning signs:** Player takes way too much damage from puddles or poison never ends.

### Pitfall 5: Grass Spawning in Sewers
**What goes wrong:** BaseZone._spawn_grass() adds grass tufts inside sewer corridors
**Why it happens:** BaseZone automatically calls `_spawn_grass()` for all zones
**How to avoid:** Override `_spawn_grass()` in sewers.gd to do nothing, or spawn sewer-themed decorations instead (e.g., moss patches, small mushrooms)
**Warning signs:** Green grass appearing on dark sewer floor.

### Pitfall 6: Companion AI in Tight Corridors
**What goes wrong:** Companions get stuck on walls in 3-4 tile wide corridors
**Why it happens:** BaseZone spawns all 3 companions who follow player via AI — tight corridors may cause navigation issues
**How to avoid:** Test companion following in narrow corridors. Companions use simple follow AI (move toward player position) with separation forces, not navigation agents, so they should handle corridors okay. May need to tune companion offsets for the sewers. If stuck, reduce companion spawn offsets.
**Warning signs:** Companions clumping at corridor corners or getting permanently stuck behind walls.

### Pitfall 7: Dark Areas Making Game Unplayable
**What goes wrong:** Player can't see enemies or puddles, gameplay becomes frustrating
**Why it happens:** CanvasModulate too dark, PointLight2D radius too small
**How to avoid:** Balance darkness level — player should see ~2-3 tiles ahead. Enemies/hazards within light radius should be clearly visible. Obvious toxic puddles should glow (bright green) to be visible even in dim areas. Light radius of ~60-80px at viewport scale.
**Warning signs:** Playtesting shows constantly walking into hazards blindly.

### Pitfall 8: AudioManager Missing Sewer Zone Match
**What goes wrong:** Wrong music plays in sewers (defaults to neighborhood music)
**Why it happens:** `_get_zone_track()` match statement doesn't have "sewers" case, falls to default
**How to avoid:** Add "sewers" case to `AudioManager._get_zone_track()` AND `_on_zone_entered()`. Also add a sewer music track to `music_tracks` dict.
**Warning signs:** Neighborhood music playing while exploring dark sewers.

## Code Examples

### Example 1: Complete Sewers Zone Script
```gdscript
# Source: Modeled on neighborhood.gd and backyard.gd patterns (verified in codebase)
extends BaseZone

var spawn_points: Dictionary = {
    "default": Vector2(60, 324),
    "from_neighborhood": Vector2(60, 324),
}

func _setup_zone() -> void:
    zone_id = "sewers"
    
    var pending_spawn = GameManager.get_pending_spawn()
    if not pending_spawn.is_empty() and spawn_points.has(pending_spawn):
        spawn_player_at(spawn_points[pending_spawn])
    elif spawn_points.has("default"):
        spawn_player_at(spawn_points["default"])
    
    # Attach PointLight2D to player for dark area visibility
    _setup_player_light()

func _setup_player_light() -> void:
    if not player:
        return
    var light = PointLight2D.new()
    light.name = "SewerLight"
    light.texture = preload("res://assets/textures/light_gradient.tres")
    light.texture_scale = 3.5
    light.energy = 1.2
    light.color = Color(0.7, 0.75, 0.9)
    player.add_child(light)

## Override: No grass in sewers
func _spawn_grass() -> void:
    pass  # Sewers don't have grass
```

### Example 2: Toxic Puddle Component
```gdscript
# Source: Follows Area2D + collision_mask=2 pattern from ZoneExit/ShopNPC
extends Area2D
class_name ToxicPuddle

@export var poison_damage: int = 2
@export var poison_duration: float = 3.0
@export var reapply_interval: float = 1.5
@export var is_camouflaged: bool = false
@export var puddle_size: Vector2 = Vector2(24, 16)

var _reapply_timer: float = 0.0
var _player_in_puddle: bool = false

func _ready() -> void:
    collision_layer = 0
    collision_mask = 2  # Player layer
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    _setup_visuals()

func _setup_visuals() -> void:
    # Collision shape
    var shape = CollisionShape2D.new()
    var rect = RectangleShape2D.new()
    rect.size = puddle_size
    shape.shape = rect
    add_child(shape)
    
    # Visual - bright green (obvious) or dark green (camouflaged)
    var visual = ColorRect.new()
    visual.size = puddle_size
    visual.position = -puddle_size / 2
    if is_camouflaged:
        visual.color = Color(0.15, 0.25, 0.12, 0.4)  # Subtle dark
    else:
        visual.color = Color(0.3, 0.8, 0.2, 0.6)  # Bright green glow
    add_child(visual)

func _process(delta: float) -> void:
    if _player_in_puddle:
        _reapply_timer += delta
        if _reapply_timer >= reapply_interval:
            _reapply_timer = 0.0
            var player_node = get_tree().get_first_node_in_group("player")
            if player_node:
                _apply_poison(player_node)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_puddle = true
        _reapply_timer = 0.0
        _apply_poison(body)

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_puddle = false

func _apply_poison(body: Node2D) -> void:
    var health_comp = body.get_node_or_null("HealthComponent")
    if health_comp and health_comp.has_method("apply_poison"):
        health_comp.apply_poison(poison_damage, poison_duration)
```

### Example 3: New Sewer Drip Ambient Particle Style
```gdscript
# Source: Follows existing AmbientParticles patterns (DUST_MOTES, LEAVES, FIREFLIES)
# Add to ambient_particles.gd ParticleStyle enum: SEWER_DRIPS

func _spawn_sewer_drip(center: Vector2) -> void:
    var drip = ColorRect.new()
    drip.size = Vector2(2, 3)
    drip.color = Color(0.3, 0.4, 0.5, randf_range(0.2, 0.5))  # Blue-grey water
    drip.z_index = 45
    
    # Spawn above viewport at random x
    var x_pos = center.x + randf_range(-viewport_size.x / 2, viewport_size.x / 2)
    drip.global_position = Vector2(x_pos, center.y - viewport_size.y / 2 - 5)
    get_tree().current_scene.add_child(drip)
    _active_particles.append(drip)
    
    # Fall straight down (dripping water)
    var fall_time = randf_range(1.0, 2.0)
    var fall_y = viewport_size.y + 10
    
    var tween = create_tween()
    tween.tween_property(drip, "global_position:y", drip.global_position.y + fall_y, fall_time)
    tween.parallel().tween_property(drip, "modulate:a", 0.0, fall_time * 0.3).set_delay(fall_time * 0.7)
    tween.tween_callback(func():
        _active_particles.erase(drip)
        drip.queue_free()
    )
```

### Example 4: GameManager Registration
```gdscript
# Source: Existing GameManager.zone_scenes pattern
# Add to game_manager.gd zone_scenes dictionary:
"sewers": "res://world/zones/sewers.tscn"
```

### Example 5: AudioManager Sewer Zone Case
```gdscript
# Source: Existing AudioManager._get_zone_track() pattern
# Add to _get_zone_track() match:
"sewers":
    return "sewers"

# Add to _on_zone_entered() match:
"sewers":
    zone_base_track = "sewers"

# Add to music_tracks dictionary:
"sewers": "res://assets/audio/music/sewers.wav"
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Godot 3 Light2D | Godot 4 PointLight2D + CanvasModulate | Godot 4.0 | Light2D split into PointLight2D and DirectionalLight2D in Godot 4 |
| TileMap (single node) | TileMapLayer (separate layers) | Godot 4.3 | This project uses ColorRect visuals instead — not affected |

**Not deprecated but relevant:**
- CanvasModulate: Still the standard way to darken a 2D scene in Godot 4.5. One per scene only — multiple CanvasModulate nodes override each other.
- PointLight2D still requires a texture — this hasn't changed and won't.

## Open Questions

1. **PointLight2D Texture Creation**
   - What we know: PointLight2D requires a texture (radial gradient). Can be a GradientTexture2D or PNG.
   - What's unclear: Best approach for programmatic texture creation vs preloaded asset. The project avoids imported assets but GradientTexture2D can be created as a .tres resource file.
   - Recommendation: Create a `light_gradient.tres` (GradientTexture2D with radial type) — this is a resource file, not an imported image, which fits the project pattern. Alternatively, create it programmatically in code.

2. **Exact Zone Dimensions for 5-7 Minute Exploration**
   - What we know: Backyard is 384x216 (one viewport). Sewers should be 3x larger. At 80 px/s walk speed, crossing 384px takes ~5 seconds.
   - What's unclear: Whether 1152x648 (3x area) is sufficient for 5-7 min with side rooms and enemy encounters slowing progress.
   - Recommendation: Start with ~1152x648 and test. The corridors, enemies, and side rooms add significant exploration time beyond raw traversal. Can adjust during implementation.

3. **Pre-Boss Door Mechanics**
   - What we know: Phase 20 builds the Rat King boss. Phase 19 needs a door/gate that leads to the boss room.
   - What's unclear: Should the boss door be a locked ZoneExit (opens in Phase 20) or an always-present but empty room?
   - Recommendation: Place a ZoneExit node pointing to `boss_arena_sewers` (target zone for Phase 20), but with `require_interaction = true` and potentially disabled until Phase 20 is implemented. Alternatively, just have a visual door that can't be opened yet — Phase 20 will implement the transition.

4. **Side Room Ambush Trigger**
   - What we know: Some side rooms should spawn enemies when player enters ("walked into their nest")
   - What's unclear: Whether to pre-place hidden enemies or dynamically spawn them on trigger
   - Recommendation: Pre-place enemies in side rooms but start them in "Idle" state with small detection range. When player enters the room's Area2D trigger, the enemies' detection area gets enlarged or they directly transition to chase. This avoids dynamic spawning complexity while achieving the "ambush" feel.

## Sources

### Primary (HIGH confidence)
- Codebase analysis: `base_zone.gd`, `neighborhood.gd`, `backyard.gd`, `boss_arena.gd` — zone architecture patterns
- Codebase analysis: `neighborhood.tscn`, `backyard.tscn` — scene file structure, visual construction patterns
- Codebase analysis: `health_component.gd` — poison DoT system (`apply_poison`, `clear_poison`)
- Codebase analysis: `zone_exit.gd` — zone transition mechanics, `require_interaction` support
- Codebase analysis: `ambient_particles.gd` — particle style system, `set_style_for_zone()`
- Codebase analysis: `game_manager.gd` — zone scene registry, transition flow
- Codebase analysis: `audio_manager.gd` — zone music system, track registry
- Codebase analysis: `effects_manager.gd` — auto-particle spawning on zone entry
- Codebase analysis: `sewer_rat.gd`, `shadow_creature.gd`, `enemy_base.gd` — enemy patterns
- Codebase analysis: `events.gd` — signal bus (zone_entered, zone_transition_requested)
- Context7: Godot 4.5 PointLight2D documentation — texture requirement, energy, color properties
- Context7: Godot 4.5 2D lighting system — CanvasModulate + Light2D blend modes

### Secondary (MEDIUM confidence)
- Web search: "Godot 4 CanvasModulate PointLight2D dark dungeon" — multiple community sources confirm CanvasModulate + PointLight2D as standard approach
- Medium article (Jan 2025): "Mastering 2D Lighting" — confirms CanvasModulate for ambient darkness
- Godot Forum (Jul 2024, Sep 2024): Multiple threads confirming CanvasModulate + PointLight2D pattern

### Tertiary (LOW confidence)
- None — all findings were verified with codebase or official docs

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — 100% based on codebase analysis of existing zone patterns
- Architecture: HIGH — follows exact patterns from neighborhood/backyard/boss_arena zones
- Darkness system: HIGH — CanvasModulate + PointLight2D verified via Godot official docs and multiple community sources
- Toxic puddles: HIGH — directly reuses existing HealthComponent.apply_poison() system
- Ambient particles: HIGH — extends existing AmbientParticles with proven pattern
- Zone size/timing: MEDIUM — 3x backyard is estimated, needs playtesting
- Pre-boss area: MEDIUM — mechanics depend on Phase 20 decisions

**Research date:** 2026-01-28
**Valid until:** 2026-02-28 (stable — Godot 4.5 APIs, no fast-moving dependencies)
