# Settings Audio Integration Test

## Purpose
This test verifies that `SettingsManager` correctly integrates with Godot's `AudioServer` to control audio bus volumes.

## What It Tests
1. ✅ SettingsManager autoload exists and is accessible
2. ✅ AudioServer buses (Master, Music, SFX) exist
3. ✅ `SettingsManager.set_master_volume()` correctly updates AudioServer Master bus
4. ✅ `SettingsManager.set_music_volume()` correctly updates AudioServer Music bus
5. ✅ `SettingsManager.set_sfx_volume()` correctly updates AudioServer SFX bus
6. ✅ Volume value 0.0 (silent) correctly sets -80 db
7. ✅ Volume value 1.0 (full) correctly sets 0 db
8. ✅ `audio_settings_changed` signal is emitted on volume changes

## How to Run

### Method 1: Run the Test Scene
1. Open the Godot editor
2. In the FileSystem panel, navigate to `res://tests/`
3. Double-click `settings_audio_integration_test.tscn` to open it
4. Press F5 or click the "Play Scene" button (▶)
5. Check the Output console at the bottom of the editor
6. All tests should show "PASS" messages

### Method 2: Attach Script to Existing Scene
1. Open any scene in the Godot editor
2. Add a new Node to the scene (right-click scene root → Add Child Node → Node)
3. Select the new Node
4. In the Inspector panel, click the "Attach Script" button
5. Navigate to `res://tests/settings_audio_integration_test.gd` and attach it
6. Run the scene (F6 or click "Play Scene")
7. Check the Output console for test results

## Expected Output
```
=== Settings Audio Integration Test ===

Test 1: Verify SettingsManager autoload exists
PASS: SettingsManager autoload found

Test 2: Verify AudioServer buses exist
PASS: All audio buses found (Master: 0, Music: 1, SFX: 2)

Test 3: Test SettingsManager.set_master_volume() affects AudioServer
  Initial Master volume (db): 0.00
  After set_master_volume(0.5): -6.02 db
PASS: Master volume changed correctly (expected: -6.02 db, got: -6.02 db)

Test 4: Test SettingsManager.set_music_volume() affects AudioServer
  Initial Music volume (db): -3.06 db
  After set_music_volume(0.3): -10.46 db
PASS: Music volume changed correctly (expected: -10.46 db, got: -10.46 db)

Test 5: Test SettingsManager.set_sfx_volume() affects AudioServer
  Initial SFX volume (db): 0.00
  After set_sfx_volume(0.7): -3.10 db
PASS: SFX volume changed correctly (expected: -3.10 db, got: -3.10 db)

Test 6: Test volume of 0.0 sets -80 db (silent)
  After set_master_volume(0.0): -80.00 db
PASS: Volume 0.0 correctly sets to -80 db (silent)

Test 7: Test volume of 1.0 sets 0 db (full volume)
  After set_master_volume(1.0): 0.00 db
PASS: Volume 1.0 correctly sets to 0 db (full)

Test 8: Verify audio_settings_changed signal is emitted
  Signal received!
PASS: audio_settings_changed signal emitted correctly

Restoring default settings...

=== All Tests Complete ===
Review the output above to verify all tests passed.

Integration verified: SettingsManager.set_*_volume() methods
correctly call AudioServer.set_bus_volume_db() for all audio buses.
```

## Troubleshooting

### "SettingsManager autoload not found"
- Ensure SettingsManager is registered in `project.godot` under [autoload]
- Restart the Godot editor if you recently added the autoload

### "Master/Music/SFX bus not found"
- Check the Audio tab in Godot editor (bottom panel)
- Ensure Master, Music, and SFX buses exist in the AudioBusLayout
- These buses should be defined in the project's audio configuration

### Tests show FAIL messages
- Read the specific error message to identify which test failed
- Check the SettingsManager implementation in `autoloads/settings_manager.gd`
- Verify the `apply_audio_settings()` method is correctly calling `AudioServer.set_bus_volume_db()`

## Integration Details

The SettingsManager integrates with AudioServer as follows:

1. **Volume Conversion**: User-facing volume values (0.0 - 1.0) are converted to decibels using `linear_to_db()`
   - 0.0 → -80 db (effectively silent)
   - 0.5 → -6 db (half volume)
   - 1.0 → 0 db (full volume)

2. **Bus Application**: Converted volume is applied to the appropriate AudioServer bus:
   - Master volume → "Master" bus
   - Music volume → "Music" bus
   - SFX volume → "SFX" bus

3. **Signal Emission**: After applying audio settings, the `audio_settings_changed` signal is emitted to notify other systems

## Manual Verification (Alternative)

You can also manually verify the integration:

1. Open the Godot editor
2. Open the Script editor
3. Select "File → New Script"
4. Choose "GDScript" and attach to any Node
5. Paste this code:
```gdscript
func _ready():
    SettingsManager.set_master_volume(0.5)
    var master_idx = AudioServer.get_bus_index("Master")
    var db = AudioServer.get_bus_volume_db(master_idx)
    print("Master volume (db): ", db)
    print("Expected: approximately -6 db")
```
6. Run the scene and check if the output shows approximately -6 db
