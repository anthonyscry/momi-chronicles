extends "res://characters/enemies/mini_boss_base.gd"
class_name RatKing
## Rat King - Sewers mini-boss.
## 150 HP, poison AoE cloud + split into rats at 50% HP.
## Massive sewer rat with crown of smaller rats. Drops Rat King's Collar on defeat.

const SEWER_RAT_SCENE = preload("res://characters/enemies/sewer_rat.tscn")

## Split mechanic — guard with boolean to prevent infinite spawning
var has_split: bool = false
const SPLIT_THRESHOLD: float = 0.5  # 50% HP
const SPLIT_RAT_COUNT: int = 4

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Stats — set BEFORE super._ready()
	patrol_speed = 30.0
	chase_speed = 55.0
	detection_range = 100.0
	attack_range = 25.0
	lose_interest_range = 200.0
	attack_damage = 18
	attack_cooldown = 2.0
	knockback_force = 120.0
	exp_value = 120
	
	# Mini-boss config
	boss_name = "RAT KING"
	is_defeated_key = "rat_king"
	loot_equipment_id = "rat_king_collar"
	attack_patterns = ["RatKingPoisonCloud", "MiniBossIdle"]  # Poison cloud → brief idle → poison → ...
	
	super._ready()
	
	# Override health AFTER super._ready()
	if health:
		health.max_health = 150
		health.current_health = 150
	
	# Largest mini-boss (2.0x scale)
	if sprite:
		sprite.scale = Vector2(2.0, 2.0)
		sprite.color = Color(0.3, 0.28, 0.2)  # Dirty brown
	
	_setup_rat_king_appearance()

# =============================================================================
# APPEARANCE
# =============================================================================

func _setup_rat_king_appearance() -> void:
	if not sprite:
		return
	
	# Crown of smaller rat shapes on top
	for i in range(3):
		var rat_nub = Polygon2D.new()
		var x_offset = (i - 1) * 4.0
		rat_nub.polygon = PackedVector2Array([
			Vector2(x_offset - 1, -8),
			Vector2(x_offset, -11),
			Vector2(x_offset + 1, -8),
		])
		rat_nub.color = Color(0.4, 0.35, 0.25)  # Lighter brown
		sprite.add_child(rat_nub)
	
	# Glowing green eyes (poison theme)
	var left_eye = Polygon2D.new()
	left_eye.polygon = PackedVector2Array([
		Vector2(-3, -2), Vector2(-2, -3), Vector2(-1, -2), Vector2(-2, -1)
	])
	left_eye.color = Color(0.5, 1.0, 0.3)  # Toxic green
	sprite.add_child(left_eye)
	
	var right_eye = Polygon2D.new()
	right_eye.polygon = PackedVector2Array([
		Vector2(1, -2), Vector2(2, -3), Vector2(3, -2), Vector2(2, -1)
	])
	right_eye.color = Color(0.5, 1.0, 0.3)
	sprite.add_child(right_eye)
	
	# Tail (long, curved line)
	var tail = Polygon2D.new()
	tail.polygon = PackedVector2Array([
		Vector2(0, 7), Vector2(1, 7),
		Vector2(4, 10), Vector2(5, 10),
		Vector2(7, 8), Vector2(6, 8),
		Vector2(3, 9), Vector2(2, 9),
	])
	tail.color = Color(0.35, 0.3, 0.22)
	sprite.add_child(tail)

# =============================================================================
# SPLIT MECHANIC (50% HP)
# =============================================================================

## Override _on_hurt to check for split threshold
func _on_hurt(attacking_hitbox: Hitbox) -> void:
	super._on_hurt(attacking_hitbox)
	
	# Check split threshold — CRITICAL: guard with has_split to prevent infinite rats
	if not has_split and health and health.get_health_percent() <= SPLIT_THRESHOLD:
		_split_into_rats()

func _split_into_rats() -> void:
	has_split = true
	
	# Screen shake for dramatic effect
	EffectsManager.screen_shake(10.0, 0.4)
	
	# Brief stun visual — flash green
	if sprite:
		sprite.modulate = Color(0.5, 1.5, 0.5)
		var flash_tween = create_tween()
		flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
	
	# Spawn sewer rats in circle around Rat King
	for i in range(SPLIT_RAT_COUNT):
		var rat = SEWER_RAT_SCENE.instantiate()
		var angle = i * TAU / SPLIT_RAT_COUNT
		rat.global_position = global_position + Vector2(cos(angle), sin(angle)) * 20
		get_parent().add_child(rat)
		
		# Track for cleanup on boss death
		spawned_minions.append(rat)
		
		# Spawn poof
		_spawn_split_poof(rat.global_position)
	
	# Shrink sprite slightly and speed up (wounded, desperate)
	if sprite:
		var shrink_tween = create_tween()
		shrink_tween.tween_property(sprite, "scale", Vector2(1.7, 1.7), 0.3)
	chase_speed = 70.0  # Speed up when split

func _spawn_split_poof(pos: Vector2) -> void:
	for j in range(4):
		var particle = ColorRect.new()
		particle.size = Vector2(3, 3)
		particle.color = Color(0.4, 0.6, 0.2, 0.8)  # Green poison poof
		particle.global_position = pos
		get_parent().add_child(particle)
		
		var angle = j * TAU / 4
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * 12
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(particle.queue_free)

# =============================================================================
# DROPS
# =============================================================================

func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 1.0, "min": 8, "max": 15},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 1.0, "min": 3, "max": 5},
	]
