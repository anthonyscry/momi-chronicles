extends Node
## Global event bus for game-wide signals.
##
## This autoload singleton provides centralized event signaling across the game.
## All components can emit and connect to these signals without tight coupling.

# ============================================================================
# Player Events
# ============================================================================
signal player_leveled_up
signal exp_gained

# ============================================================================
# Combat Events
# ============================================================================
signal boss_spawned
signal boss_enraged
signal boss_defeated
signal mini_boss_spawned
signal mini_boss_defeated

# ============================================================================
# Buff/Debuff Events
# ============================================================================
signal buff_applied
signal buff_expired

# ============================================================================
# Inventory Events
# ============================================================================
signal coins_changed

# ============================================================================
# Companion Events
# ============================================================================
signal active_companion_changed
signal companion_knocked_out
signal companion_revived
signal companion_meter_changed

# ============================================================================
# Combo Events
# ============================================================================
signal combo_changed
signal combo_dropped
signal combo_completed

# ============================================================================
# UI Events
# ============================================================================
signal ring_menu_opened
signal ring_menu_closed

# ============================================================================
# Dialogue Events
# ============================================================================

## Emitted when dialogue starts.
## @param dialogue: The DialogueResource that was started
signal dialogue_started(dialogue: DialogueResource)

## Emitted when dialogue advances to the next entry.
## @param dialogue: The new current DialogueResource
signal dialogue_advanced(dialogue: DialogueResource)

## Emitted when a dialogue choice is made.
## @param choice_index: The index of the selected choice (0-based)
## @param choice: The choice dictionary containing 'text' and 'next_id'
signal dialogue_choice_made(choice_index: int, choice: Dictionary)

## Emitted when dialogue ends.
signal dialogue_ended

## Emitted when cutscene mode begins (player input disabled).
signal cutscene_started

## Emitted when cutscene mode ends (player input re-enabled).
signal cutscene_ended
