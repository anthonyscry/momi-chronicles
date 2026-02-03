extends Control

const BossRewardManager = preload("res://autoloads/boss_reward_manager.gd")
const Events = preload("res://autoloads/events.gd")
const AudioManager = preload("res://autoloads/audio_manager.gd")

var _current_boss_id: BossRewardManager.BossID = -1
var _reward_data: Array = []

@onready var reward_icon: TextureRect = $PanelContainer/VBoxContainer/RewardIcon
@onready var boss_name_label: Label = $PanelContainer/VBoxContainer/BossNameLabel
@onready var reward_description_label: Label = $PanelContainer/VBoxContainer/RewardDescriptionLabel
@onready var unlock_info_label: Label = $PanelContainer/VBoxContainer/UnlockInfoLabel
@onready var claim_button: Button = $PanelContainer/VBoxContainer/ClaimButton

func _ready() -> void:
	Events.boss_reward_unlocked.connect(_on_reward_unlocked)
	claim_button.pressed.connect(_on_claim_button_pressed)
	hide()

func _on_reward_unlocked(boss_id: BossRewardManager.BossID, rewards: Array) -> void:
	_current_boss_id = boss_id
	_reward_data = rewards

	# Update UI elements
	reward_icon.texture = _get_boss_icon(boss_id)
	boss_name_label.text = "%s DEFEATED!" % BossRewardManager.get_boss_name(boss_id)
	reward_description_label.text = _format_reward_description(_reward_data)
	unlock_info_label.text = _format_unlock_info(_reward_data)

	# Show popup with animation
	show()
	AudioManager.play_sfx("boss_defeat")
	Events.game_paused.emit() # Pause game during reward screen

	# Enable claim button
	claim_button.disabled = false

func _on_claim_button_pressed() -> void:
	if _current_boss_id < 0:
		return

	# Claim reward (mark as received in save)
	BossRewardManager.mark_reward_claimed(_current_boss_id)

	# Emit event for game systems (e.g., UI updates)
	Events.boss_reward_claimed.emit(_current_boss_id, _reward_data)

	# Hide popup and resume game
	hide()
	Events.game_resumed.emit()

func _get_boss_icon(boss_id: BossRewardManager.BossID) -> Texture:
	match boss_id:
		BossRewardManager.BossID.ALPHA_RACCOON:
			return load("res://art/generated/enemies/alpha_raccoon.png")
		BossRewardManager.BossID.CROW_MATRIARCH:
			return load("res://art/generated/enemies/crow_matriarch.png")
		BossRewardManager.BossID.RAT_KING:
			return load("res://art/generated/enemies/rat_king.png")
		BossRewardManager.BossID.PIGEON_KING:
			return load("res://art/generated/enemies/pigeon_king.png")
		_:
			return load("res://art/generated/enemies/crow_matriarch.png")

func _format_reward_description(rewards: Array) -> String:
	if rewards.is_empty():
		return "Reward unlocked"
	var parts: Array = []
	for reward in rewards:
		parts.append(reward.get("description", "Reward unlocked"))
	return "\n".join(parts)

func _format_unlock_info(rewards: Array) -> String:
	if rewards.is_empty():
		return "Reward Unlocked!"
	var lines: Array = []
	for reward_data in rewards:
		match reward_data.get("type", BossRewardManager.RewardType.ZONE_UNLOCK):
			BossRewardManager.RewardType.ZONE_UNLOCK:
				lines.append("Zone Unlocked: %s" % reward_data.get("value", ""))
			BossRewardManager.RewardType.EQUIPMENT_TIER:
				lines.append("Equipment Tier %d Unlocked!" % reward_data.get("value", 0))
			BossRewardManager.RewardType.ABILITY_UNLOCK:
				lines.append("Ability Unlocked: %s" % reward_data.get("value", ""))
			BossRewardManager.RewardType.COMPANION_SLOT:
				lines.append("Companion Slot Unlocked!")
			_:
				lines.append("Reward Unlocked!")
	return "\n".join(lines)
