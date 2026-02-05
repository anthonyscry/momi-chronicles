# Vertical Slice Implementation Plan (Neighborhood -> Sewers)

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the vertical slice content (quests, Echo Room set-piece, quest pickups, and minimal crafting) for a 30-60 minute playable loop.

**Architecture:** Extend the existing QuestManager data-driven quest definitions, reuse QuestItemPickup for gated collectibles, and add a simple Area2D trigger in `sewers.gd` to drive the Echo Room cutscene. Add a small crafting catalog/manager used by ShopUI (no new gameplay logic in autoloads).

**Tech Stack:** Godot 4.5, GDScript, JSON dialogue resources, existing quest/event systems.

---

### Task 1: Add vertical slice quests (Missing Bait, Echoes in the Pipes, Guard the Grate)

**Files:**
- Create: `tests/test_vertical_slice_quests.gd`
- Modify: `autoloads/quest_manager.gd`

**Step 1: Write the failing test**

Create `tests/test_vertical_slice_quests.gd`:

```gdscript
extends Node

func _ready() -> void:
	var quest_manager = preload("res://autoloads/quest_manager.gd").new()
	quest_manager._register_all_quests()

	var required_ids = [
		"missing_bait",
		"echoes_in_pipes",
		"guard_grate",
	]

	for quest_id in required_ids:
		assert(quest_manager.available_quests.has(quest_id), "Missing quest: %s" % quest_id)

	get_tree().quit()
```

**Step 2: Run test to verify it fails**

Run:
`godot --headless --script tests/test_vertical_slice_quests.gd`

Expected: FAIL with assertion "Missing quest: missing_bait" (or next missing ID).

**Step 3: Write minimal implementation**

In `autoloads/quest_manager.gd`, add three new QuestData blocks at the end of `_register_all_quests()`:

```gdscript
	# Quest 10: Missing Bait (Maurice)
	var q10 = QuestData.new()
	q10.id = "missing_bait"
	q10.title = "Missing Bait"
	q10.description = "Maurice lost a bait box in the sewers. Recover it so he can finish his route."
	q10.is_main_quest = false
	q10.quest_giver_id = "maurice"
	q10.prerequisite_quest_ids = ["meet_neighbors"]
	q10.objective_descriptions = [
		"Defeat 3 sewer rats",
		"Find the bait box in the sewers",
		"Return to Maurice",
	]
	q10.optional_objectives = [false, false, false]
	q10.objective_trigger_types = ["enemy_kill", "item_collect", "dialogue"]
	q10.objective_trigger_ids = ["sewer_rat", "bait_box", "maurice"]
	q10.objective_target_counts = [3, 1, 1]
	q10.objective_requires_prior = [false, true, true]
	q10.rewards = {"coins": 60, "exp": 35, "reputation": {"maurice": 10}}
	register_quest_data(q10)

	# Quest 11: Echoes in the Pipes (Gertrude)
	var q11 = QuestData.new()
	q11.id = "echoes_in_pipes"
	q11.title = "Echoes in the Pipes"
	q11.description = "Gertrude heard a voice in the sewers. Find the Echo Room and report back."
	q11.is_main_quest = true
	q11.quest_giver_id = "gertrude"
	q11.prerequisite_quest_ids = ["meet_neighbors"]
	q11.objective_descriptions = [
		"Find the Echo Room in the sewers",
		"Return to Gertrude",
	]
	q11.optional_objectives = [false, false]
	q11.objective_trigger_types = ["dialogue", "dialogue"]
	q11.objective_trigger_ids = ["echo_room_memory", "gertrude"]
	q11.objective_target_counts = [1, 1]
	q11.objective_requires_prior = [false, true]
	q11.rewards = {"coins": 80, "exp": 45, "reputation": {"gertrude": 10}}
	register_quest_data(q11)

	# Quest 12: Guard the Grate (Henderson)
	var q12 = QuestData.new()
	q12.id = "guard_grate"
	q12.title = "Guard the Grate"
	q12.description = "Henderson wants the sewer grate secured. Clear the pests and restore the valve."
	q12.is_main_quest = false
	q12.quest_giver_id = "henderson"
	q12.prerequisite_quest_ids = ["meet_neighbors"]
	q12.objective_descriptions = [
		"Defeat 5 enemies near the grate",
		"Restore the broken valve",
		"Report back to Henderson",
	]
	q12.optional_objectives = [false, false, false]
	q12.objective_trigger_types = ["enemy_kill", "item_collect", "dialogue"]
	q12.objective_trigger_ids = ["any", "valve_wheel", "henderson"]
	q12.objective_target_counts = [5, 1, 1]
	q12.objective_requires_prior = [false, true, true]
	q12.rewards = {"coins": 90, "exp": 50, "reputation": {"henderson": 15}}
	register_quest_data(q12)
```

