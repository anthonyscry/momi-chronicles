---
phase: 36-rooftops
plan: 02
type: execute
wave: 1
depends_on: ["36-01"]
files_created:
  - characters/enemies/gnome.tscn
  - characters/enemies/gnome.gd
  - characters/enemies/states/gnome_idle.gd
  - characters/enemies/states/gnome_telegraph.gd
  - characters/enemies/states/gnome_throw.gd
  - characters/enemies/states/gnome_cooldown.gd
  - characters/enemies/projectiles/gnome_bomb.tscn
  - characters/enemies/projectiles/gnome_bomb.gd
  - art/generated/enemies/gnome_idle.png
  - art/generated/enemies/gnome_telegraph.png
  - art/generated/enemies/gnome_throw.png
  - art/generated/enemies/gnome_hurt.png
  - art/generated/enemies/gnome_death.png
  - art/generated/enemies/gnome_bomb.png
  - art/generated/enemies/gnome_explosion.png
files_modified:
  - project.godot
  - autoloads/events.gd
  - characters/enemies/enemy_base.gd
autonomous: true

must_haves:
  truths:
    - "Garden Gnome is stationary (no movement states)"
    - "Gnome throws explosive bombs with fuse timer"
    - "Orange pulsing '!' telegraph precedes each throw"
    - "Bombs explode on impact OR when fuse ends"
    - "AOE explosion damages player in radius"
    - "Gnome cycles: Idle → Telegraph → Throw → Cooldown → Idle"
    - "Gnome has 4 states total (no movement)"
  artifacts:
    - path: "characters/enemies/gnome.tscn"
      provides: "Stationary gnome enemy with bomb throwing behavior"
      contains: "CharacterBody2D, AnimatedSprite2D, CollisionShape2D, TelegraphSprite"
    - path: "characters/enemies/states/gnome_telegraph.gd"
      provides: "Orange pulsing telegraph animation"
      contains: "Sprite rotation, pulsing scale, "!" visual indicator"
    - path: "characters/enemies/projectiles/gnome_bomb.tscn"
      provides: "Explosive projectile with fuse"
      contains: "Area2D, Timer for fuse, AOE collision shape, particles"
    - path: "characters/enemies/states/gnome_throw.gd"
      provides: "Bomb throwing animation and projectile spawning"
      contains: "Animation trigger, projectile instantiation, arc trajectory"
  key_links:
    - from: "gnome.tscn"
      to: "world/rooftop_spawners"
      via: "Spawner places gnome at fixed position"
    - from: "gnome_telegraph.gd"
      to: "gnome_throw.gd"
      via: "Telegraph completes → triggers Throw state"
    - from: "gnome_throw.gd"
      to: "gnome_bomb.tscn"
      via: "Instantiates bomb at throw position"
    - from: "gnome_bomb.gd"
      to: "Events"
      via: "Emits bomb_exploded for audio/effects"

<objective>
Create a Garden Gnome enemy - stationary sentry that throws explosive projectiles with fuse timers. Gnomes provide predictable but dangerous encounters, teaching players to dodge both the bomb throws and the resulting explosions.

Purpose: Garden Gnomes serve as stationary turret enemies on rooftops, providing combat pacing between mobile pigeon flocks. Their telegraphed attacks teach timing-based dodge mechanics.
Output: Fully functional stationary gnome enemy with 4-state cycle, explosive projectiles, and AOE damage.
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
@characters/enemies/pigeon.tscn
@characters/enemies/states/enemy_idle.gd
@characters/enemies/states/enemy_hurt.gd
@characters/enemies/states/enemy_death.gd
@autoloads/events.gd
@world/rooftop_spawners.gd
</context>

<tasks>

