extends "res://characters/enemies/mini_boss_base.gd"
class_name AlphaRaccoon
## Alpha Raccoon - Neighborhood mini-boss.
## 120 HP, ground slam AoE + raccoon reinforcement summon.
## Larger, darker raccoon with crown. Drops Raccoon Crown on defeat.

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Stats — set BEFORE super._ready() per enemy extension pattern
	patrol_speed = 35.0
	chase_speed = 70.0
	detection_range = 120.0
	attack_range = 35.0
	lose_interest_range = 250.0  # Large range — don't lose interest easily
	attack_damage = 20
	attack_cooldown = 1.5
	knockback_force = 45.0  # Mini-boss — heavy feel, barely budges
	exp_value = 100
	
	# Mini-boss config
	boss_name = "ALPHA RACCOON"
	is_defeated_key = "alpha_raccoon"
	loot_equipment_id = "raccoon_crown"
	attack_patterns = ["AlphaSlam", "AlphaSummon"]
	
	super._ready()
	
	# Override health AFTER super._ready() (EnemyBase initializes HealthComponent)
	if health:
		health.max_health = 120
		health.current_health = 120
	
	# Bigger raccoon (1.8x scale)
	if sprite:
		sprite.scale = Vector2(1.8, 1.8)
		sprite.color = Color(0.35, 0.3, 0.4)  # Dark purple-grey
	
	_setup_alpha_appearance()

# =============================================================================
# APPEARANCE
# =============================================================================

func _setup_alpha_appearance() -> void:
	if not sprite:
		return
	
	# Crown on top (gold triangle points)
	var crown = Polygon2D.new()
	crown.polygon = PackedVector2Array([
		Vector2(-4, -8),
		Vector2(-2, -12),
		Vector2(0, -9),
		Vector2(2, -12),
		Vector2(4, -8)
	])
	crown.color = Color(1, 0.85, 0.2)  # Gold
	sprite.add_child(crown)
	
	# Scar across face (battle-worn look)
	var scar = Polygon2D.new()
	scar.polygon = PackedVector2Array([
		Vector2(-3, -3),
		Vector2(-2, -4),
		Vector2(3, 1),
		Vector2(2, 2),
	])
	scar.color = Color(0.5, 0.3, 0.3, 0.6)
	sprite.add_child(scar)

# =============================================================================
# DROPS
# =============================================================================

func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 1.0, "min": 5, "max": 10},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 1.0, "min": 2, "max": 3},
	]
