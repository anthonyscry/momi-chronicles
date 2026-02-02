extends "res://characters/companions/companion_base.gd"
class_name MomiCompanion

## Zoomies state
var zoomies_active: bool = false
const ZOOMIES_SPEED_MULT: float = 1.5
const ZOOMIES_ATTACK_MULT: float = 1.3

func _ready() -> void:
	companion_id = "momi"
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
	
	# Priority states
	if zoomies_active:
		# When zoomies active, use charge animation
		new_animation = "charge"
	elif velocity.length() > 5:
		# Check if running (hold run key)
		new_animation = "walk"
	
	if is_attacking:
		new_animation = "attack"
	
	if sprite.animation != new_animation:
		sprite.play(new_animation)
	
	# Facing
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false

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
		sprite.play("charge")
	AudioManager.play_sfx("dodge")  # Reuse dodge sound for activation

func _deactivate_zoomies() -> void:
	zoomies_active = false
	meter_active = false
	attack_damage = CompanionData.COMPANIONS["momi"].base_stats.attack_damage
	if sprite:
		sprite.modulate = Color.WHITE

func play_happy() -> void:
	if sprite and not is_knocked_out:
		sprite.play("happy")
		await get_tree().create_timer(0.3).timeout
		_update_animation()

func play_bark() -> void:
	if sprite and not is_knocked_out:
		sprite.play("bark")
		await get_tree().create_timer(0.2).timeout
		_update_animation()

func play_dig() -> void:
	if sprite and not is_knocked_out:
		sprite.play("dig")
		await get_tree().create_timer(0.4).timeout
		_update_animation()

func play_chomp() -> void:
	if sprite and not is_knocked_out:
		sprite.play("chomp")
		await get_tree().create_timer(0.3).timeout
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
	zoomies_active = false
	if sprite:
		sprite.modulate = Color.WHITE
		sprite.play("idle")
