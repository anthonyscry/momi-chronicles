extends Control
class_name TitleScreen
## Main title screen with start game option.

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()
	
	# Connect focus signals for navigation sounds
	start_button.focus_entered.connect(_on_button_focused)
	quit_button.focus_entered.connect(_on_button_focused)
	
	# Play title music
	AudioManager.play_music("title", false)


func _on_button_focused() -> void:
	AudioManager.play_sfx("menu_navigate")


func _on_start_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	get_tree().change_scene_to_file("res://world/zones/neighborhood.tscn")


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	get_tree().quit()
