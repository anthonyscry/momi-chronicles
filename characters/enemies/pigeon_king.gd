extends "res://characters/enemies/mini_boss_base.gd"
## Pigeon King - Rooftops mini-boss.
## 120 HP, swoop dive attack + pigeon reinforcement summon.
## Larger pigeon with purple-gold tint. Drops Pigeon Crown on defeat.

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Stats - set BEFORE super._ready()
	patrol_speed = 60.0
	chase_speed = 100.0
	detection_range = 180.0
	attack_range = 40.0
	lose_interest_range = 300.0
	attack_damage = 20
	attack_cooldown = 1.0
	knockback_force = 40.0  # Mini-boss — reduced knockback for heavy feel
	exp_value = 100

	# Mini-boss config
	boss_name = "PIGEON KING"
	is_defeated_key = "pigeon_king"
	loot_equipment_id = "pigeon_crown"
	attack_patterns = ["PigeonKingSwoopDive", "PigeonKingReinforcement"]

	super._ready()

	# Override health AFTER super._ready()
	if health:
		health.max_health = 120
		health.current_health = 120

	# Larger sprite (1.8x scale) with purple-gold tint
	if sprite:
		sprite.scale = Vector2(1.8, 1.8)
		sprite.modulate = Color(0.85, 0.75, 1.1)

# =============================================================================
# DROPS
# =============================================================================

func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 1.0, "min": 5, "max": 10},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 1.0, "min": 2, "max": 3},
	]
