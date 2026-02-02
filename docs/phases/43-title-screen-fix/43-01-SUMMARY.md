---
phase: 43-title-screen-fix
plan: 01
status: complete
affects: []
subsystem: ui/menus
tech_stack:
  added: []
key_files:
  - ui/menus/title_screen.gd
decisions:
  - "New Game loads neighborhood zone directly via change_scene_to_file"
---

# Phase 43, Plan 01 — Title Screen Fix

## What Was Done

**Task 1: Fix New Game to load neighborhood zone**
- Replaced `_show_game_start_placeholder()` call (line 96) with `get_tree().change_scene_to_file("res://world/zones/neighborhood.tscn")`
- Deleted the entire `_show_game_start_placeholder()` function (35 lines of dead code: placeholder Label, CenterContainer, disconnected input handler lambda)
- File reduced from 167 lines to 133 lines

**Task 2: Verify all title screen paths**
- **New Game**: `_on_new_game_pressed()` → difficulty selection → `_on_difficulty_selected()` → `DifficultyManager.set_difficulty()` → `GameManager.reset_game()` → `change_scene_to_file(neighborhood)` ✅
- **Continue**: `SaveManager.load_game()` → `_apply_save_data()` → restores all state → `GameManager.load_zone(target_zone)` → zone loads ✅
- **Quit**: `get_tree().quit()` ✅
- **Pause round-trip**: pause menu `_on_quit_pressed()` → `GameManager.reset_game()` → `change_scene_to_file(title_screen)` → title screen loads clean ✅

## Key Change

```gdscript
# BEFORE (broken — showed placeholder text)
_show_game_start_placeholder()

# AFTER (working — loads the game)
get_tree().change_scene_to_file("res://world/zones/neighborhood.tscn")
```

## Files Modified

| File | Change |
|------|--------|
| `ui/menus/title_screen.gd` | Replaced placeholder with scene transition, removed 35 lines dead code |
