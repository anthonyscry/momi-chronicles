extends State
class_name PlayerDeath

const DEATH_DURATION: float = 1.4
var death_timer: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	death_timer = 0.0
	
	if player.hitbox:
		player.hitbox.disable()
	if player.hurtbox:
		player.hurtbox.is_invincible = true
	
	player.set_collision_layer_value(2, false)
	_dramatic_death_sequence()

func physics_update(delta: float) -> void:
	death_timer += delta

func _dramatic_death_sequence() -> void:
	# 1. Slowmo on death
	Engine.time_scale = 0.2
	
	# 2. Screen shake
	EffectsManager.screen_shake(8.0, 0.4)
	
	# 3. Red flash
	_flash_death_screen()
	
	# 4. Player death animation (red flash + fade out)
	if player.sprite:
		var sprite_tween = player.create_tween()
		sprite_tween.set_ignore_time_scale(true)
		# Flash white briefly
		sprite_tween.tween_property(player.sprite, "color", Color(1, 1, 1, 1), 0.05)
		# Turn red
		sprite_tween.tween_property(player.sprite, "color", Color(1, 0.15, 0.15, 1), 0.15)
		# Hold red
		sprite_tween.tween_interval(0.3)
		# Fade out
		sprite_tween.tween_property(player.sprite, "color", Color(1, 0.15, 0.15, 0), 0.5)
	
	# 5. Restore time scale smoothly after the dramatic pause
	var time_tween = create_tween()
	time_tween.set_ignore_time_scale(true)
	time_tween.tween_interval(0.25)  # Hold slowmo for a beat
	time_tween.tween_property(Engine, "time_scale", 1.0, 0.3)
	
	# 6. Fade entire screen to dark red over the death
	_fade_death_overlay()


func _flash_death_screen() -> void:
	# Brief red flash overlay
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	var flash = ColorRect.new()
	flash.color = Color(0.7, 0, 0, 0.5)
	flash.anchors_preset = Control.PRESET_FULL_RECT
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(flash)
	player.get_tree().current_scene.add_child(canvas)
	
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(flash, "color:a", 0.0, 0.4)
	tween.tween_callback(canvas.queue_free)


func _fade_death_overlay() -> void:
	# Slow dark overlay that grows as death progresses
	var canvas = CanvasLayer.new()
	canvas.layer = 99
	var overlay = ColorRect.new()
	overlay.color = Color(0.1, 0, 0, 0)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(overlay)
	player.get_tree().current_scene.add_child(canvas)
	
	# Slowly darken - the game_over screen will take over from here
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(overlay, "color:a", 0.6, 1.2)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
