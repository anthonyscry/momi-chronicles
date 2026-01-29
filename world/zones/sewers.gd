extends BaseZone
## The sewers dungeon zone - dark, linear corridor system with enemies, hazards, and a boss door.
## First proper dungeon with darkness (CanvasModulate), PointLight2D on player,
## winding corridors, side rooms, water channels, and escalating difficulty.

# =============================================================================
# CONSTANTS
# =============================================================================

const SEWER_RAT_SCENE = preload("res://characters/enemies/sewer_rat.tscn")
const SHADOW_CREATURE_SCENE = preload("res://characters/enemies/shadow_creature.tscn")
const ZONE_EXIT_SCENE = preload("res://components/zone_exit/zone_exit.tscn")
const TOXIC_PUDDLE_SCRIPT = preload("res://components/hazards/toxic_puddle.gd")

## Color palette
const COLOR_BACKGROUND := Color(0.06, 0.04, 0.1)
const COLOR_FLOOR := Color(0.18, 0.16, 0.22)
const COLOR_WALL := Color(0.1, 0.08, 0.14)
const COLOR_WATER_FLOWING := Color(0.12, 0.18, 0.35, 0.7)
const COLOR_WATER_STAGNANT := Color(0.1, 0.22, 0.18, 0.6)
const COLOR_PIPE := Color(0.22, 0.2, 0.18)
const COLOR_GRATE := Color(0.15, 0.14, 0.12)
const COLOR_MOSS := Color(0.08, 0.18, 0.06, 0.6)
const COLOR_BONE := Color(0.65, 0.6, 0.5)
const COLOR_SCRATCH := Color(0.25, 0.15, 0.12, 0.5)
const COLOR_BOSS_DOOR := Color(0.3, 0.15, 0.1)
const COLOR_BOSS_DOOR_FRAME := Color(0.2, 0.1, 0.08)

# =============================================================================
# SPAWN POINTS
# =============================================================================

## Named spawn points in this zone
var spawn_points: Dictionary = {
	"default": Vector2(60, 324),
	"from_neighborhood": Vector2(60, 324),
}

# =============================================================================
# LAYOUT DATA
# =============================================================================

## Main corridor segments (each is a Rect2: position.x, position.y, size.x, size.y)
## The corridor winds from left to right in an S-curve pattern
var corridor_segments: Array[Rect2] = [
	# Entrance corridor — horizontal, left side
	Rect2(20, 300, 200, 56),
	# Downward bend
	Rect2(168, 356, 56, 120),
	# Lower horizontal stretch
	Rect2(224, 420, 250, 56),
	# Upward bend
	Rect2(420, 200, 56, 220),
	# Upper horizontal stretch
	Rect2(476, 200, 250, 56),
	# Downward bend to boss area
	Rect2(672, 256, 56, 120),
	# Boss approach corridor
	Rect2(728, 320, 200, 56),
	# Boss door alcove (wider)
	Rect2(928, 280, 120, 130),
]

## Side rooms branching off the main corridor
## Each: {rect: Rect2, type: String, connect_rect: Rect2}
var side_rooms: Array[Dictionary] = [
	# Room 1: Treasure alcove (off entrance corridor, upward)
	{
		"rect": Rect2(100, 210, 80, 80),
		"type": "treasure",
		"connector": Rect2(120, 290, 48, 16),
	},
	# Room 2: Ambush room (off lower horizontal, downward)
	{
		"rect": Rect2(280, 490, 90, 80),
		"type": "ambush",
		"connector": Rect2(310, 476, 48, 16),
	},
	# Room 3: Hazard room (off upper horizontal, upward)
	{
		"rect": Rect2(540, 110, 80, 80),
		"type": "hazard",
		"connector": Rect2(560, 190, 48, 16),
	},
	# Room 4: Deep ambush room (off boss approach, downward)
	{
		"rect": Rect2(790, 390, 90, 80),
		"type": "deep_ambush",
		"connector": Rect2(820, 376, 48, 16),
	},
]

# =============================================================================
# LIFECYCLE
# =============================================================================

