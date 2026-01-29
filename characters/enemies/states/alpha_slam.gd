extends State
class_name AlphaSlam
## Alpha Raccoon ground slam - AoE damage in a circle around the boss.
## Phase: TELEGRAPH (0.5s) -> LEAP (0.3s) -> IMPACT (0.1s) -> RECOVERY (0.6s)

const TELEGRAPH_TIME: float = 0.5
const LEAP_TIME: float = 0.3
const IMPACT_TIME: float = 0.1
const RECOVERY_TIME: float = 0.6
const AOE_RADIUS: float = 40.0

var timer: float = 0.0
enum Phase { TELEGRAPH, LEAP, IMPACT, RECOVERY }
var current_phase: Phase = Phase.TELEGRAPH

func enter() -> void:
	timer = 0.0
	current_phase = Phase.TELEGRAPH
	player.velocity = Vector2.ZERO
	# Warning visual — red-orange tint
	if player.sprite:
		player.sprite.modulate = Color(1.3, 0.9, 0.8)

func exit() -> void:
	if player.hitbox:
		player.hitbox.disable()
	if player.sprite:
		player.sprite.modulate = Color.WHITE
		player.sprite.position = Vector2.ZERO

func physics_update(delta: float) -> void:
	timer += delta
	match current_phase:
		Phase.TELEGRAPH:
			# Shake sprite to telegraph incoming slam
			if player.sprite:
				player.sprite.position.x = randf_range(-2, 2)
			if timer >= TELEGRAPH_TIME:
				current_phase = Phase.LEAP
				timer = 0.0
				_start_leap()
		Phase.LEAP:
			if timer >= LEAP_TIME:
				current_phase = Phase.IMPACT
				timer = 0.0
				_do_impact()
		Phase.IMPACT:
			if timer >= IMPACT_TIME:
				current_phase = Phase.RECOVERY
				timer = 0.0
		Phase.RECOVERY:
			if timer >= RECOVERY_TIME:
				state_machine.transition_to("MiniBossIdle")

func _start_leap() -> void:
	if player.sprite:
		player.sprite.position = Vector2.ZERO
		# Jump up animation
		var tween = create_tween()
		tween.tween_property(player.sprite, "position:y", -12.0, LEAP_TIME * 0.5)
		tween.tween_property(player.sprite, "position:y", 0.0, LEAP_TIME * 0.5)

func _do_impact() -> void:
	EffectsManager.screen_shake(8.0, 0.3)
	
	# Damage player if within AoE radius
	var player_node = player.get_tree().get_first_node_in_group("player")
	if player_node:
		var dist = player.global_position.distance_to(player_node.global_position)
		if dist <= AOE_RADIUS:
			var hc = player_node.get_node_or_null("HealthComponent")
			if hc:
				hc.take_damage(player.attack_damage)
	
	# Damage companions too
	for companion in player.get_tree().get_nodes_in_group("companions"):
		if is_instance_valid(companion):
			var dist = player.global_position.distance_to(companion.global_position)
			if dist <= AOE_RADIUS:
				var hc = companion.get_node_or_null("HealthComponent")
				if hc:
					hc.take_damage(player.attack_damage)
	
	# Spawn visual shockwave
	_spawn_slam_visual()

func _spawn_slam_visual() -> void:
	# Expanding circle that fades — shows AoE radius
	var circle = Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(16):
		var angle = i * TAU / 16.0
		points.append(Vector2(cos(angle), sin(angle)) * 5.0)  # Start small
	circle.polygon = points
	circle.color = Color(0.8, 0.4, 0.2, 0.6)  # Orange shockwave
	circle.global_position = player.global_position
	circle.z_index = 5
	player.get_parent().add_child(circle)
	
	# Expand and fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(circle, "scale", Vector2(AOE_RADIUS / 5.0, AOE_RADIUS / 5.0), 0.3)
	tween.tween_property(circle, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(circle.queue_free)
