extends Control
class_name BossHealthBar
## Large health bar for boss encounters - displayed at top of screen

# =============================================================================
# CONFIGURATION
# =============================================================================

const BAR_WIDTH: float = 200.0
const BAR_HEIGHT: float = 12.0

const BG_COLOR: Color = Color(0.15, 0.1, 0.1, 0.9)
const FILL_COLOR: Color = Color(0.9, 0.3, 0.2)
const FILL_COLOR_ENRAGED: Color = Color(1.0, 0.2, 0.1)
const FILL_COLOR_MINIBOSS: Color = Color(0.9, 0.6, 0.2)  # Orange for mini-boss
const DAMAGE_COLOR: Color = Color(1, 1, 1, 0.7)

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var boss_name_label: Label = $Container/BossName
@onready var bar_container: Control = $Container/BarContainer
@onready var background: ColorRect = $Container/BarContainer/Background
@onready var fill: ColorRect = $Container/BarContainer/Fill
@onready var damage_fill: ColorRect = $Container/BarContainer/DamageFill

# =============================================================================
# STATE
# =============================================================================

var boss_ref: Node = null
var current_health: int = 0
var max_health: int = 100
var is_enraged: bool = false
var fill_tween: Tween
var is_mini_boss: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Hide by default
	visible = false
	
	# Connect to boss events
	Events.boss_spawned.connect(_on_boss_spawned)
	Events.boss_enraged.connect(_on_boss_enraged)
	Events.boss_defeated.connect(_on_boss_defeated)
	
	# Mini-boss signals
	Events.mini_boss_spawned.connect(_on_mini_boss_spawned)
	Events.mini_boss_defeated.connect(_on_mini_boss_defeated)

func _process(_delta: float) -> void:
	if not visible or not boss_ref:
		return
	
	# Update health from boss
	if is_instance_valid(boss_ref) and boss_ref.health:
		var new_health = boss_ref.health.current_health
		if new_health != current_health:
			_update_health(new_health, boss_ref.health.max_health)

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_boss_spawned(boss: Node) -> void:
	boss_ref = boss
	is_mini_boss = false
	
	# Set boss name
	boss_name_label.text = "RACCOON KING"
	
	# Initialize health
	if boss.health:
		max_health = boss.health.max_health
		current_health = boss.health.current_health
	
	# Update fill
	fill.size.x = BAR_WIDTH
	
	# Show with animation
	_show_bar()

func _on_boss_enraged(_boss: Node) -> void:
	is_enraged = true
	fill.color = FILL_COLOR_ENRAGED
	
	# Flash effect
	modulate = Color(1.5, 1.2, 1.2)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Add "ENRAGED!" to name
	boss_name_label.text = "RACCOON KING - ENRAGED!"
	boss_name_label.add_theme_color_override("font_color", Color(1, 0.5, 0.4))

func _on_boss_defeated(_boss: Node) -> void:
	# Drain bar dramatically
	var tween = create_tween()
	tween.tween_property(fill, "size:x", 0.0, 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): visible = false)
	
	boss_ref = null

func _on_mini_boss_spawned(boss: Node, boss_name_text: String) -> void:
	boss_ref = boss
	is_mini_boss = true
	is_enraged = false
	
	# Set name
	boss_name_label.text = boss_name_text
	boss_name_label.add_theme_font_size_override("font_size", 11)
	
	# Initialize health
	if boss.health:
		max_health = boss.health.max_health
		current_health = boss.health.current_health
	
	# Set fill color for mini-boss (orange instead of red)
	fill.color = FILL_COLOR_MINIBOSS
	
	# Update fill bar
	fill.size.x = BAR_WIDTH
	
	# Show
	_show_bar()

func _on_mini_boss_defeated(_boss: Node, _boss_key: String) -> void:
	is_mini_boss = false
	
	# Drain bar dramatically (same as boss)
	var tween = create_tween()
	tween.tween_property(fill, "size:x", 0.0, 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): visible = false)
	
	boss_ref = null

# =============================================================================
# UPDATES
# =============================================================================

func _update_health(new_health: int, new_max: int) -> void:
	var old_health = current_health
	current_health = new_health
	max_health = new_max
	
	# Show damage flash
	if new_health < old_health:
		_show_damage_flash(old_health, new_health)
	
	# Animate fill bar
	_animate_fill()

func _show_damage_flash(old_hp: int, new_hp: int) -> void:
	# Position damage fill to show lost health
	var old_percent = float(old_hp) / float(max_health)
	var new_percent = float(new_hp) / float(max_health)
	
	damage_fill.position.x = BAR_WIDTH * new_percent
	damage_fill.size.x = BAR_WIDTH * (old_percent - new_percent)
	damage_fill.modulate.a = 1.0
	
	# Fade out the damage indicator slowly (lingers to show recent damage)
	var tween = create_tween()
	tween.tween_property(damage_fill, "modulate:a", 0.0, 0.6).set_delay(0.3)
	
	# Shake the entire bar on hit for impact feel
	_shake_bar()
	
	# Flash the bar white briefly
	var flash_tween = create_tween()
	flash_tween.tween_property(fill, "color", Color(1, 1, 1), 0.05)
	var restore_color = FILL_COLOR_ENRAGED if is_enraged else (FILL_COLOR_MINIBOSS if is_mini_boss else FILL_COLOR)
	flash_tween.tween_property(fill, "color", restore_color, 0.1)

func _animate_fill() -> void:
	if fill_tween and fill_tween.is_valid():
		fill_tween.kill()
	
	var target_width = BAR_WIDTH * (float(current_health) / float(max_health))
	
	fill_tween = create_tween()
	fill_tween.tween_property(fill, "size:x", target_width, 0.2)

## Shake the boss health bar for hit impact
func _shake_bar() -> void:
	if not bar_container:
		return
	var original_pos = bar_container.position
	var shake_tween = create_tween()
	shake_tween.tween_property(bar_container, "position", original_pos + Vector2(3, 0), 0.03)
	shake_tween.tween_property(bar_container, "position", original_pos + Vector2(-2, 1), 0.03)
	shake_tween.tween_property(bar_container, "position", original_pos + Vector2(1, -1), 0.03)
	shake_tween.tween_property(bar_container, "position", original_pos, 0.04)


func _show_bar() -> void:
	visible = true
	modulate.a = 0
	position.y = -30
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_property(self, "position:y", 0.0, 0.3).set_ease(Tween.EASE_OUT)
