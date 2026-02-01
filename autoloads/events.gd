extends Node
## Global event bus for game-wide signals.
## Use this to decouple systems - emit events here, listen from anywhere.

# =============================================================================
# PLAYER EVENTS
# =============================================================================

signal player_health_changed(current: int, max_health: int)
signal player_leveled_up(new_level: int)
signal exp_gained(amount: int, current_level: int, current_exp: int, exp_to_next: int)
signal guard_changed(current: float, max_guard: float)
signal player_attacked()
signal player_dodged()
signal player_damaged()
signal player_blocked()

# =============================================================================
# COMBAT EVENTS
# =============================================================================

signal enemy_defeated(enemy_id: String)
signal enemy_spawned(enemy_id: String)
signal combo_changed(count: int)
signal combo_completed(count: int)

# =============================================================================
# ECONOMY EVENTS
# =============================================================================

signal coins_changed(new_amount: int)

# =============================================================================
# INVENTORY EVENTS
# =============================================================================

signal pickup_collected(item_id: String)
signal ring_menu_opened()
signal item_used(item_id: String)

# =============================================================================
# SAVE/LOAD EVENTS
# =============================================================================

signal game_saved()
signal game_loaded()

# =============================================================================
# QUEST EVENTS
# =============================================================================

signal quest_started(quest_id: String)
signal quest_updated(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_failed(quest_id: String)
signal active_quest_changed(quest_id: String)

# =============================================================================
# TUTORIAL SIGNALS
# =============================================================================

## Emitted when a tutorial should be triggered
signal tutorial_triggered(tutorial_id: String)

## Emitted when a tutorial is completed
signal tutorial_completed(tutorial_id: String)

## Emitted when a player performs an action tracked by a tutorial
signal tutorial_action_performed(tutorial_id: String, count: int)
