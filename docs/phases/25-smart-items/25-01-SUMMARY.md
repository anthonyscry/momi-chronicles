---
phase: 25-smart-items
plan: 01
status: complete
date: 2026-01-28
duration: ~15 min
subsystem: autoloads/auto_bot.gd
affects: [25-02]

tech-stack:
  existing: [GDScript, GameManager.inventory, ItemDatabase.EffectType, guard_component]
  added: []

files:
  modified:
    - autoloads/auto_bot.gd
  created: []

key-decisions:
  - decision: "3-tier healing by HP percentage"
    rationale: "Light (<90%), moderate (<50%), heavy (<40%) prevents wasting strong items on scratches"
  - decision: "Guard snack at 20% guard in combat"
    rationale: "Below 20% guard is guard-broken territory, snack prevents full depletion"
  - decision: "One buff per decision cycle"
    rationale: "Spreading buff usage over multiple cycles prevents using all 3 treats simultaneously"
  - decision: "Speed treat at critical health regardless of tough fight"
    rationale: "Speed is the best escape tool when near death"

key-exports:
  - name: _try_use_smart_healing()
    type: function
    location: autoloads/auto_bot.gd
  - name: _try_use_guard_snack()
    type: function
    location: autoloads/auto_bot.gd
  - name: _try_use_buff_treats()
    type: function
    location: autoloads/auto_bot.gd
  - name: _is_tough_enemy()
    type: function
    location: autoloads/auto_bot.gd

patterns:
  - "Tiered item selection by damage severity"
  - "Combat-specific item usage (guard snack, buff treats)"
  - "Buff duplication prevention via has_buff() check"
---

## Summary

Replaced flat `_try_use_healing_item()` with smart 3-tier healing, added guard snack usage when guard breaks in combat, and buff treat usage before tough encounters. Bot now uses all 6 previously-ignored item types.

## What Changed

### 1. Smart Tiered Healing (`_try_use_smart_healing()`)
- Heavy damage (<40% HP): full_heal → mega_potion → health_potion → acorn → bird_seed
- Moderate damage (40-50% HP): health_potion → mega_potion → acorn → bird_seed
- Light damage (50-90% HP): acorn → bird_seed only
- Critical health triggers healing even in combat
- Safe healing (no enemies) at any damage level below 90%

### 2. Guard Snack (`_try_use_guard_snack()`)
- Triggers when guard meter < 20% AND in combat
- 5-second cooldown prevents spam
- Only checks guard_component if it exists

### 3. Buff Treats (`_try_use_buff_treats()`)
- Triggers before tough fights (3+ enemies or mini-boss with 80+ HP)
- power_treat: boosts attack for tough fights (checked first)
- tough_treat: reduces incoming damage
- speed_treat: available at critical health for escape regardless of fight toughness
- Checks `has_buff()` before each use to prevent duplication
- One buff per cycle to spread usage

### 4. Updated `_update_phase16_systems()`
- Critical healing runs even in combat
- Guard snack and buff treats run in combat block
- Non-combat items (healing, revival, equipment) run when safe
- New timer management for revival and equipment checks

## Verification
- All new functions exist, all new constants exist
- Old `_try_use_healing_item` fully removed
- All 6 item types (acorn, bird_seed, guard_snack, power_treat, speed_treat, tough_treat) referenced
- has_buff checks prevent buff duplication
