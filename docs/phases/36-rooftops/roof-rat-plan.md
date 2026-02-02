---
phase: 36-rooftops
plan: 02
type: execute
wave: 2
depends_on: ["36-01"]
files_created:
  - characters/enemies/roof_rat.tscn
  - characters/enemies/roof_rat.gd
  - characters/enemies/states/rat_wall_stealth.gd
  - characters/enemies/states/rat_wall_run.gd
  - characters/enemies/states/rat_wall_ambush.gd
  - characters/enemies/states/rat_wall_retreat.gd
  - characters/enemies/states/rat_cornered.gd
  - art/generated/enemies/roof_rat_wall_idle.png
  - art/generated/enemies/roof_rat_wall_run.png
  - art/generated/enemies/roof_rat_ambush.png
  - art/generated/enemies/roof_rat_retreat.png
  - art/generated/enemies/roof_rat_hurt.png
  - art/generated/enemies/roof_rat_death.png
files_modified:
  - project.godot
  - autoloads/events.gd
  - characters/enemies/enemy_base.gd
autonomous: true

must_haves:
  truths:
    - "Roof Rats run along vertical surfaces (walls, ledges, rooftops)"
    - "Rats stealth on walls, semi-transparent, flatten against surface"
    - "Rats ambush by dropping from wall when player walks below"
    - "Hitbox activates during ambush descent"
    - "Rats retreat upward when cornered, escaping to reposition"
    - "Wall-running uses raycast-based surface detection"
  artifacts:
    - path: "characters/enemies/roof_rat.tscn"
      provides: "Roof Rat enemy with wall-running, ambush, retreat behaviors"
      contains: "CharacterBody2D, AnimatedSprite2D, CollisionShape2D, RayCast2D, Area2D"
    - path: "characters/enemies/states/rat_wall_ambush.gd"
      provides: "Wall ambush attack with drop and hitbox activation"
      contains: "Telegraph, drop movement, hitbox timing, retreat transition"
    - path: "characters/enemies/states/rat_cornered.gd"
      provides: "Cornered behavior with upward retreat"
      contains: "Corner detection, wall escape, return to patrol"
  key_links:
    - from: "roof_rat.tscn"
      to: "world/rooftop_spawners"
      via: "Spawner spawns rat on wall surface"
    - from: "rat_wall_stealth.gd"
      to: "stray_cat.gd"
      via: "Stealth pattern adaptation (transparency, flattening)"
    - from: "rat_wall_ambush.gd"
      to: "pigeon_swoop_attack.gd"
      via: "Vertical drop timing and hitbox activation"
    - from: "rat_cornered.gd"
      to: "cat_retreat.gd"
      via: "Retreat behavior pattern"

<objective>
Create a Roof Rat enemy that runs along vertical surfaces, ambushes players from above by dropping, and retreats upward when cornered. The Roof Rat introduces wall-running mechanics with raycast-based surface detection and combines stealth ambush patterns from the Stray Cat with vertical movement from the Pigeon.

Purpose: Roof Rats provide vertical harassment encounters, teaching players to watch for threats from walls and ledges. Their wall-running mechanics introduce surface-based AI that opens design space for more complex vertical encounters.
Output: Fully functional wall-running Roof Rat enemy with stealth, ambush drop attack, and cornered retreat behavior.
</objective>

<execution_context>
@~/.config/opencode/get-shit-done/workflows/execute-plan.md
@~/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@docs/ROADMAP.md
@docs/STATE.md
@characters/enemies/enemy_base.gd
@characters/enemies/stray_cat.gd
@characters/enemies/states/cat_stealth.gd
@characters/enemies/states/cat_pounce.gd
@characters/enemies/pigeon.gd
@characters/enemies/states/pigeon_swoop_attack.gd
@characters/enemies/states/cat_retreat.gd
@autoloads/events.gd
@world/rooftop_spawners.gd
</context>

<tasks>

