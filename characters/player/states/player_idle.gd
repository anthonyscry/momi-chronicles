extends State
class_name PlayerIdle
## Idle state - player stands still and waits for input.

## Track attack button hold time for charge detection
var attack_hold_time: float = 0.0
const CHARGE_THRESHOLD: float = 0.25  # Hold this long to start charging

func enter() -> void:
	player.velocity = Vector2.ZERO
	attack_hold_time = 0.0

func physics_update(delta: float) -> void:
	# Check for bot actions first
	var bot_action = player.consume_bot_action()
	if bot_action != "":
		match bot_action:
			"attack":
				state_machine.transition_to("ComboAttack")
				return
			"charge_attack":
				state_machine.transition_to("ChargeAttack")
				return
			"ground_pound":
				state_machine.transition_to("GroundPound")
				return
			"special_attack":
				# Ground pound if level 5+, otherwise spin attack
				if player.get_current_level() >= 5 and player.get_ground_pound_cooldown() <= 0:
					state_machine.transition_to("GroundPound")
				else:
					state_machine.transition_to("SpecialAttack")
				return
			"dodge":
				state_machine.transition_to("Dodge")
				return
	
	# Check for dodge input first (highest priority)
	if Input.is_action_just_pressed("dodge"):
		state_machine.transition_to("Dodge")
		return
	
	# Check for block input (V key or bot blocking)
	var should_block = Input.is_action_pressed("block")
	if player.bot_controlled:
		should_block = player.bot_blocking
	if should_block:
		if player.guard and player.guard.can_block():
			state_machine.transition_to("Block")
			return
	
	# Check for special attack / ground pound (C key)
	if Input.is_action_just_pressed("special_attack"):
		# Ground pound if level 5+ and off cooldown, otherwise spin attack
		if player.get_current_level() >= 5 and player.get_ground_pound_cooldown() <= 0:
			state_machine.transition_to("GroundPound")
		else:
			state_machine.transition_to("SpecialAttack")
		return
	
	# Attack input - detect tap vs hold for combo vs charge
	if Input.is_action_pressed("attack"):
		attack_hold_time += delta
		if attack_hold_time >= CHARGE_THRESHOLD:
			state_machine.transition_to("ChargeAttack")
			return
	elif Input.is_action_just_released("attack"):
		if attack_hold_time > 0 and attack_hold_time < CHARGE_THRESHOLD:
			# Quick tap - do combo attack
			state_machine.transition_to("ComboAttack")
		attack_hold_time = 0.0
	else:
		attack_hold_time = 0.0
	
	# Check for movement input
	var direction = player.get_input_direction()
	
	if direction != Vector2.ZERO:
		if player.is_running():
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Walk")
