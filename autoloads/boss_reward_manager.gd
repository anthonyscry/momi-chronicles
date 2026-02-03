extends Node
## BossRewardManager - tracks boss defeats and defines rewards.
## Handles boss progression: defeat tracking, reward queries, save/load integration.

# =============================================================================
# CONSTANTS - BOSS DEFINITIONS
# =============================================================================

## Boss IDs - unique identifiers for each boss
enum BossID {
	ALPHA_RACCOON = 0,
	CROW_MATRIARCH = 1,
	RAT_KING = 2,
	PIGEON_KING = 3
}

## Boss Names - display names for UI
const BOSS_NAMES: Dictionary = {
	BossID.ALPHA_RACCOON: "Alpha Raccoon",
	BossID.CROW_MATRIARCH: "Crow Matriarch",
	BossID.RAT_KING: "Rat King",
	BossID.PIGEON_KING: "Pigeon King"
}

## Boss Reward Types - what each boss unlocks
enum RewardType {
	ZONE_UNLOCK,
	EQUIPMENT_TIER,
	ABILITY_UNLOCK,
	COMPANION_SLOT
}

## Boss Rewards - data structure for each boss's reward
## Fields: type (RewardType), description (String), value (Variant)
const BOSS_REWARDS: Dictionary = {
	BossID.ALPHA_RACCOON: {
		"type": RewardType.ZONE_UNLOCK,
		"description": "Unlocks Backyard Deep zone",
		"value": "backyard_deep"
	},
	BossID.CROW_MATRIARCH: {
		"type": RewardType.EQUIPMENT_TIER,
		"description": "Unlocks Tier 3 Crow Armor",
		"value": 3
	},
	BossID.RAT_KING: {
		"type": RewardType.ZONE_UNLOCK,
		"description": "Unlocks Rooftops access",
		"value": "rooftops"
	},
	BossID.RAT_KING: {
		"type": RewardType.ABILITY_UNLOCK,
		"description": "Grants Poison Resistance",
		"value": "poison_resist"
	},
	BossID.PIGEON_KING: {
		"type": RewardType.COMPANION_SLOT,
		"description": "Unlocks 4th Companion Slot",
		"value": 4
	}
}

# =============================================================================
# STATE
# =============================================================================

var _defeated_bosses: Dictionary = {}

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	DebugLogger.log_system("BossRewardManager initialized")
	_load_from_save_data()

# =============================================================================
# PUBLIC API - DEFEAT TRACKING
# =============================================================================

## Mark boss as defeated with timestamp and trigger save
func mark_boss_defeated(boss_id: BossID) -> void:
	var boss_key = str(boss_id)
	var timestamp = Time.get_unix_time_from_system()
	
	# Record defeat with timestamp
	_defeated_bosses[boss_key] = {
		"timestamp": timestamp,
		"reward_claimed": false
	}
	
	DebugLogger.log_system("Boss defeated: %s at %d" % [BOSS_NAMES.get(boss_id, "Unknown"), timestamp])
	
	# Get reward for this boss
	var reward = get_boss_reward(boss_id)
	
	# Emit boss_defeated signal first (for other systems like mini_boss_base)
	Events.boss_defeated.emit(boss_id)
	
	# Emit reward unlock signal with full reward data
	Events.boss_reward_unlocked.emit(boss_id, reward)
	
	# Trigger save to persist defeat
	if SaveManager:
		SaveManager.save_game()

## Check if boss has been defeated
func is_boss_defeated(boss_id: BossID) -> bool:
	var boss_key = str(boss_id)
	return _defeated_bosses.has(boss_key)

## Get reward data for specific boss
func get_boss_reward(boss_id: BossID) -> Dictionary:
	if not BOSS_REWARDS.has(boss_id):
		DebugLogger.log_error("BossRewardManager: Invalid boss_id %d in get_boss_reward" % boss_id)
		return null
	
	return BOSS_REWARDS[boss_id]

## Get all defeated boss IDs
func get_all_defeated_bosses() -> Array[BossID]:
	var defeated: Array[BossID] = []
	for boss_key in _defeated_bosses.keys():
		var boss_id = int(boss_key)
		if boss_id >= 0 and boss_id <= 3:  # Valid BossID enum values
			defeated.append(boss_id)
	return defeated

## Get human-readable reward description
func get_reward_description(boss_id: BossID) -> String:
	var reward = get_boss_reward(boss_id)
	if reward.is_empty():
		return "No reward"
	
	var reward_type = reward.get("type", RewardType.ZONE_UNLOCK)
	var reward_value = reward.get("value", "")
	
	# Build description based on reward type
	match reward_type:
		RewardType.ZONE_UNLOCK:
			return "Zone unlock: %s" % reward_value
		RewardType.EQUIPMENT_TIER:
			return "Equipment tier %d unlocked" % reward_value
		RewardType.ABILITY_UNLOCK:
			return "Ability: %s" % reward_value
		RewardType.COMPANION_SLOT:
			return "%d companion slots" % reward_value
		_:
			return reward.get("description", "Unknown reward")

# =============================================================================
# PUBLIC API - SAVE/LOAD INTEGRATION
# =============================================================================

## Load boss defeats from save data (called by SaveManager)
func load_defeats(boss_defeats_data: Dictionary) -> void:
	_defeated_bosses = boss_defeats_data.duplicate()
	DebugLogger.log_system("BossRewardManager: Loaded %d defeated bosses from save" % _defeated_bosses.size())

## Get boss defeats for save serialization
func get_save_data() -> Dictionary:
	var save_defeats: Dictionary = {}
	
	for boss_key in _defeated_bosses.keys():
		var defeat_data = _defeated_bosses[boss_key]
		save_defeats[boss_key] = defeat_data
	
	return save_defeats

## Reset all boss defeats (for new game)
func reset_defeats() -> void:
	_defeated_bosses.clear()
	DebugLogger.log_system("BossRewardManager: Boss defeats reset")
