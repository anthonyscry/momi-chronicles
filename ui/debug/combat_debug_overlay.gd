extends CanvasLayer
class_name CombatDebugOverlay
## Combat debugging overlay for monitoring frame data and input timing.
## F4 toggles visibility.

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var debug_panel: PanelContainer = $DebugPanel
@onready var debug_text: Label = $DebugPanel/MarginContainer/DebugText

# =============================================================================
# STATE
# =============================================================================

## Whether debug overlay is visible
var debug_visible: bool = false

## Player reference
var player: Player = null

## Input timing tracking
var last_input_time: float = 0.0
var last_action_time: float = 0.0
var measured_latency: float = 0.0

## Frame counter for measuring
var frame_count: int = 0

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Hidden by default
	visible = false
	debug_visible = false

	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	# Connect to combat signals for timing measurements
	Events.player_attacked.connect(_on_player_action)
	Events.player_dodged.connect(_on_player_action)
	Events.player_special_attacked.connect(_on_player_action)
	Events.player_block_started.connect(_on_player_action)


func _unhandled_input(event: InputEvent) -> void:
	# F4 toggles debug overlay
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F4:
			debug_visible = not debug_visible
			visible = debug_visible
			DebugLogger.log_ui("Combat Debug Overlay: %s (F4 to toggle)" % ("ON" if debug_visible else "OFF"))

	# Track input timing for latency measurement
	if debug_visible and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_J, KEY_K, KEY_L, KEY_SPACE]:
			last_input_time = Time.get_ticks_msec() / 1000.0


func _process(_delta: float) -> void:
	if not debug_visible or not visible:
		return

	frame_count += 1
	_update_debug_display()

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_player_action() -> void:
	if debug_visible:
		last_action_time = Time.get_ticks_msec() / 1000.0
		if last_input_time > 0:
			measured_latency = (last_action_time - last_input_time) * 1000.0  # Convert to ms

# =============================================================================
# DEBUG DISPLAY
# =============================================================================

func _update_debug_display() -> void:
	if not player or not debug_text:
		return

	var lines: Array[String] = []

	# Header
	lines.append("=== COMBAT DEBUG (F4) ===")
	lines.append("")

	# Input Latency
	var latency_color = "green" if measured_latency < 33.0 else "yellow" if measured_latency < 50.0 else "red"
	lines.append("[color=%s]Input Latency: %.1fms[/color]" % [latency_color, measured_latency])
	var frames_latency = measured_latency / 16.67  # At 60 FPS, 1 frame = 16.67ms
	lines.append("  (%.1f frames @ 60 FPS)" % frames_latency)
	lines.append("")

	# Current State
	var state_name = "NONE"
	if player.state_machine and player.state_machine.current_state:
		state_name = player.state_machine.current_state.name
	lines.append("Current State: [color=cyan]%s[/color]" % state_name)

	# Active Frame (if in combat state)
	var frame_info = _get_frame_info()
	if frame_info:
		lines.append("Active Frame: [color=yellow]%s[/color]" % frame_info)
	lines.append("")

	# Hitbox/Hurtbox Status
	lines.append("Hit/Hurtbox Status:")

	# Player hitbox
	if player.hitbox:
		var hitbox_active = player.hitbox.monitoring
		var hitbox_color = "red" if hitbox_active else "gray"
		lines.append("  Hitbox: [color=%s]%s[/color]" % [hitbox_color, "ACTIVE" if hitbox_active else "INACTIVE"])

	# Player hurtbox & i-frames
	if player.hurtbox:
		var iframe_status = _get_iframe_status()
		lines.append("  Hurtbox: %s" % iframe_status)
	lines.append("")

	# Combo Status
	var combo_info = _get_combo_info()
	lines.append("Combo: %s" % combo_info)
	lines.append("")

	# Performance
	lines.append("Frame: %d | FPS: %d" % [frame_count, Engine.get_frames_per_second()])

	# Combine and set
	debug_text.text = "\n".join(lines)


## Get current frame info from animation or state timer
func _get_frame_info() -> String:
	if not player or not player.animation_player:
		return ""

	if not player.animation_player.is_playing():
		return "N/A"

	var anim_name = player.animation_player.current_animation
	var anim_pos = player.animation_player.current_animation_position
	var anim_length = player.animation_player.current_animation_length

	if anim_length > 0:
		var progress_pct = (anim_pos / anim_length) * 100.0
		return "%s (%.0f%%)" % [anim_name, progress_pct]

	return anim_name


## Get i-frame countdown status
func _get_iframe_status() -> String:
	if not player or not player.hurtbox:
		return "[color=gray]N/A[/color]"

	if player.hurtbox.is_invincible:
		var time_left = player.hurtbox._invincibility_timer
		return "[color=lime]I-FRAMES (%.2fs)[/color]" % time_left
	else:
		return "[color=white]VULNERABLE[/color]"


## Get combo timing and count
func _get_combo_info() -> String:
	if not player:
		return "N/A"

	var combo_count = player.current_combo_count

	if combo_count == 0:
		return "[color=gray]None[/color]"

	var combo_color = "white"
	if combo_count == 1:
		combo_color = "white"
	elif combo_count == 2:
		combo_color = "yellow"
	elif combo_count >= 3:
		combo_color = "orange"

	return "[color=%s]%d Hit%s[/color]" % [combo_color, combo_count, "s" if combo_count > 1 else ""]