<task type="auto">
  <name>Task 1: Define Gnome enemy stats and constants</name>
  <files>
    characters/enemies/gnome.gd
  </files>
  <action>
  **Create gnome.gd with stats:**

  ```gdscript
  extends "res://characters/enemies/enemy_base.gd"

  class_name Gnome

  const DETECTION_RANGE: float = 200.0
  const ATTACK_RANGE: float = 300.0
  const BOMB_DAMAGE: float = 25.0
  const BOMB_AOE_RADIUS: float = 64.0
  const BOMB_FUSE_TIME: float = 1.5
  const BOMB_ARC_HEIGHT: float = 80.0
  const THROW_SPEED: float = 180.0
  const TELEGRAPH_DURATION: float = 0.8
  const COOLDOWN_DURATION: float = 2.0
  const THROW_COOLDOWN: float = 3.0

  var can_attack: bool = true
  var current_target: Node = null

  func _ready() -> void:
      health = HealthComponent.new(60, 60)
      hitbox = HitboxComponent.new()
      hitbox.damage = BOMB_DAMAGE
      hitbox.aoe_radius = BOMB_AOE_RADIUS
      hurtbox = HurtboxComponent.new()
      hurtbox.layer = 5
      add_child(hitbox)
      add_child(hurtbox)
      health.health_changed.connect(_on_health_changed)
      _setup_detection_area()
  ```

  **Stats Summary:**
  - HP: 60 (tougher than pigeons, stationary = longer exposure)
  - Bomb Damage: 25 (AOE, hits multiple targets)
  - AOE Radius: 64 pixels
  - Fuse Time: 1.5 seconds before automatic explosion
  - Detection Range: 200 pixels
  - Attack Range: 300 pixels (throw range)
  - Telegraph Duration: 0.8 seconds
  - Cooldown Duration: 2.0 seconds between cycles
  - Throw Cooldown: 3.0 seconds overall
  </action>
  <verify>
  - gnome.gd has all const declarations
  - Stats match requirements (60 HP, 25 damage, 64 AOE radius)
  - Signals connected for health changes
  - Stationary (no velocity/movement code)
  </verify>
  <done>gnome.gd created with all stats, constants, and signal connections</done>
</task>

<task type="auto">
  <name>Task 2: Create gnome.tscn scene</name>
  <files>
    characters/enemies/gnome.tscn
  </files>
  <action>
  **Scene structure:**

  ```
  Gnome (CharacterBody2D)
  ├── Sprite2D (AnimatedSprite2D)
  │   └── SpriteFrames: idle, telegraph, throw, hurt, death
  ├── CollisionShape2D (Circle, radius 12)
  ├── DetectionArea (Area2D)
  │   └── CollisionShape2D (Circle, radius 200)
  ├── Hurtbox (Area2D)
  │   └── CollisionShape2D (Circle, radius 16)
  ├── Hitbox (Area2D) - passive contact damage
  │   └── CollisionShape2D (Circle, radius 12)
  ├── TelegraphSprite (Node2D)
  │   ├── Sprite2D (Icon, "!" symbol, orange)
  │   └── CollisionShape2D (optional, for visual only)
  ├── StateMachine (Node)
  │   ├── GnomeIdle
  │   ├── GnomeTelegraph
  │   ├── GnomeThrow
  │   ├── GnomeCooldown
  │   ├── Hurt
  │   └── Death
  └── HealthComponent (Node)
  ```

  **SpriteFrames configuration:**
  - idle: 4 frames, 0.3s each, slight breathing animation
  - telegraph: 8 frames, 0.1s each, pulsing "!" with color shift
  - throw: 4 frames, 0.15s each, arm motion throwing
  - hurt: 3 frames, 0.15s each, flash white/recoil
  - death: 4 frames, 0.2s each, fall over and fade

  **TelegraphSprite configuration:**
  - Position: Above gnome head (y: -32)
  - Sprite: Orange "!" symbol, 16x16
  - Animation: Scale pulse (1.0 → 1.3 → 1.0) and color intensity
  - Only visible during GnomeTelegraph state

  **Collision layers:**
  - Layer 3: Enemy body
  - Layer 5: Enemy hurtbox
  - Layer 7: Enemy hitbox (passive contact)
  </action>
  <verify>
  - Scene has all required nodes
  - SpriteFrames has all 5 animations
  - TelegraphSprite positioned above gnome
  - DetectionArea matches DETECTION_RANGE (200px)
  - No movement/motion nodes (stationary enemy)
  </verify>
  <done>gnome.tscn scene created with all nodes and SpriteFrames</done>
</task>

