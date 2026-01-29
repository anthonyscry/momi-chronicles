extends Node
class_name EquipmentManager

signal equipment_changed(slot: int, equipment_id: String)
signal stats_recalculated

## Currently equipped items: {Slot: equipment_id or ""}
var equipped: Dictionary = {
	EquipmentDatabase.Slot.COLLAR: "",
	EquipmentDatabase.Slot.HARNESS: "",
	EquipmentDatabase.Slot.LEASH: "",
	EquipmentDatabase.Slot.COAT: "",
	EquipmentDatabase.Slot.HAT: "",
}

## Inventory of unequipped equipment: {equipment_id: quantity}
var equipment_inventory: Dictionary = {}

func _ready() -> void:
	# Give starting equipment
	add_equipment("basic_collar")
	add_equipment("training_harness")
	add_equipment("retractable_leash")

# =============================================================================
# EQUIPMENT INVENTORY
# =============================================================================

## Add equipment to inventory
func add_equipment(equip_id: String) -> bool:
	var equip_data = EquipmentDatabase.get_equipment(equip_id)
	if equip_data.is_empty():
		return false
	
	# Equipment doesn't stack - each is unique
	if equipment_inventory.has(equip_id):
		return false  # Already have this
	
	equipment_inventory[equip_id] = 1
	return true

## Remove equipment from inventory
func remove_equipment(equip_id: String) -> bool:
	if not equipment_inventory.has(equip_id):
		return false
	equipment_inventory.erase(equip_id)
	return true

## Check if player owns equipment
func has_equipment(equip_id: String) -> bool:
	return equipment_inventory.has(equip_id) or is_equipped(equip_id)

## Check if specific equipment is currently equipped
func is_equipped(equip_id: String) -> bool:
	for slot in equipped:
		if equipped[slot] == equip_id:
			return true
	return false

# =============================================================================
# EQUIPPING
# =============================================================================

## Equip an item (instant swap as per CONTEXT.md)
func equip(equip_id: String) -> bool:
	var equip_data = EquipmentDatabase.get_equipment(equip_id)
	if equip_data.is_empty():
		return false
	
	var slot = equip_data.slot
	
	# Check level requirement
	var min_level = equip_data.get("min_level", 1)
	if min_level > 1:
		var player = Engine.get_main_loop().root.get_node_or_null("Game/Player")
		if player == null:
			# Try group lookup
			var tree = Engine.get_main_loop()
			if tree is SceneTree:
				player = tree.get_first_node_in_group("player")
		if player and player.has_node("ProgressionComponent"):
			var current_level = player.get_node("ProgressionComponent").get_level()
			if current_level < min_level:
				push_warning("Level %d required for %s (current: %d)" % [min_level, equip_data.get("name", equip_id), current_level])
				return false
	
	# Check ownership (must be in inventory OR already equipped elsewhere)
	if not has_equipment(equip_id):
		return false
	
	# Unequip current item in slot (if any)
	var current = equipped[slot]
	if current != "":
		# Return current to inventory
		equipment_inventory[current] = 1
	
	# Remove from inventory if it was there
	if equipment_inventory.has(equip_id):
		equipment_inventory.erase(equip_id)
	
	# Equip new item
	equipped[slot] = equip_id
	
	equipment_changed.emit(slot, equip_id)
	stats_recalculated.emit()
	Events.equipment_changed.emit(slot, equip_id)
	
	AudioManager.play_sfx("health_pickup")  # Reuse pickup sound for equip
	return true

## Unequip an item from slot
func unequip(slot: int) -> bool:
	var current = equipped[slot]
	if current == "":
		return false
	
	# Return to inventory
	equipment_inventory[current] = 1
	equipped[slot] = ""
	
	equipment_changed.emit(slot, "")
	stats_recalculated.emit()
	Events.equipment_changed.emit(slot, "")
	return true

## Get currently equipped item in slot
func get_equipped(slot: int) -> String:
	return equipped.get(slot, "")

## Get data for equipped item in slot
func get_equipped_data(slot: int) -> Dictionary:
	var equip_id = equipped.get(slot, "")
	if equip_id == "":
		return {}
	return EquipmentDatabase.get_equipment(equip_id)

# =============================================================================
# STAT CALCULATION
# =============================================================================

## Get total bonus for a stat type from all equipment
func get_stat_bonus(stat_type: int) -> float:
	var total: float = 0.0
	
	for slot in equipped:
		var equip_id = equipped[slot]
		if equip_id == "":
			continue
		
		var equip_data = EquipmentDatabase.get_equipment(equip_id)
		if equip_data.has("stats") and equip_data.stats.has(stat_type):
			total += equip_data.stats[stat_type]
	
	return total

## Get all stat bonuses as dictionary
func get_all_stat_bonuses() -> Dictionary:
	var bonuses = {}
	
	for stat_type in EquipmentDatabase.StatType.values():
		var bonus = get_stat_bonus(stat_type)
		if bonus != 0:
			bonuses[stat_type] = bonus
	
	return bonuses

# =============================================================================
# RING MENU INTEGRATION
# =============================================================================

## Get all equipment for ring menu display (equipped + inventory, grouped by slot)
func get_equipment_for_ring() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	# Show equipped items first (with equipped indicator)
	for slot in EquipmentDatabase.Slot.values():
		var equip_id = equipped[slot]
		if equip_id != "":
			var data = EquipmentDatabase.get_equipment(equip_id)
			data["equipped"] = true
			data["slot_name"] = EquipmentDatabase.get_slot_name(slot)
			result.append(data)
	
	# Then show unequipped inventory
	for equip_id in equipment_inventory:
		var data = EquipmentDatabase.get_equipment(equip_id)
		data["equipped"] = false
		data["slot_name"] = EquipmentDatabase.get_slot_name(data.slot)
		result.append(data)
	
	return result

# =============================================================================
# SAVE/LOAD
# =============================================================================

func get_save_data() -> Dictionary:
	return {
		"equipped": equipped.duplicate(),
		"inventory": equipment_inventory.duplicate(),
	}

func load_save_data(data: Dictionary) -> void:
	equipped = data.get("equipped", {
		EquipmentDatabase.Slot.COLLAR: "",
		EquipmentDatabase.Slot.HARNESS: "",
		EquipmentDatabase.Slot.LEASH: "",
		EquipmentDatabase.Slot.COAT: "",
		EquipmentDatabase.Slot.HAT: "",
	}).duplicate()
	equipment_inventory = data.get("inventory", {}).duplicate()
	stats_recalculated.emit()