func _setup_zone() -> void:
	zone_id = "sewers"
	
	# Build the entire dungeon programmatically
	_build_background()
	_build_darkness()
	_build_corridors()
	_build_walls()
	_build_water()
	_build_decorations()
	_build_hazards()
	_build_enemies()
	_build_boss_door()
	_build_zone_exits()
	_build_boundaries()
	
	# Set up player light for darkness visibility
	_setup_player_light()
	
	# Handle spawn point
	var pending_spawn = GameManager.get_pending_spawn()
	if not pending_spawn.is_empty() and spawn_points.has(pending_spawn):
		spawn_player_at(spawn_points[pending_spawn])
	elif spawn_points.has("default"):
		spawn_player_at(spawn_points["default"])


## Override base zone grass spawning — no grass in sewers, spawn moss instead
func _spawn_grass() -> void:
	var moss_count = randi_range(12, 20)
	var all_rects: Array[Rect2] = []
	for seg in corridor_segments:
		all_rects.append(seg)
	for room in side_rooms:
		all_rects.append(room.rect)
	
	for i in range(moss_count):
		var target_rect: Rect2 = all_rects[randi() % all_rects.size()]
		var moss = ColorRect.new()
		moss.name = "Moss_%d" % i
		moss.size = Vector2(randf_range(4, 10), randf_range(3, 6))
		moss.color = Color(
			randf_range(0.06, 0.12),
			randf_range(0.15, 0.25),
			randf_range(0.04, 0.10),
			randf_range(0.4, 0.7)
		)
		# Place along edges of corridors
		var x = randf_range(target_rect.position.x, target_rect.position.x + target_rect.size.x)
		var y: float
		if randf() > 0.5:
			y = target_rect.position.y + randf_range(0, 4)
		else:
			y = target_rect.position.y + target_rect.size.y - randf_range(2, 6)
		moss.position = Vector2(x, y)
		add_child(moss)
	
	print("[Sewers] Spawned %d moss patches (no grass)" % moss_count)

# =============================================================================
# DARKNESS SYSTEM
# =============================================================================

func _build_darkness() -> void:
	var canvas_mod = CanvasModulate.new()
	canvas_mod.name = "Darkness"
	canvas_mod.color = Color(0.08, 0.06, 0.12)
	add_child(canvas_mod)


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
	light.texture_scale = 3.5
	light.energy = 1.2
	light.color = Color(0.7, 0.75, 0.9)  # Cool blue-white
	
	player.add_child(light)
	print("[Sewers] Player light attached")

# =============================================================================
# DUNGEON LAYOUT BUILDERS
# =============================================================================

func _build_background() -> void:
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.position = Vector2.ZERO
	bg.size = zone_size
	bg.color = COLOR_BACKGROUND
	add_child(bg)
	move_child(bg, 0)


func _build_corridors() -> void:
	var corridors_container = Node2D.new()
	corridors_container.name = "Corridors"
	add_child(corridors_container)
	
	# Main corridor floor segments
	for i in range(corridor_segments.size()):
		var seg: Rect2 = corridor_segments[i]
		var floor_rect = ColorRect.new()
		floor_rect.name = "Corridor_%d" % i
		floor_rect.position = seg.position
		floor_rect.size = seg.size
		floor_rect.color = COLOR_FLOOR
		corridors_container.add_child(floor_rect)
	
	# Side room floors + connectors
	for i in range(side_rooms.size()):
		var room: Dictionary = side_rooms[i]
		var room_floor = ColorRect.new()
		room_floor.name = "Room_%d_%s" % [i, room.type]
		room_floor.position = room.rect.position
		room_floor.size = room.rect.size
		room_floor.color = COLOR_FLOOR.lightened(0.03)  # Slightly different shade
		corridors_container.add_child(room_floor)
		
		# Connector passage
		var connector = ColorRect.new()
		connector.name = "Connector_%d" % i
		connector.position = room.connector.position
		connector.size = room.connector.size
		connector.color = COLOR_FLOOR
		corridors_container.add_child(connector)


