extends "res://characters/enemies/enemy_base.gd"
class_name Crow
## Crow enemy - faster, flies over obstacles, hit-and-run tactics.

# Crow-specific: can fly (ignores some collisions)
var is_flying: bool = true

func _ready() -> void:
	# Crow-specific stats - faster but weaker
	patrol_speed = 35.0
	chase_speed = 75.0
	detection_range = 90.0
	attack_range = 15.0
	lose_interest_range = 140.0
	attack_damage = 10
	attack_cooldown = 0.8
	knockback_force = 110.0  # Light enemy — flies back satisfyingly
	exp_value = 15  # Crows are fast but squishy
	
	# Call parent ready
	super._ready()
	
	# Crow ignores world collision (flies)
	set_collision_mask_value(1, false)


## Crow drops: 90% coins, 15% health, 10% bird seed
func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 0.9, "min": 1, "max": 3},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 0.15, "min": 1, "max": 1},
		{"item_id": "bird_seed", "chance": 0.10, "min": 1, "max": 3},
	]
