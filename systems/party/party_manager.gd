extends Node
class_name PartyManager

## Preload companion data to avoid autoload parse-time dependency
const _CompanionData = preload("res://systems/party/companion_data.gd")

signal active_companion_changed(companion_id: String)
signal companion_knocked_out(companion_id: String)
signal companion_revived(companion_id: String)
signal companion_meter_changed(companion_id: String, current: float, max_val: float)

## Party order for Q cycling
const PARTY_ORDER: Array[String] = ["momi", "cinnamon", "philo"]

## Currently controlled companion
var active_companion_id: String = "momi"

## Companion instances (populated when zone loads)
var companions: Dictionary = {}  # {id: CompanionBase node}

## Knocked out companions
var knocked_out: Dictionary = {}  # {id: true}

## AI preset per companion
var ai_presets: Dictionary = {
	"momi": _CompanionData.AIPreset.AGGRESSIVE,
	"cinnamon": _CompanionData.AIPreset.DEFENSIVE,
	"philo": _CompanionData.AIPreset.BALANCED,
}

## Pending health/meters from save data (applied when companions register)
var _pending_health: Dictionary = {}  # {companion_id: health_value}
var _pending_meters: Dictionary = {}  # {companion_id: meter_value}

func _ready() -> void:
	# Connect to player damage for Philo's mechanic
	Events.player_damaged.connect(_on_player_damaged)

func _unhandled_input(event: InputEvent) -> void:
	# Q to cycle companion control
	if event.is_action_pressed("cycle_companion"):
		cycle_active_companion()
		get_viewport().set_input_as_handled()

## Cycle to next companion (Q key)
func cycle_active_companion() -> void:
	var current_index = PARTY_ORDER.find(active_companion_id)
	
	# Find next non-knocked-out companion
	for i in range(1, PARTY_ORDER.size() + 1):
		var next_index = (current_index + i) % PARTY_ORDER.size()
		var next_id = PARTY_ORDER[next_index]
		
		if not knocked_out.has(next_id):
			_switch_to_companion(next_id)
			return
	
	# All knocked out - can't switch
	AudioManager.play_sfx("menu_navigate")

func _switch_to_companion(companion_id: String) -> void:
	if active_companion_id == companion_id:
		return
	
	var old_active = active_companion_id
	active_companion_id = companion_id
	
	# Update control modes
	if companions.has(old_active):
		companions[old_active].set_player_controlled(false)
	if companions.has(companion_id):
		companions[companion_id].set_player_controlled(true)
	
	active_companion_changed.emit(companion_id)
	Events.active_companion_changed.emit(companion_id)
	AudioManager.play_sfx("menu_select")

## Register companion instance
func register_companion(companion_id: String, companion_node: Node) -> void:
	companions[companion_id] = companion_node
	companion_node.knocked_out.connect(_on_companion_knocked_out.bind(companion_id))
	companion_node.meter_changed.connect(_on_meter_changed.bind(companion_id))
	
	# Set initial control mode
	companion_node.set_player_controlled(companion_id == active_companion_id)
	
	# Apply pending health/meter from save data (deferred restoration)
	if _pending_health.has(companion_id):
		companion_node.current_health = _pending_health[companion_id]
		companion_node.health_changed.emit(companion_node.current_health, companion_node.max_health)
		_pending_health.erase(companion_id)
	if _pending_meters.has(companion_id):
		companion_node.meter_value = _pending_meters[companion_id]
		companion_node.meter_changed.emit(companion_node.meter_value, companion_node.meter_max)
		_pending_meters.erase(companion_id)

## Knock out a companion
func _on_companion_knocked_out(companion_id: String) -> void:
	knocked_out[companion_id] = true
	companion_knocked_out.emit(companion_id)
	Events.companion_knocked_out.emit(companion_id)
	
	# If active companion knocked out, switch to another
	if companion_id == active_companion_id:
		cycle_active_companion()

## Revive a companion (via item or safe zone)
func revive_companion(companion_id: String, health_percent: float = 0.5) -> void:
	if not knocked_out.has(companion_id):
		return
	
	knocked_out.erase(companion_id)
	
	if companions.has(companion_id):
		companions[companion_id].revive(health_percent)
	
	companion_revived.emit(companion_id)
	Events.companion_revived.emit(companion_id)

## Handle Philo's motivation mechanic - restores when Momi gets hit
func _on_player_damaged(amount: int) -> void:
	# Only trigger if Momi is active (player IS Momi)
	if active_companion_id == "momi" and companions.has("philo"):
		companions["philo"].on_ally_damaged(amount)

## Meter change forwarding
func _on_meter_changed(current: float, max_val: float, companion_id: String) -> void:
	companion_meter_changed.emit(companion_id, current, max_val)
	Events.companion_meter_changed.emit(companion_id, current, max_val)

## Get companion for ring menu
func get_companions_for_ring() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	for companion_id in PARTY_ORDER:
		var data = _CompanionData.get_companion(companion_id)
		data["is_active"] = (companion_id == active_companion_id)
		data["is_knocked_out"] = knocked_out.has(companion_id)
		
		# Get current health/meter if companion exists
		if companions.has(companion_id):
			var comp = companions[companion_id]
			data["current_health"] = comp.get_current_health()
			data["max_health"] = comp.get_max_health()
			data["current_meter"] = comp.get_meter_value()
			data["max_meter"] = comp.get_meter_max()
		
		result.append(data)
	
	return result

## Set AI preset for companion
func set_ai_preset(companion_id: String, preset: int) -> void:
	ai_presets[companion_id] = preset
	if companions.has(companion_id):
		companions[companion_id].set_ai_preset(preset)

## Get active companion node
func get_active_companion() -> Node:
	if companions.has(active_companion_id):
		return companions[active_companion_id]
	return null

## Check if companion is knocked out
func is_knocked_out(companion_id: String) -> bool:
	return knocked_out.has(companion_id)

## Get all living companions (for camera, etc.)
func get_living_companions() -> Array:
	var result = []
	for companion_id in companions:
		if not knocked_out.has(companion_id):
			result.append(companions[companion_id])
	return result

# =============================================================================
# SAVE/LOAD
# =============================================================================

func get_save_data() -> Dictionary:
	var companion_health = {}
	var companion_meters = {}
	for companion_id in companions:
		var comp = companions[companion_id]
		companion_health[companion_id] = comp.get_current_health()
		companion_meters[companion_id] = comp.get_meter_value()
	
	return {
		"active": active_companion_id,
		"knocked_out": knocked_out.keys(),
		"health": companion_health,
		"meters": companion_meters,
		"presets": ai_presets.duplicate(),
	}

func load_save_data(data: Dictionary) -> void:
	active_companion_id = data.get("active", "momi")
	
	knocked_out.clear()
	for ko_id in data.get("knocked_out", []):
		knocked_out[ko_id] = true
	
	ai_presets = data.get("presets", {
		"momi": _CompanionData.AIPreset.AGGRESSIVE,
		"cinnamon": _CompanionData.AIPreset.DEFENSIVE,
		"philo": _CompanionData.AIPreset.BALANCED,
	}).duplicate()
	
	# Store pending health/meters for deferred application
	# (companion nodes don't exist yet — applied in register_companion)
	_pending_health = data.get("health", {})
	_pending_meters = data.get("meters", {})
