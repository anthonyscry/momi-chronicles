---
phase: 27-game-loop-ai
plan: 01
status: complete
date: 2026-01-28
duration: ~15 min
subsystem: autoloads/auto_bot.gd
affects: []

tech-stack:
  existing: [GDScript, GameManager, BaseZone.zone_id, Zone transitions]
  added: []

files:
  modified:
    - autoloads/auto_bot.gd
  created: []

key-decisions:
  - decision: "6-state game loop: FARM → SHOP → TRAVERSE → CLEAR → BOSS → VICTORY"
    rationale: "Simple linear progression matching the game's zone structure"
  - decision: "10 kill farm target before shopping"
    rationale: "Enough to earn coins and gain some levels before progressing"
  - decision: "Level 3 for sewers, Level 5 for boss"
    rationale: "Ground pound unlocks at 5 (needed for boss), sewers needs some combat ability"
  - decision: "Kill tracking via enemy count delta"
    rationale: "Comparing living enemy count between frames catches all deaths without signal wiring"

key-exports:
  - name: GameLoopState enum
    type: enum
    location: autoloads/auto_bot.gd
  - name: game_loop_state
    type: int
    location: autoloads/auto_bot.gd
  - name: _update_game_loop()
    type: function
    location: autoloads/auto_bot.gd
  - name: _get_next_zone()
    type: function
    location: autoloads/auto_bot.gd

patterns:
  - "State machine with match statement for game loop"
  - "Zone progression gates by player level"
  - "Kill tracking via frame-over-frame count comparison"
---

## Summary

Added a full game loop state machine to the AutoBot. The bot now progresses through FARM → SHOP → TRAVERSE → CLEAR → BOSS → VICTORY, navigating between all zones, shopping for supplies, clearing enemies, and fighting the boss.

## What Changed

### 1. GameLoopState Enum
- FARM: Kill enemies in neighborhood (target: 10 kills or level 3)
- SHOP: Visit Nutkin for supplies (coins > 50)
- TRAVERSE: Navigate to next zone in progression
- CLEAR: Kill all enemies in current zone
- BOSS: Navigate to and fight the boss
- VICTORY: Boss defeated — game complete

### 2. State Machine (`_update_game_loop()`)
- Runs on 10s timer interval
- Reads current zone_id and player level
- Dispatches to per-state handler
- Each handler manages transitions and sets navigation flags

### 3. Zone Progression (`_get_next_zone()`)
- Neighborhood → Backyard (always)
- Backyard → Sewers (if level >= 3, else back to neighborhood)
- Sewers → Boss Arena (if level >= 5, else back to neighborhood)
- Boss Arena → stay (fight to win)

### 4. Kill Tracking
- Counts kills by detecting drops in living enemy count
- Resets on zone transition (player ref change)
- Used by FARM state to determine when to progress

### 5. Debug Output Enhancement
- Debug log now shows game loop state alongside combat state
- Format: `[AutoBot] State: FARMING | Loop: FARM | Pos: ... | Kills: 5`

## Verification
- All 6 GameLoopState values handled in match statement
- `_update_game_loop()` called in `_physics_process()`
- Zone progression: neighborhood → backyard → sewers → boss_arena
- Level gates: 3 for sewers, 5 for boss
- Kill tracking via `_last_enemy_count` delta
- Debug output includes loop state
