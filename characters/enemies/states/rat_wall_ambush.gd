extends State
class_name RatWallAmbush

## Roof Rat ambush state - telegraph with "!" then drop from wall to attack player.

const AMBUSH_DURATION: float = 0.35
const HITBOX_START: float = 0.12
const HITBOX_END: float = 0.28
const DROP_HEIGHT: float = 80.0

var ambush_timer: float = 0.0
var hitbox_active: bool = false
var ambush_start_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO

func enter() -> void:
	ambush_timer = 0.0
	hitbox_active = false
	player.is_stealthed = false
	player.last_ambush_position = player.global_position
	ambush_start_pos = player.global_position
	
	if player.target:
		target_pos = player.target.global_position
		if player.target.has_node("CollisionShape2D"):
			var shape = player.target.get_node("CollisionShape2D")
			target_pos.y = player.target.global_position.y + shape.shape.size.y / 2
	
	if player.sprite:
		player.sprite.play("ambush")
		var tween = player.create_tween()
		tween.tween_property(player.sprite, "scale:y", 1.0, 0.1)
		tween.parallel().tween_property(player.sprite, "modulate:a", 1.0, 0.1)
	
	_show_telegraph()
	
	if player.hitbox:
		player.hitbox.monitoring = false
		player.hitbox.monitorable = false

func update(delta: float) -> void:
	if not player.can_act():
		if player.hitbox:
			player.hitbox.monitoring = false
			player.hitbox.monitorable = false
		state_machine.transition_to("WallStealth")
		return
	
	ambush_timer += delta
	var progress = ambush_timer / AMBUSH_DURATION
	
	var y_offset = progress * DROP_HEIGHT
	player.global_position.y = ambush_start_pos.y + y_offset
	
	if progress >= HITBOX_START and progress < HITBOX_END:
		if not hitbox_active and player.hitbox:
			player.hitbox.monitoring = true
			player.hitbox.monitorable = true
			hitbox_active = true
	elif progress >= HITBOX_END:
		if hitbox_active and player.hitbox:
			player.hitbox.monitoring = false
			player.hitbox.monitorable = false
			hitbox_active = false
	
	if player.target:
		var to_target = player.target.global_position - player.global_position
		to_target.y = 0
		player.velocity = to_target.normalized() * (player.WALL_PATROL_SPEED * 0.5)
	else:
		player.velocity = Vector2.ZERO
	
	player.move_and_slide()
	
	if ambush_timer >= AMBUSH_DURATION:
		state_machine.transition_to("WallRetreat")

func _show_telegraph() -> void:
	var label = Label.new()
	label.text = "!"
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-3, -20)
	label.z_index = 90
	label.scale = Vector2(0.5, 0.5)
	label.pivot_offset = Vector2(3, 8)
	player.add_child(label)
	
	var tween = player.create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.05)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.05)
	tween.tween_interval(0.15)
	tween.tween_property(label, "queue_free")

func exit() -> void:
	ambush_timer = 0.0
	hitbox_active = false
	if player.hitbox:
		player.hitbox.monitoring = false
		player.hitbox.monitorable = false
