extends Node
## Global event bus for game-wide signals.
## Decouples systems by allowing emit/subscribe without direct references.

# Player events
signal player_health_changed(current: int, max_health: int)
signal player_leveled_up(new_level: int)
signal guard_changed(current: int, max_guard: int)

# Combat events
signal combo_changed(combo_count: int, multiplier: float)
signal combo_dropped()
signal combo_completed(final_count: int, final_multiplier: float)

# Boss events
signal boss_spawned(boss_name: String, max_health: int)
signal boss_enraged()
signal boss_defeated(boss_name: String)
signal mini_boss_spawned(boss_name: String, max_health: int)
signal mini_boss_defeated(boss_name: String)

# Progression events
signal exp_gained(amount: int, current_level: int, current_exp: int, exp_to_next: int)

# Economy events
signal coins_changed(new_total: int)

# Buff/Debuff events
signal buff_applied(buff_type: String, duration: float)
signal buff_expired(buff_type: String)

# UI events
signal ring_menu_opened()

# Save/Load events
signal game_saved()
signal game_loaded()

# Companion events
signal active_companion_changed(companion_id: String)
signal companion_knocked_out(companion_id: String)
signal companion_revived(companion_id: String)
signal companion_meter_changed(companion_id: String, meter_value: float)

# Difficulty events
signal difficulty_changed(new_difficulty: int)
signal difficulty_system_ready()