<task type="auto">
  <name>Task 1: Define Roof Rat enemy stats and wall-running constants</name>
  <files>
    characters/enemies/roof_rat.gd
  </files>
  <action>
  **Create roof_rat.gd with stats and wall-running properties:**

  ```gdscript
  extends "res://characters/enemies/enemy_base.gd"

  class_name RoofRat

  const WALL_RUN_SPEED: float = 150.0
  const WALL_PATROL_SPEED: float = 80.0
  const AMBUSH_DAMAGE: float = 20.0
  const AMBUSH_DROP_HEIGHT: float = 80.0
  const AMBUSH_DURATION: float = 0.35
  const RETREAT_SPEED: float = 200.0
  const DETECTION_RANGE: float = 280.0
  const AMBUSH_TRIGGER_DISTANCE: float = 120.0
  const CORNER_DETECTION_RADIUS: float = 64.0
  const RAYCAST_LENGTH: float = 24.0
  const RAYCAST_OFFSET: float = 8.0
  const STEALTH_ALPHA: float = 0.20
  const WALL_SQUISH_FACTOR: float = 0.7
  const NO_TARGET_TIMEOUT: float = 4.0

  var is_stealthed: bool = true
  var stealth_alpha: float = STEALTH_ALPHA
  var wall_squish_factor: float = WALL_SQUISH_FACTOR
  var current_surface_normal: Vector2 = Vector2.UP
  var is_on_wall: bool = false
  var no_target_timer: float = 0.0
  var last_ambush_position: Vector2 = Vector2.ZERO

  func _ready() -> void:
      health = HealthComponent.new(45, 45)
      hitbox = HitboxComponent.new()
      hitbox.damage = AMBUSH_DAMAGE
      hurtbox = HurtboxComponent.new()
      hurtbox.layer = 5
      add_child(hitbox)
      add_child(hurtbox)
      health.health_changed.connect(_on_health_changed)
      _setup_wall_detection()
      _setup_detection_area()
  ```

  **Stats Summary:**
  - HP: 45 (moderate durability)
  - Damage: 20 (ambush drop attack)
  - Wall Run Speed: 150 (faster than ground movement)
  - Patrol Speed: 80 (slower while searching for position)
  - Detection Range: 280 pixels
  - Ambush Trigger: 120 pixels (player below)
  - Stealth Alpha: 0.20 (semi-transparent on wall)
  - Squish Factor: 0.70 (flattens against wall)

  **Wall-Running Properties:**
  - RayCast2D for surface detection
  - Surface normal tracking for orientation
  - Wall squish effect for visual integration
  </action>
  <verify>
  - roof_rat.gd has all wall-running constants
  - Stats match requirements (45 HP, 20 damage, 280 detection)
  - Raycast and surface detection setup in _ready
  - Stealth properties defined
  </verify>
  <done>roof_rat.gd created with wall-running stats, constants, and surface detection</done>
</task>

<task type="auto">
  <name>Task 2: Create roof_rat.tscn scene</name>
  <files>
    characters/enemies/roof_rat.tscn
  </files>
  <action>
  **Scene structure:**

  ```
  RoofRat (CharacterBody2D)
  ├── Sprite2D (AnimatedSprite2D)
  │   └── SpriteFrames: wall_idle, wall_run, ambush, retreat, hurt, death
  ├── CollisionShape2D (Rectangle, 16x20)
  ├── DetectionArea (Area2D)
  │   └── CollisionShape2D (Circle, radius 280)
  ├── WallRaycast (RayCast2D)
  │   ├── target_position_offset: Vector2(16, 0)
  │   └── collide_with_areas: false
  ├── Hurtbox (Area2D)
  │   └── CollisionShape2D (Rectangle, 14x18)
  ├── Hitbox (Area2D) - active during ambush
  │   └── CollisionShape2D (Rectangle, 20x20)
  ├── StateMachine (Node)
  │   ├── WallStealth
  │   ├── WallRun
  │   ├── WallAmbush
  │   ├── WallRetreat
  │   ├── Cornered
  │   ├── Hurt
  │   └── Death
  └── HealthComponent (Node)
  ```

  **SpriteFrames configuration:**
  - wall_idle: 4 frames, 0.3s each, flattened against wall
  - wall_run: 6 frames, 0.12s each, limbs moving along surface
  - ambush: 4 frames, 0.1s each, squash then drop
  - retreat: 4 frames, 0.15s each, scrambling upward
  - hurt: 3 frames, 0.15s each, recoil animation
  - death: 4 frames, 0.2s each, fall and fade

  **Collision layers:**
  - Layer 3: Enemy body
  - Layer 5: Enemy hurtbox
  - Layer 7: Enemy hitbox (ambush only)

  **RayCast2D configuration:**
  - Target position: Vector2(20, 0) relative to parent
  - Collision mask: Layer 1 (World)
  - Enabled: true
  - Hides away from walls: false
  </action>
  <verify>
  - Scene has all required nodes
  - SpriteFrames has all 6 animations
  - RayCast2D configured for wall detection
  - DetectionArea matches DETECTION_RANGE (280px)
  - Hitbox only active during ambush state
  </verify>
  <done>roof_rat.tscn scene created with all nodes, SpriteFrames, and raycast</done>
</task>

