extends Button
class_name ChoiceButton
## Interactive button for dialogue choice options with hover states

# =============================================================================
# SIGNALS
# =============================================================================

signal choice_selected(choice_index: int)

# =============================================================================
# PROPERTIES
# =============================================================================

## Index of this choice in the dialogue options
var choice_index: int = 0

## Full choice text
var choice_text: String = ""

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var background: ColorRect = $Background
@onready var hover_highlight: ColorRect = $HoverHighlight
@onready var choice_label: Label = $ChoiceLabel

# =============================================================================
# THEME COLORS
# =============================================================================

const COLOR_NORMAL = Color(0.1, 0.1, 0.15, 0.7)
const COLOR_HOVER = Color(0.15, 0.15, 0.2, 0.9)
const COLOR_PRESSED = Color(0.08, 0.08, 0.12, 0.9)
const COLOR_HIGHLIGHT = Color(0.3, 0.5, 0.8, 0.3)

const TEXT_COLOR_NORMAL = Color(0.9, 0.9, 0.95, 1.0)
const TEXT_COLOR_HOVER = Color(1.0, 1.0, 1.0, 1.0)

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Connect button signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)

	# Initialize visual state
	_update_visual_state(false)


# =============================================================================
# PUBLIC METHODS
# =============================================================================

## Setup the choice button with text and index
func setup(text: String, index: int) -> void:
	choice_text = text
	choice_index = index

	if choice_label:
		choice_label.text = text


## Enable or disable the button
func set_enabled(enabled: bool) -> void:
	disabled = not enabled
	modulate.a = 1.0 if enabled else 0.5


# =============================================================================
# VISUAL UPDATES
# =============================================================================

func _update_visual_state(is_hovered: bool, is_pressed: bool = false) -> void:
	if not background or not choice_label or not hover_highlight:
		return

	if is_pressed:
		background.color = COLOR_PRESSED
		choice_label.add_theme_color_override("font_color", TEXT_COLOR_HOVER)
		hover_highlight.modulate.a = 0.5
	elif is_hovered:
		background.color = COLOR_HOVER
		choice_label.add_theme_color_override("font_color", TEXT_COLOR_HOVER)
		hover_highlight.modulate.a = 1.0
	else:
		background.color = COLOR_NORMAL
		choice_label.add_theme_color_override("font_color", TEXT_COLOR_NORMAL)
		hover_highlight.modulate.a = 0.0


# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_mouse_entered() -> void:
	if not disabled:
		_update_visual_state(true)


func _on_mouse_exited() -> void:
	_update_visual_state(false)


func _on_button_down() -> void:
	if not disabled:
		_update_visual_state(true, true)


func _on_button_up() -> void:
	var is_hovered = get_global_rect().has_point(get_global_mouse_position())
	_update_visual_state(is_hovered)


func _on_pressed() -> void:
	if not disabled:
		choice_selected.emit(choice_index)
