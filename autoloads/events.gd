extends Node
## Global signal bus for decoupled communication between systems.
## Usage: Events.signal_name.emit(args) or Events.signal_name.connect(callable)

# =============================================================================
# PLAYER SIGNALS
# =============================================================================

## Emitted when player takes damage
signal player_damaged(amount: int)

## Emitted when player health reaches zero
signal player_died

## Emitted when player gains health
signal player_healed(amount: int)

## Emitted when player's health changes (for UI updates)
signal player_health_changed(current: int, max_health: int)

# =============================================================================
# COMBAT SIGNALS
# =============================================================================

## Emitted when any enemy takes damage
signal enemy_damaged(enemy: Node, amount: int)

## Emitted when an enemy is defeated
signal enemy_defeated(enemy: Node)

## Emitted when player performs an attack
signal player_attacked

## Emitted when player performs a special attack
signal player_special_attacked

## Emitted when player successfully hits an enemy
signal player_hit_enemy(enemy: Node)

## Emitted when player performs a dodge
signal player_dodged

# =============================================================================
# BLOCK/GUARD SIGNALS
# =============================================================================

## Emitted when player starts blocking
signal player_block_started

## Future hook — emitted when block released. Could drive shield-lower SFX,
## visual effects, or enemy AI reaction windows.
signal player_block_ended

## Future hook — guard meter depleted. Could drive guard-break SFX,
## stagger animation, enemy aggro spike, or achievement.
signal player_guard_broken

## Emitted when guard meter changes (for UI)
signal guard_changed(current: float, max_guard: float)

## Emitted when player performs a perfect parry
signal player_parried(attacker: Node, reflected_damage: int)

# =============================================================================
# COMBO SIGNALS
# =============================================================================

## Emitted when combo count changes
signal combo_changed(combo_count: int)

## Emitted when full combo chain completes (all 3 hits)
signal combo_completed(total_damage: int)

## Emitted when combo drops (missed timing window)
signal combo_dropped

# =============================================================================
# PROGRESSION SIGNALS
# =============================================================================

## Emitted when player gains EXP
signal exp_gained(amount: int, current_level: int, current_exp: int, exp_to_next: int)

## Emitted when player levels up
signal player_leveled_up(new_level: int)

## Future hook — emitted on level-up stat changes. Could drive stat sheet UI,
## achievement tracking, or companion scaling.
signal stats_updated(stat_name: String, new_value: int)

# =============================================================================
# CHARGE ATTACK SIGNALS
# =============================================================================

## Emitted when charge attack begins
signal player_charge_started

## Emitted when charge attack releases
signal player_charge_released(damage: int, charge_percent: float)

# =============================================================================
# GROUND POUND SIGNALS
# =============================================================================

## Emitted when ground pound starts
signal player_ground_pound_started

## Emitted when ground pound impacts
signal player_ground_pound_impact(damage: int, radius: float)

# =============================================================================
# BOSS SIGNALS
# =============================================================================

## Emitted when boss spawns
signal boss_spawned(boss: Node)

## Emitted when boss enters enraged state
signal boss_enraged(boss: Node)

## Emitted when boss is defeated
signal boss_defeated(boss: Node)

# =============================================================================
# MINI-BOSS SIGNALS
# =============================================================================

## Emitted when a mini-boss spawns (boss: the mini-boss node, boss_name: display name)
signal mini_boss_spawned(boss: Node, boss_name: String)

## Emitted when a mini-boss is defeated (boss: the mini-boss node, boss_key: save key)
signal mini_boss_defeated(boss: Node, boss_key: String)

# =============================================================================
# PICKUP SIGNALS
# =============================================================================

## Future hook — emitted on any pickup collection. Could drive collection
## stats, achievements, or tutorial triggers.
signal pickup_collected(pickup_type: String, value: int)

## Emitted when coin count changes
signal coins_changed(total: int)

# =============================================================================
# ZONE SIGNALS
# =============================================================================

## Emitted when entering a new zone
signal zone_entered(zone_name: String)

## Future hook — emitted before zone transition. Could drive cleanup tasks,
## play-time tracking, or zone-exit save triggers.
signal zone_exited(zone_name: String)

## Emitted when a zone transition is triggered
signal zone_transition_requested(target_zone: String, spawn_point: String)

# =============================================================================
# GAME STATE SIGNALS
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
signal active_companion_changed(companion_id: String)

## Emitted when a companion is knocked out
signal companion_knocked_out(companion_id: String)

## Emitted when a companion is revived
signal companion_revived(companion_id: String)

## Emitted when a companion's meter changes
signal companion_meter_changed(companion_id: String, current: float, max_val: float)

# =============================================================================
# SHOP SIGNALS
# =============================================================================

## Emitted when player presses E near shop NPC
signal shop_interact_requested

## Emitted when shop UI closes
signal shop_closed

## Emitted when a purchase is completed
signal shop_purchase_completed(item: Dictionary, cost: int)
