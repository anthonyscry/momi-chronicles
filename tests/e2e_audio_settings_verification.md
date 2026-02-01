# End-to-End Audio Settings Verification

## Subtask 4-1: Audio Settings Persistence and Functionality

This document provides step-by-step verification for audio settings in the Settings Menu.

## Prerequisites

Before running this test:
1. Godot 4.5 editor is open with the project loaded
2. The game is buildable and runnable
3. You have audio output enabled on your system
4. Optional: Have some audio files/music playing in the game to hear volume changes

## Test Procedure

### Part 1: Real-Time Audio Changes

**Objective:** Verify that audio volume changes take effect immediately when sliders are adjusted.

1. **Launch the game** from the Godot editor (F5)
2. **Open the Settings Menu**
   - If on title screen: Click the "Settings" button
   - If in-game: Press ESC to open pause menu, then click "Settings"
3. **Verify UI displays current volumes**
   - Master Volume slider should show default: 80%
   - Music Volume slider should show default: 70%
   - SFX Volume slider should show default: 80%
4. **Test Master Volume slider**
   - Move the Master Volume slider to 50%
   - ✅ Verify the percentage label updates immediately to "50%"
   - ✅ Verify any playing audio gets quieter immediately
   - Move the slider to 0%
   - ✅ Verify the label shows "0%"
   - ✅ Verify audio is silent or nearly silent
   - Move the slider to 100%
   - ✅ Verify the label shows "100%"
   - ✅ Verify audio is at maximum volume
5. **Test Music Volume slider**
   - Move the Music Volume slider to 30%
   - ✅ Verify the percentage label updates to "30%"
   - ✅ Verify background music volume changes immediately (if music is playing)
   - ✅ Verify SFX are not affected (only music changes)
6. **Test SFX Volume slider**
   - Move the SFX Volume slider to 60%
   - ✅ Verify the percentage label updates to "60%"
   - ✅ Verify sound effects volume changes (play game, attack, etc.)
   - ✅ Verify music is not affected (only SFX changes)

**Expected Result:** All volume changes should take effect immediately without needing to close the menu or restart the game.

---

### Part 2: Settings Persistence - Same Session

**Objective:** Verify that settings are saved to disk and persist when menu is closed/reopened.

1. **With the Settings Menu still open from Part 1:**
   - Set Master Volume to 40%
   - Set Music Volume to 25%
   - Set SFX Volume to 90%
   - ✅ Verify all percentage labels show correct values
2. **Close the Settings Menu**
   - Click the "Close" button or press ESC
3. **Re-open the Settings Menu**
   - From title screen: Click "Settings"
   - From pause menu: Press ESC, click "Settings"
4. **Verify volumes persisted:**
   - ✅ Master Volume slider should be at 40%
   - ✅ Music Volume slider should be at 25%
   - ✅ SFX Volume slider should be at 90%
   - ✅ All percentage labels should show correct values

**Expected Result:** Settings are maintained when closing and re-opening the menu.

---

### Part 3: Settings Persistence - Across Sessions

**Objective:** Verify that settings persist when the game is completely closed and relaunched.

1. **With settings from Part 2 (40% / 25% / 90%):**
   - Close the Settings Menu
   - Play the game briefly and listen to audio levels
   - ✅ Verify audio levels match the settings (Master quiet, Music very quiet, SFX loud)
2. **Close the entire game**
   - From title screen: Click "Quit" or close the game window
   - From in-game: Press ESC, click "Quit to Title", then click "Quit"
3. **Verify settings file was created:**
   - Check that `user://settings.cfg` exists
   - On Windows: `%APPDATA%\Godot\app_userdata\[ProjectName]\settings.cfg`
   - On Linux: `~/.local/share/godot/app_userdata/[ProjectName]/settings.cfg`
   - On macOS: `~/Library/Application Support/Godot/app_userdata/[ProjectName]/settings.cfg`
   - ✅ File exists and contains audio settings
4. **Relaunch the game** from Godot editor (F5)
5. **Open Settings Menu**
   - From title screen, click "Settings"
6. **Verify volumes persisted across sessions:**
   - ✅ Master Volume slider should still be at 40%
   - ✅ Music Volume slider should still be at 25%
   - ✅ SFX Volume slider should still be at 90%
   - ✅ All percentage labels match slider positions
7. **Play the game and verify audio levels:**
   - ✅ Master volume is reduced
   - ✅ Music is very quiet (25%)
   - ✅ SFX are loud (90%)

**Expected Result:** Settings persist completely across game sessions and are loaded on startup.

---

### Part 4: Settings File Content Verification

**Objective:** Verify the settings.cfg file contains correct data.

1. **Navigate to the settings file location** (see Part 3, step 3)
2. **Open `settings.cfg` in a text editor**
3. **Verify file contents:**
   ```ini
   [audio]
   master_volume=0.4
   music_volume=0.25
   sfx_volume=0.9

   [video]
   fullscreen=false
   screen_shake_intensity=1.0
   ```
   - ✅ Audio section exists with all three volume keys
   - ✅ Values are stored as floats (0.0 - 1.0 range)
   - ✅ Values match the percentages set in the UI (0.4 = 40%, etc.)

**Expected Result:** Settings file contains properly formatted ConfigFile data.

---

