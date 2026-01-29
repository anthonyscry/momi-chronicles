extends State
class_name AlphaSummon
## Alpha Raccoon summon - calls raccoon reinforcements.
## Phase: CHARGE (0.6s) -> SUMMON (instant) -> RECOVERY (0.8s)

const CHARGE_TIME: float = 0.6
const RECOVERY_TIME: float = 0.8
const MAX_MINIONS: int = 3  # Cap total alive minions
const RACCOON_SCENE = preload("res://characters/enemies/raccoon.tscn")

var timer: float = 0.0
var summoned: bool = false
enum Phase { CHARGE, SUMMON, RECOVERY }
var current_phase: Phase = Phase.CHARGE

func enter() -> void:
	timer = 0.0
	summoned = false
	current_phase = Phase.CHARGE
	player.velocity = Vector2.ZERO
	# Blue-purple glow during charge
	if player.sprite:
		player.sprite.modulate = Color(0.8, 0.7, 1.2)

func exit() -> void:
	if player.sprite:
		player.sprite.modulate = Color.WHITE

func physics_update(delta: float) -> void:
	timer += delta
	match current_phase:
		Phase.CHARGE:
			# Pulse sprite
			if player.sprite:
				player.sprite.position.x = randf_range(-1, 1)
			if timer >= CHARGE_TIME:
				current_phase = Phase.SUMMON
				timer = 0.0
				_do_summon()
		Phase.SUMMON:
			current_phase = Phase.RECOVERY
			timer = 0.0
		Phase.RECOVERY:
			if timer >= RECOVERY_TIME:
				state_machine.transition_to("MiniBossIdle")

func _do_summon() -> void:
	if player.sprite:
		player.sprite.position = Vector2.ZERO
	
	# Count living minions
	var alive_count: int = 0
	if "spawned_minions" in player:
		for minion in player.spawned_minions:
			if is_instance_valid(minion) and minion.is_alive():
				alive_count += 1
	
	# Don't exceed cap
	var spawn_count: int = mini(2, MAX_MINIONS - alive_count)
	if spawn_count <= 0:
		return
	
	var raccoon_scene = RACCOON_SCENE
	if not raccoon_scene:
		return
	
	for i in range(spawn_count):
		var raccoon = raccoon_scene.instantiate()
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		raccoon.global_position = player.global_position + offset
		player.get_parent().add_child(raccoon)
		
		# Track for cleanup on boss death
		if "spawned_minions" in player:
			player.spawned_minions.append(raccoon)
		
		# Spawn poof effect
		_spawn_poof(raccoon.global_position)
	
	EffectsManager.screen_shake(4.0, 0.15)

func _spawn_poof(pos: Vector2) -> void:
	for j in range(6):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(0.5, 0.45, 0.6, 0.8)
		particle.global_position = pos
		player.get_parent().add_child(particle)
		
		var angle = j * TAU / 6
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * 15
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(particle.queue_free)
