extends Node
## Test script to verify tutorial persistence across save/load operations.
## Run this script to test that tutorial progress is correctly saved and loaded.

# =============================================================================
# TEST CONFIGURATION
# =============================================================================

var test_results: Array[String] = []
var tests_passed: int = 0
var tests_failed: int = 0

# =============================================================================
# TEST EXECUTION
# =============================================================================

func _ready() -> void:
	print("\n========================================")
	print("TUTORIAL PERSISTENCE TEST")
	print("========================================\n")

	# Wait one frame for autoloads to initialize
	await get_tree().process_frame

	# Run all tests
	await run_all_tests()

	# Print results
	print_results()

	# Exit
	get_tree().quit()

func run_all_tests() -> void:
	## Execute all test cases
	await test_save_tutorial_progress()
	await test_load_tutorial_progress()
	await test_save_file_structure()
	await test_tutorial_state_persistence()

# =============================================================================
# TEST CASES
# =============================================================================

func test_save_tutorial_progress() -> void:
	## Test that tutorial progress can be saved to file
	print("TEST: Save tutorial progress")

	# Clean slate - delete existing save
	if SaveManager.has_save_file():
		SaveManager.delete_save()

	# Reset tutorials
	TutorialManager.reset_all_tutorials()

	# Complete movement tutorial
	TutorialManager.mark_tutorial_shown(TutorialManager.TUTORIAL_MOVEMENT)
	TutorialManager.mark_tutorial_completed(TutorialManager.TUTORIAL_MOVEMENT)

	# Complete attack tutorial
	TutorialManager.mark_tutorial_shown(TutorialManager.TUTORIAL_ATTACK)
	TutorialManager.mark_tutorial_completed(TutorialManager.TUTORIAL_ATTACK)

	# Set some action counts
	TutorialManager.action_counts[TutorialManager.TUTORIAL_DODGE] = 2

	# Save the game
	var save_result = SaveManager.save_game()

	if save_result:
		assert_true(SaveManager.has_save_file(), "Save file should exist after saving")
		print("  ✓ Save file created successfully")
	else:
		assert_true(false, "Save operation should succeed")
		print("  ✗ Save operation failed")

func test_load_tutorial_progress() -> void:
	## Test that tutorial progress can be loaded from file
	print("\nTEST: Load tutorial progress")

	# Save current state first
	TutorialManager.reset_all_tutorials()
	TutorialManager.mark_tutorial_shown(TutorialManager.TUTORIAL_MOVEMENT)
	TutorialManager.mark_tutorial_completed(TutorialManager.TUTORIAL_MOVEMENT)
	TutorialManager.mark_tutorial_shown(TutorialManager.TUTORIAL_COMBO)
	TutorialManager.action_counts[TutorialManager.TUTORIAL_COMBO] = 1
	SaveManager.save_game()

	# Reset to simulate fresh start
	TutorialManager.reset_all_tutorials()

	# Verify reset worked
	assert_false(
		TutorialManager.is_tutorial_completed(TutorialManager.TUTORIAL_MOVEMENT),
		"Movement tutorial should be incomplete after reset"
	)

	# Load the game
	var load_result = SaveManager.load_game()

	if load_result:
		# Verify loaded state
		assert_true(
			TutorialManager.is_tutorial_completed(TutorialManager.TUTORIAL_MOVEMENT),
			"Movement tutorial should be completed after load"
		)
		assert_true(
			TutorialManager.tutorials_shown.get(TutorialManager.TUTORIAL_COMBO, false),
			"Combo tutorial should be shown after load"
		)
		assert_equal(
			TutorialManager.get_action_count(TutorialManager.TUTORIAL_COMBO),
			1,
			"Combo action count should be 1 after load"
		)
		print("  ✓ Tutorial progress loaded successfully")
	else:
		assert_true(false, "Load operation should succeed")
		print("  ✗ Load operation failed")