<task type="auto">
  <name>Task 3: Create GnomeIdle state</name>
  <files>
    characters/enemies/states/gnome_idle.gd
  </files>
  <action>
  **gnome_idle.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_idle.gd"

  var scan_timer: float = 0.0
  const SCAN_INTERVAL: float = 0.5

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("idle")
      
      _hide_telegraph()
      scan_timer = 0.0

  func _hide_telegraph() -> void:
      if player.has_node("TelegraphSprite"):
          player.get_node("TelegraphSprite").visible = false

  func update(delta: float) -> void:
      scan_timer += delta
      
      if scan_timer >= SCAN_INTERVAL:
          scan_timer = 0.0
          _check_for_player()

  func _check_for_player() -> void:
      var player_node = _get_player_in_range()
      if player_node:
          state_machine.transition_to("GnomeTelegraph")
          return

  func _get_player_in_range() -> Node:
      var detection = player.get_node_or_null("DetectionArea")
      if detection:
          var bodies = detection.get_overlapping_bodies()
          for body in bodies:
              if body.is_in_group("player"):
                  return body
      return null

  func exit() -> void:
      scan_timer = 0.0
  ```

  **Behavior:**
  - Gnome stationary, plays idle animation
  - Scans for player every 0.5 seconds
  - TelegraphSprite hidden during idle
  - Transitions to GnomeTelegraph when player enters range
  </action>
  <verify>
  - State has enter/update/exit functions
  - DetectionArea used for player scanning
  - TelegraphSprite hidden on enter
  - 0.5 second scan interval
  </verify>
  <done>GnomeIdle state created with player detection</done>
</task>

<task type="auto">
  <name>Task 4: Create GnomeTelegraph state</name>
  <files>
    characters/enemies/states/gnome_telegraph.gd
  </files>
  <action>
  **gnome_telegraph.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_idle.gd"

  const PULSE_SPEED: float = 8.0
  const MAX_SCALE: float = 1.4
  const MIN_SCALE: float = 1.0

  var telegraph_time: float = 0.0
  var pulse_phase: float = 0.0
  var telegraph_sprite: Node2D = null

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("telegraph")
      
      _show_telegraph()
      telegraph_time = 0.0
      pulse_phase = 0.0

  func _show_telegraph() -> void:
      telegraph_sprite = player.get_node_or_null("TelegraphSprite")
      if telegraph_sprite:
          telegraph_sprite.visible = true
          var sprite = telegraph_sprite.get_node_or_null("Sprite2D")
          if sprite:
              sprite.modulate = Color(1.0, 0.5, 0.0, 1.0)

  func update(delta: float) -> void:
      telegraph_time += delta
      pulse_phase += delta * PULSE_SPEED
      
      _animate_telegraph(delta)
      
      if telegraph_time >= player.TELEGRAPH_DURATION:
          _complete_telegraph()

  func _animate_telegraph(delta: float) -> void:
      if not telegraph_sprite:
          return
      
      var sprite = telegraph_sprite.get_node_or_null("Sprite2D")
      if not sprite:
          return
      
      var scale_factor = MAX_SCALE - (MAX_SCALE - MIN_SCALE) * (0.5 + 0.5 * sin(pulse_phase))
      sprite.scale = Vector2(scale_factor, scale_factor)
      
      var intensity = 0.7 + 0.3 * (0.5 + 0.5 * sin(pulse_phase * 1.5))
      sprite.modulate = Color(1.0, intensity * 0.5, 0.0, 1.0)
      
      telegraph_sprite.rotation = sin(pulse_phase * 0.5) * 0.1

  func _complete_telegraph() -> void:
      state_machine.transition_to("GnomeThrow")

  func exit() -> void:
      _hide_telegraph()
      telegraph_time = 0.0
      pulse_phase = 0.0

  func _hide_telegraph() -> void:
      if telegraph_sprite:
          telegraph_sprite.visible = false
          telegraph_sprite.scale = Vector2.ONE
          telegraph_sprite.rotation = 0.0
  ```

  **Telegraph Animation:**
  - Orange "!" pulses in scale (1.0 → 1.4 → 1.0)
  - Color intensity oscillates (orange brightness)
  - Slight rotation wobble for attention
  - Duration: 0.8 seconds (configurable via player.TELEGRAPH_DURATION)
  - Visual cue gives player time to dodge
  </action>
  <verify>
  - State has pulsing scale animation
  - Orange color modulation working
  - TelegraphSprite visible only during this state
  - Transitions to GnomeThrow after TELEGRAPH_DURATION
  </verify>
  <done>GnomeTelegraph state created with orange pulsing "!" animation</done>
</task>

