extends Node
## Manages spawning and pooling of visual effects.
## Call EffectsManager.spawn_effect("hit_spark", position) to create effects.

# =============================================================================
# VIEWPORT
# =============================================================================

const VIEWPORT_SIZE := Vector2(384, 216)
const VIEWPORT_CENTER := Vector2(192, 108)

# =============================================================================
# Z-INDEX LAYERS (higher = renders on top)
# =============================================================================

const Z_BEHIND_PLAYER := -1
const Z_GROUND := 5
const Z_SWOOSH := 50
const Z_SHOCKWAVE := 50
const Z_CHARGE_BURST := 60
const Z_PARRY_SPARKS := 70
const Z_DEATH_BURST := 80
const Z_EXP_TEXT := 90
const Z_PARTICLES := 100
const Z_SCREEN_FLASH := 1000

## Canvas overlay layer indices
const CANVAS_LAYER_BOSS_TITLE := 90
const CANVAS_LAYER_DAMAGE_DIR := 95
const CANVAS_LAYER_VICTORY := 95
const CANVAS_LAYER_SCREEN_FLASH := 100

# =============================================================================
# SCREEN SHAKE PRESETS
# =============================================================================

const SHAKE_DEFAULT_INTENSITY := 3.0
const SHAKE_DEFAULT_DURATION := 0.15

const SHAKE_LIGHT_INTENSITY := 2.0
const SHAKE_LIGHT_DURATION := 0.1

const SHAKE_MEDIUM_INTENSITY := 4.0
const SHAKE_MEDIUM_DURATION := 0.15

const SHAKE_HEAVY_INTENSITY := 6.0
const SHAKE_HEAVY_DURATION := 0.2

const SHAKE_LEVEL_UP_INTENSITY := 12.0
const SHAKE_LEVEL_UP_DURATION := 0.4

const SHAKE_GROUND_POUND_INTENSITY := 10.0
const SHAKE_GROUND_POUND_DURATION := 0.35

const SHAKE_BOSS_INTRO_INTENSITY := 6.0
const SHAKE_BOSS_INTRO_DURATION := 0.5

const SHAKE_BOSS_VICTORY_INTENSITY := 12.0
const SHAKE_BOSS_VICTORY_DURATION := 0.5

const SHAKE_PARRY_INTENSITY := 6.0
const SHAKE_PARRY_DURATION := 0.2

const SHAKE_COMBO_BASE_INTENSITY := 4.0
const SHAKE_COMBO_DURATION := 0.15

const SHAKE_CHARGE_BASE_INTENSITY := 5.0
const SHAKE_CHARGE_DURATION := 0.2

# =============================================================================
# HITSTOP / IMPACT FREEZE
# =============================================================================

const HITSTOP_DEFAULT_DURATION := 0.05
const HITSTOP_LIGHT_DURATION := 0.03
const HITSTOP_HEAVY_DURATION := 0.08

# =============================================================================
# CAMERA PUNCH PRESETS
# =============================================================================

const CAMERA_PUNCH_DEFAULT_ZOOM := 1.1
const CAMERA_PUNCH_DEFAULT_DURATION := 0.15
const CAMERA_PUNCH_ZOOM_IN_RATIO := 0.3
const CAMERA_PUNCH_ZOOM_OUT_RATIO := 0.7

const CAMERA_PUNCH_GROUND_POUND_ZOOM := 1.15
const CAMERA_PUNCH_GROUND_POUND_DURATION := 0.2

const CAMERA_PUNCH_BOSS_INTRO_ZOOM := 1.2
const CAMERA_PUNCH_BOSS_INTRO_DURATION := 0.5

const CAMERA_PUNCH_PARRY_ZOOM := 1.08
const CAMERA_PUNCH_PARRY_DURATION := 0.12

const CAMERA_PUNCH_CHARGE_ZOOM := 1.1
const CAMERA_PUNCH_CHARGE_DURATION := 0.15

# =============================================================================
# TIME SCALE / SLOWMO
# =============================================================================

const SLOWMO_COMBO_SCALE := 0.5
const SLOWMO_COMBO_DURATION := 0.1

const SLOWMO_LEVEL_UP_SCALE := 0.3
const SLOWMO_LEVEL_UP_PAUSE := 0.15
const SLOWMO_LEVEL_UP_RESTORE := 0.2

const SLOWMO_BOSS_INTRO_SCALE := 0.3
const SLOWMO_BOSS_INTRO_PAUSE := 0.4
const SLOWMO_BOSS_INTRO_RESTORE := 0.3

const SLOWMO_BOSS_VICTORY_SCALE := 0.2
const SLOWMO_BOSS_VICTORY_PAUSE := 0.5
const SLOWMO_BOSS_VICTORY_RESTORE := 0.5

# =============================================================================
# COMBO
# =============================================================================

## Combo shake scaling multipliers
const COMBO_SHAKE_MULTIPLIERS := [1.0, 1.5, 2.5]
## Hit count that triggers heavy hitstop
const COMBO_HEAVY_HIT_COUNT := 3

# =============================================================================
# PICKUP SYSTEM
# =============================================================================

## Base drop chance (0.0 to 1.0)
const BASE_DROP_CHANCE: float = 0.35

## Bonus drop chance per missing 10% of player health
const LOW_HEALTH_DROP_BONUS: float = 0.08

## Drop chance caps
const MIN_DROP_CHANCE: float = 0.2
const MAX_DROP_CHANCE: float = 0.85

## Heal amounts by enemy type
const HEAL_AMOUNTS: Dictionary = {
	"default": 15,
	"crow": 10,      # Weaker enemy = less heal
	"raccoon": 20,   # Standard enemy
	"boss": 50       # Boss drops big heal
}

const DEFAULT_HEAL_AMOUNT := 15
const HEALTH_PICKUP_OFFSET_RANGE := 8.0

## Each 10% of missing health adds LOW_HEALTH_DROP_BONUS to drop chance
const HEALTH_PERCENT_SEGMENT: float = 0.1

## Pickup collection particles
const PICKUP_PARTICLE_COUNT_MIN := 5
const PICKUP_PARTICLE_COUNT_MAX := 8
const PICKUP_PARTICLE_SIZE := Vector2(2, 2)
const PICKUP_PARTICLE_CENTER_OFFSET := Vector2(1, 1)
const PICKUP_PARTICLE_DIST_MIN := 12.0
const PICKUP_PARTICLE_DIST_MAX := 20.0
const PICKUP_PARTICLE_DURATION := 0.25
const PICKUP_FLASH_SIZE := Vector2(12, 12)
const PICKUP_FLASH_HALF_SIZE := Vector2(6, 6)
const PICKUP_FLASH_ALPHA := 0.7
const PICKUP_FLASH_SCALE := Vector2(1.5, 1.5)
const PICKUP_FLASH_DURATION := 0.12

# =============================================================================
# EFFECT POOLING
# =============================================================================

const POOL_SIZE: int = 10

# =============================================================================
# HIT EFFECTS
# =============================================================================

const HIT_SPARK_OFFSET := 5.0
const DAMAGE_NUMBER_OFFSET_Y := -16.0
const PLAYER_DAMAGE_OFFSET_Y := -10.0
const ENEMY_DEFEAT_FLASH_COLOR := Color(1, 1, 1, 0.25)
const ENEMY_DEFEAT_FLASH_DURATION := 0.1

# =============================================================================
# SPECIAL ATTACK
# =============================================================================

const SPECIAL_DUST_COUNT := 4
const SPECIAL_DUST_RADIUS := 12.0

# =============================================================================
# GROUND POUND
# =============================================================================

const GROUND_POUND_DUST_COUNT := 12
const GROUND_POUND_DUST_OFFSET := 8.0
const GROUND_POUND_FLASH_COLOR := Color(1, 0.8, 0.3, 0.3)
const GROUND_POUND_FLASH_DURATION := 0.15

## Shockwave
const SHOCKWAVE_RING_COUNT := 3
const SHOCKWAVE_RING_DELAY := 0.05
const SHOCKWAVE_RADIUS_DIVISOR := 10.0
const SHOCKWAVE_RING_SCALE_INCREMENT := 0.3
const SHOCKWAVE_DURATION := 0.4
const SHOCKWAVE_RING_SEGMENTS := 16
const SHOCKWAVE_SEGMENT_RADIUS := 10.0
const SHOCKWAVE_SEGMENT_SIZE := Vector2(4, 4)
const SHOCKWAVE_SEGMENT_OFFSET := Vector2(2, 2)
const SHOCKWAVE_COLOR := Color(1, 0.9, 0.5, 0.8)

## Ground crack particles
const GROUND_CRACK_COUNT := 8
const GROUND_CRACK_SIZE := Vector2(3, 3)
const GROUND_CRACK_COLOR := Color(0.6, 0.5, 0.3, 1)
const GROUND_CRACK_DIST_MIN := 15.0
const GROUND_CRACK_DIST_MAX := 35.0
const GROUND_CRACK_MOVE_DURATION := 0.3
const GROUND_CRACK_FADE_DURATION := 0.4

# =============================================================================
# ATTACK SWOOSH
# =============================================================================

const SWOOSH_ARC_SWEEP := 2.2  ## ~130 degrees
const SWOOSH_ARC_RADIUS := 14.0
const SWOOSH_FACING_OFFSET := 6.0
const SWOOSH_START_ANGLE_OFFSET := -0.5
const SWOOSH_COUNT := 8
const SWOOSH_PARTICLE_SIZE := Vector2(3, 2)
const SWOOSH_ALPHA_BASE := 0.8
const SWOOSH_ALPHA_FADE_RANGE := 0.4
const SWOOSH_APPEAR_DURATION := 0.02
const SWOOSH_STAGGER_DELAY := 0.04
const SWOOSH_FADE_DURATION := 0.1

# =============================================================================
# DODGE AFTERIMAGE
# =============================================================================

const AFTERIMAGE_COUNT := 3
const AFTERIMAGE_DELAY := 0.06
const AFTERIMAGE_DEFAULT_POLYGON_SIZE := 6.0
const AFTERIMAGE_ALPHA_BASE := 0.5
const AFTERIMAGE_ALPHA_DECREMENT := 0.12
const AFTERIMAGE_COLOR := Color(0.5, 0.8, 1.0)
const AFTERIMAGE_FADE_DURATION := 0.2

