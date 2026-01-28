extends Control
class_name TitleScreen
## Main title screen with continue and new game options.

@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var confirm_dialog: ConfirmationDialog = $ConfirmationDialog

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	confirm_dialog.confirmed.connect(_on_new_game_confirmed)
	
	# Update button visibility based on save state
	_update_buttons()
	
	# Connect focus signals for navigation sounds
	continue_button.focus_entered.connect(_on_button_focused)
	start_button.focus_entered.connect(_on_button_focused)
	quit_button.focus_entered.connect(_on_button_focused)
	
	# Play title music
	AudioManager.play_music("title", false)


func _update_buttons() -> void:
	if SaveManager.has_save():
		continue_button.visible = true
		start_button.text = "New Game"
		continue_button.grab_focus()
	else:
		continue_button.visible = false
		start_button.text = "Start Game"
		start_button.grab_focus()


func _on_button_focused() -> void:
	AudioManager.play_sfx("menu_navigate")


func _on_continue_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	# Load saved game
	if not SaveManager.load_game():
		# If load fails, show error and stay on title
		push_error("Failed to load save game")
		_update_buttons()


func _on_start_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	if SaveManager.has_save():
		# Show confirmation dialog
		confirm_dialog.dialog_text = "This will overwrite your saved progress.\nContinue?"
		confirm_dialog.popup_centered()
	else:
		_start_new_game()


func _on_new_game_confirmed() -> void:
	SaveManager.delete_save()
	_start_new_game()


func _start_new_game() -> void:
	# Reset game state
	GameManager.coins = 0
	GameManager.boss_defeated = false
	get_tree().change_scene_to_file("res://world/zones/neighborhood.tscn")


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	get_tree().quit()
