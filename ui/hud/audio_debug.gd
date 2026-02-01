extends CanvasLayer
class_name AudioDebugUI
## Shows current audio track and A/B version. Press F2 to toggle.

@onready var label: Label = $Panel/Label

var visible_timer: float = 0.0
const SHOW_DURATION: float = 4.0


func _ready() -> void:
	# Hide in release builds
	if not DebugConfig.show_debug_ui:
		visible = false
		return

	# Start hidden
	$Panel.modulate.a = 0.0

	# Connect to AudioManager version changes
	AudioManager.version_changed.connect(_on_version_changed)

	# Show initial state after a short delay
	await get_tree().create_timer(0.5).timeout
	_update_display()
	_show_briefly()


func _process(delta: float) -> void:
	if visible_timer > 0:
		visible_timer -= delta
		if visible_timer <= 0:
			_fade_out()


func _on_version_changed(track_name: String, version: String) -> void:
	_update_display()
	_show_briefly()


func _update_display() -> void:
	var info = AudioManager.get_current_track_info()
	if info.track.is_empty():
		label.text = "No music playing"
	elif info.has_ab:
		label.text = "♪ %s [%s]\nF2 = Switch A/B" % [info.track.to_upper(), info.version]
	else:
		label.text = "♪ %s" % info.track.to_upper()


func _show_briefly() -> void:
	visible_timer = SHOW_DURATION
	var tween = create_tween()
	tween.tween_property($Panel, "modulate:a", 1.0, 0.2)


func _fade_out() -> void:
	var tween = create_tween()
	tween.tween_property($Panel, "modulate:a", 0.0, 0.5)


func _unhandled_input(event: InputEvent) -> void:
	# F2 toggle only works in debug builds (show_debug_ui check in _ready ensures this)
	# Show UI when F2 is pressed (AudioManager handles the toggle)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		# Update display after a tiny delay to let AudioManager process first
		await get_tree().create_timer(0.05).timeout
		_update_display()
		_show_briefly()