func _build_walls() -> void:
	var walls_container = Node2D.new()
	walls_container.name = "Walls"
	add_child(walls_container)
	
	# Build walls as StaticBody2D along corridor edges
	# Each corridor segment gets top and bottom (or left and right) walls
	var wall_thickness: float = 12.0
	
	for i in range(corridor_segments.size()):
		var seg: Rect2 = corridor_segments[i]
		var is_horizontal: bool = seg.size.x > seg.size.y
		
		if is_horizontal:
			# Top wall
			_add_wall(walls_container, "Wall_%d_top" % i,
				Vector2(seg.position.x, seg.position.y - wall_thickness),
				Vector2(seg.size.x, wall_thickness))
			# Bottom wall
			_add_wall(walls_container, "Wall_%d_bottom" % i,
				Vector2(seg.position.x, seg.position.y + seg.size.y),
				Vector2(seg.size.x, wall_thickness))
		else:
			# Left wall
			_add_wall(walls_container, "Wall_%d_left" % i,
				Vector2(seg.position.x - wall_thickness, seg.position.y),
				Vector2(wall_thickness, seg.size.y))
			# Right wall
			_add_wall(walls_container, "Wall_%d_right" % i,
				Vector2(seg.position.x + seg.size.x, seg.position.y),
				Vector2(wall_thickness, seg.size.y))
	
	# Side room walls (surround each room except at connector opening)
	for i in range(side_rooms.size()):
		var room: Dictionary = side_rooms[i]
		var r: Rect2 = room.rect
		var c: Rect2 = room.connector
		
		# Top wall
		_add_wall(walls_container, "RoomWall_%d_top" % i,
			Vector2(r.position.x, r.position.y - wall_thickness),
			Vector2(r.size.x, wall_thickness))
		# Bottom wall
		_add_wall(walls_container, "RoomWall_%d_bottom" % i,
			Vector2(r.position.x, r.position.y + r.size.y),
			Vector2(r.size.x, wall_thickness))
		# Left wall
		_add_wall(walls_container, "RoomWall_%d_left" % i,
			Vector2(r.position.x - wall_thickness, r.position.y),
			Vector2(wall_thickness, r.size.y))
		# Right wall
		_add_wall(walls_container, "RoomWall_%d_right" % i,
			Vector2(r.position.x + r.size.x, r.position.y),
			Vector2(wall_thickness, r.size.y))


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
	
	# Visual
	var visual = ColorRect.new()
	visual.size = wall_size
	visual.position = -wall_size / 2
	visual.color = COLOR_WALL
	wall.add_child(visual)
	
	parent.add_child(wall)


func _build_water() -> void:
	var water_container = Node2D.new()
	water_container.name = "Water"
	add_child(water_container)
	
	# Flowing water channels along main corridor edges
	var channel_width: float = 6.0
	
	for i in range(corridor_segments.size()):
		var seg: Rect2 = corridor_segments[i]
		# Skip the boss alcove (last segment) — no water channels there
		if i == corridor_segments.size() - 1:
			continue
		
		var is_horizontal: bool = seg.size.x > seg.size.y
		
		if is_horizontal:
			# Top channel
			var top_channel = ColorRect.new()
			top_channel.name = "WaterChannel_%d_top" % i
			top_channel.position = seg.position + Vector2(0, 2)
			top_channel.size = Vector2(seg.size.x, channel_width)
			top_channel.color = COLOR_WATER_FLOWING
			water_container.add_child(top_channel)
			
			# Bottom channel
			var bottom_channel = ColorRect.new()
			bottom_channel.name = "WaterChannel_%d_bottom" % i
			bottom_channel.position = seg.position + Vector2(0, seg.size.y - channel_width - 2)
			bottom_channel.size = Vector2(seg.size.x, channel_width)
			bottom_channel.color = COLOR_WATER_FLOWING
			water_container.add_child(bottom_channel)
		else:
			# Left channel
			var left_channel = ColorRect.new()
			left_channel.name = "WaterChannel_%d_left" % i
			left_channel.position = seg.position + Vector2(2, 0)
			left_channel.size = Vector2(channel_width, seg.size.y)
			left_channel.color = COLOR_WATER_FLOWING
			water_container.add_child(left_channel)
			
			# Right channel
			var right_channel = ColorRect.new()
			right_channel.name = "WaterChannel_%d_right" % i
			right_channel.position = seg.position + Vector2(seg.size.x - channel_width - 2, 0)
			right_channel.size = Vector2(channel_width, seg.size.y)
			right_channel.color = COLOR_WATER_FLOWING
			water_container.add_child(right_channel)
	
	# Stagnant water pools in side rooms
	for i in range(side_rooms.size()):
		var room: Dictionary = side_rooms[i]
		var r: Rect2 = room.rect
		
		var pool = ColorRect.new()
		pool.name = "StagnantPool_%d" % i
		# Center of room, slightly offset, variable size
		var pool_size = Vector2(randf_range(20, 35), randf_range(14, 24))
		pool.size = pool_size
		pool.position = r.position + r.size / 2 - pool_size / 2 + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		pool.color = COLOR_WATER_STAGNANT
		water_container.add_child(pool)
	
	# Animate flowing water with a subtle shimmer
	_animate_water_flow(water_container)


