extends State
class_name RatWallRetreat

## Roof Rat retreat state - climbs upward away from player after ambush.

const RETREAT_DURATION: float = 0.8
const RETREAT_HEIGHT: float = 120.0

var retreat_timer: float = 0.0
var retreat_start_y: float = 0.0
var target_y: float = 0.0

func enter() -> void:
	retreat_timer = 0.0
	retreat_start_y = player.global_position.y
	target_y = retreat_start_y - RETREAT_HEIGHT
	
	if player.sprite:
		player.sprite.play("retreat")
		player.sprite.flip_h = false

func update(delta: float) -> void:
	if not player.can_act():
		state_machine.transition_to("WallStealth")
		return
	
	retreat_timer += delta
	var progress = retreat_timer / RETREAT_DURATION
	var eased = ease_out_quad(progress)
	
	player.global_position.y = retreat_start_y - (eased * RETREAT_HEIGHT)
	
	if player.sprite:
		if progress < 0.5:
			player.sprite.flip_h = false
		else:
			player.sprite.flip_h = true
	
	player.velocity = Vector2.ZERO
	player.move_and_slide()
	
	if retreat_timer >= RETREAT_DURATION:
		_find_climb_position()

func _find_climb_position() -> void:
	var search_offsets = [Vector2(30, -40), Vector2(-30, -40), Vector2(0, -60)]
	for offset in search_offsets:
		var test_pos = player.global_position + offset
		if _is_valid_climb_position(test_pos):
			player.global_position = test_pos
			state_machine.transition_to("WallStealth")
			return
	state_machine.transition_to("WallRun")

func _is_valid_climb_position(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1
	var result = space_state.intersect_point(query)
	return result.size() > 0

func ease_out_quad(t: float) -> float:
	return 1.0 - (1.0 - t) * (1.0 - t)

func exit() -> void:
	retreat_timer = 0.0
