extends "res://characters/enemies/mini_boss_base.gd"
class_name CrowMatriarch
## Crow Matriarch - Backyard mini-boss.
## 80 HP, dive bomb attack + crow swarm summon.
## Larger, darker crow with feathered crown. Drops Crow Feather Coat on defeat.

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Stats - set BEFORE super._ready()
	patrol_speed = 50.0
	chase_speed = 90.0
	detection_range = 130.0
	attack_range = 30.0
	lose_interest_range = 250.0
	attack_damage = 15
	attack_cooldown = 1.2
	knockback_force = 50.0  # Mini-boss — reduced knockback for heavy feel
	exp_value = 80
	
	# Mini-boss config
	boss_name = "CROW MATRIARCH"
	is_defeated_key = "crow_matriarch"
	loot_equipment_id = "crow_feather_coat"
	attack_patterns = ["CrowDiveBomb", "CrowSwarmSummon"]
	
	super._ready()
	
	# Override health AFTER super._ready()
	if health:
		health.max_health = 80
		health.current_health = 80
	
	# Larger crow (1.5x scale)
	if sprite:
		sprite.scale = Vector2(1.5, 1.5)

# =============================================================================
# DROPS
# =============================================================================

func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 1.0, "min": 4, "max": 8},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 1.0, "min": 2, "max": 3},
	]
