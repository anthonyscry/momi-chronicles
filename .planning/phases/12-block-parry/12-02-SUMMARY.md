---
phase: 12-block-parry
plan: 02
status: complete
subsystem: combat
affects: [player, enemies, hud]

tech-stack:
  added: []
  patterns: [parry-window, stun-state, guard-meter-ui]

key-files:
  - characters/player/states/player_block.gd
  - components/guard/guard_component.gd
  - characters/enemies/enemy_base.gd
  - ui/hud/guard_bar.gd
  - ui/hud/guard_bar.tscn
  - ui/hud/game_hud.tscn

decisions:
  - "Parry window is 0.15 seconds at start of block"
  - "Perfect parry reflects 50% damage back to attacker"
  - "Perfect parry stuns attacker for 1 second"
  - "Stun handled inline in enemy_base.gd (no separate Stunned state)"
  - "Stunned enemies have blue tint visual feedback"
  - "Guard bar fades when full (0.3 alpha), solid when depleting"
  - "Guard bar uses blue/cyan color theme"

requires: ["12-01"]
---

## Summary

Added parry mechanics with timing-based counter and guard meter UI to complete the defensive combat system.

## What Was Built

### Parry System (`characters/player/states/player_block.gd`)
- `PARRY_WINDOW: 0.15` - First 150ms of block is parry window
- `block_timer` tracks time since block started
- `parry_available` flag prevents multiple parries per block
- `is_in_parry_window()` method for GuardComponent to query
- Bot control support via `player.bot_blocking`

### Parry Execution (`components/guard/guard_component.gd`)
- `on_blocked_hit(attacker, incoming_damage)` - Called when hit while blocking
  - Checks if in parry window via `block_state.is_in_parry_window()`
  - Returns `true` if parried (no damage taken)
  - Returns `false` if normal block (extra 15 guard cost)
- `_execute_parry(attacker, incoming_damage)` - Handles parry effects:
  - Reflects 50% damage to attacker's HealthComponent
  - Calls `attacker.apply_stun(1.0)` for 1 second stun
  - White flash on player sprite (0.1s)
  - Emits `Events.player_parried(attacker, reflected_damage)`

### Enemy Stun Support (`characters/enemies/enemy_base.gd`)
- `is_stunned: bool` and `stun_timer: float` state
- `apply_stun(duration)` - Sets stun state, blue tint visual
- `_end_stun()` - Clears stun, restores visual
- `can_act()` helper - Returns false if stunned or dead
- Stun timer handled in `_process()` - no separate state node needed

### Guard Bar UI (`ui/hud/guard_bar.gd`, `guard_bar.tscn`)
- ProgressBar showing current/max guard
- Label showing numeric value
- Fades to 0.3 alpha when guard is full
- Solid (1.0 alpha) when guard is depleting
- Color gradient: blue (>50%) → darker blue (>25%) → purple (danger)
- Connected to `Events.guard_changed` signal

### HUD Integration (`ui/hud/game_hud.tscn`)
- GuardBar added below HealthBar in VBoxContainer
- Automatically visible with health bar

### Events Added (`autoloads/events.gd`)
- `signal player_parried(attacker: Node, reflected_damage: int)`

## How It Works

1. **Player presses V** → Block state entered, `block_timer = 0`
2. **First 0.15 seconds** → `is_in_parry_window()` returns true
3. **Enemy hits player** → `player._on_hurt()` calls `guard.on_blocked_hit()`
4. **If in parry window** → `_execute_parry()`:
   - Attacker takes 50% reflected damage
   - Attacker stunned for 1 second (blue tint, can't act)
   - Player takes NO damage
   - `Events.player_parried` emitted
5. **If after parry window** → Normal block:
   - 50% damage reduction
   - 15 extra guard cost
   - Player doesn't transition to Hurt state
6. **Guard bar** updates in real-time via Events

## Testing Verification

- [x] Parry timing works (early block = parry, late block = normal)
- [x] Parried enemies take reflected damage
- [x] Parried enemies stunned for 1 second (blue tint, no movement)
- [x] Guard bar visible below health bar
- [x] Guard bar fades when full, solid when depleting
- [x] Guard bar color changes based on percentage

## Phase 12 Complete

Block & Parry system fully implemented:
- Block reduces damage by 50%
- Guard meter depletes while blocking
- Perfect parry (first 0.15s) reflects damage and stuns
- Guard bar shows meter status in HUD
