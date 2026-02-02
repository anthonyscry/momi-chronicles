extends State
class_name EnemyAttack
## Enemy attack state - performs an attack on the player.

const ATTACK_DURATION: float = 0.4
const HITBOX_START: float = 0.15
const HITBOX_END: float = 0.35

## Telegraph: brief red flash before attack connects
const TELEGRAPH_DURATION: float = 0.12

var attack_timer: float = 0.0
var hitbox_active: bool = false
var telegraph_indicator: ColorRect = null

func enter() -> void:
	player.velocity = Vector2.ZERO
	attack_timer = 0.0
	hitbox_active = false
	if player.sprite:
		player.sprite.play("attack")
	if player.target:
		var direction = player.get_direction_to_target()
		player.update_facing(direction)
		_position_hitbox(direction)
	
	if player.hitbox:
		player.hitbox.reset()
	
	player.start_attack_cooldown()
	
	_show_telegraph()

func exit() -> void:
	if player.hitbox:
		player.hitbox.disable()
	hitbox_active = false

func physics_update(delta: float) -> void:
	# Cancel attack if stunned
	if not player.can_act():
		if player.hitbox:
			player.hitbox.disable()
		state_machine.transition_to("Idle")
		return
	
	attack_timer += delta
	var progress = attack_timer / ATTACK_DURATION
	
	# Enable hitbox during active frames
	if progress >= HITBOX_START and progress < HITBOX_END:
		if not hitbox_active and player.hitbox:
			player.hitbox.enable()
			hitbox_active = true
	elif progress >= HITBOX_END:
		if hitbox_active and player.hitbox:
			player.hitbox.disable()
			hitbox_active = false
	
	# Attack finished
	if attack_timer >= ATTACK_DURATION:
		state_machine.transition_to("Chase")

func _position_hitbox(direction: Vector2) -> void:
	if not player.hitbox:
		return
	
	var hitbox_shape = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	
	# Position based on direction
	hitbox_shape.position = direction.normalized() * 12


## Show a brief red "!" indicator above enemy before attacking
func _show_telegraph() -> void:
	# Red exclamation mark above head
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
	tween.tween_interval(TELEGRAPH_DURATION)
	tween.tween_property(label, "modulate:a", 0.0, 0.1)
	tween.tween_callback(label.queue_free)
	
	# Also flash the enemy sprite red briefly
	if player.sprite:
		var flash_tween = player.create_tween()
		flash_tween.tween_property(player.sprite, "modulate", Color(1.5, 0.6, 0.6), 0.06)
		flash_tween.tween_property(player.sprite, "modulate", Color.WHITE, 0.1)
