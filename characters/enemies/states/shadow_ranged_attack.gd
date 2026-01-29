extends State
class_name ShadowRangedAttack
## Shadow ranged attack state — charges up, fires a shadow bolt at the player,
## then transitions back to ShadowPhase after cooldown.

const CHARGE_DURATION: float = 0.4
const TOTAL_DURATION: float = 0.9  ## charge + fire + recovery

var attack_timer: float = 0.0
var has_fired: bool = false

## Telegraph visual
var telegraph_label: Label = null


func enter() -> void:
	attack_timer = 0.0
	has_fired = false

	# Stop movement
	player.velocity = Vector2.ZERO

	# Face the target
	if player.target:
		var dir = player.get_direction_to_target()
		player.update_facing(dir)

	# Start attack cooldown
	player.start_attack_cooldown()

	# Visual charge-up: pulse the sprite
	_show_charge_telegraph()


func exit() -> void:
	# Clean up telegraph if still present
	if telegraph_label and is_instance_valid(telegraph_label):
		telegraph_label.queue_free()
		telegraph_label = null


func physics_update(delta: float) -> void:
	# Cancel if stunned
	if not player.can_act():
		state_machine.transition_to("ShadowPhase")
		return

	attack_timer += delta

	# Fire at charge completion
	if attack_timer >= CHARGE_DURATION and not has_fired:
		has_fired = true
		_fire_shadow_bolt()

	# Finish state after total duration
	if attack_timer >= TOTAL_DURATION:
		state_machine.transition_to("ShadowPhase")


## Fire a shadow bolt toward the player
func _fire_shadow_bolt() -> void:
	if not player.target:
		return

	var bolt_scene = player.SHADOW_BOLT_SCENE
	if not bolt_scene:
		return

	var bolt = bolt_scene.instantiate()
	bolt.fire(player.global_position, player.target.global_position)

	# Add bolt to the zone (parent of the enemy)
	var zone = player.get_parent()
	if zone:
		zone.add_child(bolt)


## Show telegraph: purple "!" and sprite pulse during charge
func _show_charge_telegraph() -> void:
	# Purple exclamation mark above head
	telegraph_label = Label.new()
	telegraph_label.text = "!"
	telegraph_label.add_theme_font_size_override("font_size", 12)
	telegraph_label.add_theme_color_override("font_color", Color(0.6, 0.2, 0.8))
	telegraph_label.add_theme_color_override("font_outline_color", Color(0.1, 0, 0.2))
	telegraph_label.add_theme_constant_override("outline_size", 2)
	telegraph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	telegraph_label.position = Vector2(-4, -26)
	telegraph_label.z_index = 90
	telegraph_label.scale = Vector2(0.5, 0.5)
	telegraph_label.pivot_offset = Vector2(4, 10)
	player.add_child(telegraph_label)

	# Pop-in animation
	var tween = player.create_tween()
	tween.tween_property(telegraph_label, "scale", Vector2(1.3, 1.3), 0.06)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(telegraph_label, "scale", Vector2(1.0, 1.0), 0.04)
	tween.tween_interval(CHARGE_DURATION - 0.1)
	tween.tween_property(telegraph_label, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func():
		if telegraph_label and is_instance_valid(telegraph_label):
			telegraph_label.queue_free()
			telegraph_label = null
	)

	# Sprite purple pulse during charge
	if player.sprite:
		var flash_tween = player.create_tween()
		flash_tween.tween_property(player.sprite, "modulate", Color(1.5, 0.6, 1.5), 0.1)
		flash_tween.tween_property(player.sprite, "modulate", Color.WHITE, 0.15)
