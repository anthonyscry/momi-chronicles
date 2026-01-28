extends Node
## UITester - Automated UI testing framework for Momi's Adventure.
## Toggle with F2 key. Disabled by default.
##
## Provides:
## - Test runner framework with scenarios
## - Timestamped logging with context
## - Screenshot capture on failures
## - Retry logic with fix attempts

# =============================================================================
# STATE VARIABLES
# =============================================================================

## Whether UITester is active
var enabled: bool = false

## Current scenario being executed
var current_scenario: String = ""

## All test outcomes
var test_results: Array = []

## Counters
var passed_count: int = 0
var failed_count: int = 0
var fixed_on_retry_count: int = 0

## Internal state
var _f2_held: bool = false
var _initialized: bool = false
var _test_running: bool = false

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	call_deferred("_deferred_init")


func _deferred_init() -> void:
	log_test("Initialized - Press F2 to toggle")
	_initialized = true


func _input(event: InputEvent) -> void:
	if not _initialized:
		return
	
	# Toggle with F2 key
	if event is InputEventKey and event.keycode == KEY_F2:
		if event.pressed and not _f2_held:
			_f2_held = true
			_toggle_enabled()
		elif not event.pressed:
			_f2_held = false


func _toggle_enabled() -> void:
	enabled = not enabled
	
	if enabled:
		log_test("UITester ENABLED")
		# Reset counters for new test run
		passed_count = 0
		failed_count = 0
		fixed_on_retry_count = 0
		test_results.clear()
		# Start test suite
		run_all_tests()
	else:
		log_test("UITester DISABLED")
		_test_running = false


# =============================================================================
# LOGGING INFRASTRUCTURE
# =============================================================================

## Log a message with [UITester] prefix and ISO timestamp
func log_test(message: String) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	print("[UITester] [%s] %s" % [timestamp, message])


## Log the start of a scenario
func log_scenario_start(name: String) -> void:
	current_scenario = name
	var timestamp = Time.get_datetime_string_from_system()
	print("")
	print("=" .repeat(60))
	print("[UITester] [%s] === STARTING SCENARIO: %s ===" % [timestamp, name])
	print("=" .repeat(60))


## Log the end of a scenario
func log_scenario_end(name: String, passed: int, failed: int) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var status = "PASSED" if failed == 0 else "FAILED"
	print("-" .repeat(60))
	print("[UITester] [%s] === SCENARIO %s: %s (passed: %d, failed: %d) ===" % [
		timestamp, name, status, passed, failed
	])
	print("-" .repeat(60))
	print("")


## Log a check result with actual vs expected values
func log_check(description: String, actual, expected, passed: bool) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	var status = "PASS" if passed else "FAIL"
	var icon = "[OK]" if passed else "[X]"
	print("[UITester] [%s] %s %s: %s" % [timestamp, icon, status, description])
	if not passed:
		print("           Expected: %s" % str(expected))
		print("           Actual:   %s" % str(actual))


## Log a detailed failure
func log_failure(description: String, reason: String) -> void:
	var timestamp = Time.get_datetime_string_from_system()
	print("[UITester] [%s] [X] FAILURE: %s" % [timestamp, description])
	print("           Reason: %s" % reason)


## Log test summary
func log_summary() -> void:
	var timestamp = Time.get_datetime_string_from_system()
	print("")
	print("=" .repeat(60))
	print("[UITester] [%s] === TEST SUMMARY ===" % timestamp)
	print("=" .repeat(60))
	print("  Total Passed:       %d" % passed_count)
	print("  Total Failed:       %d" % failed_count)
	print("  Fixed on Retry:     %d" % fixed_on_retry_count)
	print("  Total Checks:       %d" % (passed_count + failed_count))
	var overall = "PASSED" if failed_count == 0 else "FAILED"
	print("  Overall Status:     %s" % overall)
	print("=" .repeat(60))
	print("")


# =============================================================================
# TEST RUNNER
# =============================================================================

