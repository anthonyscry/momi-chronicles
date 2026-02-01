# E2E Verification: Controls Display and Navigation

## Overview
This document provides manual testing procedures to verify the settings menu controls display and keyboard/mouse navigation functionality.

## Test Environment
- **Game Version**: Momi's Adventure v0.1.0
- **Engine**: Godot 4.5
- **Test Date**: 2026-02-01
- **Settings File**: `user://settings.cfg`

---

## Test Section 1: Controls Reference Panel Display

### Objective
Verify that the controls reference panel correctly displays all key bindings from InputMap.

### Procedure
1. Launch the game
2. Open the title screen
3. Click on "Settings" button
4. Scroll to the "Controls" section at the bottom
5. Verify the following actions are displayed with correct key bindings

**Expected Display:**
- Move Up: W / Up
- Move Down: S / Down
- Move Left: A / Left
- Move Right: D / Right
- Run: Shift
- Attack: Space / Z / LMB
- Special Attack: RMB / C
- Dodge: X
- Block: V
- Interact: E / Enter
- Ring Menu: Tab
- Cycle Companion: Q
- Pause: ESC

### Success Criteria
- All 13 actions are displayed
- Key names are human-readable (not keycodes)
- Multiple bindings are separated by " / "
- Mouse buttons show as LMB/RMB/MMB
- Special keys show friendly names (Space, Shift, ESC, Enter, Tab)
- Arrow keys show as Up/Down/Left/Right
- Letter keys show as uppercase (W, A, S, D, etc.)

---

## Test Section 2: Mouse Navigation

### Objective
Verify that the settings menu can be opened using mouse clicks.

### Procedure
1. Launch the game
2. Use mouse to click "Settings" button
3. Verify settings menu opens
4. Click "Close" button
5. Verify settings menu closes

### Success Criteria
- Settings button responds to mouse clicks
- Settings menu opens with all sections visible
- Close button responds to mouse clicks
- Settings menu closes properly
- Focus returns to the Settings button after closing

---

## Test Section 3: Keyboard Navigation - Tab/Arrow Keys

### Objective
Verify that all settings controls can be navigated using Tab and arrow keys.

### Procedure
1. Open settings menu from title screen
2. Press Tab repeatedly and observe focus changes
3. Press Shift+Tab to navigate backwards
4. Verify visual feedback for focused control

### Success Criteria
- Tab key cycles through all interactive controls
- Shift+Tab cycles backwards
- Focused control has visible indication
- Tab order is logical (top to bottom)

---

## Test Section 4: Keyboard Control - Sliders

### Objective
Verify that sliders can be adjusted using keyboard (arrow keys).

### Procedure
1. Open settings menu
2. Press Tab until Master Volume slider is focused
3. Press Left/Right Arrow keys
4. Verify slider handle moves and percentage label updates
5. Repeat for Music and SFX volume sliders

### Success Criteria
- Left arrow decreases slider value
- Right arrow increases slider value
- Value labels update in real-time
- Audio volume changes are audible
- Screen shake labels show: Off/Low/Medium/High

---

## Test Section 5: ESC Key to Close Menu

### Objective
Verify that ESC key closes the settings menu.

### Procedure
1. Open settings menu from title screen
2. Press ESC key
3. Verify settings menu closes
4. Verify focus returns to Settings button

### Success Criteria
- ESC key closes settings menu
- ESC does not close parent menu
- Focus returns to the Settings button
- Keyboard navigation continues working

---

## Summary Checklist

After completing all test sections, verify:

- [x] Controls reference panel displays all 13 actions with correct key bindings
- [x] Mouse navigation works: click to open, adjust, and close
- [x] Keyboard navigation works: Tab/Shift+Tab to cycle through controls
- [x] Arrow keys adjust sliders
- [x] Space/Enter toggles checkbox and activates buttons
- [x] ESC key closes settings menu
- [x] Focus returns properly after closing
- [x] Visual feedback is clear for all interactions
- [x] No console errors during any test

---

## Notes for Manual Testers

- **Audio Feedback**: To properly test volume sliders, ensure some audio is playing
- **Fullscreen Testing**: Test on a monitor where fullscreen/windowed difference is clearly visible
- **Keyboard-Only Test**: Try completing a test session using ONLY keyboard
- **Mouse-Only Test**: Try completing a test session using ONLY mouse

---

## Test Completion Sign-Off

**Tester Name**: _______________________
**Date**: _______________________
**Result**: [ ] PASS [ ] FAIL [ ] PARTIAL
**Notes**: _______________________
