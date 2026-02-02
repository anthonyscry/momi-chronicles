extends State
class_name PlayerBlock
## Block state - player holds position and reduces incoming damage.
## Guard meter depletes while blocking. First 0.15s is parry window.

const PARRY_WINDOW: float = 0.15  # First 150ms = perfect parry

var block_timer: float = 0.0
var parry_available: bool = true

# Denial feedback spam prevention (shared across instances)
static var denial_cooldown: float = 0.0

func enter() -> void:
	block_timer = 0.0
	parry_available = true

	if not player.guard or not player.guard.can_block():
		# Guard depleted - denial feedback (throttled)
		if denial_cooldown <= 0:
			AudioManager.play_sfx("menu_navigate")
			Events.permission_denied.emit("guard", "Guard meter depleted")
			denial_cooldown = 0.3
		state_machine.transition_to("Idle")
		return
	
	player.guard.start_blocking()
	player.velocity = Vector2.ZERO
	
	# Play block animation
	if player.sprite:
		player.sprite.play("block")
	
	# Visual: darken sprite slightly to show blocking stance
	if player.sprite:
		player.sprite.modulate = Color(0.7, 0.7, 0.8, 1.0)
	
	Events.player_block_started.emit()

func exit() -> void:
	if player.guard:
		player.guard.stop_blocking()
	
	# Restore sprite modulate
	if player.sprite:
		player.sprite.modulate = Color.WHITE
	
	Events.player_block_ended.emit()

func _process(delta: float) -> void:
	# Update static denial cooldown (runs even when not in this state)
	if denial_cooldown > 0:
		denial_cooldown -= delta

func physics_update(delta: float) -> void:
	block_timer += delta
	
	# Parry window expires
	if parry_available and block_timer > PARRY_WINDOW:
		parry_available = false
	
	# Check if block should end (bot or player input)
	var should_block = Input.is_action_pressed("block")
	if player.bot_controlled:
		should_block = player.bot_blocking
	
	if not should_block or not player.guard.can_block():
		state_machine.transition_to("Idle")
		return
	
	# Can't move while blocking
	player.velocity = Vector2.ZERO
	player.move_and_slide()

## Check if we're in the parry window
func is_in_parry_window() -> bool:
	return parry_available and block_timer <= PARRY_WINDOW

func can_transition_to(state_name: String) -> bool:
	# Can transition to Hurt (if guard breaks or big hit)
	# Can transition to Idle (release block)
	return state_name in ["Idle", "Hurt", "Death"]
