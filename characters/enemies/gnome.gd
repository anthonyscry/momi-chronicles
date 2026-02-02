extends "res://characters/enemies/enemy_base.gd"

## Garden Gnome enemy - stationary sentry that throws explosive bombs
## Stationary turret enemy for rooftop encounters

## Detection and attack ranges
const DETECTION_RANGE: float = 200.0
const ATTACK_RANGE: float = 300.0

## Bomb properties
const BOMB_DAMAGE: float = 25.0
const BOMB_AOE_RADIUS: float = 64.0
const BOMB_FUSE_TIME: float = 1.5
const BOMB_ARC_HEIGHT: float = 80.0
const THROW_SPEED: float = 180.0

## State durations
const TELEGRAPH_DURATION: float = 0.8
const COOLDOWN_DURATION: float = 2.0

## Telegraph animation properties
const PULSE_SPEED: float = 8.0
const MAX_SCALE: float = 1.4
const MIN_SCALE: float = 1.0

var can_attack: bool = true
var telegraph_sprite: Node2D = null
var pulse_phase: float = 0.0

func _ready() -> void:
	# Gnome-specific stats - stationary enemy with moderate HP
	patrol_speed = 0.0
	chase_speed = 0.0
	detection_range = DETECTION_RANGE
	attack_range = ATTACK_RANGE
	attack_damage = BOMB_DAMAGE
	attack_cooldown = 3.0
	knockback_force = 30.0  # Heavy - barely moves
	exp_value = 25
	
	# Call parent ready
	super._ready()
	
	# Get reference to telegraph sprite
	telegraph_sprite = get_node_or_null("TelegraphSprite")


func _on_hurt(attacking_hitbox: Hitbox) -> void:
	var damage_amount = attacking_hitbox.damage if attacking_hitbox else 0
	super._on_hurt(attacking_hitbox)
	Events.gnome_hurt.emit(self, damage_amount)


## Override to use gnome-specific attack state
func get_attack_state_name() -> String:
	return "GnomeThrow"


## Initialize gnome-specific drop table
func _init_default_drops() -> void:
	# Gnomes drop coins and occasional garden items
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 0.8, "min": 3, "max": 6},
		{"item_id": "guard_snack", "chance": 0.1, "min": 1, "max": 1},
		{"item_id": "revival_bone", "chance": 0.05, "min": 1, "max": 1},
	]


## Override update_animation for gnome states
func _update_animation() -> void:
	if not sprite or not is_alive():
		return

	var new_animation: String = "idle"
	if state_machine and state_machine.current_state_name:
		var state_name = state_machine.current_state_name
		if state_name == "GnomeIdle":
			new_animation = "idle"
		elif state_name == "GnomeTelegraph":
			new_animation = "telegraph"
		elif state_name == "GnomeThrow":
			new_animation = "throw"
		elif state_name == "GnomeCooldown":
			new_animation = "idle"
		elif state_name == "Hurt":
			new_animation = "hurt"
		elif state_name == "Death":
			new_animation = "death"

	if sprite.animation != new_animation:
		sprite.play(new_animation)


## Show telegraph sprite with pulsing animation
func show_telegraph() -> void:
	if telegraph_sprite:
		telegraph_sprite.visible = true


## Hide telegraph sprite
func hide_telegraph() -> void:
	if telegraph_sprite:
		telegraph_sprite.visible = false
		telegraph_sprite.scale = Vector2.ONE
		telegraph_sprite.rotation = 0.0
		var visual = _get_telegraph_visual()
		if visual:
			visual.scale = Vector2.ONE
			visual.modulate = Color(1.0, 0.5, 0.0, 1.0)


## Update telegraph pulse animation
func update_telegraph_pulse(delta: float) -> void:
	if not telegraph_sprite:
		return
	
	pulse_phase += delta * PULSE_SPEED
	
	var visual = _get_telegraph_visual()
	if visual:
		# Scale pulsing
		var scale_factor = MAX_SCALE - (MAX_SCALE - MIN_SCALE) * (0.5 + 0.5 * sin(pulse_phase))
		visual.scale = Vector2(scale_factor, scale_factor)
		
		# Color intensity oscillation (orange)
		var intensity = 0.7 + 0.3 * (0.5 + 0.5 * sin(pulse_phase * 1.5))
		visual.modulate = Color(1.0, intensity * 0.5, 0.0, 1.0)
	
	# Slight rotation wobble
	telegraph_sprite.rotation = sin(pulse_phase * 0.5) * 0.1


## Reset telegraph animation state
func reset_telegraph() -> void:
	pulse_phase = 0.0


func _get_telegraph_visual() -> CanvasItem:
	if not telegraph_sprite:
		return null
	var sprite_2d = telegraph_sprite.get_node_or_null("Sprite2D")
	if sprite_2d:
		return sprite_2d
	var label = telegraph_sprite.get_node_or_null("Label")
	if label:
		return label
	return null
