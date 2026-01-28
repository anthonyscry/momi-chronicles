extends State
class_name BossAttackCharge
## Charges at player, deals heavy damage on impact

const TELEGRAPH: float = 0.6
const CHARGE_SPEED: float = 200.0
const CHARGE_DURATION: float = 0.8
const RECOVERY: float = 0.8

var timer: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO
enum Phase { TELEGRAPH, CHARGE, RECOVERY }
var current_phase: Phase = Phase.TELEGRAPH

func enter() -> void:
	timer = 0.0
	current_phase = Phase.TELEGRAPH
	enemy.velocity = Vector2.ZERO
	
	# Lock onto player position
	if enemy.target:
		charge_direction = enemy.get_direction_to_target()
	else:
		charge_direction = Vector2.DOWN
	
	# Telegraph visual - crouch and glow
	if enemy.sprite:
		enemy.sprite.scale.y = enemy.sprite.scale.y * 0.7
		enemy.sprite.modulate = Color(1.5, 0.8, 0.8)

func exit() -> void:
	if enemy.hitbox:
		enemy.hitbox.disable()
	if enemy.sprite:
		enemy.sprite.scale = Vector2(2.5, 2.5)
		var is_enraged = enemy.get("is_enraged") if enemy.get("is_enraged") != null else false
		enemy.sprite.modulate = Color(1.3, 0.8, 0.8) if is_enraged else Color.WHITE

func physics_update(delta: float) -> void:
	timer += delta
	
	match current_phase:
		Phase.TELEGRAPH:
			# Shake during telegraph
			if enemy.sprite:
				enemy.sprite.position.x = randf_range(-2, 2)
			
			if timer >= TELEGRAPH:
				current_phase = Phase.CHARGE
				timer = 0.0
				_start_charge()
		
		Phase.CHARGE:
			enemy.velocity = charge_direction * CHARGE_SPEED
			enemy.move_and_slide()
			
			if timer >= CHARGE_DURATION:
				current_phase = Phase.RECOVERY
				timer = 0.0
				_end_charge()
		
		Phase.RECOVERY:
			enemy.velocity = enemy.velocity.lerp(Vector2.ZERO, delta * 5)
			enemy.move_and_slide()
			
			if timer >= RECOVERY:
				state_machine.transition_to("BossIdle")

func _start_charge() -> void:
	if enemy.sprite:
		enemy.sprite.scale = Vector2(2.5, 2.5)
		enemy.sprite.position.x = 0
	
	if enemy.hitbox:
		enemy.hitbox.damage = int(enemy.attack_damage * 1.5)
		enemy.hitbox.enable()
	
	EffectsManager.screen_shake(6.0, 0.2)

func _end_charge() -> void:
	if enemy.hitbox:
		enemy.hitbox.disable()
	
	# Dust cloud on stop
	EffectsManager.screen_shake(8.0, 0.15)