<task type="auto">
  <name>Task 3: Create WallStealth state</name>
  <files>
    characters/enemies/states/rat_wall_stealth.gd
  </files>
  <action>
  **rat_wall_stealth.gd:**

  ```gdscript
  extends State
  class_name RatWallStealth

  var no_target_timer: float = 0.0

  func enter() -> void:
      player.velocity = Vector2.ZERO
      player.is_stealthed = true
      no_target_timer = 0.0
      
      if player.sprite:
          player.sprite.play("wall_idle")
          var tween = player.create_tween()
          tween.tween_property(player.sprite, "scale:y", player.wall_squish_factor, 0.2)
          tween.parallel().tween_property(player.sprite, "modulate:a", player.stealth_alpha, 0.3)

  func update(delta: float) -> void:
      if not player.can_act():
          player.velocity = Vector2.ZERO
          player.move_and_slide()
          return
      
      if player.target and player.is_target_in_detection_range():
          no_target_timer = 0.0
          if _is_player_below():
              state_machine.transition_to("WallAmbush")
              return
          _track_target_approach(delta)
          return
      
      no_target_timer += delta
      if no_target_timer >= player.NO_TARGET_TIMEOUT:
          state_machine.transition_to("WallRun")
          return
      
      player.velocity = Vector2.ZERO
      player.move_and_slide()

  func _is_player_below() -> bool:
      if not player.target:
          return false
      var to_target = player.target.global_position - player.global_position
      return to_target.y > 0 and abs(to_target.x) < 40.0

  func _track_target_approach(delta: float) -> void:
      var to_target = player.target.global_position - player.global_position
      var distance = to_target.length()
      
      if distance < player.AMBUSH_TRIGGER_DISTANCE and _is_player_below():
          state_machine.transition_to("WallAmbush")
          return
      
      if player.sprite:
          if to_target.x > 0:
              player.sprite.flip_h = false
          elif to_target.x < 0:
              player.sprite.flip_h = true

  func exit() -> void:
      no_target_timer = 0.0
      player.is_stealthed = false
      if player.sprite:
          var tween = player.create_tween()
          tween.tween_property(player.sprite, "scale:y", 1.0, 0.1)
          tween.parallel().tween_property(player.sprite, "modulate:a", 1.0, 0.15)
  ```

  **Behavior:**
  - Semi-transparent while waiting on wall (0.20 alpha)
  - Squished against wall surface (0.7 scale.y)
  - Monitors for player below to trigger ambush
  - Times out to patrol if no player detected
  - Faces toward expected player approach
  </action>
  <verify>
  - State has enter/update/exit functions
  - Stealth visual effects applied (alpha, scale)
  - Player below detection works correctly
  - Timeout transitions to WallRun
  </verify>
  <done>WallStealth state created with stealth visuals and ambush detection</done>
</task>

<task type="auto">
  <name>Task 4: Create WallRun state</name>
  <files>
    characters/enemies/states/rat_wall_run.gd
  </files>
  <action>
  **rat_wall_run.gd:**

  ```gdscript
  extends State
  class_name RatWallRun

  var patrol_direction: int = 1
  var wall_check_timer: float = 0.0
  const WALL_CHECK_INTERVAL: float = 0.1

  func enter() -> void:
      patrol_direction = 1 if randf() > 0.5 else -1
      if player.sprite:
          player.sprite.play("wall_run")
          player.sprite.flip_h = (patrol_direction < 0)

  func update(delta: float) -> void:
      if not player.can_act():
          player.velocity = Vector2.ZERO
          player.move_and_slide()
          return
      
      wall_check_timer += delta
      if wall_check_timer >= WALL_CHECK_INTERVAL:
          wall_check_timer = 0.0
          if not _is_on_surface():
              _find_new_surface()
              return
      
      if player.target and player.is_target_in_detection_range():
          if _is_player_below():
              state_machine.transition_to("WallAmbush")
              return
          elif _is_player_approaching():
              state_machine.transition_to("WallStealth")
              return
      
      _patrol_along_wall(delta)

  func _is_on_surface() -> bool:
      if not player.get("wall_raycast") or not player.wall_raycast:
          return false
      player.wall_raycast.force_raycast_update()
      return player.wall_raycast.is_raycast_enabled() and player.wall_raycast.is_colliding()

  func _find_new_surface() -> void:
      var player_node = get_tree().get_first_node_in_group("player")
      if player_node:
          var to_player = player_node.global_position - player.global_position
          var search_radius = 100.0
          var found_surface = _scan_for_surface(player.global_position, search_radius)
          if found_surface:
              player.global_position = found_surface
              return
      state_machine.transition_to("WallStealth")

  func _scan_for_surface(origin: Vector2, radius: float) -> Vector2:
      var angles = [0, PI/4, - PI/2, -PI/2]
      for angle in angles:
          var direction = VectorPI/4,2(cos(angle), sin(angle))
          var test_pos = origin + direction * radius
          if _test_surface_at(test_pos):
              return test_pos
      return Vector2.ZERO

  func _test_surface_at(pos: Vector2) -> bool:
      var space_state = get_world_2d().direct_space_state
      var query = PhysicsPointQueryParameters2D.new()
      query.position = pos
      query.collision_mask = 1
      var result = space_state.intersect_point(query)
      return result.size() > 0

  func _is_player_below() -> bool:
      if not player.target:
          return false
      var to_target = player.target.global_position - player.global_position
      return to_target.y > 0 and abs(to_target.x) < 40.0

  func _is_player_approaching() -> bool:
      if not player.target:
          return false
      var distance = player.global_position.distance_to(player.target.global_position)
      return distance < player.DETECTION_RANGE * 0.7

  func _patrol_along_wall(delta: float) -> void:
      player.velocity = Vector2(patrol_direction * player.WALL_PATROL_SPEED, 0)
      player.move_and_slide()

  func exit() -> void:
      wall_check_timer = 0.0
  ```

  **Behavior:**
  - Patrols along wall surface at patrol speed
  - Uses raycast to verify surface contact
  - Searches for new surface if current wall ends
  - Transitions to ambush if player detected below
  - Transitions to stealth if player approaching
  </action>
  <verify>
  - State patrols at WALL_PATROL_SPEED (80)
  - Raycast checks for surface contact
  - Surface scanning when wall ends
  - Detection transitions work correctly
  </verify>
  <done>WallRun state created with patrol movement and surface detection</done>