**Step 4: Run test to verify it passes**

Run:
`godot --headless --script tests/test_vertical_slice_quests.gd`

Expected: PASS (exit code 0, no assertion failures).

**Step 5: Commit**

```bash
git add tests/test_vertical_slice_quests.gd autoloads/quest_manager.gd
git commit -m "feat(quests): add vertical slice quest definitions"
```

---

### Task 2: Add Echo Room cutscene dialogue resource

**Files:**
- Create: `resources/dialogues/echo_room.json`
- Create: `tests/test_echo_room_dialogue.gd`

**Step 1: Write the failing test**

Create `tests/test_echo_room_dialogue.gd`:

```gdscript
extends Node

func _ready() -> void:
	var dialogue_data = preload("res://systems/dialogue/dialogue_data.gd")
	var dialogues = dialogue_data.load_dialogue_file("res://resources/dialogues/echo_room.json")
	assert(dialogues.has("echo_room_memory"), "Missing echo_room_memory dialogue")
	assert(dialogues["echo_room_memory"].is_cutscene, "Echo Room dialogue must be cutscene")
	get_tree().quit()
```

**Step 2: Run test to verify it fails**

Run:
`godot --headless --script tests/test_echo_room_dialogue.gd`

Expected: FAIL because `echo_room.json` does not exist yet.

**Step 3: Write minimal implementation**

Create `resources/dialogues/echo_room.json`:

```json
{
  "dialogues": [
    {
      "id": "echo_room_memory",
      "character": "Echo Chamber",
      "portrait": "",
      "text": "A crackling tape hisses to life... 'If anyone hears this, protect the neighborhood. The hoarder below isn't a myth.'",
      "choices": [],
      "next_id": "echo_room_memory_2",
      "is_cutscene": true
    },
    {
      "id": "echo_room_memory_2",
      "character": "Echo Chamber",
      "portrait": "",
      "text": "'We kept their hunger at bay, but the tunnels are changing. Keep your pack close.'",
      "choices": [],
      "next_id": "",
      "is_cutscene": true
    }
  ]
}
```

**Step 4: Run test to verify it passes**

Run:
`godot --headless --script tests/test_echo_room_dialogue.gd`

Expected: PASS (exit code 0, no assertion failures).

**Step 5: Commit**

```bash
git add resources/dialogues/echo_room.json tests/test_echo_room_dialogue.gd
git commit -m "feat(dialogue): add echo room cutscene"
```

---

### Task 3: Add Echo Room trigger and quest pickups in Sewers

**Files:**
- Modify: `world/zones/sewers.gd`

**Step 1: Write the failing test**

Add a manual test entry to `tests/MANUAL_TEST_CHECKLIST.md` (new section "Vertical Slice - Echo Room") that includes:
- Enter sewers while `echoes_in_pipes` is active
- Walk into Echo Room
- Expected: cutscene starts, player input disabled
- Expected: quest objective completes after cutscene

**Step 2: Run test to verify it fails**

Run:
`godot --path .`

Expected: Echo Room cutscene does not trigger; no quest completion.

**Step 3: Write minimal implementation**

In `world/zones/sewers.gd`:

- Add preload:
```gdscript
const QuestItemPickupScript = preload("res://components/quest_item_pickup/quest_item_pickup.gd")
```

- Add state flag:
```gdscript
var _echo_room_triggered: bool = false
```

