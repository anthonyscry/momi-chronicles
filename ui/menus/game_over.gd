extends CanvasLayer
class_name GameOverScreen
## Game over screen shown when player dies.

@onready var overlay: ColorRect = $Overlay
@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel
@onready var level_label: Label = $Panel/VBoxContainer/StatsContainer/LevelLabel
@onready var coins_label: Label = $Panel/VBoxContainer/StatsContainer/CoinsLabel
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
	# Update stats display
	_update_stats()
	
	# Small delay before showing
	await get_tree().create_timer(0.5).timeout
	
	show()
	_animate_in()
	
	get_tree().paused = true
	
	# Delay focus grab until animation completes
	await get_tree().create_timer(0.4).timeout
	retry_button.grab_focus()


func _update_stats() -> void:
	# Get player level from progression
	var player_level = 1
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("Progression"):
		player_level = player.get_node("Progression").current_level
	
	level_label.text = "Level Reached: %d" % player_level
	coins_label.text = "Coins: %d" % GameManager.coins


func _animate_in() -> void:
	# Dramatic fade in
	overlay.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	
	var tween = create_tween()
	
	# Slow fade in of red overlay
	tween.tween_property(overlay, "modulate:a", 1.0, 0.4)
	
	# Panel scales up and fades in
	tween.parallel().tween_property(panel, "modulate:a", 1.0, 0.3).set_delay(0.2)
	tween.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Title shake effect
	tween.tween_callback(_shake_title)


func _shake_title() -> void:
	var tween = create_tween()
	var original_pos = title_label.position
	for i in 3:
		tween.tween_property(title_label, "position:x", original_pos.x + 2, 0.03)
		tween.tween_property(title_label, "position:x", original_pos.x - 2, 0.03)
	tween.tween_property(title_label, "position:x", original_pos.x, 0.03)


func _on_retry_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	_animate_out_and_retry()


func _animate_out_and_retry() -> void:
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.15)
	tween.tween_callback(_do_retry)


func _do_retry() -> void:
	hide()
	GameManager.restart_game()


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("menu_select")
	_animate_out_and_quit()


func _animate_out_and_quit() -> void:
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.2)
	tween.parallel().tween_property(panel, "modulate:a", 0.0, 0.15)
	tween.tween_callback(GameManager.quit_game)