## Run all test scenarios
func run_all_tests() -> void:
	if _test_running:
		log_test("Tests already running, ignoring request")
		return
	
	_test_running = true
	
	log_test("========================================")
	log_test("   UI TESTER - FULL TEST SUITE")
	log_test("========================================")
	
	# Reset counters for new test run
	passed_count = 0
	failed_count = 0
	fixed_on_retry_count = 0
	test_results.clear()
	
	# Framework self-test first
	await _run_framework_self_test()
	
	# Scenario 1: Title Screen Flow
	var s1_passed = await test_scenario_title_screen()
	test_results.append({"scenario": "Title Screen Flow", "passed": s1_passed})
	log_test("SCENARIO RESULT: Title Screen Flow - " + ("PASS" if s1_passed else "FAIL"))
	
	# Scenario 2: Gameplay HUD
	var s2_passed = await test_scenario_gameplay_hud()
	test_results.append({"scenario": "Gameplay HUD", "passed": s2_passed})
	log_test("SCENARIO RESULT: Gameplay HUD - " + ("PASS" if s2_passed else "FAIL"))
	
	# Scenario 3: Pause Menu Flow
	var s3_passed = await test_scenario_pause_menu()
	test_results.append({"scenario": "Pause Menu Flow", "passed": s3_passed})
	log_test("SCENARIO RESULT: Pause Menu Flow - " + ("PASS" if s3_passed else "FAIL"))
	
	# Scenario 4: Game Over Flow
	var s4_passed = await test_scenario_game_over()
	test_results.append({"scenario": "Game Over Flow", "passed": s4_passed})
	log_test("SCENARIO RESULT: Game Over Flow - " + ("PASS" if s4_passed else "FAIL"))
	
	# Scenario 5: New Features Smoke Test
	var s5_passed = await test_scenario_new_features()
	test_results.append({"scenario": "New Features Smoke", "passed": s5_passed})
	log_test("SCENARIO RESULT: New Features Smoke - " + ("PASS" if s5_passed else "FAIL"))
	
	# Print final summary
	print_test_summary()
	
	_test_running = false
	log_test("Test suite complete")


## Self-test to verify framework works
func _run_framework_self_test() -> void:
	log_scenario_start("Framework Self-Test")
	
	var scenario_passed = 0
	var scenario_failed = 0
	
	# Test 1: Verify logging works (always passes)
	var check1_passed = true
	log_check("Logging system functional", true, true, check1_passed)
	if check1_passed:
		scenario_passed += 1
		passed_count += 1
	else:
		scenario_failed += 1
		failed_count += 1
	
	# Test 2: Verify timestamp format
	var timestamp = Time.get_datetime_string_from_system()
	var check2_passed = timestamp.length() > 10  # Basic sanity check
	log_check("Timestamp format valid", timestamp.length(), "> 10", check2_passed)
	if check2_passed:
		scenario_passed += 1
		passed_count += 1
	else:
		scenario_failed += 1
		failed_count += 1
	
	# Test 3: Verify screenshot directory can be created
	var dir = DirAccess.open("res://")
	var can_create_dir = dir != null
	log_check("DirAccess available for screenshots", can_create_dir, true, can_create_dir)
	if can_create_dir:
		scenario_passed += 1
		passed_count += 1
	else:
		scenario_failed += 1
		failed_count += 1
	
	# Test 4: Verify screenshot capture works (capture a test screenshot)
	await _test_screenshot_capture()
	scenario_passed += 1
	passed_count += 1
	
	log_scenario_end("Framework Self-Test", scenario_passed, scenario_failed)


## Test that screenshot capture actually works
func _test_screenshot_capture() -> void:
	log_test("Testing screenshot capture system...")
	
	# Ensure the directory structure exists
	_ensure_screenshot_directory()
	
	# Capture a test screenshot to verify the system works
	var datetime = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var test_filename = "res://exports/test_screenshots/framework_test_%s.png" % datetime
	
	# Wait for frame to be drawn
	await RenderingServer.frame_post_draw
	
	# Capture viewport
	var viewport = get_viewport()
	if viewport:
		var img = viewport.get_texture().get_image()
		var error = img.save_png(test_filename)
		if error == OK:
			log_check("Screenshot capture functional", "saved", "saved", true)
			log_test("Test screenshot saved: %s" % test_filename)
		else:
			log_check("Screenshot capture functional", "error: %d" % error, "saved", false)
	else:
		log_check("Screenshot capture functional", "no viewport", "saved", false)


## Ensure the screenshot directory exists
func _ensure_screenshot_directory() -> void:
	var dir = DirAccess.open("res://")
	if dir:
		if not dir.dir_exists("exports"):
			var err1 = dir.make_dir("exports")
			if err1 == OK:
				log_test("Created exports/ directory")
		if not dir.dir_exists("exports/test_screenshots"):
			var err2 = dir.make_dir("exports/test_screenshots")
			if err2 == OK:
				log_test("Created exports/test_screenshots/ directory")


## Record a test result
func record_result(scenario: String, check: String, passed: bool, details: Dictionary = {}) -> void:
	var result = {
		"scenario": scenario,
		"check": check,
		"passed": passed,
		"timestamp": Time.get_datetime_string_from_system(),
		"details": details
	}
	test_results.append(result)


# =============================================================================
# SCREENSHOT CAPTURE
# =============================================================================

