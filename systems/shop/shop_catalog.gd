extends Node
## Shop Catalog - Defines prices for all buyable items and equipment.
## Tracks stock levels per item, restocks on neighborhood zone entry.
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
	"raccoon_crown": 200,
	"crow_feather_coat": 250,
	"rat_king_collar": 220,
}

## Sell-back multiplier (50% of buy price)
const SELL_MULTIPLIER: float = 0.5

# =============================================================================
# STOCK DATA
# =============================================================================

## Default stock levels for items (reset on restock)
const DEFAULT_ITEM_STOCK: Dictionary = {
	"acorn": 10,
	"bird_seed": 15,
	"health_potion": 5,
	"mega_potion": 3,
	"full_heal": 1,
	"power_treat": 3,
	"speed_treat": 3,
	"tough_treat": 3,
	"guard_snack": 5,
	"revival_bone": 2,
}

## Default equipment stock (each piece available once per restock)
const DEFAULT_EQUIPMENT_STOCK: Dictionary = {
	"basic_collar": 1,
	"spiked_collar": 1,
	"lucky_collar": 1,
	"training_harness": 1,
	"tactical_harness": 1,
	"padded_harness": 1,
	"retractable_leash": 1,
	"chain_leash": 1,
	"bungee_leash": 1,
	"raincoat": 1,
	"sweater": 1,
	"leather_jacket": 1,
	"baseball_cap": 1,
	"bandana": 1,
	"guard_helmet": 1,
}

## Current stock levels: {item_id: quantity_available}
var shop_stock: Dictionary = {}

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	restock()
	Events.zone_entered.connect(_on_zone_entered)


func _on_zone_entered(zone_name: String) -> void:
	if zone_name == "neighborhood":
		restock()

# =============================================================================
# STOCK MANAGEMENT
# =============================================================================

## Restock all items and equipment to default levels.
## Equipment already owned by the player is not restocked.
func restock() -> void:
	shop_stock.clear()
	
	# Restock items
	for item_id in DEFAULT_ITEM_STOCK:
		shop_stock[item_id] = DEFAULT_ITEM_STOCK[item_id]
	
	# Restock equipment (skip already-owned)
	for equip_id in DEFAULT_EQUIPMENT_STOCK:
		if GameManager.equipment_manager and GameManager.equipment_manager.has_equipment(equip_id):
			shop_stock[equip_id] = 0
		else:
			shop_stock[equip_id] = DEFAULT_EQUIPMENT_STOCK[equip_id]
	
	print("[ShopCatalog] Shop restocked!")


## Get current stock for an item.
func get_stock(item_id: String) -> int:
	return shop_stock.get(item_id, 0)


## Reduce stock by 1 after a purchase.
func reduce_stock(item_id: String) -> void:
	if shop_stock.has(item_id) and shop_stock[item_id] > 0:
		shop_stock[item_id] -= 1

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
## Only returns items with stock > 0.
func get_all_shop_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in SHOP_ITEMS:
		if get_stock(item_id) <= 0:
			continue
		var data = ItemDatabase.get_item(item_id)
		if not data.is_empty():
			data["buy_price"] = SHOP_ITEMS[item_id]
			data["stock"] = get_stock(item_id)
			result.append(data)
	return result


## Get all shop equipment with full data (from EquipmentDatabase) plus buy_price.
## Only returns equipment with stock > 0.
func get_all_shop_equipment() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for equip_id in SHOP_EQUIPMENT:
		if get_stock(equip_id) <= 0:
			continue
		var data = EquipmentDatabase.get_equipment(equip_id)
		if not data.is_empty():
			data["buy_price"] = SHOP_EQUIPMENT[equip_id]
			data["stock"] = get_stock(equip_id)
			result.append(data)
	return result


## Check if an ID is a shop item.
func is_item(item_id: String) -> bool:
	return SHOP_ITEMS.has(item_id)


## Check if an ID is shop equipment.
func is_equipment(item_id: String) -> bool:
	return SHOP_EQUIPMENT.has(item_id)
