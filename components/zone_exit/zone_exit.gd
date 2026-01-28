class_name ZoneExit
extends Area2D
## Triggers zone transitions when player enters.
## Place at doorways, zone edges, or other transition points.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Unique ID for this exit (e.g., "door_north", "alley_entrance")
@export var exit_id: String = "exit"

## Target zone to load (e.g., "backyard", "neighborhood")
@export var target_zone: String = ""

## Spawn point ID in the target zone (e.g., "from_neighborhood")
@export var target_spawn: String = "default"

## If true, require player to press action to use exit
@export var require_interaction: bool = false

## Visual indicator color
@export var indicator_color: Color = Color(1, 0, 1, 0.5)  # Magenta

# =============================================================================
# STATE
# =============================================================================

var player_in_area: bool = false

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var indicator: ColorRect = $Indicator if has_node("Indicator") else null

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Set up collision
	collision_layer = 0
	collision_mask = 2  # Player layer
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up visual indicator
	if indicator:
		indicator.color = indicator_color


func _unhandled_input(event: InputEvent) -> void:
	if require_interaction and player_in_area:
		if event.is_action_pressed("interact") or event.is_action_pressed("attack"):
			_trigger_transition()

# =============================================================================
# TRANSITION HANDLING
# =============================================================================

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = true
		if not require_interaction:
			_trigger_transition()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = false


func _trigger_transition() -> void:
	if target_zone.is_empty():
		push_warning("ZoneExit %s has no target_zone set" % exit_id)
		return
	
	Events.zone_transition_requested.emit(target_zone, target_spawn)
