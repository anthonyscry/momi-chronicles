extends CanvasLayer
class_name GameHUD
## Main game HUD containing health bar and debug info.

@onready var health_bar: HealthBar = $MarginContainer/VBoxContainer/HealthBar

## Low HP vignette overlay
var low_hp_vignette: ColorRect
var vignette_tween: Tween
var is_low_hp: bool = false
const LOW_HP_THRESHOLD: float = 0.25

## Buff status icons
var buff_icons = null  # BuffIcons instance (preloaded to avoid scope issues)

## Save indicator
var save_indicator: Label

## Tutorial prompt overlay
var tutorial_prompt = null  # TutorialPrompt instance

## Quest objective tracker (top-right corner)
var quest_tracker = null

## Quest reward notification
var reward_popup: Label = null

## Boss reward popup
var boss_reward_popup: Control = null

func _ready() -> void:
	# Create low HP vignette overlay
	_setup_low_hp_vignette()
	
	# Create buff icons display
	_setup_buff_icons()
	
	# Create save indicator
	_setup_save_indicator()

	# Create tutorial prompt overlay
	_setup_tutorial_prompt()

	# Create quest tracker (top-right)
	_setup_quest_tracker()

	# Create quest reward notification
	_setup_reward_popup()

	# Create boss reward popup
	_setup_boss_reward_popup()

	# Connect to health changes
	Events.player_health_changed.connect(_on_health_changed)
	
	# Connect to save events
	Events.game_saved.connect(_on_game_saved)
	
	# Connect to game_loaded to refresh all HUD elements after loading a save
	Events.game_loaded.connect(_on_game_loaded)



func _setup_save_indicator() -> void:
	save_indicator = Label.new()
	save_indicator.name = "SaveIndicator"
	save_indicator.text = "SAVING..."
	save_indicator.add_theme_font_size_override("font_size", 7)
	save_indicator.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 0.8))
	save_indicator.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	save_indicator.add_theme_constant_override("outline_size", 1)
	# Bottom-right corner
	save_indicator.position = Vector2(320, 200)
	save_indicator.modulate.a = 0.0
	add_child(save_indicator)


func _on_game_saved() -> void:
	if not save_indicator:
		return
	# Brief flash: fade in, hold, fade out
	var tween = create_tween()
	tween.tween_property(save_indicator, "modulate:a", 1.0, 0.15)
	tween.tween_interval(1.0)
	tween.tween_property(save_indicator, "modulate:a", 0.0, 0.4)


func _on_game_loaded() -> void:
	# Wait for player to spawn after zone load (same pattern as save_manager)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Refresh health bar
	var health_comp = player.get_node_or_null("HealthComponent")
	if health_comp:
		Events.player_health_changed.emit(health_comp.current_health, health_comp.max_health)
	
	# Refresh coin counter
	Events.coins_changed.emit(GameManager.coins)
	
	# Refresh EXP bar and level display
	var progression = player.get_node_or_null("ProgressionComponent")
	if progression:
		Events.exp_gained.emit(0, progression.current_level, progression.get_exp_progress(), progression.get_exp_to_next_level())
		Events.player_leveled_up.emit(progression.current_level)
	
	# Refresh guard bar
	var guard_comp = player.get_node_or_null("GuardComponent")
	if guard_comp:
		Events.guard_changed.emit(guard_comp.current_guard, guard_comp.max_guard)


func _setup_buff_icons() -> void:
	var BuffIconsScript = preload("res://ui/hud/buff_icons.gd")
	buff_icons = BuffIconsScript.new()
	buff_icons.name = "BuffIcons"
	# Position bottom-left below health bar
	buff_icons.position = Vector2(8, 60)
	add_child(buff_icons)


func _setup_tutorial_prompt() -> void:
	var prompt_scene = preload("res://ui/tutorial/tutorial_prompt.tscn")
	tutorial_prompt = prompt_scene.instantiate()
	tutorial_prompt.name = "TutorialPrompt"
	# Center screen overlay
	add_child(tutorial_prompt)


func _setup_quest_tracker() -> void:
	var tracker_scene = preload("res://ui/quest/quest_tracker.tscn")
	quest_tracker = tracker_scene.instantiate()
	quest_tracker.name = "QuestTracker"
	add_child(quest_tracker)


