extends State
class_name CatPounce
## Cat pounce state - reveals from stealth, lunges at target with high damage.

const POUNCE_DURATION: float = 0.3
const HITBOX_START: float = 0.1
const HITBOX_END: float = 0.25

var pounce_timer: float = 0.0
var hitbox_active: bool = false
var pounce_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	pounce_timer = 0.0
	hitbox_active = false
	player.is_stealthed = false
	
	# Fully reveal from stealth
	if player.sprite:
		player.sprite.modulate.a = 1.0
	
	# Calculate lunge direction
	if player.target:
		pounce_direction = player.get_direction_to_target()
		player.update_facing(pounce_direction)
	else:
		pounce_direction = player.facing_direction
	
	# Set lunge velocity
	player.velocity = pounce_direction * player.pounce_speed
	
	# Reset hitbox for fresh attack
	if player.hitbox:
		player.hitbox.reset()
		_position_hitbox(pounce_direction)
	
	# Start attack cooldown
	player.start_attack_cooldown()
	
	# Telegraph: "!" warning above cat
	_show_telegraph()
	
	# Squash-stretch animation on sprite
	_apply_pounce_squash()


func exit() -> void:
	if player.hitbox:
		player.hitbox.disable()
	hitbox_active = false


func physics_update(delta: float) -> void:
	# Cancel if stunned
	if not player.can_act():
		if player.hitbox:
			player.hitbox.disable()
		state_machine.transition_to("Idle")
		return
	
	pounce_timer += delta
	var progress = pounce_timer / POUNCE_DURATION
	
	# Enable hitbox during active frames (0.1 - 0.25)
	if progress >= HITBOX_START and progress < HITBOX_END:
		if not hitbox_active and player.hitbox:
			player.hitbox.enable()
			hitbox_active = true
	elif progress >= HITBOX_END:
		if hitbox_active and player.hitbox:
			player.hitbox.disable()
			hitbox_active = false
	
	# Decelerate velocity during pounce
	player.velocity = player.velocity.lerp(Vector2.ZERO, delta * 6.0)
	player.move_and_slide()
	
	# Pounce finished — transition to retreat
	if pounce_timer >= POUNCE_DURATION:
		state_machine.transition_to("CatRetreat")


func _position_hitbox(direction: Vector2) -> void:
	if not player.hitbox:
		return
	var hitbox_shape = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	hitbox_shape.position = direction.normalized() * 10


## Show "!" telegraph above cat (same pattern as enemy_attack.gd)
func _show_telegraph() -> void:
	var label = Label.new()
	label.text = "!"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-4, -26)
	label.z_index = 90
	label.scale = Vector2(0.5, 0.5)
	label.pivot_offset = Vector2(4, 10)
	player.add_child(label)
	
	# Pop-in animation
	var tween = player.create_tween()
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.06)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.04)
	tween.tween_interval(0.12)
	tween.tween_property(label, "modulate:a", 0.0, 0.1)
	tween.tween_callback(label.queue_free)


## Squash-stretch on pounce start for weight feel
func _apply_pounce_squash() -> void:
	if not player.sprite:
		return
	var original_scale = player.sprite.scale
	var tween = player.create_tween()
	# Stretch in pounce direction
	tween.tween_property(player.sprite, "scale", original_scale * Vector2(1.4, 0.7), 0.06)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(player.sprite, "scale", original_scale * Vector2(0.9, 1.1), 0.08)
	tween.tween_property(player.sprite, "scale", original_scale, 0.06)
