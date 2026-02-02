# 41-01 Summary: Quest Backend Wiring

## What Was Done

**Task 1: Fix bugs and extend quest data model**
- Fixed `Events.quest_updated` signal signature from 1 param to 2 params (`quest_id`, `objective_index`) — prevents crash when QuestManager emits with 2 args
- Replaced all 5 bare `print()` calls in `quest_manager.gd` with `DebugLogger.log_system()` — convention compliance
- Extended `QuestObjective` with trigger metadata: `trigger_type`, `trigger_id`, `target_count`, `current_count`
- Added `advance()` method to QuestObjective for counter-based objective progression
- Updated `QuestObjective.to_dict()` and `from_dict()` for trigger field serialization (backward compatible via `.get()`)
- Added `objective_trigger_types`, `objective_trigger_ids`, `objective_target_counts` arrays to `QuestData`
- Updated `QuestData.create_quest()` to pass trigger data through to QuestObjective constructor

**Task 2: Wire quest system into game loop with sample quests**
- Added `_register_all_quests()` in QuestManager._ready() with 2 sample quests:
  - **"Meet the Neighbors"** — talk to Maurice, Kids Gang, Henderson (50 coins, 25 EXP)
  - **"Community Watch"** — visit Backyard and Sewers (75 coins, 30 EXP; requires meet_neighbors)
- Wired `Events.dialogue_started` → `_on_dialogue_started_for_quests()` for auto-start and dialogue objective completion
- Wired `Events.zone_entered` → `_on_zone_entered_for_quests()` for zone objective completion
- Added `_check_dialogue_objectives()` and `_check_zone_objectives()` helpers
- Wired SaveManager: `_gather_save_data()` calls `QuestManager.get_save_data()`, `_apply_save_data()` calls `QuestManager.load_save_data()`
- Wired GameManager.reset_game() to clear all quest state (active_quests, completed_quest_ids, failed_quest_ids, current_active_quest_id)

## Files Modified

| File | Change |
|------|--------|
| `autoloads/events.gd` | Fixed quest_updated signal to 2 params |
| `autoloads/quest_manager.gd` | print→DebugLogger, _register_all_quests, event handlers, objective checkers |
| `systems/quest/quest_objective.gd` | trigger_type/id/count fields, advance(), updated serialization |
| `systems/quest/quest_data.gd` | trigger arrays, updated create_quest() |
| `autoloads/save_manager.gd` | Quest save/load wiring |
| `autoloads/game_manager.gd` | Quest reset in reset_game() |

## Key Decisions

- Used programmatic quest definitions (code, not .tres files) — matches ItemDatabase/EquipmentDatabase pattern
- Quest auto-start mapped to NPC dialogue_id (Gertrude→meet_neighbors, Maurice→community_watch)
- Dialogue objective matching uses DialogueManager._dialogues reverse lookup to get dialogue_id from DialogueResource
- Quest completion checking iterates active_quests.keys() — safe for dictionary mutation since complete_quest is called after loop

## Artifacts

- 2 sample quests registered on startup
- Event-driven objective completion (dialogue + zone triggers)
- Full save/load persistence for quest state
- New game reset clears all quest progress
