extends State
class_name MiniBossIdle
## Mini-boss idle state - waits briefly, faces target, then picks next attack.
## Uses attack pattern cycling from MiniBossBase.get_next_attack_state().

var idle_timer: float = 0.0
@export var idle_duration: float = 1.5

func enter() -> void:
	idle_timer = 0.0
	player.velocity = Vector2.ZERO

func physics_update(delta: float) -> void:
	if not player.can_act():
		return
	
	# Face target
	if player.target:
		player.update_facing(player.get_direction_to_target())
	
	# No target — go chase
	if not player.target:
		state_machine.transition_to("Chase")
		return
	
	idle_timer += delta
	if idle_timer >= idle_duration:
		# Use get_attack_state_name() for compatibility with existing boss pattern
		if player.has_method("get_attack_state_name"):
			var attack_state = player.get_attack_state_name()
			state_machine.transition_to(attack_state)
		else:
			state_machine.transition_to("Chase")
