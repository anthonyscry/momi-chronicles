extends Node
class_name StateMachine

signal state_changed(old_state: State, new_state: State)

## Path to initial state node (set in inspector)
@export_node_path("Node") var initial_state_path: NodePath

var current_state: State
var states: Dictionary = {}
var _initialized: bool = false

func _ready() -> void:
	# Build states dictionary from children
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
	
	# Debug output
	print("StateMachine ready. States: ", states.keys())

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
		print("Starting state: ", current_state.name)
		current_state.enter()
	else:
		push_error("StateMachine: No initial state found!")

func _physics_process(delta: float) -> void:
	if current_state and _initialized:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state and _initialized:
		current_state.update(delta)

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
	
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()
	print("Transitioned to: ", current_state.name)
