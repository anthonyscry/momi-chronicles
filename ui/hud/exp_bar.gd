extends Control
class_name ExpBar
## Displays player EXP progress and current level

# =============================================================================
# CONFIGURATION
# =============================================================================

const BAR_WIDTH: float = 80.0
const BAR_HEIGHT: float = 6.0

const BG_COLOR: Color = Color(0.15, 0.1, 0.2, 0.8)
const FILL_COLOR: Color = Color(0.5, 0.3, 0.9, 1.0)  # Purple
const FILL_COLOR_FULL: Color = Color(0.7, 0.5, 1.0, 1.0)  # Lighter when gaining

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var background: ColorRect = $Background
@onready var fill: ColorRect = $Fill
@onready var level_label: Label = $LevelLabel

# =============================================================================
# STATE
# =============================================================================

var current_exp: int = 0
var exp_to_next: int = 100
var current_level: int = 1
var fill_tween: Tween

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Setup bar visuals
	_setup_visuals()
	
	# Connect to events
	Events.exp_gained.connect(_on_exp_gained)
	Events.player_leveled_up.connect(_on_level_up)
	
	_update_display()

func _setup_visuals() -> void:
	background.color = BG_COLOR
	background.size = Vector2(BAR_WIDTH, BAR_HEIGHT)
	
	fill.color = FILL_COLOR
	fill.size = Vector2(0, BAR_HEIGHT)
	fill.position = Vector2(0, 0)
	
	level_label.text = "Lv.1"

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_exp_gained(amount: int, level: int, exp_progress: int, exp_needed: int) -> void:
	current_level = level
	current_exp = exp_progress
	exp_to_next = exp_needed
	_animate_fill()

func _on_level_up(new_level: int) -> void:
	current_level = new_level
	level_label.text = "Lv." + str(current_level)
	
	# Flash effect on level up
	_flash_bar()
	
	# Reset fill for new level (will refill with remaining exp)
	fill.size.x = 0

# =============================================================================
# DISPLAY UPDATES
# =============================================================================

func _animate_fill() -> void:
	if fill_tween and fill_tween.is_valid():
		fill_tween.kill()
	
	var target_width = BAR_WIDTH * (float(current_exp) / float(exp_to_next)) if exp_to_next > 0 else BAR_WIDTH
	target_width = clampf(target_width, 0, BAR_WIDTH)
	
	fill_tween = create_tween()
	fill_tween.tween_property(fill, "size:x", target_width, 0.3).set_ease(Tween.EASE_OUT)
	
	# Briefly brighten on gain
	fill.color = FILL_COLOR_FULL
	fill_tween.parallel().tween_property(fill, "color", FILL_COLOR, 0.3)

func _flash_bar() -> void:
	fill.color = Color(1, 1, 1, 1)
	var tween = create_tween()
	tween.tween_property(fill, "color", FILL_COLOR, 0.2)

func _update_display() -> void:
	level_label.text = "Lv." + str(current_level)
	var fill_percent = float(current_exp) / float(exp_to_next) if exp_to_next > 0 else 0
	fill.size.x = BAR_WIDTH * fill_percent

func set_exp(current: int, to_next: int, level: int) -> void:
	current_exp = current
	exp_to_next = to_next
	current_level = level
	_update_display()
