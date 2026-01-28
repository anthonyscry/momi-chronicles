extends Control
class_name TitleScreen
## Main title screen with continue and new game options.

@onready var title_label: Label = $ContentContainer/TitleContainer/Title
@onready var continue_button: Button = $ContentContainer/ButtonContainer/ContinueButton
@onready var start_button: Button = $ContentContainer/ButtonContainer/StartButton
@onready var quit_button: Button = $ContentContainer/ButtonContainer/QuitButton
@onready var confirm_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var content_container: VBoxContainer = $ContentContainer

var title_tween: Tween

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
	
	# Start animations
	_animate_intro()
	_animate_title_glow()


func _animate_intro() -> void:
	# Fade in the whole screen
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Slide in content from above
	content_container.position.y -= 20
	tween.parallel().tween_property(content_container, "position:y", content_container.position.y + 20, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _animate_title_glow() -> void:
	# Subtle pulsing glow on title
	title_tween = create_tween().set_loops()
	title_tween.tween_property(title_label, "modulate", Color(1.2, 1.2, 1.0, 1.0), 1.5).set_ease(Tween.EASE_IN_OUT)
	title_tween.tween_property(title_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.5).set_ease(Tween.EASE_IN_OUT)


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
	_fade_out_and_load()


func _fade_out_and_load() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_do_load_game)


func _do_load_game() -> void:
	if not SaveManager.load_game():
		# If load fails, show error and stay on title
		push_error("Failed to load save game")
		modulate.a = 1.0
		_update_buttons()


func _on_start_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	if SaveManager.has_save():
		# Show confirmation dialog
		confirm_dialog.dialog_text = "This will overwrite your saved progress.\nContinue?"
		confirm_dialog.popup_centered()
	else:
		_fade_out_and_start()


func _on_new_game_confirmed() -> void:
	SaveManager.delete_save()
	_fade_out_and_start()


func _fade_out_and_start() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(_start_new_game)


func _start_new_game() -> void:
	# Reset game state
	GameManager.coins = 0
	GameManager.boss_defeated = false
	get_tree().change_scene_to_file("res://world/zones/neighborhood.tscn")


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(get_tree().quit)
