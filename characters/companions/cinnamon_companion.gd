extends CompanionBase
class_name CinnamonCompanion

## Overheat state
var is_blocking: bool = false
var is_overheated: bool = false
const OVERHEAT_COOLDOWN: float = 3.0
var overheat_timer: float = 0.0

func _ready() -> void:
	companion_id = "cinnamon"
	super._ready()

func _update_meter(delta: float) -> void:
	if is_overheated:
		# Forced cooldown - drain quickly
		meter_value -= meter_drain_rate * 2.0 * delta
		overheat_timer -= delta
		
		if overheat_timer <= 0 or meter_value <= 0:
			meter_value = 0
			is_overheated = false
			if sprite:
				sprite.modulate = Color.WHITE
	elif is_blocking:
		# Heat builds while blocking (handled in damage)
		pass
	else:
		# Cool down when not blocking
		meter_value = max(0, meter_value - meter_drain_rate * delta)
	
	meter_changed.emit(meter_value, meter_max)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Block input
	if is_player_controlled and not is_overheated:
		is_blocking = Input.is_action_pressed("block")
	elif not is_player_controlled and ai:
		is_blocking = ai.should_block() and not is_overheated

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var damage = 0
	var parent = area.get_parent()
	if parent and parent.has_method("get") and parent.get("damage"):
		damage = parent.damage
	elif area.get("damage"):
		damage = area.damage
	
	if damage <= 0:
		return
	
	if is_blocking and not is_overheated:
		# Block reduces damage
		var reduced_damage = int(damage * 0.5)
		take_damage(reduced_damage)
		
		# Build overheat
		meter_value += meter_build_rate
		if meter_value >= meter_max:
			_trigger_overheat()
		
		meter_changed.emit(meter_value, meter_max)
		
		# Block flash
		if sprite:
			sprite.modulate = Color(0.7, 0.7, 1.0)
			await get_tree().create_timer(0.1).timeout
			if sprite:
				sprite.modulate = Color.WHITE
	else:
		take_damage(damage)

func _trigger_overheat() -> void:
	is_overheated = true
	is_blocking = false
	overheat_timer = OVERHEAT_COOLDOWN
	meter_value = meter_max
	
	# Visual feedback
	if sprite:
		sprite.modulate = Color(1.0, 0.5, 0.3)  # Orange tint
	
	AudioManager.play_sfx("player_hurt")