<task type="auto">
  <name>Task 5: Create GnomeThrow state</name>
  <files>
    characters/enemies/states/gnome_throw.gd
  </files>
  <action>
  **gnome_throw.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_idle.gd"

  var throw_animation_played: bool = false
  var bomb_instance: Node = null

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("throw")
      
      throw_animation_played = false
      bomb_instance = null

  func update(delta: float) -> void:
      if player.sprite and not throw_animation_played:
          var frame = player.sprite.frame
          if frame >= 2:
              throw_animation_played = true
              _spawn_bomb()

      if throw_animation_played:
          if player.sprite and player.sprite.is_playing():
              if player.sprite.frame >= player.sprite.sprite_frames.get_frame_count("throw") - 1:
                  if not player.sprite.is_playing():
                      state_machine.transition_to("GnomeCooldown")
          else:
              state_machine.transition_to("GnomeCooldown")

  func _spawn_bomb() -> void:
      var target = _get_player_position()
      if target == Vector2.ZERO:
          target = player.global_position + Vector2(player.ATTACK_RANGE, 0)
      
      bomb_instance = _create_bomb(target)
      if bomb_instance:
          var start_pos = player.global_position + Vector2(0, -16)
          bomb_instance.global_position = start_pos
          get_parent().add_child(bomb_instance)
          
          Events.gnome_threw_bomb.emit(player, bomb_instance)

  func _get_player_position() -> Vector2:
      var player_node = get_tree().get_first_node_in_group("player")
      if player_node and is_instance_valid(player_node):
          return player_node.global_position
      return Vector2.ZERO

  func _create_bomb(target: Vector2) -> Node:
      var bomb_scene = preload("res://characters/enemies/projectiles/gnome_bomb.tscn")
      var bomb = bomb_scene.instantiate()
      
      bomb.fuse_time = player.BOMB_FUSE_TIME
      bomb.aoe_radius = player.BOMB_AOE_RADIUS
      bomb.damage = player.BOMB_DAMAGE
      bomb.target_position = target
      bomb.throw_height = player.BOMB_ARC_HEIGHT
      bomb.throw_speed = player.THROW_SPEED
      bomb.source_gnome = player
      
      return bomb

  func exit() -> void:
      throw_animation_played = false
      bomb_instance = null
  ```

  **Throw Mechanics:**
  - Plays throw animation (arm motion)
  - Spawns bomb at animation frame 2 (mid-throw)
  - Bomb calculates arc trajectory to player position
  - Emits signal for audio effects
  - Transitions to Cooldown after animation completes
  </action>
  <verify>
  - Throw animation triggers bomb spawn at correct frame
  - Bomb instantiated with correct stats (fuse, AOE, damage)
  - Arc trajectory calculation in bomb.gd
  - Signal emitted for audio system
  </verify>
  <done>GnomeThrow state created with bomb spawning and arc trajectory</done>
</task>

<task type="auto">
  <name>Task 6: Create GnomeCooldown state</name>
  <files>
    characters/enemies/states/gnome_cooldown.gd
  </files>
  <action>
  **gnome_cooldown.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_idle.gd"

  var cooldown_timer: float = 0.0
  var player_in_range: bool = false

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("idle")
      
      cooldown_timer = 0.0
      player_in_range = false

  func update(delta: float) -> void:
      cooldown_timer += delta
      
      _check_player_proximity()
      
      if cooldown_timer >= player.COOLDOWN_DURATION:
          if player_in_range:
              state_machine.transition_to("GnomeTelegraph")
          else:
              state_machine.transition_to("GnomeIdle")

  func _check_player_proximity() -> void:
      var player_node = get_tree().get_first_node_in_group("player")
      if player_node:
          var dist = player.global_position.distance_to(player_node.global_position)
          player_in_range = dist < player.ATTACK_RANGE
      else:
          player_in_range = false

  func exit() -> void:
      cooldown_timer = 0.0
  ```

  **Cooldown Behavior:**
  - Plays idle animation during cooldown
  - Monitors if player is still in range
  - After cooldown, returns to Telegraph (if player close) or Idle
  - Prevents infinite telegraph loops if player leaves range
  </action>
  <verify>
  - Cooldown timer respects COOLDOWN_DURATION
  - Player proximity checked every frame
  - Correct state transitions based on player presence
  </verify>
  <done>GnomeCooldown state created with player proximity check</done>
</task>

