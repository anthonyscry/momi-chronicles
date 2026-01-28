extends CompanionBase
class_name MomiCompanion

## Zoomies state
var zoomies_active: bool = false
const ZOOMIES_SPEED_MULT: float = 1.5
const ZOOMIES_ATTACK_MULT: float = 1.3

func _ready() -> void:
	companion_id = "momi"
	super._ready()

func _update_meter(delta: float) -> void:
	if zoomies_active:
		# Drain while active
		meter_value -= meter_drain_rate * delta
		if meter_value <= 0:
			meter_value = 0
			_deactivate_zoomies()
	
	meter_changed.emit(meter_value, meter_max)

func _on_attack_performed() -> void:
	if not zoomies_active:
		# Build meter from combat
		meter_value = min(meter_value + meter_build_rate, meter_max)
		meter_changed.emit(meter_value, meter_max)

func _get_speed_multiplier() -> float:
	return ZOOMIES_SPEED_MULT if zoomies_active else 1.0

func _unhandled_input(event: InputEvent) -> void:
	if not is_player_controlled:
		return
	
	# Special ability key to activate Zoomies
	if event.is_action_pressed("special_attack") and meter_value >= 50:
		if not zoomies_active:
			_activate_zoomies()

func _activate_zoomies() -> void:
	zoomies_active = true
	meter_active = true
	attack_damage = int(CompanionData.COMPANIONS["momi"].base_stats.attack_damage * ZOOMIES_ATTACK_MULT)
	if sprite:
		sprite.modulate = Color(1.2, 1.0, 0.7)  # Golden tint
	AudioManager.play_sfx("dodge")  # Reuse dodge sound for activation

func _deactivate_zoomies() -> void:
	zoomies_active = false
	meter_active = false
	attack_damage = CompanionData.COMPANIONS["momi"].base_stats.attack_damage
	if sprite:
		sprite.modulate = Color.WHITE
