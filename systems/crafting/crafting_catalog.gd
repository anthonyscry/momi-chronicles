extends Node
## Crafting Catalog - Defines crafting recipes.
## NOTE: This is an autoload, so don't use class_name.

const RECIPES: Dictionary = {
	"antidote_recipe": {
		"id": "antidote_recipe",
		"name": "Antidote",
		"inputs": {
			"rat_gland": 1,
			"herb": 1,
		},
		"output": {
			"item_id": "antidote",
			"quantity": 1,
		},
	},
	"potion_recipe": {
		"id": "potion_recipe",
		"name": "Health Potion",
		"inputs": {
			"acorn": 2,
			"bird_seed": 2,
		},
		"output": {
			"item_id": "health_potion",
			"quantity": 1,
		},
	},
}


static func get_recipe(recipe_id: String) -> Dictionary:
	if RECIPES.has(recipe_id):
		return RECIPES[recipe_id].duplicate(true)
	return {}


static func get_all_recipes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for recipe_id in RECIPES:
		result.append(RECIPES[recipe_id].duplicate(true))
	return result