func test_save_file_structure() -> void:
	## Test that save file has correct JSON structure with tutorial data
	print("\nTEST: Save file structure")

	# Save with known state
	TutorialManager.reset_all_tutorials()
	TutorialManager.set_tutorials_enabled(true)
	TutorialManager.mark_tutorial_completed(TutorialManager.TUTORIAL_MOVEMENT)
	TutorialManager.mark_tutorial_completed(TutorialManager.TUTORIAL_ATTACK)
	SaveManager.save_game()

	# Read and parse save file
	var save_path = SaveManager.SAVE_FILE_PATH
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				var data = json.data

				# Check structure
				assert_true(data.has("tutorial"), "Save file should contain 'tutorial' key")

				if data.has("tutorial"):
					var tutorial_data = data["tutorial"]
					assert_true(tutorial_data.has("tutorial_enabled"), "Tutorial data should have 'tutorial_enabled'")
					assert_true(tutorial_data.has("tutorials_shown"), "Tutorial data should have 'tutorials_shown'")
					assert_true(tutorial_data.has("tutorials_completed"), "Tutorial data should have 'tutorials_completed'")
					assert_true(tutorial_data.has("action_counts"), "Tutorial data should have 'action_counts'")

					# Verify specific values
					assert_true(tutorial_data["tutorial_enabled"], "Tutorials should be enabled")
					assert_true(
						tutorial_data["tutorials_completed"].get(TutorialManager.TUTORIAL_MOVEMENT, false),
						"Movement tutorial should be marked completed in save file"
					)
					assert_true(
						tutorial_data["tutorials_completed"].get(TutorialManager.TUTORIAL_ATTACK, false),
						"Attack tutorial should be marked completed in save file"
					)

					print("  ✓ Save file structure is correct")
					print("  ✓ Tutorial data properly serialized to JSON")
				else:
					print("  ✗ Save file missing tutorial data")
			else:
				print("  ✗ Failed to parse save file JSON")
		else:
			print("  ✗ Failed to open save file")
	else:
		print("  ✗ Save file does not exist")

func test_tutorial_state_persistence() -> void:
	## Test that tutorial state persists correctly across multiple save/load cycles
	print("\nTEST: Tutorial state persistence across multiple cycles")

	# Cycle 1: Save with movement completed
	TutorialManager.reset_all_tutorials()
	TutorialManager.mark_tutorial_completed(TutorialManager.TUTORIAL_MOVEMENT)
	SaveManager.save_game()
	TutorialManager.reset_all_tutorials()
	SaveManager.load_game()

	assert_true(
		TutorialManager.is_tutorial_completed(TutorialManager.TUTORIAL_MOVEMENT),
		"Movement tutorial should persist after cycle 1"
	)

	# Cycle 2: Add attack tutorial and save
	TutorialManager.mark_tutorial_completed(TutorialManager.TUTORIAL_ATTACK)
	SaveManager.save_game()
	TutorialManager.reset_all_tutorials()
	SaveManager.load_game()

	assert_true(
		TutorialManager.is_tutorial_completed(TutorialManager.TUTORIAL_MOVEMENT),
		"Movement tutorial should still be completed after cycle 2"
	)
	assert_true(
		TutorialManager.is_tutorial_completed(TutorialManager.TUTORIAL_ATTACK),
		"Attack tutorial should be completed after cycle 2"
	)

	# Cycle 3: Disable tutorials and save
	TutorialManager.set_tutorials_enabled(false)
	SaveManager.save_game()
	TutorialManager.set_tutorials_enabled(true)  # Reset to true
	SaveManager.load_game()

	assert_false(
		TutorialManager.tutorial_enabled,
		"Tutorial enabled state should persist (disabled)"
	)

	print("  ✓ Tutorial state persists correctly across multiple save/load cycles")

# =============================================================================
# ASSERTION HELPERS
# =============================================================================

func assert_true(condition: bool, message: String) -> void:
	if condition:
		tests_passed += 1
		test_results.append("✓ PASS: " + message)
	else:
		tests_failed += 1
		test_results.append("✗ FAIL: " + message)

func assert_false(condition: bool, message: String) -> void:
	assert_true(not condition, message)

func assert_equal(actual, expected, message: String) -> void:
	if actual == expected:
		tests_passed += 1
		test_results.append("✓ PASS: " + message + " (got: " + str(actual) + ")")
	else:
		tests_failed += 1
		test_results.append("✗ FAIL: " + message + " (expected: " + str(expected) + ", got: " + str(actual) + ")")

# =============================================================================
# RESULT REPORTING
# =============================================================================

func print_results() -> void:
	print("\n========================================")
	print("TEST RESULTS")
	print("========================================\n")

	for result in test_results:
		print(result)

	print("\n========================================")
	print("SUMMARY")
	print("========================================")
	print("Passed: ", tests_passed)
	print("Failed: ", tests_failed)
	print("Total:  ", tests_passed + tests_failed)

	if tests_failed == 0:
		print("\n✓ ALL TESTS PASSED")
	else:
		print("\n✗ SOME TESTS FAILED")

	print("========================================\n")