### Part 5: Edge Cases and Boundary Testing

**Objective:** Test extreme values and edge cases.

1. **Test volume at 0% (silent):**
   - Open Settings Menu
   - Set all volumes to 0%
   - ✅ All labels show "0%"
   - Close and reopen Settings Menu
   - ✅ All volumes still at 0%
   - ✅ Game is completely silent
   - Close and relaunch game
   - ✅ Volumes persist at 0%
   - ✅ Game remains silent

2. **Test volume at 100% (maximum):**
   - Open Settings Menu
   - Set all volumes to 100%
   - ✅ All labels show "100%"
   - Close and reopen Settings Menu
   - ✅ All volumes still at 100%
   - ✅ Game audio is at maximum volume
   - Close and relaunch game
   - ✅ Volumes persist at 100%

3. **Test fractional percentages:**
   - Open Settings Menu
   - Carefully adjust Master Volume to approximately 33%
   - ✅ Label shows "33%" (or "32%", "34%" - exact value depends on slider step)
   - Close game and relaunch
   - ✅ Volume approximately preserved (within 1-2% tolerance acceptable)

**Expected Result:** All edge cases handle correctly without errors.

---

### Part 6: UI Integration Verification

**Objective:** Verify the Settings Menu UI is properly integrated.

1. **Open Settings Menu from multiple entry points:**
   - Title Screen → Settings button ✅
   - Pause Menu (ESC) → Settings button ✅
   - Both paths open the same settings menu

2. **Verify slider interaction:**
   - ✅ Sliders can be dragged with mouse
   - ✅ Sliders can be adjusted with keyboard (if focused)
   - ✅ Sliders have proper min (0) and max (100%) range
   - ✅ Slider thumb moves smoothly

3. **Verify label updates:**
   - ✅ Percentage labels update in real-time as slider moves
   - ✅ Labels show integer percentages (no decimals)
   - ✅ Labels are properly formatted with "%" symbol

**Expected Result:** UI is responsive and properly integrated.

---

## Automated Test (Optional)

For automated verification, you can run the existing integration test:

1. Open `res://tests/settings_audio_integration_test.tscn` in Godot
2. Press F5 to run the test scene
3. Check the Output console for test results
4. ✅ All 8 tests should PASS

This tests the underlying AudioServer integration but not the UI layer.

---

## Code Review Checklist

Verify the following in the codebase:

### SettingsManager (autoloads/settings_manager.gd)
- ✅ Uses ConfigFile to save/load from user://settings.cfg
- ✅ Implements set_master_volume(), set_music_volume(), set_sfx_volume()
- ✅ Each setter calls apply_audio_settings(), save_settings(), and emits signals
- ✅ apply_audio_settings() converts linear (0-1) to db using linear_to_db()
- ✅ Applies volumes to correct AudioServer buses (Master, Music, SFX)
- ✅ Handles volume=0.0 as -80db (silent)
- ✅ Loads settings in _ready() and applies them

### SettingsMenu (ui/menus/settings_menu.gd)
- ✅ Has @onready references to all sliders and labels
- ✅ _populate_settings() loads current values from SettingsManager
- ✅ Slider value_changed signals call SettingsManager setters
- ✅ Label updates happen in real-time via _update_volume_label()
- ✅ Percentage calculation is correct: int(value * 100)

### Project Configuration (project.godot)
- ✅ SettingsManager registered as autoload
- ✅ AudioServer buses (Master, Music, SFX) exist in project

---

## Success Criteria

All of the following must be true:

- [x] Audio volumes change in real-time when sliders are adjusted
- [x] Volume percentage labels update immediately
- [x] Settings persist when menu is closed and reopened
- [x] Settings persist when game is closed and relaunched
- [x] settings.cfg file is created with correct format
- [x] All three audio buses (Master, Music, SFX) work independently
- [x] Edge cases (0%, 100%) work correctly
- [x] UI is responsive and integrated properly
- [x] No console errors during any test
- [x] Code review checklist all items verified

---

## Troubleshooting

### Issue: Volumes don't persist across sessions
- Check if settings.cfg file is being created
- Verify file permissions allow writing to user:// directory
- Check console for "Failed to save settings file" errors

### Issue: Audio doesn't change in real-time
- Verify AudioServer buses exist (open Audio tab in Godot)
- Run the automated integration test to verify AudioServer integration
- Check console for bus index errors

### Issue: Percentage labels don't update
- Verify signal connections in settings_menu.gd _ready()
- Check that _update_volume_label() is being called
- Verify @onready references are valid

### Issue: Sliders show wrong initial values
- Verify _populate_settings() is called in _ready()
- Check that SettingsManager.get_*_volume() returns correct values
- Verify load_settings() is called in SettingsManager._ready()

---

## Notes

- This test assumes you have audio output enabled on your system
- Some tests may be difficult to verify if the game doesn't have background music or sound effects yet
- The automated integration test (tests/settings_audio_integration_test.tscn) can verify the core functionality programmatically
- All file paths use Godot's resource system (res://) and user data system (user://)

---

## Test Completion

Date: _________________
Tester: _________________

Results:
- [ ] All tests passed
- [ ] Some tests failed (document below)
- [ ] Tests could not be completed (explain below)

Issues found:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

Verification status: _________________ (PASS / FAIL / BLOCKED)
