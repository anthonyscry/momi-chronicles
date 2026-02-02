---
phase: 36-rooftops
plan: 01
type: execute
wave: 1
depends_on: ["35-01"]
files_created:
  - characters/enemies/pigeon.tscn
  - characters/enemies/pigeon.gd
  - characters/enemies/states/pigeon_flock_idle.gd
  - characters/enemies/states/pigeon_flock_chase.gd
  - characters/enemies/states/pigeon_swoop_attack.gd
  - characters/enemies/states/pigeon_hurt.gd
  - characters/enemies/states/pigeon_death.gd
  - art/generated/enemies/pigeon_idle.png
  - art/generated/enemies/pigeon_fly.png
  - art/generated/enemies/pigeon_swoop.png
  - art/generated/enemies/pigeon_hurt.png
  - art/generated/enemies/pigeon_death.png
files_modified:
  - project.godot
  - autoloads/events.gd
  - characters/enemies/enemy_base.gd
autonomous: true

must_haves:
  truths:
    - "Pigeons spawn in groups of 3-6 (flock behavior)"
    - "Pigeons detect player from rooftops and swoop attack"
    - "Flock coordinates attacks - lead pigeon triggers, others follow with delay"
    - "Pigeons flee when HP drops below 30% (group retreat)"
    - "Pigeon hurt animation causes brief pause but no state interruption"
  artifacts:
    - path: "characters/enemies/pigeon.tscn"
      provides: "Pigeon enemy with flock behavior, hitbox, hurtbox, detection area"
      contains: "CharacterBody2D, AnimatedSprite2D, CollisionShape2D, Area2D"
    - path: "characters/enemies/states/pigeon_flock_chase.gd"
      provides: "Coordinated flock movement toward player"
      contains: "FlockManager integration, formation flying, attack coordination"
    - path: "characters/enemies/states/pigeon_swoop_attack.gd"
      provides: "Aerial swoop attack with damage"
      contains: "Velocity-based movement, hitbox activation, return to perch"
  key_links:
    - from: "pigeon.tscn"
      to: "world/rooftop_spawners"
      via: "Spawner spawns pigeon group on trigger"
    - from: "FlockManager"
      to: "pigeon_swoop_attack"
      via: "Assigns swoop timing to each pigeon"
    - from: "pigeon_hurt.gd"
      to: "FlockManager"
      via: "Reports damage, may trigger group flee"

<objective>
Create a Pigeon enemy that spawns in flocks (3-6 units) and coordinates aerial swoop attacks from rooftops. Pigeons are weak individually but dangerous in groups, with coordinated attack patterns and group flee behavior when threatened.

Purpose: Pigeons provide rooftop harassment encounters, teaching players to deal with multiple aerial threats. Their flock mechanics introduce coordination patterns that scale to future boss encounters.
Output: Fully functional flock-based pigeon enemy with swoop attack, coordinated group behavior, and HP-based retreat.
</objective>

<execution_context>
@~/.config/opencode/get-shit-done/workflows/execute-plan.md
@~/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@docs/ROADMAP.md
@docs/STATE.md
@characters/enemies/enemy_base.gd
@characters/enemies/raccoon.tscn
@characters/enemies/crow.tscn
@characters/enemies/states/enemy_chase.gd
@characters/enemies/states/enemy_hurt.gd
@characters/enemies/states/enemy_death.gd
@autoloads/events.gd
@world/rooftop_spawners.gd
</context>

<tasks>

