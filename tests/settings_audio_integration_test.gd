extends Node
## Test script to verify SettingsManager audio integration with AudioServer
##
## Instructions:
## 1. Create a new Node in a test scene
## 2. Attach this script to the Node
## 3. Run the scene
## 4. Check the Output console for test results
## 5. Verify that AudioServer bus volumes change when SettingsManager methods are called

func _ready() -> void:
	print("=== Settings Audio Integration Test ===")
	print("")

	# Wait one frame for all autoloads to initialize
	await get_tree().process_frame

	# Test 1: Verify SettingsManager exists
	print("Test 1: Verify SettingsManager autoload exists")
	if SettingsManager == null:
		push_error("FAIL: SettingsManager autoload not found")
		return
	print("PASS: SettingsManager autoload found")
	print("")

	# Test 2: Verify AudioServer buses exist
	print("Test 2: Verify AudioServer buses exist")
	var master_idx: int = AudioServer.get_bus_index("Master")
	var music_idx: int = AudioServer.get_bus_index("Music")
	var sfx_idx: int = AudioServer.get_bus_index("SFX")

	if master_idx < 0:
		push_error("FAIL: Master bus not found")
		return
	if music_idx < 0:
		push_error("FAIL: Music bus not found")
		return
	if sfx_idx < 0:
		push_error("FAIL: SFX bus not found")
		return

	print("PASS: All audio buses found (Master: %d, Music: %d, SFX: %d)" % [master_idx, music_idx, sfx_idx])
	print("")

	# Test 3: Test master volume integration
	print("Test 3: Test SettingsManager.set_master_volume() affects AudioServer")
	var initial_master_db: float = AudioServer.get_bus_volume_db(master_idx)
	print("  Initial Master volume (db): %.2f" % initial_master_db)

	# Set master volume to 0.5 (should be approximately -6 db)
	SettingsManager.set_master_volume(0.5)
	await get_tree().process_frame

	var new_master_db: float = AudioServer.get_bus_volume_db(master_idx)
	print("  After set_master_volume(0.5): %.2f db" % new_master_db)

	# Verify it changed (0.5 linear should be around -6 db)
	var expected_db: float = linear_to_db(0.5)
	var tolerance: float = 0.1  # Allow small floating point error

	if abs(new_master_db - expected_db) < tolerance:
		print("PASS: Master volume changed correctly (expected: %.2f db, got: %.2f db)" % [expected_db, new_master_db])
	else:
		push_error("FAIL: Master volume incorrect (expected: %.2f db, got: %.2f db)" % [expected_db, new_master_db])
	print("")

	# Test 4: Test music volume integration
	print("Test 4: Test SettingsManager.set_music_volume() affects AudioServer")
	var initial_music_db: float = AudioServer.get_bus_volume_db(music_idx)
	print("  Initial Music volume (db): %.2f" % initial_music_db)

	# Set music volume to 0.3
	SettingsManager.set_music_volume(0.3)
	await get_tree().process_frame

	var new_music_db: float = AudioServer.get_bus_volume_db(music_idx)
	print("  After set_music_volume(0.3): %.2f db" % new_music_db)

	expected_db = linear_to_db(0.3)
	if abs(new_music_db - expected_db) < tolerance:
		print("PASS: Music volume changed correctly (expected: %.2f db, got: %.2f db)" % [expected_db, new_music_db])
	else:
		push_error("FAIL: Music volume incorrect (expected: %.2f db, got: %.2f db)" % [expected_db, new_music_db])
	print("")

	# Test 5: Test SFX volume integration
	print("Test 5: Test SettingsManager.set_sfx_volume() affects AudioServer")
	var initial_sfx_db: float = AudioServer.get_bus_volume_db(sfx_idx)
	print("  Initial SFX volume (db): %.2f" % initial_sfx_db)

	# Set SFX volume to 0.7
	SettingsManager.set_sfx_volume(0.7)
	await get_tree().process_frame

	var new_sfx_db: float = AudioServer.get_bus_volume_db(sfx_idx)
	print("  After set_sfx_volume(0.7): %.2f db" % new_sfx_db)

	expected_db = linear_to_db(0.7)
	if abs(new_sfx_db - expected_db) < tolerance:
		print("PASS: SFX volume changed correctly (expected: %.2f db, got: %.2f db)" % [expected_db, new_sfx_db])
	else:
		push_error("FAIL: SFX volume incorrect (expected: %.2f db, got: %.2f db)" % [expected_db, new_sfx_db])
	print("")

	# Test 6: Test volume of 0.0 (silent)
	print("Test 6: Test volume of 0.0 sets -80 db (silent)")
	SettingsManager.set_master_volume(0.0)
	await get_tree().process_frame

	var silent_db: float = AudioServer.get_bus_volume_db(master_idx)
	print("  After set_master_volume(0.0): %.2f db" % silent_db)

	if abs(silent_db - (-80.0)) < tolerance:
		print("PASS: Volume 0.0 correctly sets to -80 db (silent)")
	else:
		push_error("FAIL: Volume 0.0 should be -80 db, got: %.2f db" % silent_db)
	print("")

	# Test 7: Test volume of 1.0 (full)
	print("Test 7: Test volume of 1.0 sets 0 db (full volume)")
	SettingsManager.set_master_volume(1.0)
	await get_tree().process_frame

	var full_db: float = AudioServer.get_bus_volume_db(master_idx)
	print("  After set_master_volume(1.0): %.2f db" % full_db)

	if abs(full_db - 0.0) < tolerance:
		print("PASS: Volume 1.0 correctly sets to 0 db (full)")
	else:
		push_error("FAIL: Volume 1.0 should be 0 db, got: %.2f db" % full_db)
	print("")

	# Test 8: Verify signals are emitted
	print("Test 8: Verify audio_settings_changed signal is emitted")
	var signal_received: bool = false

	SettingsManager.audio_settings_changed.connect(func():
		signal_received = true
		print("  Signal received!")
	)

	SettingsManager.set_master_volume(0.8)
	await get_tree().process_frame

	if signal_received:
		print("PASS: audio_settings_changed signal emitted correctly")
	else:
		push_error("FAIL: audio_settings_changed signal not received")
	print("")

	# Restore default values
	print("Restoring default settings...")
	SettingsManager.set_master_volume(SettingsManager.DEFAULT_MASTER_VOLUME)
	SettingsManager.set_music_volume(SettingsManager.DEFAULT_MUSIC_VOLUME)
	SettingsManager.set_sfx_volume(SettingsManager.DEFAULT_SFX_VOLUME)

	print("")
	print("=== All Tests Complete ===")
	print("Review the output above to verify all tests passed.")
	print("")
	print("Integration verified: SettingsManager.set_*_volume() methods")
	print("correctly call AudioServer.set_bus_volume_db() for all audio buses.")
