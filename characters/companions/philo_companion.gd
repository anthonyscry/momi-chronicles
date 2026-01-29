extends "res://characters/companions/companion_base.gd"
class_name PhiloCompanion

## Motivation affects healing output
const HIGH_MOTIVATION_THRESHOLD: float = 70.0

func _ready() -> void:
	companion_id = "philo"
	super._ready()

func _update_meter(delta: float) -> void:
	# Motivation drains over time (unique: starts high!)
	meter_value = max(0, meter_value - meter_drain_rate * delta)
	meter_changed.emit(meter_value, meter_max)
	
	# Visual indicator when motivation is low
	if sprite:
		if meter_value < 30:
			sprite.modulate = Color(0.7, 0.7, 0.8)  # Dim when unmotivated
		else:
			sprite.modulate = Color.WHITE

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
