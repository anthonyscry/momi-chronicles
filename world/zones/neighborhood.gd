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
	"from_sewers": Vector2(530, 370),       # Returning from sewers via manhole
	"home": Vector2(80, 180),               # Near Momi's house
	"park_center": Vector2(150, 480),       # Park fountain area
	"stores": Vector2(450, 380),            # Near the stores
	"road_west": Vector2(50, 300),          # West end of main road
	"road_east": Vector2(680, 300),         # East end of main road
	"shop": Vector2(380, 350),              # Near Nutkin's shop
}

# =============================================================================
# LIFECYCLE
# =============================================================================

func _setup_zone() -> void:
	zone_id = "neighborhood"
	
	# Build manhole entrance to sewers
	_build_manhole()
	
	# Check if we have a pending spawn from zone transition
	var pending_spawn = GameManager.get_pending_spawn()
	if not pending_spawn.is_empty() and spawn_points.has(pending_spawn):
		spawn_player_at(spawn_points[pending_spawn])
	elif spawn_points.has("default"):
		spawn_player_at(spawn_points["default"])


# =============================================================================
# MANHOLE ENTRANCE (to Sewers)
# =============================================================================

## Build manhole cover visual and ZoneExit for sewers access
func _build_manhole() -> void:
	var manhole_pos = Vector2(530, 370)  # On sidewalk south of road, between stores
	
	# Manhole rim — outer ring (slightly lighter grey)
	var rim = Polygon2D.new()
	rim.name = "ManholeRim"
	var rim_points: PackedVector2Array = []
	var rim_radius: float = 15.0
	for i in range(10):
		var angle = i * TAU / 10.0
		rim_points.append(Vector2(cos(angle), sin(angle)) * rim_radius)
	rim.polygon = rim_points
	rim.color = Color(0.35, 0.35, 0.38)
	rim.position = manhole_pos
	rim.z_index = 1
	add_child(rim)
	
	# Manhole cover — inner circle (dark grey metal)
	var cover = Polygon2D.new()
	cover.name = "ManholeCover"
	var cover_points: PackedVector2Array = []
	var cover_radius: float = 12.0
	for i in range(10):
		var angle = i * TAU / 10.0
		cover_points.append(Vector2(cos(angle), sin(angle)) * cover_radius)
	cover.polygon = cover_points
	cover.color = Color(0.25, 0.25, 0.28)
	cover.position = manhole_pos
	cover.z_index = 2
	add_child(cover)
	
	# Cross-hatch detail on manhole cover
	var detail_h = ColorRect.new()
	detail_h.name = "ManholeDetailH"
	detail_h.position = manhole_pos + Vector2(-8, -1)
	detail_h.size = Vector2(16, 2)
	detail_h.color = Color(0.2, 0.2, 0.22)
	detail_h.z_index = 3
	add_child(detail_h)
	
	var detail_v = ColorRect.new()
	detail_v.name = "ManholeDetailV"
	detail_v.position = manhole_pos + Vector2(-1, -8)
	detail_v.size = Vector2(2, 16)
	detail_v.color = Color(0.2, 0.2, 0.22)
	detail_v.z_index = 3
	add_child(detail_v)
	
	# ZoneExit for manhole — press E to enter sewers
	var exit = preload("res://components/zone_exit/zone_exit.tscn").instantiate()
	exit.name = "ToSewers"
	exit.position = manhole_pos
	exit.exit_id = "to_sewers"
	exit.target_zone = "sewers"
	exit.target_spawn = "from_neighborhood"
	exit.require_interaction = true
	add_child(exit)
