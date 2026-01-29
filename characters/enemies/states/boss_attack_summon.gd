extends State
class_name BossAttackSummon
## Summons minion raccoons

const SUMMON_TIME: float = 1.0
const RECOVERY: float = 0.5

const RACCOON_SCENE: PackedScene = preload("res://characters/enemies/raccoon.tscn")

var timer: float = 0.0
var summoned: bool = false

func enter() -> void:
	timer = 0.0
	summoned = false
	enemy.velocity = Vector2.ZERO
	
	# Summon pose - blue glow
	if enemy.sprite:
		enemy.sprite.modulate = Color(0.8, 0.8, 1.2)

func exit() -> void:
	if enemy.sprite:
		var is_enraged = enemy.get("is_enraged") if enemy.get("is_enraged") != null else false
		enemy.sprite.modulate = Color(1.3, 0.8, 0.8) if is_enraged else Color.WHITE

func physics_update(delta: float) -> void:
	timer += delta
	
	if not summoned and timer >= SUMMON_TIME * 0.5:
		_do_summon()
		summoned = true
	
	if timer >= SUMMON_TIME + RECOVERY:
		state_machine.transition_to("BossIdle")

func _do_summon() -> void:
	# Only summon more in enraged phase
	var is_enraged = enemy.get("is_enraged") if enemy.get("is_enraged") != null else false
	var count = 2 if is_enraged else 1
	
	# Use preloaded raccoon scene (no frame stutter)
	var raccoon_scene = RACCOON_SCENE
	if not raccoon_scene:
		return
	
	for i in range(count):
		var raccoon = raccoon_scene.instantiate()
		
		# Spawn near boss
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		raccoon.global_position = enemy.global_position + offset
		
		# Add to scene
		enemy.get_parent().add_child(raccoon)
		
		# Spawn effect
		_spawn_effect(raccoon.global_position)
	
	EffectsManager.screen_shake(5.0, 0.2)

func _spawn_effect(pos: Vector2) -> void:
	# Poof of smoke
	for j in range(6):
		var particle = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = Color(0.6, 0.5, 0.7, 0.8)
		particle.global_position = pos
		enemy.get_parent().add_child(particle)
		
		var angle = j * TAU / 6
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * 15
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(particle.queue_free)
