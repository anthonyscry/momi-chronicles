extends State
## Pigeon King swoop dive — ascend, telegraph target, dive at high speed.
## Phase: TELEGRAPH (0.6s) -> ASCEND (0.4s) -> DIVE -> RECOVERY (0.5s)
## Faster and more damaging than the Crow Matriarch's dive bomb.

const TELEGRAPH_TIME: float = 0.6
const ASCEND_TIME: float = 0.4
const DIVE_SPEED: float = 250.0
const DIVE_DAMAGE: float = 25.0
const RECOVERY_TIME: float = 0.5
const ASCEND_HEIGHT: float = 60.0
const DIVE_TIME: float = 0.5

var timer: float = 0.0
enum Phase { TELEGRAPH, ASCEND, DIVE, RECOVERY }
var current_phase: Phase = Phase.TELEGRAPH
var dive_target: Vector2 = Vector2.ZERO
var dive_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	timer = 0.0
	current_phase = Phase.TELEGRAPH
	player.velocity = Vector2.ZERO
	if player.sprite:
		player.sprite.play("attack")
	_start_telegraph()


func exit() -> void:
	if player.hitbox:
		player.hitbox.disable()
	if player.sprite:
		player.sprite.modulate = Color(0.85, 0.75, 1.1)  # Restore Pigeon King tint
		player.sprite.position = Vector2.ZERO
		player.sprite.scale = Vector2(1.8, 1.8)  # Restore king scale
	# Re-enable hurtbox
	if player.hurtbox:
		player.hurtbox.is_invincible = false


func physics_update(delta: float) -> void:
	timer += delta
	match current_phase:
		Phase.TELEGRAPH:
			# Flash sprite gold, shake slightly
			if player.sprite:
				var flash_intensity = sin(timer * 12.0) * 0.3 + 0.7
				player.sprite.modulate = Color(1.0, 0.9 * flash_intensity, 0.4 * flash_intensity)
			if timer >= TELEGRAPH_TIME:
				current_phase = Phase.ASCEND
				timer = 0.0
				_lock_target()
				_start_ascend()
		Phase.ASCEND:
			if timer >= ASCEND_TIME:
				current_phase = Phase.DIVE
				timer = 0.0
				_start_dive()
		Phase.DIVE:
			# Move toward target at high speed
			player.velocity = dive_direction * DIVE_SPEED
			player.move_and_slide()

			# Check if close to target or time expired
			var dist = player.global_position.distance_to(dive_target)
			if dist < 10.0 or timer >= DIVE_TIME:
				current_phase = Phase.RECOVERY
				timer = 0.0
				_do_impact()
		Phase.RECOVERY:
			player.velocity = player.velocity.lerp(Vector2.ZERO, delta * 8.0)
			player.move_and_slide()
			if timer >= RECOVERY_TIME:
				state_machine.transition_to("MiniBossIdle")


func _start_telegraph() -> void:
	# Record player position as dive target early for indicator
	var player_node = player.get_tree().get_first_node_in_group("player")
	if player_node:
		dive_target = player_node.global_position
	# Spawn warning indicator at target
	_spawn_target_indicator(dive_target)


func _lock_target() -> void:
	# Update target to player's current position
	var player_node = player.get_tree().get_first_node_in_group("player")
	if player_node:
		dive_target = player_node.global_position
	else:
		dive_target = player.global_position + Vector2(0, 50)

	dive_direction = (dive_target - player.global_position).normalized()


func _start_ascend() -> void:
	# Fly up visual (sprite moves up, becomes semi-transparent)
	if player.sprite:
		player.sprite.modulate = Color(1.0, 1.0, 1.2, 0.7)
		var tween = create_tween()
		tween.tween_property(player.sprite, "position:y", -15.0, ASCEND_TIME)
	# Become invulnerable during ascend
	if player.hurtbox:
		player.hurtbox.is_invincible = true


func _start_dive() -> void:
	# Dive down visual — aggressive red tint
	if player.sprite:
		player.sprite.modulate = Color(1.3, 0.7, 0.7, 1.0)
		var tween = create_tween()
		tween.tween_property(player.sprite, "position:y", 0.0, DIVE_TIME * 0.5)
	# Enable hitbox during dive
	if player.hitbox:
		player.hitbox.damage = int(DIVE_DAMAGE)
		player.hitbox.enable()

	# Spawn final target indicator
	_spawn_target_indicator(dive_target)


func _do_impact() -> void:
	# Disable hitbox
	if player.hitbox:
		player.hitbox.disable()
	# Re-enable hurtbox (vulnerable during recovery)
	if player.hurtbox:
		player.hurtbox.is_invincible = false

	player.velocity = Vector2.ZERO
	EffectsManager.screen_shake(5.0, 0.2)

	# Impact visual — dust cloud
	_spawn_impact_dust()


func _spawn_target_indicator(pos: Vector2) -> void:
	var indicator = Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8.0
		points.append(Vector2(cos(angle), sin(angle)) * 14.0)
	indicator.polygon = points
	indicator.color = Color(1.0, 0.3, 0.3, 0.4)  # Red target circle
	indicator.global_position = pos
	indicator.z_index = 0
	player.get_parent().add_child(indicator)

	# Pulse and fade
	var tween = create_tween()
	tween.tween_property(indicator, "modulate:a", 0.8, 0.15)
	tween.tween_property(indicator, "modulate:a", 0.3, 0.15)
	tween.tween_property(indicator, "modulate:a", 0.8, 0.15)
	tween.tween_callback(indicator.queue_free)


func _spawn_impact_dust() -> void:
	for i in range(8):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(0.5, 0.45, 0.4, 0.7)
		particle.global_position = player.global_position
		player.get_parent().add_child(particle)

		var angle = i * TAU / 8
		var end_pos = player.global_position + Vector2(cos(angle), sin(angle)) * 25

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.4)
		tween.tween_property(particle, "modulate:a", 0.0, 0.4)
		tween.chain().tween_callback(particle.queue_free)
