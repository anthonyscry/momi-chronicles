extends Control
class_name CoinCounter
## Displays player's coin count with smooth counting animation.

@onready var icon: ColorRect = $HBoxContainer/Icon
@onready var label: Label = $HBoxContainer/Label

var display_coins: int = 0
var target_coins: int = 0

func _ready() -> void:
	Events.coins_changed.connect(_on_coins_changed)
	# Initialize from GameManager
	target_coins = GameManager.get_coins()
	display_coins = target_coins
	_update_display()

func _process(delta: float) -> void:
	# Smooth counting animation
	if display_coins != target_coins:
		var diff = target_coins - display_coins
		var step = max(1, abs(diff) * 10 * delta)
		if diff > 0:
			display_coins = mini(display_coins + int(step), target_coins)
		else:
			display_coins = maxi(display_coins - int(step), target_coins)
		_update_display()

func _on_coins_changed(total: int) -> void:
	var gained = total > target_coins
	target_coins = total
	# Pop animation on gain
	if gained:
		_pop_animation()

func _update_display() -> void:
	if label:
		label.text = str(display_coins)

func _pop_animation() -> void:
	# Quick scale pop
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12).set_ease(Tween.EASE_OUT)