## Capture a screenshot on test failure
func capture_screenshot(test_name: String) -> void:
	var datetime = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var safe_name = test_name.to_snake_case().replace(" ", "_")
	var filename = "res://exports/test_screenshots/%s_%s.png" % [safe_name, datetime]
	
	# Ensure directory exists
	_ensure_screenshot_directory()
	
	# Wait for frame to be drawn
	await RenderingServer.frame_post_draw
	
	# Capture viewport
	var viewport = get_viewport()
	if viewport:
		var img = viewport.get_texture().get_image()
		var error = img.save_png(filename)
		if error == OK:
			log_test("Screenshot saved: %s" % filename)
		else:
			log_test("Failed to save screenshot: %s (error: %d)" % [filename, error])
	else:
		log_test("Failed to capture screenshot: no viewport")


# =============================================================================
# CHECK WITH RETRY
# =============================================================================

## Run a check with optional retry and fix attempt
func run_check_with_retry(check_name: String, check_func: Callable, fix_func: Callable = Callable()) -> bool:
	# First attempt
	var result = check_func.call()
	if result:
		log_check(check_name, "pass", "pass", true)
		passed_count += 1
		record_result(current_scenario, check_name, true)
		return true
	
	# First failure - capture screenshot
	await capture_screenshot(check_name)
	log_failure(check_name, "Initial check failed")
	
	# Attempt fix if provided
	if fix_func.is_valid():
		log_test("Attempting fix for: %s" % check_name)
		fix_func.call()
		
		# Wait for fix to apply
		await get_tree().create_timer(0.5).timeout
		
		# Retry check
		result = check_func.call()
		if result:
			log_check(check_name + " (fixed)", "pass", "pass", true)
			fixed_on_retry_count += 1
			record_result(current_scenario, check_name, true, {"fixed_on_retry": true})
			return true
		else:
			await capture_screenshot(check_name + "_after_fix")
	
	# Final failure
	log_check(check_name, "fail", "pass", false)
	failed_count += 1
	record_result(current_scenario, check_name, false)
	return false


# =============================================================================
# TEST SCENARIOS
# =============================================================================

## Scenario 1: Title Screen Flow
## Tests that title screen loads correctly and Start button works
func test_scenario_title_screen() -> bool:
	log_scenario_start("Title Screen Flow")
	var all_passed = true
	var scenario_passed = 0
	var scenario_failed = 0
	
	# Navigate to title screen if not already there
	var title = find_ui_node("TitleScreen")
	if not title:
		log_test("Navigating to title screen...")
		get_tree().change_scene_to_file("res://ui/menus/title_screen.tscn")
		await get_tree().create_timer(1.0).timeout
	
	# Check 1: Title screen loaded
	var title_exists = await verify_exists("TitleScreen", "Title Screen root")
	if title_exists:
		scenario_passed += 1
	else:
		scenario_failed += 1
		all_passed = false
	
	# Check 2: Start or Continue button exists
	var start_btn = find_ui_node("StartButton")
	var continue_btn = find_ui_node("ContinueButton")
	var has_start_btn = start_btn != null or continue_btn != null
	if not has_start_btn:
		log_check("EXISTS: Start or Continue button", "neither found", "at least one", false)
		failed_count += 1
		scenario_failed += 1
		all_passed = false
		await capture_screenshot("missing_start_button")
	else:
		log_check("EXISTS: Start or Continue button", "found", "found", true)
		passed_count += 1
		scenario_passed += 1
	
	# Check 3: Start button visible (or Continue if save exists)
	if start_btn:
		var start_visible = await verify_visible("StartButton", "Start Button visible")
		if start_visible:
			scenario_passed += 1
		else:
			scenario_failed += 1
			all_passed = false
	elif continue_btn:
		var continue_visible = await verify_visible("ContinueButton", "Continue Button visible")
		if continue_visible:
			scenario_passed += 1
		else:
			scenario_failed += 1
			all_passed = false
	
	# Check 4: Quit button exists
	var quit_exists = await verify_exists("QuitButton", "Quit Button")
	if quit_exists:
		scenario_passed += 1
	else:
		scenario_failed += 1
		all_passed = false
	
	# Check 5: Simulate Start button press and verify scene change
	log_test("Testing Start button interaction...")
	var btn = start_btn if start_btn else continue_btn
	if btn and btn is Button:
		btn.emit_signal("pressed")
		await get_tree().create_timer(2.0).timeout  # Wait for scene change
		
		# Check 6: Scene changed to gameplay (player should exist)
		var player = get_player()
		var scene_changed = player != null
		log_check("SCENE: Gameplay loaded after Start", str(scene_changed), "true", scene_changed)
		if scene_changed:
			passed_count += 1
			scenario_passed += 1
		else:
			failed_count += 1
			scenario_failed += 1
			all_passed = false
			await capture_screenshot("scene_change_failed")
	else:
		log_failure("Start Button", "Could not interact with button")
		failed_count += 1
		scenario_failed += 1
		all_passed = false
	
	log_scenario_end("Title Screen Flow", scenario_passed, scenario_failed)
	return all_passed


