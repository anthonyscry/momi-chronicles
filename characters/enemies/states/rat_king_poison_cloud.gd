extends State
class_name RatKingPoisonCloud
## Rat King poison cloud - creates an AoE poison zone at target location.
## Phase: TELEGRAPH (0.4s) → SPIT (0.2s) → RECOVERY (0.6s)
## The poison cloud persists for 4 seconds, applying poison DoT on contact.

const TELEGRAPH_TIME: float = 0.4
const SPIT_TIME: float = 0.2
const RECOVERY_TIME: float = 0.6
const CLOUD_RADIUS: float = 30.0
const CLOUD_DURATION: float = 4.0
const POISON_DAMAGE: int = 3
const POISON_TICK_DURATION: float = 3.0

var timer: float = 0.0
enum Phase { TELEGRAPH, SPIT, RECOVERY }
var current_phase: Phase = Phase.TELEGRAPH
var target_pos: Vector2 = Vector2.ZERO

func enter() -> void:
	timer = 0.0
	current_phase = Phase.TELEGRAPH
	player.velocity = Vector2.ZERO
	
	# Lock target position
	var player_node = player.get_tree().get_first_node_in_group("player")
	if player_node:
		target_pos = player_node.global_position
	else:
		target_pos = player.global_position + Vector2(0, 30)
	
	# Green-purple glow during telegraph
	if player.sprite:
		player.sprite.modulate = Color(0.7, 1.2, 0.6)

func exit() -> void:
	if player.sprite:
		player.sprite.modulate = Color.WHITE
		player.sprite.position = Vector2.ZERO

func physics_update(delta: float) -> void:
	timer += delta
	match current_phase:
		Phase.TELEGRAPH:
			# Swell/pulse sprite
			if player.sprite:
				var pulse = 1.0 + sin(timer * 12.0) * 0.1
				player.sprite.scale = Vector2(2.0, 2.0) * pulse  # Rat King is 2x scale
			if timer >= TELEGRAPH_TIME:
				current_phase = Phase.SPIT
				timer = 0.0
				_spawn_poison_cloud()
		Phase.SPIT:
			if timer >= SPIT_TIME:
				current_phase = Phase.RECOVERY
				timer = 0.0
		Phase.RECOVERY:
			if player.sprite:
				player.sprite.scale = Vector2(2.0, 2.0)  # Reset scale
			if timer >= RECOVERY_TIME:
				state_machine.transition_to("MiniBossIdle")

func _spawn_poison_cloud() -> void:
	EffectsManager.screen_shake(3.0, 0.1)
	
	# Create poison cloud Area2D
	var cloud = Area2D.new()
	cloud.name = "PoisonCloud"
	cloud.collision_layer = 0
	cloud.collision_mask = 2  # Player layer
	cloud.global_position = target_pos
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = CLOUD_RADIUS
	shape.shape = circle
	cloud.add_child(shape)
	
	# Visual — green-purple translucent circle
	var visual = Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(12):
		var angle = i * TAU / 12.0
		points.append(Vector2(cos(angle), sin(angle)) * CLOUD_RADIUS)
	visual.polygon = points
	visual.color = Color(0.4, 0.7, 0.2, 0.35)  # Sickly green, translucent
	visual.z_index = 1
	cloud.add_child(visual)
	
	# Inner darker circle for depth
	var inner = Polygon2D.new()
	var inner_points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8.0
		inner_points.append(Vector2(cos(angle), sin(angle)) * CLOUD_RADIUS * 0.5)
	inner.polygon = inner_points
	inner.color = Color(0.3, 0.5, 0.15, 0.5)
	inner.z_index = 2
	cloud.add_child(inner)
	
	# Poison on contact — uses HealthComponent.apply_poison()
	cloud.body_entered.connect(func(body: Node2D):
		if body.is_in_group("player") or body.is_in_group("companions"):
			var hc = body.get_node_or_null("HealthComponent")
			if hc and hc.has_method("apply_poison"):
				hc.apply_poison(POISON_DAMAGE, POISON_TICK_DURATION)
	)
	
	player.get_parent().add_child(cloud)
	
	# Pulse animation on cloud
	var pulse_tween = cloud.create_tween().set_loops(int(CLOUD_DURATION / 0.8))
	pulse_tween.tween_property(visual, "modulate:a", 0.5, 0.4)
	pulse_tween.tween_property(visual, "modulate:a", 1.0, 0.4)
	
	# Auto-despawn after duration
	var despawn_timer = player.get_tree().create_timer(CLOUD_DURATION)
	despawn_timer.timeout.connect(func():
		if is_instance_valid(cloud):
			var fade = cloud.create_tween()
			fade.tween_property(cloud, "modulate:a", 0.0, 0.5)
			fade.tween_callback(cloud.queue_free)
	)
