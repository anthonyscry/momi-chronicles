---
phase: 12-block-parry
plan: 01
status: complete
subsystem: combat
affects: [player, combat-system]

tech-stack:
  added: []
  patterns: [guard-component, block-state]

key-files:
  - components/guard/guard_component.gd
  - components/guard/guard_component.tscn
  - characters/player/states/player_block.gd
  - characters/player/player.gd
  - characters/player/player.tscn

decisions:
  - "Block mapped to V key"
  - "Guard depletes at 30/sec, regens at 20/sec after 1s delay"
  - "Blocking reduces damage by 50%"
  - "Extra 10 guard cost when hit while blocking"
  - "Visual feedback via sprite color darkening (blue-gray tint)"

requires: []
---

## Summary

Created the block state and guard meter system for defensive combat.

## What Was Built

### GuardComponent (`components/guard/`)
- **guard_component.gd**: Resource management for blocking
  - `max_guard: 100`, `guard_drain_rate: 30/sec`, `guard_regen_rate: 20/sec`
  - `regen_delay: 1.0s` before regeneration starts
  - Signals: `guard_changed`, `guard_broken`, `guard_restored`
  - Emits global Events for UI (guard bar in Phase 12-02)
  - Helper: `get_damage_reduction()` returns 0.5 when blocking

### PlayerBlock State (`characters/player/states/player_block.gd`)
- Enters when V pressed and guard available
- Stops player movement
- Visual feedback: sprite darkens to blue-gray tint
- Exits on: button release, guard depleted, or taking hit that breaks guard
- Emits `Events.player_block_started` / `player_block_ended`

### Player Integration
- **player.gd**: 
  - Added `@onready var guard = $GuardComponent`
  - Added `is_blocking()` helper method
  - Updated `_on_hurt()`: reduces damage by 50% when blocking, costs 10 extra guard on hit, skips Hurt state transition while blocking
- **player.tscn**: Added Block state to StateMachine, added GuardComponent instance
- **player_idle.gd**: Already had block input check (lines 43-47)

### Events Added (`autoloads/events.gd`)
- `signal player_block_started`
- `signal player_block_ended`
- `signal player_guard_broken`
- `signal guard_changed(current: float, max_guard: float)`

## How It Works

1. **Press V to block**: Idle state checks `Input.is_action_pressed("block")` and transitions to Block state if guard available
2. **Guard depletes**: GuardComponent's `_process()` calls `use_guard()` every frame while `is_blocking = true`
3. **Taking damage while blocking**: `player._on_hurt()` checks `guard.is_blocking`, applies 50% reduction, adds 10 guard cost
4. **Guard breaks**: When `current_guard <= 0`, `guard_broken` emitted, `is_blocking` set false, player forced out of Block state
5. **Regeneration**: After 1 second of not blocking, guard regens at 20/sec until full

## Testing Instructions

1. Run game with F5
2. Press V to enter block state (Momi stops, sprite turns blue-gray)
3. Release V to exit block state (sprite returns to tan)
4. Find an enemy, let it hit you while blocking - damage should be halved
5. Hold V for ~3.3 seconds - guard depletes and block breaks automatically
6. Wait 1+ seconds after blocking - guard regenerates

## Next Steps

- **12-02-PLAN.md**: Add parry system (perfect timing in first 0.15s) and guard bar UI