func _animate_water_flow(water_container: Node2D) -> void:
	# Subtle alpha pulsing on flowing water channels
	for child in water_container.get_children():
		if child.name.begins_with("WaterChannel"):
			var tween = create_tween().set_loops()
			var delay = randf_range(0.0, 1.5)
			tween.tween_interval(delay)
			tween.tween_property(child, "modulate:a", 0.7, 1.2)\
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(child, "modulate:a", 1.0, 1.2)\
				.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _build_decorations() -> void:
	var decor_container = Node2D.new()
	decor_container.name = "Decorations"
	add_child(decor_container)
	
	# --- Pipes along walls ---
	_build_pipes(decor_container)
	
	# --- Grates on the floor ---
	_build_grates(decor_container)
	
	# --- Drip points ---
	_build_drip_points(decor_container)
	
	# --- Pre-boss area warning decorations ---
	_build_boss_warnings(decor_container)


func _build_pipes(parent: Node) -> void:
	# Horizontal pipes along upper walls of horizontal corridors
	var pipe_positions: Array[Dictionary] = [
		{"pos": Vector2(40, 294), "size": Vector2(140, 4)},
		{"pos": Vector2(240, 414), "size": Vector2(180, 4)},
		{"pos": Vector2(490, 194), "size": Vector2(200, 4)},
		{"pos": Vector2(740, 314), "size": Vector2(160, 4)},
	]
	# Vertical pipes along vertical corridor walls
	var v_pipe_positions: Array[Dictionary] = [
		{"pos": Vector2(162, 360), "size": Vector2(4, 100)},
		{"pos": Vector2(414, 220), "size": Vector2(4, 180)},
		{"pos": Vector2(666, 260), "size": Vector2(4, 100)},
	]
	
	var idx = 0
	for p in pipe_positions:
		var pipe = ColorRect.new()
		pipe.name = "PipeH_%d" % idx
		pipe.position = p.pos
		pipe.size = p.size
		pipe.color = COLOR_PIPE
		parent.add_child(pipe)
		idx += 1
	
	idx = 0
	for p in v_pipe_positions:
		var pipe = ColorRect.new()
		pipe.name = "PipeV_%d" % idx
		pipe.position = p.pos
		pipe.size = p.size
		pipe.color = COLOR_PIPE
		parent.add_child(pipe)
		idx += 1


func _build_grates(parent: Node) -> void:
	var grate_positions: Array[Vector2] = [
		Vector2(80, 318),
		Vector2(300, 438),
		Vector2(550, 218),
		Vector2(800, 338),
		Vector2(960, 330),
	]
	
	for i in range(grate_positions.size()):
		var grate = ColorRect.new()
		grate.name = "Grate_%d" % i
		grate.position = grate_positions[i]
		grate.size = Vector2(16, 12)
		grate.color = COLOR_GRATE
		parent.add_child(grate)
		
		# Grate bars (horizontal lines across)
		for bar in range(3):
			var bar_rect = ColorRect.new()
			bar_rect.name = "GrateBar_%d_%d" % [i, bar]
			bar_rect.position = grate_positions[i] + Vector2(0, 2 + bar * 4)
			bar_rect.size = Vector2(16, 1)
			bar_rect.color = COLOR_GRATE.darkened(0.3)
			parent.add_child(bar_rect)


