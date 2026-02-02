extends BaseZone
## The Rooftops zone — nighttime rooftop platforms connected by walkways and bridges.
## Fourth explorable zone. Moonlit atmosphere, chimney obstacles, tight platforms.
## Home to pigeon flocks, garden gnome sentries, roof rats, and the Pigeon King mini-boss.

# =============================================================================
# CONSTANTS
# =============================================================================

const ZONE_EXIT_SCENE = preload("res://components/zone_exit/zone_exit.tscn")
const GNOME_SCENE = preload("res://characters/enemies/gnome.tscn")
const ROOF_RAT_SCENE = preload("res://characters/enemies/roof_rat.tscn")
const PIGEON_KING_SCENE = preload("res://characters/enemies/pigeon_king.tscn")

## Color palette — moonlit rooftop at night
const COLOR_SKY := Color(0.04, 0.03, 0.08)
const COLOR_PLATFORM := Color(0.28, 0.22, 0.18)
const COLOR_PLATFORM_LIGHT := Color(0.32, 0.26, 0.22)
const COLOR_WALKWAY := Color(0.25, 0.20, 0.16)
const COLOR_WALL := Color(0.2, 0.16, 0.14)
const COLOR_CHIMNEY := Color(0.35, 0.25, 0.2)
const COLOR_CHIMNEY_CAP := Color(0.4, 0.3, 0.25)
const COLOR_CHIMNEY_DARK := Color(0.15, 0.1, 0.08)
const COLOR_ANTENNA := Color(0.3, 0.3, 0.35)
const COLOR_MOON := Color(0.95, 0.92, 0.75)
const COLOR_STAR := Color(0.85, 0.85, 0.95)
const COLOR_RAILING := Color(0.3, 0.28, 0.25)
const COLOR_VENT := Color(0.25, 0.25, 0.28)
const COLOR_DEBRIS := Color(0.35, 0.3, 0.25)

# =============================================================================
# SPAWN POINTS
# =============================================================================

## Named spawn points in this zone
var spawn_points: Dictionary = {
	"default": Vector2(60, 460),
	"from_neighborhood": Vector2(60, 460),
	"boss_area": Vector2(980, 340),
}

# Wave encounter state
var _wave_central_spawned: bool = false
var _wave_ridge_spawned: bool = false
var _wave_boss_spawned: bool = false
var _enemies_container: Node2D = null

# =============================================================================
# LAYOUT DATA
# =============================================================================

## Main rooftop platforms (each is a Rect2: position.x, position.y, size.x, size.y)
var platforms: Array[Rect2] = [
	# Platform 1: Entry Platform (left side) — safe starting area
	Rect2(20, 400, 200, 120),
	# Platform 2: Central Rooftop — main encounter area, wide and open
	Rect2(280, 300, 300, 180),
	# Platform 3: Sentry Ridge — elevated narrow platform, gnome territory
	Rect2(640, 200, 250, 140),
	# Platform 4: Boss Overlook — wide platform for Pigeon King fight
	Rect2(940, 280, 220, 160),
]

## Connecting walkways between platforms
var walkways: Array[Rect2] = [
	# Entry -> Central walkway
	Rect2(220, 440, 60, 40),
	# Central -> Sentry Ridge bridge
	Rect2(580, 350, 60, 40),
	# Sentry Ridge -> Boss Overlook walkway
	Rect2(890, 310, 50, 40),
]

# =============================================================================
# CHIMNEY DATA
# =============================================================================

## Chimney positions and sizes {pos: Vector2, size: Vector2, platform_idx: int}
var chimney_configs: Array[Dictionary] = [
	# Entry Platform chimneys
	{"pos": Vector2(60, 420), "size": Vector2(16, 28)},
	{"pos": Vector2(170, 430), "size": Vector2(14, 24)},
	# Central Rooftop chimneys
	{"pos": Vector2(320, 320), "size": Vector2(16, 28)},
	{"pos": Vector2(440, 340), "size": Vector2(18, 30)},
	{"pos": Vector2(530, 380), "size": Vector2(14, 24)},
	# Sentry Ridge chimneys
	{"pos": Vector2(680, 220), "size": Vector2(16, 28)},
	{"pos": Vector2(830, 240), "size": Vector2(14, 26)},
	# Boss Overlook chimney
	{"pos": Vector2(1100, 310), "size": Vector2(18, 30)},
]

