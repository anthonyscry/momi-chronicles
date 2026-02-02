# End-to-End Difficulty System Verification Guide

This guide provides step-by-step instructions for manually verifying that the entire difficulty system works correctly from start to finish.

## Overview

The difficulty system consists of:
- **Core System**: DifficultyManager, DifficultySettings, Events
- **Save System**: SaveManager, GameManager integration
- **UI System**: TitleScreen, PauseMenu, DifficultySelection
- **Gameplay Integration**: EnemyDifficultyModifier component

## Automated Verification Scene

### Quick Start (Automated)

1. Open the project in Godot Editor:
   ```bash
   godot --path . --editor
   ```

2. Run the E2E verification scene:
   - Navigate to `tests/e2e_difficulty_verification.tscn`
   - Press F6 (or click "Run Current Scene")

3. Follow the on-screen instructions:
   - Press **1-5** to run each verification step
   - Press **R** to reset verification
   - Press **C** to clear save file
   - Press **ESC** to test pause menu

4. Check console output for detailed verification results

### Headless E2E (New)

Run the full UITester suite in headless mode:

```bash
godot --headless tests/e2e_full_suite.tscn
```

### What the Automated Scene Tests

- ✅ Difficulty selection and switching
- ✅ Difficulty multipliers (damage, drops, AI aggression)
- ✅ Save/Load persistence
- ✅ Enemy damage scaling
- ✅ Event signal propagation

---

## Manual End-to-End Verification

For a complete manual walkthrough of all difficulty features, follow these steps:

### Step 1: Title Screen Difficulty Selection

**Goal**: Verify title screen shows difficulty selection for new games

**Instructions**:
1. Open `ui/menus/title_screen.tscn` in Godot
2. Press F6 to run the scene
3. Click "New Game" button

**Expected Result**:
- ✅ Difficulty selection panel appears
- ✅ Three difficulty options are shown:
  - Story Mode (with description)
  - Normal (with description)
  - Challenge (with description)
- ✅ Each button is clickable
- ✅ ESC key closes difficulty selection

**Verification**:
- [ ] Difficulty selection UI displays correctly
- [ ] All three difficulty buttons are visible and functional
- [ ] Difficulty descriptions are clear and accurate

---

### Step 2: Select Story Mode and Verify

**Goal**: Verify selecting Story Mode sets difficulty correctly

**Instructions**:
1. Continue from Step 1 (on title screen)
2. Click "New Game" → Select "Story Mode"
3. Open console (F3 or View → Toggle Output)
4. Check console output

**Expected Result**:
```
Starting new game with difficulty: Story Mode
DifficultyManager: Difficulty set to 0 (Story Mode)
Events.difficulty_changed signal emitted
```

**Verification**:
- [ ] Console shows "Story Mode" as current difficulty
- [ ] DifficultyManager reports 0.5x damage multiplier
- [ ] DifficultyManager reports 2.0x drop multiplier
- [ ] DifficultyManager reports 0.7x AI aggression

**Console Commands** (for manual verification):
```gdscript
# In Godot console:
print(DifficultyManager.get_difficulty())  # Should be 0 (STORY)
print(DifficultyManager.get_damage_multiplier())  # Should be 0.5
print(DifficultyManager.get_drop_multiplier())  # Should be 2.0
```

---

### Step 3: Change to Challenge via Pause Menu

**Goal**: Verify difficulty can be changed mid-game without issues

**Instructions**:
1. While "in-game" (after selecting Story Mode)
2. Press **ESC** to open pause menu
3. Click "Change Difficulty"
4. Select "Challenge"
5. Check console output

**Expected Result**:
- ✅ Pause menu appears when ESC is pressed
- ✅ "Change Difficulty" button is visible
- ✅ Difficulty selection shows current difficulty (Story Mode)
- ✅ Selecting Challenge immediately updates difficulty
- ✅ Console shows: `Events.difficulty_changed signal emitted: Challenge`

**Verification**:
- [ ] Pause menu opens with ESC key
- [ ] Difficulty can be changed from pause menu
- [ ] Difficulty change is immediate (no restart required)
- [ ] Console confirms difficulty changed to Challenge
- [ ] Multipliers update: 1.5x damage, 0.5x drops, 1.3x AI aggression

**Console Commands**:
```gdscript
print(DifficultyManager.get_difficulty())  # Should be 2 (CHALLENGE)
print(DifficultyManager.get_damage_multiplier())  # Should be 1.5
```