func _build_drip_points(parent: Node) -> void:
	# Drip locations — small visual indicators of dripping water
	var drip_positions: Array[Vector2] = [
		Vector2(110, 300),
		Vector2(200, 356),
		Vector2(350, 420),
		Vector2(460, 200),
		Vector2(600, 200),
		Vector2(700, 256),
		Vector2(850, 320),
	]
	
	for i in range(drip_positions.size()):
		# Small blue dot
		var drip = ColorRect.new()
		drip.name = "DripPoint_%d" % i
		drip.position = drip_positions[i]
		drip.size = Vector2(3, 3)
		drip.color = Color(0.3, 0.5, 0.7, 0.6)
		parent.add_child(drip)
		
		# Animate drip falling
		var tween = create_tween().set_loops()
		tween.tween_interval(randf_range(1.0, 4.0))
		tween.tween_property(drip, "modulate:a", 1.0, 0.1)
		tween.tween_property(drip, "position:y", drip_positions[i].y + 8, 0.3)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(drip, "modulate:a", 0.0, 0.1)
		tween.tween_callback(func(): drip.position.y = drip_positions[i].y)
		tween.tween_interval(0.1)
		tween.tween_property(drip, "modulate:a", 0.6, 0.1)


func _build_boss_warnings(parent: Node) -> void:
	# Pre-boss area: corridor segment 6 (728, 320) and boss alcove (928, 280)
	var warning_base = Vector2(750, 320)
	
	# Bone decorations
	var bone_positions: Array[Vector2] = [
		warning_base + Vector2(10, 10),
		warning_base + Vector2(60, 44),
		warning_base + Vector2(120, 8),
		warning_base + Vector2(150, 40),
	]
	for i in range(bone_positions.size()):
		# Cross-bone shape (two small rects)
		var bone_h = ColorRect.new()
		bone_h.name = "Bone_%d_h" % i
		bone_h.position = bone_positions[i]
		bone_h.size = Vector2(10, 3)
		bone_h.color = COLOR_BONE
		parent.add_child(bone_h)
		
		var bone_v = ColorRect.new()
		bone_v.name = "Bone_%d_v" % i
		bone_v.position = bone_positions[i] + Vector2(3.5, -3.5)
		bone_v.size = Vector2(3, 10)
		bone_v.color = COLOR_BONE
		parent.add_child(bone_v)
	
	# Scratch marks on walls
	var scratch_positions: Array[Vector2] = [
		Vector2(760, 314),
		Vector2(820, 314),
		Vector2(880, 314),
	]
	for i in range(scratch_positions.size()):
		for s in range(3):
			var scratch = ColorRect.new()
			scratch.name = "Scratch_%d_%d" % [i, s]
			scratch.position = scratch_positions[i] + Vector2(s * 4, 0)
			scratch.size = Vector2(2, 8)
			scratch.color = COLOR_SCRATCH
			parent.add_child(scratch)
	
	# Health pickup near boss door (visual indicator — green cross)
	var health_pos = Vector2(910, 340)
	var health_h = ColorRect.new()
	health_h.name = "PreBossHealth_H"
	health_h.position = health_pos
	health_h.size = Vector2(12, 4)
	health_h.color = Color(0.3, 0.85, 0.3, 0.8)
	parent.add_child(health_h)
	var health_v = ColorRect.new()
	health_v.name = "PreBossHealth_V"
	health_v.position = health_pos + Vector2(4, -4)
	health_v.size = Vector2(4, 12)
	health_v.color = Color(0.3, 0.85, 0.3, 0.8)
	parent.add_child(health_v)