# =============================================================================
# LIFECYCLE
# =============================================================================

func _setup_zone() -> void:
	zone_id = "rooftops"

	# Build the entire rooftop zone programmatically
	_build_background()
	_build_moonlight()
	_build_platforms()
	_build_walkways()
	_build_walls()
	_build_chimneys()
	_build_decorations()
	_build_stars()
	_build_mini_boss_trigger()
	_build_wave_triggers()
	_build_zone_exits()
	_build_boundaries()

	# Set up player light for night visibility
	_setup_player_light()

	# Handle spawn point
	var pending_spawn = GameManager.get_pending_spawn()
	if not pending_spawn.is_empty() and spawn_points.has(pending_spawn):
		spawn_player_at(spawn_points[pending_spawn])
	elif spawn_points.has("default"):
		spawn_player_at(spawn_points["default"])


## Override base zone grass spawning — no grass on rooftops, spawn debris instead
func _spawn_grass() -> void:
	var debris_count = randi_range(8, 14)
	var all_rects: Array[Rect2] = []
	for plat in platforms:
		all_rects.append(plat)

	for i in range(debris_count):
		var target_rect: Rect2 = all_rects[randi() % all_rects.size()]
		var debris = ColorRect.new()
		debris.name = "Debris_%d" % i
		debris.size = Vector2(randf_range(3, 7), randf_range(2, 4))
		debris.color = Color(
			randf_range(0.3, 0.4),
			randf_range(0.25, 0.35),
			randf_range(0.2, 0.3),
			randf_range(0.4, 0.7)
		)
		var x = randf_range(target_rect.position.x + 8, target_rect.position.x + target_rect.size.x - 8)
		var y = randf_range(target_rect.position.y + 4, target_rect.position.y + target_rect.size.y - 4)
		debris.position = Vector2(x, y)
		add_child(debris)

	DebugLogger.log_zone("Spawned %d rooftop debris pieces (no grass)" % debris_count)

# =============================================================================
# ATMOSPHERE — NIGHT SKY & MOONLIGHT
# =============================================================================

func _build_background() -> void:
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.position = Vector2.ZERO
	bg.size = zone_size
	bg.color = COLOR_SKY
	add_child(bg)
	move_child(bg, 0)


func _build_moonlight() -> void:
	# CanvasModulate for moonlit night (brighter than sewers)
	var canvas_mod = CanvasModulate.new()
	canvas_mod.name = "MoonlightTint"
	canvas_mod.color = Color(0.18, 0.16, 0.28)
	add_child(canvas_mod)

	# Moon visual — pale yellow circle in upper-right
	var moon_container = Node2D.new()
	moon_container.name = "Moon"
	moon_container.z_index = -1
	add_child(moon_container)

	var moon = Polygon2D.new()
	moon.name = "MoonDisc"
	var moon_points: PackedVector2Array = []
	var moon_radius: float = 24.0
	for i in range(16):
		var angle = i * TAU / 16.0
		moon_points.append(Vector2(cos(angle), sin(angle)) * moon_radius)
	moon.polygon = moon_points
	moon.color = COLOR_MOON
	moon.position = Vector2(1050, 60)
	moon_container.add_child(moon)

	# Moon glow — larger, softer circle behind
	var moon_glow = Polygon2D.new()
	moon_glow.name = "MoonGlow"
	var glow_points: PackedVector2Array = []
	var glow_radius: float = 40.0
	for i in range(16):
		var angle = i * TAU / 16.0
		glow_points.append(Vector2(cos(angle), sin(angle)) * glow_radius)
	moon_glow.polygon = glow_points
	moon_glow.color = Color(0.95, 0.92, 0.75, 0.15)
	moon_glow.position = Vector2(1050, 60)
	moon_container.add_child(moon_glow)


