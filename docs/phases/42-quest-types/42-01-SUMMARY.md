---
phase: 42-quest-types
plan: 01
status: complete
subsystem: quest-system
affects: [42-02]
tech_stack:
  added: []
  used: [GDScript, Events signal bus, QuestManager autoload]
key_files:
  - autoloads/quest_manager.gd
  - systems/quest/quest_objective.gd
  - systems/quest/quest_data.gd
  - characters/npcs/dialogue_npc.gd
  - ui/quest/quest_tracker.gd
  - ui/quest/quest_log.gd
  - components/quest_item_pickup/quest_item_pickup.gd
  - world/zones/neighborhood.gd
patterns_established:
  - requires_prior_complete flag for sequential quest objectives
  - Data-driven NPC quest markers via quest_giver_id + npc_id
  - Quest item pickup component (Area2D + quest-gated visibility)
  - Reputation rewards in quest reward system
  - Progress counts in HUD tracker and quest log
decisions:
  - npc_id stable identifier on dialogue_npc separate from dialogue_id (which changes with Henderson's reputation)
  - quest_giver_id on QuestData matches npc_id for data-driven quest-NPC association
  - enemy_kill trigger uses "any" for all enemy types or specific script basename
  - Generic auto-start loop replaces hardcoded per-NPC quest start logic
---

## Summary

Extended the quest engine to support all 5 quest type patterns (fetch, elimination, delivery, interaction, chain) by adding new trigger types, sequential objective ordering, data-driven NPC markers, a reusable quest item pickup component, and progress display in HUD/journal.

## Changes

### quest_objective.gd
- Added `requires_prior_complete: bool = false` property
- Updated `_init()` to accept 7th parameter `p_requires_prior_complete`
- Updated `to_dict()` and `from_dict()` for serialization (backward compatible via `.get()` default)

### quest_data.gd
- Added `@export var quest_giver_id: String = ""` — stable NPC identifier for quest givers
- Added `@export var objective_requires_prior: Array[bool] = []` — per-objective sequential gating
- Updated `create_quest()` to pass `requires_prior` to QuestObjective constructor
- Updated trigger types comment to include "enemy_kill" and "item_collect"

### quest_manager.gd
- Connected `Events.enemy_defeated` and `Events.pickup_collected` signals in `_ready()`
- Added `_on_enemy_defeated_for_quests()` — extracts enemy type from script path
- Added `_on_pickup_collected_for_quests()` — forwards to item_collect checker
- Added `_check_enemy_kill_objectives()` — supports "any" and specific enemy types
- Added `_check_item_collect_objectives()` — matches item_id to trigger_id
- All 4 objective checkers now respect `requires_prior_complete` flag
- Replaced hardcoded quest auto-start (gertrude→meet_neighbors, maurice→community_watch) with generic `quest_giver_id` loop
- Added reputation rewards in `_grant_rewards()` — handles `{"reputation": {"npc_id": amount}}`
- Set `quest_giver_id` on existing quests: q1="gertrude", q2="maurice"

### dialogue_npc.gd
- Added `@export var npc_id: String = ""` — stable identifier separate from dialogue_id
- Removed hardcoded `npc_quest_map` dictionary
- "!" marker now uses data-driven `quest_giver_id` lookup across all available quests
- "?" marker now checks `requires_prior_complete` before showing (won't show if objective is blocked)
- Uses `lookup_id = npc_id if not npc_id.is_empty() else dialogue_id`

### neighborhood.gd
- Set `npc_id` on all 4 story NPCs: gertrude, maurice, kids_gang, henderson

### quest_tracker.gd
- Updated `_update_display()` to show progress counts: "Objective (3/5)" for multi-count objectives

### quest_log.gd
- Updated `_create_quest_entry()` to show progress counts: "[✓] Objective (3/5)" in objectives list

### NEW: components/quest_item_pickup/quest_item_pickup.gd
- Reusable Area2D-based collectible quest item
- Exports: item_id, quest_id, pickup_color, label_text
- Emits `Events.pickup_collected(item_id, 1)` on player collision
- Quest-gated visibility: hidden until associated quest is active, auto-hides on completion
- Visual: colored diamond with bob + rotation animation
- Collection animation: scale up + fade out → queue_free
- Does not use class_name (project convention)