<task type="auto">
  <name>Task 1: Define Pigeon enemy stats and constants</name>
  <files>
    characters/enemies/pigeon.gd
  </files>
  <action>
  **Create pigeon.gd with stats:**

  ```gdscript
  extends "res://characters/enemies/enemy_base.gd"

  class_name Pigeon

  const GROUP_SIZE_MIN: int = 3
  const GROUP_SIZE_MAX: int = 6
  const FLEE_HP_THRESHOLD: float = 0.3
  const SWOOP_DAMAGE: float = 15.0
  const SWOOP_COOLDOWN: float = 2.5
  const SWOOP_DELAY_BETWEEN_PIGEONS: float = 0.3
  const DETECTION_RANGE: float = 256.0
  const ATTACK_RANGE: float = 180.0
  const FLY_SPEED: float = 120.0
  const FLEE_SPEED: float = 180.0
  const PERCH_HEIGHT: float = 48.0

  var flock_id: int = 0
  var flock_position: int = 0
  var is_lead_pigeon: bool = false
  var can_swoop: bool = true
  var is_fleeing: bool = false
  var perch_position: Vector2 = Vector2.ZERO

  func _ready() -> void:
      health = HealthComponent.new(30, 30)
      hitbox = HitboxComponent.new()
      hitbox.damage = SWOOP_DAMAGE
      hurtbox = HurtboxComponent.new()
      hurtbox.layer = 5
      add_child(hitbox)
      add_child(hurtbox)
      health.health_changed.connect(_on_health_changed)
      _setup_detection_area()
  ```

  **Stats Summary:**
  - HP: 30 (weak individually)
  - Damage: 15 (swoop attack)
  - Speed: 120 fly, 180 flee
  - Detection Range: 256 pixels
  - Attack Range: 180 pixels (aerial)
  - Flee Threshold: 30% HP
  - Group Size: 3-6 pigeons
  - Swoop Delay: 0.3s between pigeons
  </action>
  <verify>
  - pigeon.gd has all const declarations
  - Stats match requirements (30 HP, 15 damage, 256 detection)
  - Signals connected for health changes
  </verify>
  <done>pigeon.gd created with all stats, constants, and signal connections</done>
</task>

<task type="auto">
  <name>Task 2: Create pigeon.tscn scene</name>
  <files>
    characters/enemies/pigeon.tscn
  </files>
  <action>
  **Scene structure:**

  ```
  Pigeon (CharacterBody2D)
  ├── Sprite2D (AnimatedSprite2D)
  │   └── SpriteFrames: idle, fly, swoop, hurt, death
  ├── CollisionShape2D (Circle, radius 8)
  ├── DetectionArea (Area2D)
  │   └── CollisionShape2D (Circle, radius 256)
  ├── Hurtbox (Area2D)
  │   └── CollisionShape2D (Circle, radius 12)
  ├── Hitbox (Area2D) - active during swoop
  │   └── CollisionShape2D (Capsule, size 24x8)
  ├── StateMachine (Node)
  │   ├── FlockIdle
  │   ├── FlockChase
  │   ├── SwoopAttack
  │   ├── Hurt
  │   └── Death
  └── HealthComponent (Node)
  ```

  **SpriteFrames configuration:**
  - idle: 4 frames, 0.2s each, stationary on perch
  - fly: 4 frames, 0.15s each, wings flapping
  - swoop: 6 frames, 0.1s each, diving toward ground
  - hurt: 3 frames, 0.15s each, recoil animation
  - death: 4 frames, 0.2s each, fall and disappear

  **Collision layers:**
  - Layer 3: Enemy body
  - Layer 5: Enemy hurtbox
  - Layer 7: Enemy hitbox (swoop only)
  </action>
  <verify>
  - Scene has all required nodes
  - SpriteFrames has all 5 animations
  - DetectionArea matches DETECTION_RANGE (256px)
  - Hitbox only active during swoop state
  </verify>
  <done>pigeon.tscn scene created with all nodes and SpriteFrames</done>
</task>

