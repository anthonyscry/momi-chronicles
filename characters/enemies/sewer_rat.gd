extends "res://characters/enemies/enemy_base.gd"
class_name SewerRat
## Sewer Rat enemy — weak individually but spawns in packs.
## Inflicts poison damage-over-time on bite. Forces players to deal with swarms
## quickly or suffer sustained poison.

## Poison damage per tick when bite lands
var poison_damage: int = 3
## Poison duration in seconds
var poison_duration: float = 3.0
## Pack identifier — rats with the same pack_id swarm together
var pack_id: int = 0

func _ready() -> void:
	# Set rat-specific stats
	patrol_speed = 40.0
	chase_speed = 65.0
	detection_range = 50.0
	attack_range = 12.0
	attack_damage = 5
	attack_cooldown = 0.8
	knockback_force = 30.0
	exp_value = 8

	# Call parent ready (sets up state machine, health bar, etc.)
	super._ready()

	# Appearance: dark brown, small rat polygon
	if sprite:
		sprite.color = Color(0.45, 0.35, 0.3)
		sprite.polygon = PackedVector2Array([
			Vector2(-4, -3), Vector2(0, -5), Vector2(4, -3),
			Vector2(5, 2), Vector2(3, 5), Vector2(-3, 5), Vector2(-5, 2)
		])
		sprite.scale = Vector2(0.8, 0.8)


## Rat drops: 60% coins, 10% health, 15% antidote (thematic — they poison you)
func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 0.6, "min": 1, "max": 1},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 0.1, "min": 1, "max": 1},
		{"item_id": "antidote", "chance": 0.15, "min": 1, "max": 1},
	]