---

### Step 4: Save, Quit, Reload - Verify Persistence

**Goal**: Verify difficulty setting persists across save/load

**Instructions**:
1. Ensure difficulty is set to **Challenge** (from Step 3)
2. Open pause menu (ESC) and click "Save Game" (or trigger save via code)
3. Verify save file created:
   - Check console for "Game saved successfully"
   - Or manually check for `user://save_data.json`
4. Quit to title screen
5. Click "Continue" to load saved game
6. Check console output for loaded difficulty

**Expected Result**:
```
SaveManager: Game saved successfully to user://save_data.json
[...later...]
SaveManager: Game loaded successfully from user://save_data.json
DifficultyManager: Difficulty set to 2 (Challenge)
```

**Verification**:
- [ ] Save file is created at `user://save_data.json`
- [ ] Loading game restores Challenge difficulty
- [ ] Difficulty multipliers are correct after load
- [ ] No errors or warnings in console

**Manual Save File Check**:
1. Find save file location:
   - Windows: `%APPDATA%\Godot\app_userdata\[YourProjectName]\save_data.json`
   - Linux: `~/.local/share/godot/app_userdata/[YourProjectName]/save_data.json`
   - macOS: `~/Library/Application Support/Godot/app_userdata/[YourProjectName]/save_data.json`
2. Open `save_data.json` in text editor
3. Verify it contains:
   ```ini
   [game]
   difficulty=2
   ```

**Console Commands**:
```gdscript
# Before save:
SaveManager.save_game()
print("Saved with difficulty: ", DifficultyManager.get_difficulty())

# Change difficulty temporarily:
DifficultyManager.set_difficulty(0)  # Change to Story Mode

# Reload:
SaveManager.load_game()
print("Loaded difficulty: ", DifficultyManager.get_difficulty())  # Should be 2 (CHALLENGE)
```

---

### Step 5: Spawn Enemy and Verify Damage Scaling

**Goal**: Verify enemies apply difficulty modifiers correctly

**Instructions**:
1. Ensure difficulty is set to **Challenge**
2. Open `tests/e2e_difficulty_verification.tscn` and run it (F6)
3. Press **5** to spawn a test enemy
4. Observe console output
5. Let the enemy attack (moves close to blue player placeholder)
6. Check damage values in console

**Expected Result**:
```
TestEnemy spawned with modifiers - Damage: 1.50x, Drops: 0.50x, AI: 1.30x
TestEnemy dealt 15.0 damage (base: 10.0, multiplier: 1.50x)
```

**Verification**:
- [ ] Enemy spawns with correct difficulty modifiers
- [ ] Base damage is 10.0
- [ ] Scaled damage is 15.0 (10.0 × 1.5x)
- [ ] Attack cooldown is reduced (faster attacks due to 1.3x AI aggression)
- [ ] Drop chance is reduced (0.5x multiplier)

**Alternative Test** (Manual enemy spawn):
1. Create a test scene
2. Instance `entities/enemies/test_enemy.tscn`
3. Add a player node to the "player" group
4. Run scene and observe console logs
5. Change difficulty via pause menu (ESC)
6. Observe enemy damage adjusts in real-time

**Difficulty Comparison Table**:

| Difficulty | Damage Multiplier | Base (10) → Scaled | Attack Speed | Drop Chance |
|------------|-------------------|-------------------|--------------|-------------|
| Story Mode | 0.5x             | 10 → 5            | Slower (0.7x)| Higher (2.0x)|
| Normal     | 1.0x             | 10 → 10           | Normal (1.0x)| Normal (1.0x)|
| Challenge  | 1.5x             | 10 → 15           | Faster (1.3x)| Lower (0.5x) |

---

## Complete E2E Flow Test

For the most comprehensive test, run through this entire sequence:

1. **Start Fresh**:
   - Delete save file (press C in verification scene)
   - Set difficulty to Normal

2. **New Game Flow**:
   - Run `title_screen.tscn`
   - Click "New Game"
   - Select "Story Mode"
   - Verify game starts with Story Mode

3. **Mid-Game Change**:
   - Press ESC to pause
   - Click "Change Difficulty"
   - Select "Challenge"
   - Verify difficulty updates immediately

4. **Save/Load Test**:
   - Save game (via SaveManager)
   - Change difficulty to Story Mode
   - Reload game
   - Verify difficulty restores to Challenge

