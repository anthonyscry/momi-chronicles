extends BaseZone
## The main neighborhood zone - Momi's home territory.
## A vibrant area with houses, stores, a park, and patrolling enemies.

# =============================================================================
# SPAWN POINTS
# =============================================================================

## Named spawn points in this zone
var spawn_points: Dictionary = {
	"default": Vector2(100, 500),           # Start in park area
	"from_backyard": Vector2(720, 550),     # Coming from backyard
	"home": Vector2(80, 180),               # Near Momi's house
	"park_center": Vector2(150, 480),       # Park fountain area
	"stores": Vector2(450, 380),            # Near the stores
	"road_west": Vector2(50, 300),          # West end of main road
	"road_east": Vector2(680, 300),         # East end of main road
}

# =============================================================================
# LIFECYCLE
# =============================================================================

func _setup_zone() -> void:
	zone_id = "neighborhood"
	
	# Check if we have a pending spawn from zone transition
	var pending_spawn = GameManager.get_pending_spawn()
	if not pending_spawn.is_empty() and spawn_points.has(pending_spawn):
		spawn_player_at(spawn_points[pending_spawn])
	elif spawn_points.has("default"):
		spawn_player_at(spawn_points["default"])