# =============================================================================
# DEATH EXPLOSION
# =============================================================================

const DEATH_PARTICLE_COUNT := 10
const DEATH_PARTICLE_SIZE_MIN := 2.0
const DEATH_PARTICLE_SIZE_MAX := 5.0
const DEATH_EXPLOSION_COLORS := [
	Color(0.9, 0.3, 0.2), Color(0.8, 0.5, 0.2),
	Color(1, 0.8, 0.3), Color(0.7, 0.2, 0.2)
]
const DEATH_DIST_MIN := 15.0
const DEATH_DIST_MAX := 35.0
const DEATH_MOVE_X_DURATION := 0.4
const DEATH_ARC_UP_Y := 10.0
const DEATH_ARC_UP_DURATION := 0.2
const DEATH_ARC_DOWN_Y := 5.0
const DEATH_ARC_DOWN_DURATION := 0.2
const DEATH_FADE_DURATION := 0.15

# =============================================================================
# CHARGE ATTACK
# =============================================================================

const CHARGE_GLOW_SIZE := Vector2(24, 24)
const CHARGE_GLOW_OFFSET := Vector2(-12, -12)
const CHARGE_GLOW_COLOR := Color(1, 0.6, 0.2, 0.4)
const CHARGE_GLOW_INTENSE_COLOR := Color(1, 0.3, 0.1, 0.6)
const CHARGE_GLOW_PULSE_SCALE := Vector2(1.3, 1.3)
const CHARGE_GLOW_PULSE_DURATION := 0.3
const CHARGE_GLOW_COLOR_SHIFT_DURATION := 0.8

const CHARGE_INTENSITY_BASE := 0.5
const CHARGE_INTENSITY_SCALE := 0.5
const CHARGE_HEAVY_THRESHOLD := 0.7
const CHARGE_CAMERA_THRESHOLD := 0.9
const CHARGE_FLASH_ALPHA_FACTOR := 0.4
const CHARGE_FLASH_COLOR_BASE := Color(1, 0.8, 0.4)
const CHARGE_FLASH_DURATION := 0.1

const CHARGE_BURST_BASE_COUNT := 6
const CHARGE_BURST_SCALE_COUNT := 8
const CHARGE_BURST_BASE_SIZE := 3.0
const CHARGE_BURST_SCALE_SIZE := 2.0
const CHARGE_BURST_COLOR := Color(1, 0.7, 0.3, 1)
const CHARGE_BURST_SPEED_MIN := 40.0
const CHARGE_BURST_SPEED_MAX := 80.0
const CHARGE_BURST_SPEED_SCALE := 0.3
const CHARGE_BURST_MOVE_DURATION := 0.25
const CHARGE_BURST_FADE_DURATION := 0.3

# =============================================================================
# PARRY EFFECT
# =============================================================================

const PARRY_FLASH_COLOR := Color(0.3, 0.6, 1.0, 0.4)
const PARRY_FLASH_DURATION := 0.15

const PARRY_SPARK_COUNT := 10
const PARRY_SPARK_SIZE := Vector2(4, 2)
const PARRY_SPARK_COLOR := Color(0.5, 0.8, 1.0, 1)
const PARRY_SPARK_ANGLE_JITTER := 0.2
const PARRY_SPARK_DIST_MIN := 20.0
const PARRY_SPARK_DIST_MAX := 35.0
const PARRY_SPARK_MOVE_DURATION := 0.2
const PARRY_SPARK_FADE_DURATION := 0.25

const PARRY_TEXT_FONT_SIZE := 14
const PARRY_TEXT_COLOR := Color(0.5, 0.8, 1.0)
const PARRY_TEXT_OUTLINE_COLOR := Color(0.1, 0.2, 0.4)
const PARRY_TEXT_OUTLINE_SIZE := 2
const PARRY_TEXT_OFFSET := Vector2(-25, -40)
const PARRY_TEXT_INITIAL_SCALE := Vector2(0.5, 0.5)
const PARRY_TEXT_POP_SCALE := Vector2(1.2, 1.2)
const PARRY_TEXT_POP_DURATION := 0.1
const PARRY_TEXT_SETTLE_SCALE := Vector2(1.0, 1.0)
const PARRY_TEXT_FLOAT_Y := -55.0
const PARRY_TEXT_FLOAT_DURATION := 0.6
const PARRY_TEXT_FADE_DURATION := 0.3

# =============================================================================
# LEVEL UP CELEBRATION
# =============================================================================

const LEVEL_UP_FLASH_COLOR := Color(1, 0.95, 0.5, 0.5)
const LEVEL_UP_FLASH_DURATION := 0.4
const LEVEL_UP_CELEBRATION_DELAY := 0.3

## Aura
const LEVEL_UP_AURA_SIZE := Vector2(40, 40)
const LEVEL_UP_AURA_COLOR := Color(1, 0.85, 0.3, 0.6)
const LEVEL_UP_AURA_SCALE_TARGET := Vector2(2.5, 2.5)
const LEVEL_UP_AURA_DURATION := 0.5

## Rings
const LEVEL_UP_RING_COUNT := 3
const LEVEL_UP_RING_DELAY := 0.1
const LEVEL_UP_RING_BASE_PARTICLES := 12
const LEVEL_UP_RING_PARTICLE_INCREMENT := 4
const LEVEL_UP_RING_BASE_RADIUS := 25.0
const LEVEL_UP_RING_RADIUS_INCREMENT := 15.0
const LEVEL_UP_RING_PARTICLE_SIZE := Vector2(3, 3)
const LEVEL_UP_RING_COLORS := [Color(1, 0.8, 0.2), Color(1, 0.95, 0.4), Color(1, 1, 0.8)]
const LEVEL_UP_RING_BASE_DURATION := 0.3
const LEVEL_UP_RING_DURATION_INCREMENT := 0.1
const LEVEL_UP_RING_FADE_DELAY := 0.1

## Sparkles
const LEVEL_UP_SPARKLE_COUNT := 12
const LEVEL_UP_SPARKLE_SIZE := Vector2(2, 4)
const LEVEL_UP_SPARKLE_COLOR := Color(1, 1, 0.6, 1)
const LEVEL_UP_SPARKLE_X_SPREAD := 15.0
const LEVEL_UP_SPARKLE_Y_MIN := 30.0
const LEVEL_UP_SPARKLE_Y_MAX := 60.0
const LEVEL_UP_SPARKLE_DRIFT_X := 20.0
const LEVEL_UP_SPARKLE_Y_DURATION_MIN := 0.4
const LEVEL_UP_SPARKLE_Y_DURATION_MAX := 0.8
const LEVEL_UP_SPARKLE_DRIFT_DURATION := 0.6
const LEVEL_UP_SPARKLE_FADE_DELAY := 0.2

## Level-up text
const LEVEL_UP_TEXT_OFFSET_Y := -40.0
const LEVEL_UP_TEXT_FONT_SIZE := 14
const LEVEL_UP_TEXT_COLOR := Color(1, 0.9, 0.2)
const LEVEL_UP_TEXT_OUTLINE_COLOR := Color(0.4, 0.25, 0)
const LEVEL_UP_TEXT_OUTLINE_SIZE := 3
const LEVEL_UP_TEXT_POSITION := Vector2(-40, 0)
const LEVEL_UP_TEXT_PIVOT := Vector2(40, 10)
const LEVEL_UP_TEXT_INITIAL_SCALE := Vector2(2.0, 2.0)
const LEVEL_UP_TEXT_SCALE_DURATION := 0.3
const LEVEL_UP_LEVEL_FONT_SIZE := 11
const LEVEL_UP_LEVEL_COLOR := Color(1, 1, 0.8)
const LEVEL_UP_LEVEL_OUTLINE_COLOR := Color(0.3, 0.2, 0)
const LEVEL_UP_LEVEL_OUTLINE_SIZE := 2
const LEVEL_UP_LEVEL_POSITION := Vector2(-20, 18)
const LEVEL_UP_LEVEL_FADE_DELAY := 0.15
const LEVEL_UP_TEXT_HOLD := 0.8
const LEVEL_UP_TEXT_FLOAT_Y := 25.0
const LEVEL_UP_TEXT_FADE_DURATION := 0.6

## Stat popups
const STAT_POPUP_DELAY := 0.15
const STAT_POPUP_FONT_SIZE := 8
const STAT_POPUP_OUTLINE_COLOR := Color(0, 0, 0)
const STAT_POPUP_OUTLINE_SIZE := 1
const STAT_POPUP_FLOAT_Y := 20.0
const STAT_POPUP_FADE_IN := 0.15
const STAT_POPUP_FLOAT_DURATION := 0.8
const STAT_POPUP_HOLD_DELAY := 0.4
const STAT_POPUP_FADE_DURATION := 0.4

# =============================================================================
# EXP POPUP
# =============================================================================

const EXP_POPUP_FONT_SIZE := 10
const EXP_POPUP_COLOR := Color(0.7, 0.5, 1.0)
const EXP_POPUP_OUTLINE_COLOR := Color(0.2, 0.1, 0.3)
const EXP_POPUP_OUTLINE_SIZE := 1
const EXP_POPUP_OFFSET := Vector2(-15, -20)
const EXP_POPUP_FLOAT_Y := 25.0
const EXP_POPUP_DURATION := 0.8
const EXP_POPUP_FADE_DELAY := 0.3

# =============================================================================
# DAMAGE DIRECTION INDICATOR
# =============================================================================

const DAMAGE_DIR_BAR_LENGTH := 80.0
const DAMAGE_DIR_BAR_THICKNESS := 6.0
const DAMAGE_DIR_COLOR := Color(1, 0.1, 0.05, 0.7)
const DAMAGE_DIR_FADE_DURATION := 0.25

# =============================================================================
# BOSS INTRO
# =============================================================================

const BOSS_INTRO_OVERLAY_COLOR := Color(0, 0, 0, 0.6)
const BOSS_INTRO_OVERLAY_DURATION := 0.8

