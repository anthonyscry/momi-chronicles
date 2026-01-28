extends CanvasLayer
class_name GameOverScreen
## Game over screen shown when player dies.

@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect buttons
	retry_button.pressed.connect(_on_retry_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect focus signals for navigation sounds
	retry_button.focus_entered.connect(_on_button_focused)
	quit_button.focus_entered.connect(_on_button_focused)
	
	# Connect to game over event
	Events.game_over.connect(_on_game_over)


func _on_button_focused() -> void:
	AudioManager.play_sfx("menu_navigate")


func _on_game_over() -> void:
	# Game over music is triggered by AudioManager via Events.game_over signal
	# Small delay before showing
	await get_tree().create_timer(0.5).timeout
	show()
	get_tree().paused = true
	retry_button.grab_focus()


func _on_retry_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	hide()
	GameManager.restart_game()


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	GameManager.quit_game()
