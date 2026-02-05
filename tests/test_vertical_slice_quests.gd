extends Node
## Test script to verify vertical slice quest registration.

func _ready() -> void:
	await get_tree().process_frame
	test_vertical_slice_quests_registered()
	get_tree().quit()

func test_vertical_slice_quests_registered() -> void:
	var quest_ids = [
		"missing_bait",
		"echoes_in_pipes",
		"guard_grate"
	]

	for quest_id in quest_ids:
		assert(QuestManager.is_quest_available(quest_id))