<task type="auto">
  <name>Task 3: Create FlockIdle state</name>
  <files>
    characters/enemies/states/pigeon_flock_idle.gd
  </files>
  <action>
  **pigeon_flock_idle.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_idle.gd"

  var flock_members: Array = []
  var perch_target: Vector2 = Vector2.ZERO
  var formation_offset: Vector2 = Vector2.ZERO
  var hover_time: float = 0.0
  var HOVER_DURATION: float = 1.5

  func enter() -> void:
      player.is_fleeing = false
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("idle")
      
      _find_perch_position()
      _setup_formation_offset()
      
      if player.is_lead_pigeon:
          Events.pigeon_entered_idle.emit(player.flock_id)

  func _find_perch_position() -> void:
      if player.is_lead_pigeon:
          player.perch_position = player.global_position
      else:
          var lead = _get_flock_lead()
          if lead and is_instance_valid(lead):
              player.perch_position = lead.perch_position + formation_offset

  func _setup_formation_offset() -> void:
      if not player.is_lead_pigeon:
          var lead = _get_flock_lead()
          if lead and is_instance_valid(lead):
              var angle = player.flock_position * PI * 2 / (flock_members.size() - 1)
              var radius = 32.0 if player.flock_position > 0 else 0.0
              formation_offset = Vector2(cos(angle), sin(angle)) * radius
          else:
              formation_offset = Vector2(randf_range(-24, 24), randf_range(-16, 16))

  func _get_flock_lead() -> Node:
      for member in flock_members:
          if member.is_lead_pigeon:
              return member
      return null

  func update(delta: float) -> void:
      hover_time += delta
      
      if hover_time >= HOVER_DURATION:
          hover_time = 0.0
          _check_for_player()
      
      if player.is_fleeing:
          state_machine.transition_to("FlockChase")
          return

      if player.sprite:
          player.sprite.position.y = sin(Time.get_ticks_msec() * 0.005) * 2

  func _check_for_player() -> void:
      var player_node = get_tree().get_first_node_in_group("player")
      if player_node:
          var dist = player.global_position.distance_to(player_node.global_position)
          if dist < player.DETECTION_RANGE:
              if player.is_lead_pigeon:
                  Events.pigeon_detected_player.emit(player.flock_id, player_node.global_position)
              state_machine.transition_to("FlockChase")

  func exit() -> void:
      hover_time = 0.0
  ```

  **Behavior:**
  - Pigeons hover on perch positions in formation
  - Lead pigeon monitors for player
  - All pigeons flee if any member takes damage
  - Hover bobbing animation for visual interest
  </action>
  <verify>
  - State has enter/update/exit functions
  - Formation offset calculated correctly
  - Lead pigeon emits detection signal
  - Flee check in update()
  </verify>
  <done>FlockIdle state created with formation flying and detection</done>
</task>

<task type="auto">
  <name>Task 4: Create FlockChase state</name>
  <files>
    characters/enemies/states/pigeon_flock_chase.gd
  </files>
  <action>
  **pigeon_flock_chase.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_chase.gd"

  const FORMATION_SPACING: float = 40.0
  const VERTICAL_ADJUST_SPEED: float = 60.0
  const SWOOP_TRIGGER_DISTANCE: float = 200.0

  var target_position: Vector2 = Vector2.ZERO
  var hover_offset: float = 0.0
  var swoop_scheduled: bool = false
  var swoop_time: float = 0.0

  func enter() -> void:
      if player.sprite:
          player.sprite.play("fly")
      
      target_position = player.global_position
      
      if player.is_lead_pigeon:
          _announce_chase_start()
      else:
          _sync_with_flock()

  func _announce_chase_start() -> void:
      Events.pigeon_chase_started.emit(player.flock_id, player.global_position)

  func _sync_with_flock() -> void:
      var lead = _get_flock_lead()
      if lead and is_instance_valid(lead):
          var delay = player.flock_position * player.SWOOP_DELAY_BETWEEN_PIGEONS
          swoop_time = delay
          swoop_scheduled = true

  func _get_flock_lead() -> Node:
      for member in get_tree().get_nodes_in_group("pigeon_flock_" + str(player.flock_id)):
          if member.is_lead_pigeon:
              return member
      return null

  func update(delta: float) -> void:
      var player_node = _get_target_player()
      if not player_node:
          state_machine.transition_to("FlockIdle")
          return
      
      var to_target = player_node.global_position - player.global_position
      var distance = to_target.length()
      
      if player.is_fleeing:
          _flee_from_threat(delta)
          return
      
      if distance < player.ATTACK_RANGE and not swoop_scheduled:
          if player.is_lead_pigeon:
              _schedule_swoop(0.0)
          else:
              var delay = player.flock_position * player.SWOOP_DELAY_BETWEEN_PIGEONS
              _schedule_swoop(delay)
      
      if swoop_scheduled:
          swoop_time -= delta
          if swoop_time <= 0:
              state_machine.transition_to("SwoopAttack")
              return
      
      _update_movement(to_target, distance, delta)
      _update_facing(to_target.x)

  func _get_target_player() -> Node:
      var group_name = "pigeon_flock_" + str(player.flock_id)
      var flock = get_tree().get_nodes_in_group(group_name)
      if flock.size() > 0:
          var lead = flock[0]
          if is_instance_valid(lead) and lead.has_method("get_attack_target"):
              return lead.get_attack_target()
      return get_tree().get_first_node_in_group("player")

  func _schedule_swoop(delay: float) -> void:
      swoop_scheduled = true
      swoop_time = delay

  func _update_movement(to_target: Vector2, distance: float, delta: float) -> void:
      if distance > SWOOP_TRIGGER_DISTANCE:
          var direction = to_target.normalized()
          var vertical = player.PERCH_HEIGHT - player.global_position.y
          var target_pos = to_target.normalized() * (distance - SWOOP_TRIGGER_DISTANCE * 0.5)
          target_pos.y += vertical * 0.5
          
          var formation_pos = _get_formation_position()
          var desired = formation_pos + target_pos * 0.5
          
          var steering = (desired - player.velocity) * 2.0
          player.velocity = (player.velocity + steering * delta).limit_length(player.FLY_SPEED)
          
          player.move_and_slide()

  func _get_formation_position() -> Vector2:
      var lead = _get_flock_lead()
      if lead and is_instance_valid(lead):
          var angle = player.flock_position * PI * 2 / 6
          return lead.global_position + Vector2(cos(angle), sin(angle)) * FORMATION_SPACING
      return Vector2.ZERO

  func _flee_from_threat(delta: float) -> void:
      var threat_direction = -player.velocity.normalized()
      player.velocity = (threat_direction * player.FLEE_SPEED)
      player.move_and_slide()
      
      if player.global_position.y > 500:
          state_machine.transition_to("FlockIdle")

  func _update_facing(horizontal: float) -> void:
      if player.sprite:
          if horizontal < -1:
              player.sprite.flip_h = true
          elif horizontal > 1:
              player.sprite.flip_h = false

  func exit() -> void:
      swoop_scheduled = false
      swoop_time = 0.0
  ```

  **Flock Coordination:**
  - Lead pigeon initiates chase, others sync attack timing
  - Formation flying with circular offset pattern
  - Individual swoop delays prevent simultaneous attacks
  - Flee behavior when HP drops below threshold
  </action>
  <verify>
  - FlockChase calculates formation positions
  - Lead pigeon schedules swoop at 0 delay
  - Other pigeons delay based on flock_position
  - Flee behavior triggers at 30% HP
  </verify>
  <done>FlockChase state created with flock coordination and attack timing</done>
