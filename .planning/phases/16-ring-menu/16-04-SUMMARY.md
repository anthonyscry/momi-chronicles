---
phase: 16-ring-menu
plan: 04
status: complete
affects: []
subsystem: party
---

# 16-04 Summary: Party System

## What Was Built

Full party system with 3 AI-controlled bulldog companions fighting together, each with unique meter mechanics.

## Key Files

| File | Purpose |
|------|---------|
| `systems/party/companion_data.gd` | Companion definitions (~100 lines) |
| `systems/party/party_manager.gd` | Party cycling and state (~180 lines) |
| `systems/party/companion_ai.gd` | AI follow/attack behavior (~120 lines) |
| `characters/companions/companion_base.gd` | Base companion class (~220 lines) |
| `characters/companions/momi_companion.gd` | Momi with Zoomies |
| `characters/companions/cinnamon_companion.gd` | Cinnamon with Overheat |
| `characters/companions/philo_companion.gd` | Philo with Motivation |
| `ui/hud/companion_hud.gd` | HUD for all companions |
| `ui/hud/companion_hud.tscn` | HUD scene with 3 panels |

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Party fights together (not swap) | User's explicit preference |
| Q cycles control | Quick switching without menu |
| Philo restores when MOMI hit | Unique support synergy |
| AI with presets | Configurable via Options ring |
| CompanionBase class | Shared behavior, subclass for unique meters |

## The Bulldog Squad

| Companion | Role | Meter | Unique Mechanic |
|-----------|------|-------|-----------------|
| Momi | DPS | Zoomies | Builds from combat, activate for speed boost |
| Cinnamon | Tank | Overheat | Builds from blocking, forces cooldown when maxed |
| Philo | Support | Motivation | Starts high, drains over time, restores when Momi hit |

## Tech Available

- `CompanionData.get_companion(id)` - Get companion definition
- `PartyManager.cycle_active_companion()` - Q key cycling
- `PartyManager.revive_companion(id, percent)` - Revival via items
- `PartyManager.get_companions_for_ring()` - Ring menu data
- `CompanionAI.get_ai_move_direction()` - Follow/attack movement
- `CompanionAI.should_attack()` - Attack decision

## Integration Points

- `GameManager.party_manager` - Global access
- Ring menu `_get_companions()` returns real party data
- Ring menu `_switch_companion()` switches control
- `Events.active_companion_changed` for HUD highlight
- `Events.companion_knocked_out` for KO handling
- `Events.companion_meter_changed` for HUD updates

## AI Presets

| Preset | Follow Distance | Attack Range |
|--------|-----------------|--------------|
| Aggressive | 60px | 120px |
| Balanced | 80px | 100px |
| Defensive | 40px | 80px |

## Commit

`f22c223` - feat(16-04): implement party system with 3 companions