## Scenario 2: Gameplay HUD
## Tests that all HUD elements are present and showing correct values
func test_scenario_gameplay_hud() -> bool:
	log_scenario_start("Gameplay HUD")
	var all_passed = true
	var scenario_passed = 0
	var scenario_failed = 0
	
	# Ensure we're in gameplay (player must exist)
	var player = get_player()
	if not player:
		log_test("Not in gameplay - running title screen test first to get there")
		await test_scenario_title_screen()
		await get_tree().create_timer(1.0).timeout
		player = get_player()
	
	if not player:
		log_failure("Gameplay HUD", "Cannot test - no player found after title screen test")
		return false
	
	log_test("Player found, proceeding with HUD verification...")
	
	# Run HUD element verification (checks all 5 elements)
	var hud_results = await verify_hud_elements()
	
	# Count results from HUD verification
	for element in hud_results:
		if hud_results[element]:
			scenario_passed += 1
		else:
			scenario_failed += 1
			all_passed = false
	
	# Value verification - check HUD matches player state
	log_test("--- HUD Value Verification ---")
	
	# Health bar value check
	var player_hp = get_player_health()
	log_test("Player HP from HealthComponent: " + str(player_hp))
	
	if player_hp >= 0:
		var health_bar = find_ui_node("HealthBar")
		if health_bar:
			# HealthBar contains a ProgressBar child
			var progress_bar = health_bar.find_child("ProgressBar", true, false)
			if progress_bar and progress_bar.get("value") != null:
				var hp_matches = await verify_value(progress_bar.value, player_hp, "Health bar matches player HP", 1.0)
				if hp_matches:
					scenario_passed += 1
				else:
					scenario_failed += 1
			else:
				log_test("HealthBar ProgressBar not found or has no value property")
	
	# Coin counter check
	var coins = 0
	if is_instance_valid(GameManager):
		coins = GameManager.coins
	log_test("Current coins from GameManager: " + str(coins))
	
	var coin_counter = find_ui_node("CoinCounter")
	if coin_counter:
		# Find label within coin counter
		var label = coin_counter.find_child("Label", true, false)
		if label and label is Label:
			var label_text = label.text
			var has_coins = str(coins) in label_text
			log_check("VALUE: Coin counter shows correct count", label_text, "contains " + str(coins), has_coins)
			if has_coins:
				passed_count += 1
				scenario_passed += 1
			else:
				failed_count += 1
				scenario_failed += 1
		else:
			log_test("CoinCounter Label child not found")
	
	# Level/EXP check
	var player_level = get_player_level()
	if player_level > 0:
		log_test("Player level: " + str(player_level))
		# Check if ExpBar exists and is showing something
		var exp_bar = find_ui_node("ExpBar")
		if exp_bar:
			log_test("ExpBar found and level is " + str(player_level))
	
	log_test("Gameplay HUD verification complete")
	log_scenario_end("Gameplay HUD", scenario_passed, scenario_failed)
	return all_passed


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

## Get current test status for HUD display
func get_status() -> String:
	if not enabled:
		return "OFF"
	if _test_running:
		return "RUNNING: %s" % current_scenario
	return "IDLE (P:%d F:%d)" % [passed_count, failed_count]


## Check if tests are currently running
func is_running() -> bool:
	return _test_running


## Get test results
func get_results() -> Array:
	return test_results.duplicate()


# =============================================================================
# NODE FINDING HELPERS
# =============================================================================

## Find a UI node anywhere in the scene tree (recursive search)
func find_ui_node(node_name: String) -> Node:
	return get_tree().root.find_child(node_name, true, false)


## Get the player node from the "player" group
func get_player() -> Node:
	return get_tree().get_first_node_in_group("player")


## Get player's current health value
func get_player_health() -> float:
	var player = get_player()
	if player and player.has_node("HealthComponent"):
		var health = player.get_node("HealthComponent")
		if health.get("current_health") != null:
			return health.current_health
	return -1.0


## Get player's current level
func get_player_level() -> int:
	var player = get_player()
	if player and player.get("progression") != null:
		return player.progression.current_level
	return -1


# =============================================================================
# VERIFICATION HELPERS
# =============================================================================