- Add a new side room entry in `side_rooms` (type "echo_room") and create a new helper to build decorations and trigger:
```gdscript
{
	"rect": Rect2(620, 110, 90, 80),
	"type": "echo_room",
	"connector": Rect2(640, 190, 48, 16),
},
```

- Add `_build_echo_room()`:
```gdscript
func _build_echo_room() -> void:
	var echo_center = Vector2(665, 150)

	var altar = ColorRect.new()
	altar.name = "EchoAltar"
	altar.position = echo_center + Vector2(-12, -6)
	altar.size = Vector2(24, 12)
	altar.color = Color(0.2, 0.22, 0.28)
	add_child(altar)

	var shimmer = ColorRect.new()
	shimmer.name = "EchoShimmer"
	shimmer.position = echo_center + Vector2(-10, -22)
	shimmer.size = Vector2(20, 6)
	shimmer.color = Color(0.6, 0.7, 0.9, 0.4)
	add_child(shimmer)

	var trigger = Area2D.new()
	trigger.name = "EchoRoomTrigger"
	trigger.position = echo_center
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	add_child(trigger)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(60, 40)
	shape.shape = rect
	trigger.add_child(shape)

	trigger.body_entered.connect(_on_echo_room_triggered)
```

- Add trigger handler:
```gdscript
func _on_echo_room_triggered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _echo_room_triggered:
		return
	if not QuestManager.is_quest_active("echoes_in_pipes"):
		return
	_echo_room_triggered = true
	DialogueManager.start_dialogue("echo_room_memory")
```

- Add quest pickups builder:
```gdscript
func _build_quest_pickups() -> void:
	var bait = Area2D.new()
	bait.set_script(QuestItemPickupScript)
	bait.name = "BaitBoxPickup"
	bait.item_id = "bait_box"
	bait.quest_id = "missing_bait"
	bait.pickup_color = Color(0.8, 0.5, 0.2)
	bait.label_text = "Bait"
	bait.position = Vector2(300, 510)
	add_child(bait)

	var valve = Area2D.new()
	valve.set_script(QuestItemPickupScript)
	valve.name = "ValveWheelPickup"
	valve.item_id = "valve_wheel"
	valve.quest_id = "guard_grate"
	valve.pickup_color = Color(0.6, 0.6, 0.7)
	valve.label_text = "Valve"
	valve.position = Vector2(830, 420)
	add_child(valve)
```

- Call new builders in `_setup_zone()`:
```gdscript
DialogueManager.load_dialogue_file("res://resources/dialogues/echo_room.json")
_build_echo_room()
_build_quest_pickups()
```

**Step 4: Run test to verify it passes**

Run:
`godot --path .`

Expected:
- Echo Room cutscene triggers once when quest active
- Bait/Valve pickups appear only when corresponding quest is active

**Step 5: Commit**

```bash
git add world/zones/sewers.gd tests/MANUAL_TEST_CHECKLIST.md
git commit -m "feat(sewers): add echo room trigger and quest pickups"
```

---

### Task 4: Update NPC dialogues with quest hooks

**Files:**
- Modify: `resources/dialogues/maurice.json`
- Modify: `resources/dialogues/gertrude.json`
- Modify: `resources/dialogues/henderson.json`

**Step 1: Write the failing test**

Add a manual test entry to `tests/MANUAL_TEST_CHECKLIST.md` ("Vertical Slice - Dialogue Hooks"):
- Talk to Maurice, Gertrude, Henderson
- Expected: new quest-related lines appear

**Step 2: Run test to verify it fails**

Run:
`godot --path .`

Expected: dialogues do not mention Missing Bait / Echo Room / Guard the Grate.

**Step 3: Write minimal implementation**

Add new dialogue nodes and hook them from existing choices. Example for Maurice:

```json
{
  "id": "maurice_bait",
  "character": "Mailman Maurice",
  "portrait": "",
  "text": "I dropped a bait box down the manhole. If you find it, I can finish my route.",
  "choices": [],
  "next_id": "",
  "is_cutscene": false
}
```