const BOSS_NAME_FONT_SIZE := 18
const BOSS_NAME_COLOR := Color(1, 0.85, 0.2)
const BOSS_NAME_OUTLINE_COLOR := Color(0.3, 0.1, 0)
const BOSS_NAME_OUTLINE_SIZE := 3
const BOSS_NAME_X_OFFSET := 80.0
const BOSS_NAME_Y_OFFSET := 20.0
const BOSS_NAME_PIVOT := Vector2(80, 15)
const BOSS_NAME_INITIAL_SCALE := Vector2(0.1, 0.1)
const BOSS_NAME_SLAM_DURATION := 0.2
const BOSS_NAME_FADE_IN_DURATION := 0.15

const BOSS_SUBTITLE_FONT_SIZE := 9
const BOSS_SUBTITLE_COLOR := Color(0.9, 0.7, 0.4)
const BOSS_SUBTITLE_OUTLINE_COLOR := Color(0.2, 0.1, 0)
const BOSS_SUBTITLE_OUTLINE_SIZE := 1
const BOSS_SUBTITLE_X_OFFSET := 60.0
const BOSS_SUBTITLE_Y_OFFSET := 10.0
const BOSS_SUBTITLE_FADE_DURATION := 0.2

const BOSS_TITLE_HOLD := 1.5
const BOSS_TITLE_FADE_OUT := 0.5

# =============================================================================
# BOSS VICTORY
# =============================================================================

const VICTORY_FLASH_COLOR := Color(1, 1, 0.8, 0.6)
const VICTORY_FLASH_DURATION := 0.5

const VICTORY_FONT_SIZE := 24
const VICTORY_TEXT_COLOR := Color(1, 0.95, 0.3)
const VICTORY_OUTLINE_COLOR := Color(0.4, 0.2, 0)
const VICTORY_OUTLINE_SIZE := 4
const VICTORY_X_OFFSET := 60.0
const VICTORY_Y_OFFSET := 25.0
const VICTORY_PIVOT := Vector2(60, 18)
const VICTORY_INITIAL_SCALE := Vector2(3.0, 3.0)
const VICTORY_SLAM_DURATION := 0.3
const VICTORY_HOLD := 2.5
const VICTORY_FLOAT_Y := 30.0
const VICTORY_FADE_DURATION := 0.8

## Fireworks
const FIREWORK_WAVE_COUNT := 3
const FIREWORK_WAVE_DELAY := 0.3
const FIREWORK_X_SPREAD := 60.0
const FIREWORK_Y_SPREAD_MIN := -40.0
const FIREWORK_Y_SPREAD_MAX := 20.0
const FIREWORK_PARTICLE_COUNT := 15
const FIREWORK_PARTICLE_SIZE := Vector2(3, 3)
const FIREWORK_COLORS := [Color(1, 0.9, 0.2), Color(1, 0.4, 0.2), Color(1, 1, 1)]
const FIREWORK_DIST_MIN := 20.0
const FIREWORK_DIST_MAX := 50.0
const FIREWORK_MOVE_DURATION := 0.5
const FIREWORK_ARC_UP := 15.0
const FIREWORK_ARC_UP_DURATION := 0.25
const FIREWORK_ARC_DOWN := 10.0
const FIREWORK_ARC_DOWN_DURATION := 0.25
const FIREWORK_FADE_DURATION := 0.4
const FIREWORK_FADE_DELAY := 0.1

# =============================================================================
# EFFECT SCENES
# =============================================================================

var effect_scenes: Dictionary = {
	"hit_spark": preload("res://components/effects/hit_spark.tscn"),
	"dust_puff": preload("res://components/effects/dust_puff.tscn"),
	"death_poof": preload("res://components/effects/death_poof.tscn"),
	"damage_number": preload("res://components/effects/damage_number.tscn")
}

var health_pickup_scene: PackedScene = preload("res://components/health/health_pickup.tscn")

# =============================================================================
# STATE
# =============================================================================

var effect_pools: Dictionary = {}

## Toggle screen shake on/off (QoL accessibility option)
var screen_shake_enabled: bool = true

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var original_camera_offset: Vector2 = Vector2.ZERO

var freeze_timer: SceneTreeTimer = null
var is_frozen: bool = false

## Ambient particle system (auto-spawned per zone)
var _ambient_particles: Node2D = null

## Charge attack glow reference
var charge_glow_node: Node2D = null

var camera_punch_active: bool = false

# =============================================================================
# ATTACK TYPE CONFIGURATIONS
# =============================================================================

## Configuration for screen shake and hit-stop per attack type
## Each entry: {shake_intensity, shake_duration, hitstop_duration}
const ATTACK_CONFIGS: Dictionary = {
	"light": {
		"shake_intensity": 2.0,
		"shake_duration": 0.1,
		"hitstop_duration": 0.03
	},
	"heavy": {
		"shake_intensity": 5.0,
		"shake_duration": 0.18,
		"hitstop_duration": 0.06
	},
	"combo_finisher": {
		"shake_intensity": 7.0,
		"shake_duration": 0.25,
		"hitstop_duration": 0.08
	},
	"ground_pound": {
		"shake_intensity": 10.0,
		"shake_duration": 0.35,
		"hitstop_duration": 0.1
	},
	"charge_release": {
		"shake_intensity": 6.0,
		"shake_duration": 0.2,
		"hitstop_duration": 0.07
	},
	"parry": {
		"shake_intensity": 6.0,
		"shake_duration": 0.2,
		"hitstop_duration": 0.08
	}
}

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Pre-warm pools
	for effect_name in effect_scenes.keys():
		effect_pools[effect_name] = []

	# Connect to combat events for automatic effects
	_connect_signals()

	# Auto-spawn ambient particles on zone entry
	Events.zone_entered.connect(_on_zone_entered_particles)

	DebugLogger.log_custom("INIT", "EffectsManager ready")


func _process(delta: float) -> void:
	_process_screen_shake(delta)


func _process_screen_shake(delta: float) -> void:
	if shake_timer <= 0.0:
		return

	shake_timer -= delta

	var player = get_tree().get_first_node_in_group("player")
	if player == null or not player.has_node("Camera2D"):
		return

	var camera: Camera2D = player.get_node("Camera2D")

	if shake_timer > 0.0:
		# Apply random shake offset based on remaining intensity
		var current_intensity = shake_intensity * (shake_timer / shake_duration)
		var offset = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
		camera.offset = original_camera_offset + offset
	else:
		# Reset camera when shake ends
		camera.offset = original_camera_offset
		shake_timer = 0.0


func _connect_signals() -> void:
	Events.player_hit_enemy.connect(_on_player_hit_enemy)
	Events.enemy_damaged.connect(_on_enemy_damaged)
	Events.enemy_defeated.connect(_on_enemy_defeated)
	Events.player_dodged.connect(_on_player_dodged)
	Events.player_damaged.connect(_on_player_damaged)
	Events.player_special_attacked.connect(_on_player_special_attacked)
	Events.combo_changed.connect(_on_combo_hit)
	Events.combo_completed.connect(_on_combo_completed)
	Events.player_leveled_up.connect(_on_player_level_up)
	Events.exp_gained.connect(_on_exp_gained)
	# Combat juice - special abilities
	Events.player_ground_pound_impact.connect(_on_ground_pound_impact)
	Events.player_charge_started.connect(_on_charge_started)
	Events.player_charge_released.connect(_on_charge_released)
	Events.player_parried.connect(_on_parry_success)
	# Boss events
	Events.boss_spawned.connect(_on_boss_intro)
	Events.boss_defeated.connect(_on_boss_victory)

# =============================================================================
# REUSABLE TWEEN HELPERS
# =============================================================================

## Set time scale and smoothly restore it via tween (ignoring time scale).
## Used by level-up, boss intro, boss victory slowmo sequences.
func _tween_slowmo_restore(target_scale: float, pause_delay: float, restore_duration: float) -> void:
	Engine.time_scale = target_scale
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_interval(pause_delay)
	tween.tween_property(Engine, "time_scale", 1.0, restore_duration)


## Create a ring of particles that expand outward from a center position.
## Used by level-up rings and similar ring expansion effects.
func _create_expanding_ring_particles(
	pos: Vector2,
	particle_count: int,
	ring_radius: float,
	particle_size: Vector2,
	color: Color,
	z_index: int,
	duration: float,
	fade_delay: float
) -> void:
	for i in range(particle_count):
		var angle = i * TAU / particle_count
		var particle = ColorRect.new()
		particle.size = particle_size
		particle.color = color
		particle.global_position = pos
		particle.z_index = z_index
		get_tree().current_scene.add_child(particle)

		var end_pos = pos + Vector2(cos(angle), sin(angle)) * ring_radius
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, duration).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, duration).set_delay(fade_delay)
		tween.chain().tween_callback(_safe_free.bind(particle))


## Create a styled Label node with font size, color, and outline.
## Returns the Label for further customization. Used by popup text effects.
func _create_styled_label(
	text: String,
	font_size: int,
	font_color: Color,
	outline_color: Color,
	outline_size: int
) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)
	return label


## Create a CanvasLayer + ColorRect for full-screen overlay effects.
## Returns the canvas for cleanup. Used by boss title, victory, damage direction.
func _create_canvas_overlay(layer: int) -> CanvasLayer:
	var canvas = CanvasLayer.new()
	canvas.layer = layer
	get_tree().current_scene.add_child(canvas)
	return canvas


## Safely queue_free a node if it's still valid (guards against zone-transition crashes).
## During zone changes, tweens on EffectsManager (autoload) persist but their target nodes
## may be freed — this prevents "previously freed" errors in tween callbacks.
func _safe_free(node: Node) -> void:
	if is_instance_valid(node):
		node.queue_free()


## Animate a slam-in scale effect (scale from initial to 1.0 with TRANS_BACK).
## Used by boss title, victory text, level-up text.
func _tween_slam_in(
	tween: Tween,
	node: Node,
	initial_scale: Vector2,
	duration: float
) -> void:
	node.scale = initial_scale
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), duration)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# =============================================================================
# SPAWN EFFECTS
# =============================================================================

## Spawn an effect at a world position
func spawn_effect(effect_name: String, position: Vector2, params: Dictionary = {}) -> Node:
	if not effect_scenes.has(effect_name):
		push_warning("EffectsManager: Unknown effect '%s'" % effect_name)
		return null

	var effect = _get_or_create_effect(effect_name)
	if effect == null:
		return null

	# Add to scene tree if needed
	if not effect.is_inside_tree():
		_get_effects_container().add_child(effect)

	# Position and configure
	effect.global_position = position
	effect.show()

	# Apply any custom parameters
	if effect.has_method("setup"):
		effect.setup(params)

	# Start the effect
	if effect.has_method("play"):
		effect.play()

	return effect


