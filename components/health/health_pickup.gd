extends Area2D
class_name HealthPickup
## A health pickup that heals the player on contact.
## Spawns from defeated enemies or placed in the world.

@export var heal_amount: int = 20

## Lifetime before despawning (0 = never)
@export var lifetime: float = 15.0

## Magnet effect - pull toward player when close
@export var magnet_range: float = 40.0  # Start moving toward player
@export var magnet_speed: float = 150.0  # Speed when magneting

## Bob animation
var bob_time: float = 0.0
var start_y: float = 0.0

## Visual
@onready var sprite: Polygon2D = $Sprite2D

func _ready() -> void:
	add_to_group("pickups")
	body_entered.connect(_on_body_entered)
	start_y = position.y
	
	# Start lifetime timer if set
	if lifetime > 0:
		var timer = get_tree().create_timer(lifetime)
		timer.timeout.connect(_on_lifetime_expired)
	
	# Spawn animation - pop in
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	# Gentle bob animation
	bob_time += delta * 3.0
	position.y = start_y + sin(bob_time) * 2.0
	
	# Gentle glow pulse
	if sprite:
		var pulse = 0.8 + sin(bob_time * 1.5) * 0.2
		sprite.modulate = Color(pulse, 1.0, pulse, 1.0)
	
	# Magnet effect - pull toward player when close
	var player = _get_player()
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= magnet_range:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * magnet_speed * delta
			# Update bob center so it doesn't fight the magnet
			start_y = global_position.y - sin(bob_time) * 2.0


func _get_player() -> Node:
	var players = EntityRegistry.get_players()
	return players[0] if players.size() > 0 else null


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Heal the player
		if body.has_node("HealthComponent"):
			var health = body.get_node("HealthComponent")
			health.heal(heal_amount)
		
		# Emit pickup signal
		Events.pickup_collected.emit("health", heal_amount)
		
		# Play pickup sound
		AudioManager.play_sfx("health_pickup")
		
		# Visual effects - pink burst
		EffectsManager.spawn_pickup_effect(global_position, Color(1.0, 0.4, 0.5))  # Pink
		EffectsManager.flash_pickup(global_position, Color(1.0, 0.8, 0.8))
		
		# Pickup effect - quick scale up and fade
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
		tween.tween_property(self, "modulate:a", 0.0, 0.15)
		tween.set_parallel(false)
		tween.tween_callback(queue_free)


func _on_lifetime_expired() -> void:
	# Fade out before despawning
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