Repeat with Gertrude (Echo Room hint) and Henderson (Guard the Grate request), then add a new choice from their start/repeat nodes to these entries.

**Step 4: Run test to verify it passes**

Run:
`godot --path .`

Expected: new quest-related lines appear in each NPC dialogue.

**Step 5: Commit**

```bash
git add resources/dialogues/maurice.json resources/dialogues/gertrude.json resources/dialogues/henderson.json tests/MANUAL_TEST_CHECKLIST.md
git commit -m "docs(dialogue): add vertical slice quest hooks"
```

---

### Task 5: Add minimal crafting data (materials + recipes)

**Files:**
- Modify: `systems/inventory/item_database.gd`
- Modify: `systems/shop/shop_catalog.gd`
- Create: `systems/crafting/crafting_catalog.gd`
- Create: `systems/crafting/crafting_manager.gd`
- Create: `tests/test_crafting_recipes.gd`

**Step 1: Write the failing test**

Create `tests/test_crafting_recipes.gd`:

```gdscript
extends Node

func _ready() -> void:
	var inventory = Inventory.new()
	inventory.add_item("rat_gland", 1)
	inventory.add_item("herb", 1)

	var crafting_manager = preload("res://systems/crafting/crafting_manager.gd")
	var success = crafting_manager.craft("antidote_recipe", inventory)
	assert(success, "Crafting should succeed")
	assert(inventory.has_item("antidote", 1), "Antidote should be crafted")
	get_tree().quit()
```

**Step 2: Run test to verify it fails**

Run:
`godot --headless --script tests/test_crafting_recipes.gd`

Expected: FAIL because crafting files and items are missing.

**Step 3: Write minimal implementation**

- Add material items to `systems/inventory/item_database.gd`:

```gdscript
"rat_gland": {
	"id": "rat_gland",
	"name": "Rat Gland",
	"desc": "Gross, but useful. A crafting material.",
	"type": "material",
	"consumable": false,
	"stackable": true,
	"max_stack": 20,
	"color": Color(0.5, 0.6, 0.4),
	"icon": "res://art/generated/items/rat_gland.png",
},
"herb": {
	"id": "herb",
	"name": "Herb",
	"desc": "A soothing herb used in remedies.",
	"type": "material",
	"consumable": false,
	"stackable": true,
	"max_stack": 20,
	"color": Color(0.3, 0.8, 0.3),
	"icon": "res://art/generated/items/herb.png",
},
```

- Add shop stock for materials in `systems/shop/shop_catalog.gd`:

```gdscript
SHOP_ITEMS["rat_gland"] = 8
SHOP_ITEMS["herb"] = 6
DEFAULT_ITEM_STOCK["rat_gland"] = 5
DEFAULT_ITEM_STOCK["herb"] = 8
```

- Create `systems/crafting/crafting_catalog.gd`:

```gdscript
extends Node

const RECIPES: Dictionary = {
	"antidote_recipe": {
		"id": "antidote_recipe",
		"name": "Antidote",
		"inputs": {"rat_gland": 1, "herb": 1},
		"output": {"item_id": "antidote", "quantity": 1},
	},
	"potion_recipe": {
		"id": "potion_recipe",
		"name": "Health Potion",
		"inputs": {"acorn": 2, "bird_seed": 2},
		"output": {"item_id": "health_potion", "quantity": 1},
	},
}

static func get_recipe(recipe_id: String) -> Dictionary:
	return RECIPES.get(recipe_id, {})

static func get_all_recipes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for recipe_id in RECIPES:
		result.append(RECIPES[recipe_id])
	return result
```

- Create `systems/crafting/crafting_manager.gd`:

```gdscript
extends Node

static func can_craft(recipe_id: String, inventory: Inventory = null) -> bool:
	if inventory == null:
		inventory = GameManager.inventory
	if inventory == null:
		return false
	var recipe = CraftingCatalog.get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	for item_id in recipe.inputs:
		if not inventory.has_item(item_id, recipe.inputs[item_id]):
			return false
	return true

static func craft(recipe_id: String, inventory: Inventory = null) -> bool:
	if inventory == null:
		inventory = GameManager.inventory
	if not can_craft(recipe_id, inventory):
		return false
	var recipe = CraftingCatalog.get_recipe(recipe_id)
	for item_id in recipe.inputs:
		inventory.remove_item(item_id, recipe.inputs[item_id])
	var output = recipe.output
	return inventory.add_item(output.item_id, output.quantity)
```

