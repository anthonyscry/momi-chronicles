extends EnemyBase
class_name BossRaccoonKing
## The Raccoon King - Final boss of the backyard zone
## Has 3 attack patterns that cycle, enrages at 50% HP

# =============================================================================
# BOSS CONFIGURATION
# =============================================================================

## Boss stats (override base)
const BOSS_MAX_HP: int = 400
const BOSS_DAMAGE: int = 35
const BOSS_SPEED: float = 50.0
const BOSS_EXP: int = 500

## Attack pattern timings
const ATTACK_COOLDOWN_BASE: float = 1.5
const ENRAGE_THRESHOLD: float = 0.5  # 50% HP

## Attack patterns
enum AttackPattern { SWIPE, CHARGE, SUMMON }
var attack_pattern_order = [AttackPattern.SWIPE, AttackPattern.CHARGE, AttackPattern.SWIPE, AttackPattern.SUMMON]
var current_attack_index: int = 0

## Enrage state
var is_enraged: bool = false

## Boss-specific
var phase: int = 1  # 1 = normal, 2 = enraged

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# Override base stats before calling super
	patrol_speed = BOSS_SPEED
	chase_speed = BOSS_SPEED * 1.5
	attack_damage = BOSS_DAMAGE
	exp_value = BOSS_EXP
	
	# Larger detection range
	detection_range = 150.0
	attack_range = 35.0
	lose_interest_range = 300.0  # Never loses interest
	
	super._ready()
	
	# Override health after parent sets it up
	if health:
		health.max_health = BOSS_MAX_HP
		health.current_health = BOSS_MAX_HP
	
	# Customize appearance
	_setup_boss_appearance()
	
	add_to_group("boss")
	
	Events.boss_spawned.emit(self)

func _setup_boss_appearance() -> void:
	if not sprite:
		return
	
	# Boss is bigger - scale up
	sprite.scale = Vector2(2.5, 2.5)

# =============================================================================
# COMBAT AI
# =============================================================================

func get_next_attack() -> AttackPattern:
	var pattern = attack_pattern_order[current_attack_index]
	current_attack_index = (current_attack_index + 1) % attack_pattern_order.size()
	return pattern

func get_attack_state_name() -> String:
	var pattern = get_next_attack()
	match pattern:
		AttackPattern.SWIPE:
			return "BossAttackSwipe"
		AttackPattern.CHARGE:
			return "BossAttackCharge"
		AttackPattern.SUMMON:
			return "BossAttackSummon"
	return "BossAttackSwipe"

func check_enrage() -> void:
	if is_enraged:
		return
	
	if health and health.get_health_percent() <= ENRAGE_THRESHOLD:
		_enter_enrage()

func _enter_enrage() -> void:
	is_enraged = true
	phase = 2
	
	# Speed up attacks and hit harder
	attack_cooldown = ATTACK_COOLDOWN_BASE * 0.4
	chase_speed = BOSS_SPEED * 2.5
	attack_damage = BOSS_DAMAGE + 15  # 50 damage in enrage
	
	# Visual feedback - switch to enrage animation
	if sprite:
		sprite.play("idle_enrage")
		sprite.modulate = Color(1.3, 0.8, 0.8)  # Red tint
	
	# Screen shake
	EffectsManager.screen_shake(10.0, 0.5)
	
	Events.boss_enraged.emit(self)

# =============================================================================
# DAMAGE OVERRIDE
# =============================================================================

func _on_hurt(attacking_hitbox: Hitbox) -> void:
	super._on_hurt(attacking_hitbox)
	check_enrage()

	# Boss heavy feel: reduce knockback to 30% (alternative to setting low knockback_force)
	# This approach allows using normal knockback_force while having boss-specific resistance
	velocity = velocity * 0.3

func _on_died() -> void:
	# Boss death is special
	Events.boss_defeated.emit(self)
	
	# Grant legendary equipment: King's Mantle
	if GameManager.equipment_manager:
		if not GameManager.equipment_manager.has_equipment("kings_mantle"):
			GameManager.equipment_manager.add_equipment("kings_mantle")
			_show_loot_notification("kings_mantle")
	
	# Spawn drops (boss always drops lots of loot!)
	_spawn_drops()
	
	# Dramatic death sequence
	_play_death_sequence()


## Boss drops: 100% coins, 100% health, guaranteed King's Mantle + energy treat
func _init_default_drops() -> void:
	drop_table = [
		{"scene": COIN_PICKUP_SCENE, "chance": 1.0, "min": 10, "max": 20},
		{"scene": HEALTH_PICKUP_SCENE, "chance": 1.0, "min": 3, "max": 5},
		{"item_id": "energy_treat", "chance": 1.0, "min": 1, "max": 1},
	]

## Show floating text notification for boss loot drop
func _show_loot_notification(equip_id: String) -> void:
	var equip_data = EquipmentDatabase.get_equipment(equip_id)
	if equip_data.is_empty():
		return
	var label = Label.new()
	label.text = "Got %s!" % equip_data.get("name", "???")
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", equip_data.get("color", Color.GOLD))
	label.global_position = global_position + Vector2(-30, -30)
	label.z_index = 100
	get_parent().add_child(label)
	var tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 30, 1.2)
	tween.tween_property(label, "modulate:a", 0.0, 1.2).set_delay(0.5)
	tween.chain().tween_callback(label.queue_free)


func _play_death_sequence() -> void:
	# Disable collision
	set_collision_layer_value(2, false)
	
	# Stop all movement
	velocity = Vector2.ZERO
	
	# Flash and shake sequence
	for i in range(5):
		if sprite:
			sprite.modulate = Color(2, 2, 2) if i % 2 == 0 else Color(1, 0.5, 0.5)
		EffectsManager.screen_shake(8.0, 0.2)
		await get_tree().create_timer(0.3).timeout
	
	# Explode into particles
	_spawn_death_particles()
	
	# Remove boss
	queue_free()

func _spawn_death_particles() -> void:
	for i in range(20):
		var particle = ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = Color(0.4, 0.35, 0.5)
		particle.global_position = global_position
		get_parent().add_child(particle)
		
		var angle = randf() * TAU
		var speed = randf_range(50, 150)
		var end_pos = global_position + Vector2(cos(angle), sin(angle)) * speed
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", end_pos, 0.5)
		tween.tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.chain().tween_callback(particle.queue_free)
