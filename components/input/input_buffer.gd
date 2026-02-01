extends Node
class_name InputBuffer
## Input buffer component for storing and consuming player inputs within a time window.
## Allows inputs to be buffered slightly before they can be executed, improving responsiveness.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Time window (in seconds) that buffered inputs remain valid
@export var buffer_window: float = 0.1

## Maximum number of buffered actions to store (prevent memory issues)
const MAX_BUFFER_SIZE: int = 5

# =============================================================================
# SIGNALS
# =============================================================================

signal action_buffered(action_name: String)
signal action_consumed(action_name: String)
signal buffer_cleared()

# =============================================================================
# STATE
# =============================================================================

## Queue of buffered actions with their timestamps
var _buffered_actions: Array[Dictionary] = []

# =============================================================================
# PUBLIC API
# =============================================================================

## Buffer an input action with the current timestamp
func buffer_action(action_name: String) -> void:
	# Don't buffer if action already exists in buffer
	for buffered in _buffered_actions:
		if buffered.action == action_name:
			return

	# Enforce max buffer size
	if _buffered_actions.size() >= MAX_BUFFER_SIZE:
		_buffered_actions.pop_front()

	_buffered_actions.append({
		"action": action_name,
		"timestamp": Time.get_ticks_msec() / 1000.0
	})

	action_buffered.emit(action_name)

## Consume and return the oldest valid buffered action (removes from buffer)
func consume_buffered_action() -> String:
	_clear_expired_actions()

	if _buffered_actions.is_empty():
		return ""

	var buffered = _buffered_actions.pop_front()
	var action_name = buffered.action

	action_consumed.emit(action_name)
	return action_name

## Check if there's a valid buffered action without consuming it
func peek_buffered_action() -> String:
	_clear_expired_actions()

	if _buffered_actions.is_empty():
		return ""

	return _buffered_actions[0].action

## Check if a specific action is buffered
func has_buffered_action(action_name: String) -> bool:
	_clear_expired_actions()

	for buffered in _buffered_actions:
		if buffered.action == action_name:
			return true

	return false

## Clear all buffered actions
func clear_buffer() -> void:
	if not _buffered_actions.is_empty():
		_buffered_actions.clear()
		buffer_cleared.emit()

## Get the number of currently buffered actions
func get_buffer_size() -> int:
	_clear_expired_actions()
	return _buffered_actions.size()

# =============================================================================
# PRIVATE METHODS
# =============================================================================

## Remove actions that have exceeded the buffer window
func _clear_expired_actions() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	var valid_actions: Array[Dictionary] = []

	for buffered in _buffered_actions:
		var age = current_time - buffered.timestamp
		if age <= buffer_window:
			valid_actions.append(buffered)

	_buffered_actions = valid_actions