## Spawn hit spark between attacker and target
func spawn_hit_spark(attacker_pos: Vector2, target_pos: Vector2) -> void:
	var mid_point = (attacker_pos + target_pos) / 2.0
	# Offset slightly toward target
	var direction = (target_pos - attacker_pos).normalized()
	var spawn_pos = mid_point + direction * HIT_SPARK_OFFSET
	spawn_effect("hit_spark", spawn_pos)


## Spawn dust puff at position
func spawn_dust(position: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	spawn_effect("dust_puff", position, {"direction": direction})


## Spawn death poof at position
func spawn_death_poof(position: Vector2) -> void:
	spawn_effect("death_poof", position)


## Spawn floating damage number
func spawn_damage_number(position: Vector2, amount: int, is_critical: bool = false) -> void:
	spawn_effect("damage_number", position, {
		"amount": amount,
		"is_critical": is_critical
	})


# =============================================================================
# HEALTH PICKUP SPAWNING
# =============================================================================

## Try to spawn a health pickup at enemy position
func _try_spawn_health_pickup(enemy: Node) -> void:
	if enemy == null:
		return

	# Calculate drop chance based on player health
	var drop_chance = _calculate_drop_chance()

	# Roll for drop
	if randf() > drop_chance:
		return  # No drop this time

	# Spawn the pickup
	spawn_health_pickup(enemy.global_position, _get_enemy_heal_amount(enemy))


## Spawn a health pickup at position
func spawn_health_pickup(pos: Vector2, heal_amount: int = DEFAULT_HEAL_AMOUNT) -> void:
	var pickup = health_pickup_scene.instantiate()
	pickup.heal_amount = heal_amount
	pickup.global_position = pos + Vector2(
		randf_range(-HEALTH_PICKUP_OFFSET_RANGE, HEALTH_PICKUP_OFFSET_RANGE),
		randf_range(-HEALTH_PICKUP_OFFSET_RANGE, HEALTH_PICKUP_OFFSET_RANGE)
	)

	# Add to scene
	var container = _get_effects_container()
	container.add_child(pickup)


## Calculate drop chance based on player health
func _calculate_drop_chance() -> float:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return BASE_DROP_CHANCE

	var health_percent = 1.0
	if player.has_node("HealthComponent"):
		var health = player.get_node("HealthComponent")
		health_percent = health.get_health_percent()

	# Bonus for low health: +8% per 10% missing health
	var missing_health_percent = 1.0 - health_percent
	var bonus = (missing_health_percent / HEALTH_PERCENT_SEGMENT) * LOW_HEALTH_DROP_BONUS

	var final_chance = clampf(BASE_DROP_CHANCE + bonus, MIN_DROP_CHANCE, MAX_DROP_CHANCE)
	return final_chance


## Get heal amount based on enemy type
func _get_enemy_heal_amount(enemy: Node) -> int:
	if enemy == null:
		return HEAL_AMOUNTS["default"]

	var enemy_name = enemy.name.to_lower()

	# Check for boss
	if "boss" in enemy_name or enemy.is_in_group("bosses"):
		return HEAL_AMOUNTS["boss"]

	# Check for specific enemy types
	for enemy_type in HEAL_AMOUNTS.keys():
		if enemy_type in enemy_name:
			return HEAL_AMOUNTS[enemy_type]

	return HEAL_AMOUNTS["default"]


# =============================================================================
# SCREEN SHAKE
# =============================================================================

## Shake the camera with given intensity and duration
func screen_shake(intensity: float = SHAKE_DEFAULT_INTENSITY, duration: float = SHAKE_DEFAULT_DURATION) -> void:
	if not screen_shake_enabled:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null or not player.has_node("Camera2D"):
		return

	var camera: Camera2D = player.get_node("Camera2D")

	# Store original offset if starting new shake
	if shake_timer <= 0.0:
		original_camera_offset = camera.offset

	# Use strongest shake if overlapping
	shake_intensity = max(shake_intensity, intensity)
	shake_duration = duration
	shake_timer = duration


## Light shake for minor impacts
func shake_light() -> void:
	screen_shake(SHAKE_LIGHT_INTENSITY, SHAKE_LIGHT_DURATION)


## Medium shake for regular hits
func shake_medium() -> void:
	screen_shake(SHAKE_MEDIUM_INTENSITY, SHAKE_MEDIUM_DURATION)


## Heavy shake for big impacts
func shake_heavy() -> void:
	screen_shake(SHAKE_HEAVY_INTENSITY, SHAKE_HEAVY_DURATION)


# =============================================================================
# IMPACT FREEZE (HITSTOP)
# =============================================================================

## Briefly freeze the game for impact feel
func impact_freeze(duration: float = HITSTOP_DEFAULT_DURATION) -> void:
	if is_frozen:
		return  # Don't stack freezes

	is_frozen = true
	Engine.time_scale = 0.0

	# Create timer that ignores time_scale (process_always)
	freeze_timer = get_tree().create_timer(duration, true, false, true)
	freeze_timer.timeout.connect(_on_freeze_timeout)


func _on_freeze_timeout() -> void:
	Engine.time_scale = 1.0
	is_frozen = false


## Light hitstop for regular hits
func hitstop_light() -> void:
	impact_freeze(HITSTOP_LIGHT_DURATION)


## Heavy hitstop for kills/big hits
func hitstop_heavy() -> void:
	impact_freeze(HITSTOP_HEAVY_DURATION)


## Apply configured screen shake and hitstop for a specific attack type
func apply_attack_impact(attack_type: String, intensity_multiplier: float = 1.0) -> void:
	if not ATTACK_CONFIGS.has(attack_type):
		push_warning("EffectsManager: Unknown attack type '%s'" % attack_type)
		return

	var config = ATTACK_CONFIGS[attack_type]
	var shake_intensity = config.shake_intensity * intensity_multiplier
	var shake_duration = config.shake_duration
	var hitstop_duration = config.hitstop_duration

	screen_shake(shake_intensity, shake_duration)
	impact_freeze(hitstop_duration)


# =============================================================================
# POOLING HELPERS
# =============================================================================

func _get_or_create_effect(effect_name: String) -> Node:
	var pool = effect_pools.get(effect_name, [])

	# Try to find an available effect in pool
	for effect in pool:
		if is_instance_valid(effect) and not effect.visible:
			return effect

	# Create new effect if pool not full
	if pool.size() < POOL_SIZE:
		var scene = effect_scenes[effect_name]
		var new_effect = scene.instantiate()
		pool.append(new_effect)
		effect_pools[effect_name] = pool
		return new_effect

	# Pool full, reuse oldest valid entry
	if pool.size() > 0 and is_instance_valid(pool[0]):
		return pool[0]

	return null


func _get_effects_container() -> Node:
	# Get or create a container for effects in the current scene
	var root = get_tree().current_scene
	if not is_instance_valid(root):
		return self

	var container = root.get_node_or_null("EffectsContainer")
	if container == null:
		container = Node2D.new()
		container.name = "EffectsContainer"
		root.add_child(container)

	return container

# =============================================================================
# EVENT HANDLERS
# =============================================================================

func _on_player_hit_enemy(enemy: Node) -> void:
	if enemy == null:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player:
		spawn_hit_spark(player.global_position, enemy.global_position)
		# Attack swoosh arc
		_create_attack_swoosh(player)

	# Light impact for hitting enemy (screen shake handled by combo system)
	# Only apply hitstop here
	impact_freeze(ATTACK_CONFIGS["light"].hitstop_duration)
	# Light hitstop for hitting enemy
	hitstop_light()


func _on_enemy_damaged(enemy: Node, amount: int) -> void:
	if enemy == null:
		return

	# Spawn damage number above the enemy
	spawn_damage_number(enemy.global_position + Vector2(0, -16), amount)

	# Light screen shake for enemy damage (using configured values)
	screen_shake(ATTACK_CONFIGS["light"].shake_intensity, ATTACK_CONFIGS["light"].shake_duration)
	spawn_damage_number(enemy.global_position + Vector2(0, DAMAGE_NUMBER_OFFSET_Y), amount)

	# Light screen shake for enemy damage
	shake_light()


func _on_enemy_defeated(enemy: Node) -> void:
	if enemy == null:
		return

	spawn_death_poof(enemy.global_position)

	# Enhanced death explosion particles
	_create_death_explosion(enemy.global_position)

	# Heavy effects for kill (use heavy attack config)
	apply_attack_impact("heavy")

	# Brief flash at enemy position
	_flash_screen(Color(1, 1, 1, 0.25), 0.1)
	# Heavy effects for kill
	shake_medium()
	hitstop_heavy()

	# Brief flash at enemy position
	_flash_screen(ENEMY_DEFEAT_FLASH_COLOR, ENEMY_DEFEAT_FLASH_DURATION)

	# Try to spawn health pickup
	_try_spawn_health_pickup(enemy)


func _on_player_dodged() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		spawn_dust(player.global_position)
		# Start afterimage trail during dodge
		_create_dodge_afterimages(player)


func _on_player_damaged(amount: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		spawn_damage_number(player.global_position + Vector2(0, PLAYER_DAMAGE_OFFSET_Y), amount)
		# Damage direction indicator - flash from nearest enemy direction
		_create_damage_direction_indicator(player)

	# Screen shake when player takes damage
	shake_medium()


func _on_player_special_attacked() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Spawn dust puffs in a circle around player for spin effect
		for i in range(SPECIAL_DUST_COUNT):
			var angle = (i / float(SPECIAL_DUST_COUNT)) * TAU
			var offset = Vector2(cos(angle), sin(angle)) * SPECIAL_DUST_RADIUS
			spawn_dust(player.global_position + offset)

		# Light screen shake for power
		shake_light()


func _on_combo_hit(combo_count: int) -> void:
	if combo_count == 0:
		return

	# Combo hits 1-2 use light attack config, hit 3 (finisher) uses combo_finisher config
	if combo_count < 3:
		# Light attacks with increasing intensity
		var index = mini(combo_count - 1, COMBO_SHAKE_MULTIPLIERS.size() - 1)
		var multiplier = COMBO_SHAKE_MULTIPLIERS[index]
		apply_attack_impact("light", multiplier)
	else:
		# Combo finisher gets special impact
		apply_attack_impact("combo_finisher")


func _on_combo_completed(total_damage: int) -> void:
	# Full combo completion uses finisher config with extra multiplier
	apply_attack_impact("combo_finisher", 1.2)
	# Shake intensity increases with combo
	var index = mini(combo_count - 1, COMBO_SHAKE_MULTIPLIERS.size() - 1)
	var multiplier = COMBO_SHAKE_MULTIPLIERS[index]
	screen_shake(SHAKE_COMBO_BASE_INTENSITY * multiplier, SHAKE_COMBO_DURATION)

	# Hit 3 gets extra hitstop
	if combo_count == COMBO_HEAVY_HIT_COUNT:
		hitstop_heavy()


func _on_combo_completed(total_damage: int) -> void:
	# Big screen shake for full combo
	shake_heavy()

	# Brief time slow for impact
	Engine.time_scale = SLOWMO_COMBO_SCALE
	await get_tree().create_timer(SLOWMO_COMBO_DURATION * SLOWMO_COMBO_SCALE).timeout
	Engine.time_scale = 1.0


func _on_player_level_up(new_level: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Play level up sound
	AudioManager.play_sfx("level_up")

	# Brief slowmo for impact
	_tween_slowmo_restore(SLOWMO_LEVEL_UP_SCALE, SLOWMO_LEVEL_UP_PAUSE * SLOWMO_LEVEL_UP_SCALE, SLOWMO_LEVEL_UP_RESTORE)

	# Create all visual effects
	_create_level_up_celebration(player, new_level)

	# Screen effects
	screen_shake(SHAKE_LEVEL_UP_INTENSITY, SHAKE_LEVEL_UP_DURATION)
	_flash_screen(LEVEL_UP_FLASH_COLOR, LEVEL_UP_FLASH_DURATION)


func _create_level_up_celebration(target: Node2D, new_level: int) -> void:
	var pos = target.global_position

	# 1. Golden aura glow around player
	_create_level_up_aura(target)

	# 2. Multiple expanding rings
	_create_level_up_rings(pos)

	# 3. Sparkle particles shooting up
	_create_level_up_sparkles(pos)

	# 4. Big "LEVEL UP!" text
	_create_level_up_text(pos, new_level)

	# 5. Stat increase popups (delayed)
	await get_tree().create_timer(LEVEL_UP_CELEBRATION_DELAY).timeout
	if not is_instance_valid(target):
		return
	_create_stat_popups(pos)


func _create_level_up_aura(target: Node2D) -> void:
	# Golden glow circle around player
	var aura = ColorRect.new()
	aura.size = LEVEL_UP_AURA_SIZE
	aura.color = LEVEL_UP_AURA_COLOR
	aura.pivot_offset = aura.size / 2
	aura.position = target.position - aura.size / 2
	aura.z_index = Z_BEHIND_PLAYER
	target.add_child(aura)

	# Pulse and fade
	var tween = create_tween()
	tween.tween_property(aura, "scale", LEVEL_UP_AURA_SCALE_TARGET, LEVEL_UP_AURA_DURATION).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(aura, "modulate:a", 0.0, LEVEL_UP_AURA_DURATION)
	tween.tween_callback(_safe_free.bind(aura))


func _create_level_up_rings(pos: Vector2) -> void:
	# Multiple expanding rings with delay
	for ring_idx in range(LEVEL_UP_RING_COUNT):
		await get_tree().create_timer(LEVEL_UP_RING_DELAY * ring_idx).timeout
		if not is_instance_valid(get_tree().current_scene):
			return

		var particle_count = LEVEL_UP_RING_BASE_PARTICLES + ring_idx * LEVEL_UP_RING_PARTICLE_INCREMENT
		var ring_radius = LEVEL_UP_RING_BASE_RADIUS + ring_idx * LEVEL_UP_RING_RADIUS_INCREMENT
		var duration = LEVEL_UP_RING_BASE_DURATION + ring_idx * LEVEL_UP_RING_DURATION_INCREMENT

		_create_expanding_ring_particles(
			pos,
			particle_count,
			ring_radius,
			LEVEL_UP_RING_PARTICLE_SIZE,
			LEVEL_UP_RING_COLORS[ring_idx],
			Z_PARTICLES,
			duration,
			LEVEL_UP_RING_FADE_DELAY
		)


func _create_level_up_sparkles(pos: Vector2) -> void:
	# Sparkles shooting upward
	for i in range(LEVEL_UP_SPARKLE_COUNT):
		var sparkle = ColorRect.new()
		sparkle.size = LEVEL_UP_SPARKLE_SIZE
		sparkle.color = LEVEL_UP_SPARKLE_COLOR
		sparkle.global_position = pos + Vector2(randf_range(-LEVEL_UP_SPARKLE_X_SPREAD, LEVEL_UP_SPARKLE_X_SPREAD), 0)
		sparkle.z_index = Z_PARTICLES
		get_tree().current_scene.add_child(sparkle)

		var end_y = pos.y - randf_range(LEVEL_UP_SPARKLE_Y_MIN, LEVEL_UP_SPARKLE_Y_MAX)
		var drift_x = randf_range(-LEVEL_UP_SPARKLE_DRIFT_X, LEVEL_UP_SPARKLE_DRIFT_X)

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sparkle, "global_position:y", end_y, randf_range(LEVEL_UP_SPARKLE_Y_DURATION_MIN, LEVEL_UP_SPARKLE_Y_DURATION_MAX)).set_ease(Tween.EASE_OUT)
		tween.tween_property(sparkle, "global_position:x", sparkle.global_position.x + drift_x, LEVEL_UP_SPARKLE_DRIFT_DURATION)
		tween.tween_property(sparkle, "modulate:a", 0.0, LEVEL_UP_SPARKLE_DRIFT_DURATION).set_delay(LEVEL_UP_SPARKLE_FADE_DELAY)
		tween.chain().tween_callback(_safe_free.bind(sparkle))


func _create_level_up_text(pos: Vector2, new_level: int) -> void:
	# Container for text
	var container = Control.new()
	container.global_position = pos + Vector2(0, LEVEL_UP_TEXT_OFFSET_Y)
	container.z_index = Z_PARTICLES
	get_tree().current_scene.add_child(container)

	# "LEVEL UP!" text - starts big, settles down
	var label = _create_styled_label(
		"LEVEL UP!",
		LEVEL_UP_TEXT_FONT_SIZE,
		LEVEL_UP_TEXT_COLOR,
		LEVEL_UP_TEXT_OUTLINE_COLOR,
		LEVEL_UP_TEXT_OUTLINE_SIZE
	)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = LEVEL_UP_TEXT_POSITION
	label.pivot_offset = LEVEL_UP_TEXT_PIVOT
	label.scale = LEVEL_UP_TEXT_INITIAL_SCALE
	container.add_child(label)

	# Level number below
	var level_label = _create_styled_label(
		"Lv. %d" % new_level,
		LEVEL_UP_LEVEL_FONT_SIZE,
		LEVEL_UP_LEVEL_COLOR,
		LEVEL_UP_LEVEL_OUTLINE_COLOR,
		LEVEL_UP_LEVEL_OUTLINE_SIZE
	)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.position = LEVEL_UP_LEVEL_POSITION
	level_label.modulate.a = 0
	container.add_child(level_label)

	# Animate: scale down, then float up
	var tween = create_tween()
	_tween_slam_in(tween, label, LEVEL_UP_TEXT_INITIAL_SCALE, LEVEL_UP_TEXT_SCALE_DURATION)
	tween.parallel().tween_property(level_label, "modulate:a", 1.0, LEVEL_UP_TEXT_SCALE_DURATION).set_delay(LEVEL_UP_LEVEL_FADE_DELAY)
	tween.tween_interval(LEVEL_UP_TEXT_HOLD)
	tween.tween_property(container, "global_position:y", container.global_position.y - LEVEL_UP_TEXT_FLOAT_Y, LEVEL_UP_TEXT_FADE_DURATION)
	tween.parallel().tween_property(container, "modulate:a", 0.0, LEVEL_UP_TEXT_FADE_DURATION)
	tween.tween_callback(_safe_free.bind(container))


func _create_stat_popups(pos: Vector2) -> void:
	# Show stat increases floating up from different positions
	var stats = [
		{text = "+10 HP", color = Color(0.4, 1, 0.4), offset = Vector2(-25, 10)},
		{text = "+3 ATK", color = Color(1, 0.5, 0.4), offset = Vector2(0, 15)},
		{text = "+2 SPD", color = Color(0.4, 0.8, 1), offset = Vector2(25, 10)}
	]

	for i in range(stats.size()):
		await get_tree().create_timer(STAT_POPUP_DELAY).timeout
		if not is_instance_valid(get_tree().current_scene):
			return

		var stat = stats[i]
		var label = _create_styled_label(
			stat.text,
			STAT_POPUP_FONT_SIZE,
			stat.color,
			STAT_POPUP_OUTLINE_COLOR,
			STAT_POPUP_OUTLINE_SIZE
		)
		label.global_position = pos + stat.offset
		label.z_index = Z_PARTICLES
		label.modulate.a = 0
		get_tree().current_scene.add_child(label)

		var tween = create_tween()
		tween.tween_property(label, "modulate:a", 1.0, STAT_POPUP_FADE_IN)
		tween.tween_property(label, "global_position:y", label.global_position.y - STAT_POPUP_FLOAT_Y, STAT_POPUP_FLOAT_DURATION).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(label, "modulate:a", 0.0, STAT_POPUP_FADE_DURATION).set_delay(STAT_POPUP_HOLD_DELAY)
		tween.tween_callback(_safe_free.bind(label))


func _flash_screen(color: Color, duration: float) -> void:
	var flash = ColorRect.new()
	flash.color = color
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = Z_SCREEN_FLASH

	# Add to CanvasLayer for HUD-level rendering
	var canvas = _create_canvas_overlay(CANVAS_LAYER_SCREEN_FLASH)
	canvas.add_child(flash)

	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	tween.tween_callback(_safe_free.bind(canvas))


func _on_exp_gained(amount: int, _level: int, _current: int, _to_next: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Create floating EXP text
	_create_exp_popup(player.global_position, amount)


func _create_exp_popup(pos: Vector2, amount: int) -> void:
	var label = _create_styled_label(
		"+" + str(amount) + " EXP",
		EXP_POPUP_FONT_SIZE,
		EXP_POPUP_COLOR,
		EXP_POPUP_OUTLINE_COLOR,
		EXP_POPUP_OUTLINE_SIZE
	)
	label.global_position = pos + EXP_POPUP_OFFSET
	label.z_index = Z_EXP_TEXT

	get_tree().current_scene.add_child(label)

	# Animate float up and fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - EXP_POPUP_FLOAT_Y, EXP_POPUP_DURATION)
	tween.tween_property(label, "modulate:a", 0.0, EXP_POPUP_DURATION).set_delay(EXP_POPUP_FADE_DELAY)
	tween.chain().tween_callback(_safe_free.bind(label))


# =============================================================================
# PICKUP COLLECTION EFFECTS
# =============================================================================

## Spawn pickup collection particles
func spawn_pickup_effect(pos: Vector2, color: Color) -> void:
	# Spawn 5-8 small particles that burst outward
	var particle_count = randi_range(PICKUP_PARTICLE_COUNT_MIN, PICKUP_PARTICLE_COUNT_MAX)
	for i in particle_count:
		var particle = ColorRect.new()
		particle.size = PICKUP_PARTICLE_SIZE
		particle.color = color
		particle.position = pos - PICKUP_PARTICLE_CENTER_OFFSET
		get_tree().current_scene.add_child(particle)

		# Animate outward and fade
		var tween = particle.create_tween()
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var end_pos = pos + direction * randf_range(PICKUP_PARTICLE_DIST_MIN, PICKUP_PARTICLE_DIST_MAX)
		tween.set_parallel(true)
		tween.tween_property(particle, "position", end_pos, PICKUP_PARTICLE_DURATION)
		tween.tween_property(particle, "modulate:a", 0.0, PICKUP_PARTICLE_DURATION)
		tween.chain().tween_callback(_safe_free.bind(particle))


## Quick flash at position (for emphasis)
func flash_pickup(pos: Vector2, color: Color) -> void:
	var flash = ColorRect.new()
	flash.size = PICKUP_FLASH_SIZE
	flash.position = pos - PICKUP_FLASH_HALF_SIZE
	flash.color = color
	flash.modulate.a = PICKUP_FLASH_ALPHA
	get_tree().current_scene.add_child(flash)

	var tween = flash.create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "scale", PICKUP_FLASH_SCALE, PICKUP_FLASH_DURATION)
	tween.tween_property(flash, "modulate:a", 0.0, PICKUP_FLASH_DURATION)
	tween.chain().tween_callback(_safe_free.bind(flash))

# =============================================================================
# ATTACK SWOOSH EFFECT
# =============================================================================

## Create an arc swoosh trail when player attacks
func _create_attack_swoosh(attacker: Node2D) -> void:
	var pos = attacker.global_position
	var facing_left = attacker.get("facing_left")
	if facing_left == null:
		facing_left = false
	var facing_dir = attacker.get("facing_direction")
	if facing_dir == null:
		facing_dir = "side"

	# Determine arc direction based on facing
	var arc_center: Vector2
	var arc_start_angle: float
	var arc_sweep: float = SWOOSH_ARC_SWEEP
	var arc_radius: float = SWOOSH_ARC_RADIUS

	match facing_dir:
		"down":
			arc_center = pos + Vector2(0, SWOOSH_FACING_OFFSET)
			arc_start_angle = SWOOSH_START_ANGLE_OFFSET
		"up":
			arc_center = pos + Vector2(0, -SWOOSH_FACING_OFFSET)
			arc_start_angle = PI + SWOOSH_START_ANGLE_OFFSET
		_:  # side
			if facing_left:
				arc_center = pos + Vector2(-SWOOSH_FACING_OFFSET, 0)
				arc_start_angle = PI * 0.5 + SWOOSH_START_ANGLE_OFFSET
			else:
				arc_center = pos + Vector2(SWOOSH_FACING_OFFSET, 0)
				arc_start_angle = -PI * 0.5 + SWOOSH_START_ANGLE_OFFSET

	# Create swoosh particles along the arc
	for i in range(SWOOSH_COUNT):
		var t = float(i) / float(SWOOSH_COUNT - 1)
		var angle = arc_start_angle + t * arc_sweep
		var swoosh_pos = arc_center + Vector2(cos(angle), sin(angle)) * arc_radius

		var particle = ColorRect.new()
		particle.size = SWOOSH_PARTICLE_SIZE
		particle.pivot_offset = particle.size / 2
		particle.rotation = angle
		particle.color = Color(1, 1, 1, SWOOSH_ALPHA_BASE - t * SWOOSH_ALPHA_FADE_RANGE)
		particle.global_position = swoosh_pos
		particle.z_index = Z_SWOOSH
		particle.modulate.a = 0.0
		get_tree().current_scene.add_child(particle)

		# Staggered appear then fade
		var tween = create_tween()
		tween.tween_property(particle, "modulate:a", 1.0, SWOOSH_APPEAR_DURATION).set_delay(t * SWOOSH_STAGGER_DELAY)
		tween.tween_property(particle, "modulate:a", 0.0, SWOOSH_FADE_DURATION)
		tween.tween_callback(_safe_free.bind(particle))

# =============================================================================
# DODGE AFTERIMAGE EFFECT
# =============================================================================

## Create ghost afterimages during dodge
func _create_dodge_afterimages(player_node: Node2D) -> void:
	var sprite = player_node.get_node_or_null("Sprite2D")
	if sprite == null:
		return

	# Create 3 afterimages spaced during the dodge
	for i in range(AFTERIMAGE_COUNT):
		await get_tree().create_timer(AFTERIMAGE_DELAY).timeout

		if not is_instance_valid(player_node):
			return

		# Create ghost copy
		var ghost = Polygon2D.new()
		var poly_size = AFTERIMAGE_DEFAULT_POLYGON_SIZE
		ghost.polygon = sprite.polygon.duplicate() if sprite is Polygon2D else PackedVector2Array([
			Vector2(-poly_size, -poly_size),
			Vector2(poly_size, -poly_size),
			Vector2(poly_size, poly_size),
			Vector2(-poly_size, poly_size)
		])
		ghost.color = Color(AFTERIMAGE_COLOR.r, AFTERIMAGE_COLOR.g, AFTERIMAGE_COLOR.b, AFTERIMAGE_ALPHA_BASE - i * AFTERIMAGE_ALPHA_DECREMENT)
		ghost.global_position = player_node.global_position
		ghost.z_index = player_node.z_index - 1

		# Match player scale/flip
		if sprite is Polygon2D:
			ghost.scale = sprite.scale

		get_tree().current_scene.add_child(ghost)

		# Fade out
		var tween = create_tween()
		tween.tween_property(ghost, "modulate:a", 0.0, AFTERIMAGE_FADE_DURATION)
		tween.tween_callback(_safe_free.bind(ghost))

# =============================================================================
# ENHANCED ENEMY DEATH EXPLOSION
# =============================================================================

## More dramatic death particles
func _create_death_explosion(pos: Vector2) -> void:
	# Burst of colored fragments
	for i in range(DEATH_PARTICLE_COUNT):
		var particle = ColorRect.new()
		particle.size = Vector2(
			randf_range(DEATH_PARTICLE_SIZE_MIN, DEATH_PARTICLE_SIZE_MAX),
			randf_range(DEATH_PARTICLE_SIZE_MIN, DEATH_PARTICLE_SIZE_MAX)
		)
		# Random warm colors (enemy guts lol)
		particle.color = DEATH_EXPLOSION_COLORS[randi() % DEATH_EXPLOSION_COLORS.size()]
		particle.global_position = pos
		particle.z_index = Z_DEATH_BURST
		get_tree().current_scene.add_child(particle)

		# Explode outward in random directions
		var angle = randf() * TAU
		var distance = randf_range(DEATH_DIST_MIN, DEATH_DIST_MAX)
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * distance

		var tween = create_tween()
		tween.set_parallel(true)
		# Arc upward then fall
		tween.tween_property(particle, "global_position:x", end_pos.x, DEATH_MOVE_X_DURATION).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "global_position:y", end_pos.y - DEATH_ARC_UP_Y, DEATH_ARC_UP_DURATION).set_ease(Tween.EASE_OUT)
		tween.chain().tween_property(particle, "global_position:y", end_pos.y + DEATH_ARC_DOWN_Y, DEATH_ARC_DOWN_DURATION).set_ease(Tween.EASE_IN)
		tween.tween_property(particle, "modulate:a", 0.0, DEATH_FADE_DURATION)
		tween.tween_callback(_safe_free.bind(particle))

# =============================================================================
# COMBAT JUICE - SPECIAL ABILITIES
# =============================================================================

## Ground pound impact - massive shockwave effect
func _on_ground_pound_impact(damage: int, radius: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var pos = player.global_position

	# Apply configured ground pound impact
	apply_attack_impact("ground_pound")
	# Heavy screen shake
	screen_shake(SHAKE_GROUND_POUND_INTENSITY, SHAKE_GROUND_POUND_DURATION)

	# Heavy hitstop
	hitstop_heavy()

	# Camera punch (zoom effect)
	camera_punch(CAMERA_PUNCH_GROUND_POUND_ZOOM, CAMERA_PUNCH_GROUND_POUND_DURATION)

	# Shockwave ring effect
	_create_shockwave(pos, radius)

	# Dust burst in all directions
	for i in range(GROUND_POUND_DUST_COUNT):
		var angle = i * TAU / GROUND_POUND_DUST_COUNT
		var dust_pos = pos + Vector2(cos(angle), sin(angle)) * GROUND_POUND_DUST_OFFSET
		spawn_dust(dust_pos, Vector2(cos(angle), sin(angle)))

	# Ground crack particles
	_create_ground_crack_particles(pos)

	# Screen flash
	_flash_screen(GROUND_POUND_FLASH_COLOR, GROUND_POUND_FLASH_DURATION)


## Create expanding shockwave ring
func _create_shockwave(pos: Vector2, radius: float) -> void:
	# Create multiple expanding rings
	for ring_idx in range(SHOCKWAVE_RING_COUNT):
		var ring = _create_ring_sprite(pos)
		var delay = ring_idx * SHOCKWAVE_RING_DELAY
		var target_scale = (radius / SHOCKWAVE_RADIUS_DIVISOR) * (1.0 + ring_idx * SHOCKWAVE_RING_SCALE_INCREMENT)

		var tween = create_tween()
		tween.tween_property(ring, "scale", Vector2(target_scale, target_scale), SHOCKWAVE_DURATION)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(delay)
		tween.parallel().tween_property(ring, "modulate:a", 0.0, SHOCKWAVE_DURATION).set_delay(delay)
		tween.tween_callback(_safe_free.bind(ring))


## Create a ring sprite for shockwave
func _create_ring_sprite(pos: Vector2) -> Node2D:
	# Use ColorRect as placeholder ring (circle approximation)
	var container = Node2D.new()
	container.global_position = pos
	container.z_index = Z_SHOCKWAVE
	get_tree().current_scene.add_child(container)

	# Create ring from multiple small rects
	for i in range(SHOCKWAVE_RING_SEGMENTS):
		var angle = i * TAU / SHOCKWAVE_RING_SEGMENTS
		var rect = ColorRect.new()
		rect.size = SHOCKWAVE_SEGMENT_SIZE
		rect.position = Vector2(cos(angle), sin(angle)) * SHOCKWAVE_SEGMENT_RADIUS - SHOCKWAVE_SEGMENT_OFFSET
		rect.color = SHOCKWAVE_COLOR
		container.add_child(rect)

	return container


## Create ground crack particle burst
func _create_ground_crack_particles(pos: Vector2) -> void:
	for i in range(GROUND_CRACK_COUNT):
		var particle = ColorRect.new()
		particle.size = GROUND_CRACK_SIZE
		particle.color = GROUND_CRACK_COLOR
		particle.global_position = pos
		particle.z_index = Z_GROUND
		get_tree().current_scene.add_child(particle)

		var angle = randf() * TAU
		var distance = randf_range(GROUND_CRACK_DIST_MIN, GROUND_CRACK_DIST_MAX)
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * distance

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, GROUND_CRACK_MOVE_DURATION)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, GROUND_CRACK_FADE_DURATION)
		tween.tween_callback(_safe_free.bind(particle))


