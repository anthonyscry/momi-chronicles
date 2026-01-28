extends Area2D
class_name Hurtbox
## Damage-receiving component. Detects when hit by a Hitbox and notifies owner.
## Attach to player body, enemy body, destructible objects, etc.

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when this hurtbox is hit by a hitbox
signal hurt(hitbox: Hitbox)

# =============================================================================
# STATE
# =============================================================================

## Whether this hurtbox is currently invincible (ignores hits)
var is_invincible: bool = false

## Timer for invincibility frames
var _invincibility_timer: float = 0.0

## Duration of invincibility after being hit
var _invincibility_duration: float = 0.0

# =============================================================================
# LIFECYCLE
# =============================================================================

func _process(delta: float) -> void:
	# Handle invincibility timer
	if is_invincible and _invincibility_duration > 0:
		_invincibility_timer -= delta
		if _invincibility_timer <= 0:
			end_invincibility()

# =============================================================================
# PUBLIC METHODS
# =============================================================================

## Called by Hitbox when it enters this hurtbox
func take_hit(hitbox: Hitbox) -> void:
	if is_invincible:
		return
	
	hurt.emit(hitbox)

## Start invincibility for a duration (0 = permanent until end_invincibility called)
func start_invincibility(duration: float = 0.0) -> void:
	is_invincible = true
	_invincibility_duration = duration
	_invincibility_timer = duration

## End invincibility manually
func end_invincibility() -> void:
	is_invincible = false
	_invincibility_timer = 0.0
	_invincibility_duration = 0.0

## Check if currently invincible
func is_currently_invincible() -> bool:
	return is_invincible
