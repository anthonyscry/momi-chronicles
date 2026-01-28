extends Node
## Companion Data - Companion definitions for the Bulldog Squad
## NOTE: This is an autoload, so don't use class_name

## Companion roles
enum Role { DPS, TANK, SUPPORT }

## AI behavior presets (configurable from Options ring)
enum AIPreset { AGGRESSIVE, BALANCED, DEFENSIVE }

## Companion definitions - The Bulldog Squad!
const COMPANIONS: Dictionary = {
	"momi": {
		"id": "momi",
		"name": "Momi",
		"breed": "French Bulldog",
		"role": Role.DPS,
		"desc": "The brave leader. Fast attacks and Zoomies mode!",
		"type": "companion",
		"color": Color(0.9, 0.7, 0.5),  # Fawn
		"base_stats": {
			"max_health": 100,
			"attack_damage": 25,
			"move_speed": 80,
			"attack_speed": 1.0,
		},
		"meter": {
			"name": "Zoomies",
			"desc": "Builds from combat. Activate for speed boost!",
			"color": Color(1.0, 0.8, 0.2),  # Yellow/Gold
			"max_value": 100.0,
			"start_value": 0.0,  # Starts empty, builds up
			"build_rate": 5.0,   # Per hit dealt
			"drain_rate": 15.0,  # Per second when active
		},
	},
	"cinnamon": {
		"id": "cinnamon",
		"name": "Cinnamon",
		"breed": "English Bulldog",
		"role": Role.TANK,
		"desc": "The stalwart defender. Blocks hits but watch the heat!",
		"type": "companion",
		"color": Color(0.8, 0.5, 0.3),  # Brown/Cinnamon
		"base_stats": {
			"max_health": 150,
			"attack_damage": 18,
			"move_speed": 60,
			"attack_speed": 0.8,
		},
		"meter": {
			"name": "Overheat",
			"desc": "Builds from blocking. Maxed = forced cooldown!",
			"color": Color(1.0, 0.3, 0.1),  # Red/Orange
			"max_value": 100.0,
			"start_value": 0.0,  # Starts cool
			"build_rate": 10.0,  # Per blocked hit
			"drain_rate": 8.0,   # Per second when not blocking
		},
	},
	"philo": {
		"id": "philo",
		"name": "Philo",
		"breed": "Boston Terrier",
		"role": Role.SUPPORT,
		"desc": "The loyal supporter. Gets motivated when the team needs help!",
		"type": "companion",
		"color": Color(0.2, 0.2, 0.25),  # Black/White
		"base_stats": {
			"max_health": 80,
			"attack_damage": 15,
			"move_speed": 90,
			"attack_speed": 1.2,
		},
		"meter": {
			"name": "Motivation",
			"desc": "Starts high, drains over time. Restores when Momi gets hit!",
			"color": Color(0.3, 0.8, 1.0),  # Cyan/Blue
			"max_value": 100.0,
			"start_value": 100.0,  # STARTS HIGH (unique!)
			"build_rate": 25.0,    # Per Momi damage taken
			"drain_rate": 3.0,     # Per second passive drain
		},
	},
}

## Get companion data
static func get_companion(companion_id: String) -> Dictionary:
	if COMPANIONS.has(companion_id):
		return COMPANIONS[companion_id].duplicate(true)
	return {}

## Get all companions
static func get_all_companions() -> Array:
	var result = []
	for id in COMPANIONS:
		result.append(COMPANIONS[id].duplicate(true))
	return result

## Get role name
static func get_role_name(role: Role) -> String:
	match role:
		Role.DPS: return "DPS"
		Role.TANK: return "Tank"
		Role.SUPPORT: return "Support"
		_: return "Unknown"
