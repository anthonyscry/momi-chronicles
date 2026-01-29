---
phase: 26-zone-traversal
plan: 01
status: complete
date: 2026-01-28
duration: ~15 min
subsystem: autoloads/auto_bot.gd
affects: [27]

tech-stack:
  existing: [GDScript, ZoneExit, ShopNPC, Events signals]
  added: []

files:
  modified:
    - autoloads/auto_bot.gd
  created: []

key-decisions:
  - decision: "Navigate to zone exit by target_zone property"
    rationale: "ZoneExit nodes have target_zone export — match by desired destination"
  - decision: "E key interaction for require_interaction exits"
    rationale: "Manhole and boss door require E press, matching player behavior"
  - decision: "Shop visit when health items < 3 and coins > 200"
    rationale: "Balance between being well-stocked and not wasting time shopping"
  - decision: "Direct Events.shop_interact_requested emission"
    rationale: "Same signal path as player pressing E near NPC — shop UI opens normally"

key-exports:
  - name: _find_zone_exit()
    type: function
    location: autoloads/auto_bot.gd
  - name: _navigate_to_zone_exit()
    type: function
    location: autoloads/auto_bot.gd
  - name: _should_visit_shop()
    type: function
    location: autoloads/auto_bot.gd
  - name: _navigate_to_shop_npc()
    type: function
    location: autoloads/auto_bot.gd
  - name: wants_zone_transition
    type: bool
    location: autoloads/auto_bot.gd
  - name: target_exit_zone_id
    type: String
    location: autoloads/auto_bot.gd

patterns:
  - "Priority-based navigation in wander state (zone exit > shop > patrol)"
  - "InputEventAction for interact button simulation"
  - "Timer-gated shop visit checks (20s interval)"
---

## Summary

Added zone exit navigation and NPC shop interaction to the AutoBot. Bot can now detect ZoneExit nodes, navigate to them, press E for interactive exits, detect when supplies are low, navigate to Nutkin's shop, and interact to open the shop.

## What Changed

### 1. Zone Exit Navigation
- `_find_zone_exit(target_zone_id)`: Searches ZoneExits container and direct children for matching exit
- `_navigate_to_zone_exit(delta)`: Walks to exit, presses E for require_interaction exits
- `wants_zone_transition` / `target_exit_zone_id` flags for Phase 27 game loop to set
- 30px interact range, 1s cooldown between E presses

### 2. Shop NPC Interaction
- `_should_visit_shop()`: Checks neighborhood zone + 200+ coins + <3 health items
- `_navigate_to_shop_npc()`: Finds ShopNPC, walks to it, emits shop_interact_requested
- Auto-closes shop after 2s browse period
- 20s check interval, only in neighborhood, only when safe

### 3. Decision Integration
- Zone transition is highest priority in wander state (overrides patrol)
- Shop visit is second priority (overrides patrol)
- Normal wander/patrol is fallback when no navigation objective

## Verification
- All 4 navigation functions exist
- State variables for zone traversal and shop navigation exist
- Constants SHOP_HEALTH_ITEM_MIN (3) and SHOP_COINS_MIN (200) exist
- Zone exit interact and shop interact logic present