## Charge attack started - show charging glow
func _on_charge_started() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Create charging glow effect
	charge_glow_node = _create_charge_glow(player)


func _create_charge_glow(target: Node2D) -> Node2D:
	var glow = Node2D.new()
	glow.name = "ChargeGlow"
	glow.z_index = Z_BEHIND_PLAYER
	target.add_child(glow)

	# Pulsing glow circle
	var circle = ColorRect.new()
	circle.size = CHARGE_GLOW_SIZE
	circle.position = CHARGE_GLOW_OFFSET
	circle.color = CHARGE_GLOW_COLOR
	glow.add_child(circle)

	# Animate pulsing
	var tween = create_tween().set_loops()
	tween.tween_property(circle, "scale", CHARGE_GLOW_PULSE_SCALE, CHARGE_GLOW_PULSE_DURATION)
	tween.tween_property(circle, "scale", Vector2(1.0, 1.0), CHARGE_GLOW_PULSE_DURATION)

	# Color shift as charge builds
	var color_tween = create_tween().set_loops()
	color_tween.tween_property(circle, "color", CHARGE_GLOW_INTENSE_COLOR, CHARGE_GLOW_COLOR_SHIFT_DURATION)
	color_tween.tween_property(circle, "color", CHARGE_GLOW_COLOR, CHARGE_GLOW_COLOR_SHIFT_DURATION)

	return glow


