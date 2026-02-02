extends Node
## Equipment Database - All equipment definitions
## NOTE: This is an autoload, so don't use class_name

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
	# Tier 1 (Level 1)
	"basic_collar": {
		"id": "basic_collar",
		"name": "Basic Collar",
		"desc": "A simple collar. +5 Max HP",
		"type": "equipment",
		"slot": Slot.COLLAR,
		"stats": {StatType.MAX_HEALTH: 5},
		"min_level": 1,
		"color": Color(0.8, 0.4, 0.2),
		"icon": "res://art/generated/equipment/basic_collar.png",
	},
	# Tier 2 (Level 3)
	"spiked_collar": {
		"id": "spiked_collar",
		"name": "Spiked Collar",
		"desc": "Intimidating spikes. +3 Attack",
		"type": "equipment",
		"slot": Slot.COLLAR,
		"stats": {StatType.ATTACK_DAMAGE: 3},
		"min_level": 3,
		"color": Color(0.3, 0.3, 0.3),
		"icon": "res://art/generated/equipment/spiked_collar.png",
	},
	# Tier 3 (Level 5)
	"lucky_collar": {
		"id": "lucky_collar",
		"name": "Lucky Collar",
		"desc": "Brings good fortune. +10% EXP",
		"type": "equipment",
		"slot": Slot.COLLAR,
		"stats": {StatType.EXP_BONUS: 10},
		"min_level": 5,
		"color": Color(1.0, 0.84, 0.0),
		"icon": "res://art/generated/equipment/lucky_collar.png",
	},
	
	# === HARNESSES ===
	# Tier 1 (Level 1)
	"training_harness": {
		"id": "training_harness",
		"name": "Training Harness",
		"desc": "Sturdy training gear. +10 Max HP",
		"type": "equipment",
		"slot": Slot.HARNESS,
		"stats": {StatType.MAX_HEALTH: 10},
		"min_level": 1,
		"color": Color(0.2, 0.5, 0.8),
		"icon": "res://art/generated/equipment/training_harness.png",
	},
	# Tier 2 (Level 3)
	"padded_harness": {
		"id": "padded_harness",
		"name": "Padded Harness",
		"desc": "Extra padding. +10% Defense",
		"type": "equipment",
		"slot": Slot.HARNESS,
		"stats": {StatType.DEFENSE: 10},
		"min_level": 3,
		"color": Color(0.6, 0.4, 0.6),
		"icon": "res://art/generated/equipment/padded_harness.png",
	},
	# Tier 3 (Level 5)
	"tactical_harness": {
		"id": "tactical_harness",
		"name": "Tactical Harness",
		"desc": "Military grade. +5 Attack, +5 HP",
		"type": "equipment",
		"slot": Slot.HARNESS,
		"stats": {StatType.ATTACK_DAMAGE: 5, StatType.MAX_HEALTH: 5},
		"min_level": 5,
		"color": Color(0.3, 0.35, 0.3),
		"icon": "res://art/generated/equipment/tactical_harness.png",
	},
	
	# === LEASHES ===
	# Tier 1 (Level 1)
	"retractable_leash": {
		"id": "retractable_leash",
		"name": "Retractable Leash",
		"desc": "Freedom to roam. +5 Speed",
		"type": "equipment",
		"slot": Slot.LEASH,
		"stats": {StatType.MOVE_SPEED: 5},
		"min_level": 1,
		"color": Color(0.9, 0.1, 0.1),
		"icon": "res://art/generated/equipment/retractable_leash.png",
	},
	# Tier 2 (Level 3)
	"chain_leash": {
		"id": "chain_leash",
		"name": "Chain Leash",
		"desc": "Heavy duty chain. +5 Attack",
		"type": "equipment",
		"slot": Slot.LEASH,
		"stats": {StatType.ATTACK_DAMAGE: 5},
		"min_level": 3,
		"color": Color(0.7, 0.7, 0.75),
		"icon": "res://art/generated/equipment/chain_leash.png",
	},
	# Tier 3 (Level 5)
	"bungee_leash": {
		"id": "bungee_leash",
		"name": "Bungee Leash",
		"desc": "Springy and fun. +8 Speed",
		"type": "equipment",
		"slot": Slot.LEASH,
		"stats": {StatType.MOVE_SPEED: 8},
		"min_level": 5,
		"color": Color(0.0, 0.8, 0.4),
		"icon": "res://art/generated/equipment/bungee_leash.png",
	},
	
	# === COATS ===
	# Tier 1 (Level 1)
	"raincoat": {
		"id": "raincoat",
		"name": "Raincoat",
		"desc": "Keeps you dry. +15 Max HP",
		"type": "equipment",
		"slot": Slot.COAT,
		"stats": {StatType.MAX_HEALTH: 15},
		"min_level": 1,
		"color": Color(1.0, 0.9, 0.2),
		"icon": "res://art/generated/equipment/raincoat.png",
	},
	# Tier 2 (Level 3)
	"sweater": {
		"id": "sweater",
		"name": "Cozy Sweater",
		"desc": "Warm and comfy. +5% Defense, +5 HP",
		"type": "equipment",
		"slot": Slot.COAT,
		"stats": {StatType.DEFENSE: 5, StatType.MAX_HEALTH: 5},
		"min_level": 3,
		"color": Color(0.9, 0.5, 0.5),
		"icon": "res://art/generated/equipment/sweater.png",
	},
	# Tier 3 (Level 5)
	"leather_jacket": {
		"id": "leather_jacket",
		"name": "Leather Jacket",
		"desc": "Cool and tough. +8 Attack",
		"type": "equipment",
		"slot": Slot.COAT,
		"stats": {StatType.ATTACK_DAMAGE: 8},
		"min_level": 5,
		"color": Color(0.15, 0.1, 0.1),
		"icon": "res://art/generated/equipment/leather_jacket.png",
	},
	
	# === HATS ===
	# Tier 1 (Level 1)
	"baseball_cap": {
		"id": "baseball_cap",
		"name": "Baseball Cap",
		"desc": "Sporty style. +3 Speed",
		"type": "equipment",
		"slot": Slot.HAT,
		"stats": {StatType.MOVE_SPEED: 3},
		"min_level": 1,
		"color": Color(0.8, 0.2, 0.2),
		"icon": "res://art/generated/equipment/baseball_cap.png",
	},
	# Tier 2 (Level 3)
	"bandana": {
		"id": "bandana",
		"name": "Bandana",
		"desc": "Stylish headwear. +2 Attack, +2 Speed",
		"type": "equipment",
		"slot": Slot.HAT,
		"stats": {StatType.ATTACK_DAMAGE: 2, StatType.MOVE_SPEED: 2},
		"min_level": 3,
		"color": Color(0.1, 0.3, 0.6),
	},
	# Tier 3 (Level 5)
	"guard_helmet": {
		"id": "guard_helmet",
		"name": "Guard Helmet",
		"desc": "Protective headgear. +10% Defense, +Guard Regen",
		"type": "equipment",
		"slot": Slot.HAT,
		"stats": {StatType.DEFENSE: 10, StatType.GUARD_REGEN: 5},
		"min_level": 5,
		"color": Color(0.5, 0.5, 0.55),
	},
	
	# === MINI-BOSS LOOT (RARE — no level requirement, earned through combat) ===
	"raccoon_crown": {
		"id": "raccoon_crown",
		"name": "Raccoon Crown",
		"desc": "Trophy from the Alpha. +15 Max HP, +5 Attack",
		"type": "equipment",
		"slot": Slot.HAT,
		"stats": {StatType.MAX_HEALTH: 15, StatType.ATTACK_DAMAGE: 5},
		"min_level": 1,
		"color": Color(1.0, 0.85, 0.2),
	},
	"crow_feather_coat": {
		"id": "crow_feather_coat",
		"name": "Crow Feather Coat",
		"desc": "Dark plumage of the Matriarch. +10 Speed, +10% Defense",
		"type": "equipment",
		"slot": Slot.COAT,
		"stats": {StatType.MOVE_SPEED: 10, StatType.DEFENSE: 10},
		"min_level": 1,
		"color": Color(0.1, 0.08, 0.15),
		"icon": "res://art/generated/equipment/crow_feather_coat.png",
	},
	"rat_king_collar": {
		"id": "rat_king_collar",
		"name": "Rat King's Collar",
		"desc": "Filthy but powerful. +8 Attack, +5 Guard Regen",
		"type": "equipment",
		"slot": Slot.COLLAR,
		"stats": {StatType.ATTACK_DAMAGE: 8, StatType.GUARD_REGEN: 5},
		"min_level": 1,
		"color": Color(0.4, 0.35, 0.2),
		"icon": "res://art/generated/equipment/rat_king_collar.png",
	},
	
	# === BOSS LOOT (LEGENDARY — earned from final boss) ===
	"kings_mantle": {
		"id": "kings_mantle",
		"name": "King's Mantle",
		"desc": "The Raccoon King's royal cape. +12 ATK, +20 HP, +10% DEF",
		"type": "equipment",
		"slot": Slot.COAT,
		"stats": {StatType.ATTACK_DAMAGE: 12, StatType.MAX_HEALTH: 20, StatType.DEFENSE: 10},
		"min_level": 1,
		"color": Color(0.6, 0.1, 0.8),
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