func _build_stars() -> void:
	var star_container = Node2D.new()
	star_container.name = "Stars"
	star_container.z_index = -1
	add_child(star_container)

	var star_count = randi_range(10, 16)
	for i in range(star_count):
		var star = ColorRect.new()
		star.name = "Star_%d" % i
		star.size = Vector2(2, 2) if randf() > 0.3 else Vector2(3, 3)
		star.color = Color(
			randf_range(0.75, 0.95),
			randf_range(0.75, 0.95),
			randf_range(0.85, 1.0),
			randf_range(0.4, 0.8)
		)
		# Place in sky area (above platforms, within zone)
		star.position = Vector2(
			randf_range(20, zone_size.x - 20),
			randf_range(10, 180)
		)
		star_container.add_child(star)

		# Subtle twinkle animation
		var tween = create_tween().set_loops()
		tween.tween_interval(randf_range(0.5, 3.0))
		tween.tween_property(star, "modulate:a", randf_range(0.3, 0.5), randf_range(0.8, 1.5))\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(star, "modulate:a", 1.0, randf_range(0.8, 1.5))\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _setup_player_light() -> void:
	if not player:
		return

	# Create a radial gradient texture for the light
	var gradient_tex = GradientTexture2D.new()
	gradient_tex.width = 256
	gradient_tex.height = 256
	gradient_tex.fill = GradientTexture2D.FILL_RADIAL
	gradient_tex.fill_from = Vector2(0.5, 0.5)
	gradient_tex.fill_to = Vector2(0.5, 0.0)

	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient_tex.gradient = gradient

	var light = PointLight2D.new()
	light.name = "PlayerLight"
	light.texture = gradient_tex
	light.texture_scale = 4.0  # Larger than sewers — moonlit, not pitch dark
	light.energy = 1.0
	light.color = Color(0.75, 0.78, 0.95)  # Cool blue-white moonlight

	player.add_child(light)
	DebugLogger.log_zone("Player moonlight attached")

# =============================================================================
# PLATFORM & WALKWAY BUILDERS
# =============================================================================

func _build_platforms() -> void:
	var platforms_container = Node2D.new()
	platforms_container.name = "Platforms"
	add_child(platforms_container)

	for i in range(platforms.size()):
		var plat: Rect2 = platforms[i]
		var floor_rect = ColorRect.new()
		floor_rect.name = "Platform_%d" % i
		floor_rect.position = plat.position
		floor_rect.size = plat.size
		# Alternate colors slightly for visual variety
		floor_rect.color = COLOR_PLATFORM if i % 2 == 0 else COLOR_PLATFORM_LIGHT
		platforms_container.add_child(floor_rect)

		# Shingle lines (horizontal lines across platform for roof texture)
		var shingle_spacing: float = 12.0
		var num_shingles = int(plat.size.y / shingle_spacing)
		for s in range(num_shingles):
			var shingle = ColorRect.new()
			shingle.name = "Shingle_%d_%d" % [i, s]
			shingle.position = plat.position + Vector2(0, s * shingle_spacing)
			shingle.size = Vector2(plat.size.x, 1)
			shingle.color = Color(0.2, 0.16, 0.12, 0.3)
			platforms_container.add_child(shingle)


func _build_walkways() -> void:
	var walkways_container = Node2D.new()
	walkways_container.name = "Walkways"
	add_child(walkways_container)

	for i in range(walkways.size()):
		var walk: Rect2 = walkways[i]
		var walk_rect = ColorRect.new()
		walk_rect.name = "Walkway_%d" % i
		walk_rect.position = walk.position
		walk_rect.size = walk.size
		walk_rect.color = COLOR_WALKWAY
		walkways_container.add_child(walk_rect)

		# Railing lines on walkway edges
		var railing_top = ColorRect.new()
		railing_top.name = "Railing_%d_top" % i
		railing_top.position = walk.position + Vector2(0, -2)
		railing_top.size = Vector2(walk.size.x, 2)
		railing_top.color = COLOR_RAILING
		walkways_container.add_child(railing_top)

		var railing_bottom = ColorRect.new()
		railing_bottom.name = "Railing_%d_bottom" % i
		railing_bottom.position = walk.position + Vector2(0, walk.size.y)
		railing_bottom.size = Vector2(walk.size.x, 2)
		railing_bottom.color = COLOR_RAILING
		walkways_container.add_child(railing_bottom)

# =============================================================================
# WALL BUILDERS
# =============================================================================