**Step 4: Run test to verify it passes**

Run:
`godot --headless --script tests/test_crafting_recipes.gd`

Expected: PASS (exit code 0, no assertion failures).

**Step 5: Commit**

```bash
git add systems/inventory/item_database.gd systems/shop/shop_catalog.gd \
  systems/crafting/crafting_catalog.gd systems/crafting/crafting_manager.gd \
  tests/test_crafting_recipes.gd
git commit -m "feat(crafting): add minimal recipes and materials"
```

---

### Task 6: Integrate Crafting into Shop UI

**Files:**
- Modify: `ui/shop/shop_ui.gd`

**Step 1: Write the failing test**

Add a manual test entry to `tests/MANUAL_TEST_CHECKLIST.md` ("Vertical Slice - Crafting UI"):
- Open shop
- Switch to Craft category
- Craft Antidote using materials
- Expected: materials removed, antidote added

**Step 2: Run test to verify it fails**

Run:
`godot --path .`

Expected: Shop has no Craft category.

**Step 3: Write minimal implementation**

In `ui/shop/shop_ui.gd`:

- Add category constant:
```gdscript
const CATEGORY_CRAFT: int = 2
```

- Update category cycling to include craft when `current_tab == 0` (BUY).

- When `current_category == CATEGORY_CRAFT`, build list from recipes:
```gdscript
current_list = CraftingCatalog.get_all_recipes()
```

- Update detail panel to show ingredients instead of price:
```gdscript
detail_price.text = "Ingredients: %s" % _format_recipe_inputs(recipe.inputs)
```

- Add craft action on confirm:
```gdscript
if current_category == CATEGORY_CRAFT and current_tab == 0:
	if CraftingManager.craft(recipe.id):
		_flash_success()
	else:
		_flash_fail()
```

**Step 4: Run test to verify it passes**

Run:
`godot --path .`

Expected: Craft category appears; crafting consumes materials and adds output item.

**Step 5: Commit**

```bash
git add ui/shop/shop_ui.gd tests/MANUAL_TEST_CHECKLIST.md
git commit -m "feat(ui): add crafting tab to shop"
```

---

### Task 7: Add a vertical slice manual test checklist

**Files:**
- Modify: `tests/MANUAL_TEST_CHECKLIST.md`

**Step 1: Write the failing test**

Add a new section "Vertical Slice - Full Run" with:
- Start New Game
- Accept Missing Bait, Echoes in the Pipes, Guard the Grate
- Complete objectives in Sewers
- Trigger Echo Room cutscene
- Return to town and turn in
- Craft an Antidote

**Step 2: Run test to verify it fails**

Run:
`godot --path .`

Expected: checklist steps not present.

**Step 3: Write minimal implementation**

Add the new checklist section with expected results for each step.

**Step 4: Run test to verify it passes**

Run:
`godot --path .`

Expected: full vertical slice run is verifiable with clear pass/fail notes.

**Step 5: Commit**

```bash
git add tests/MANUAL_TEST_CHECKLIST.md
git commit -m "docs(test): add vertical slice manual checklist"
```

---

## Notes / Guardrails
- Use `DebugLogger` instead of `print()` in gameplay code.
- Use `preload()` for scenes/scripts; avoid runtime `load()` during gameplay.
- Use `QuestItemPickup` for quest-only collectibles (bait_box, valve_wheel).
- Keep Echo Room trigger gated by active quest to avoid repeated cutscene.

## Verification Summary (expected)
- `godot --headless --script tests/test_vertical_slice_quests.gd`
- `godot --headless --script tests/test_echo_room_dialogue.gd`
- `godot --headless --script tests/test_crafting_recipes.gd`
- Manual checklist entries in `tests/MANUAL_TEST_CHECKLIST.md`
