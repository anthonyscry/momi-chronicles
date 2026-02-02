extends State
class_name RatWallRun

## Roof Rat wall patrol state - runs along wall surface looking for ambush positions.

var patrol_direction: int = 1
var wall_check_timer: float = 0.0
const WALL_CHECK_INTERVAL: float = 0.1

func enter() -> void:
	patrol_direction = 1 if randf() > 0.5 else -1
	if player.sprite:
		player.sprite.play("wall_run")
		player.sprite.flip_h = (patrol_direction < 0)

func update(delta: float) -> void:
	if not player.can_act():
		player.velocity = Vector2.ZERO
		player.move_and_slide()
		return
	
	wall_check_timer += delta
	if wall_check_timer >= WALL_CHECK_INTERVAL:
		wall_check_timer = 0.0
		if not _is_on_surface():
			_find_new_surface()
			return
	
	if player.target and player.is_target_in_detection_range():
		if _is_player_below():
			state_machine.transition_to("WallAmbush")
			return
		elif _is_player_approaching():
			state_machine.transition_to("WallStealth")
			return
	
	_patrol_along_wall(delta)

func _is_on_surface() -> bool:
	if not player.get("wall_raycast") or not player.wall_raycast:
		return false
	player.wall_raycast.force_raycast_update()
	return player.wall_raycast.is_colliding()

func _find_new_surface() -> void:
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var to_player = player_node.global_position - player.global_position
		var search_radius = 100.0
		var found_surface = _scan_for_surface(player.global_position, search_radius)
		if found_surface:
			player.global_position = found_surface
			return
	state_machine.transition_to("WallStealth")

func _scan_for_surface(origin: Vector2, radius: float) -> Vector2:
	var angles = [0, PI/4, -PI/2, -PI]
	for angle in angles:
		var direction = Vector2(cos(angle), sin(angle))
		var test_pos = origin + direction * radius
		if _test_surface_at(test_pos):
			return test_pos
	return Vector2.ZERO

func _test_surface_at(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1
	var result = space_state.intersect_point(query)
	return result.size() > 0

func _is_player_below() -> bool:
	if not player.target:
		return false
	var to_target = player.target.global_position - player.global_position
	return to_target.y > 0 and abs(to_target.x) < 40.0

func _is_player_approaching() -> bool:
	if not player.target:
		return false
	var distance = player.global_position.distance_to(player.target.global_position)
	return distance < player.DETECTION_RANGE * 0.7

func _patrol_along_wall(delta: float) -> void:
	player.velocity = Vector2(patrol_direction * player.WALL_PATROL_SPEED, 0)
	player.move_and_slide()

func exit() -> void:
	wall_check_timer = 0.0
