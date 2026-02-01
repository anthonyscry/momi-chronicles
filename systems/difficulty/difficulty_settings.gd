extends Resource
class_name DifficultySettings
## Resource defining difficulty level data and multipliers.
## Contains settings for Story Mode, Normal, and Challenge difficulties.

## Difficulty levels enum
enum Difficulty {
	STORY = 0,    ## Easy mode: reduced damage, increased drops, slower AI
	NORMAL = 1,   ## Balanced mode: game as designed
	CHALLENGE = 2 ## Hard mode: increased damage, fewer drops, aggressive AI
}

## Difficulty level
@export var difficulty: Difficulty = Difficulty.NORMAL

## Multiplier for enemy damage output (0.5 = half damage, 1.5 = 50% more damage)
@export var damage_multiplier: float = 1.0

## Multiplier for health drop rates (2.0 = double drops, 0.5 = half drops)
@export var drop_multiplier: float = 1.0

## Multiplier for AI aggression/speed (affects attack cooldowns, movement speed)
@export var ai_aggression_multiplier: float = 1.0

## Human-readable name
@export var difficulty_name: String = "Normal"

## Description of what this difficulty changes
@export var description: String = "Balanced gameplay as designed"


## Get settings for a specific difficulty level
static func get_settings(level: Difficulty) -> DifficultySettings:
	var settings = DifficultySettings.new()
	settings.difficulty = level

	match level:
		Difficulty.STORY:
			settings.difficulty_name = "Story Mode"
			settings.description = "Focus on exploration and narrative.\nEnemies deal 50% less damage.\nHealth drops doubled.\nSlower enemy attacks."
			settings.damage_multiplier = 0.5
			settings.drop_multiplier = 2.0
			settings.ai_aggression_multiplier = 0.7

		Difficulty.NORMAL:
			settings.difficulty_name = "Normal"
			settings.description = "Balanced gameplay as designed.\nStandard enemy damage and drops.\nNormal enemy behavior."
			settings.damage_multiplier = 1.0
			settings.drop_multiplier = 1.0
			settings.ai_aggression_multiplier = 1.0

		Difficulty.CHALLENGE:
			settings.difficulty_name = "Challenge"
			settings.description = "Test your combat skills.\nEnemies deal 50% more damage.\nHealth drops reduced.\nFaster, more aggressive enemies."
			settings.damage_multiplier = 1.5
			settings.drop_multiplier = 0.5
			settings.ai_aggression_multiplier = 1.3

	return settings


## Get difficulty name string
static func get_difficulty_name(level: Difficulty) -> String:
	match level:
		Difficulty.STORY:
			return "Story Mode"
		Difficulty.NORMAL:
			return "Normal"
		Difficulty.CHALLENGE:
			return "Challenge"
		_:
			return "Unknown"
