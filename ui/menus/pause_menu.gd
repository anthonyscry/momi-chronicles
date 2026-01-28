extends CanvasLayer
class_name PauseMenu
## Pause menu with resume, audio controls, and quit options.

@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton
@onready var music_slider: HSlider = $Panel/VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/SFXContainer/SFXSlider

func _ready() -> void:
	# Start hidden
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect buttons
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect sliders
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Connect to game events
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)


func _on_game_paused() -> void:
	# Update sliders to current values
	music_slider.value = AudioManager.get_music_volume()
	sfx_slider.value = AudioManager.get_sfx_volume()
	
	show()
	resume_button.grab_focus()


func _on_game_resumed() -> void:
	# Save audio settings when closing menu
	AudioManager.save_settings()
	hide()


func _on_resume_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	GameManager.resume_game()


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	AudioManager.save_settings()
	GameManager.quit_game()


func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value)


func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	# Play a test sound so user can hear the new volume
	AudioManager.play_sfx("menu_navigate")
