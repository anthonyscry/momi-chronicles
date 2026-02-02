extends "res://characters/enemies/enemy_base.gd"
class_name Pigeon

## Pigeon enemy - flock-based aerial attacker that swoops from rooftops.

# ==============================================================================
# STATS & CONSTANTS
# ==============================================================================

# Group/Flock settings
const GROUP_SIZE_MIN: int = 3
const GROUP_SIZE_MAX: int = 6
const SWOOP_DELAY_BETWEEN_PIGEONS: float = 0.3

# HP & Combat
const MAX_HEALTH: int = 30
const SWOOP_DAMAGE: float = 15.0

# Movement
const FLY_SPEED: float = 120.0
const FLEE_SPEED: float = 180.0

# Detection & Range
const DETECTION_RANGE: float = 256.0
const ATTACK_RANGE: float = 180.0  # Aerial swoop range

# Flee behavior
const FLEE_HP_THRESHOLD: float = 0.3  # 30% HP triggers flee
const PERCH_HEIGHT: float = 48.0

# ==============================================================================
# FLOCK STATE
# ==============================================================================

var flock_id: int = 0
var flock_position: int = 0  # 0 = lead pigeon
var is_lead_pigeon: bool = false
var can_swoop: bool = true
var is_fleeing: bool = false
var perch_position: Vector2 = Vector2.ZERO

# ==============================================================================
# LIFECYCLE
# ==============================================================================

func _ready() -> void:
	# Set health component
	health = HealthComponent.new(MAX_HEALTH, MAX_HEALTH)
	
	# Setup hitbox for swoop attacks
	hitbox = Hitbox.new()
	hitbox.damage = SWOOP_DAMAGE
	hitbox.knockback_force = 50.0
	add_child(hitbox)
	
	# Setup hurtbox
	hurtbox = Hurtbox.new()
	hurtbox.layer = 5  # Enemy hurtbox layer
	hurtbox.mask = 64  # Player hitbox mask
	add_child(hurtbox)
	
	# Connect health signals
	health.health_changed.connect(_on_health_changed)
	
	# Call parent ready
	super._ready()
	
	# Set pigeon-specific sprite animation
	if sprite:
		sprite.play("idle")

func _on_health_changed(current_health: int, max_health: int) -> void:
	# Check flee condition when damaged
	var health_percent = float(current_health) / float(max_health)
	if health_percent <= FLEE_HP_THRESHOLD and not is_fleeing:
		is_fleeing = true
		Events.pigeon_fled.emit(flock_id, self)

# ==============================================================================
# FLOCK COORDINATION
# ==============================================================================

## Register this pigeon with the flock system
func register_with_flock(new_flock_id: int, position: int) -> void:
	flock_id = new_flock_id
	flock_position = position
	is_lead_pigeon = (position == 0)
	
	# Add to flock group for easy lookup
	add_to_group("pigeon_flock_" + str(flock_id))
	
	if is_lead_pigeon:
		add_to_group("pigeon_flock_lead_" + str(flock_id))

## Get all members of this flock
func get_flock_members() -> Array:
	return get_tree().get_nodes_in_group("pigeon_flock_" + str(flock_id))

## Get the lead pigeon of this flock
func get_flock_lead() -> Node:
	var flock = get_flock_members()
	for member in flock:
		if member.is_lead_pigeon:
			return member
	return null

# ==============================================================================
# ATTACK TARGET
# ==============================================================================

func get_attack_target() -> Node:
	return get_tree().get_first_node_in_group("player")

# ==============================================================================
# ANIMATION MAPPING (for base class)
# ==============================================================================

func get_attack_state_name() -> String:
	return "SwoopAttack"

func _update_animation() -> void:
	if not sprite or not is_alive():
		return
	
	var new_animation: String = "idle"
	if state_machine and state_machine.current_state_name:
		var state_name = state_machine.current_state_name
		if state_name == "FlockIdle":
			new_animation = "idle"
		elif state_name == "FlockChase":
			new_animation = "fly"
		elif state_name == "SwoopAttack":
			new_animation = "swoop"
		elif state_name == "Hurt":
			new_animation = "hurt"
		elif state_name == "Death":
			new_animation = "death"
	
	if sprite.animation != new_animation:
		sprite.play(new_animation)
	
	# Handle facing for flying
	if state_machine and state_machine.current_state_name in ["FlockChase", "SwoopAttack"]:
		if velocity.x < 0:
			sprite.flip_h = true
		elif velocity.x > 0:
			sprite.flip_h = false

# ==============================================================================
# DROPS
# ==============================================================================

func _init_default_drops() -> void:
	# Pigeons drop: 70% coins, 20% health, 10% breadcrumbs
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 0.7, "min": 1, "max": 2},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 0.2, "min": 1, "max": 1},
		{"item_id": "breadcrumbs", "chance": 0.10, "min": 1, "max": 3},
	]
