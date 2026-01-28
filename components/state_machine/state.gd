extends Node
class_name State
## Base class for all states. Extend this class and override the virtual methods.
## States are children of a StateMachine node and handle specific behaviors.

# =============================================================================
# REFERENCES (set by StateMachine.init())
# =============================================================================

## Reference to the entity this state controls (usually Player or Enemy)
var player: CharacterBody2D

## Reference to the parent state machine
var state_machine: StateMachine

# =============================================================================
# VIRTUAL METHODS - Override these in child states
# =============================================================================

## Called when entering this state
func enter() -> void:
	pass

## Called when exiting this state
func exit() -> void:
	pass

## Called every frame (connect to _process)
func update(_delta: float) -> void:
	pass

## Called every physics frame (connect to _physics_process)
func physics_update(_delta: float) -> void:
	pass

## Called for input events (connect to _unhandled_input)
func handle_input(_event: InputEvent) -> void:
	pass
