extends Area2D
class_name CoinPickup
## A coin pickup that adds currency when collected.

@export var coin_value: int = 1

## Magnet and movement
@export var magnet_range: float = 50.0  # Coins have bigger magnet than health
@export var magnet_speed: float = 200.0  # Coins move faster to player
@export var lifetime: float = 60.0  # Coins last longer than health

## Bob animation
var bob_time: float = 0.0
var start_y: float = 0.0
var is_collected: bool = false

@onready var sprite: Polygon2D = $Sprite2D

func _ready() -> void:
	add_to_group("pickups")
	add_to_group("coins")
	body_entered.connect(_on_body_entered)
	start_y = position.y
	
	# Start lifetime timer
	if lifetime > 0:
		var timer = get_tree().create_timer(lifetime)
		timer.timeout.connect(_on_lifetime_expired)
	
	# Spawn animation - pop in
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if is_collected:
		return
	
	# Gentle bob animation
	bob_time += delta * 4.0
	position.y = start_y + sin(bob_time) * 1.5
	
	# Gold shimmer effect
	if sprite:
		var shimmer = 0.85 + sin(bob_time * 2.0) * 0.15
		sprite.modulate = Color(1.0, shimmer, 0.2, 1.0)
	
	# Magnet toward player
	var player = _get_player()
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= magnet_range:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * magnet_speed * delta
			start_y = global_position.y - sin(bob_time) * 1.5


func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		is_collected = true
		
		# Add coins to GameManager
		GameManager.add_coins(coin_value)
		
		# Emit signal
		Events.pickup_collected.emit("coin", coin_value)
		
		# Play coin sound
		AudioManager.play_sfx("coin")
		
		# Pickup effect - quick scale up and fade
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15)
		tween.tween_property(self, "modulate:a", 0.0, 0.15)
		tween.set_parallel(false)
		tween.tween_callback(queue_free)


func _on_lifetime_expired() -> void:
	if is_collected:
		return
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)


func _get_player() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	return players[0] if players.size() > 0 else null
