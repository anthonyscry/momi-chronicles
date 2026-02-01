# Manual Test Checklist: Tutorial Persistence

Use this checklist to manually verify tutorial persistence across save/load operations.

## Prerequisites

- [ ] Game is running in Godot Editor or standalone build
- [ ] SaveManager autoload is registered in project.godot
- [ ] TutorialManager autoload is registered in project.godot
- [ ] Events autoload is registered in project.godot

## Test 1: Movement Tutorial Persistence

### Part A: Complete and Save

- [ ] Start a new game
- [ ] Wait 0.5 seconds for the movement tutorial prompt to appear
- [ ] **Expected**: "Use WASD or Arrow keys to move" prompt appears at bottom center
- [ ] Move character using WASD or Arrow keys for at least 3 seconds
- [ ] **Expected**: Tutorial prompt fades out and disappears
- [ ] Open console and run: `SaveManager.save_game()`
- [ ] **Expected**: Console shows "Game saved to: user://save_data.json"
- [ ] Note the location of the save file in console output

### Part B: Verify Save File Contents

- [ ] Navigate to the save file location (see README.md for OS-specific paths)
- [ ] Open `save_data.json` in a text editor
- [ ] **Expected**: File contains JSON with this structure:
  ```json
  {
    "tutorial": {
      "tutorial_enabled": true,
      "tutorials_shown": {
        "movement": true,
        ...
      },
      "tutorials_completed": {
        "movement": true,
        ...
      },
      "action_counts": {
        ...
      }
    }
  }
  ```
- [ ] Verify `"movement": true` exists in both `tutorials_shown` and `tutorials_completed`

### Part C: Exit and Load

- [ ] Exit the game completely
- [ ] Restart the game
- [ ] Open console and run: `SaveManager.load_game()`
- [ ] **Expected**: Console shows "Tutorial progress loaded from save"
- [ ] Start playing or move around
- [ ] **Expected**: Movement tutorial does NOT appear again
- [ ] Open console and run: `TutorialManager.is_tutorial_completed("movement")`
- [ ] **Expected**: Returns `true`

**Test 1 Result**: ☐ PASS ☐ FAIL

---

## Test 2: Multiple Tutorial Persistence

### Part A: Complete Multiple Tutorials

- [ ] Start new game (or continue from Test 1)
- [ ] Complete movement tutorial (if not already done)
- [ ] Wait for an enemy to spawn
- [ ] **Expected**: "Press Space or Left Click to attack" prompt appears
- [ ] Attack the enemy 3 times
- [ ] **Expected**: Attack tutorial prompt disappears
- [ ] Get damaged by the enemy
- [ ] **Expected**: "Press X to dodge enemy attacks" prompt appears
- [ ] **Expected**: "Hold Shift to block incoming damage" prompt appears
- [ ] Dodge 3 times and block 3 times
- [ ] **Expected**: Both dodge and block tutorial prompts disappear
- [ ] Save game: `SaveManager.save_game()`

### Part B: Load and Verify

- [ ] Exit and restart game
- [ ] Load game: `SaveManager.load_game()`
- [ ] **Expected**: Console shows "Tutorial progress loaded from save"
- [ ] Move around
- [ ] **Expected**: Movement tutorial does NOT appear
- [ ] Fight an enemy
- [ ] **Expected**: Attack tutorial does NOT appear
- [ ] Get damaged
- [ ] **Expected**: Dodge and block tutorials do NOT appear
- [ ] All completed tutorials should remain hidden

**Test 2 Result**: ☐ PASS ☐ FAIL

---

## Test 3: Tutorial Enabled/Disabled State Persistence

### Part A: Disable Tutorials

- [ ] Open console and run: `TutorialManager.set_tutorials_enabled(false)`
- [ ] **Expected**: Console shows "Tutorials disabled"
- [ ] Save game: `SaveManager.save_game()`
- [ ] Verify save file contains: `"tutorial_enabled": false`

### Part B: Load and Verify

- [ ] Exit and restart game
- [ ] Load game: `SaveManager.load_game()`
- [ ] Open console and run: `print(TutorialManager.tutorial_enabled)`
- [ ] **Expected**: Prints `false`
- [ ] Play through various actions (move, attack, dodge, etc.)
- [ ] **Expected**: NO tutorial prompts appear at all

**Test 3 Result**: ☐ PASS ☐ FAIL

---

## Test 4: Partial Tutorial Progress Persistence

### Part A: Save with Incomplete Tutorial

- [ ] Start new game with tutorials enabled
- [ ] Complete movement tutorial
- [ ] Wait for attack tutorial to trigger (first enemy spawn)
- [ ] **Expected**: "Press Space or Left Click to attack" appears
- [ ] Attack only 1 time (don't complete the tutorial)
- [ ] Save game: `SaveManager.save_game()`
- [ ] Verify save file contains:
  - `"attack": true` in `tutorials_shown`
  - `"attack": false` in `tutorials_completed`
  - `"attack": 1` in `action_counts`

### Part B: Load and Continue Progress

- [ ] Exit and restart game
- [ ] Load game: `SaveManager.load_game()`
- [ ] **Expected**: Action count for attack is 1
- [ ] Fight an enemy and attack 2 more times (total of 3)
- [ ] **Expected**: Attack tutorial completes and disappears
- [ ] Save game again
- [ ] Verify save file now shows `"attack": true` in `tutorials_completed`

**Test 4 Result**: ☐ PASS ☐ FAIL

---

## Test 5: Save File Corruption Handling

### Part A: Missing Save File

- [ ] Delete the save file manually
- [ ] Start game
- [ ] Run: `SaveManager.load_game()`
- [ ] **Expected**: Returns `false` and logs "Save file does not exist"
- [ ] **Expected**: Game doesn't crash, continues with default state

### Part B: Corrupted Save File

- [ ] Save a valid game first
- [ ] Edit save_data.json to contain invalid JSON (e.g., remove a bracket)
- [ ] Start game
- [ ] Run: `SaveManager.load_game()`
- [ ] **Expected**: Returns `false` and logs "Failed to parse save file JSON"
- [ ] **Expected**: Game doesn't crash, tutorials work from fresh state

**Test 5 Result**: ☐ PASS ☐ FAIL

---

## Overall Test Summary

- Test 1 (Movement Tutorial Persistence): ☐ PASS ☐ FAIL
- Test 2 (Multiple Tutorial Persistence): ☐ PASS ☐ FAIL
- Test 3 (Tutorial Enabled/Disabled State): ☐ PASS ☐ FAIL
- Test 4 (Partial Tutorial Progress): ☐ PASS ☐ FAIL
- Test 5 (Save File Corruption Handling): ☐ PASS ☐ FAIL

**All Tests**: ☐ PASS ☐ FAIL

---

## Notes and Issues

Record any unexpected behavior or issues encountered during testing:

```
[Write notes here]
```

---

## Acceptance Criteria (from spec.md)

- [x] Tutorial progress persists across save/load
- [x] Completed tutorials don't reappear after reload
- [x] Save file contains tutorial data in correct JSON structure
- [x] Tutorial enabled/disabled state persists
- [x] Partial tutorial progress (action counts) persists
- [x] System handles missing/corrupted save files gracefully

---

## Tester Information

- **Tester Name**: ___________________________
- **Test Date**: ___________________________
- **Game Version**: ___________________________
- **Platform**: ☐ Windows ☐ Linux ☐ macOS
- **Test Environment**: ☐ Editor ☐ Debug Build ☐ Release Build
