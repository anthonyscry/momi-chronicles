extends Node2D
## Test zone for development and debugging.
## Provides a simple bounded area for testing player movement.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Size of the zone in pixels
@export var zone_size: Vector2 = Vector2(640, 360)

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var player: Player = $Player

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Set camera limits to zone boundaries
	if player:
		player.set_camera_limits(Rect2(Vector2.ZERO, zone_size))
	
	# Emit zone entered signal
	Events.zone_entered.emit("test_zone")
