extends State
class_name RatPoisonAttack
## Poison bite attack for Sewer Rats — fast, short-range bite that
## inflicts poison damage-over-time on the player via HealthComponent.

const ATTACK_DURATION: float = 0.3
const HITBOX_START: float = 0.1 / ATTACK_DURATION  # normalised progress
const HITBOX_END: float = 0.25 / ATTACK_DURATION

## Telegraph duration before the bite lands
const TELEGRAPH_DURATION: float = 0.08

var attack_timer: float = 0.0
var hitbox_active: bool = false
var poison_applied: bool = false

func enter() -> void:
	player.velocity = Vector2.ZERO
	attack_timer = 0.0
	hitbox_active = false
	poison_applied = false

	# Face the target
	if player.target:
		var direction = player.get_direction_to_target()
		player.update_facing(direction)
		_position_hitbox(direction)

	# Reset hitbox hit tracking
	if player.hitbox:
		player.hitbox.reset()

	# Start cooldown immediately
	player.start_attack_cooldown()

	# Quick telegraph
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
		# Apply poison if hitbox connected
		if not poison_applied:
			poison_applied = true
			_try_apply_poison()

	# Attack finished — return to swarm chase
	if attack_timer >= ATTACK_DURATION:
		state_machine.transition_to("RatSwarmChase")


## Position hitbox collision shape toward target direction.
func _position_hitbox(direction: Vector2) -> void:
	if not player.hitbox:
		return
	var hitbox_shape = player.hitbox.get_node_or_null("CollisionShape2D")
	if not hitbox_shape:
		return
	hitbox_shape.position = direction.normalized() * 6


## Apply poison DoT to any target the hitbox connected with.
func _try_apply_poison() -> void:
	if not player.hitbox:
		return
	for target_node in player.hitbox.hit_targets:
		if not is_instance_valid(target_node):
			continue
		var health_comp = target_node.get_node_or_null("HealthComponent")
		if health_comp and health_comp.has_method("apply_poison"):
			health_comp.apply_poison(player.poison_damage, player.poison_duration)


## Show a brief "!" telegraph above the rat before biting.
func _show_telegraph() -> void:
	var label = Label.new()
	label.text = "!"
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.3))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-3, -20)
	label.z_index = 90
	label.scale = Vector2(0.5, 0.5)
	label.pivot_offset = Vector2(3, 8)
	player.add_child(label)

	var tween = player.create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.04)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.03)
	tween.tween_interval(TELEGRAPH_DURATION)
	tween.tween_property(label, "modulate:a", 0.0, 0.08)
	tween.tween_callback(label.queue_free)

	# Flash sprite green briefly
	if player.sprite:
		var flash_tween = player.create_tween()
		flash_tween.tween_property(player.sprite, "modulate", Color(0.6, 1.5, 0.6), 0.04)
		flash_tween.tween_property(player.sprite, "modulate", Color.WHITE, 0.06)