func _build_walls() -> void:
	var walls_container = Node2D.new()
	walls_container.name = "Walls"
	add_child(walls_container)

	var wall_thickness: float = 10.0

	# Walls around each platform
	for i in range(platforms.size()):
		var plat: Rect2 = platforms[i]
		# Top wall
		_add_wall(walls_container, "PlatWall_%d_top" % i,
			Vector2(plat.position.x, plat.position.y - wall_thickness),
			Vector2(plat.size.x, wall_thickness))
		# Bottom wall
		_add_wall(walls_container, "PlatWall_%d_bottom" % i,
			Vector2(plat.position.x, plat.position.y + plat.size.y),
			Vector2(plat.size.x, wall_thickness))
		# Left wall
		_add_wall(walls_container, "PlatWall_%d_left" % i,
			Vector2(plat.position.x - wall_thickness, plat.position.y),
			Vector2(wall_thickness, plat.size.y))
		# Right wall
		_add_wall(walls_container, "PlatWall_%d_right" % i,
			Vector2(plat.position.x + plat.size.x, plat.position.y),
			Vector2(wall_thickness, plat.size.y))

	# Walls around walkways (sides only — ends connect to platforms)
	for i in range(walkways.size()):
		var walk: Rect2 = walkways[i]
		# Top side wall
		_add_wall(walls_container, "WalkWall_%d_top" % i,
			Vector2(walk.position.x, walk.position.y - wall_thickness),
			Vector2(walk.size.x, wall_thickness))
		# Bottom side wall
		_add_wall(walls_container, "WalkWall_%d_bottom" % i,
			Vector2(walk.position.x, walk.position.y + walk.size.y),
			Vector2(walk.size.x, wall_thickness))


func _add_wall(parent: Node, wall_name: String, pos: Vector2, wall_size: Vector2) -> void:
	var wall = StaticBody2D.new()
	wall.name = wall_name
	wall.position = pos + wall_size / 2  # Center the body
	wall.collision_layer = 1
	wall.collision_mask = 0

	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = wall_size
	collision.shape = shape
	wall.add_child(collision)

	# Visual — wall edge (slightly visible roof edge)
	var visual = ColorRect.new()
	visual.size = wall_size
	visual.position = -wall_size / 2
	visual.color = COLOR_WALL
	wall.add_child(visual)

	parent.add_child(wall)

# =============================================================================
# CHIMNEY BUILDERS
# =============================================================================

func _build_chimneys() -> void:
	var chimney_container = Node2D.new()
	chimney_container.name = "Chimneys"
	add_child(chimney_container)

	for i in range(chimney_configs.size()):
		var config: Dictionary = chimney_configs[i]
		var pos: Vector2 = config.pos
		var chimney_size: Vector2 = config.size

		# Chimney body (StaticBody2D obstacle)
		var chimney = StaticBody2D.new()
		chimney.name = "Chimney_%d" % i
		chimney.position = pos + chimney_size / 2
		chimney.collision_layer = 1
		chimney.collision_mask = 0

		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = chimney_size
		collision.shape = shape
		chimney.add_child(collision)

		# Chimney visual
		var body_visual = ColorRect.new()
		body_visual.size = chimney_size
		body_visual.position = -chimney_size / 2
		body_visual.color = COLOR_CHIMNEY
		chimney.add_child(body_visual)

		# Chimney cap (wider than body)
		var cap = ColorRect.new()
		cap.name = "Cap"
		cap.size = Vector2(chimney_size.x + 4, 4)
		cap.position = Vector2(-chimney_size.x / 2 - 2, -chimney_size.y / 2 - 4)
		cap.color = COLOR_CHIMNEY_CAP
		chimney.add_child(cap)

		# Dark opening at top
		var opening = ColorRect.new()
		opening.name = "Opening"
		opening.size = Vector2(chimney_size.x - 4, 3)
		opening.position = Vector2(-chimney_size.x / 2 + 2, -chimney_size.y / 2 - 1)
		opening.color = COLOR_CHIMNEY_DARK
		chimney.add_child(opening)

		chimney_container.add_child(chimney)

# =============================================================================
# DECORATIONS
# =============================================================================

func _build_decorations() -> void:
	var decor_container = Node2D.new()
	decor_container.name = "Decorations"
	add_child(decor_container)

	_build_antennas(decor_container)
	_build_vents(decor_container)
	_build_clotheslines(decor_container)
	_build_edge_details(decor_container)


