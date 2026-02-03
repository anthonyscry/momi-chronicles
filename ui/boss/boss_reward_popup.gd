extends Control

var _current_boss_id: int = -1
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

func _on_reward_unlocked(boss_id: int, rewards: Array) -> void:
	_current_boss_id = boss_id
	_reward_data = rewards

	# Update UI elements
	reward_icon.texture = BossRewardManager.get_boss_icon_texture(boss_id)
	boss_name_label.text = "%s DEFEATED!" % BossRewardManager.get_boss_name(boss_id)
	
	# Format reward description
	if rewards.is_empty():
		reward_description_label.text = "Reward unlocked"
	else:
		var parts = []
		for r in rewards:
			parts.append(r.get("description", "Reward unlocked"))
		reward_description_label.text = "\n".join(parts)
	
	# Format unlock info
	if rewards.is_empty():
		unlock_info_label.text = "Reward Unlocked!"
	else:
		var lines = []
		for r in rewards:
			match r.get("type", BossRewardManager.RewardType.ZONE_UNLOCK):
				BossRewardManager.RewardType.ZONE_UNLOCK:
					lines.append("Zone Unlocked: %s" % r.get("value", ""))
				BossRewardManager.RewardType.EQUIPMENT_TIER:
					lines.append("Equipment Tier %d Unlocked!" % r.get("value", 0))
				BossRewardManager.RewardType.ABILITY_UNLOCK:
					lines.append("Ability Unlocked: %s" % r.get("value", ""))
				BossRewardManager.RewardType.COMPANION_SLOT:
					lines.append("Companion Slot Unlocked!")
				_: lines.append("Reward Unlocked!")
		unlock_info_label.text = "\n".join(lines)

	# Show popup with animation
	show()
	AudioManager.play_sfx("boss_defeat")
	Events.game_paused.emit()
	claim_button.disabled = false

func _on_claim_button_pressed() -> void:
	if _current_boss_id < 0: return
	BossRewardManager.mark_reward_claimed(_current_boss_id)
	var first_reward = _reward_data[0] if _reward_data.size() > 0 else {}
	Events.boss_reward_claimed.emit(_current_boss_id, first_reward)
	hide()
	Events.game_resumed.emit()
