extends Node
## Singleton managing the current difficulty level and providing difficulty query methods.
## Emits Events.difficulty_changed when difficulty is modified.

## Current difficulty level
var current_difficulty: DifficultySettings.Difficulty = DifficultySettings.Difficulty.NORMAL

## Current difficulty settings cache
var _current_settings: DifficultySettings = null


func _ready() -> void:
	# Initialize with default difficulty (Normal)
	_current_settings = DifficultySettings.get_settings(current_difficulty)
	Events.difficulty_system_ready.emit()


## Get current difficulty level
func get_difficulty() -> DifficultySettings.Difficulty:
	return current_difficulty


## Set difficulty level and emit change event
func set_difficulty(level: DifficultySettings.Difficulty) -> void:
	if level == current_difficulty:
		return

	current_difficulty = level
	_current_settings = DifficultySettings.get_settings(level)
	Events.difficulty_changed.emit(level)
	DebugLogger.log_system("Difficulty changed to: %s" % DifficultySettings.get_difficulty_name(level))


## Get current difficulty settings
func get_settings() -> DifficultySettings:
	return _current_settings


## Get enemy damage multiplier for current difficulty
func get_damage_multiplier() -> float:
	return _current_settings.damage_multiplier


## Get health drop multiplier for current difficulty
func get_drop_multiplier() -> float:
	return _current_settings.drop_multiplier


## Get AI aggression multiplier for current difficulty
func get_ai_aggression_multiplier() -> float:
	return _current_settings.ai_aggression_multiplier


## Get human-readable name of current difficulty
func get_difficulty_name() -> String:
	return _current_settings.difficulty_name


## Get description of current difficulty
func get_description() -> String:
	return _current_settings.description
