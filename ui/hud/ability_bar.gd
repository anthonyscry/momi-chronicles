extends Control
class_name AbilityBar
## Displays abilities, their unlock state, and cooldowns

# =============================================================================
# ABILITY DATA
# =============================================================================

const ABILITIES = {
	"charge": {
		"name": "Charge Attack",
		"key": "Hold",
		"icon": "C",
		"unlock_level": 1,
		"color": Color(1, 0.8, 0.3)
	},
	"ground_pound": {
		"name": "Ground Pound",
		"key": "Spec",
		"icon": "G",
		"unlock_level": 5,
		"color": Color(0.5, 0.8, 1.0)
	}
}

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var container: HBoxContainer = $HBoxContainer
var ability_nodes: Dictionary = {}

# =============================================================================
# STATE
# =============================================================================

var current_level: int = 1
var player_ref: Player = null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	Events.player_leveled_up.connect(_on_level_up)
	
	# Find player after a frame
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")
	
	_create_ability_slots()
	_update_all_abilities()

func _process(_delta: float) -> void:
	_update_cooldowns()

# =============================================================================
# UI CREATION
# =============================================================================

func _create_ability_slots() -> void:
	for ability_id in ABILITIES:
		var ability = ABILITIES[ability_id]
		var slot = _create_slot(ability_id, ability)
		container.add_child(slot)
		ability_nodes[ability_id] = slot

func _create_slot(id: String, data: Dictionary) -> Control:
	# COMPACT DESIGN: 16x16 icons for minimal screen footprint
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(18, 18)
	slot.name = id
	
	# Background - smaller, semi-transparent
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.size = Vector2(18, 18)
	bg.color = Color(0.1, 0.1, 0.15, 0.7)
	slot.add_child(bg)
	
	# Inner
	var inner = ColorRect.new()
	inner.name = "Inner"
	inner.size = Vector2(14, 14)
	inner.position = Vector2(2, 2)
	inner.color = Color(0.08, 0.08, 0.12, 0.9)
	slot.add_child(inner)
	
	# Icon - compact
	var icon = Label.new()
	icon.name = "Icon"
	icon.text = data.icon
	icon.add_theme_font_size_override("font_size", 10)
	icon.add_theme_color_override("font_color", data.color)
	icon.position = Vector2(5, 1)
	slot.add_child(icon)
	
	# Cooldown overlay (radial-style: covers from bottom up)
	var cooldown = ColorRect.new()
	cooldown.name = "CooldownOverlay"
	cooldown.size = Vector2(14, 0)
	cooldown.position = Vector2(2, 16)
	cooldown.color = Color(0, 0, 0, 0.8)
	slot.add_child(cooldown)
	
	# Lock overlay
	var lock = ColorRect.new()
	lock.name = "LockOverlay"
	lock.size = Vector2(18, 18)
	lock.color = Color(0.05, 0.05, 0.08, 0.9)
	lock.visible = false
	slot.add_child(lock)
	
	# Lock icon (small padlock symbol)
	var lock_text = Label.new()
	lock_text.name = "LockText"
	lock_text.text = str(data.unlock_level)
	lock_text.add_theme_font_size_override("font_size", 8)
	lock_text.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	lock_text.position = Vector2(6, 4)
	lock.add_child(lock_text)
	
	return slot

# =============================================================================
# UPDATES
# =============================================================================

func _on_level_up(new_level: int) -> void:
	var old_level = current_level
	current_level = new_level
	_update_all_abilities()
	
	# Check for new unlocks
	for ability_id in ABILITIES:
		var unlock_level = ABILITIES[ability_id].unlock_level
		if unlock_level > old_level and unlock_level <= new_level:
			_play_unlock_effect(ability_id)

func _update_all_abilities() -> void:
	if player_ref and player_ref.progression:
		current_level = player_ref.progression.get_level()
	
	for ability_id in ABILITIES:
		var ability = ABILITIES[ability_id]
		var slot = ability_nodes.get(ability_id)
		if not slot:
			continue
		
		var is_unlocked = current_level >= ability.unlock_level
		var lock_overlay = slot.get_node("LockOverlay")
		lock_overlay.visible = not is_unlocked

func _update_cooldowns() -> void:
	# Ground pound cooldown - compact 14px height
	if ability_nodes.has("ground_pound") and player_ref:
		var cooldown = player_ref.get_ground_pound_cooldown() if player_ref.has_method("get_ground_pound_cooldown") else 0.0
		var max_cooldown = 3.0  # Match PlayerGroundPound.COOLDOWN
		var slot = ability_nodes["ground_pound"]
		var overlay = slot.get_node("CooldownOverlay")
		
		if cooldown > 0:
			var percent = cooldown / max_cooldown
			overlay.size.y = 14 * percent
			overlay.position.y = 2 + 14 * (1 - percent)
		else:
			overlay.size.y = 0

func _play_unlock_effect(ability_id: String) -> void:
	var slot = ability_nodes.get(ability_id)
	if not slot:
		return
	
	# Flash effect
	var tween = create_tween()
	tween.tween_property(slot, "modulate", Color(2, 2, 2, 1), 0.1)
	tween.tween_property(slot, "modulate", Color.WHITE, 0.3)
	
	# Create "UNLOCKED!" popup
	var popup = Label.new()
	popup.text = "UNLOCKED!"
	popup.add_theme_font_size_override("font_size", 10)
	popup.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	popup.global_position = slot.global_position + Vector2(-10, -20)
	get_tree().current_scene.add_child(popup)
	
	var popup_tween = create_tween()
	popup_tween.tween_property(popup, "global_position:y", popup.global_position.y - 20, 0.8)
	popup_tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.8).set_delay(0.3)
	popup_tween.tween_callback(popup.queue_free)
