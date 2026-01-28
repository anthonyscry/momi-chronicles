extends CanvasLayer
class_name PauseMenu
## Pause menu with resume, audio controls, and quit options.

@onready var overlay: ColorRect = $Overlay
@onready var panel: Panel = $Panel
@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var save_button: Button = $Panel/VBoxContainer/SaveButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton
@onready var music_slider: HSlider = $Panel/VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/SFXContainer/SFXSlider

var panel_start_y: float = 0.0

func _ready() -> void:
	# Start hidden
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Store original position
	panel_start_y = panel.position.y
	
	# Connect buttons
	resume_button.pressed.connect(_on_resume_pressed)
	save_button.pressed.connect(_on_save_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect focus for sounds
	resume_button.focus_entered.connect(_on_button_focused)
	save_button.focus_entered.connect(_on_button_focused)
	quit_button.focus_entered.connect(_on_button_focused)
	
	# Connect sliders
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	# Connect to game events
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)


func _on_button_focused() -> void:
	AudioManager.play_sfx("menu_navigate")


func _on_game_paused() -> void:
	# Don't show pause menu if ring menu is open (it has its own pause)
	if RingMenu and RingMenu.is_open:
		return
	
	# Update sliders to current values
	music_slider.value = AudioManager.get_music_volume()
	sfx_slider.value = AudioManager.get_sfx_volume()
	
	show()
	_animate_in()
	resume_button.grab_focus()


func _on_game_resumed() -> void:
	# Save audio settings when closing menu
	AudioManager.save_settings()
	_animate_out()


func _animate_in() -> void:
	# Fade in overlay
	overlay.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.15)
	
	# Slide panel down from above
	panel.position.y = panel_start_y - 30
	panel.modulate.a = 0.0
	tween.parallel().tween_property(panel, "position:y", panel_start_y, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.15)


func _animate_out() -> void:
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.1)
	tween.parallel().tween_property(panel, "position:y", panel_start_y - 20, 0.1).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.1)
	tween.tween_callback(hide)


func _on_resume_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	GameManager.resume_game()


func _on_save_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	if SaveManager.save_game():
		# Visual feedback - flash button text briefly
		var original_text = save_button.text
		save_button.text = "Saved!"
		save_button.disabled = true
		await get_tree().create_timer(1.0).timeout
		save_button.text = original_text
		save_button.disabled = false
	else:
		save_button.text = "Save Failed"
		await get_tree().create_timer(1.0).timeout
		save_button.text = "Save Game"


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
