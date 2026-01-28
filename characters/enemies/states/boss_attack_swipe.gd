extends State
class_name BossAttackSwipe
## Wide melee swipe attack for boss

const WINDUP: float = 0.4
const SWIPE: float = 0.3
const RECOVERY: float = 0.5

var timer: float = 0.0
enum Phase { WINDUP, SWIPE, RECOVERY }
var current_phase: Phase = Phase.WINDUP

func enter() -> void:
	timer = 0.0
	current_phase = Phase.WINDUP
	enemy.velocity = Vector2.ZERO
	
	# Windup visual
	if enemy.sprite:
		enemy.sprite.modulate = Color(1.2, 1.0, 0.8)

func exit() -> void:
	if enemy.hitbox:
		enemy.hitbox.disable()
	if enemy.sprite:
		var is_enraged = enemy.get("is_enraged") if enemy.get("is_enraged") != null else false
		enemy.sprite.modulate = Color(1.3, 0.8, 0.8) if is_enraged else Color.WHITE

func physics_update(delta: float) -> void:
	timer += delta
	
	match current_phase:
		Phase.WINDUP:
			if timer >= WINDUP:
				current_phase = Phase.SWIPE
				timer = 0.0
				_do_swipe()
		Phase.SWIPE:
			if timer >= SWIPE:
				current_phase = Phase.RECOVERY
				timer = 0.0
				if enemy.hitbox:
					enemy.hitbox.disable()
		Phase.RECOVERY:
			if timer >= RECOVERY:
				state_machine.transition_to("BossIdle")

func _do_swipe() -> void:
	# Enable larger hitbox
	if enemy.hitbox:
		enemy.hitbox.damage = enemy.attack_damage
		var shape = enemy.hitbox.get_node_or_null("CollisionShape2D")
		if shape:
			shape.scale = Vector2(2.0, 1.5)  # Wide swipe
			var dir = enemy.get_direction_to_target() if enemy.target else Vector2.DOWN
			shape.position = dir * 25
		enemy.hitbox.enable()
	
	# Visual swing
	if enemy.sprite:
		var facing_left = enemy.get("facing_left") if enemy.get("facing_left") != null else false
		enemy.sprite.rotation = -0.3 if not facing_left else 0.3
		var tween = create_tween()
		tween.tween_property(enemy.sprite, "rotation", 0.3 if not facing_left else -0.3, SWIPE)
		tween.tween_property(enemy.sprite, "rotation", 0.0, 0.1)
	
	EffectsManager.screen_shake(4.0, 0.1)