<task type="auto">
  <name>Task 7: Create GnomeHurt and GnomeDeath states</name>
  <files>
    characters/enemies/states/gnome_hurt.gd
    characters/enemies/states/gnome_death.gd
  </files>
  <action>
  **gnome_hurt.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_hurt.gd"

  const PAUSE_DURATION: float = 0.4
  var pause_time: float = 0.0

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("hurt")
      
      pause_time = 0.0
      _interrupt_any_action()

  func _interrupt_any_action() -> void:
      if player.has_node("TelegraphSprite"):
          player.get_node("TelegraphSprite").visible = false

  func update(delta: float) -> void:
      pause_time += delta
      
      if pause_time >= PAUSE_DURATION:
          if player.sprite and player.sprite.is_playing():
              if not player.sprite.is_playing():
                  _return_to_cycle()
          else:
              _return_to_cycle()

  func _return_to_cycle() -> void:
      var player_node = get_tree().get_first_node_in_group("player")
      if player_node:
          var dist = player.global_position.distance_to(player_node.global_position)
          if dist < player.ATTACK_RANGE:
              state_machine.transition_to("GnomeTelegraph")
          else:
              state_machine.transition_to("GnomeIdle")
      else:
          state_machine.transition_to("GnomeIdle")

  func exit() -> void:
      pause_time = 0.0
  ```

  **gnome_death.gd:**

  ```gdscript
  extends "res://characters/enemies/states/enemy_death.gd"

  const DEATH_DURATION: float = 0.6
  var death_time: float = 0.0

  func enter() -> void:
      player.velocity = Vector2.ZERO
      
      if player.sprite:
          player.sprite.play("death")
      
      player.hitbox.monitoring = false
      player.hitbox.monitorable = false
      
      if player.has_node("TelegraphSprite"):
          player.get_node("TelegraphSprite").visible = false
      
      death_time = 0.0
      Events.gnome_died.emit(player)

  func update(delta: float) -> void:
      death_time += delta
      
      if player.sprite:
          player.sprite.modulate.a = 1.0 - (death_time / DEATH_DURATION)
      
      if death_time >= DEATH_DURATION:
          player.queue_free()

  func exit() -> void:
      pass
  ```

  **Special Behavior:**
  - Hurt state interrupts telegraph/throw animations
  - Hides TelegraphSprite on hurt
  - Death fades out sprite over 0.6 seconds
  - Both emit events for audio/UI feedback
  </action>
  <verify>
  - Hurt state interrupts current action
  - TelegraphSprite hidden on hurt/death
  - Death state fades sprite alpha
  - Events emitted for system integration
  </verify>
  <done>GnomeHurt and GnomeDeath states created with proper state handling</done>
</task>

<task type="auto">
  <name>Task 8: Create gnome_bomb.gd projectile script</name>
  <files>
    characters/enemies/projectiles/gnome_bomb.gd
  </files>
  <action>
  **gnome_bomb.gd:**

  ```gdscript
  extends Area2D

  class_name GnomeBomb

  signal exploded(bomb: Node, position: Vector2, radius: float)

  var fuse_time: float = 1.5
  var aoe_radius: float = 64.0
  var damage: float = 25.0
  var target_position: Vector2 = Vector2.ZERO
  var throw_height: float = 80.0
  var throw_speed: float = 180.0
  var source_gnome: Node = null

  var _time_alive: float = 0.0
  var _arc_start: Vector2 = Vector2.ZERO
  var _landed: bool = false
  var _exploded: bool = false

  func _ready() -> void:
      _time_alive = 0.0
      _landed = false
      _exploded = false
      _arc_start = global_position
      
      _setup_collision()
      _create_fuse_particle()

  func _setup_collision() -> void:
      var collision = CollisionShape2D.new()
      var circle = CircleShape2D.new()
      circle.radius = 12.0
      collision.shape = circle
      collision.name = "CollisionShape2D"
      add_child(collision)
      
      monitoring = true
      monitorable = true
      area_entered.connect(_on_area_entered)

  func _create_fuse_particle() -> void:
      var timer = get_tree().create_timer(fuse_time)
      timer.timeout.connect(_on_fuse_expire)

  func _process(delta: float) -> void:
      if _exploded:
          return
      
      _time_alive += delta
      
      if not _landed:
          _update_arc_trajectory(delta)
      else:
          _pulse_effect(delta)

  func _update_arc_trajectory(delta: float) -> void:
      var to_target = target_position - _arc_start
      var distance = to_target.length()
      var direction = to_target.normalized()
      
      var total_time = distance / throw_speed
      var progress = _time_alive / total_time
      
      if progress >= 1.0:
          _landed = true
          global_position = target_position
          return
      
      var horizontal = direction * throw_speed * _time_alive
      var parabolic = 4 * throw_height * progress * (1.0 - progress)
      
      global_position = _arc_start + horizontal + Vector2(0, -parabolic)
      
      if sprite:
          sprite.rotation = direction.angle() + PI * 0.25 * progress

  func _pulse_effect(delta: float) -> void:
      var pulse_intensity = sin(_time_alive * 15.0) * 0.3 + 0.7
      if sprite:
          sprite.modulate = Color(1.0, pulse_intensity * 0.5, 0.0, 1.0)

  func _on_area_entered(area: Area2D) -> void:
      if _exploded or not _landed:
          return
      
      if area.get_parent().is_in_group("player"):
          _explode()

  func _on_fuse_expire() -> void:
      if not _exploded:
          _explode()

  func _explode() -> void:
      if _exploded:
          return
      _exploded = true
      
      emit_signal("exploded", self, global_position, aoe_radius)
      
      _create_explosion_effect()
      _apply_aoe_damage()
      
      queue_free()

  func _create_explosion_effect() -> void:
      var explosion = preload("res://art/generated/enemies/gnome_explosion.tscn").instantiate()
      explosion.global_position = global_position
      get_parent().add_child(explosion)
      
      if has_method("play"):
          await get_tree().create_timer(0.5).timeout
          if is_instance_valid(explosion):
              explosion.queue_free()

  func _apply_aoe_damage() -> void:
      var bodies = get_overlapping_bodies()
      for body in bodies:
          if body.is_in_group("player"):
              var dist = global_position.distance_to(body.global_position)
              if dist <= aoe_radius:
                  var damage_event = DamageEvent.new()
                  damage_event.amount = damage
                  damage_event.source = source_gnome
                  damage_event.type = DamageEvent.Type.EXPLOSIVE
                  body.take_damage(damage_event)

  func get_sprite() -> Node2D:
      return get_node_or_null("Sprite2D")

  var sprite: Node2D:
      get:
          return get_sprite()
  ```

  **Bomb Behavior:**
  - Arc trajectory from throw point to target
  - Sparks fuse particle/timer
  - Lands at target after travel time
  - Explodes on impact OR fuse end (whichever first)
  - AOE damage to all bodies in radius
  - Visual explosion effect on detonation
  </action>
  <verify>
  - Arc trajectory calculated correctly
  - Fuse timer triggers explosion
  - Impact detection works
  - AOE damage applied to all in radius
  - Explosion effect spawned
  </verify>
  <done>gnome_bomb.gd created with arc trajectory, fuse, and AOE explosion</done>
</task>

<task type="auto">
  <name>Task 9: Create gnome_bomb.tscn scene</name>
  <files>
    characters/enemies/projectiles/gnome_bomb.tscn
  </files>
  <action>
  **Scene structure:**

  ```
  GnomeBomb (Area2D)
  ├── Sprite2D (AnimatedSprite2D)
  │   └── SpriteFrames: bomb_fuse, bomb_landed, explosion
  ├── CollisionShape2D (Circle, radius 12)
  └── Timer (for fuse - optional, using code timer)
  ```

  **SpriteFrames configuration:**
  - bomb_fuse: 4 frames, 0.2s each, sparking fuse
  - bomb_landed: 2 frames, 0.3s each, pulsing glow
  - explosion: 8 frames, 0.08s each, expanding blast

  **Scene properties:**
  - Layer 7: Enemy hitbox (bomb damage to player)
  - Monitorable: true
  - Monitoring: true
  </action>
  <verify>
  - Scene has Area2D as root
  - SpriteFrames has all animations
  - Collision shape matches radius
  </verify>
  <done>gnome_bomb.tscn scene created with animations</done>
</task>

<task type="auto">
  <name>Task 10: Add gnome signals to Events autoload</name>
  <files>
    autoloads/events.gd
  </files>
  <action>
  **Add signals to Events:**

  ```gdscript
  signal gnome_threw_bomb(gnome: Node, bomb: Node)
  signal gnome_bomb_exploded(position: Vector2, radius: float)
  signal gnome_died(gnome: Node)
  signal gnome_hurt(gnome: Node, damage: float)
  ```

  **Integration with existing pigeon signals:**
  - gnome signals are separate from pigeon flock signals
  - gnome_bomb_exploded can share explosion effects with other sources
  - gnome_died similar pattern to pigeon_died
  </action>
  <verify>
  - All gnome signals added to Events
  - Signal signatures match state implementations
  </verify>
  <done>Events autoload updated with gnome signals</done>
</task>

<task type="auto">
  <name>Task 11: Create generated gnome sprites</name>
  <files>
    art/generated/enemies/gnome_idle.png
    art/generated/enemies/gnome_telegraph.png
    art/generated/enemies/gnome_throw.png
    art/generated/enemies/gnome_hurt.png
    art/generated/enemies/gnome_death.png
    art/generated/enemies/gnome_bomb.png
    art/generated/enemies/gnome_explosion.png
  </files>
  <action>
  **Sprite specifications:**

  **gnome_idle.png (4 frames, 32x32):**
  - Classic garden gnome: red hat, beard, blue shirt
  - Frames 0-1: Standing still, slight breathing
  - Frames 2-3: Same with feather/hat movement

  **gnome_telegraph.png (8 frames, 32x32):**
  - Same base gnome, orange overlay/glow
  - Frames 0-2: "!" appears above head, small to large
  - Frames 3-5: Pulse effect, "!" grows/shrinks
  - Frames 6-7: Final pulse, arm starting to raise

  **gnome_throw.png (4 frames, 32x32):**
  - Arm motion: down → back → forward → release
  - Frame 0: Arm down
  - Frame 1: Arm back (wind up)
  - Frame 2: Arm forward (release point)
  - Frame 3: Arm returning to side

  **gnome_hurt.png (3 frames, 32x32):**
  - Frame 0: Normal pose
  - Frame 1: Flash white/recoil backward
  - Frame 2: Return to neutral

  **gnome_death.png (4 frames, 32x32):**
  - Frames 0-1: Tip over (rotation + position shift)
  - Frames 2-3: Fade out (alpha reduction)

  **gnome_bomb.png (4 frames, 16x16):**
  - Black spherical bomb with fuse
  - Frames 0-1: Fuse sparking (small particles)
  - Frames 2-3: Fuse burning brighter

  **gnome_explosion.png (8 frames, 64x64):**
  - Orange/red explosion expanding
  - Frames 0-2: Small spark expanding outward
  - Frames 3-5: Full blast, brightest point
  - Frames 6-8: Fading, smoke effect

  **Style guidelines:**
  - 16x16 actual sprite, 32x32 canvas (16x16 for bomb, 64x64 for explosion)
  - Red pointed hat (iconic gnome)
  - White beard
  - Blue shirt, black vest
  - Black bomb with brown fuse
  - Orange explosion with yellow core
  - Nearest-neighbor scaling for pixel-perfect rendering
  </action>
  <verify>
  - All 7 sprite sheets created
  - Frame counts match animation definitions
  - Proper canvas sizes (32x32 gnome, 16x16 bomb, 64x64 explosion)
  - Style consistent with existing enemy sprites
  - Orange telegraph color matches specification
  </verify>
  <done>All gnome sprite sheets generated and ready for SpriteFrames</done>
</task>

<task type="auto">
  <name>Task 12: Update project.godot for gnome integration</name>
  <files>
    project.godot
  </files>
  <action>
  **Add gnome class to autoload if needed, or ensure it's loadable:**

  No changes required if gnome.gd extends enemy_base.gd properly.

  **Ensure projectile resources are loadable:**
  - gnome_bomb.tscn should be loadable
  </action>
  <verify>
  - project.godot loads gnome.gd without errors
  - gnome_bomb.tscn is valid resource
  </verify>
  <done>project.godot configured for gnome enemy</done>
</task>

</tasks>

<state_machine_diagram>

## Gnome State Machine (4 States + Hurt/Death)

```
                    ┌─────────────────────────────────────────┐
                    │           PLAYER ENTERS RANGE            │
                    │              (200px radius)              │
                    └─────────────────┬───────────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────────────┐
                    │              GnomeIdle                  │
                    │  • Plays idle animation                 │
                    │  • Scans for player every 0.5s          │
                    │  • TelegraphSprite hidden               │
                    └─────────────────┬───────────────────────┘
                                      │
                         ┌────────────┴────────────┐
                         │  Player in range?       │
                         │  (ATTACK_RANGE: 300px)  │
                         └────────────┬────────────┘
                                      │
                     YES ────────────┘ │ NO
                                     │
                                     ▼
                    ┌─────────────────────────────────────────┐
                    │            GnomeTelegraph              │
                    │  • Orange "!" pulses (0.8s)            │
                    │  • Scale: 1.0 → 1.4 → 1.0              │
                    │  • Color intensity oscillates          │
                    │  • Slight rotation wobble              │
                    │  • TelegraphSprite visible             │
                    └─────────────────┬───────────────────────┘
                                      │
                    TELEGRAPH COMPLETE │
                    (0.8s elapsed)     │
                                      ▼
                    ┌─────────────────────────────────────────┐
                    │              GnomeThrow                 │
                    │  • Plays throw animation               │
                    │  • Spawns bomb at frame 2              │
                    │  • Bomb arcs to player position        │
                    │  • Emits gnome_threw_bomb signal       │
                    └─────────────────┬───────────────────────┘
                                      │
                    ANIMATION COMPLETE │
                                      ▼
                    ┌─────────────────────────────────────────┐
                    │            GnomeCooldown                │
                    │  • Plays idle animation                │
                    │  • Timer: 2.0 seconds                  │
                    │  • Monitors player proximity           │
                    └─────────────────┬───────────────────────┘
                                      │
                    COOLDOWN COMPLETE │
                                      │
                         ┌────────────┴────────────┐
                         │  Player still in range? │
                         └────────────┬────────────┘
                                      │
                     YES ────────────┘ │ NO
                                     │    │
                                     ▼    ▼
                    ┌──────┐   ┌───────────────────────────────┐
                    │Tele- │   │          GnomeIdle            │
                    │graph │   │  (Returns to scanning loop)   │
                    └──┬───┘   └───────────────────────────────┘
                       │                   ▲
                       └───────────────────┘
                    (If player leaves during cooldown,
                     returns to Idle and stops scanning)

                    ╔════════════════════════════════════════════╗
                    ║              HURT / DEATH                  ║
                    ╠════════════════════════════════════════════╣
                    ║  From any state:                           ║
                    ║  • Interrupt current action                ║
                    ║  • Hide TelegraphSprite                    ║
                    ║  • Play hurt animation (0.4s pause)        ║
                    ║  • Return to cycle or death                ║
                    ║                                            ║
                    ║  Death:                                    ║
                    ║  • Play death animation                    ║
                    ║  • Fade alpha over 0.6s                    ║
                    ║  • Emit gnome_died signal                  ║
                    ║  • queue_free()                            ║
                    ╚════════════════════════════════════════════╝
