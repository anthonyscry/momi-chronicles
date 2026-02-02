extends Node
## Item Database - All item definitions
## NOTE: This is an autoload, so don't use class_name

## Item effect types
enum EffectType {
	HEAL,           # Restore HP
	HEAL_PERCENT,   # Restore % of max HP
	BUFF_ATTACK,    # Temporary attack boost
	BUFF_SPEED,     # Temporary speed boost
	BUFF_DEFENSE,   # Temporary damage reduction
	RESTORE_GUARD,  # Restore guard meter
	CURE_STATUS,    # Remove negative effects
	REVIVE,         # Revive companion
	INVINCIBLE,     # Brief invincibility
}

## All item definitions
const ITEMS: Dictionary = {
	# === HEALING ITEMS ===
	"health_potion": {
		"id": "health_potion",
		"name": "Health Potion",
		"desc": "Restores 50 HP",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 10,
		"effect": EffectType.HEAL,
		"value": 50,
		"color": Color(1.0, 0.3, 0.3),
		"icon": "res://art/generated/items/health_potion.png",
	},
	"mega_potion": {
		"id": "mega_potion",
		"name": "Mega Potion",
		"desc": "Restores 150 HP",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 5,
		"effect": EffectType.HEAL,
		"value": 150,
		"color": Color(1.0, 0.1, 0.5),
		"icon": "res://art/generated/items/mega_potion.png",
	},
	"full_heal": {
		"id": "full_heal",
		"name": "Full Heal",
		"desc": "Fully restores HP",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 3,
		"effect": EffectType.HEAL_PERCENT,
		"value": 1.0,
		"color": Color(1.0, 0.8, 0.9),
		"icon": "res://art/generated/items/full_heal.png",
	},
	
	# === FOOD ITEMS (from enemy drops) ===
	"acorn": {
		"id": "acorn",
		"name": "Acorn",
		"desc": "A crunchy snack. Restores 15 HP",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 20,
		"effect": EffectType.HEAL,
		"value": 15,
		"color": Color(0.6, 0.4, 0.2),
		"icon": "res://art/generated/items/acorn.png",
	},
	"bird_seed": {
		"id": "bird_seed",
		"name": "Bird Seed",
		"desc": "Nutritious seeds. Restores 10 HP",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 30,
		"effect": EffectType.HEAL,
		"value": 10,
		"color": Color(0.9, 0.85, 0.6),
		"icon": "res://art/generated/items/bird_seed.png",
	},
	
	# === BUFF ITEMS ===
	"power_treat": {
		"id": "power_treat",
		"name": "Power Treat",
		"desc": "Attack +50% for 30 seconds",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 5,
		"effect": EffectType.BUFF_ATTACK,
		"value": 0.5,
		"duration": 30.0,
		"color": Color(1.0, 0.5, 0.0),
		"icon": "res://art/generated/items/power_treat.png",
	},
	"speed_treat": {
		"id": "speed_treat",
		"name": "Speed Treat",
		"desc": "Speed +30% for 30 seconds",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 5,
		"effect": EffectType.BUFF_SPEED,
		"value": 0.3,
		"duration": 30.0,
		"color": Color(0.3, 0.9, 1.0),
		"icon": "res://art/generated/items/speed_treat.png",
	},
	"tough_treat": {
		"id": "tough_treat",
		"name": "Tough Treat",
		"desc": "Damage taken -30% for 30 seconds",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 5,
		"effect": EffectType.BUFF_DEFENSE,
		"value": 0.3,
		"duration": 30.0,
		"color": Color(0.5, 0.5, 0.8),
		"icon": "res://art/generated/items/tough_treat.png",
	},
	
	# === GUARD ITEMS (v1.2) ===
	"guard_snack": {
		"id": "guard_snack",
		"name": "Guard Snack",
		"desc": "Restores guard meter fully",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 10,
		"effect": EffectType.RESTORE_GUARD,
		"value": 100.0,
		"color": Color(0.4, 0.6, 1.0),
		"icon": "res://art/generated/items/guard_snack.png",
	},
	
	# === STATUS CURE ITEMS ===
	"antidote": {
		"id": "antidote",
		"name": "Antidote",
		"desc": "Cures poison. Tastes awful",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 10,
		"effect": EffectType.CURE_STATUS,
		"value": 0,
		"color": Color(0.2, 0.9, 0.4),
		"icon": "res://art/generated/items/antidote.png",
	},
	
	# === TACTICAL ITEMS ===
	"smoke_bomb": {
		"id": "smoke_bomb",
		"name": "Smoke Bomb",
		"desc": "Brief invincibility for 3 seconds",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 5,
		"effect": EffectType.INVINCIBLE,
		"value": 3.0,
		"color": Color(0.5, 0.5, 0.5),
		"icon": "res://art/generated/items/smoke_bomb.png",
	},
	"energy_treat": {
		"id": "energy_treat",
		"name": "Energy Treat",
		"desc": "All buffs at once! +25% ATK/SPD/DEF for 20s",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 3,
		"effect": EffectType.BUFF_ATTACK,
		"value": 0.25,
		"duration": 20.0,
		"all_buffs": true,
		"color": Color(1.0, 0.85, 0.0),
		"icon": "res://art/generated/items/energy_treat.png",
	},
	
	# === REVIVAL ITEMS ===
	"revival_bone": {
		"id": "revival_bone",
		"name": "Revival Bone",
		"desc": "Revives a knocked out companion with 50% HP",
		"type": "item",
		"consumable": true,
		"stackable": true,
		"max_stack": 3,
		"effect": EffectType.REVIVE,
		"value": 0.5,
		"color": Color(1.0, 1.0, 0.8),
		"icon": "res://art/generated/items/revival_bone.png",
	},
}

## Get item data by ID
static func get_item(item_id: String) -> Dictionary:
	if ITEMS.has(item_id):
		return ITEMS[item_id].duplicate(true)
	push_error("Unknown item: %s" % item_id)
	return {}

## Get all items of a type
static func get_items_by_type(item_type: String) -> Array:
	var result = []
	for id in ITEMS:
		if ITEMS[id].type == item_type:
			result.append(ITEMS[id].duplicate(true))
	return result

## Check if item exists
static func has_item(item_id: String) -> bool:
	return ITEMS.has(item_id)