func _build_hazards() -> void:
	var hazards_container: Node2D
	if has_node("Hazards"):
		hazards_container = $Hazards
	else:
		hazards_container = Node2D.new()
		hazards_container.name = "Hazards"
		add_child(hazards_container)
	
	# 4 obvious toxic puddles + 2 camouflaged
	var puddle_configs: Array[Dictionary] = [
		# Obvious — placed along corridors (visible danger)
		{"pos": Vector2(130, 320), "camo": false, "size": Vector2(24, 16)},
		{"pos": Vector2(310, 440), "camo": false, "size": Vector2(28, 16)},
		{"pos": Vector2(520, 220), "camo": false, "size": Vector2(24, 18)},
		{"pos": Vector2(780, 340), "camo": false, "size": Vector2(26, 16)},
		# Camouflaged — hidden in dark corners and side rooms
		{"pos": Vector2(130, 240), "camo": true, "size": Vector2(20, 14)},
		{"pos": Vector2(830, 420), "camo": true, "size": Vector2(22, 14)},
	]
	
	for i in range(puddle_configs.size()):
		var config = puddle_configs[i]
		var puddle = Area2D.new()
		puddle.name = "ToxicPuddle_%d" % i
		puddle.set_script(TOXIC_PUDDLE_SCRIPT)
		puddle.position = config.pos
		puddle.is_camouflaged = config.camo
		puddle.puddle_size = config.size
		hazards_container.add_child(puddle)


func _build_enemies() -> void:
	var enemies_cont: Node2D
	if has_node("Enemies"):
		enemies_cont = $Enemies
	else:
		enemies_cont = Node2D.new()
		enemies_cont.name = "Enemies"
		add_child(enemies_cont)
	
	# Early corridor — rat packs (entrance area, lower difficulty)
	var early_rats: Array[Vector2] = [
		Vector2(100, 320),
		Vector2(115, 330),
		Vector2(108, 340),
		# Second pack near first bend
		Vector2(180, 380),
		Vector2(195, 390),
		Vector2(188, 400),
	]
	for i in range(early_rats.size()):
		var rat = SEWER_RAT_SCENE.instantiate()
		rat.name = "SewerRat_early_%d" % i
		rat.position = early_rats[i]
		enemies_cont.add_child(rat)
	
	# Mid corridor — mixed rats and shadow creatures
	var mid_rats: Array[Vector2] = [
		Vector2(300, 440),
		Vector2(315, 450),
		Vector2(380, 435),
		Vector2(395, 445),
	]
	for i in range(mid_rats.size()):
		var rat = SEWER_RAT_SCENE.instantiate()
		rat.name = "SewerRat_mid_%d" % i
		rat.position = mid_rats[i]
		enemies_cont.add_child(rat)
	
	# Shadow creatures in deeper areas (upper horizontal and beyond)
	var shadow_positions: Array[Vector2] = [
		Vector2(510, 225),
		Vector2(620, 220),
		Vector2(700, 300),
	]
	for i in range(shadow_positions.size()):
		var shadow = SHADOW_CREATURE_SCENE.instantiate()
		shadow.name = "ShadowCreature_%d" % i
		shadow.position = shadow_positions[i]
		enemies_cont.add_child(shadow)
	
	# Side room ambushes
	# Room 1 (treasure): 2 rats guarding
	var treasure_rats: Array[Vector2] = [
		Vector2(125, 240),
		Vector2(155, 255),
	]
	for i in range(treasure_rats.size()):
		var rat = SEWER_RAT_SCENE.instantiate()
		rat.name = "SewerRat_treasure_%d" % i
		rat.position = treasure_rats[i]
		enemies_cont.add_child(rat)
	
	# Room 2 (ambush): 4 rats swarm
	var ambush_rats: Array[Vector2] = [
		Vector2(300, 510),
		Vector2(320, 520),
		Vector2(340, 510),
		Vector2(310, 540),
	]
	for i in range(ambush_rats.size()):
		var rat = SEWER_RAT_SCENE.instantiate()
		rat.name = "SewerRat_ambush_%d" % i
		rat.position = ambush_rats[i]
		enemies_cont.add_child(rat)
	
	# Room 3 (hazard): shadow creature lurking
	var hazard_shadow = SHADOW_CREATURE_SCENE.instantiate()
	hazard_shadow.name = "ShadowCreature_hazard"
	hazard_shadow.position = Vector2(575, 145)
	enemies_cont.add_child(hazard_shadow)
	
	# Room 4 (deep ambush): shadow creature + rat pack
	var deep_shadow = SHADOW_CREATURE_SCENE.instantiate()
	deep_shadow.name = "ShadowCreature_deep"
	deep_shadow.position = Vector2(830, 420)
	enemies_cont.add_child(deep_shadow)
	var deep_rats: Array[Vector2] = [
		Vector2(810, 430),
		Vector2(850, 440),
		Vector2(825, 450),
	]
	for i in range(deep_rats.size()):
		var rat = SEWER_RAT_SCENE.instantiate()
		rat.name = "SewerRat_deep_%d" % i
		rat.position = deep_rats[i]
		enemies_cont.add_child(rat)
	
	# Pre-boss corridor — final rat pack
	var boss_rats: Array[Vector2] = [
		Vector2(860, 340),
		Vector2(875, 350),
		Vector2(890, 338),
	]
	for i in range(boss_rats.size()):
		var rat = SEWER_RAT_SCENE.instantiate()
		rat.name = "SewerRat_boss_%d" % i
		rat.position = boss_rats[i]
		enemies_cont.add_child(rat)


