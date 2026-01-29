extends Node
class_name Inventory

signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal item_used(item_id: String)
signal inventory_changed

## Inventory slots: {item_id: quantity}
var items: Dictionary = {}

## Maximum unique item types
const MAX_SLOTS: int = 20

## Active buffs: {effect_type: {value, end_time}}
var active_buffs: Dictionary = {}

func _ready() -> void:
	# Give starting items
	add_item("health_potion", 3)
	add_item("acorn", 5)

func _process(_delta: float) -> void:
	# Check buff expirations
	_update_buffs()

# =============================================================================
# INVENTORY MANAGEMENT
# =============================================================================

func add_item(item_id: String, quantity: int = 1) -> bool:
	var item_data = ItemDatabase.get_item(item_id)
	if item_data.is_empty():
		return false
	
	if items.has(item_id):
		# Stack existing
		var max_stack = item_data.get("max_stack", 99)
		items[item_id] = min(items[item_id] + quantity, max_stack)
	else:
		# New item
		if items.size() >= MAX_SLOTS:
			push_warning("Inventory full!")
			return false
		items[item_id] = quantity
	
	item_added.emit(item_id, quantity)
	inventory_changed.emit()
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not items.has(item_id):
		return false
	
	items[item_id] -= quantity
	
	if items[item_id] <= 0:
		items.erase(item_id)
	
	item_removed.emit(item_id, quantity)
	inventory_changed.emit()
	return true

func has_item(item_id: String, quantity: int = 1) -> bool:
	return items.get(item_id, 0) >= quantity

func get_quantity(item_id: String) -> int:
	return items.get(item_id, 0)

func get_all_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in items:
		var item_data = ItemDatabase.get_item(item_id)
		item_data["quantity"] = items[item_id]
		result.append(item_data)
	return result

# =============================================================================
# ITEM USAGE
# =============================================================================

func use_item(item_id: String, target: Node = null) -> bool:
	if not has_item(item_id):
		return false
	
	var item_data = ItemDatabase.get_item(item_id)
	if item_data.is_empty():
		return false
	
	# Get target (default to player)
	if target == null:
		target = get_tree().get_first_node_in_group("player")
	
	if target == null:
		return false
	
	# Apply effect
	var success = _apply_item_effect(item_data, target)
	
	if success and item_data.get("consumable", false):
		remove_item(item_id, 1)
		item_used.emit(item_id)
		AudioManager.play_sfx("health_pickup")
	
	return success

