extends State
class_name RatCornered

## Roof Rat cornered state - escapes upward when trapped against wall.

const CORNER_CHECK_INTERVAL: float = 0.15
const ESCAPE_COOLDOWN: float = 2.0
const ESCAPE_HEIGHT: float = 150.0

var corner_check_timer: float = 0.0
var escape_cooldown_timer: float = 0.0
var is_escaping: bool = false

func enter() -> void:
	corner_check_timer = 0.0
	escape_cooldown_timer = 0.0
	is_escaping = false
	
	if player.sprite:
		player.sprite.play("retreat")
	
	_attempt_escape()

func update(delta: float) -> void:
	escape_cooldown_timer = max(0, escape_cooldown_timer - delta)
	
	if is_escaping:
		_perform_escape(delta)
		return
	
	corner_check_timer += delta
	if corner_check_timer >= CORNER_CHECK_INTERVAL:
		corner_check_timer = 0.0
		if not _is_cornered():
			state_machine.transition_to("WallRun")
			return
	
	if escape_cooldown_timer <= 0:
		_attempt_escape()

func _is_cornered() -> bool:
	var player_node = get_tree().get_first_node_in_group("player")
	if not player_node:
		return false
	
	var to_player = player_node.global_position - player.global_position
	var distance = to_player.length()
	
	var escape_paths = [
		Vector2(0, -1),
		Vector2(1, -1),
		Vector2(-1, -1)
	]
	
	for direction in escape_paths:
		if _has_escape_path(direction):
			return false
	
	return distance < player.CORNER_DETECTION_RADIUS

func _has_escape_path(direction: Vector2) -> bool:
	var ray_length = ESCAPE_HEIGHT * 0.5
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = player.global_position
	query.to = player.global_position + direction * ray_length
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	return result == null or not result.is_empty()

func _attempt_escape() -> void:
	if not _is_cornered():
		return
	
	var escape_direction = _find_best_escape_direction()
	if escape_direction != Vector2.ZERO:
		is_escaping = true
		player.velocity = escape_direction * player.RETREAT_SPEED
		escape_cooldown_timer = ESCAPE_COOLDOWN

func _find_best_escape_direction() -> Vector2:
	var directions = [Vector2(0, -1), Vector2(1, -1), Vector2(-1, -1)]
	var best_direction = Vector2.ZERO
	var best_score = -1.0
	
	for direction in directions:
		if _has_clear_path(direction):
			var player_node = get_tree().get_first_node_in_group("player")
			var dot = 1.0
			if player_node:
				var to_player = player_node.global_position - player.global_position
				dot = direction.dot(to_player.normalized())
			var score = _path_clearance(direction) - dot * 0.5
			if score > best_score:
				best_score = score
				best_direction = direction
	
	return best_direction

func _has_clear_path(direction: Vector2) -> bool:
	var ray_length = ESCAPE_HEIGHT
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = player.global_position
	query.to = player.global_position + direction * ray_length
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	return result == null or result.is_empty()

func _path_clearance(direction: Vector2) -> float:
	var test_positions = [0.3, 0.6, 1.0]
	var clear_count = 0
	for t in test_positions:
		var pos = player.global_position + direction * ESCAPE_HEIGHT * t
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = pos
		query.collision_mask = 1
		var result = space_state.intersect_point(query)
		if result.size() == 0:
			clear_count += 1
	return float(clear_count) / test_positions.size()

func _perform_escape(delta: float) -> void:
	player.move_and_slide()
	
	var escape_complete = true
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		var dist_after = player.global_position.distance_to(player_node.global_position)
		if dist_after > player.CORNER_DETECTION_RADIUS * 1.5:
			escape_complete = true
		else:
			escape_complete = false
	
	if escape_complete and player.velocity.length() < 10:
		is_escaping = false
		state_machine.transition_to("WallRun")

func exit() -> void:
	corner_check_timer = 0.0
	is_escaping = false
