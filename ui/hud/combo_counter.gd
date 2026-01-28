extends Control
class_name ComboCounter
## Displays current combo hit count with visual feedback

# =============================================================================
# CONFIGURATION
# =============================================================================

const COLORS = [
	Color(1, 1, 1),       # Hit 1: White
	Color(1, 0.9, 0.3),   # Hit 2: Yellow
	Color(1, 0.4, 0.2)    # Hit 3: Orange-red
]

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var hit_container: HBoxContainer = $HitContainer
@onready var hit1: Label = $HitContainer/Hit1
@onready var hit2: Label = $HitContainer/Hit2
@onready var hit3: Label = $HitContainer/Hit3
@onready var combo_text: Label = $ComboText

# =============================================================================
# STATE
# =============================================================================

var fade_tween: Tween
var current_combo: int = 0

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect to combo signals
	Events.combo_changed.connect(_on_combo_changed)
	Events.combo_dropped.connect(_on_combo_dropped)
	Events.combo_completed.connect(_on_combo_completed)
	
	# Initial state - hidden
	_reset_display()
	visible = false

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_combo_changed(count: int) -> void:
	current_combo = count
	
	if count == 0:
		_start_fade_out()
		return
	
	# Show and update
	visible = true
	modulate.a = 1.0
	
	# Cancel any fade
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	
	_update_display(count)

func _on_combo_dropped() -> void:
	_start_fade_out()

func _on_combo_completed(total_damage: int) -> void:
	# Show "COMBO!" text with celebration
	combo_text.visible = true
	combo_text.text = "COMBO!"
	combo_text.modulate = Color(1, 0.8, 0.2)
	_pulse_label(combo_text, 1.5)
	
	# Flash all indicators
	for label in [hit1, hit2, hit3]:
		label.modulate = Color(1, 0.9, 0.3)
	
	# Fade out after celebration
	await get_tree().create_timer(0.8).timeout
	_start_fade_out()

# =============================================================================
# DISPLAY UPDATES
# =============================================================================

func _update_display(count: int) -> void:
	_reset_display()
	
	var labels = [hit1, hit2, hit3]
	
	# Light up completed hits
	for i in range(count):
		if i < labels.size():
			var label = labels[i]
			label.modulate = COLORS[i]
			label.add_theme_font_size_override("font_size", 20 + i * 4)
	
	# Pulse the current hit indicator
	if count > 0 and count <= 3:
		var current_label = labels[count - 1]
		_pulse_label(current_label, 1.3)
	
	# Show COMBO text on hit 3
	combo_text.visible = (count >= 3)

func _reset_display() -> void:
	# Dim all indicators
	var labels = [hit1, hit2, hit3]
	for label in labels:
		label.modulate = Color(0.4, 0.4, 0.4)
		label.add_theme_font_size_override("font_size", 20)
		label.scale = Vector2.ONE
	
	combo_text.visible = false

func _pulse_label(label: Label, scale_factor: float = 1.3) -> void:
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(scale_factor, scale_factor), 0.08).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_IN)

func _start_fade_out() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.2)
	fade_tween.tween_callback(func():
		visible = false
		_reset_display()
	)
