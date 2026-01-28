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
	log_test("Starting test suite...")
	
	# Placeholder: In subsequent plans, these will be implemented
	# Scenario 1: HUD Display Tests
	# Scenario 2: Menu Navigation Tests
	# Scenario 3: Save/Load UI Tests
	# Scenario 4: Combat UI Tests
	# Scenario 5: Zone Transition Tests
	
	# For now, run a simple self-test to verify the framework works
	await _run_framework_self_test()
	
	# Log final summary
	log_summary()
	
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
	
	log_scenario_end("Framework Self-Test", scenario_passed, scenario_failed)


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
	var dir = DirAccess.open("res://")
	if dir:
		if not dir.dir_exists("exports"):
			dir.make_dir("exports")
		if not dir.dir_exists("exports/test_screenshots"):
			dir.make_dir("exports/test_screenshots")
	
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
