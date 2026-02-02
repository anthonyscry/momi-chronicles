extends State

## Gnome death state - fades out and is removed from scene.

const DEATH_DURATION: float = 0.6
var death_time: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	
	if player.sprite:
		player.sprite.play("death")
	
	if player.hitbox:
		player.hitbox.monitoring = false
		player.hitbox.monitorable = false
	
	player.hide_telegraph()
	
	player.set_collision_layer_value(3, false)
	
	death_time = 0.0
	Events.gnome_died.emit(player)
	
	_fade_out()


func update(delta: float) -> void:
	death_time += delta
	
	if player.sprite:
		player.sprite.modulate.a = 1.0 - (death_time / DEATH_DURATION)
	
	if death_time >= DEATH_DURATION:
		player.queue_free()


func _fade_out() -> void:
	if player.sprite:
		var tween = player.create_tween()
		tween.tween_property(player.sprite, "modulate:a", 0.0, DEATH_DURATION)


func exit() -> void:
	pass