</task>

<task type="auto">
  <name>Task 5: Create WallAmbush state</name>
  <files>
    characters/enemies/states/rat_wall_ambush.gd
  </files>
  <action>
  **rat_wall_ambush.gd:**

  ```gdscript
  extends State
  class_name RatWallAmbush

  const AMBUSH_DURATION: float = 0.35
  const HITBOX_START: float = 0.12
  const HITBOX_END: float = 0.28
  const DROP_HEIGHT: float = 80.0

  var ambush_timer: float = 0.0
  var hitbox_active: bool = false
  var ambush_start_pos: Vector2 = Vector2.ZERO
  var target_pos: Vector2 = Vector2.ZERO

  func enter() -> void:
      ambush_timer = 0.0
      hitbox_active = false
      player.is_stealthed = false
      player.last_ambush_position = player.global_position
      ambush_start_pos = player.global_position
      
      if player.target:
          target_pos = player.target.global_position
          if player.target.has_node("CollisionShape2D"):
              var shape = player.target.get_node("CollisionShape2D")
              target_pos.y = player.target.global_position.y + shape.shape.size.y / 2
      
      if player.sprite:
          player.sprite.play("ambush")
          var tween = player.create_tween()
          tween.tween_property(player.sprite, "scale:y", 1.0, 0.1)
          tween.parallel().tween_property(player.sprite, "modulate:a", 1.0, 0.1)
      
      _show_telegraph()
      
      if player.hitbox:
          player.hitbox.monitoring = false
          player.hitbox.monitorable = false

  func update(delta: float) -> void:
      if not player.can_act():
          if player.hitbox:
              player.hitbox.monitoring = false
              player.hitbox.monitorable = false
          state_machine.transition_to("WallStealth")
          return
      
      ambush_timer += delta
      var progress = ambush_timer / AMBUSH_DURATION
      
      var y_offset = progress * DROP_HEIGHT
      player.global_position.y = ambush_start_pos.y + y_offset
      
      if progress >= HITBOX_START and progress < HITBOX_END:
          if not hitbox_active and player.hitbox:
              player.hitbox.monitoring = true
              player.hitbox.monitorable = true
              hitbox_active = true
      elif progress >= HITBOX_END:
          if hitbox_active and player.hitbox:
              player.hitbox.monitoring = false
              player.hitbox.monitorable = false
              hitbox_active = false
      
      if player.target:
          var to_target = player.target.global_position - player.global_position
          to_target.y = 0
          player.velocity = to_target.normalized() * (player.WALL_PATROL_SPEED * 0.5)
      else:
          player.velocity = Vector2.ZERO
      
      player.move_and_slide()
      
      if ambush_timer >= AMBUSH_DURATION:
          state_machine.transition_to("WallRetreat")

  func _show_telegraph() -> void:
      var label = Label.new()
      label.text = "!"
      label.add_theme_font_size_override("font_size", 10)
      label.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
      label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
      label.add_theme_constant_override("outline_size", 2)
      label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
      label.position = Vector2(-3, -20)
      label.z_index = 90
      label.scale = Vector2(0.5, 0.5)
      label.pivot_offset = Vector2(3, 8)
      player.add_child(label)
      
      var tween = player.create_tween()
      tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.05)\
          .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
      tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.05)
      tween.tween_interval(0.15)
      tween.tween_property(label, "queue_free")

  func exit() -> void:
      ambush_timer = 0.0
      hitbox_active = false
      if player.hitbox:
          player.hitbox.monitoring = false
          player.hitbox.monitorable = false
  ```

  **Attack Pattern:**
  - Telegraphs with "!" warning icon
  - Drops vertically toward player position
  - Hitbox activates mid-drop for damage window
  - Hitbox deactivates after damage window
  - Transitions to retreat after ambush completes
  </action>
  <verify>
  - Telegraph displays before drop
  - Hitbox only active during HITBOX_START to HITBOX_END
  - Vertical drop movement toward player
  - Retreat transition after ambush
  </verify>
  <done>WallAmbush state created with telegraph, drop attack, and hitbox timing</done>
