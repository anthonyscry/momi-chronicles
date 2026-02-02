---
phase: 16-ring-menu
plan: 02
status: complete
affects: [16-04]
subsystem: inventory
---

# 16-02 Summary: Items & Inventory System

## What Was Built

Complete item and inventory system with consumables, buffs, and ring menu integration.

## Key Files

| File | Purpose |
|------|---------|
| `systems/inventory/item_database.gd` | Item definitions with effects (~140 lines) |
| `systems/inventory/inventory.gd` | Inventory management and buff system (~200 lines) |

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Static const ITEMS dictionary | Fast lookup, no runtime allocation |
| Buff system in Inventory | Keeps all item effects centralized |
| Revival item for companions | Prepares for 16-04 party system |
| MAX_SLOTS = 20 | Reasonable limit for ring menu display |

## Items Available

| Item | Effect | Max Stack |
|------|--------|-----------|
| Health Potion | +50 HP | 10 |
| Mega Potion | +150 HP | 5 |
| Full Heal | 100% HP | 3 |
| Acorn | +15 HP | 20 |
| Bird Seed | +10 HP | 30 |
| Power Treat | +50% Attack, 30s | 5 |
| Speed Treat | +30% Speed, 30s | 5 |
| Tough Treat | -30% Damage, 30s | 5 |
| Guard Snack | Full guard meter | 10 |
| Revival Bone | Revive companion 50% | 3 |

## Tech Available

- `ItemDatabase.get_item(id)` - Get item data
- `ItemDatabase.EffectType` enum - HEAL, BUFF_ATTACK, etc.
- `Inventory.add_item(id, qty)`, `remove_item(id, qty)`
- `Inventory.use_item(id, target)` - Applies effect
- `Inventory.get_buff_multiplier(effect_type)` - For stats
- `Inventory.get_all_items()` - For ring menu

## Integration Points

- `GameManager.inventory` - Global access
- Ring menu `_get_inventory_items()` returns real data
- Ring menu `_use_item()` calls `inventory.use_item()`
- `EffectsManager.spawn_pickup_effect()` for visual feedback
- `AudioManager.play_sfx("health_pickup")` on item use

## Starting Inventory

- 3x Health Potion
- 5x Acorn

## Commit

`8b600fe` - feat(16-02/03): implement inventory and equipment systems