</task>

<task type="auto">
  <name>Task 5: Create SwoopAttack state</name>
  <files>
    characters/enemies/states/pigeon_swoop_attack.gd
  </files>
  <action>
  **pigeon_swoop_attack.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_attack.gd"

  const SWOOP_HEIGHT: float = 120.0
  const SWOOP_DURATION: float = 0.6
  const RETURN_SPEED: float = 100.0
  const HITBOX_DURATION: float = 0.2

  var swoop_direction: Vector2 = Vector2.ZERO
  var swoop_start: Vector2 = Vector2.ZERO
  var swoop_progress: float = 0.0
  var attack_phase: int = 0
  var has_hit_player: bool = false

  func enter() -> void:
      var player_node = get_tree().get_first_node_in_group("player")
      if player_node:
          swoop_start = player.global_position
          var target = player_node.global_position
          target.y += 16
          swoop_direction = (target - swoop_start).normalized()
      
      if player.sprite:
          player.sprite.play("swoop")
      
      _enable_hitbox(false)
      attack_phase = 0
      has_hit_player = false

  func update(delta: float) -> void:
      match attack_phase:
          0:
              _dive_phase(delta)
          1:
              _damage_window(delta)
          2:
              _return_phase(delta)

  func _dive_phase(delta: float) -> void:
      swoop_progress += delta / SWOOP_DURATION
      
      if swoop_progress >= 1.0:
          attack_phase = 1
          swoop_progress = 0.0
          return
      
      var progress = ease_in_quad(swoop_progress)
      var vertical_drop = progress * SWOOP_HEIGHT
      
      player.global_position = swoop_start + swoop_direction * (progress * 150) + Vector2(0, vertical_drop)
      
      if player.sprite:
          player.sprite.rotation = lerp(0.0, PI * 0.25, progress)

  func _damage_window(delta: float) -> void:
      swoop_progress += delta / HITBOX_DURATION
      
      if swoop_progress >= 1.0:
          attack_phase = 2
          swoop_progress = 0.0
          _enable_hitbox(false)
          return
      
      if not has_hit_player:
          _enable_hitbox(true)
          _check_hit_player()

  func _check_hit_player() -> void:
      var hurtboxes = player.hurtbox.get_overlapping_areas()
      for area in hurtboxes:
          if area.get_parent().is_in_group("player"):
              var damage_event = DamageEvent.new()
              damage_event.amount = player.SWOOP_DAMAGE
              damage_event.source = player
              damage_event.type = DamageEvent.Type.AERIAL
              area.get_parent().take_damage(damage_event)
              has_hit_player = true
              Events.pigeon_hit_player.emit(player.flock_id)

  func _enable_hitbox(enabled: bool) -> void:
      if player.hitbox:
          player.hitbox.monitoring = enabled
          player.hitbox.monitorable = enabled

  func _return_phase(delta: float) -> void:
      var perch = player.perch_position
      var to_perch = perch - player.global_position
      var distance = to_perch.length()
      
      player.global_position += to_perch.normalized() * min(RETURN_SPEED * delta, distance)
      
      if player.sprite:
          player.sprite.rotation = lerp(player.sprite.rotation, 0.0, delta * 5)
      
      if distance < 8:
          state_machine.transition_to("FlockIdle")

  func ease_in_quad(t: float) -> float:
      return t * t

  func exit() -> void:
      player.global_position = player.perch_position
      if player.sprite:
          player.sprite.rotation = 0.0
      _enable_hitbox(false)

  func get_attack_target() -> Node:
      return get_tree().get_first_node_in_group("player")
  ```

  **Attack Phases:**
  1. **Dive Phase (0.6s):** Player swoops down toward player position, sprite rotates downward
  2. **Damage Window (0.2s):** Hitbox activates, checks for player collision
  3. **Return Phase:** Player flies back to perch position, sprite rotates back to neutral
  </action>
  <verify>
  - SwoopAttack has 3 distinct phases
  - Hitbox only active during damage window
  - Player returns to perch after attack
  - Damage event emitted on hit
  </verify>
  <done>SwoopAttack state created with dive/damage/return phases</done>
</task>

<task type="auto">
  <name>Task 6: Create PigeonHurt and PigeonDeath states</name>
  <files>
    characters/enemies/states/pigeon_hurt.gd
    characters/enemies/states/pigeon_death.gd
  </files>
  <action>
  **pigeon_hurt.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_hurt.gd"

  const PAUSE_DURATION: float = 0.3
  var pause_time: float = 0.0

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("hurt")
      
      _check_flee_condition()
      pause_time = 0.0

  func _check_flee_condition() -> void:
      var health_percent = player.health.current_health / player.health.max_health
      if health_percent <= player.FLEE_HP_THRESHOLD:
          player.is_fleeing = true
          Events.pigeon_fled.emit(player.flock_id, player)

  func update(delta: float) -> void:
      pause_time += delta
      
      if player.sprite and not player.sprite.is_playing():
          if player.is_fleeing:
              state_machine.transition_to("FlockChase")
          else:
              state_machine.transition_to("FlockIdle")
      
      if pause_time >= PAUSE_DURATION and player.is_fleeing:
          state_machine.transition_to("FlockChase")

  func exit() -> void:
      pause_time = 0.0
  ```

  **pigeon_death.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_death.gd"

  const FALL_DURATION: float = 0.4
  var fall_time: float = 0.0

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("death")
      
      player.hitbox.monitoring = false
      player.hitbox.monitorable = false
      
      fall_time = 0.0
      Events.pigeon_died.emit(player.flock_id, player)

  func update(delta: float) -> void:
      fall_time += delta
      
      if fall_time < FALL_DURATION:
          player.global_position.y += delta * 200
      else:
          player.queue_free()

  func exit() -> void:
      pass
  ```

  **Special Behavior:**
  - Hurt state triggers flee check (30% HP threshold)
  - Hurt state reports to FlockManager for coordinated response
  - Death reports to flock for position recalculation
  </action>
  <verify>
  - Hurt state checks HP threshold
  - Death state removes pigeon from scene
  - Both emit events for flock coordination
  </verify>
  <done>PigeonHurt and PigeonDeath states created with flock integration</done>
</task>

<task type="auto">
  <name>Task 7: Add flock management to Events autoload</name>
  <files>
    autoloads/events.gd
  </files>
  <action>
  **Add signals to Events:**

  ```gdscript
  signal pigeon_detected_player(flock_id: int, player_position: Vector2)
  signal pigeon_chase_started(flock_id: int, origin_position: Vector2)
  signal pigeon_swoop_started(flock_id: int, pigeon: Node)
  signal pigeon_hit_player(flock_id: int)
  signal pigeon_fled(flock_id: int, pigeon: Node)
  signal pigeon_died(flock_id: int, pigeon: Node)
  signal pigeon_entered_idle(flock_id: int)
  ```

  **Add flock management functions:**

  ```gdscript
  var _flock_data: Dictionary = {}
  var _next_flock_id: int = 0

  func get_next_flock_id() -> int:
      _next_flock_id += 1
      return _next_flock_id - 1

  func register_flock(flock_id: int, members: Array) -> void:
      _flock_data[flock_id] = {
          "members": members,
          "lead_pigeon": null,
          "state": "idle",
          "target_position": Vector2.ZERO
      }
      for i in range(members.size()):
          members[i].flock_id = flock_id
          members[i].flock_position = i
          members[i].is_lead_pigeon = (i == 0)
          if i == 0:
              _flock_data[flock_id]["lead_pigeon"] = members[i]

  func unregister_flock(flock_id: int) -> void:
      _flock_data.erase(flock_id)

  func get_flock_members(flock_id: int) -> Array:
      if _flock_data.has(flock_id):
          return _flock_data[flock_id]["members"]
      return []
  ```
  </action>
  <verify>
  - All pigeon signals added to Events
  - Flock management functions added
  - Signal signatures match state implementations
  </verify>
  <done>Events autoload updated with pigeon signals and flock management</done>
</task>

<task type="auto">
  <name>Task 8: Create generated pigeon sprites</name>
  <files>
    art/generated/enemies/pigeon_idle.png
    art/generated/enemies/pigeon_fly.png
    art/generated/enemies/pigeon_swoop.png
    art/generated/enemies/pigeon_hurt.png
    art/generated/enemies/pigeon_death.png
  </files>
  <action>
  **Sprite specifications:**

  **pigeon_idle.png (4 frames, 32x32):**
  - Frames 0-1: Stationary on perch, slight head bob
  - Frames 2-3: Same with feather ruffling

  **pigeon_fly.png (4 frames, 32x32):**
  - Wings up, down, up, down cycle
  - Forward facing with slight upward angle

  **pigeon_swoop.png (6 frames, 32x32):**
  - Frame 0-2: Diving pose, increasing downward angle
  - Frame 3-5: Sustained dive with wings tucked

  **pigeon_hurt.png (3 frames, 32x32):**
  - Frame 0: Recoil pose
  - Frame 1: Flash white/recoil
  - Frame 2: Return to neutral

  **pigeon_death.png (4 frames, 32x32):**
  - Frames 0-1: Falling down
  - Frames 2-3: Fade out/disappear

  **Style guidelines:**
  - 16x16 actual sprite, 32x32 canvas with centering
  - Gray/blue plumage with lighter chest
  - Beak yellow-orange
  - Red eye ring characteristic
  - Nearest-neighbor scaling for pixel-perfect rendering
  </action>
  <verify>
  - All 5 sprite sheets created
  - Frame counts match animation definitions
  - Proper canvas size (32x32) and centered sprites
  - Style consistent with existing enemy sprites
  </verify>
  <done>All pigeon sprite sheets generated and ready for SpriteFrames</done>
</task>

<task type="auto">
  <name>Task 9: Update project.godot for pigeon integration</name>
  <files>
    project.godot
  </files>
  <action>
  **Add pigeon class to autoload if needed, or ensure it's loadable:**

  No changes required if pigeon.gd extends enemy_base.gd properly.

  **Ensure input map includes any pigeon-specific controls (debug):**
  - Not required for gameplay, pigeons are AI-only
  </action>
  <verify>
  - project.godot loads pigeon.gd without errors
  </verify>
  <done>project.godot configured for pigeon enemy</done>
</task>

</tasks>

<flock_behavior_detailed>

## Flocking Mechanics

### Spawn and Formation
1. Rooftop spawner creates 3-6 pigeons (random count)
2. First pigeon spawned becomes lead pigeon (is_lead_pigeon = true)
3. All pigeons added to same flock group (group name: "pigeon_flock_N")
4. Lead pigeon assigned perch position at spawn point
5. Other pigeons calculate formation offsets around lead

### Formation Pattern
- Circular formation around lead pigeon
- Radius increases with flock size
- Each pigeon has unique angle based on flock_position
- Formula: `angle = flock_position * 2π / (flock_size - 1)`
- Offset: `Vector2(cos(angle), sin(angle)) * spacing`

### Attack Coordination
1. Lead pigeon detects player → emits pigeon_detected_player
2. All pigeons transition to FlockChase
3. Lead schedules immediate swoop (delay = 0)
4. Each subsequent pigeon schedules swoop with delay:
   - `swoop_delay = flock_position * SWOOP_DELAY_BETWEEN_PIGEONS`
   - SWOOP_DELAY_BETWEEN_PIGEONS = 0.3s
5. Pigeons swoop in sequence, not simultaneously
6. After swoop, all return to perch and resume FlockIdle

### Flee Behavior
1. Any pigeon taking damage checks HP threshold (30%)
2. If below threshold, pigeon.is_fleeing = true
3. PigeonHurt state emits pigeon_fled signal
4. All flock members transition to FlockChase with flee direction
5. Fleeing pigeons fly upward and away from threat
6. Once at sufficient height/distance, resume FlockIdle

### Death Handling
1. When pigeon dies, pigeon_death state emits pigeon_died
2. Lead pigeon checks remaining flock size
3. If lead died, promote next pigeon to lead
4. Formation recalculates with remaining members
5. Remaining pigeons continue normal behavior

</flock_behavior_detailed>

<code_snippets>

### Flock Manager Integration

```gdscript
extends Node

