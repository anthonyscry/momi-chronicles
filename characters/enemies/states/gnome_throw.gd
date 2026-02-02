extends State

## Gnome throw state - throws explosive bomb at player.
## Spawns bomb projectile after a short windup delay.

const THROW_DELAY: float = 0.15
const THROW_DURATION: float = 0.45

var throw_animation_played: bool = false
var bomb_instance: Node = null
var throw_timer: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("throw")
	
	throw_animation_played = false
	bomb_instance = null
	throw_timer = 0.0


func update(delta: float) -> void:
	throw_timer += delta
	
	# Spawn bomb after windup delay
	if not throw_animation_played and throw_timer >= THROW_DELAY:
		throw_animation_played = true
		_spawn_bomb()
	
	# Transition after throw duration
	if throw_timer >= THROW_DURATION:
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
	throw_timer = 0.0
