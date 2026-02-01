extends CanvasLayer
class_name PauseMenu
## Pause menu overlay with tabs for quest log and other pause menu features.
## Press ESC to open/close. Pauses game tree when visible.

## Container for tab content
@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var tab_container: TabContainer = $CenterContainer/PanelContainer/MarginContainer/TabContainer
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/TabContainer/General/VBoxContainer/ResumeButton

## Whether menu is currently visible
var is_paused: bool = false


func _ready() -> void:
	# Hide menu by default
	visible = false
	is_paused = false

	# Set process mode to always process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect resume button
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)


func _unhandled_input(event: InputEvent) -> void:
	# Toggle pause menu with ESC key
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	is_paused = not is_paused

	if is_paused:
		_open_menu()
	else:
		_close_menu()


func _open_menu() -> void:
	visible = true
	is_paused = true
	get_tree().paused = true

	# Focus resume button for keyboard navigation
	if resume_button:
		resume_button.grab_focus()


func _close_menu() -> void:
	visible = false
	is_paused = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	_close_menu()
