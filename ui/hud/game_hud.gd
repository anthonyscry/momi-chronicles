extends CanvasLayer
class_name GameHUD
## Main game HUD containing health bar and debug info.
## F3 toggles debug panel visibility.

@onready var health_bar: HealthBar = $MarginContainer/VBoxContainer/HealthBar
@onready var debug_panel: PanelContainer = $MarginContainer/VBoxContainer/DebugPanel
@onready var autobot_label: Label = $MarginContainer/VBoxContainer/DebugPanel/AutoBotLabel

## Whether debug panel is visible
var debug_visible: bool = true

func _ready() -> void:
	# Show debug by default (can toggle with F3)
	debug_panel.visible = debug_visible


func _unhandled_input(event: InputEvent) -> void:
	# F3 toggles debug panel
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			debug_visible = not debug_visible
			debug_panel.visible = debug_visible
			print("[HUD] Debug panel: %s (F3 to toggle)" % ("ON" if debug_visible else "OFF"))


func _process(_delta: float) -> void:
	# Only update if debug panel is visible
	if not debug_visible or not debug_panel.visible:
		return
	
	# Update AutoBot status label
	if autobot_label and is_instance_valid(AutoBot):
		var status = AutoBot.get_status()
		if AutoBot.enabled:
			# Show detailed debug info
			autobot_label.text = AutoBot.get_debug_info() + "\nF1=Bot | F3=Hide"
			
			# Color based on state
			match status:
				"ATTACKING", "DESPERATE_ATTACK":
					autobot_label.modulate = Color(1, 0.4, 0.4, 1)  # Red when attacking
				"CLOSING":
					autobot_label.modulate = Color(1, 0.7, 0.3, 1)  # Orange when closing
				"HUNTING", "FINISH_THEM":
					autobot_label.modulate = Color(1, 0.9, 0.3, 1)  # Yellow when hunting
				"WANDERING":
					autobot_label.modulate = Color(0.4, 1, 0.6, 1)  # Green when wandering
				"KITING", "ESCAPING", "RETREATING":
					autobot_label.modulate = Color(0.4, 0.8, 1, 1)  # Blue when defensive
				"LAST_STAND":
					autobot_label.modulate = Color(1, 0.2, 0.8, 1)  # Purple for last stand
				_:
					autobot_label.modulate = Color(0.7, 0.7, 0.7, 1)  # Gray for other
		else:
			autobot_label.text = "[AutoBot: OFF]\nF1=Bot | F3=Hide"
			autobot_label.modulate = Color(1, 0.5, 0.4, 1)
