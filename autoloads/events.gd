extends Node
## Global event bus for game-wide signals.
## Use this to decouple systems - emit events here, listen from anywhere.

# Player events
signal player_health_changed(current: int, max_health: int)
signal player_leveled_up(new_level: int)
signal exp_gained(amount: int, current_level: int, current_exp: int, exp_to_next: int)
signal guard_changed(current: float, max_guard: float)

# Economy events
signal coins_changed(new_amount: int)

# Save/Load events
signal game_saved()
signal game_loaded()

# Quest events
signal quest_started(quest_id: String)
signal quest_updated(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal active_quest_changed(quest_id: String)