</task>

<task type="auto">
  <name>Task 6: Create WallRetreat state</name>
  <files>
    characters/enemies/states/rat_wall_retreat.gd
  </files>
  <action>
  **rat_wall_retreat.gd:**

  ```gdscript
  extends State
  class_name RatWallRetreat

  const RETREAT_DURATION: float = 0.8
  const RETREAT_HEIGHT: float = 120.0

  var retreat_timer: float = 0.0
  var retreat_start_y: float = 0.0
  var target_y: float = 0.0

  func enter() -> void:
      retreat_timer = 0.0
      retreat_start_y = player.global_position.y
      target_y = retreat_start_y - RETREAT_HEIGHT
      
      if player.sprite:
          player.sprite.play("retreat")
          player.sprite.flip_h = false

  func update(delta: float) -> void:
      if not player.can_act():
          state_machine.transition_to("WallStealth")
          return
      
      retreat_timer += delta
      var progress = retreat_timer / RETREAT_DURATION
      var eased = ease_out_quad(progress)
      
      player.global_position.y = retreat_start_y - (eased * RETREAT_HEIGHT)
      
      if player.sprite:
          if progress < 0.5:
              player.sprite.flip_h = false
          else:
              player.sprite.flip_h = true
      
      player.velocity = Vector2.ZERO
      player.move_and_slide()
      
      if retreat_timer >= RETREAT_DURATION:
          _find_climb_position()

  func _find_climb_position() -> void:
      var search_offsets = [Vector2(30, -40), Vector2(-30, -40), Vector2(0, -60)]
      for offset in search_offsets:
          var test_pos = player.global_position + offset
          if _is_valid_climb_position(test_pos):
              player.global_position = test_pos
              state_machine.transition_to("WallStealth")
              return
      state_machine.transition_to("WallRun")

  func _is_valid_climb_position(pos: Vector2) -> bool:
      var space_state = get_world_2d().direct_space_state
      var query = PhysicsPointQueryParameters2D.new()
      query.position = pos
      query.collision_mask = 1
      var result = space_state.intersect_point(query)
      return result.size() > 0

  func ease_out_quad(t: float) -> float:
      return 1.0 - (1.0 - t) * (1.0 - t)

  func exit() -> void:
      retreat_timer = 0.0
  ```

  **Retreat Behavior:**
  - Climbs upward away from player
  - Duration: 0.8 seconds
  - Height gain: 120 pixels
  - Searches for valid climb position afterward
  - Transitions to stealth or patrol based on position
  </action>
  <verify>
  - Retreat moves upward (negative Y)
  - Eased movement for smooth animation
  - Climb position validation
  - State transition after retreat completes
  </verify>
  <done>WallRetreat state created with upward climb and position recovery</done>
</task>