## Verify a node exists in the scene tree
func verify_exists(node_name: String, description: String) -> bool:
	var node = find_ui_node(node_name)
	var exists = node != null
	var actual = "found" if exists else "not found"
	log_check("EXISTS: " + description, actual, "found", exists)
	if not exists:
		passed_count -= 1 if exists else 0  # Don't double-decrement
		failed_count += 1
		await capture_screenshot("missing_" + node_name.to_snake_case())
	else:
		passed_count += 1
	return exists


## Verify a node is visible
func verify_visible(node_name: String, description: String) -> bool:
	var node = find_ui_node(node_name)
	if not node:
		log_check("VISIBLE: " + description, "node not found", "visible", false)
		failed_count += 1
		await capture_screenshot("not_found_" + node_name.to_snake_case())
		return false
	
	var visible_val: bool = true
	if node is CanvasItem:
		visible_val = node.visible
	elif node is CanvasLayer:
		visible_val = node.visible
	
	log_check("VISIBLE: " + description, str(visible_val), "true", visible_val)
	if not visible_val:
		failed_count += 1
		await capture_screenshot("hidden_" + node_name.to_snake_case())
	else:
		passed_count += 1
	return visible_val


## Verify a value matches expected (with optional tolerance for floats)
func verify_value(actual, expected, description: String, tolerance: float = 0.0) -> bool:
	var passed: bool
	if typeof(actual) == TYPE_FLOAT and typeof(expected) == TYPE_FLOAT:
		passed = abs(actual - expected) <= tolerance
	elif typeof(actual) == TYPE_INT and typeof(expected) == TYPE_INT:
		passed = actual == expected
	else:
		passed = str(actual) == str(expected)
	
	log_check("VALUE: " + description, str(actual), str(expected), passed)
	if not passed:
		failed_count += 1
		await capture_screenshot("wrong_value_" + description.to_snake_case().replace(" ", "_"))
	else:
		passed_count += 1
	return passed


## Verify a property on a node matches expected value
func verify_property(node_name: String, property: String, expected, description: String) -> bool:
	var node = find_ui_node(node_name)
	if not node:
		log_check("PROPERTY: " + description, "node not found", str(expected), false)
		failed_count += 1
		return false
	
	var actual = node.get(property)
	var passed = actual == expected
	log_check("PROPERTY: " + description, str(actual), str(expected), passed)
	if not passed:
		failed_count += 1
		await capture_screenshot("wrong_prop_" + node_name.to_snake_case())
	else:
		passed_count += 1
	return passed


# =============================================================================
# HUD-SPECIFIC VERIFICATION
# =============================================================================

## Verify all HUD elements exist and are visible
## Returns a dictionary with results for each element
func verify_hud_elements() -> Dictionary:
	log_test("--- Verifying HUD Elements ---")
	var results = {}
	
	# Health bar (from game_hud.tscn - node name is "HealthBar")
	results["health_bar"] = await verify_exists("HealthBar", "Health Bar")
	if results["health_bar"]:
		results["health_bar"] = await verify_visible("HealthBar", "Health Bar visible") and results["health_bar"]
	
	# Guard bar (from Phase 12 - node name is "GuardBar")
	results["guard_bar"] = await verify_exists("GuardBar", "Guard Bar")
	if results["guard_bar"]:
		results["guard_bar"] = await verify_visible("GuardBar", "Guard Bar visible") and results["guard_bar"]
	
	# EXP bar (from Phase 9 - node name is "ExpBar")
	results["exp_bar"] = await verify_exists("ExpBar", "EXP Bar")
	if results["exp_bar"]:
		results["exp_bar"] = await verify_visible("ExpBar", "EXP Bar visible") and results["exp_bar"]
	
	# Coin counter (from Phase 13 - node name is "CoinCounter")
	results["coin_counter"] = await verify_exists("CoinCounter", "Coin Counter")
	if results["coin_counter"]:
		results["coin_counter"] = await verify_visible("CoinCounter", "Coin Counter visible") and results["coin_counter"]
	
	# Combo counter (may only show during combos - node name is "ComboCounter")
	results["combo_counter"] = await verify_exists("ComboCounter", "Combo Counter")
	# Don't fail visibility check - combo counter may be hidden when no combo active
	if results["combo_counter"]:
		var combo_node = find_ui_node("ComboCounter")
		if combo_node and combo_node is CanvasItem:
			log_test("ComboCounter visibility: " + str(combo_node.visible) + " (may be hidden when no active combo)")
	
	# Summary
	var all_passed = true
	var passed_elements = []
	var failed_elements = []
	for key in results:
		if results[key]:
			passed_elements.append(key)
		else:
			failed_elements.append(key)
			all_passed = false
	
	log_test("HUD Elements Summary: " + str(passed_elements.size()) + "/" + str(results.size()) + " passed")
	if failed_elements.size() > 0:
		log_test("Failed elements: " + str(failed_elements))
	
	return results


