extends Node
## Global event bus for game-wide signals.
## Emit events here and connect from anywhere to decouple systems.

# =============================================================================
# PLAYER EVENTS
# =============================================================================

signal player_health_changed(current, max_health)
signal player_leveled_up(new_level)
signal exp_gained(amount, current_level, current_exp, exp_to_next)
signal guard_changed(current, max_guard)
signal player_attacked
signal player_dodged
signal player_damaged(amount)
signal player_blocked
signal player_block_started
signal player_block_ended
signal player_guard_broken
signal player_parried(attacker, reflect_damage)
signal player_charge_started
signal player_charge_released(damage, charge_percent)
signal player_special_attacked
signal player_ground_pound_started
signal player_ground_pound_impact(damage, radius)
signal player_hit_enemy(enemy)
signal player_healed(amount)
signal player_died
signal stats_updated(stat_key, level)

# =============================================================================
# COMBAT EVENTS
# =============================================================================

signal enemy_damaged(enemy, damage)
signal enemy_defeated(enemy)
signal enemy_spawned(enemy)
signal boss_spawned(boss)
signal boss_enraged(boss)
signal boss_defeated(boss)
signal mini_boss_spawned(boss, boss_key)
signal mini_boss_defeated(boss, boss_key)
signal combo_changed(count)
signal combo_dropped
signal combo_completed(total_damage)

# =============================================================================
# ECONOMY AND INVENTORY EVENTS
# =============================================================================

signal coins_changed(new_total)
signal pickup_collected(item_id, amount)
signal item_used(item_id)
signal item_equipped(item)
signal inventory_opened
signal inventory_closed

# =============================================================================
# BUFF AND DEBUFF EVENTS
# =============================================================================

signal buff_applied(buff_type, duration)
signal buff_expired(buff_type)

# =============================================================================
# UI AND MENU EVENTS
# =============================================================================

signal menu_opened
signal menu_closed
signal ring_menu_opened
signal ring_menu_closed
signal shop_interact_requested
signal shop_closed
signal shop_purchase_completed(item, cost)
signal permission_denied(system, reason)

# =============================================================================
# SAVE / LOAD EVENTS
# =============================================================================

signal game_saved
signal game_loaded
signal save_corrupted

# =============================================================================
# GAME STATE EVENTS
# =============================================================================

signal game_paused
signal game_resumed
signal game_over
signal game_restarted

# =============================================================================
# ZONE EVENTS
# =============================================================================

signal zone_exited(zone_name)
signal zone_entered(zone_name)
signal zone_transition_requested(target_zone, spawn_point)
signal zone_unlocked(zone_id)

# =============================================================================
# QUEST EVENTS
# =============================================================================

signal quest_started(quest_id)
signal quest_updated(quest_id, objective_index)
signal quest_completed(quest_id)
signal quest_failed(quest_id)
signal active_quest_changed(quest_id)

# =============================================================================
# COMPANION AND PARTY EVENTS
# =============================================================================

signal companion_joined(companion_id)
signal active_companion_changed(companion_id)
signal companion_knocked_out(companion_id)
signal companion_revived(companion_id)
signal companion_meter_changed(companion_id, current, max_val)

# =============================================================================
# TUTORIAL EVENTS
# =============================================================================

signal tutorial_triggered(tutorial_id)
signal tutorial_completed(tutorial_id)

# =============================================================================
# DIALOGUE AND CUTSCENE EVENTS
# =============================================================================

signal dialogue_started(dialogue)
signal dialogue_advanced(dialogue)
signal dialogue_choice_made(choice_index, choice)
signal dialogue_ended
signal cutscene_started
signal cutscene_ended

# =============================================================================
# DIFFICULTY EVENTS
# =============================================================================

signal difficulty_changed(new_difficulty)
signal difficulty_system_ready

# =============================================================================
# FLOCK / PIGEON EVENTS
# =============================================================================

signal pigeon_detected_player(flock_id, player_position)
signal pigeon_chase_started(flock_id, origin_position)
signal pigeon_swoop_started(flock_id, pigeon)
signal pigeon_hit_player(flock_id)
signal pigeon_fled(flock_id, pigeon)
signal pigeon_died(flock_id, pigeon)
signal pigeon_entered_idle(flock_id)

var _flock_data: Dictionary = {}
var _next_flock_id: int = 0

func get_next_flock_id() -> int:
	var id = _next_flock_id
	_next_flock_id += 1
	return id

func register_flock(flock_id: int, members: Array) -> void:
	_flock_data[flock_id] = {
		"members": members,
		"lead_pigeon": null,
		"state": "idle",
		"perch_position": Vector2.ZERO,
	}

	for i in range(members.size()):
		members[i].flock_id = flock_id
		members[i].flock_position = i
		members[i].is_lead_pigeon = (i == 0)
		members[i].add_to_group("pigeon_flock_" + str(flock_id))
		if i == 0:
			_flock_data[flock_id]["lead_pigeon"] = members[i]
			members[i].add_to_group("pigeon_flock_lead_" + str(flock_id))

func unregister_flock(flock_id: int) -> void:
	_flock_data.erase(flock_id)

func get_flock_members(flock_id: int) -> Array:
	if _flock_data.has(flock_id):
		return _flock_data[flock_id]["members"]
	return []

func get_flock_lead(flock_id: int) -> Node:
	if _flock_data.has(flock_id):
		return _flock_data[flock_id]["lead_pigeon"]
	return null

func promote_new_lead(flock_id: int) -> void:
	if not _flock_data.has(flock_id):
		return

	var members = _flock_data[flock_id]["members"]
	for member in members:
		if is_instance_valid(member) and not member.is_lead_pigeon:
			member.is_lead_pigeon = true
			member.flock_position = 0
			_flock_data[flock_id]["lead_pigeon"] = member
			member.add_to_group("pigeon_flock_lead_" + str(flock_id))
			break

func create_pigeon_flock(spawn_position: Vector2, size: int) -> Array:
	var flock_id = get_next_flock_id()
	var pigeon_scene = load("res://characters/enemies/pigeon.tscn")
	var flock_members: Array = []

	for i in range(size):
		var pigeon = pigeon_scene.instantiate()
		pigeon.global_position = spawn_position
		if i > 0:
			var angle = i * TAU / size
			var offset = Vector2(cos(angle), sin(angle)) * 32.0
			pigeon.global_position += offset
		flock_members.append(pigeon)

	register_flock(flock_id, flock_members)

	if flock_members.size() > 0:
		_flock_data[flock_id]["perch_position"] = spawn_position
		flock_members[0].perch_position = spawn_position

	return flock_members

# =============================================================================
# ROOF RAT EVENTS
# =============================================================================

signal roof_rat_ambush_started(rat)
signal roof_rat_hit_player(rat)
signal roof_rat_retreated(rat)
signal roof_rat_cornered(rat)
signal roof_rat_escaped(rat)

# =============================================================================
# GARDEN GNOME EVENTS
# =============================================================================

signal gnome_threw_bomb(gnome, bomb)
signal gnome_bomb_exploded(position, radius)
signal gnome_died(gnome)
signal gnome_hurt(gnome, damage)

# =============================================================================
# BOSS REWARD EVENTS
# =============================================================================

signal boss_reward_unlocked(boss_id: int, rewards: Array)
signal boss_reward_claimed(boss_id: int, reward: Dictionary)

# =============================================================================
# NPC REPUTATION EVENTS
# =============================================================================

signal reputation_changed(npc_id, old_value, new_value)
