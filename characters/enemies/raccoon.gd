extends "res://characters/enemies/enemy_base.gd"
class_name Raccoon
## Raccoon enemy - basic melee attacker that patrols and chases player.

func _ready() -> void:
	# Set raccoon-specific stats
	patrol_speed = 25.0
	chase_speed = 55.0
	detection_range = 70.0
	attack_range = 18.0
	attack_damage = 15
	attack_cooldown = 1.2
	exp_value = 25  # Raccoons are tougher, worth more EXP
	
	# Call parent ready
	super._ready()


## Raccoon drops: 80% coins, 25% health, 10% acorn
func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 0.8, "min": 1, "max": 2},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 0.25, "min": 1, "max": 1},
		{"item_id": "acorn", "chance": 0.10, "min": 1, "max": 2},
	]
