extends State
class_name PlayerGroundPound
## Ground Pound - AoE attack that damages and stuns nearby enemies.
## Unlocked at level 5.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Level required to use this ability
const UNLOCK_LEVEL: int = 5

## Cooldown between uses
const COOLDOWN: float = 3.0

## Jump up duration
const JUMP_DURATION: float = 0.25

## Slam down duration
const SLAM_DURATION: float = 0.15

## Recovery duration
const RECOVERY_DURATION: float = 0.3

## Area of effect radius
const AOE_RADIUS: float = 50.0

## Damage dealt
const DAMAGE: int = 40

## Stun duration applied to enemies
const STUN_DURATION: float = 1.5

## Jump height (visual only in 2D)
const JUMP_HEIGHT: float = 20.0

# =============================================================================
# STATE
# =============================================================================

enum Phase { JUMP, SLAM, RECOVERY }
var current_phase: Phase = Phase.JUMP
var phase_timer: float = 0.0
var original_y: float = 0.0

# Static cooldown tracking (shared across instances)
static var cooldown_remaining: float = 0.0

# Denial feedback spam prevention (shared across instances)
static var denial_cooldown: float = 0.0

# =============================================================================
# LIFECYCLE
# =============================================================================

func enter() -> void:
	# Check if ability is unlocked
	if player.progression and player.progression.get_level() < UNLOCK_LEVEL:
		# Not unlocked - denial feedback (throttled)
		if denial_cooldown <= 0:
			AudioManager.play_sfx("menu_navigate")
			_flash_sprite(Color(1.5, 0.5, 0.5))
			Events.permission_denied.emit("ability", "Ground Pound requires Level %d" % UNLOCK_LEVEL)
			denial_cooldown = 0.3
		state_machine.transition_to("Idle")
		return

	# Check cooldown
	if cooldown_remaining > 0:
		# On cooldown - denial feedback (throttled)
		if denial_cooldown <= 0:
			AudioManager.play_sfx("menu_navigate")
			_flash_sprite(Color(0.5, 0.5, 1.5))
			Events.permission_denied.emit("ability", "Ground Pound on cooldown")
			denial_cooldown = 0.3
		state_machine.transition_to("Idle")
		return
	
	player.velocity = Vector2.ZERO
	current_phase = Phase.JUMP
	phase_timer = 0.0
	original_y = player.global_position.y
	
	# Start jump animation
	_start_jump()
	
	Events.player_ground_pound_started.emit()

func exit() -> void:
	# Reset position
	player.global_position.y = original_y
	
	# Reset sprite
	if player.sprite:
		player.sprite.scale = Vector2.ONE
		player.sprite.modulate = Color.WHITE

func physics_update(delta: float) -> void:
	phase_timer += delta
	
	match current_phase:
		Phase.JUMP:
			_update_jump(delta)
		Phase.SLAM:
			_update_slam(delta)
		Phase.RECOVERY:
			_update_recovery(delta)

func _process(delta: float) -> void:
	# Update static cooldown (runs even when not in this state)
	if cooldown_remaining > 0:
		cooldown_remaining -= delta
	if denial_cooldown > 0:
		denial_cooldown -= delta

# =============================================================================
# PHASES
# =============================================================================

func _start_jump() -> void:
	# Visual: scale up and glow
	if player.sprite:
		player.sprite.modulate = Color(1.2, 1.1, 0.9)

func _update_jump(delta: float) -> void:
	# Arc upward
	var progress = phase_timer / JUMP_DURATION
	var height_offset = sin(progress * PI) * JUMP_HEIGHT
	player.global_position.y = original_y - height_offset
	
	# Scale effect
	if player.sprite:
		player.sprite.scale = Vector2(1.0 + progress * 0.2, 1.0 - progress * 0.1)
	
	if phase_timer >= JUMP_DURATION:
		current_phase = Phase.SLAM
		phase_timer = 0.0
		_start_slam()

