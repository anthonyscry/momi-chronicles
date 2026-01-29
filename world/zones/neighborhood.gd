extends BaseZone
## The main neighborhood zone - Momi's home territory.
## A vibrant area with houses, stores, a park, and patrolling enemies.

const ALPHA_RACCOON_SCENE = preload("res://characters/enemies/alpha_raccoon.tscn")

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
	
	# Build mini-boss trigger (Alpha Raccoon)
	_build_mini_boss_trigger()
	
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


# =============================================================================
# MINI-BOSS TRIGGER (Alpha Raccoon)
# =============================================================================

## Mini-boss spawn tracking (once per zone load)
var _alpha_raccoon_spawned: bool = false

func _build_mini_boss_trigger() -> void:
	# Check if already defeated in save
	if GameManager.mini_bosses_defeated.get("alpha_raccoon", false):
		return  # Don't build trigger — already defeated
	
	var trigger_pos = Vector2(150, 480)  # Park area — open space for fight
	
	# Warning decor — skull-like marking on ground
	var warning = Polygon2D.new()
	warning.name = "MiniBossWarning"
	var points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8.0
		points.append(Vector2(cos(angle), sin(angle)) * 20.0)
	warning.polygon = points
	warning.color = Color(0.6, 0.2, 0.2, 0.3)  # Faint red circle
	warning.position = trigger_pos
	warning.z_index = 0
	add_child(warning)
	
	# Trigger Area2D
	var trigger = Area2D.new()
	trigger.name = "AlphaRaccoonTrigger"
	trigger.collision_layer = 0
	trigger.collision_mask = 2  # Player layer
	trigger.position = trigger_pos
	add_child(trigger)
	
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(80, 60)
	shape.shape = rect
	trigger.add_child(shape)
	
	trigger.body_entered.connect(_on_alpha_raccoon_trigger)

func _on_alpha_raccoon_trigger(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _alpha_raccoon_spawned:
		return
	if GameManager.mini_bosses_defeated.get("alpha_raccoon", false):
		return
	
	_alpha_raccoon_spawned = true
	
	# Spawn Alpha Raccoon
	var boss = ALPHA_RACCOON_SCENE.instantiate()
	boss.global_position = Vector2(150, 460)  # Slightly above trigger center
	add_child(boss)
	
	# Remove trigger and warning after spawn
	var trigger_node = get_node_or_null("AlphaRaccoonTrigger")
	if trigger_node:
		trigger_node.queue_free()
	var warning_node = get_node_or_null("MiniBossWarning")
	if warning_node:
		# Fade warning out
		var tween = create_tween()
		tween.tween_property(warning_node, "modulate:a", 0.0, 0.5)
		tween.tween_callback(warning_node.queue_free)
	
	# Play boss music
	if AudioManager.has_method("play_music"):
		AudioManager.play_music("boss_fight_b")
