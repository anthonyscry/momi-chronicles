extends Node
class_name GuardComponent
## Guard meter component for blocking. Depletes while blocking, regenerates when not.

signal guard_changed(current: float, max_guard: float)
signal guard_broken
signal guard_restored

@export var max_guard: float = 100.0
@export var guard_drain_rate: float = 30.0  # Per second while blocking
@export var guard_regen_rate: float = 20.0  # Per second when not blocking
@export var regen_delay: float = 1.0  # Seconds before regen starts

var current_guard: float = 100.0
var is_blocking: bool = false
var regen_timer: float = 0.0

func _ready() -> void:
	current_guard = max_guard
	Events.guard_changed.emit(current_guard, max_guard)

func _process(delta: float) -> void:
	if is_blocking:
		regen_timer = regen_delay
		use_guard(guard_drain_rate * delta)
	elif current_guard < max_guard:
		regen_timer -= delta
		if regen_timer <= 0:
			restore_guard(guard_regen_rate * delta)

func use_guard(amount: float) -> bool:
	if current_guard <= 0:
		return false
	current_guard = max(0, current_guard - amount)
	guard_changed.emit(current_guard, max_guard)
	Events.guard_changed.emit(current_guard, max_guard)
	if current_guard <= 0:
		guard_broken.emit()
		Events.player_guard_broken.emit()
		is_blocking = false
	return true

func restore_guard(amount: float) -> void:
	var was_empty = current_guard <= 0
	current_guard = min(max_guard, current_guard + amount)
	guard_changed.emit(current_guard, max_guard)
	Events.guard_changed.emit(current_guard, max_guard)
	if was_empty and current_guard > 0:
		guard_restored.emit()

func start_blocking() -> void:
	if current_guard > 0:
		is_blocking = true

func stop_blocking() -> void:
	is_blocking = false

func can_block() -> bool:
	return current_guard > 0

func get_damage_reduction() -> float:
	return 0.5 if is_blocking else 0.0

func get_guard_percent() -> float:
	return current_guard / max_guard if max_guard > 0 else 0.0

## Called when hit while blocking - returns true if parried (no damage)
func on_blocked_hit(attacker: Node, incoming_damage: int) -> bool:
	var owner_node = get_parent()
	if owner_node == null:
		return false
	
	# Check if player is in parry window
	var block_state = null
	if owner_node.has_node("StateMachine"):
		block_state = owner_node.get_node("StateMachine").current_state
	
	if block_state and block_state.has_method("is_in_parry_window"):
		if block_state.is_in_parry_window():
			# Perfect parry!
			_execute_parry(attacker, incoming_damage)
			return true
	
	# Normal block - drain extra guard on hit
	use_guard(15.0)
	return false

func _execute_parry(attacker: Node, incoming_damage: int) -> void:
	# Reflect 50% damage back
	var reflect_damage = int(incoming_damage * 0.5)
	
	if attacker.has_node("HealthComponent"):
		attacker.get_node("HealthComponent").take_damage(reflect_damage)
	
	# Stun attacker for 1 second
	if attacker.has_method("apply_stun"):
		attacker.apply_stun(1.0)
	
	# Visual feedback - flash white briefly
	var owner_node = get_parent()
	if owner_node and owner_node.has_node("Sprite2D"):
		var sprite = owner_node.get_node("Sprite2D")
		var original_color = sprite.color
		sprite.color = Color.WHITE
		# Restore after brief flash
		get_tree().create_timer(0.1).timeout.connect(func(): sprite.color = original_color)
	
	Events.player_parried.emit(attacker, reflect_damage)
	print("[Parry] Perfect parry! Reflected %d damage, stunned attacker" % reflect_damage)
