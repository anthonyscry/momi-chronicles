extends State
class_name CrowDiveBomb
## Crow Matriarch dive bomb - ascend, lock target, dive at high speed.
## Phase: ASCEND (0.4s) -> TELEGRAPH (0.3s) -> DIVE (0.4s) -> RECOVERY (0.5s)

const ASCEND_TIME: float = 0.4
const TELEGRAPH_TIME: float = 0.3
const DIVE_TIME: float = 0.4
const RECOVERY_TIME: float = 0.5
const DIVE_SPEED: float = 280.0
const DIVE_DAMAGE_RADIUS: float = 18.0

var timer: float = 0.0
enum Phase { ASCEND, TELEGRAPH, DIVE, RECOVERY }
var current_phase: Phase = Phase.ASCEND
var dive_target: Vector2 = Vector2.ZERO
var dive_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	timer = 0.0
	current_phase = Phase.ASCEND
	player.velocity = Vector2.ZERO
	if player.sprite:
		player.sprite.play("attack")
	_start_ascend()

func exit() -> void:
	if player.hitbox:
		player.hitbox.disable()
	if player.sprite:
		player.sprite.modulate = Color.WHITE
		player.sprite.position = Vector2.ZERO
		player.sprite.scale = Vector2(1.5, 1.5)  # Restore matriarch scale
	# Re-enable hurtbox
	if player.hurtbox:
		player.hurtbox.is_invincible = false

func physics_update(delta: float) -> void:
	timer += delta
	match current_phase:
		Phase.ASCEND:
			if timer >= ASCEND_TIME:
				current_phase = Phase.TELEGRAPH
				timer = 0.0
				_lock_target()
		Phase.TELEGRAPH:
			# Show ground indicator pulsing
			if timer >= TELEGRAPH_TIME:
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

func _start_ascend() -> void:
	# Fly up visual (sprite moves up, becomes semi-transparent)
	if player.sprite:
		player.sprite.modulate = Color(1.0, 1.0, 1.2, 0.7)
		var tween = create_tween()
		tween.tween_property(player.sprite, "position:y", -15.0, ASCEND_TIME)
	# Become invulnerable during ascend
	if player.hurtbox:
		player.hurtbox.is_invincible = true

func _lock_target() -> void:
	# Lock onto player's current position
	var player_node = player.get_tree().get_first_node_in_group("player")
	if player_node:
		dive_target = player_node.global_position
	else:
		dive_target = player.global_position + Vector2(0, 50)
	
	dive_direction = (dive_target - player.global_position).normalized()
	
	# Show ground indicator at target
	_spawn_target_indicator(dive_target)

func _start_dive() -> void:
	# Dive down visual
	if player.sprite:
		player.sprite.modulate = Color(1.3, 0.8, 0.8, 1.0)
		var tween = create_tween()
		tween.tween_property(player.sprite, "position:y", 0.0, DIVE_TIME * 0.5)
	# Enable hitbox during dive
	if player.hitbox:
		player.hitbox.damage = int(player.attack_damage * 1.5)  # Dive does 1.5x damage
		player.hitbox.enable()

func _do_impact() -> void:
	# Disable hitbox
	if player.hitbox:
		player.hitbox.disable()
	# Re-enable hurtbox (vulnerable during recovery)
	if player.hurtbox:
		player.hurtbox.is_invincible = false
	
	player.velocity = Vector2.ZERO
	EffectsManager.screen_shake(5.0, 0.2)
	
	# Impact visual - small dust cloud
	_spawn_impact_dust()

func _spawn_target_indicator(pos: Vector2) -> void:
	var indicator = Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8.0
		points.append(Vector2(cos(angle), sin(angle)) * 12.0)
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
	for i in range(6):
		var particle = ColorRect.new()
		particle.size = Vector2(3, 3)
		particle.color = Color(0.6, 0.55, 0.5, 0.7)
		particle.global_position = player.global_position
		player.get_parent().add_child(particle)
		
		var angle = i * TAU / 6
		var end_pos = player.global_position + Vector2(cos(angle), sin(angle)) * 20
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(particle.queue_free)