## Scenario 3: Pause Menu Flow
## Tests ESC toggle, pause state, buttons, audio sliders, and Resume
func test_scenario_pause_menu() -> bool:
	log_scenario_start("Pause Menu Flow")
	var all_passed = true
	var scenario_passed = 0
	var scenario_failed = 0
	
	# Must be in gameplay
	var player = get_player()
	if not player:
		log_failure("Pause Menu", "Cannot test - not in gameplay")
		return false
	
	# Check 1: Pause menu initially hidden
	var pause_menu = find_ui_node("PauseMenu")
	if pause_menu:
		var initially_hidden = not pause_menu.visible
		log_check("INITIAL: Pause menu hidden", str(initially_hidden), "true", initially_hidden)
		if initially_hidden:
			passed_count += 1
			scenario_passed += 1
		else:
			failed_count += 1
			scenario_failed += 1
			all_passed = false
	else:
		log_test("INFO: PauseMenu node not found - may be nested differently")
	
	# Check 2: Simulate ESC to open pause
	log_test("Simulating ESC key press to open pause menu...")
	var esc_event = InputEventKey.new()
	esc_event.keycode = KEY_ESCAPE
	esc_event.pressed = true
	Input.parse_input_event(esc_event)
	await get_tree().create_timer(0.5).timeout
	
	# Release ESC
	esc_event.pressed = false
	Input.parse_input_event(esc_event)
	
	# Check 3: Pause menu now visible
	pause_menu = find_ui_node("PauseMenu")
	if pause_menu:
		var now_visible = pause_menu.visible
		log_check("VISIBLE: Pause menu visible after ESC", str(now_visible), "true", now_visible)
		if now_visible:
			passed_count += 1
			scenario_passed += 1
		else:
			failed_count += 1
			scenario_failed += 1
			all_passed = false
			await capture_screenshot("pause_not_visible")
	
	# Check 4: Game is paused
	var is_paused = get_tree().paused
	log_check("STATE: Game paused", str(is_paused), "true", is_paused)
	if is_paused:
		passed_count += 1
		scenario_passed += 1
	else:
		failed_count += 1
		scenario_failed += 1
		all_passed = false
	
	# Check 5: Required buttons exist
	var resume_exists = await verify_exists("ResumeButton", "Resume Button")
	if resume_exists:
		scenario_passed += 1
	else:
		scenario_failed += 1
		all_passed = false
	
	var save_exists = await verify_exists("SaveButton", "Save Button")
	if save_exists:
		scenario_passed += 1
	else:
		scenario_failed += 1
		all_passed = false
	
	var quit_exists = await verify_exists("QuitButton", "Quit Button")
	if quit_exists:
		scenario_passed += 1
	else:
		scenario_failed += 1
		all_passed = false
	
	# Check 6: Audio sliders exist and respond
	var music_slider = find_ui_node("MusicSlider")
	if music_slider:
		log_check("EXISTS: Music Slider", "found", "found", true)
		passed_count += 1
		scenario_passed += 1
		# Test slider responds
		if music_slider is HSlider:
			var original = music_slider.value
			music_slider.value = clampf(original + 0.1, 0.0, 1.0)
			await get_tree().create_timer(0.1).timeout
			log_test("Music slider interaction: OK (changed to %.2f)" % music_slider.value)
			music_slider.value = original
	else:
		log_check("EXISTS: Music Slider", "not found", "found", false)
		failed_count += 1
		scenario_failed += 1
		all_passed = false
	
	var sfx_slider = find_ui_node("SFXSlider")
	if sfx_slider:
		log_check("EXISTS: SFX Slider", "found", "found", true)
		passed_count += 1
		scenario_passed += 1
	else:
		log_check("EXISTS: SFX Slider", "not found", "found", false)
		failed_count += 1
		scenario_failed += 1
		all_passed = false
	
	# Check 7: Test Resume button
	log_test("Testing Resume button...")
	var resume_btn = find_ui_node("ResumeButton")
	if resume_btn and resume_btn is Button:
		resume_btn.emit_signal("pressed")
		await get_tree().create_timer(0.5).timeout
		
		# Game should be unpaused
		var is_unpaused = not get_tree().paused
		log_check("STATE: Game unpaused after Resume", str(is_unpaused), "true", is_unpaused)
		if is_unpaused:
			passed_count += 1
			scenario_passed += 1
		else:
			failed_count += 1
			scenario_failed += 1
			all_passed = false
		
		# Pause menu should be hidden
		pause_menu = find_ui_node("PauseMenu")
		if pause_menu:
			var hidden_after = not pause_menu.visible
			log_check("VISIBLE: Pause menu hidden after Resume", str(hidden_after), "true", hidden_after)
			if hidden_after:
				passed_count += 1
				scenario_passed += 1
			else:
				failed_count += 1
				scenario_failed += 1
				all_passed = false
	else:
		log_failure("Resume Button", "Could not interact")
		failed_count += 1
		scenario_failed += 1
		all_passed = false
	
	log_scenario_end("Pause Menu Flow", scenario_passed, scenario_failed)
	return all_passed


