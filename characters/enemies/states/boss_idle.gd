extends State
class_name BossIdle
## Boss idle - waits briefly then picks next attack

var idle_timer: float = 0.0
const IDLE_DURATION: float = 1.0

func enter() -> void:
	idle_timer = 0.0
	enemy.velocity = Vector2.ZERO

func physics_update(delta: float) -> void:
	if not enemy.can_act():
		return
	
	idle_timer += delta
	
	# Face player
	if enemy.target:
		enemy.update_facing(enemy.get_direction_to_target())
	
	if idle_timer >= IDLE_DURATION:
		# Pick next attack
		if enemy.has_method("get_attack_state_name"):
			var attack_state = enemy.get_attack_state_name()
			state_machine.transition_to(attack_state)
		else:
			state_machine.transition_to("BossAttackSwipe")
