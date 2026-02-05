extends Node
## Crafting Manager - Handles crafting validation and execution.
## NOTE: This is an autoload, so don't use class_name.

const CraftingCatalog = preload("res://systems/crafting/crafting_catalog.gd")


static func can_craft(recipe_id: String, inventory: Inventory = null) -> bool:
	if inventory == null:
		inventory = GameManager.inventory
	if inventory == null:
		return false

	var recipe = CraftingCatalog.get_recipe(recipe_id)
	if recipe.is_empty():
		return false

	var inputs_value = recipe.get("inputs", {})
	if not (inputs_value is Dictionary) or inputs_value.is_empty():
		return false
	var inputs: Dictionary = inputs_value
	for item_id in inputs:
		var quantity = inputs[item_id]
		if not (quantity is int) or quantity <= 0:
			return false
		if not inventory.has_item(item_id, quantity):
			return false

	var output_value = recipe.get("output", {})
	if not (output_value is Dictionary):
		return false
	var output: Dictionary = output_value
	var output_item_id = output.get("item_id", "")
	var output_quantity = output.get("quantity", 0)
	if output_item_id == "" or not (output_quantity is int) or output_quantity <= 0:
		return false
	if not ItemDatabase.has_item(output_item_id):
		return false
	var item_data = ItemDatabase.get_item(output_item_id)
	var max_stack = item_data.get("max_stack", 99)
	if inventory.has_item(output_item_id):
		var current_qty = inventory.get_quantity(output_item_id)
		if current_qty + output_quantity > max_stack:
			return false
	elif inventory.items.size() >= Inventory.MAX_SLOTS:
		return false

	return true


static func craft(recipe_id: String, inventory: Inventory = null) -> bool:
	if inventory == null:
		inventory = GameManager.inventory
	if not can_craft(recipe_id, inventory):
		return false

	var recipe = CraftingCatalog.get_recipe(recipe_id)
	var inputs: Dictionary = recipe.get("inputs", {})
	var output: Dictionary = recipe.get("output", {})
	var output_item_id = output.get("item_id", "")
	var output_quantity = output.get("quantity", 0)

	for item_id in inputs:
		inventory.remove_item(item_id, inputs[item_id])

	return inventory.add_item(output_item_id, output_quantity)
