# Video Settings End-to-End Verification

## Overview
This document provides comprehensive verification steps for video settings persistence and functionality in the Settings Menu feature.

## Test Sections

### 1. Fullscreen Toggle - Real-time Changes
**Objective:** Verify fullscreen toggle changes window mode immediately

**Steps:**
1. Launch game (title screen should appear in windowed mode by default)
2. Click Settings button
3. In Video section, verify Fullscreen checkbox is unchecked
4. Click the Fullscreen checkbox
5. Observe window behavior

**Expected Results:**
- [ ] Window immediately switches to fullscreen mode
- [ ] No game restart required
- [ ] Settings menu remains visible and functional in fullscreen

**Implementation Details:**
- `SettingsManager.set_fullscreen()` is called on checkbox toggle
- `apply_video_settings()` executes `DisplayServer.window_set_mode()`
- Uses `WINDOW_MODE_FULLSCREEN` or `WINDOW_MODE_WINDOWED`

**Code Path:**
```
settings_menu.gd:_on_fullscreen_toggled()
  → SettingsManager.set_fullscreen()
    → apply_video_settings()
      → DisplayServer.window_set_mode()
    → save_settings()
```

---

### 2. Fullscreen Toggle - Same Session Persistence
**Objective:** Verify fullscreen setting persists within same game session

**Steps:**
1. With fullscreen enabled, close settings menu (ESC or Close button)
2. Return to title screen (if in game, use Quit to Title)
3. Open settings menu again
4. Check Fullscreen checkbox state

**Expected Results:**
- [ ] Fullscreen checkbox remains checked
- [ ] Window remains in fullscreen mode
- [ ] Setting not lost when closing/reopening settings menu

---

### 3. Fullscreen Toggle - Cross-Session Persistence
**Objective:** Verify fullscreen setting persists across game launches

**Steps:**
1. Enable fullscreen in settings
2. Close settings menu
3. Quit game completely (`Quit` button or close window)
4. Relaunch game
5. Observe initial window state
6. Open settings menu
7. Check Fullscreen checkbox state

**Expected Results:**
- [ ] Game launches in fullscreen mode
- [ ] Fullscreen checkbox is checked when opening settings
- [ ] Setting loaded from `user://settings.cfg`

**Implementation Details:**
- `SettingsManager._ready()` calls `load_settings()`
- ConfigFile loads `video.fullscreen` from `user://settings.cfg`
- `apply_all_settings()` applies the loaded fullscreen state
- Default value is `false` if no saved settings exist

---

### 4. Screen Shake Intensity - Real-time Label Updates
**Objective:** Verify screen shake slider updates label correctly

**Steps:**
1. Open settings menu
2. Locate Screen Shake slider in Video section
3. Move slider to minimum (left)
4. Observe label value
5. Move slider to ~25% position
6. Observe label value
7. Move slider to ~50% position
8. Observe label value
9. Move slider to maximum (right)
10. Observe label value

**Expected Results:**
- [ ] Slider at 0.0: Label shows "Off"
- [ ] Slider at ~0.33: Label shows "Low"
- [ ] Slider at ~0.5-0.65: Label shows "Medium"
- [ ] Slider at 1.0: Label shows "High"
- [ ] Label updates in real-time as slider moves

**Implementation Details:**
- Slider value range: 0.0 to 1.0
- Label thresholds:
  - `value <= 0.0` → "Off"
  - `value <= 0.35` → "Low"
  - `value <= 0.65` → "Medium"
  - `value > 0.65` → "High"

**Code Path:**
```
settings_menu.gd:_on_screen_shake_changed(value)
  → _update_screen_shake_label(value)
    → screen_shake_value_label.text = [Off/Low/Medium/High]
  → SettingsManager.set_screen_shake_intensity(value)
```

---

### 5. Screen Shake Intensity - Persistence
**Objective:** Verify screen shake intensity persists across sessions

**Steps:**
1. Open settings menu
2. Set screen shake to "Low" (slider ~25%)
3. Close settings menu
4. Quit game completely
5. Relaunch game
6. Open settings menu
7. Check screen shake slider position and label

**Expected Results:**
- [ ] Slider position matches saved value
- [ ] Label shows "Low"
- [ ] Value loaded from `user://settings.cfg`

**Implementation Details:**
- Saved to ConfigFile as `video.screen_shake_intensity`
- Value range: 0.0 to 1.0
- Default value: 1.0 (full intensity)

---

### 6. Screen Shake Integration Readiness
**Objective:** Verify screen shake setting is accessible for future EffectsManager integration

**Steps:**
1. Review `SettingsManager` API
2. Verify getter method exists
3. Check signal emissions
4. Verify value clamping

**Expected Results:**
- [ ] `SettingsManager.get_screen_shake_intensity()` returns float 0.0-1.0
- [ ] `video_settings_changed` signal emitted on changes
- [ ] Value clamped to 0.0-1.0 range in setter
- [ ] EffectsManager can query current intensity at any time

**Implementation Details:**
```gdscript
# Future EffectsManager integration:
func apply_screen_shake(base_intensity: float) -> void:
    var user_preference = SettingsManager.get_screen_shake_intensity()
    var final_intensity = base_intensity * user_preference
    # Apply shake with final_intensity
```

