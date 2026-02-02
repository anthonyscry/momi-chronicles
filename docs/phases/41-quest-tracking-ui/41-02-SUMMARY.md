# 41-02 Summary: Quest UI Integration

## What Was Done

**Task 1: HUD tracker + Ring Menu quest log + reward notification**
- Added QuestTracker (.tscn) instantiation to GameHUD via `_setup_quest_tracker()` — top-right corner, auto-anchored
- Added quest reward notification popup: gold Label centered on screen with slide-up + fade animation
- Connected `Events.quest_completed` → `_on_quest_completed_reward()` for reward text display
- Added "Quest Log" as first option in ring menu OPTIONS ring
- Added `_open_quest_log()` / `_close_quest_log()` methods to ring_menu.gd — dark background CanvasLayer with quest_log.tscn
- Wired ESC/dodge/ring_menu input to close quest log overlay
- Fixed QuestTracker safety: added `/root/QuestManager` check, added `ring_menu_closed` re-show handler
- Fixed bare `print()` calls in ring_menu.gd `_handle_option()` → `DebugLogger.log_ui()`

**Task 2: NPC quest marker icons**
- Added `quest_marker` Label to `dialogue_npc.gd` — "!" (yellow) for available quests, "?" (gray) for in-progress objectives
- Created `_create_quest_marker()` — Label with outline, z_index 5, above NPC head at y=-34
- Created `_update_quest_marker()` with NPC→quest mapping:
  - Checks `QuestManager.active_quests` for dialogue objectives matching `dialogue_id` → shows "?"
  - Checks `npc_quest_map` (gertrude→meet_neighbors, maurice→community_watch) for available quests → shows "!"
  - Exclamation takes priority over question mark
- Wired to `Events.quest_started`, `quest_updated`, `quest_completed` for real-time updates
- Added quest marker refresh in `_on_dialogue_ended()` (quest may have started/progressed)
- Added subtle bob animation for quest marker (sin wave at 3x speed, ±1.5px)

## Files Modified

| File | Change |
|------|--------|
| `ui/hud/game_hud.gd` | QuestTracker setup, reward popup, quest_completed handler |
| `ui/ring_menu/ring_menu.gd` | Quest Log option, overlay open/close, ESC handling, print→DebugLogger |
| `ui/quest/quest_tracker.gd` | Safety check, ring_menu_closed re-show |
| `characters/npcs/dialogue_npc.gd` | Quest marker Label, update logic, event wiring, bob animation |

## Key Decisions

- Quest log uses CanvasLayer at layer 100 with dark semi-transparent background (matches game's overlay pattern)
- Reward popup uses simple Label with tween animation (not a separate scene) — lightweight, consistent with save indicator pattern
- NPC quest markers use hardcoded npc_quest_map Dictionary (gertrude→meet_neighbors, maurice→community_watch) — simple and correct for current quest count, can be generalized in Phase 42
- Quest tracker re-shows after ring menu closes only if a quest is active — prevents stale UI

## Artifacts

- QuestTracker visible on HUD during active quests (top-right)
- Quest Log accessible from ring menu Options → "Quest Log"
- NPC quest markers: "!" yellow for quest givers, "?" gray for objective targets
- Reward notification popup on quest completion
