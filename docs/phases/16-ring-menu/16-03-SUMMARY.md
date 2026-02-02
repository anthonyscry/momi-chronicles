---
phase: 16-ring-menu
plan: 03
status: complete
affects: [16-04]
subsystem: equipment
---

# 16-03 Summary: Equipment System

## What Was Built

Equipment system with 5 dog-themed slots and stat bonuses.

## Key Files

| File | Purpose |
|------|---------|
| `systems/equipment/equipment_database.gd` | Equipment definitions (~180 lines) |
| `systems/equipment/equipment_manager.gd` | Equip/unequip and stat calculation (~180 lines) |

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| 5 slots (Collar/Harness/Leash/Coat/Hat) | Dog-themed as per CONTEXT.md |
| Instant equip (no confirmation) | User preference from discussion |
| Equipment doesn't stack | Each piece is unique |
| Stats as dictionary with enum keys | Type-safe, easy lookup |

## Equipment Slots

| Slot | Typical Stats | Starting Item |
|------|---------------|---------------|
| Collar | HP, Attack, EXP | Basic Collar (+5 HP) |
| Harness | HP, Defense, Attack | Training Harness (+10 HP) |
| Leash | Speed, Attack | Retractable Leash (+5 Speed) |
| Coat | HP, Defense, Attack | (none) |
| Hat | Speed, Defense, Guard | (none) |

## Stat Types

- `MAX_HEALTH` - Bonus HP
- `ATTACK_DAMAGE` - Bonus damage
- `MOVE_SPEED` - Bonus speed
- `DEFENSE` - Damage reduction %
- `GUARD_REGEN` - Guard meter recovery
- `EXP_BONUS` - Bonus experience %

## Tech Available

- `EquipmentDatabase.get_equipment(id)` - Get equipment data
- `EquipmentDatabase.Slot` enum - COLLAR, HARNESS, etc.
- `EquipmentDatabase.StatType` enum - MAX_HEALTH, etc.
- `EquipmentManager.equip(id)` - Instant equip
- `EquipmentManager.unequip(slot)` - Unequip
- `EquipmentManager.get_stat_bonus(stat_type)` - Total bonus
- `EquipmentManager.get_equipment_for_ring()` - For ring menu

## Integration Points

- `GameManager.equipment_manager` - Global access
- Ring menu `_get_equipment_items()` returns real data
- Ring menu `_equip_item()` calls equip/unequip
- `Events.equipment_changed` signal for UI updates
- `stats_recalculated` signal for player stat updates

## Starting Equipment

- Basic Collar (+5 Max HP)
- Training Harness (+10 Max HP)
- Retractable Leash (+5 Speed)

## Commit

`8b600fe` - feat(16-02/03): implement inventory and equipment systems
