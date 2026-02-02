extends Area2D

## Gnome bomb projectile - explosive with fuse timer.
## Arcs through air and explodes on impact or fuse end.

signal exploded(bomb: Node, position: Vector2, radius: float)

const DamageUtils = preload("res://components/combat/damage_utils.gd")

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

var _sprite: Node2D = null
var _hitbox = null

func _ready() -> void:
	_time_alive = 0.0
	_landed = false
	_exploded = false
	_arc_start = global_position
	
	_setup_collision()
	_create_fuse_timer()
	
	_sprite = get_node_or_null("Sprite2D")
	_hitbox = get_node_or_null("Hitbox")
	if _hitbox:
		_hitbox.damage = damage


func _setup_collision() -> void:
	var collision = get_node_or_null("CollisionShape2D")
	if not collision:
		collision = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 12.0
		collision.shape = circle
		collision.name = "CollisionShape2D"
		add_child(collision)
	
	monitoring = true
	monitorable = true
	area_entered.connect(_on_area_entered)


func _create_fuse_timer() -> void:
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
	if distance <= 0.01 or throw_speed <= 0.0:
		_landed = true
		global_position = target_position
		return
	
	var total_time = distance / throw_speed
	var progress = _time_alive / total_time
	
	if progress >= 1.0:
		_landed = true
		global_position = target_position
		return
	
	var horizontal = direction * throw_speed * _time_alive
	var parabolic = 4 * throw_height * progress * (1.0 - progress)
	
	global_position = _arc_start + horizontal + Vector2(0, -parabolic)
	
	if _sprite:
		_sprite.rotation = direction.angle() + PI * 0.25 * progress


func _pulse_effect(delta: float) -> void:
	var pulse_intensity = sin(_time_alive * 15.0) * 0.3 + 0.7
	if _sprite:
		_sprite.modulate = Color(1.0, pulse_intensity * 0.5, 0.0, 1.0)


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
	Events.gnome_bomb_exploded.emit(global_position, aoe_radius)
	
	_create_explosion_effect()
	_apply_aoe_damage()
	
	queue_free()


func _create_explosion_effect() -> void:
	# Create visual explosion effect
	var explosion = Sprite2D.new()
	explosion.texture = preload("res://art/generated/enemies/gnome_explosion.png")
	explosion.centered = true
	explosion.global_position = global_position
	explosion.z_index = 50
	get_parent().add_child(explosion)
	
	# Animate explosion
	var tween = explosion.create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(explosion.queue_free)


func _apply_aoe_damage() -> void:
	if not _hitbox:
		return
	_hitbox.reset()
	var players = EntityRegistry.get_players()
	for player_node in players:
		if not is_instance_valid(player_node):
			continue
		var dist = global_position.distance_to(player_node.global_position)
		if dist <= aoe_radius:
			DamageUtils.apply_hitbox_damage(player_node, _hitbox)