var _active_flocks: Dictionary = {}
var _next_flock_id: int = 0

func create_flock(spawn_position: Vector2, size: int) -> Array:
    var flock_id = _next_flock_id
    _next_flock_id += 1
    
    var pigeon_scene = load("res://characters/enemies/pigeon.tscn")
    var flock_members: Array = []
    
    for i in range(size):
        var pigeon = pigeon_scene.instantiate()
        pigeon.flock_id = flock_id
        pigeon.flock_position = i
        pigeon.is_lead_pigeon = (i == 0)
        
        var offset = Vector2.ZERO
        if i > 0:
            var angle = i * TAU / size
            offset = Vector2(cos(angle), sin(angle)) * 32.0
        
        pigeon.global_position = spawn_position + offset
        pigeon.add_to_group("pigeon_flock_" + str(flock_id))
        
        flock_members.append(pigeon)
    
    _active_flocks[flock_id] = {
        "members": flock_members,
        "state": "idle",
        "perch_position": spawn_position
    }
    
    return flock_members

func get_flock_lead(flock_id: int) -> Node:
    if _active_flocks.has(flock_id):
        var members = _active_flocks[flock_id]["members"]
        for member in members:
            if member.is_lead_pigeon:
                return member
    return null

func promote_new_lead(flock_id: int) -> void:
    if _active_flocks.has(flock_id):
        var members = _active_flocks[flock_id]["members"]
        for member in members:
            if is_instance_valid(member) and not member.is_lead_pigeon:
                member.is_lead_pigeon = true
                member.flock_position = 0
                _active_flocks[flock_id]["lead_pigeon"] = member
                break