func _start_slam() -> void:
	# Slam down fast
	if player.sprite:
		player.sprite.modulate = Color(1.4, 1.2, 0.8)
		player.sprite.scale = Vector2(0.8, 1.3)

func _update_slam(delta: float) -> void:
	# Fast descent
	var progress = phase_timer / SLAM_DURATION
	var ease_progress = progress * progress  # Ease in (accelerate)
	player.global_position.y = original_y - JUMP_HEIGHT * (1.0 - ease_progress)
	
	if phase_timer >= SLAM_DURATION:
		current_phase = Phase.RECOVERY
		phase_timer = 0.0
		_do_impact()

func _do_impact() -> void:
	# Return to ground
	player.global_position.y = original_y
	
	# Deal AoE damage and stun
	_hit_enemies_in_range()
	
	# Visual effects
	_create_impact_effect()
	EffectsManager.screen_shake(15.0, 0.3)
	
	# Start cooldown
	cooldown_remaining = COOLDOWN
	
	Events.player_ground_pound_impact.emit(DAMAGE, AOE_RADIUS)

func _update_recovery(delta: float) -> void:
	# Brief recovery
	if player.sprite:
		player.sprite.scale = player.sprite.scale.lerp(Vector2.ONE, delta * 8)
		player.sprite.modulate = player.sprite.modulate.lerp(Color.WHITE, delta * 5)
	
	if phase_timer >= RECOVERY_DURATION:
		state_machine.transition_to("Idle")

# =============================================================================
# DENIAL FEEDBACK
# =============================================================================

## Flash player sprite a color then tween back to white
func _flash_sprite(color: Color) -> void:
	if player.sprite:
		player.sprite.modulate = color
		var tween = create_tween()
		tween.tween_property(player.sprite, "modulate", Color.WHITE, 0.2)

# =============================================================================
# IMPACT
# =============================================================================

func _hit_enemies_in_range() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance <= AOE_RADIUS:
			# Calculate damage (reduced at edges), includes equipment + buff bonuses
			var falloff = 1.0 - (distance / AOE_RADIUS) * 0.5  # 100% at center, 50% at edge
			var base_dmg = DAMAGE + (player.get_effective_base_damage() - player.BASE_ATTACK_DAMAGE)
			var final_damage = int(base_dmg * falloff)
			
			# Damage enemy
			if enemy.health:
				enemy.health.take_damage(final_damage)
			
			# Apply stun
			if enemy.has_method("apply_stun"):
				enemy.apply_stun(STUN_DURATION)
			
			# Knockback away from player
			var knockback_dir = (enemy.global_position - player.global_position).normalized()
			enemy.velocity = knockback_dir * 150
			
			# Visual feedback
			Events.enemy_damaged.emit(enemy, final_damage)

func _create_impact_effect() -> void:
	# Create expanding ring
	var ring_count = 2
	for i in range(ring_count):
		_spawn_ring(player.global_position, i * 0.05, AOE_RADIUS * (0.5 + i * 0.3))
	
	# Dust particles
	for j in range(12):
		var angle = j * TAU / 12
		var dust = ColorRect.new()
		dust.size = Vector2(3, 3)
		dust.color = Color(0.6, 0.5, 0.4, 0.8)
		dust.global_position = player.global_position
		dust.z_index = 50
		get_tree().current_scene.add_child(dust)
		
		var end_pos = player.global_position + Vector2(cos(angle), sin(angle)) * AOE_RADIUS
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(dust, "global_position", end_pos, 0.3).set_ease(Tween.EASE_OUT)
		tween.tween_property(dust, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(dust.queue_free)

func _spawn_ring(pos: Vector2, delay: float, radius: float) -> void:
	# Wait for delay
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	# Create circle of particles
	var segments = 16
	for i in range(segments):
		var angle = i * TAU / segments
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(1, 0.9, 0.5, 0.9)
		particle.global_position = pos
		particle.z_index = 60
		get_tree().current_scene.add_child(particle)
		
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * radius
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.2).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.25)
		tween.chain().tween_callback(particle.queue_free)
