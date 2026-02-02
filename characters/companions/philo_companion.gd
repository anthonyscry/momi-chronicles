extends "res://characters/companions/companion_base.gd"
class_name PhiloCompanion

## Motivation affects healing output
const HIGH_MOTIVATION_THRESHOLD: float = 70.0
const LOW_MOTIVATION_THRESHOLD: float = 30.0

var is_jealous: bool = false

func _ready() -> void:
	companion_id = "philo"
	super._ready()
	if sprite:
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_animation()

func _update_animation() -> void:
	if not sprite or is_knocked_out:
		return
	
	var new_animation: String = "idle"
	
	# Priority states - motivation-based
	if meter_value < LOW_MOTIVATION_THRESHOLD:
		new_animation = "lazy"
	elif meter_value >= HIGH_MOTIVATION_THRESHOLD:
		new_animation = "motivated"
	
	if is_attacking:
		new_animation = "attack"
	elif velocity.length() > 5:
		# Use motivated_run when motivated and moving
		if meter_value >= HIGH_MOTIVATION_THRESHOLD:
			new_animation = "motivated_run"
		else:
			new_animation = "walk"
	
	if is_jealous:
		new_animation = "jealous"
	
	if sprite.animation != new_animation:
		sprite.play(new_animation)
	
	# Facing
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

func _update_meter(delta: float) -> void:
	# Motivation drains over time (unique: starts high!)
	meter_value = max(0, meter_value - meter_drain_rate * delta)
	meter_changed.emit(meter_value, meter_max)

## Called when Momi (active companion) takes damage
## This is Philo's unique mechanic - gets motivated when team needs help!
func on_ally_damaged(amount: int) -> void:
	# Restore motivation when Momi gets hit
	var motivation_gain = meter_build_rate * (float(amount) / 10.0)
	meter_value = min(meter_value + motivation_gain, meter_max)
	meter_changed.emit(meter_value, meter_max)
	
	# Visual feedback
	if sprite:
		sprite.modulate = Color(0.5, 1.0, 1.0)  # Cyan flash
		await get_tree().create_timer(0.2).timeout
		if sprite:
			sprite.modulate = Color.WHITE

## Philo's attacks can heal allies when motivated
func _on_attack_performed() -> void:
	if meter_value >= HIGH_MOTIVATION_THRESHOLD:
		# High motivation = bonus healing to nearby allies
		_heal_nearby_allies()

func _heal_nearby_allies() -> void:
	var allies = get_tree().get_nodes_in_group("player_allies")
	for ally in allies:
		if ally == self:
			continue
		if not is_instance_valid(ally):
			continue
		if ally.global_position.distance_to(global_position) < 80:
			if ally.has_method("heal"):
				ally.heal(3)  # Small heal per attack

func play_bark() -> void:
	if sprite and not is_knocked_out:
		sprite.play("bark")
		await get_tree().create_timer(0.2).timeout
		_update_animation()

func play_happy() -> void:
	if sprite and not is_knocked_out:
		sprite.play("happy")
		await get_tree().create_timer(0.3).timeout
		_update_animation()

func set_jealous(state: bool) -> void:
	is_jealous = state
	_update_animation()

func take_damage(amount: int) -> void:
	var old_health = current_health
	super.take_damage(amount)
	if current_health > 0 and old_health != current_health and sprite:
		sprite.play("hurt")
		await get_tree().create_timer(0.2).timeout
		_update_animation()

func _knock_out() -> void:
	if sprite:
		sprite.play("death")
	await get_tree().create_timer(0.3).timeout
	super._knock_out()

func revive(health_percent: float = 0.5) -> void:
	super.revive(health_percent)
	is_jealous = false
	if sprite:
		sprite.modulate = Color.WHITE
		sprite.play("idle")
