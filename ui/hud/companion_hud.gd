extends Control
class_name CompanionHUD

## Per-companion panel data
var panels: Dictionary = {}

func _ready() -> void:
	# Set up panel references
	for companion_id in ["momi", "cinnamon", "philo"]:
		var panel = get_node_or_null(companion_id.capitalize() + "Panel")
		if panel:
			panels[companion_id] = {
				"panel": panel,
				"health_bar": panel.get_node_or_null("HealthBar"),
				"meter_bar": panel.get_node_or_null("MeterBar"),
				"name_label": panel.get_node_or_null("NameLabel"),
				"ko_overlay": panel.get_node_or_null("KOOverlay"),
			}
	
	# Connect to events
	Events.active_companion_changed.connect(_on_active_changed)
	Events.companion_knocked_out.connect(_on_knocked_out)
	Events.companion_revived.connect(_on_revived)
	Events.companion_meter_changed.connect(_on_meter_changed)
	
	# Initialize display
	_initialize_panels()

func _initialize_panels() -> void:
	for companion_id in panels:
		var data = CompanionData.get_companion(companion_id)
		var p = panels[companion_id]
		
		# Set name
		if p.name_label:
			p.name_label.text = data.name
		
		# Set meter color based on companion
		if p.meter_bar:
			p.meter_bar.modulate = data.meter.color
		
		# Hide KO overlay initially
		if p.ko_overlay:
			p.ko_overlay.visible = false
	
	# Highlight active companion
	var active_id = "momi"
	if GameManager.party_manager:
		active_id = GameManager.party_manager.active_companion_id
	_highlight_active(active_id)

func _highlight_active(companion_id: String) -> void:
	for id in panels:
		var p = panels[id]
		if p.panel:
			# Active companion has brighter border/background
			if id == companion_id:
				p.panel.modulate = Color.WHITE
			else:
				p.panel.modulate = Color(0.7, 0.7, 0.7)

func _on_active_changed(companion_id: String) -> void:
	_highlight_active(companion_id)

func _on_knocked_out(companion_id: String) -> void:
	var p = panels.get(companion_id)
	if p and p.ko_overlay:
		p.ko_overlay.visible = true
	if p and p.panel:
		p.panel.modulate = Color(0.4, 0.4, 0.4)

func _on_revived(companion_id: String) -> void:
	var p = panels.get(companion_id)
	if p and p.ko_overlay:
		p.ko_overlay.visible = false
	
	var active_id = "momi"
	if GameManager.party_manager:
		active_id = GameManager.party_manager.active_companion_id
	_highlight_active(active_id)

func _on_meter_changed(companion_id: String, current: float, max_val: float) -> void:
	var p = panels.get(companion_id)
	if p and p.meter_bar:
		p.meter_bar.value = (current / max_val) * 100.0 if max_val > 0 else 0

func update_health(companion_id: String, current: int, max_hp: int) -> void:
	var p = panels.get(companion_id)
	if p and p.health_bar:
		p.health_bar.value = (float(current) / max_hp) * 100.0 if max_hp > 0 else 0

func _process(_delta: float) -> void:
	# Update health bars from companion instances
	if GameManager.party_manager:
		for companion_id in GameManager.party_manager.companions:
			var comp = GameManager.party_manager.companions[companion_id]
			if is_instance_valid(comp):
				update_health(companion_id, comp.get_current_health(), comp.get_max_health())
