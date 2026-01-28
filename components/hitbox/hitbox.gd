extends Area2D
class_name Hitbox
## Damage-dealing component. Enable during attacks to detect and damage hurtboxes.
## Attach to player attacks, enemy attacks, projectiles, etc.

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when this hitbox successfully hits a hurtbox
signal hit_landed(hurtbox: Hurtbox)

# =============================================================================
# CONFIGURATION
# =============================================================================

## Amount of damage this hitbox deals
@export var damage: int = 10

## Knockback force applied to hit targets
@export var knockback_force: float = 100.0

# =============================================================================
# STATE
# =============================================================================

## Targets already hit this attack (prevents multi-hit)
var hit_targets: Array[Node] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect to area detection
	area_entered.connect(_on_area_entered)
	
	# Start disabled
	disable()

# =============================================================================
# PUBLIC METHODS
# =============================================================================

## Enable the hitbox (call at start of attack)
func enable() -> void:
	monitoring = true
	monitorable = true
	# Show collision shape in editor/debug
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

## Disable the hitbox (call at end of attack)
func disable() -> void:
	# Use set_deferred to avoid physics errors during signal handling
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)

## Reset hit tracking (call for new attack)
func reset() -> void:
	hit_targets.clear()

## Get knockback direction from hitbox owner to target
func get_knockback_direction(target_position: Vector2) -> Vector2:
	return (target_position - global_position).normalized()

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_area_entered(area: Area2D) -> void:
	# Only interact with hurtboxes
	if not area is Hurtbox:
		return
	
	var hurtbox: Hurtbox = area
	
	# Skip if already hit this target
	if hurtbox.owner in hit_targets:
		return
	
	# Skip if hurtbox is invincible
	if hurtbox.is_invincible:
		return
	
	# Record hit and notify hurtbox
	hit_targets.append(hurtbox.owner)
	hurtbox.take_hit(self)
	hit_landed.emit(hurtbox)
