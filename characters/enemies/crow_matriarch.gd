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
	knockback_force = 60.0
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
		sprite.color = Color(0.1, 0.08, 0.15)  # Very dark purple-black
	
	_setup_matriarch_appearance()

# =============================================================================
# APPEARANCE
# =============================================================================

func _setup_matriarch_appearance() -> void:
	if not sprite:
		return
	
	# Feathered crest on top
	var crest = Polygon2D.new()
	crest.polygon = PackedVector2Array([
		Vector2(-2, -8),
		Vector2(0, -14),
		Vector2(2, -8),
		Vector2(1, -11),
		Vector2(-1, -11),
	])
	crest.color = Color(0.2, 0.15, 0.3)  # Dark purple crest
	sprite.add_child(crest)
	
	# Glowing red eyes
	var left_eye = Polygon2D.new()
	left_eye.polygon = PackedVector2Array([
		Vector2(-3, -2), Vector2(-2, -3), Vector2(-1, -2), Vector2(-2, -1)
	])
	left_eye.color = Color(1.0, 0.3, 0.2)  # Glowing red
	sprite.add_child(left_eye)
	
	var right_eye = Polygon2D.new()
	right_eye.polygon = PackedVector2Array([
		Vector2(1, -2), Vector2(2, -3), Vector2(3, -2), Vector2(2, -1)
	])
	right_eye.color = Color(1.0, 0.3, 0.2)
	sprite.add_child(right_eye)

# =============================================================================
# DROPS
# =============================================================================

func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 1.0, "min": 4, "max": 8},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 1.0, "min": 2, "max": 3},
	]