5. **Enemy Interaction**:
   - Spawn test enemy
   - Verify damage is 15.0 (Challenge mode)
   - Change difficulty to Story Mode via pause
   - Verify next attack deals 5.0 damage
   - Change back to Challenge
   - Verify attack deals 15.0 again

6. **Persistence Test**:
   - Save game with Challenge difficulty
   - Quit Godot completely
   - Reopen project
   - Load save
   - Verify difficulty is still Challenge

---

## Automated Test Scene Features

The `e2e_difficulty_verification.tscn` scene provides:

### Keyboard Controls:
- **1**: Verify title screen (manual check)
- **2**: Verify Story Mode selection
- **3**: Verify Challenge mode change
- **4**: Verify save/load persistence
- **5**: Verify enemy damage scaling
- **R**: Reset verification
- **C**: Clear save file
- **ESC**: Open pause menu

### Visual Indicators:
- ☐ Uncompleted step (white)
- ✓ Completed step (green)
- Current difficulty displayed at bottom
- Test enemy spawns at position (500, 300)
- Player placeholder at position (400, 300)

### Console Logging:
All verification results are logged to console with detailed output including:
- Current difficulty level
- Multiplier values
- Expected vs actual values
- Pass/fail status for each step

---

## Troubleshooting

### Save File Not Found
**Problem**: "No save file found" error when loading

**Solutions**:
- Ensure you called `SaveManager.save_game()` before loading
- Check save file location (see Step 4)
- Verify file permissions for user data directory

### Difficulty Not Persisting
**Problem**: Loaded difficulty doesn't match saved difficulty

**Solutions**:
- Verify `save_data.json` contains `difficulty=X` entry
- Check SaveManager loads difficulty before other data (line 57-60)
- Ensure DifficultyManager is in autoload list

### Enemy Not Scaling Damage
**Problem**: Enemy deals same damage regardless of difficulty

**Solutions**:
- Verify enemy has `EnemyDifficultyModifier` child node
- Check enemy uses `difficulty_modifier.apply_damage()` method
- Ensure enemy is using `test_enemy.tscn` or similar structure
- Verify DifficultyManager autoload is initialized

### Pause Menu Not Opening
**Problem**: ESC key doesn't open pause menu

**Solutions**:
- Verify PauseMenu is registered as autoload in `project.godot`
- Check PauseMenu process_mode is set to PROCESS_MODE_ALWAYS (3)
- Ensure no other node is capturing input
- Verify "pause" action is mapped to ESC in Input Map

---

## Success Criteria

All verification steps should pass with the following outcomes:

✅ **Core System**:
- Three difficulty levels (Story, Normal, Challenge) are selectable
- Difficulty can be changed at any time
- Multipliers are applied correctly (damage, drops, AI aggression)

✅ **Save System**:
- Difficulty persists across save/load
- Save file contains correct difficulty value
- Loading restores all difficulty settings

✅ **UI System**:
- Title screen shows difficulty selection
- Pause menu allows difficulty changes
- Difficulty indicator shows current setting

✅ **Gameplay Integration**:
- Enemies apply difficulty modifiers
- Damage scales correctly (0.5x, 1.0x, 1.5x)
- Real-time updates when difficulty changes
- Drop rates and AI behavior adjust accordingly

---

## Acceptance Criteria Checklist

From the original spec, verify:

- [ ] At least 3 difficulty levels: Story Mode, Normal, Challenge
- [ ] Difficulty selectable at game start and changeable mid-game via pause menu
- [ ] Story Mode: enemy damage reduced 50%, health drops doubled
- [ ] Challenge Mode: enemy damage increased 50%, fewer drops, faster attack patterns
- [ ] Difficulty affects enemy behavior (aggression, combo frequency) not just number tuning
- [ ] No achievements or content locked behind difficulty level
- [ ] Clear description of what each difficulty changes shown in selection UI
- [ ] Difficulty setting persists across save/load cycles
- [ ] No crashes when switching difficulty with active enemies

---

## Next Steps After Verification

Once all steps pass:

1. ✅ Mark subtask-5-1 as complete in `implementation_plan.json`
2. ✅ Commit changes with descriptive message
3. ✅ Update `build-progress.txt` with verification results
4. ✅ Proceed to subtask-5-2 (optional additional test scene)

---

## Notes

- This verification guide covers the complete difficulty system
- All manual tests can be automated using the provided test scene
- Console output is critical for debugging - always check it
- Save file persistence is one of the most important features to verify
- Enemy damage scaling proves the entire system works end-to-end
