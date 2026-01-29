extends Node
## Shop Catalog - Defines prices for all buyable items and equipment.
## NOTE: This is an autoload, so don't use class_name.

# =============================================================================
# PRICE DATA
# =============================================================================

## Item prices (item_id -> buy_price in coins)
const SHOP_ITEMS: Dictionary = {
	"acorn": 5,
	"health_potion": 25,
	"mega_potion": 80,
	"full_heal": 200,
	"power_treat": 40,
	"speed_treat": 35,
	"tough_treat": 35,
	"guard_snack": 20,
	"revival_bone": 100,
	"bird_seed": 3,
}

## Equipment prices (equipment_id -> buy_price in coins)
const SHOP_EQUIPMENT: Dictionary = {
	"basic_collar": 30,
	"spiked_collar": 60,
	"lucky_collar": 150,
	"training_harness": 50,
	"tactical_harness": 120,
	"padded_harness": 80,
	"retractable_leash": 40,
	"chain_leash": 75,
	"bungee_leash": 90,
	"raincoat": 70,
	"sweater": 65,
	"leather_jacket": 130,
	"baseball_cap": 35,
	"bandana": 55,
	"guard_helmet": 140,
}

## Sell-back multiplier (50% of buy price)
const SELL_MULTIPLIER: float = 0.5

# =============================================================================
# PRICE FUNCTIONS
# =============================================================================

## Get the buy price for an item or equipment. Returns -1 if not found.
func get_buy_price(item_id: String) -> int:
	if SHOP_ITEMS.has(item_id):
		return SHOP_ITEMS[item_id]
	if SHOP_EQUIPMENT.has(item_id):
		return SHOP_EQUIPMENT[item_id]
	return -1


## Get the sell price for an item or equipment. Returns -1 if not found.
func get_sell_price(item_id: String) -> int:
	var buy_price = get_buy_price(item_id)
	if buy_price < 0:
		return -1
	return int(floor(buy_price * SELL_MULTIPLIER))


## Check if the player can afford an item or equipment.
func can_afford(item_id: String) -> bool:
	var buy_price = get_buy_price(item_id)
	if buy_price < 0:
		return false
	return GameManager.coins >= buy_price


# =============================================================================
# CATALOG QUERIES
# =============================================================================

## Get all shop items with full data (from ItemDatabase) plus buy_price.
func get_all_shop_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in SHOP_ITEMS:
		var data = ItemDatabase.get_item(item_id)
		if not data.is_empty():
			data["buy_price"] = SHOP_ITEMS[item_id]
			result.append(data)
	return result


## Get all shop equipment with full data (from EquipmentDatabase) plus buy_price.
func get_all_shop_equipment() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for equip_id in SHOP_EQUIPMENT:
		var data = EquipmentDatabase.get_equipment(equip_id)
		if not data.is_empty():
			data["buy_price"] = SHOP_EQUIPMENT[equip_id]
			result.append(data)
	return result


## Check if an ID is a shop item.
func is_item(item_id: String) -> bool:
	return SHOP_ITEMS.has(item_id)


## Check if an ID is shop equipment.
func is_equipment(item_id: String) -> bool:
	return SHOP_EQUIPMENT.has(item_id)
