extends CharacterBody2D
class_name TestDummy
## A static test dummy for testing combat. Does not move or fight back.

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var health: HealthComponent = $HealthComponent

# =============================================================================
# STATE
# =============================================================================

var flash_timer: float = 0.0
var is_flashing: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect signals
	if hurtbox:
		hurtbox.hurt.connect(_on_hurt)
	if health:
		health.died.connect(_on_died)
		health.damage_taken.connect(_on_damage_taken)

func _process(delta: float) -> void:
	# Handle flash effect
	if is_flashing:
		flash_timer -= delta
		if flash_timer <= 0:
			is_flashing = false
			sprite.modulate = Color.WHITE

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_hurt(hitbox: Hitbox) -> void:
	if health:
		health.take_damage(hitbox.damage)

func _on_damage_taken(amount: int) -> void:
	# Flash red when hit
	_flash_damage()
	print("Test dummy took %d damage! Health: %d/%d" % [amount, health.current_health, health.max_health])

func _on_died() -> void:
	print("Test dummy destroyed!")
	# Simple death - just remove
	queue_free()

# =============================================================================
# EFFECTS
# =============================================================================

func _flash_damage() -> void:
	is_flashing = true
	flash_timer = 0.15
	sprite.modulate = Color(1, 0.3, 0.3, 1)
