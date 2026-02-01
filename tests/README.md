# Tutorial Persistence Tests

This directory contains tests for verifying tutorial progress persistence across save/load operations.

## Test Files

- `test_tutorial_persistence.gd` - Test script with automated test cases
- `test_tutorial_persistence.tscn` - Test scene that runs the test script

## Running the Tests

### Method 1: Using Godot Editor

1. Open the project in Godot Editor
2. Navigate to the `tests` folder in the FileSystem dock
3. Double-click `test_tutorial_persistence.tscn` to open the scene
4. Press F6 (or click "Run Current Scene")
5. Check the Output panel for test results

### Method 2: Command Line (Headless)

```bash
godot --headless --script tests/test_tutorial_persistence.gd
```

### Method 3: Run Scene from Command Line

```bash
godot tests/test_tutorial_persistence.tscn
```

## Manual Verification Steps

For comprehensive manual testing of tutorial persistence:

### Step 1: Complete Movement Tutorial

1. Start a new game
2. Wait for the movement tutorial prompt to appear
3. Move using WASD or Arrow keys for at least 3 seconds
4. Verify the tutorial prompt disappears
5. Open the pause menu (if available) or wait a moment
6. Save the game using SaveManager.save_game()

### Step 2: Exit and Check Save File

1. Exit the game
2. Navigate to the save file location:
   - **Windows**: `%APPDATA%\Godot\app_userdata\[project_name]\save_data.json`
   - **Linux**: `~/.local/share/godot/app_userdata/[project_name]/save_data.json`
   - **macOS**: `~/Library/Application Support/Godot/app_userdata/[project_name]/save_data.json`
3. Open `save_data.json` in a text editor
4. Verify the file contains:
   ```json
   {
     "tutorial": {
       "tutorial_enabled": true,
       "tutorials_shown": {
         "movement": true
       },
       "tutorials_completed": {
         "movement": true
       },
       "action_counts": {}
     }
   }
   ```

### Step 3: Load Save and Verify

1. Start the game again
2. Load the saved game using SaveManager.load_game()
3. Move around - verify the movement tutorial does NOT appear again
4. Check the console/debug output for "Tutorial progress loaded from save"
5. Verify TutorialManager.is_tutorial_completed("movement") returns true

### Step 4: Test with Multiple Tutorials

1. Continue playing until other tutorials trigger (attack, dodge, combo, etc.)
2. Complete 2-3 tutorials
3. Save the game
4. Exit and reload
5. Verify none of the completed tutorials appear again
6. Verify incomplete tutorials still trigger when appropriate

## Expected Test Results

When running the automated tests, you should see:

```
========================================
TUTORIAL PERSISTENCE TEST
========================================

TEST: Save tutorial progress
  ✓ Save file created successfully

TEST: Load tutorial progress
  ✓ Tutorial progress loaded successfully

TEST: Save file structure
  ✓ Save file structure is correct
  ✓ Tutorial data properly serialized to JSON

TEST: Tutorial state persistence across multiple cycles
  ✓ Tutorial state persists correctly across multiple save/load cycles

========================================
TEST RESULTS
========================================

✓ PASS: Save file should exist after saving
✓ PASS: Movement tutorial should be completed after load
✓ PASS: Combo tutorial should be shown after load
✓ PASS: Combo action count should be 1 after load
✓ PASS: Save file should contain 'tutorial' key
✓ PASS: Tutorial data should have 'tutorial_enabled'
✓ PASS: Tutorial data should have 'tutorials_shown'
✓ PASS: Tutorial data should have 'tutorials_completed'
✓ PASS: Tutorial data should have 'action_counts'
✓ PASS: Tutorials should be enabled
✓ PASS: Movement tutorial should be marked completed in save file
✓ PASS: Attack tutorial should be marked completed in save file
✓ PASS: Movement tutorial should persist after cycle 1
✓ PASS: Movement tutorial should still be completed after cycle 2
✓ PASS: Attack tutorial should be completed after cycle 2
✓ PASS: Tutorial enabled state should persist (disabled)

========================================
SUMMARY
========================================
Passed: 16
Failed: 0
Total:  16

✓ ALL TESTS PASSED
========================================
```

## Troubleshooting

### Save file not found

- Ensure SaveManager.save_game() is called
- Check the correct user data directory for your OS
- Verify file permissions for the user data directory

### Tutorials still appear after load

- Verify TutorialManager.load_save_data() is called after loading
- Check that the save file contains the correct tutorial data
- Ensure tutorials_completed dictionary has the tutorial IDs set to true

### Test script errors

- Make sure all autoloads (TutorialManager, SaveManager, Events) are registered in project.godot
- Verify the project is opened from the correct directory
- Check the Output panel for specific error messages