<task type="auto">
  <name>Task 7: Create Cornered state</name>
  <files>
    characters/enemies/states/rat_cornered.gd
  </files>
  <action>
  **rat_cornered.gd:**

  ```gdscript
  extends State
  class_name RatCornered

  const CORNER_CHECK_INTERVAL: float = 0.15
  const ESCAPE_COOLDOWN: float = 2.0
  const ESCAPE_HEIGHT: float = 150.0

  var corner_check_timer: float = 0.0
  var escape_cooldown_timer: float = 0.0
  var is_escaping: bool = false

  func enter() -> void:
      corner_check_timer = 0.0
      escape_cooldown_timer = 0.0
      is_escaping = false
      
      if player.sprite:
          player.sprite.play("retreat")
      
      _attempt_escape()

  func update(delta: float) -> void:
      escape_cooldown_timer = max(0, escape_cooldown_timer - delta)
      
      if is_escaping:
          _perform_escape(delta)
          return
      
      corner_check_timer += delta
      if corner_check_timer >= CORNER_CHECK_INTERVAL:
          corner_check_timer = 0.0
          if not _is_cornered():
              state_machine.transition_to("WallRun")
              return
      
      if escape_cooldown_timer <= 0:
          _attempt_escape()

  func _is_cornered() -> bool:
      var player_node = get_tree().get_first_node_in_group("player")
      if not player_node:
          return false
      
      var to_player = player_node.global_position - player.global_position
      var distance = to_player.length()
      
      var escape_paths = [
          Vector2(0, -1),
          Vector2(1, -1),
          Vector2(-1, -1)
      ]
      
      for direction in escape_paths:
          if _has_escape_path(direction):
              return false
      
      return distance < player.CORNER_DETECTION_RADIUS

  func _has_escape_path(direction: Vector2) -> bool:
      var ray_length = ESCAPE_HEIGHT * 0.5
      var space_state = get_world_2d().direct_space_state
      var query = PhysicsRayQueryParameters2D.new()
      query.from = player.global_position
      query.to = player.global_position + direction * ray_length
      query.collision_mask = 1
      var result = space_state.intersect_ray(query)
      return result == null or not result.is_empty()

  func _attempt_escape() -> void:
      if not _is_cornered():
          return
      
      var escape_direction = _find_best_escape_direction()
      if escape_direction != Vector2.ZERO:
          is_escaping = true
          player.velocity = escape_direction * player.RETREAT_SPEED
          escape_cooldown_timer = ESCAPE_COOLDOWN

  func _find_best_escape_direction() -> Vector2:
      var directions = [Vector2(0, -1), Vector2(1, -1), Vector2(-1, -1)]
      var best_direction = Vector2.ZERO
      var best_score = -1.0
      
      for direction in directions:
          if _has_clear_path(direction):
              var player_node = get_tree().get_first_node_in_group("player")
              var dot = 1.0
              if player_node:
                  var to_player = player_node.global_position - player.global_position
                  dot = direction.dot(to_player.normalized())
              var score = _path_clearance(direction) - dot * 0.5
              if score > best_score:
                  best_score = score
                  best_direction = direction
      
      return best_direction

  func _has_clear_path(direction: Vector2) -> bool:
      var ray_length = ESCAPE_HEIGHT
      var space_state = get_world_2d().direct_space_state
      var query = PhysicsRayQueryParameters2D.new()
      query.from = player.global_position
      query.to = player.global_position + direction * ray_length
      query.collision_mask = 1
      var result = space_state.intersect_ray(query)
      return result == null or result.is_empty()

  func _path_clearance(direction: Vector2) -> float:
      var test_positions = [0.3, 0.6, 1.0]
      var clear_count = 0
      for t in test_positions:
          var pos = player.global_position + direction * ESCAPE_HEIGHT * t
          var space_state = get_world_2d().direct_space_state
          var query = PhysicsPointQueryParameters2D.new()
          query.position = pos
          query.collision_mask = 1
          var result = space_state.intersect_point(query)
          if result.size() == 0:
              clear_count += 1
      return float(clear_count) / test_positions.size()

  func _perform_escape(delta: float) -> void:
      player.move_and_slide()
      
      var escape_complete = true
      var player_node = get_tree().get_first_node_in_group("player")
      if player_node:
          var dist_after = player.global_position.distance_to(player_node.global_position)
          if dist_after > player.CORNER_DETECTION_RADIUS * 1.5:
              escape_complete = true
          else:
              escape_complete = false
      
      if escape_complete and player.velocity.length() < 10:
          is_escaping = false
          state_machine.transition_to("WallRun")

  func exit() -> void:
      corner_check_timer = 0.0
      is_escaping = false
  ```

  **Cornered Behavior:**
  - Detects when trapped against wall with player nearby
  - Checks escape paths in upward and diagonal directions
  - Escapes along best available path
  - Returns to patrol after escaping
  - Cooldown prevents immediate re-cornering
  </action>
  <verify>
  - Corner detection radius works (64px)
  - Escape path checking in 3 directions
  - Best escape direction selected by clearance
  - Cooldown prevents escape spam
  </verify>
  <done>Cornered state created with escape pathfinding and retreat behavior</done>
</task>

<task type="auto">
  <name>Task 8: Create Roof Rat hurt and death states</name>
  <files>
    characters/enemies/states/rat_hurt.gd
    characters/enemies/states/rat_death.gd
  </files>
  <action>
  **rat_hurt.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_hurt.gd"

  const PAUSE_DURATION: float = 0.25

  var pause_time: float = 0.0

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("hurt")
      
      pause_time = 0.0

  func update(delta: float) -> void:
      pause_time += delta
      
      if player.sprite and not player.sprite.is_playing():
          if player.health.current_health <= 0:
              state_machine.transition_to("Death")
          else:
              state_machine.transition_to("WallStealth")
      
      if pause_time >= PAUSE_DURATION:
          state_machine.transition_to("WallStealth")

  func exit() -> void:
      pause_time = 0.0
  ```

  **rat_death.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_death.gd"

  const FALL_DURATION: float = 0.5
  var fall_time: float = 0.0

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("death")
      
      if player.hitbox:
          player.hitbox.monitoring = false
          player.hitbox.monitorable = false
      
      fall_time = 0.0

  func update(delta: float) -> void:
      fall_time += delta
      
      if fall_time < FALL_DURATION:
          player.global_position.y += delta * 150
      else:
          player.queue_free()

  func exit() -> void:
      pass
  ```

  **Behavior:**
  - Hurt state brief pause then returns to stealth
  - Death falls down and fades out
  - No special flee or flock behavior needed (solo enemy)
  </action>
  <verify>
  - Hurt state has brief pause
  - Death removes rat from scene
  - Transitions work correctly from both states
  </verify>
  <done>RatHurt and RatDeath states created with standard enemy behavior</done>
