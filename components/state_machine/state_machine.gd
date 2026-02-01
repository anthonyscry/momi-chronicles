extends Node
class_name StateMachine
## StateMachine — Generic hierarchical state machine component.
## Attach as a child node and add State-derived children for each behavior.
## Delegates _process/_physics_process to the active state and provides
## transition_to(name) for switching states with enter()/exit() lifecycle.
##
## Usage:
##   1. Add StateMachine as a child of your entity (Player, Enemy, etc.)
##   2. Add State-derived nodes as children of the StateMachine
##   3. Set initial_state_path in the inspector or rely on first-child fallback
##   4. Call state_machine.init(entity) from the entity's _ready()
##   5. Call state_machine.transition_to("state_name") to change states

# =============================================================================
# SIGNALS
# =============================================================================

signal state_changed(old_state: State, new_state: State)

# =============================================================================
# CONFIGURATION
# =============================================================================

## Path to initial state node (set in inspector)
@export_node_path("Node") var initial_state_path: NodePath

# =============================================================================
# STATE
# =============================================================================

var current_state: State
var states: Dictionary = {}
var _initialized: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Build states dictionary from children
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self

	DebugLogger.log_ai("StateMachine ready. States: %s" % [states.keys()])


func init(entity: CharacterBody2D) -> void:
	# Pass entity reference to all states
	for child in get_children():
		if child is State:
			child.player = entity
			child.state_machine = self

	# Get initial state from path or first child
	var initial_state: State = null

	if initial_state_path and has_node(initial_state_path):
		initial_state = get_node(initial_state_path) as State

	# Fallback: use first state child
	if not initial_state:
		for child in get_children():
			if child is State:
				initial_state = child
				break

	# Start initial state
	if initial_state and not _initialized:
		_initialized = true
		current_state = initial_state
		DebugLogger.log_ai("Starting state: %s" % current_state.name)
		current_state.enter()
	else:
		push_error("StateMachine: No initial state found!")


func _physics_process(delta: float) -> void:
	if current_state and _initialized:
		current_state.physics_update(delta)


func _process(delta: float) -> void:
	if current_state and _initialized:
		current_state.update(delta)

# =============================================================================
# PUBLIC API
# =============================================================================

func transition_to(state_name: String) -> void:
	if not _initialized:
		return

	var target = state_name.to_lower()

	if not states.has(target):
		push_error("State not found: %s. Available: %s" % [state_name, states.keys()])
		return

	var new_state: State = states[target]

	if new_state == current_state:
		return

	var old_state := current_state

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
	DebugLogger.log_ai("State transition: %s -> %s" % [
		old_state.name if old_state else "NONE", current_state.name])
	state_changed.emit(old_state, current_state)