func _build_boss_door() -> void:
	var boss_door_container = Node2D.new()
	boss_door_container.name = "BossDoor"
	add_child(boss_door_container)
	
	# Door frame
	var frame_pos = Vector2(1010, 300)
	var frame = ColorRect.new()
	frame.name = "DoorFrame"
	frame.position = frame_pos
	frame.size = Vector2(24, 80)
	frame.color = COLOR_BOSS_DOOR_FRAME
	boss_door_container.add_child(frame)
	
	# Door itself (large, imposing)
	var door = ColorRect.new()
	door.name = "Door"
	door.position = frame_pos + Vector2(2, 4)
	door.size = Vector2(20, 72)
	door.color = COLOR_BOSS_DOOR
	boss_door_container.add_child(door)
	
	# Door handle / knocker (small circle-like rect)
	var handle = ColorRect.new()
	handle.name = "DoorHandle"
	handle.position = frame_pos + Vector2(5, 34)
	handle.size = Vector2(6, 6)
	handle.color = Color(0.5, 0.4, 0.15)
	boss_door_container.add_child(handle)
	
	# Warning text above door
	var warning_label = Label.new()
	warning_label.name = "WarningLabel"
	warning_label.position = frame_pos + Vector2(-20, -20)
	warning_label.text = "DANGER!"
	warning_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 0.8))
	warning_label.add_theme_font_size_override("font_size", 10)
	boss_door_container.add_child(warning_label)


func _build_zone_exits() -> void:
	var exits_container: Node2D
	if has_node("ZoneExits"):
		exits_container = $ZoneExits
	else:
		exits_container = Node2D.new()
		exits_container.name = "ZoneExits"
		add_child(exits_container)
	
	# Exit back to neighborhood (at entrance)
	var to_neighborhood = ZONE_EXIT_SCENE.instantiate()
	to_neighborhood.name = "ToNeighborhood"
	to_neighborhood.position = Vector2(24, 324)
	to_neighborhood.exit_id = "to_neighborhood"
	to_neighborhood.target_zone = "neighborhood"
	to_neighborhood.target_spawn = "from_sewers"
	exits_container.add_child(to_neighborhood)
	
	# Exit to boss room (at the boss door)
	var to_boss = ZONE_EXIT_SCENE.instantiate()
	to_boss.name = "ToBossRoom"
	to_boss.position = Vector2(1020, 340)
	to_boss.exit_id = "to_boss_room"
	to_boss.target_zone = "boss_arena"
	to_boss.target_spawn = "default"
	to_boss.require_interaction = true  # Must press action to enter
	exits_container.add_child(to_boss)


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