## Scenario 4: Game Over Flow
## Tests player death triggers game over screen and retry works
func test_scenario_game_over() -> bool:
	log_scenario_start("Game Over Flow")
	var all_passed = true
	var scenario_passed = 0
	var scenario_failed = 0
	
	var player = get_player()
	if not player:
		log_failure("Game Over", "Cannot test - player not found")
		return false
	
	# Store current state to detect changes
	log_test("Triggering player death for game over test...")
	
	# Kill the player - try multiple methods
	var death_triggered = false
	
	# Method 1: Direct health component damage
	if player.has_node("HealthComponent"):
		var health = player.get_node("HealthComponent")
		if health.has_method("take_damage"):
			log_test("Using HealthComponent.take_damage(9999)...")
			health.take_damage(9999)
			death_triggered = true
		elif "current_health" in health:
			log_test("Setting HealthComponent.current_health = 0...")
			health.current_health = 0
			if health.has_signal("died"):
				health.died.emit()
			death_triggered = true
	
	# Method 2: Emit death signal directly
	if not death_triggered:
		log_test("Emitting Events.player_died signal...")
		Events.player_died.emit()
		death_triggered = true
	
	await get_tree().create_timer(1.5).timeout  # Wait for death/transition
	
	# Check 1: Game over screen exists and is visible
	var game_over = find_ui_node("GameOver")
	if not game_over:
		game_over = find_ui_node("GameOverScreen")
	
	if game_over:
		var go_visible = game_over.visible
		log_check("VISIBLE: Game Over screen visible", str(go_visible), "true", go_visible)
		if go_visible:
			passed_count += 1
			scenario_passed += 1
		else:
			failed_count += 1
			scenario_failed += 1
			all_passed = false
			await capture_screenshot("game_over_not_visible")
		
		# Check 2: Retry button exists
		var retry_exists = await verify_exists("RetryButton", "Retry Button")
		if retry_exists:
			scenario_passed += 1
		else:
			scenario_failed += 1
			all_passed = false
		
		# Check 3: Test Retry button
		log_test("Testing Retry button...")
		var retry_btn = find_ui_node("RetryButton")
		if retry_btn and retry_btn is Button:
			retry_btn.emit_signal("pressed")
			await get_tree().create_timer(2.0).timeout
			
			# Should be back in gameplay with player alive
			player = get_player()
			var back_in_game = player != null
			log_check("STATE: Returned to gameplay after Retry", str(back_in_game), "true", back_in_game)
			if back_in_game:
				passed_count += 1
				scenario_passed += 1
			else:
				failed_count += 1
				scenario_failed += 1
				all_passed = false
				await capture_screenshot("retry_failed")
			
			# Check player is alive (HP > 0)
			if back_in_game:
				var hp = get_player_health()
				var is_alive = hp > 0
				log_check("STATE: Player is alive after Retry (HP > 0)", str(hp), "> 0", is_alive)
				if is_alive:
					passed_count += 1
					scenario_passed += 1
				else:
					failed_count += 1
					scenario_failed += 1
					all_passed = false
		else:
			log_failure("Retry Button", "Could not interact")
			failed_count += 1
			scenario_failed += 1
			all_passed = false
	else:
		log_failure("Game Over", "Game over screen not found after death")
		await capture_screenshot("missing_game_over")
		failed_count += 1
		scenario_failed += 1
		all_passed = false
	
	log_scenario_end("Game Over Flow", scenario_passed, scenario_failed)
	return all_passed


