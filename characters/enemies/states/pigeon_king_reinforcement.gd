extends State
## Pigeon King reinforcement call — charge up and summon a pigeon flock.
## Phase: CHARGE (0.8s) -> SUMMON (instant) -> RECOVERY (0.6s)
## Uses Events.create_pigeon_flock() and tracks via spawned_minions for cleanup.

const CHARGE_TIME: float = 0.8
const RECOVERY_TIME: float = 0.6
const PIGEON_COUNT: int = 3
const MAX_REINFORCEMENTS: int = 6

var timer: float = 0.0
var summoned: bool = false
enum Phase { CHARGE, SUMMON, RECOVERY }
var current_phase: Phase = Phase.CHARGE

func enter() -> void:
	timer = 0.0
	summoned = false
	current_phase = Phase.CHARGE
	player.velocity = Vector2.ZERO
	# Gold glow during charge
	if player.sprite:
		player.sprite.modulate = Color(1.0, 0.9, 0.5)


func exit() -> void:
	if player.sprite:
		player.sprite.modulate = Color(0.85, 0.75, 1.1)  # Restore Pigeon King tint


func physics_update(delta: float) -> void:
	timer += delta
	match current_phase:
		Phase.CHARGE:
			# Shake during charge
			if player.sprite:
				player.sprite.position.y = randf_range(-1, 1)
			EffectsManager.screen_shake(2.0, delta)
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
	# Reset sprite shake
	if player.sprite:
		player.sprite.position = Vector2.ZERO

	# Count existing living minions
	var alive_count: int = 0
	if "spawned_minions" in player:
		for minion in player.spawned_minions:
			if is_instance_valid(minion) and minion.has_method("is_alive") and minion.is_alive():
				alive_count += 1

	var spawn_count = mini(PIGEON_COUNT, MAX_REINFORCEMENTS - alive_count)
	if spawn_count <= 0:
		return

	# Spawn a flock above the boss
	var spawn_pos = player.global_position + Vector2(0, -40)
	var flock = Events.create_pigeon_flock(spawn_pos, spawn_count)

	for pigeon in flock:
		# Add to the scene
		player.get_parent().add_child(pigeon)

		# Track for cleanup on boss death
		if "spawned_minions" in player:
			player.spawned_minions.append(pigeon)

		# Feather poof effect per pigeon
		_spawn_feather_poof(pigeon.global_position)

	EffectsManager.screen_shake(3.0, 0.15)
	DebugLogger.log_zone("Pigeon King summoned %d reinforcements (total alive: %d)" % [spawn_count, alive_count + spawn_count])


func _spawn_feather_poof(pos: Vector2) -> void:
	for j in range(4):
		var feather = ColorRect.new()
		feather.size = Vector2(3, 2)
		feather.color = Color(0.6, 0.55, 0.7, 0.8)  # Light purple feather
		feather.global_position = pos
		player.get_parent().add_child(feather)

		var angle = j * TAU / 4
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * 14

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(feather, "global_position", end_pos, 0.4)
		tween.tween_property(feather, "modulate:a", 0.0, 0.4)
		tween.chain().tween_callback(feather.queue_free)