</task>

<task type="auto">
  <name>Task 9: Add roof rat signals to Events autoload</name>
  <files>
    autoloads/events.gd
  </files>
  <action>
  **Add signals to Events:**

  ```gdscript
  signal roof_rat_ambush_started(rat: Node)
  signal roof_rat_hit_player(rat: Node)
  signal roof_rat_retreated(rat: Node)
  signal roof_rat_cornered(rat: Node)
  signal roof_rat_escaped(rat: Node)
  ```

  **No flock management needed - Roof Rats are solo enemies**
  </action>
  <verify>
  - All roof rat signals added to Events
  - Signal signatures match state implementations
  </verify>
  <done>Events autoload updated with roof rat signals</done>
</task>

<task type="auto">
  <name>Task 10: Create generated roof rat sprites</name>
  <files>
    art/generated/enemies/roof_rat_wall_idle.png
    art/generated/enemies/roof_rat_wall_run.png
    art/generated/enemies/roof_rat_ambush.png
    art/generated/enemies/roof_rat_retreat.png
    art/generated/enemies/roof_rat_hurt.png
    art/generated/enemies/roof_rat_death.png
  </files>
  <action>
  **Sprite specifications:**

  **roof_rat_wall_idle.png (4 frames, 32x32):**
  - Flattened profile against wall surface
  - Subtle breathing animation
  - Semi-transparent overlay ready (for stealth effect)

  **roof_rat_wall_run.png (6 frames, 32x32):**
  - Profile view running along vertical surface
  - Legs moving in running cycle
  - Body slightly angled along surface

  **roof_rat_ambush.png (4 frames, 32x32):**
  - Frame 0: Squashed pre-drop pose
  - Frame 1-2: Dropping down with stretched body
  - Frame 3: Landing/crouch pose

  **roof_rat_retreat.png (4 frames, 32x32):**
  - Climbing upward scramble animation
  - Legs reaching up
  - Body stretched vertically

  **roof_rat_hurt.png (3 frames, 32x32):**
  - Recoil pose
  - Flash white
  - Return to neutral

  **roof_rat_death.png (4 frames, 32x32):**
  - Falling down animation
  - Fade out effect

  **Style guidelines:**
  - 16x16 actual sprite, 32x32 canvas with centering
  - Brown/gray fur with lighter underbelly
  - Pink nose, dark eyes
  - Pointed ears visible in profile
  - Long tail trailing behind
  - Nearest-neighbor scaling for pixel-perfect rendering
  </action>
  <verify>
  - All 6 sprite sheets created
  - Frame counts match animation definitions
  - Proper canvas size (32x32) and centered sprites
  - Style consistent with existing enemy sprites
  </verify>
  <done>All roof rat sprite sheets generated and ready for SpriteFrames</done>
</task>

<task type="auto">
  <name>Task 11: Update project.godot for roof rat integration</name>
  <files>
    project.godot
  </files>
  <action>
  **Ensure roof_rat.gd loads properly:**

  No major changes required if roof_rat.gd extends enemy_base.gd properly.
  Verify that the new state files are loadable.
  </action>
  <verify>
  - project.godot loads roof_rat.gd without errors
  </verify>
  <done>project.godot configured for roof rat enemy</done>
</task>

</tasks>

<wall_running_mechanics_detailed>

## Wall-Running System

### Surface Detection
1. RayCast2D extends horizontally from rat body
2. When raycast collides with World layer, rat is "on wall"
3. Rat orients sprite based on wall surface normal
4. Movement restricted to wall plane

### Wall States
- **Stealth**: Semi-transparent, squished, waiting for prey
- **Run**: Patrolling along wall surface
- **Ambush**: Dropping to attack player below
- **Retreat**: Climbing upward to escape
- **Cornered**: Escaping when trapped

### Surface Detection Code Pattern
```gdscript
func _is_on_surface() -> bool:
    wall_raycast.force_raycast_update()
    return wall_raycast.is_colliding()

func _update_wall_orientation() -> void:
    if wall_raycast.is_colliding():
        var normal = wall_raycast.get_collision_normal()
        player.sprite.rotation = normal.angle() - PI/2
```

### Wall Patrol Behavior
1. Rat moves along wall at WALL_PATROL_SPEED (80)
2. Patrol direction alternates or random at state entry
3. Raycast continuously validates surface contact
4. If surface lost, rat scans for new wall nearby
5. Falls to ground if no wall found (edge case)

