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

## Save corruption state
var _save_is_corrupted: bool = false

## Warning UI elements (created programmatically)
var _corrupt_warning_label: Label = null

func _ready() -> void:
	# Connect save_corrupted BEFORE any load attempt can fire
	Events.save_corrupted.connect(_on_save_corrupted)
	
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


func _on_save_corrupted() -> void:
	_save_is_corrupted = true


func _do_load_game() -> void:
	if not SaveManager.load_game():
		# Load failed — stay on title
		push_error("Failed to load save game")
		modulate.a = 1.0
		_update_buttons()
		
		if _save_is_corrupted:
			_show_corrupt_save_warning()
			_save_is_corrupted = false


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


# =============================================================================
# CORRUPT SAVE HANDLING
# =============================================================================

func _show_corrupt_save_warning() -> void:
	# Remove any previous warning
	if _corrupt_warning_label and is_instance_valid(_corrupt_warning_label):
		_corrupt_warning_label.queue_free()
	
	# Create red warning label
	_corrupt_warning_label = Label.new()
	_corrupt_warning_label.name = "CorruptWarning"
	_corrupt_warning_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	_corrupt_warning_label.add_theme_color_override("font_outline_color", Color(0.2, 0, 0))
	_corrupt_warning_label.add_theme_constant_override("outline_size", 1)
	_corrupt_warning_label.add_theme_font_size_override("font_size", 9)
	_corrupt_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_corrupt_warning_label.anchors_preset = Control.PRESET_CENTER_TOP
	_corrupt_warning_label.position = Vector2(-120, 20)
	_corrupt_warning_label.size = Vector2(240, 40)
	_corrupt_warning_label.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_corrupt_warning_label)
	
	# Check if backup exists
	var has_backup = FileAccess.file_exists(SaveManager.BACKUP_PATH)
	
	if has_backup:
		_corrupt_warning_label.text = "Save corrupted. Backup found — restore?"
		# Use ConfirmationDialog for restore/fresh choice
		confirm_dialog.dialog_text = "Restore from backup save?\n\n[Yes] = Restore backup\n[No] = Start fresh (delete save)"
		confirm_dialog.ok_button_text = "Restore Backup"
		confirm_dialog.cancel_button_text = "Start Fresh"
		
		# Disconnect previous signals to avoid stacking
		if confirm_dialog.confirmed.is_connected(_on_new_game_confirmed):
			confirm_dialog.confirmed.disconnect(_on_new_game_confirmed)
		if confirm_dialog.canceled.is_connected(_on_corrupt_start_fresh):
			confirm_dialog.canceled.disconnect(_on_corrupt_start_fresh)
		
		confirm_dialog.confirmed.connect(_on_corrupt_restore_backup, CONNECT_ONE_SHOT)
		confirm_dialog.canceled.connect(_on_corrupt_start_fresh, CONNECT_ONE_SHOT)
		confirm_dialog.popup_centered()
	else:
		_corrupt_warning_label.text = "Save corrupted. Start fresh?"
		# Only Start Fresh option via dialog
		confirm_dialog.dialog_text = "Save file is corrupted and no backup exists.\nStart a new game?"
		confirm_dialog.ok_button_text = "Start Fresh"
		confirm_dialog.cancel_button_text = "Cancel"
		
		# Disconnect previous signals to avoid stacking
		if confirm_dialog.confirmed.is_connected(_on_new_game_confirmed):
			confirm_dialog.confirmed.disconnect(_on_new_game_confirmed)
		
		confirm_dialog.confirmed.connect(_on_corrupt_start_fresh, CONNECT_ONE_SHOT)
		confirm_dialog.popup_centered()


func _on_corrupt_restore_backup() -> void:
	# Copy backup to main save path
	if FileAccess.file_exists(SaveManager.BACKUP_PATH):
		if FileAccess.file_exists(SaveManager.SAVE_PATH):
			DirAccess.remove_absolute(SaveManager.SAVE_PATH)
		DirAccess.copy_absolute(SaveManager.BACKUP_PATH, SaveManager.SAVE_PATH)
	
	# Clear warning
	_clear_corrupt_warning()
	
	# Re-connect the new game confirmed handler
	if not confirm_dialog.confirmed.is_connected(_on_new_game_confirmed):
		confirm_dialog.confirmed.connect(_on_new_game_confirmed)
	
	# Reset dialog button text
	confirm_dialog.ok_button_text = "Yes"
	confirm_dialog.cancel_button_text = "No"
	
	# Show brief "Restored from backup" feedback before retrying load
	_show_restore_success_note()
	
	# Retry load after brief delay
	await get_tree().create_timer(0.5).timeout
	_fade_out_and_load()


func _on_corrupt_start_fresh() -> void:
	# Clear warning
	_clear_corrupt_warning()
	
	# Re-connect the new game confirmed handler
	if not confirm_dialog.confirmed.is_connected(_on_new_game_confirmed):
		confirm_dialog.confirmed.connect(_on_new_game_confirmed)
	
	# Reset dialog button text
	confirm_dialog.ok_button_text = "Yes"
	confirm_dialog.cancel_button_text = "No"
	
	# Delete corrupted save and start new game
	SaveManager.delete_save()
	_fade_out_and_start()


func _clear_corrupt_warning() -> void:
	if _corrupt_warning_label and is_instance_valid(_corrupt_warning_label):
		_corrupt_warning_label.queue_free()
		_corrupt_warning_label = null


func _show_restore_success_note() -> void:
	var note = Label.new()
	note.name = "RestoreNote"
	note.text = "Restored from backup"
	note.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	note.add_theme_color_override("font_outline_color", Color(0, 0.2, 0))
	note.add_theme_constant_override("outline_size", 1)
	note.add_theme_font_size_override("font_size", 9)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.anchors_preset = Control.PRESET_CENTER_TOP
	note.position = Vector2(-100, 40)
	note.size = Vector2(200, 20)
	note.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(note)
	
	# Fade out after 2 seconds
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(note, "modulate:a", 0.0, 0.5)
	tween.tween_callback(note.queue_free)
