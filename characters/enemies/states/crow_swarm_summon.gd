extends State
class_name CrowSwarmSummon
## Crow Matriarch swarm summon - calls crows in circular formation.
## Phase: CHARGE (0.5s) -> SUMMON (instant) -> RECOVERY (0.7s)

const CHARGE_TIME: float = 0.5
const RECOVERY_TIME: float = 0.7
const CROW_COUNT_MIN: int = 3
const CROW_COUNT_MAX: int = 4
const MAX_MINIONS: int = 4
const CROW_SCENE = preload("res://characters/enemies/crow.tscn")

var timer: float = 0.0
var summoned: bool = false
enum Phase { CHARGE, SUMMON, RECOVERY }
var current_phase: Phase = Phase.CHARGE

func enter() -> void:
	timer = 0.0
	summoned = false
	current_phase = Phase.CHARGE
	player.velocity = Vector2.ZERO
	# Purple glow during charge
	if player.sprite:
		player.sprite.modulate = Color(0.9, 0.7, 1.3)

func exit() -> void:
	if player.sprite:
		player.sprite.modulate = Color.WHITE

func physics_update(delta: float) -> void:
	timer += delta
	match current_phase:
		Phase.CHARGE:
			if player.sprite:
				player.sprite.position.y = randf_range(-1, 1)
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
	
	var spawn_count = mini(randi_range(CROW_COUNT_MIN, CROW_COUNT_MAX), MAX_MINIONS - alive_count)
	if spawn_count <= 0:
		return
	
	var crow_scene = CROW_SCENE
	if not crow_scene:
		return
	
	for i in range(spawn_count):
		var crow = crow_scene.instantiate()
		# Spawn in circle around matriarch
		var angle = i * TAU / spawn_count
		crow.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * 25
		player.get_parent().add_child(crow)
		
		# Track for cleanup on boss death
		if "spawned_minions" in player:
			player.spawned_minions.append(crow)
		
		# Feather poof effect per crow
		_spawn_feather_poof(crow.global_position)
	
	EffectsManager.screen_shake(3.0, 0.15)

func _spawn_feather_poof(pos: Vector2) -> void:
	for j in range(4):
		var feather = ColorRect.new()
		feather.size = Vector2(3, 2)
		feather.color = Color(0.15, 0.12, 0.2, 0.8)  # Dark feather color
		feather.global_position = pos
		player.get_parent().add_child(feather)
		
		var angle = j * TAU / 4
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * 12
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(feather, "global_position", end_pos, 0.4)
		tween.tween_property(feather, "modulate:a", 0.0, 0.4)
		tween.chain().tween_callback(feather.queue_free)