func _apply_item_effect(item_data: Dictionary, target: Node) -> bool:
	var effect = item_data.get("effect", -1)
	var value = item_data.get("value", 0)
	
	match effect:
		ItemDatabase.EffectType.HEAL:
			if target.has_node("HealthComponent"):
				target.get_node("HealthComponent").heal(int(value))
				_spawn_heal_effect(target)
				return true
		
		ItemDatabase.EffectType.HEAL_PERCENT:
			if target.has_node("HealthComponent"):
				var health = target.get_node("HealthComponent")
				var heal_amount = int(health.max_health * value)
				health.heal(heal_amount)
				_spawn_heal_effect(target)
				return true
		
		ItemDatabase.EffectType.BUFF_ATTACK:
			_apply_buff(ItemDatabase.EffectType.BUFF_ATTACK, value, item_data.get("duration", 30.0))
			# Energy Treat: apply all three buffs at once
			if item_data.get("all_buffs", false):
				_apply_buff(ItemDatabase.EffectType.BUFF_SPEED, value, item_data.get("duration", 30.0))
				_apply_buff(ItemDatabase.EffectType.BUFF_DEFENSE, value, item_data.get("duration", 30.0))
			_spawn_buff_effect(target, item_data.get("color", Color.ORANGE))
			return true
		
		ItemDatabase.EffectType.BUFF_SPEED:
			_apply_buff(ItemDatabase.EffectType.BUFF_SPEED, value, item_data.get("duration", 30.0))
			_spawn_buff_effect(target, item_data.get("color", Color.CYAN))
			return true
		
		ItemDatabase.EffectType.BUFF_DEFENSE:
			_apply_buff(ItemDatabase.EffectType.BUFF_DEFENSE, value, item_data.get("duration", 30.0))
			_spawn_buff_effect(target, item_data.get("color", Color.PURPLE))
			return true
		
		ItemDatabase.EffectType.RESTORE_GUARD:
			if target.has_node("GuardComponent"):
				target.get_node("GuardComponent").restore_guard(value)
				return true
			# Fallback if no guard component - just succeed
			return true
		
		ItemDatabase.EffectType.CURE_STATUS:
			# Cure poison and other negative effects
			if target.has_node("HealthComponent"):
				var hp = target.get_node("HealthComponent")
				if hp.has_method("clear_poison"):
					hp.clear_poison()
				# Also clear poison visual via modulate reset
				if target.has_node("Sprite2D"):
					target.get_node("Sprite2D").modulate = Color.WHITE
				_spawn_buff_effect(target, Color(0.2, 1.0, 0.4))
				return true
			return true  # Succeed even without target (clears status)
		
		ItemDatabase.EffectType.INVINCIBLE:
			# Brief invincibility (smoke bomb)
			if target.has_node("Hurtbox"):
				var hurtbox_node = target.get_node("Hurtbox")
				hurtbox_node.start_invincibility(value)
				_spawn_smoke_effect(target)
				return true
			return false
		
		ItemDatabase.EffectType.REVIVE:
			# Revive first knocked-out companion
			if GameManager.party_manager:
				var knocked = GameManager.party_manager.knocked_out
				if knocked.is_empty():
					return false  # No one to revive — don't consume item
				var companion_id = knocked.keys()[0]
				GameManager.party_manager.revive_companion(companion_id, value)
				_spawn_buff_effect(target, Color(1.0, 0.95, 0.5))  # Gold glow
				return true
			return false
	
	return false

func _spawn_heal_effect(target: Node) -> void:
	if has_node("/root/EffectsManager"):
		get_node("/root/EffectsManager").spawn_pickup_effect(
			target.global_position, Color(0.3, 1.0, 0.3)
		)

func _spawn_buff_effect(target: Node, color: Color) -> void:
	if has_node("/root/EffectsManager"):
		get_node("/root/EffectsManager").spawn_pickup_effect(
			target.global_position, color
		)

func _spawn_smoke_effect(target: Node) -> void:
	if has_node("/root/EffectsManager"):
		get_node("/root/EffectsManager").spawn_pickup_effect(
			target.global_position, Color(0.5, 0.5, 0.5, 0.8)
		)

# =============================================================================
# BUFF SYSTEM
# =============================================================================

func _apply_buff(effect_type: int, value: float, duration: float) -> void:
	var end_time = Time.get_ticks_msec() / 1000.0 + duration
	active_buffs[effect_type] = {"value": value, "end_time": end_time}
	Events.buff_applied.emit(effect_type, value, duration)

func _update_buffs() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	var expired = []
	
	for effect_type in active_buffs:
		if current_time >= active_buffs[effect_type].end_time:
			expired.append(effect_type)
	
	for effect_type in expired:
		active_buffs.erase(effect_type)
		Events.buff_expired.emit(effect_type)

func get_buff_multiplier(effect_type: int) -> float:
	if active_buffs.has(effect_type):
		return 1.0 + active_buffs[effect_type].value
	return 1.0

func has_buff(effect_type: int) -> bool:
	return active_buffs.has(effect_type)

# =============================================================================
# SAVE/LOAD
# =============================================================================

func get_save_data() -> Dictionary:
	return {
		"items": items.duplicate(),
	}

func load_save_data(data: Dictionary) -> void:
	items = data.get("items", {}).duplicate()
	inventory_changed.emit()