func _setup_reward_popup() -> void:
	reward_popup = Label.new()
	reward_popup.name = "RewardPopup"
	reward_popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	reward_popup.add_theme_font_size_override("font_size", 10)
	reward_popup.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
	reward_popup.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	reward_popup.add_theme_constant_override("outline_size", 2)
	# Center of screen, slightly above middle
	reward_popup.position = Vector2(92, 80)
	reward_popup.size = Vector2(200, 40)
	reward_popup.modulate.a = 0.0
	reward_popup.z_index = 10
	add_child(reward_popup)

	# Connect to quest completion
	Events.quest_completed.connect(_on_quest_completed_reward)


func _setup_boss_reward_popup() -> void:
	var popup_scene = preload("res://ui/boss/boss_reward_popup.tscn")
	boss_reward_popup = popup_scene.instantiate()
	boss_reward_popup.name = "BossRewardPopup"
	add_child(boss_reward_popup)


func _on_quest_completed_reward(quest_id: String) -> void:
	if not reward_popup:
		return
	# Build reward text from quest data
	if not has_node("/root/QuestManager"):
		return
	var quest_data = QuestManager.available_quests.get(quest_id, null)
	if not quest_data:
		return
	var rewards = quest_data.rewards
	var parts: Array = ["Quest Complete!"]
	if rewards.has("coins") and rewards["coins"] > 0:
		parts.append("+%d Coins" % rewards["coins"])
	if rewards.has("exp") and rewards["exp"] > 0:
		parts.append("+%d EXP" % rewards["exp"])
	reward_popup.text = " ".join(parts)

	# Animate: slide up + fade in, hold, fade out
	var tween = create_tween()
	reward_popup.position.y = 90
	reward_popup.modulate.a = 0.0
	tween.tween_property(reward_popup, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(reward_popup, "position:y", 75, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(reward_popup, "modulate:a", 0.0, 0.5)


func _setup_low_hp_vignette() -> void:
	# Red vignette overlay for when HP is low
	low_hp_vignette = ColorRect.new()
	low_hp_vignette.name = "LowHPVignette"
	low_hp_vignette.color = Color(0.8, 0, 0, 0)  # Transparent red initially
	low_hp_vignette.anchors_preset = Control.PRESET_FULL_RECT
	low_hp_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	low_hp_vignette.show_behind_parent = true
	# Use a gradient-like effect: full color at edges, transparent center
	# Since we can't do real gradient in ColorRect, we'll pulse it subtly
	add_child(low_hp_vignette)
	low_hp_vignette.visible = false


func _on_health_changed(current: int, max_health: int) -> void:
	var health_percent = float(current) / float(max_health) if max_health > 0 else 1.0
	
	if health_percent <= LOW_HP_THRESHOLD and not is_low_hp:
		# Just went low HP - start pulsing red vignette
		is_low_hp = true
		_start_vignette_pulse()
	elif health_percent > LOW_HP_THRESHOLD and is_low_hp:
		# Recovered above threshold - stop vignette
		is_low_hp = false
		_stop_vignette_pulse()


func _start_vignette_pulse() -> void:
	if not low_hp_vignette:
		return
	low_hp_vignette.visible = true
	
	# Kill existing tween
	if vignette_tween and vignette_tween.is_valid():
		vignette_tween.kill()
	
	# Looping pulse: fade in -> fade out -> repeat
	vignette_tween = create_tween().set_loops(999999)
	vignette_tween.tween_property(low_hp_vignette, "color:a", 0.18, 0.6)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	vignette_tween.tween_property(low_hp_vignette, "color:a", 0.04, 0.6)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _stop_vignette_pulse() -> void:
	if vignette_tween and vignette_tween.is_valid():
		vignette_tween.kill()
	if low_hp_vignette:
		# Fade out smoothly
		var fade_out = create_tween()
		fade_out.tween_property(low_hp_vignette, "color:a", 0.0, 0.3)
		var vignette_ref = weakref(low_hp_vignette)
		var hide_func = func():
			var node = vignette_ref.get_ref()
			if node:
				node.visible = false
		var hide_ref = weakref(hide_func)
		fade_out.tween_callback(func():
			var cb = hide_ref.get_ref()
			if cb:
				cb.call()
		)


