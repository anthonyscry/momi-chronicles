extends CanvasLayer
class_name TutorialPrompt
## Displays contextual tutorial prompts that fade in/out smoothly.
## Positioned bottom-center with subtle background for readability.

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var panel: PanelContainer = $Panel
@onready var prompt_text: Label = $Panel/MarginContainer/PromptText

# =============================================================================
# STATE
# =============================================================================

var fade_tween: Tween
var is_visible: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Initial state - hidden
	modulate.a = 0.0
	visible = false

	# Connect to tutorial events
	Events.tutorial_triggered.connect(_on_tutorial_triggered)
	Events.tutorial_completed.connect(_on_tutorial_completed)

## Handle tutorial trigger - show appropriate prompt based on tutorial_id
func _on_tutorial_triggered(tutorial_id: String) -> void:
	var prompt_messages = {
		"movement": "Use WASD or Arrow keys to move",
		"attack": "Press Space or Left Click to attack",
		"special_attack": "Press Right Click or C for special attack",
		"dodge": "Press X to dodge enemy attacks",
		"block": "Hold Shift to block incoming damage",
		"combo": "Chain 3 attacks for combo damage bonus",
		"ring_menu": "Press Tab to open Ring Menu",
		"item_usage": "Select item and press Enter to use",
		"companion_swap": "Use Ring Menu to swap companions"
	}

	var message = prompt_messages.get(tutorial_id, "")
	if message:
		show_prompt(message)

## Handle tutorial completion - hide prompt
func _on_tutorial_completed(tutorial_id: String) -> void:
	hide_prompt()

# =============================================================================
# PUBLIC METHODS
# =============================================================================

## Show tutorial prompt with fade-in animation and subtle pulse
func show_prompt(text: String) -> void:
	if is_visible and prompt_text.text == text:
		return  # Already showing this prompt

	prompt_text.text = text
	visible = true
	is_visible = true

	# Cancel any existing fade
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()

	# Fade in with pulse emphasis
	fade_tween = create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(self, "modulate:a", 1.0, 0.2).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.1).set_ease(Tween.EASE_OUT)
	fade_tween.chain().tween_property(panel, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN)

## Hide prompt with fade-out animation
func hide_prompt() -> void:
	if not is_visible:
		return

	is_visible = false

	# Cancel any existing fade
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()

	# Fade out
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN)
	fade_tween.tween_callback(func():
		visible = false
		prompt_text.text = ""
	)