**Code Analysis:**
- `set_screen_shake_intensity()` includes `clampf(value, 0.0, 1.0)`
- `get_screen_shake_intensity()` returns current value
- Setting saved immediately on change
- Signal emitted for listeners

---

### 7. Settings File Format Verification
**Objective:** Verify video settings are correctly stored in ConfigFile

**Steps:**
1. Set fullscreen to ON
2. Set screen shake to "Medium" (~0.5)
3. Close game
4. Navigate to settings file location:
   - Windows: `%APPDATA%\Godot\app_userdata\Momi's Adventure\settings.cfg`
   - Linux: `~/.local/share/godot/app_userdata/Momi's Adventure/settings.cfg`
   - macOS: `~/Library/Application Support/Godot/app_userdata/Momi's Adventure/settings.cfg`
5. Open `settings.cfg` in text editor
6. Verify contents

**Expected File Format:**
```ini
[audio]
master_volume=0.8
music_volume=0.7
sfx_volume=0.8

[video]
fullscreen=true
screen_shake_intensity=0.5
```

**Expected Results:**
- [ ] `[video]` section exists
- [ ] `fullscreen` is boolean (true/false)
- [ ] `screen_shake_intensity` is float (0.0-1.0)
- [ ] Values match what was set in settings menu

---

### 8. Edge Cases and Error Handling
**Objective:** Verify settings handle edge cases gracefully

**Test Cases:**

#### 8.1 Missing Settings File
**Steps:**
1. Delete `settings.cfg` file if it exists
2. Launch game

**Expected:**
- [ ] Game uses default values (windowed, screen shake 1.0)
- [ ] No errors in console
- [ ] Warning logged: "Could not load settings file, using defaults"

#### 8.2 Corrupted Settings File
**Steps:**
1. Edit `settings.cfg` manually with invalid data:
   ```ini
   [video]
   fullscreen=invalid_value
   screen_shake_intensity=9999
   ```
2. Launch game

**Expected:**
- [ ] Game falls back to defaults for invalid values
- [ ] No crashes
- [ ] Valid settings overwrite corrupted file

#### 8.3 Multiple Rapid Changes
**Steps:**
1. Open settings
2. Rapidly toggle fullscreen checkbox 10 times
3. Rapidly move screen shake slider back and forth

**Expected:**
- [ ] Window mode updates reflect final state
- [ ] No crashes or lag
- [ ] Settings file contains final values

---

### 9. UI Integration Verification
**Objective:** Verify video settings UI matches implementation

**Steps:**
1. Open settings menu
2. Verify all video controls exist
3. Test control interactions

**Expected Results:**
- [ ] Video section has clear label/separator
- [ ] Fullscreen checkbox exists and is interactive
- [ ] Screen Shake slider exists with min/max labels
- [ ] Screen Shake value label updates in real-time
- [ ] Controls use consistent styling with rest of menu

**UI Structure:**
```
VideoSection (VBoxContainer)
  ├─ VideoLabel ("== Video ==")
  ├─ FullscreenContainer (HBoxContainer)
  │   ├─ FullscreenLabel ("Fullscreen")
  │   └─ FullscreenCheckBox
  └─ ScreenShakeContainer (HBoxContainer)
      ├─ ScreenShakeLabel ("Screen Shake")
      ├─ ScreenShakeSlider (HSlider)
      └─ ScreenShakeValue (Label)
```

---

## Summary Checklist

### Fullscreen Toggle
- [ ] Changes window mode immediately (no restart)
- [ ] Setting persists within same session
- [ ] Setting persists across game launches
- [ ] DisplayServer.window_set_mode() called correctly
- [ ] Checkbox state reflects current window mode

### Screen Shake Intensity
- [ ] Slider updates label in real-time (Off/Low/Medium/High)
- [ ] Setting persists across game launches
- [ ] Value clamped to 0.0-1.0 range
- [ ] Getter method available for EffectsManager integration
- [ ] Signal emitted on changes

### Persistence Layer
- [ ] Settings saved to user://settings.cfg
- [ ] File format correct ([video] section with fullscreen and screen_shake_intensity)
- [ ] Settings loaded on game start
- [ ] Defaults used if file missing or corrupted

### Error Handling
- [ ] Graceful fallback to defaults if file missing
- [ ] No crashes with corrupted settings
- [ ] Warnings logged appropriately

---

## Test Results

### Test Session: [Date/Time]
**Tester:** [Name]
**Build:** [Commit hash]

| Test Section | Status | Notes |
|--------------|--------|-------|
| 1. Fullscreen Real-time | ⬜ PASS / ⬜ FAIL | |
| 2. Fullscreen Same Session | ⬜ PASS / ⬜ FAIL | |
| 3. Fullscreen Cross-Session | ⬜ PASS / ⬜ FAIL | |
| 4. Screen Shake Labels | ⬜ PASS / ⬜ FAIL | |
| 5. Screen Shake Persistence | ⬜ PASS / ⬜ FAIL | |
| 6. Integration Readiness | ⬜ PASS / ⬜ FAIL | |
| 7. File Format | ⬜ PASS / ⬜ FAIL | |
| 8. Edge Cases | ⬜ PASS / ⬜ FAIL | |
| 9. UI Integration | ⬜ PASS / ⬜ FAIL | |

**Overall Result:** ⬜ PASS / ⬜ FAIL

**Issues Found:**
- [List any issues discovered during testing]

**Notes:**
- [Additional observations or comments]