func _build_antennas(parent: Node) -> void:
	## TV antennas on rooftop edges
	var antenna_positions: Array[Dictionary] = [
		{"pos": Vector2(100, 395), "height": 30},
		{"pos": Vector2(450, 295), "height": 35},
		{"pos": Vector2(750, 195), "height": 28},
		{"pos": Vector2(1050, 275), "height": 32},
	]

	for i in range(antenna_positions.size()):
		var config = antenna_positions[i]
		var pos: Vector2 = config.pos
		var h: int = config.height

		# Vertical pole
		var pole = ColorRect.new()
		pole.name = "Antenna_%d_pole" % i
		pole.position = pos + Vector2(-1, -h)
		pole.size = Vector2(2, h)
		pole.color = COLOR_ANTENNA
		parent.add_child(pole)

		# Cross arm
		var arm = ColorRect.new()
		arm.name = "Antenna_%d_arm" % i
		arm.position = pos + Vector2(-8, -h + 6)
		arm.size = Vector2(16, 2)
		arm.color = COLOR_ANTENNA
		parent.add_child(arm)

		# Second cross arm (shorter, lower)
		var arm2 = ColorRect.new()
		arm2.name = "Antenna_%d_arm2" % i
		arm2.position = pos + Vector2(-5, -h + 14)
		arm2.size = Vector2(10, 2)
		arm2.color = COLOR_ANTENNA
		parent.add_child(arm2)


func _build_vents(parent: Node) -> void:
	## Rooftop ventilation units
	var vent_positions: Array[Vector2] = [
		Vector2(150, 470),
		Vector2(370, 420),
		Vector2(710, 300),
		Vector2(1000, 380),
	]

	for i in range(vent_positions.size()):
		var pos = vent_positions[i]
		var vent = ColorRect.new()
		vent.name = "Vent_%d" % i
		vent.position = pos
		vent.size = Vector2(12, 8)
		vent.color = COLOR_VENT
		parent.add_child(vent)

		# Vent slats
		for s in range(3):
			var slat = ColorRect.new()
			slat.name = "VentSlat_%d_%d" % [i, s]
			slat.position = pos + Vector2(1, 1 + s * 3)
			slat.size = Vector2(10, 1)
			slat.color = COLOR_VENT.darkened(0.3)
			parent.add_child(slat)


func _build_clotheslines(parent: Node) -> void:
	## Clotheslines between chimneys (Central Rooftop)
	var line_start = Vector2(325, 328)
	var line_end = Vector2(435, 348)

	var line = ColorRect.new()
	line.name = "Clothesline"
	line.position = line_start
	line.size = Vector2(line_end.x - line_start.x, 1)
	line.color = Color(0.5, 0.5, 0.5, 0.5)
	parent.add_child(line)

	# Hanging items (small colored rectangles drooping from line)
	var items_count = 4
	for i in range(items_count):
		var t = float(i + 1) / float(items_count + 1)
		var x_pos = lerp(line_start.x, line_end.x, t)
		var item = ColorRect.new()
		item.name = "ClothItem_%d" % i
		item.position = Vector2(x_pos, line_start.y + 2)
		item.size = Vector2(6, randf_range(6, 10))
		# Random cloth colors
		var colors = [Color(0.8, 0.3, 0.3, 0.7), Color(0.3, 0.5, 0.8, 0.7),
					  Color(0.9, 0.9, 0.4, 0.7), Color(0.9, 0.5, 0.7, 0.7)]
		item.color = colors[i % colors.size()]
		parent.add_child(item)


func _build_edge_details(parent: Node) -> void:
	## Edge trim / lip on platforms (darker strip at edges)
	for i in range(platforms.size()):
		var plat: Rect2 = platforms[i]

		# Bottom edge lip (visible 3/4 perspective edge)
		var edge = ColorRect.new()
		edge.name = "PlatEdge_%d" % i
		edge.position = Vector2(plat.position.x, plat.position.y + plat.size.y - 4)
		edge.size = Vector2(plat.size.x, 4)
		edge.color = Color(0.18, 0.14, 0.1, 0.6)
		parent.add_child(edge)

# =============================================================================
# WAVE-BASED ENCOUNTER SPAWNING
# =============================================================================