```

### Swoop Attack Sequence

```gdscript
func execute_coordinated_swoop(flock_id: int) -> void:
    var members = Events.get_flock_members(flock_id)
    
    for i in range(members.size()):
        var pigeon = members[i]
        if is_instance_valid(pigeon):
            var delay = i * pigeon.SWOOP_DELAY_BETWEEN_PIGEONS
            await get_tree().create_timer(delay).timeout
            
            if is_instance_valid(pigeon) and pigeon.state_machine:
                pigeon.state_machine.transition_to("SwoopAttack")
```

### Rooftop Spawner Usage

```gdscript
extends Node2D

@export var flock_size_min: int = 3
@export var flock_size_max: int = 6
@export var spawn_cooldown: float = 8.0

var _cooldown_timer: float = 0.0

func _ready() -> void:
    _cooldown_timer = 0.0

func _process(delta: float) -> void:
    _cooldown_timer -= delta
    if _cooldown_timer <= 0:
        _try_spawn_flock()
        _cooldown_timer = spawn_cooldown

func _try_spawn_flock() -> void:
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return
    
    var dist = global_position.distance_to(player.global_position)
    if dist > 400 or dist < 150:
        return
    
    var size = randi_range(flock_size_min, flock_size_max)
    var flock = Events.create_flock(global_position, size)
    
    for pigeon in flock:
        get_parent().add_child(pigeon)
    
    Events.pigeon_swoop_started.emit(Events.get_next_flock_id() - 1, flock[0])
```

</code_snippets>

<verification>
1. Run the game and navigate to rooftop area
2. Observe pigeon spawn (3-6 pigeons appear on perch)
3. Pigeons hover in formation, lead bobbing more prominently
4. Approach within detection range (256px)
5. Lead pigeon triggers chase, all pigeons pursue
6. Pigeons swoop in sequence (0.3s delay between each)
7. Each swoop damages player if hit
8. After swoop, pigeons return to perch
9. Attack player with 2-3 swoop waves
10. Reduce one pigeon to <30% HP
11. Observe group flee behavior (all retreat)
12. Kill a pigeon, observe formation recalculation
13. Verify no errors in console
</verification>

<success_criteria>
- Pigeons spawn in flocks of 3-6 with proper formation
- Lead pigeon coordinates detection and attack timing
- Swoop attacks execute with 0.3s delay between pigeons
- Flee behavior triggers at 30% HP
- Death of lead pigeon promotes replacement
- All animations play correctly (idle, fly, swoop, hurt, death)
- No Polygon2D or placeholder graphics
- Player can kill individual pigeons without instant group wipe
- Group flee prevents player from being overwhelmed
</success_criteria>

<output>
After completion, create `docs/phases/36-rooftops/36-01-SUMMARY.md`
</output>