## Charge attack released - flash and effects
func _on_charge_released(damage: int, charge_percent: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Remove charge glow
	if charge_glow_node and is_instance_valid(charge_glow_node):
		charge_glow_node.queue_free()
		charge_glow_node = null

	# Scale effects based on charge percent (50% to 100% intensity)
	var intensity_multiplier = 0.5 + charge_percent * 0.5

	# Apply configured charge release impact scaled by charge amount
	apply_attack_impact("charge_release", intensity_multiplier)
	# Scale effects based on charge percent
	var intensity = CHARGE_INTENSITY_BASE + charge_percent * CHARGE_INTENSITY_SCALE

	# Screen shake scaled to charge
	screen_shake(SHAKE_CHARGE_BASE_INTENSITY * intensity, SHAKE_CHARGE_DURATION)

	# Hitstop for powerful charged hits
	if charge_percent > CHARGE_HEAVY_THRESHOLD:
		hitstop_heavy()
	else:
		hitstop_light()

	# Camera punch for fully charged
	if charge_percent > CHARGE_CAMERA_THRESHOLD:
		camera_punch(CAMERA_PUNCH_CHARGE_ZOOM, CAMERA_PUNCH_CHARGE_DURATION)

	# Release flash
	var flash_color = Color(CHARGE_FLASH_COLOR_BASE.r, CHARGE_FLASH_COLOR_BASE.g, CHARGE_FLASH_COLOR_BASE.b, CHARGE_FLASH_ALPHA_FACTOR * intensity)
	_flash_screen(flash_color, CHARGE_FLASH_DURATION)

	# Burst particles
	_create_charge_release_burst(player.global_position, charge_percent)


func _create_charge_release_burst(pos: Vector2, charge_percent: float) -> void:
	var particle_count = int(CHARGE_BURST_BASE_COUNT + charge_percent * CHARGE_BURST_SCALE_COUNT)

	for i in range(particle_count):
		var particle = ColorRect.new()
		var size_val = CHARGE_BURST_BASE_SIZE + charge_percent * CHARGE_BURST_SCALE_SIZE
		particle.size = Vector2(size_val, size_val)
		particle.color = CHARGE_BURST_COLOR
		particle.global_position = pos
		particle.z_index = Z_CHARGE_BURST
		get_tree().current_scene.add_child(particle)

		var angle = randf() * TAU
		var speed = randf_range(CHARGE_BURST_SPEED_MIN, CHARGE_BURST_SPEED_MAX) * (CHARGE_INTENSITY_BASE + charge_percent * CHARGE_INTENSITY_SCALE)
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * speed * CHARGE_BURST_SPEED_SCALE

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, CHARGE_BURST_MOVE_DURATION)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, CHARGE_BURST_FADE_DURATION)
		tween.tween_callback(_safe_free.bind(particle))


