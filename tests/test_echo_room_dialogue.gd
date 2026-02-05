extends Node

func _ready() -> void:
	var dialogues = DialogueData.load_dialogue_file("res://resources/dialogues/echo_room.json")
	assert(dialogues.has("echo_room_memory"))
	assert(dialogues["echo_room_memory"].is_cutscene)
	get_tree().quit()