### Ambush Trigger Conditions
1. Player must be within DETECTION_RANGE (280px)
2. Player Y position must be below rat (positive Y delta)
3. Player X position must be within 40px horizontal of rat
4. All three conditions met → transition to WallAmbush

### Retreat Pattern
1. Ambush completes → WallRetreat
2. Rat climbs upward for 0.8 seconds
3. Gains ~120 pixels of height
4. Searches for valid climb position
5. Returns to stealth on new position

### Corner Detection
1. Player within CORNER_DETECTION_RADIUS (64px)
2. No escape paths available (raycast in 3 upward directions)
3. Rat attempts escape along best path
4. Escapes upward and diagonally away from player
5. Returns to patrol after escaping

</wall_running_mechanics_detailed>

<code_snippets>

### Wall Surface Detection and Movement

```gdscript
extends State
class_name RatWallRun

const WALL_CHECK_INTERVAL: float = 0.1

var patrol_direction: int = 1
var wall_check_timer: float = 0.0

func _is_on_surface() -> bool:
    if not player.get("wall_raycast") or not player.wall_raycast:
        return false
    player.wall_raycast.force_raycast_update()
    return player.wall_raycast.is_colliding()

func update(delta: float) -> void:
    wall_check_timer += delta
    if wall_check_timer >= WALL_CHECK_INTERVAL:
        wall_check_timer = 0.0
        if not _is_on_surface():
            _find_new_surface()
            return
    
    player.velocity = Vector2(patrol_direction * player.WALL_PATROL_SPEED, 0)
    player.move_and_slide()
```

### Ambush Drop with Hitbox Timing

```gdscript
extends State
class_name RatWallAmbush

const AMBUSH_DURATION: float = 0.35
const HITBOX_START: float = 0.12
const HITBOX_END: float = 0.28
const DROP_HEIGHT: float = 80.0

var ambush_timer: float = 0.0
var hitbox_active: bool = false

func update(delta: float) -> void:
    ambush_timer += delta
    var progress = ambush_timer / AMBUSH_DURATION
    
    var y_offset = progress * DROP_HEIGHT
    player.global_position.y = ambush_start_pos.y + y_offset
    
    if progress >= HITBOX_START and progress < HITBOX_END:
        if not hitbox_active and player.hitbox:
            player.hitbox.monitoring = true
            player.hitbox.monitorable = true
            hitbox_active = true
    elif progress >= HITBOX_END:
        if hitbox_active and player.hitbox:
            player.hitbox.monitoring = false
            player.hitbox.monitorable = false
            hitbox_active = false
```

### Rooftop Spawner for Wall Rats

```gdscript
extends Node2D

@export var wall_offset: float = 20.0
@export var spawn_cooldown: float = 6.0

var _cooldown_timer: float = 0.0

func _ready() -> void:
    _cooldown_timer = 0.0

func _process(delta: float) -> void:
    _cooldown_timer -= delta
    if _cooldown_timer <= 0:
        _try_spawn_rat()
        _cooldown_timer = spawn_cooldown

func _try_spawn_rat() -> void:
    var player = get_tree().get_first_node_in_group("player")
    if not player:
        return
    
    var dist = global_position.distance_to(player.global_position)
    if dist > 350 or dist < 100:
        return
    
    var rat_scene = load("res://characters/enemies/roof_rat.tscn")
    var rat = rat_scene.instantiate()
    
    var surface_pos = global_position + Vector2(0, wall_offset)
    rat.global_position = surface_pos
    
    get_parent().add_child(rat)
    Events.roof_rat_ambush_started.emit(rat)
```

</code_snippets>

<verification>
1. Run the game and navigate to rooftop area with walls
2. Observe roof rat spawn on wall surface
3. Rat appears semi-transparent and squished (stealth mode)
4. Walk under the rat
5. Observe "!" telegraph appear
6. Rat drops down with hitbox active
7. Take damage if hit by drop
8. Rat retreats upward after ambush
9. Approach rat while it's on wall
10. Observe rat transition to ambush if you're below
11. Corner rat against wall with player proximity
12. Observe escape behavior climbing upward
13. Attack rat until HP depleted
14. Observe death animation (fall and fade)
15. Verify no errors in console
</verification>

<success_criteria>
- Roof Rats spawn on wall surfaces with correct orientation
- Rats are semi-transparent and squished while in stealth
- Ambush triggers when player walks directly below
- Telegraph displays before drop attack
- Hitbox only active during drop (not before/after)
- Rats retreat upward after ambush completes
- Corner detection works (player nearby + no escape paths)
- Escape moves rat to valid climb position
- Death animation plays correctly (fall + fade)
- No Polygon2D or placeholder graphics
- All 5 states transition correctly
- Raycast-based surface detection works reliably
</success_criteria>

<output>
After completion, create `docs/phases/36-rooftops/36-02-SUMMARY.md`
</output>