## Parry success - satisfying feedback
func _on_parry_success(attacker: Node, reflected_damage: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var pos = player.global_position

	# Apply configured parry impact
	apply_attack_impact("parry")
	# Medium screen shake
	screen_shake(SHAKE_PARRY_INTENSITY, SHAKE_PARRY_DURATION)

	# Hitstop for impact
	hitstop_heavy()

	# Blue parry flash
	_flash_screen(PARRY_FLASH_COLOR, PARRY_FLASH_DURATION)

	# Parry spark effect
	_create_parry_sparks(pos)

	# "PARRY!" text popup
	_create_parry_text(pos)

	# Camera punch
	camera_punch(CAMERA_PUNCH_PARRY_ZOOM, CAMERA_PUNCH_PARRY_DURATION)


func _create_parry_sparks(pos: Vector2) -> void:
	# Blue/white sparks radiating outward
	for i in range(PARRY_SPARK_COUNT):
		var spark = ColorRect.new()
		spark.size = PARRY_SPARK_SIZE
		spark.color = PARRY_SPARK_COLOR
		spark.global_position = pos
		spark.z_index = Z_PARRY_SPARKS
		spark.rotation = randf() * TAU
		get_tree().current_scene.add_child(spark)

		var angle = i * TAU / PARRY_SPARK_COUNT + randf_range(-PARRY_SPARK_ANGLE_JITTER, PARRY_SPARK_ANGLE_JITTER)
		var end_pos = pos + Vector2(cos(angle), sin(angle)) * randf_range(PARRY_SPARK_DIST_MIN, PARRY_SPARK_DIST_MAX)

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(spark, "global_position", end_pos, PARRY_SPARK_MOVE_DURATION)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(spark, "modulate:a", 0.0, PARRY_SPARK_FADE_DURATION)
		tween.tween_callback(_safe_free.bind(spark))


func _create_parry_text(pos: Vector2) -> void:
	var label = _create_styled_label(
		"PARRY!",
		PARRY_TEXT_FONT_SIZE,
		PARRY_TEXT_COLOR,
		PARRY_TEXT_OUTLINE_COLOR,
		PARRY_TEXT_OUTLINE_SIZE
	)
	label.global_position = pos + PARRY_TEXT_OFFSET
	label.z_index = Z_PARTICLES
	get_tree().current_scene.add_child(label)

	# Pop and float animation
	label.scale = PARRY_TEXT_INITIAL_SCALE
	var tween = create_tween()
	tween.tween_property(label, "scale", PARRY_TEXT_POP_SCALE, PARRY_TEXT_POP_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", PARRY_TEXT_SETTLE_SCALE, PARRY_TEXT_POP_DURATION)
	tween.parallel().tween_property(label, "global_position:y", pos.y + PARRY_TEXT_FLOAT_Y, PARRY_TEXT_FLOAT_DURATION)
	tween.tween_property(label, "modulate:a", 0.0, PARRY_TEXT_FADE_DURATION)
	tween.tween_callback(_safe_free.bind(label))


# =============================================================================
# CAMERA PUNCH (ZOOM EFFECT)
# =============================================================================

## Quick zoom in/out for impact feel
func camera_punch(zoom_amount: float = CAMERA_PUNCH_DEFAULT_ZOOM, duration: float = CAMERA_PUNCH_DEFAULT_DURATION) -> void:
	if camera_punch_active:
		return

	var player = get_tree().get_first_node_in_group("player")
	if not player or not player.has_node("Camera2D"):
		return

	var camera: Camera2D = player.get_node("Camera2D")
	var original_zoom = camera.zoom
	var punch_zoom = original_zoom * zoom_amount

	camera_punch_active = true

	var tween = create_tween()
	tween.tween_property(camera, "zoom", punch_zoom, duration * CAMERA_PUNCH_ZOOM_IN_RATIO)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(camera, "zoom", original_zoom, duration * CAMERA_PUNCH_ZOOM_OUT_RATIO)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func(): camera_punch_active = false)

# =============================================================================
# AMBIENT WORLD PARTICLES
# =============================================================================

## Spawn ambient particles for the current zone
func _on_zone_entered_particles(zone_name: String) -> void:
	# Remove old ambient particles
	if _ambient_particles and is_instance_valid(_ambient_particles):
		_ambient_particles.queue_free()

	# Create new ambient particles for this zone
	# NOTE: Must preload script since class_name isn't available in autoload scope
	var AmbientParticlesScript = preload("res://components/effects/ambient_particles.gd")
	_ambient_particles = AmbientParticlesScript.new()
	_ambient_particles.set_style_for_zone(zone_name)
	add_child(_ambient_particles)

# =============================================================================
# DAMAGE DIRECTION INDICATOR
# =============================================================================

## Show a brief red flash from the direction damage came from
func _create_damage_direction_indicator(player_node: Node2D) -> void:
	# Find nearest enemy to determine damage direction
	var nearest_enemy: Node2D = null
	var nearest_dist: float = INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var dist = player_node.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_enemy = enemy

	if nearest_enemy == null:
		# No enemy found, flash from random direction
		_spawn_directional_flash(randf() * TAU)
		return

	# Calculate angle from player to enemy (damage source direction)
	var direction = (nearest_enemy.global_position - player_node.global_position).normalized()
	var angle = direction.angle()
	_spawn_directional_flash(angle)


## Spawn a red flash bar on the screen edge from the given angle
func _spawn_directional_flash(angle: float) -> void:
	var center = VIEWPORT_SIZE / 2.0

	var canvas = _create_canvas_overlay(CANVAS_LAYER_DAMAGE_DIR)

	# Create a thin red bar positioned on the screen edge toward the angle
	var flash = ColorRect.new()
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Determine which edge of the screen the flash should appear on
	var dir = Vector2(cos(angle), sin(angle))

	if absf(dir.x) > absf(dir.y):
		# Left or right edge
		flash.size = Vector2(DAMAGE_DIR_BAR_THICKNESS, DAMAGE_DIR_BAR_LENGTH)
		flash.position.y = center.y - DAMAGE_DIR_BAR_LENGTH / 2.0
		if dir.x > 0:
			flash.position.x = VIEWPORT_SIZE.x - DAMAGE_DIR_BAR_THICKNESS  # Right edge
		else:
			flash.position.x = 0  # Left edge
	else:
		# Top or bottom edge
		flash.size = Vector2(DAMAGE_DIR_BAR_LENGTH, DAMAGE_DIR_BAR_THICKNESS)
		flash.position.x = center.x - DAMAGE_DIR_BAR_LENGTH / 2.0
		if dir.y > 0:
			flash.position.y = VIEWPORT_SIZE.y - DAMAGE_DIR_BAR_THICKNESS  # Bottom edge
		else:
			flash.position.y = 0  # Top edge

	flash.color = DAMAGE_DIR_COLOR
	canvas.add_child(flash)

	# Quick flash and fade
	var tween = create_tween()
	tween.tween_property(flash, "color:a", 0.0, DAMAGE_DIR_FADE_DURATION)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_callback(_safe_free.bind(canvas))

# =============================================================================
# BOSS INTRO & VICTORY (Phase P6)
# =============================================================================

## Dramatic boss intro sequence
func _on_boss_intro(boss: Node) -> void:
	if not is_instance_valid(boss):
		return

	# Slowmo entrance with smooth restore
	_tween_slowmo_restore(SLOWMO_BOSS_INTRO_SCALE, SLOWMO_BOSS_INTRO_PAUSE, SLOWMO_BOSS_INTRO_RESTORE)

	# Dark overlay flash
	_flash_screen(BOSS_INTRO_OVERLAY_COLOR, BOSS_INTRO_OVERLAY_DURATION)

	# Camera zoom in on boss
	camera_punch(CAMERA_PUNCH_BOSS_INTRO_ZOOM, CAMERA_PUNCH_BOSS_INTRO_DURATION)

	# Screen shake for weight
	screen_shake(SHAKE_BOSS_INTRO_INTENSITY, SHAKE_BOSS_INTRO_DURATION)

	# "BOSS!" title text
	_create_boss_title(boss)


func _create_boss_title(boss: Node) -> void:
	var canvas = _create_canvas_overlay(CANVAS_LAYER_BOSS_TITLE)

	# Boss name banner
	var label = _create_styled_label(
		"RACCOON KING",
		BOSS_NAME_FONT_SIZE,
		BOSS_NAME_COLOR,
		BOSS_NAME_OUTLINE_COLOR,
		BOSS_NAME_OUTLINE_SIZE
	)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(VIEWPORT_SIZE.x / 2 - BOSS_NAME_X_OFFSET, VIEWPORT_SIZE.y / 2 - BOSS_NAME_Y_OFFSET)
	label.pivot_offset = BOSS_NAME_PIVOT
	label.scale = BOSS_NAME_INITIAL_SCALE
	label.modulate.a = 0.0
	canvas.add_child(label)

	# Subtitle
	var subtitle = _create_styled_label(
		"Ruler of the Backyard",
		BOSS_SUBTITLE_FONT_SIZE,
		BOSS_SUBTITLE_COLOR,
		BOSS_SUBTITLE_OUTLINE_COLOR,
		BOSS_SUBTITLE_OUTLINE_SIZE
	)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(VIEWPORT_SIZE.x / 2 - BOSS_SUBTITLE_X_OFFSET, VIEWPORT_SIZE.y / 2 + BOSS_SUBTITLE_Y_OFFSET)
	subtitle.modulate.a = 0.0
	canvas.add_child(subtitle)

	# Animate: slam in, hold, fade out
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	# Name slams in
	_tween_slam_in(tween, label, BOSS_NAME_INITIAL_SCALE, BOSS_NAME_SLAM_DURATION)
	tween.parallel().tween_property(label, "modulate:a", 1.0, BOSS_NAME_FADE_IN_DURATION)
	# Subtitle fades in
	tween.tween_property(subtitle, "modulate:a", 1.0, BOSS_SUBTITLE_FADE_DURATION)
	# Hold
	tween.tween_interval(BOSS_TITLE_HOLD)
	# Fade out
	tween.tween_property(canvas, "modulate:a", 0.0, BOSS_TITLE_FADE_OUT)
	tween.tween_callback(_safe_free.bind(canvas))


## Boss victory celebration
func _on_boss_victory(boss: Node) -> void:
	# Dramatic slowmo with smooth restore
	_tween_slowmo_restore(SLOWMO_BOSS_VICTORY_SCALE, SLOWMO_BOSS_VICTORY_PAUSE, SLOWMO_BOSS_VICTORY_RESTORE)

	# Big screen shake
	screen_shake(SHAKE_BOSS_VICTORY_INTENSITY, SHAKE_BOSS_VICTORY_DURATION)

	# White flash
	_flash_screen(VICTORY_FLASH_COLOR, VICTORY_FLASH_DURATION)

	# "VICTORY!" text
	_create_victory_text()

	# Firework particles
	_create_victory_fireworks()


func _create_victory_text() -> void:
	var canvas = _create_canvas_overlay(CANVAS_LAYER_VICTORY)

	var label = _create_styled_label(
		"VICTORY!",
		VICTORY_FONT_SIZE,
		VICTORY_TEXT_COLOR,
		VICTORY_OUTLINE_COLOR,
		VICTORY_OUTLINE_SIZE
	)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(VIEWPORT_SIZE.x / 2 - VICTORY_X_OFFSET, VIEWPORT_SIZE.y / 2 - VICTORY_Y_OFFSET)
	label.pivot_offset = VICTORY_PIVOT
	label.scale = VICTORY_INITIAL_SCALE
	canvas.add_child(label)

	# Slam in and hold
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	_tween_slam_in(tween, label, VICTORY_INITIAL_SCALE, VICTORY_SLAM_DURATION)
	tween.tween_interval(VICTORY_HOLD)
	tween.tween_property(label, "global_position:y", label.global_position.y - VICTORY_FLOAT_Y, VICTORY_FADE_DURATION)
	tween.parallel().tween_property(canvas, "modulate:a", 0.0, VICTORY_FADE_DURATION)
	tween.tween_callback(_safe_free.bind(canvas))


func _create_victory_fireworks() -> void:
	# Burst of gold particles from boss position
	var player = get_tree().get_first_node_in_group("player")
	var center = player.global_position if player else VIEWPORT_CENTER

	# 3 waves of firework bursts
	for wave in range(FIREWORK_WAVE_COUNT):
		await get_tree().create_timer(FIREWORK_WAVE_DELAY * wave).timeout
		if not is_instance_valid(get_tree().current_scene):
			return

		var burst_pos = center + Vector2(
			randf_range(-FIREWORK_X_SPREAD, FIREWORK_X_SPREAD),
			randf_range(FIREWORK_Y_SPREAD_MIN, FIREWORK_Y_SPREAD_MAX)
		)
		for i in range(FIREWORK_PARTICLE_COUNT):
			var particle = ColorRect.new()
			particle.size = FIREWORK_PARTICLE_SIZE
			# Gold / red / white mix
			particle.color = FIREWORK_COLORS[randi() % FIREWORK_COLORS.size()]
			particle.global_position = burst_pos
			particle.z_index = Z_PARTICLES
			get_tree().current_scene.add_child(particle)

			var angle = randf() * TAU
			var dist = randf_range(FIREWORK_DIST_MIN, FIREWORK_DIST_MAX)
			var end_pos = burst_pos + Vector2(cos(angle), sin(angle)) * dist

			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(particle, "global_position", end_pos, FIREWORK_MOVE_DURATION)\
				.set_ease(Tween.EASE_OUT)
			# Arc: go up then fall
			tween.tween_property(particle, "global_position:y", end_pos.y - FIREWORK_ARC_UP, FIREWORK_ARC_UP_DURATION)\
				.set_ease(Tween.EASE_OUT)
			tween.chain().tween_property(particle, "global_position:y", end_pos.y + FIREWORK_ARC_DOWN, FIREWORK_ARC_DOWN_DURATION)\
				.set_ease(Tween.EASE_IN)
			tween.tween_property(particle, "modulate:a", 0.0, FIREWORK_FADE_DURATION).set_delay(FIREWORK_FADE_DELAY)
			tween.chain().tween_callback(_safe_free.bind(particle))
