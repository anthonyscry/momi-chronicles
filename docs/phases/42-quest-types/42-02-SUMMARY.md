---
phase: 42-quest-types
plan: 02
status: complete
subsystem: quest-system
affects: []
tech_stack:
  added: []
  used: [GDScript, QuestData, QuestItemPickupScript]
key_files:
  - autoloads/quest_manager.gd
  - world/zones/backyard.gd
  - world/zones/neighborhood.gd
patterns_established:
  - Quest content defined programmatically in _register_all_quests (code, not .tres)
  - Quest item pickups placed in zone _setup_zone via _build_quest_pickups helper
  - Chain quests use prerequisite_quest_ids for sequential unlock
  - Henderson reputation gate (>= 30) as runtime check in auto-start loop
decisions:
  - All enemy kills count for elimination quests (trigger_id = "any")
  - Chain quests 1-4 are main quests (is_main_quest = true)
  - Lost ball at backyard (300, 80), mail package near Maurice (420, 310)
---

## Summary

Defined 7 new quests covering all 5 quest type patterns (Fetch, Elimination, Delivery, 4-part Chain) and placed 2 quest item pickups in zones, bringing the total quest count to 9.

## Changes

### quest_manager.gd — 7 New Quest Definitions
Added quests q3-q9 in `_register_all_quests()`:

| Quest | ID | Type | Quest Giver | Prerequisites | Objectives |
|-------|-----|------|-------------|---------------|------------|
| q3 | find_lost_ball | Fetch | kids_gang | meet_neighbors | item_collect(lost_ball) → dialogue(kids_gang) |
| q4 | pest_control | Elimination | henderson | meet_neighbors + rep≥30 | enemy_kill(any, 5) → dialogue(henderson) |
| q5 | special_delivery | Delivery | maurice | community_watch | item_collect(mail_package) → dialogue(gertrude) |
| q6 | investigation_1 | Chain 1/4 | gertrude | meet_neighbors | zone(backyard) → dialogue(gertrude) |
| q7 | investigation_2 | Chain 2/4 | gertrude | investigation_1 | enemy_kill(any, 3) → dialogue(gertrude) |
| q8 | investigation_3 | Chain 3/4 | gertrude | investigation_2 | zone(sewers) → dialogue(gertrude) |
| q9 | investigation_4 | Chain 4/4 | gertrude | investigation_3 | dialogue(maurice,kids_gang,henderson) → dialogue(gertrude) |

All new quests use `objective_requires_prior` for return-to-NPC sequential gating.

### quest_manager.gd — Henderson Reputation Gate
Added reputation check (≥ 30) inside the generic auto-start loop for Henderson quests. Prevents starting pest_control before player has built up Henderson's trust.

### backyard.gd — Lost Ball Pickup
- Added `QuestItemPickupScript` preload
- Added `_build_quest_pickups()` call in `_setup_zone()`
- Created red ball pickup at (300, 80), quest-gated to "find_lost_ball"

### neighborhood.gd — Mail Package Pickup
- Added `QuestItemPickupScript` preload
- Added `_build_quest_pickups()` call in `_setup_zone()`
- Created purple package pickup at (420, 310) near Maurice, quest-gated to "special_delivery"

## Quest Reward Summary

| Quest | Coins | EXP | Reputation |
|-------|-------|-----|------------|
| find_lost_ball | 60 | 30 | kids_gang +15 |
| pest_control | 100 | 50 | henderson +20 |
| special_delivery | 75 | 35 | maurice +15, gertrude +10 |
| investigation_1 | 40 | 20 | gertrude +10 |
| investigation_2 | 60 | 30 | gertrude +10 |
| investigation_3 | 80 | 40 | gertrude +10 |
| investigation_4 | 150 | 75 | gertrude +20, maurice +10, kids_gang +10, henderson +10 |
| **Total new** | **565** | **280** | Multiple NPCs |
