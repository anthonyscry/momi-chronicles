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
# COMPANION EVENTS
# =============================================================================

## Emitted when a companion joins the party
signal companion_joined(companion_id: String)

## Future hook — emitted before zone transition. Could drive cleanup tasks,
## play-time tracking, or zone-exit save triggers.
signal zone_exited(zone_name: String)

## Emitted when a zone transition is triggered
signal zone_transition_requested(target_zone: String, spawn_point: String)

# ======================================================================# GAME STATE SIGNALS
# =============================================================================

## Emitted when game is paused
signal game_paused

## Emitted when game is resumed
signal game_resumed

## Emitted when game over state is triggered
signal game_over

## Emitted when game restarts — temporary state cleared in GameManager.restart_game()
signal game_restarted

# =============================================================================
# SAVE SYSTEM SIGNALS
# =============================================================================

## Emitted when game is saved
signal game_saved

## Emitted when game is loaded — could drive HUD refresh on load
signal game_loaded

## Emitted if save file is corrupt — handled by title screen warning UI
signal save_corrupted

# =============================================================================
# MENU SIGNALS
# =============================================================================

## Emitted when pause menu opens
signal menu_opened

## Emitted when pause menu closes
signal menu_closed

## Emitted when inventory opens
signal inventory_opened

## Emitted when inventory closes
signal inventory_closed

# =============================================================================
# RING MENU SIGNALS
# =============================================================================

## Emitted when ring menu opens
signal ring_menu_opened

## Future hook — paired with ring_menu_opened. Could re-show hidden HUD
## elements or resume gameplay effects on menu close.
signal ring_menu_closed

# =============================================================================
# BUFF SYSTEM SIGNALS
# =============================================================================

## Emitted when a buff is applied
signal buff_applied(effect_type: int, value: float, duration: float)

## Emitted when a buff expires
signal buff_expired(effect_type: int)

# =============================================================================
# EQUIPMENT SIGNALS
# =============================================================================

## Future hook — broadcast when equipment slot changes. Could drive inventory
## UI refresh, paper-doll display, or stat comparisons.
signal equipment_changed(slot: int, equipment_id: String)

## Emitted when an item is equipped
signal item_equipped(item: Dictionary)

## Emitted when a consumable item is used
signal item_used(item: Dictionary)

# =============================================================================
# COMPANION/PARTY SIGNALS
# =============================================================================

## Emitted when active companion changes
=======
## Emitted when the active companion is changed (companion swap)
signal active_companion_changed(companion_id: String)

## Emitted when a companion is knocked out
signal companion_knocked_out(companion_id: String)

## Emitted when a companion is revived
signal companion_revived(companion_id: String)

## Emitted when a companion's meter value changes
signal companion_meter_changed(companion_id: String, current: float, max_val: float)

# =============================================================================
# TUTORIAL SIGNALS
# =============================================================================

## Emitted when a tutorial should be triggered
signal tutorial_triggered(tutorial_id: String)

## Emitted when shop UI closes
signal shop_closed

## Emitted when a purchase is completed
signal shop_purchase_completed(item: Dictionary, cost: int)
## Emitted when a tutorial is completed
signal tutorial_completed(tutorial_id: String)

## Emitted when a player performs an action tracked by a tutorial
signal tutorial_action_performed(tutorial_id: String, count: int)