func _build_wave_triggers() -> void:
	# Create shared enemies container
	_enemies_container = Node2D.new()
	_enemies_container.name = "Enemies"
	add_child(_enemies_container)

	# Entry Platform — spawn immediately (warm-up area)
	_spawn_wave_entry()

	# Wave triggers at walkway entrances — enemies spawn when player crosses
	_create_wave_trigger("WaveTrigger_Central", walkways[0].position + walkways[0].size / 2, Vector2(60, 60), _on_wave_central_trigger)
	_create_wave_trigger("WaveTrigger_Ridge", walkways[1].position + walkways[1].size / 2, Vector2(60, 60), _on_wave_ridge_trigger)
	_create_wave_trigger("WaveTrigger_Boss", walkways[2].position + walkways[2].size / 2, Vector2(50, 50), _on_wave_boss_trigger)

	DebugLogger.log_zone("Rooftops wave triggers placed (3 triggers + entry enemies)")


func _create_wave_trigger(trigger_name: String, pos: Vector2, trigger_size: Vector2, callback: Callable) -> void:
	var trigger = Area2D.new()
	trigger.name = trigger_name
	trigger.collision_layer = 0
	trigger.collision_mask = 2  # Player layer
	trigger.position = pos
	add_child(trigger)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = trigger_size
	shape.shape = rect
	trigger.add_child(shape)

	trigger.body_entered.connect(callback)


# --- Entry Platform (spawns immediately — warm-up) ---

func _spawn_wave_entry() -> void:
	# 1 pigeon flock of 3
	var entry_flock = Events.create_pigeon_flock(Vector2(100, 420), 3)
	for pigeon in entry_flock:
		_enemies_container.add_child(pigeon)

	# 1 roof rat near Entry chimney
	var entry_rat = ROOF_RAT_SCENE.instantiate()
	entry_rat.name = "RoofRat_entry"
	entry_rat.position = Vector2(160, 430)
	_enemies_container.add_child(entry_rat)

	_show_encounter_announcement("ENTRY PLATFORM")
	DebugLogger.log_zone("Wave ENTRY spawned: 1 flock(3), 1 rat")


# --- Central Rooftop (triggers on walkway 1 crossing) ---

func _on_wave_central_trigger(body: Node2D) -> void:
	if not body.is_in_group("player") or _wave_central_spawned:
		return
	_wave_central_spawned = true

	# 1 pigeon flock of 5
	var central_flock = Events.create_pigeon_flock(Vector2(400, 340), 5)
	for pigeon in central_flock:
		_enemies_container.add_child(pigeon)

	# 2 garden gnomes — crossfire coverage
	var gnome_central_1 = GNOME_SCENE.instantiate()
	gnome_central_1.name = "Gnome_central_1"
	gnome_central_1.position = Vector2(350, 310)
	_enemies_container.add_child(gnome_central_1)

	var gnome_central_2 = GNOME_SCENE.instantiate()
	gnome_central_2.name = "Gnome_central_2"
	gnome_central_2.position = Vector2(500, 380)
	_enemies_container.add_child(gnome_central_2)

	# 2 roof rats near Central chimneys
	var rat_central_1 = ROOF_RAT_SCENE.instantiate()
	rat_central_1.name = "RoofRat_central_1"
	rat_central_1.position = Vector2(320, 360)
	_enemies_container.add_child(rat_central_1)

	var rat_central_2 = ROOF_RAT_SCENE.instantiate()
	rat_central_2.name = "RoofRat_central_2"
	rat_central_2.position = Vector2(480, 330)
	_enemies_container.add_child(rat_central_2)

	_show_encounter_announcement("CENTRAL ROOFTOP")
	DebugLogger.log_zone("Wave CENTRAL spawned: 1 flock(5), 2 gnomes, 2 rats")

	# Remove trigger
	var trigger_node = get_node_or_null("WaveTrigger_Central")
	if trigger_node:
		trigger_node.queue_free()


# --- Sentry Ridge (triggers on walkway 2 crossing) ---

