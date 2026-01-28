extends Node
class_name EquipmentDatabase

## Equipment slot types (5 slots as per CONTEXT.md)
enum Slot {
	COLLAR,     # Neck - primary accessory
	HARNESS,    # Body harness for stats
	LEASH,      # Held item / tether
	COAT,       # Coat/Jacket/Shirt - body covering
	HAT,        # Head accessory
}

## Stat types that equipment can modify
enum StatType {
	MAX_HEALTH,
	ATTACK_DAMAGE,
	MOVE_SPEED,
	DEFENSE,        # Damage reduction %
	GUARD_REGEN,    # Guard meter regen rate
	EXP_BONUS,      # Bonus EXP %
}

## Slot display names
const SLOT_NAMES: Dictionary = {
	Slot.COLLAR: "Collar",
	Slot.HARNESS: "Harness",
	Slot.LEASH: "Leash",
	Slot.COAT: "Coat",
	Slot.HAT: "Hat",
}

## All equipment definitions
const EQUIPMENT: Dictionary = {
	# === COLLARS ===
	"basic_collar": {
		"id": "basic_collar",
		"name": "Basic Collar",
		"desc": "A simple collar. +5 Max HP",
		"type": "equipment",
		"slot": Slot.COLLAR,
		"stats": {StatType.MAX_HEALTH: 5},
		"color": Color(0.8, 0.4, 0.2),  # Brown leather
	},
	"spiked_collar": {
		"id": "spiked_collar",
		"name": "Spiked Collar",
		"desc": "Intimidating spikes. +3 Attack",
		"type": "equipment",
		"slot": Slot.COLLAR,
		"stats": {StatType.ATTACK_DAMAGE: 3},
		"color": Color(0.3, 0.3, 0.3),  # Dark metal
	},
	"lucky_collar": {
		"id": "lucky_collar",
		"name": "Lucky Collar",
		"desc": "Brings good fortune. +10% EXP",
		"type": "equipment",
		"slot": Slot.COLLAR,
		"stats": {StatType.EXP_BONUS: 10},
		"color": Color(1.0, 0.84, 0.0),  # Gold
	},
	
	# === HARNESSES ===
	"training_harness": {
		"id": "training_harness",
		"name": "Training Harness",
		"desc": "Sturdy training gear. +10 Max HP",
		"type": "equipment",
		"slot": Slot.HARNESS,
		"stats": {StatType.MAX_HEALTH: 10},
		"color": Color(0.2, 0.5, 0.8),  # Blue
	},
	"tactical_harness": {
		"id": "tactical_harness",
		"name": "Tactical Harness",
		"desc": "Military grade. +5 Attack, +5 HP",
		"type": "equipment",
		"slot": Slot.HARNESS,
		"stats": {StatType.ATTACK_DAMAGE: 5, StatType.MAX_HEALTH: 5},
		"color": Color(0.3, 0.35, 0.3),  # Olive
	},
	"padded_harness": {
		"id": "padded_harness",
		"name": "Padded Harness",
		"desc": "Extra padding. +10% Defense",
		"type": "equipment",
		"slot": Slot.HARNESS,
		"stats": {StatType.DEFENSE: 10},
		"color": Color(0.6, 0.4, 0.6),  # Purple
	},
	
	# === LEASHES ===
	"retractable_leash": {
		"id": "retractable_leash",
		"name": "Retractable Leash",
		"desc": "Freedom to roam. +5 Speed",
		"type": "equipment",
		"slot": Slot.LEASH,
		"stats": {StatType.MOVE_SPEED: 5},
		"color": Color(0.9, 0.1, 0.1),  # Red
	},
	"chain_leash": {
		"id": "chain_leash",
		"name": "Chain Leash",
		"desc": "Heavy duty chain. +5 Attack",
		"type": "equipment",
		"slot": Slot.LEASH,
		"stats": {StatType.ATTACK_DAMAGE: 5},
		"color": Color(0.7, 0.7, 0.75),  # Silver
	},
	"bungee_leash": {
		"id": "bungee_leash",
		"name": "Bungee Leash",
		"desc": "Springy and fun. +8 Speed",
		"type": "equipment",
		"slot": Slot.LEASH,
		"stats": {StatType.MOVE_SPEED: 8},
		"color": Color(0.0, 0.8, 0.4),  # Green
	},
	
	# === COATS ===
	"raincoat": {
		"id": "raincoat",
		"name": "Raincoat",
		"desc": "Keeps you dry. +15 Max HP",
		"type": "equipment",
		"slot": Slot.COAT,
		"stats": {StatType.MAX_HEALTH: 15},
		"color": Color(1.0, 0.9, 0.2),  # Yellow
	},
	"sweater": {
		"id": "sweater",
		"name": "Cozy Sweater",
		"desc": "Warm and comfy. +5% Defense, +5 HP",
		"type": "equipment",
		"slot": Slot.COAT,
		"stats": {StatType.DEFENSE: 5, StatType.MAX_HEALTH: 5},
		"color": Color(0.9, 0.5, 0.5),  # Pink
	},
	"leather_jacket": {
		"id": "leather_jacket",
		"name": "Leather Jacket",
		"desc": "Cool and tough. +8 Attack",
		"type": "equipment",
		"slot": Slot.COAT,
		"stats": {StatType.ATTACK_DAMAGE: 8},
		"color": Color(0.15, 0.1, 0.1),  # Black
	},
	
	# === HATS ===
	"baseball_cap": {
		"id": "baseball_cap",
		"name": "Baseball Cap",
		"desc": "Sporty style. +3 Speed",
		"type": "equipment",
		"slot": Slot.HAT,
		"stats": {StatType.MOVE_SPEED: 3},
		"color": Color(0.8, 0.2, 0.2),  # Red
	},
	"bandana": {
		"id": "bandana",
		"name": "Bandana",
		"desc": "Stylish headwear. +2 Attack, +2 Speed",
		"type": "equipment",
		"slot": Slot.HAT,
		"stats": {StatType.ATTACK_DAMAGE: 2, StatType.MOVE_SPEED: 2},
		"color": Color(0.1, 0.3, 0.6),  # Navy
	},
	"guard_helmet": {
		"id": "guard_helmet",
		"name": "Guard Helmet",
		"desc": "Protective headgear. +10% Defense, +Guard Regen",
		"type": "equipment",
		"slot": Slot.HAT,
		"stats": {StatType.DEFENSE: 10, StatType.GUARD_REGEN: 5},
		"color": Color(0.5, 0.5, 0.55),  # Steel
	},
}

## Get equipment data by ID
static func get_equipment(equip_id: String) -> Dictionary:
	if EQUIPMENT.has(equip_id):
		return EQUIPMENT[equip_id].duplicate(true)
	push_error("Unknown equipment: %s" % equip_id)
	return {}

## Get all equipment for a specific slot
static func get_equipment_for_slot(slot: Slot) -> Array:
	var result = []
	for id in EQUIPMENT:
		if EQUIPMENT[id].slot == slot:
			result.append(EQUIPMENT[id].duplicate(true))
	return result

## Get slot name
static func get_slot_name(slot: Slot) -> String:
	return SLOT_NAMES.get(slot, "Unknown")

## Check if equipment exists
static func has_equipment(equip_id: String) -> bool:
	return EQUIPMENT.has(equip_id)
