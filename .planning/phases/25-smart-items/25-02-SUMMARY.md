---
phase: 25-smart-items
plan: 02
status: complete
date: 2026-01-28
duration: ~10 min (combined with 25-01 implementation)
subsystem: autoloads/auto_bot.gd
affects: [26, 27]

tech-stack:
  existing: [GDScript, GameManager.party_manager, GameManager.equipment_manager, EquipmentDatabase]
  added: []

files:
  modified:
    - autoloads/auto_bot.gd
  created: []

key-decisions:
  - decision: "Revive at 50% HP"
    rationale: "Standard RPG revival rate — companion is functional but not full health"
  - decision: "Weighted stat scoring for equipment"
    rationale: "ATK 3x, DEF 2x, HP/Guard 1.5x, SPD 1x, EXP 0.5x — attack-first strategy for faster kills"
  - decision: "Both use_item and revive_companion calls"
    rationale: "use_item consumes the item + plays sound, revive_companion handles game logic — both needed"
  - decision: "Equipment check every 30s"
    rationale: "New gear only arrives from drops/shop, no need for frequent checks"

key-exports:
  - name: _try_revive_companion()
    type: function
    location: autoloads/auto_bot.gd
  - name: _optimize_equipment()
    type: function
    location: autoloads/auto_bot.gd
  - name: _get_equipment_score()
    type: function
    location: autoloads/auto_bot.gd

patterns:
  - "Timer-gated periodic checks (revival 5s, equipment 30s)"
  - "Weighted scoring for equipment comparison"
  - "Dual API call pattern (consume item + execute game logic)"
---

## Summary

Added companion revival using revival_bone and equipment auto-optimization to the AutoBot. Bot now keeps its party alive and always wears the strongest available gear.

## What Changed

### 1. Companion Revival (`_try_revive_companion()`)
- Checks every 5s via `revival_check_timer`
- Only when safe (no enemies nearby)
- Checks `party_manager.knocked_out` dictionary for KO'd companions
- Uses `inventory.use_item("revival_bone")` to consume + `party_manager.revive_companion(id, 0.5)` to revive at 50% HP
- Revives first knocked-out companion found

### 2. Equipment Optimization (`_optimize_equipment()`)
- Checks every 30s via `equip_check_timer`
- Only when safe (no enemies nearby)
- Iterates all 5 equipment slots (Collar, Harness, Leash, Coat, Hat)
- For each slot: compares currently equipped item's score vs all unequipped alternatives
- Equips highest-scoring item per slot
- Score = weighted sum of all stats

### 3. Equipment Scoring (`_get_equipment_score()`)
- ATTACK_DAMAGE: 3.0x (kills faster = takes less damage)
- DEFENSE: 2.0x (percentage reduction is powerful)
- MAX_HEALTH: 1.5x (survival buffer)
- GUARD_REGEN: 1.5x (supports blocking playstyle)
- MOVE_SPEED: 1.0x (kiting utility)
- EXP_BONUS: 0.5x (nice but not survival)

## Verification
- `_try_revive_companion`, `_optimize_equipment`, `_get_equipment_score` functions exist
- `REVIVAL_CHECK_INTERVAL` (5.0) and `EQUIP_CHECK_INTERVAL` (30.0) constants exist
- `revival_bone` and `revive_companion` calls present
- Equipment scoring weights verified
