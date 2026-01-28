extends Control
class_name ComboCounter
## Displays current combo hit count with minimal dot indicators

# =============================================================================
# CONFIGURATION
# =============================================================================

const COLORS = [
	Color(1, 1, 1),       # Hit 1: White
	Color(1, 0.85, 0.3),  # Hit 2: Yellow
	Color(1, 0.5, 0.2)    # Hit 3: Orange
]

const DIM_COLOR = Color(0.3, 0.3, 0.3, 0.6)

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
	
	# Hide when ring menu opens
	Events.ring_menu_opened.connect(func(): visible = false)
	
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
	
	# Fire burst particles on full combo!
	_spawn_combo_fire()
	
	# Fade out after celebration
	await get_tree().create_timer(0.8).timeout
	_start_fade_out()

# =============================================================================
# DISPLAY UPDATES
# =============================================================================

func _reset_display() -> void:
	# Dim all indicators with consistent styling
	var labels = [hit1, hit2, hit3]
	for label in labels:
		label.modulate = DIM_COLOR
		label.scale = Vector2.ONE
	
	combo_text.visible = false

func _pulse_label(label: Label, scale_factor: float = 1.4) -> void:
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(scale_factor, scale_factor), 0.06).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)

func _start_fade_out() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3).set_delay(0.2)
	fade_tween.tween_callback(func():
		visible = false
		_reset_display()
	)

# =============================================================================
# COMBO FIRE EFFECT (Phase P7)
# =============================================================================

## Spawn fire particles around the combo dots on full combo
func _spawn_combo_fire() -> void:
	var labels = [hit1, hit2, hit3]
	for label in labels:
		for i in range(4):
			var spark = ColorRect.new()
			spark.size = Vector2(2, 3)
			spark.color = [Color(1, 0.6, 0.1), Color(1, 0.3, 0.05), Color(1, 0.9, 0.3)][randi() % 3]
			spark.position = label.position + Vector2(randf_range(-3, 3), 0)
			spark.z_index = 10
			add_child(spark)
			
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(spark, "position:y", spark.position.y - randf_range(8, 18), 0.4)\
				.set_ease(Tween.EASE_OUT)
			tween.tween_property(spark, "position:x", spark.position.x + randf_range(-5, 5), 0.4)
			tween.tween_property(spark, "modulate:a", 0.0, 0.3).set_delay(0.1)
			tween.chain().tween_callback(spark.queue_free)


## On hit 2+, show escalating glow behind the current dot
func _update_display(count: int) -> void:
	_reset_display()
	
	var labels = [hit1, hit2, hit3]
	
	# Light up completed hits with consistent size
	for i in range(count):
		if i < labels.size():
			var label = labels[i]
			label.modulate = COLORS[i]
	
	# Pulse the current hit indicator (subtle)
	if count > 0 and count <= 3:
		var current_label = labels[count - 1]
		_pulse_label(current_label, 1.4)
	
	# On hit 2+, emit small spark from the dot
	if count >= 2:
		var dot = labels[count - 1]
		_emit_hit_spark(dot, COLORS[count - 1])
	
	# Show COMBO text on hit 3
	combo_text.visible = (count >= 3)


## Small spark from a dot on escalating hits
func _emit_hit_spark(label: Label, color: Color) -> void:
	for i in range(2):
		var spark = ColorRect.new()
		spark.size = Vector2(2, 2)
		spark.color = color
		spark.position = label.position + Vector2(randf_range(-2, 2), 0)
		spark.z_index = 10
		add_child(spark)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(spark, "position:y", spark.position.y - randf_range(5, 12), 0.25)
		tween.tween_property(spark, "modulate:a", 0.0, 0.2).set_delay(0.05)
		tween.chain().tween_callback(spark.queue_free)