func _on_wave_ridge_trigger(body: Node2D) -> void:
	if not body.is_in_group("player") or _wave_ridge_spawned:
		return
	_wave_ridge_spawned = true

	# 2 garden gnomes at elevated positions — crossfire
	var gnome_ridge_1 = GNOME_SCENE.instantiate()
	gnome_ridge_1.name = "Gnome_ridge_1"
	gnome_ridge_1.position = Vector2(700, 230)
	_enemies_container.add_child(gnome_ridge_1)

	var gnome_ridge_2 = GNOME_SCENE.instantiate()
	gnome_ridge_2.name = "Gnome_ridge_2"
	gnome_ridge_2.position = Vector2(820, 260)
	_enemies_container.add_child(gnome_ridge_2)

	# 1 pigeon flock of 4 patrolling the ridge
	var ridge_flock = Events.create_pigeon_flock(Vector2(750, 280), 4)
	for pigeon in ridge_flock:
		_enemies_container.add_child(pigeon)

	# 1 roof rat near bridge to Boss Overlook
	var rat_ridge = ROOF_RAT_SCENE.instantiate()
	rat_ridge.name = "RoofRat_ridge"
	rat_ridge.position = Vector2(870, 240)
	_enemies_container.add_child(rat_ridge)

	_show_encounter_announcement("SENTRY RIDGE")
	DebugLogger.log_zone("Wave RIDGE spawned: 2 gnomes, 1 flock(4), 1 rat")

	# Remove trigger
	var trigger_node = get_node_or_null("WaveTrigger_Ridge")
	if trigger_node:
		trigger_node.queue_free()


# --- Boss Overlook (triggers on walkway 3 crossing) ---

func _on_wave_boss_trigger(body: Node2D) -> void:
	if not body.is_in_group("player") or _wave_boss_spawned:
		return
	_wave_boss_spawned = true

	# 1 roof rat — light guard before mini-boss
	var rat_boss = ROOF_RAT_SCENE.instantiate()
	rat_boss.name = "RoofRat_boss_guard"
	rat_boss.position = Vector2(980, 310)
	_enemies_container.add_child(rat_boss)

	_show_encounter_announcement("BOSS OVERLOOK")
	DebugLogger.log_zone("Wave BOSS spawned: 1 rat guard")

	# Remove trigger
	var trigger_node = get_node_or_null("WaveTrigger_Boss")
	if trigger_node:
		trigger_node.queue_free()


# =============================================================================
# ENCOUNTER ANNOUNCEMENTS
# =============================================================================

func _show_encounter_announcement(text: String) -> void:
	var label = Label.new()
	label.name = "Announcement"
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.5))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(zone_size.x / 2 - 80, 20)
	label.size = Vector2(160, 30)
	label.modulate.a = 0.0
	label.z_index = 100
	add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free)

# =============================================================================
# MINI-BOSS TRIGGER (Pigeon King)
# =============================================================================

var _pigeon_king_spawned: bool = false

func _build_mini_boss_trigger() -> void:
	# Check if already defeated
	if GameManager.mini_bosses_defeated.get("pigeon_king", false):
		return

	# Trigger position — center of Boss Overlook
	var trigger_pos = Vector2(1040, 350)

	# Warning decor — faint gold octagon
	var warning = Polygon2D.new()
	warning.name = "PigeonKingWarning"
	var points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8.0
		points.append(Vector2(cos(angle), sin(angle)) * 20.0)
	warning.polygon = points
	warning.color = Color(0.6, 0.5, 0.2, 0.3)  # Faint gold circle
	warning.position = trigger_pos
	warning.z_index = 1
	add_child(warning)

	# Trigger Area2D
	var trigger = Area2D.new()
	trigger.name = "PigeonKingTrigger"
	trigger.collision_layer = 0
	trigger.collision_mask = 2  # Player layer
	trigger.position = trigger_pos
	add_child(trigger)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(80, 60)
	shape.shape = rect
	trigger.add_child(shape)

	trigger.body_entered.connect(_on_pigeon_king_trigger)


