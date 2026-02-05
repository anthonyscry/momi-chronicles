extends Node

const CraftingManager = preload("res://systems/crafting/crafting_manager.gd")


func _ready() -> void:
	var capped_inventory = Inventory.new()
	capped_inventory.add_item("rat_gland", 1)
	capped_inventory.add_item("herb", 1)
	capped_inventory.add_item("antidote", 10)

	var can_craft = CraftingManager.can_craft("antidote_recipe", capped_inventory)

	assert(not can_craft, "Crafting should fail when output exceeds max stack")

	var inventory = Inventory.new()
	inventory.add_item("rat_gland", 1)
	inventory.add_item("herb", 1)

	var crafted = CraftingManager.craft("antidote_recipe", inventory)

	assert(crafted, "Crafting should succeed")
	assert(inventory.has_item("antidote", 1), "Antidote should be added")

	get_tree().quit()