```

</state_machine_diagram>

<projectile_behavior>

## Bomb Trajectory and Explosion

### Arc Trajectory Formula
```
horizontal_position = direction * throw_speed * time_alive
vertical_offset = 4 * throw_height * progress * (1 - progress)
final_position = start + horizontal + Vector2(0, -vertical_offset)

Where:
- progress = time_alive / total_travel_time
- total_travel_time = distance_to_target / throw_speed
- throw_height = 80 pixels (peak of arc)
```

### Explosion Trigger Conditions
1. **Impact:** If bomb collides with player body → explode immediately
2. **Fuse End:** If fuse timer (1.5s) expires → explode at current position

### AOE Damage Application
```
for each body in get_overlapping_bodies():
    if body.is_in_group("player"):
        distance = bomb.position.distance_to(body.position)
        if distance <= AOE_RADIUS (64px):
            apply_damage(damage=25, type=EXPLOSIVE)
```

### Visual Effects Timeline
1. **Throw → Travel (0.5-1.0s):** Bomb arcs through air, rotates
2. **Landed → Fuse End (0.5-1.0s):** Bomb pulses on ground
3. **Explosion (0.5s):** Explosion sprite expands and fades
4. **Cleanup:** Both bomb and explosion effects removed

</projectile_behavior>

<code_snippets>

### Bomb Arc Calculation

```gdscript
func _update_arc_trajectory(delta: float) -> void:
    var to_target = target_position - _arc_start
    var distance = to_target.length()
    var direction = to_target.normalized()
    
    var total_time = distance / throw_speed
    var progress = _time_alive / total_time
    
    if progress >= 1.0:
        _landed = true
        global_position = target_position
        return
    
    var horizontal = direction * throw_speed * _time_alive
    var parabolic = 4 * throw_height * progress * (1.0 - progress)
    
    global_position = _arc_start + horizontal + Vector2(0, -parabolic)