func _on_pigeon_king_trigger(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _pigeon_king_spawned:
		return
	if GameManager.mini_bosses_defeated.get("pigeon_king", false):
		return

	_pigeon_king_spawned = true

	# Spawn Pigeon King
	var boss = PIGEON_KING_SCENE.instantiate()
	boss.global_position = Vector2(1040, 320)  # Slightly above trigger
	add_child(boss)

	# Remove trigger and fade warning
	var trigger_node = get_node_or_null("PigeonKingTrigger")
	if trigger_node:
		trigger_node.queue_free()
	var warning_node = get_node_or_null("PigeonKingWarning")
	if warning_node:
		var tween = create_tween()
		tween.tween_property(warning_node, "modulate:a", 0.0, 0.5)
		tween.tween_callback(warning_node.queue_free)

	# Play boss music
	if AudioManager.has_method("play_music"):
		AudioManager.play_music("boss_fight_b")

# =============================================================================
# ZONE EXITS
# =============================================================================

func _build_zone_exits() -> void:
	var exits_container: Node2D
	if has_node("ZoneExits"):
		exits_container = $ZoneExits
	else:
		exits_container = Node2D.new()
		exits_container.name = "ZoneExits"
		add_child(exits_container)

	# Exit back to neighborhood (at ladder on Entry Platform, left side)
	var to_neighborhood = ZONE_EXIT_SCENE.instantiate()
	to_neighborhood.name = "ToNeighborhood"
	to_neighborhood.position = Vector2(30, 460)
	to_neighborhood.exit_id = "to_neighborhood"
	to_neighborhood.target_zone = "neighborhood"
	to_neighborhood.target_spawn = "from_rooftops"
	to_neighborhood.require_interaction = true  # Press E to climb down
	exits_container.add_child(to_neighborhood)

	# Ladder visual at the exit
	_build_ladder_visual(Vector2(30, 460))

	# Label above ladder
	var label = Label.new()
	label.name = "LadderLabel"
	label.position = Vector2(14, 430)
	label.text = "LADDER"
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8, 0.6))
	add_child(label)


func _build_ladder_visual(pos: Vector2) -> void:
	var ladder_container = Node2D.new()
	ladder_container.name = "LadderVisual"
	ladder_container.z_index = 2
	add_child(ladder_container)

	var ladder_height: float = 30.0
	var ladder_width: float = 10.0
	var rung_count: int = 5

	# Left rail
	var left_rail = ColorRect.new()
	left_rail.name = "LeftRail"
	left_rail.position = pos + Vector2(-ladder_width / 2, -ladder_height / 2)
	left_rail.size = Vector2(2, ladder_height)
	left_rail.color = Color(0.45, 0.35, 0.2)
	ladder_container.add_child(left_rail)

	# Right rail
	var right_rail = ColorRect.new()
	right_rail.name = "RightRail"
	right_rail.position = pos + Vector2(ladder_width / 2 - 2, -ladder_height / 2)
	right_rail.size = Vector2(2, ladder_height)
	right_rail.color = Color(0.45, 0.35, 0.2)
	ladder_container.add_child(right_rail)

	# Rungs
	var rung_spacing = ladder_height / float(rung_count + 1)
	for i in range(rung_count):
		var rung = ColorRect.new()
		rung.name = "Rung_%d" % i
		rung.position = pos + Vector2(-ladder_width / 2 + 2, -ladder_height / 2 + (i + 1) * rung_spacing - 1)
		rung.size = Vector2(ladder_width - 4, 2)
		rung.color = Color(0.45, 0.35, 0.2)
		ladder_container.add_child(rung)

# =============================================================================
# BOUNDARIES
# =============================================================================

func _build_boundaries() -> void:
	var boundaries = StaticBody2D.new()
	boundaries.name = "Boundaries"
	boundaries.collision_layer = 1
	boundaries.collision_mask = 0
	add_child(boundaries)

	# Top wall
	var top = CollisionShape2D.new()
	top.name = "Top"
	var top_shape = RectangleShape2D.new()
	top_shape.size = Vector2(zone_size.x, 16)
	top.shape = top_shape
	top.position = Vector2(zone_size.x / 2, -8)
	boundaries.add_child(top)

	# Bottom wall
	var bottom = CollisionShape2D.new()
	bottom.name = "Bottom"
	var bottom_shape = RectangleShape2D.new()
	bottom_shape.size = Vector2(zone_size.x, 16)
	bottom.shape = bottom_shape
	bottom.position = Vector2(zone_size.x / 2, zone_size.y + 8)
	boundaries.add_child(bottom)

	# Left wall
	var left = CollisionShape2D.new()
	left.name = "Left"
	var left_shape = RectangleShape2D.new()
	left_shape.size = Vector2(16, zone_size.y)
	left.shape = left_shape
	left.position = Vector2(-8, zone_size.y / 2)
	boundaries.add_child(left)

	# Right wall
	var right = CollisionShape2D.new()
	right.name = "Right"
	var right_shape = RectangleShape2D.new()
	right_shape.size = Vector2(16, zone_size.y)
	right.shape = right_shape
	right.position = Vector2(zone_size.x + 8, zone_size.y / 2)
	boundaries.add_child(right)
