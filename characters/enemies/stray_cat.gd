extends "res://characters/enemies/enemy_base.gd"
class_name StrayCat
## Stray Cat enemy - stealthy ambusher that hides, pounces for high damage, then retreats.
## Forces players to stay alert and watch for nearly-invisible threats.

## Cat-specific stealth properties
var stealth_alpha: float = 0.15  ## Transparency when stealthed
var is_stealthed: bool = true  ## Starts in stealth
var pounce_speed: float = 200.0  ## Lunge velocity during pounce

func _ready() -> void:
	# Set cat-specific stats
	patrol_speed = 20.0  # Slow stalk
	chase_speed = 90.0  # Fast pounce
	detection_range = 60.0
	attack_range = 30.0  # Pounce distance
	attack_damage = 20  # High burst
	attack_cooldown = 2.5  # Slow between attacks
	knockback_force = 100.0  # Strong pounce impact
	exp_value = 30
	
	# Call parent ready
	super._ready()
	
	# Cat appearance: orange/ginger color
	if sprite:
		sprite.color = Color(0.85, 0.55, 0.2)
		# Cat-shaped polygon with triangle ears
		sprite.polygon = PackedVector2Array([
			Vector2(-6, -5), Vector2(-4, -9), Vector2(-2, -5),
			Vector2(2, -5), Vector2(4, -9), Vector2(6, -5),
			Vector2(7, 0), Vector2(5, 7), Vector2(-5, 7), Vector2(-7, 0)
		])


## Cat attacks via pounce, not generic Attack state
func get_attack_state_name() -> String:
	return "CatPounce"


## Cat drops: 70% chance for 1-2 coins, 20% chance for health
func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 0.7, "min": 1, "max": 2},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 0.2, "min": 1, "max": 1},
	]