```

### Telegraph Pulse Animation

```gdscript
func _animate_telegraph(delta: float) -> void:
    pulse_phase += delta * PULSE_SPEED
    
    var scale_factor = MAX_SCALE - (MAX_SCALE - MIN_SCALE) * (0.5 + 0.5 * sin(pulse_phase))
    sprite.scale = Vector2(scale_factor, scale_factor)
    
    var intensity = 0.7 + 0.3 * (0.5 + 0.5 * sin(pulse_phase * 1.5))
    sprite.modulate = Color(1.0, intensity * 0.5, 0.0, 1.0)
```

### Rooftop Spawner Usage

```gdscript
extends Node2D

@export var gnome_scene: PackedScene

func _ready() -> void:
    gnome_scene = load("res://characters/enemies/gnome.tscn")

func spawn_gnome(position: Vector2) -> void:
    var gnome = gnome_scene.instantiate()
    gnome.global_position = position
    get_parent().add_child(gnome)
    Events.gnome_spawned.emit(gnome)
```

</code_snippets>

<verification>
1. Run the game and navigate to rooftop area
2. Observe gnome at spawn position (stationary)
3. Approach within detection range (200px)
4. Observe orange pulsing "!" telegraph (0.8s)
5. Watch throw animation and bomb arc to player position
6. Note bomb travel time and fuse behavior
7. Step away from bomb: observe AOE explosion when fuse ends
8. Get hit by bomb: observe explosion damage
9. Wait through cooldown (2.0s)
10. Observe gnome resume attack cycle
11. Attack gnome: observe hurt animation and interrupt
12. Reduce gnome to 0 HP: observe death fade
13. Verify no errors in console
14. Test multiple gnomes: verify independent attack cycles
</verification>

<success_criteria>
- Gnome stationary (no movement toward player)
- Orange pulsing "!" telegraph visible during GnomeTelegraph state
- Telegraph duration: 0.8 seconds before throw
- Bomb arcs from gnome to player position
- Bomb explodes on impact OR fuse end (1.5s)
- AOE explosion damages player in 64px radius
- Cooldown state prevents rapid attack cycling
- Hurt state interrupts telegraph/throw properly
- Death state fades sprite and removes from scene
- No placeholder graphics - all pixel art sprites
- Multiple gnomes attack independently
</success_criteria>

<output>
After completion, create `docs/phases/36-rooftops/36-02-SUMMARY.md`
</output>