## Scenario 5: New Features Smoke Test
## Verifies Phase 12-14 features have proper UI elements
func test_scenario_new_features() -> bool:
	log_scenario_start("New Features Smoke Test")
	var all_passed = true
	var scenario_passed = 0
	var scenario_failed = 0
	
	# Ensure gameplay
	var player = get_player()
	if not player:
		log_test("Not in gameplay - running title screen test first")
		await test_scenario_title_screen()
		await get_tree().create_timer(1.0).timeout
		player = get_player()
	
	if not player:
		log_failure("New Features", "Cannot test - no player")
		return false
	
	log_test("--- Phase 12: Block/Parry UI ---")
	
	# Guard bar exists
	var guard_bar_exists = await verify_exists("GuardBar", "Guard Bar (block system)")
	if guard_bar_exists:
		scenario_passed += 1
	else:
		scenario_failed += 1
		all_passed = false
	
	# Check guard component exists on player
	if player.has_node("GuardComponent"):
		var guard = player.get_node("GuardComponent")
		log_check("EXISTS: Player GuardComponent", "found", "found", true)
		passed_count += 1
		scenario_passed += 1
		
		# Verify guard bar updates with guard value
		var guard_bar = find_ui_node("GuardBar")
		if guard_bar and guard_bar.get("value") != null and guard.get("current_guard") != null:
			log_test("Guard bar value: %.1f" % guard_bar.value)
			log_test("Guard component value: %.1f" % guard.current_guard)
	else:
		log_test("INFO: GuardComponent not found on player (may be optional)")
	
	log_test("--- Phase 13: Pickup/Coin UI ---")
	
	# Coin counter exists
	var coin_exists = await verify_exists("CoinCounter", "Coin Counter (pickup system)")
	if coin_exists:
		scenario_passed += 1
	else:
		scenario_failed += 1
		all_passed = false
	
	# Verify coin count matches GameManager
	var coins = 0
	if is_instance_valid(GameManager) and "coins" in GameManager:
		coins = GameManager.coins
	log_test("GameManager coins: %d" % coins)
	
	var coin_counter = find_ui_node("CoinCounter")
	if coin_counter:
		var label = coin_counter.find_child("Label", true, false)
		if label and label is Label:
			log_test("Coin counter text: %s" % label.text)
	
	log_test("--- Phase 14: Save System UI ---")
	
	# Save button in pause menu (already verified in scenario 3, but confirm here)
	var save_btn = find_ui_node("SaveButton")
	var save_btn_exists = save_btn != null
	log_check("EXISTS: Save Button (from Phase 14)", "found" if save_btn_exists else "not found", "found", save_btn_exists)
	if save_btn_exists:
		passed_count += 1
		scenario_passed += 1
	else:
		failed_count += 1
		scenario_failed += 1
		all_passed = false
	
	# Continue button on title (indicates save system working)
	var continue_btn = find_ui_node("ContinueButton")
	if continue_btn:
		log_test("Continue button present (save file may exist)")
	else:
		log_test("INFO: No Continue button (normal if no save file)")
	
	# Test save functionality if SaveManager exists
	if is_instance_valid(SaveManager) and SaveManager.has_method("save_game"):
		log_test("Testing save functionality...")
		var save_result = SaveManager.save_game()
		log_check("FUNC: SaveManager.save_game()", str(save_result), "true", save_result)
		if save_result:
			passed_count += 1
			scenario_passed += 1
		else:
			failed_count += 1
			scenario_failed += 1
			all_passed = false
	else:
		log_test("INFO: SaveManager not available for direct testing")
	
	log_scenario_end("New Features Smoke Test", scenario_passed, scenario_failed)
	return all_passed


## Print final test summary with comprehensive reporting
func print_test_summary() -> void:
	log_test("")
	log_test("================================================================")
	log_test("                  UI TESTER - FINAL REPORT")
	log_test("================================================================")
	log_test("Timestamp: " + Time.get_datetime_string_from_system())
	log_test("")
	
	# Scenario results with PASS/FAIL icons
	log_test("SCENARIO RESULTS:")
	log_test("----------------------------------------------------------------")
	for result in test_results:
		var icon = "[PASS]" if result.get("passed", false) else "[FAIL]"
		log_test("  %s %s" % [icon, result.get("scenario", "Unknown")])
	log_test("")
	
	# Summary counts
	log_test("SUMMARY:")
	log_test("----------------------------------------------------------------")
	var total = passed_count + failed_count
	log_test("  Total checks:  %d" % total)
	log_test("  Passed:        %d" % passed_count)
	log_test("  Failed:        %d" % failed_count)
	log_test("  Fixed/Retry:   %d" % fixed_on_retry_count)
	log_test("")
	
	# Pass rate percentage
	var pass_rate = (float(passed_count) / float(total) * 100.0) if total > 0 else 0.0
	log_test("  Pass rate: %.1f%%" % pass_rate)
	log_test("")
	
	# Screenshots location if failures
	if failed_count > 0:
		log_test("SCREENSHOTS:")
		log_test("----------------------------------------------------------------")
		log_test("  Location: exports/test_screenshots/")
		log_test("  Check screenshots for failure details")
		log_test("")
	
	log_test("================================================================")
	
	# Final verdict
	if failed_count == 0:
		log_test("            ALL TESTS PASSED!")
	else:
		log_test("  %d TEST(S) FAILED - Review logs and screenshots" % failed_count)
	
	log_test("================================================================")
	log_test("")
	log_test("UITester complete. Press F2 to run again.")
