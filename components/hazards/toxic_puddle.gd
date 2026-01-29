extends Area2D
## Environmental hazard that applies poison DoT when the player steps on it.
## Obvious puddles glow bright green with bubbling animation.
## Camouflaged puddles are subtle dark green and harder to spot.
##
## Usage: Instance in any zone scene. Configure exports per placement.

# =============================================================================
# CONFIGURATION
# =============================================================================

## Damage per poison tick
@export var poison_damage: int = 2

## How long poison lasts after leaving the puddle
@export var poison_duration: float = 3.0

## Re-poison cooldown while standing in puddle
@export var reapply_interval: float = 1.5

## Obvious (bright green) vs hidden (dark subtle)
@export var is_camouflaged: bool = false

## Size of the puddle area
@export var puddle_size: Vector2 = Vector2(24, 16)

# =============================================================================
# STATE
# =============================================================================

var _reapply_timer: float = 0.0
var _player_in_puddle: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2  # Player layer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_setup_visuals()


func _process(delta: float) -> void:
	if _player_in_puddle:
		_reapply_timer += delta
		if _reapply_timer >= reapply_interval:
			_reapply_timer = 0.0
			var player = get_tree().get_first_node_in_group("player")
			if player:
				_apply_poison(player)

# =============================================================================
# VISUALS
# =============================================================================

func _setup_visuals() -> void:
	# Collision shape
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape"
	var shape = RectangleShape2D.new()
	shape.size = puddle_size
	collision.shape = shape
	add_child(collision)
	
	# Visual puddle
	var visual = ColorRect.new()
	visual.name = "PuddleVisual"
	if not is_camouflaged:
		visual.color = Color(0.3, 0.8, 0.2, 0.6)  # Bright green glow
	else:
		visual.color = Color(0.15, 0.25, 0.12, 0.4)  # Subtle dark green
	visual.size = puddle_size
	visual.position = -puddle_size / 2  # Centered on Area2D origin
	add_child(visual)
	
	# Bubbling animation for obvious puddles
	if not is_camouflaged:
		_start_bubbling(visual)


func _start_bubbling(visual: ColorRect) -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(visual, "modulate:a", 0.5, 0.8)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(visual, "modulate:a", 0.8, 0.8)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

# =============================================================================
# COLLISION HANDLERS
# =============================================================================

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_puddle = true
		_reapply_timer = 0.0
		_apply_poison(body)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_puddle = false

# =============================================================================
# POISON APPLICATION
# =============================================================================

func _apply_poison(body: Node) -> void:
	var health_comp = body.get_node_or_null("HealthComponent")
	if health_comp and health_comp.has_method("apply_poison"):
		health_comp.apply_poison(poison_damage, poison_duration)
