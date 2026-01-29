extends "res://characters/enemies/enemy_base.gd"
class_name ShadowCreature
## Shadow Creature enemy — mysterious ranged attacker that phases in/out of visibility
## and fires shadow bolt projectiles. Teleports when hit to evade.
## The primary "strange threat" from the game's lore.

## Shadow bolt projectile scene (preloaded)
const SHADOW_BOLT_SCENE = preload("res://components/projectile/shadow_bolt.tscn")

## Phase cycling properties
var phase_timer: float = 0.0
var phase_cycle: float = 4.0  ## Full cycle duration (phase out + phase in)
var is_phased_out: bool = false

## Teleport evasion
var teleport_distance: float = 50.0

## Glow aura child
var glow_aura: Polygon2D


func _ready() -> void:
	# Shadow-specific stats
	patrol_speed = 25.0
	chase_speed = 35.0
	detection_range = 100.0
	attack_range = 80.0
	attack_damage = 12
	attack_cooldown = 2.0
	knockback_force = 40.0
	exp_value = 40

	# Call parent ready
	super._ready()

	# Shadow appearance: very dark purple amorphous blob
	if sprite:
		sprite.color = Color(0.15, 0.05, 0.25)
		sprite.polygon = PackedVector2Array([
			Vector2(-5, -7), Vector2(-2, -9), Vector2(2, -9), Vector2(5, -7),
			Vector2(7, -3), Vector2(6, 2), Vector2(4, 6), Vector2(1, 8),
			Vector2(-2, 7), Vector2(-5, 4), Vector2(-7, -1)
		])

	# Create glow aura (larger translucent purple polygon behind sprite)
	glow_aura = Polygon2D.new()
	glow_aura.polygon = PackedVector2Array([
		Vector2(-8, -10), Vector2(-3, -12), Vector2(3, -12), Vector2(8, -10),
		Vector2(10, -4), Vector2(9, 3), Vector2(6, 9), Vector2(2, 11),
		Vector2(-3, 10), Vector2(-7, 6), Vector2(-10, -1)
	])
	glow_aura.color = Color(0.3, 0.1, 0.5, 0.25)
	glow_aura.z_index = -1
	if sprite:
		sprite.add_child(glow_aura)
	else:
		add_child(glow_aura)


## Shadow drops: 80% 2-4 coins, 30% health
func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 0.8, "min": 2, "max": 4},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 0.3, "min": 1, "max": 1},
	]


func _process(delta: float) -> void:
	super._process(delta)

	# Phase cycling — toggle visibility on a timer
	# Only cycle when alive and not in hurt/attack states
	if not is_alive():
		return
	var current_state_name = ""
	if state_machine and state_machine.current_state:
		current_state_name = state_machine.current_state.name.to_lower()
	if current_state_name == "hurt" or current_state_name == "death":
		return

	phase_timer += delta
	var half_cycle = phase_cycle / 2.0
	if phase_timer >= half_cycle:
		phase_timer -= half_cycle
		_toggle_phase()


## Toggle between phased-out (barely visible) and phased-in (attackable)
func _toggle_phase() -> void:
	is_phased_out = not is_phased_out
	if is_phased_out:
		_phase_out()
	else:
		_phase_in()


## Phase out: become barely visible and invulnerable
func _phase_out() -> void:
	is_phased_out = true
	# Tween alpha to ghostly
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.1, 0.3)
	# Disable hurtbox so can't be hit
	if hurtbox:
		hurtbox.start_invincibility(0.0)  # Permanent until phase in


## Phase in: become visible and vulnerable
func _phase_in() -> void:
	is_phased_out = false
	# Tween alpha back
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.85, 0.3)
	# Re-enable hurtbox
	if hurtbox:
		hurtbox.end_invincibility()


## Override hurt to add teleport evasion
func _on_hurt(attacking_hitbox: Hitbox) -> void:
	# Force phase in when hit (so player sees damage feedback)
	if is_phased_out:
		_phase_in()
		phase_timer = 0.0  # Reset cycle

	# Store old position for poof effect
	var old_pos = global_position

	# Call parent hurt (damage, knockback, state transition)
	super._on_hurt(attacking_hitbox)

	# Teleport to random nearby position
	var random_angle = randf() * TAU
	var teleport_offset = Vector2(cos(random_angle), sin(random_angle)) * teleport_distance
	global_position = old_pos + teleport_offset

	# Purple poof particles at old position
	_spawn_teleport_poof(old_pos)


## Spawn purple particle poof at position (teleport visual)
func _spawn_teleport_poof(pos: Vector2) -> void:
	if not get_parent():
		return
	for i in range(8):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(0.4, 0.1, 0.6, 0.8)
		particle.global_position = pos + Vector2(randf_range(-4, 4), randf_range(-4, 4))
		get_parent().add_child(particle)

		var angle = randf() * TAU
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * randf_range(10, 22)
		var tween = particle.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.3).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.35)
		tween.tween_callback(particle.queue_free)
