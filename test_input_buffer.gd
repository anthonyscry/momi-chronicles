extends SceneTree
## Test script for InputBuffer component
## Run with: godot --headless --script test_input_buffer.gd

var test_count: int = 0
var passed_count: int = 0
var failed_count: int = 0

func _init() -> void:
	print("\n=== InputBuffer Component Tests ===\n")

	test_buffer_action()
	test_consume_action()
	test_peek_action()
	test_has_buffered_action()
	test_clear_buffer()
	test_expiration()
	test_duplicate_prevention()
	test_max_buffer_size()

	print("\n=== Test Results ===")
	print("Total: %d | Passed: %d | Failed: %d" % [test_count, passed_count, failed_count])

	if failed_count == 0:
		print("\n✓ All buffer tests pass")
		quit(0)
	else:
		print("\n✗ Some tests failed")
		quit(1)

func test_buffer_action() -> void:
	print("Test: buffer_action()")
	var buffer = InputBuffer.new()

	# Test buffering an action
	buffer.buffer_action("attack")
	assert_equal(buffer.get_buffer_size(), 1, "Should have 1 buffered action")

	# Test buffering multiple actions
	buffer.buffer_action("dodge")
	buffer.buffer_action("jump")
	assert_equal(buffer.get_buffer_size(), 3, "Should have 3 buffered actions")

	buffer.free()
	print("")

func test_consume_action() -> void:
	print("Test: consume_buffered_action()")
	var buffer = InputBuffer.new()

	# Test consuming when buffer is empty
	var result = buffer.consume_buffered_action()
	assert_equal(result, "", "Should return empty string when buffer is empty")

	# Test consuming buffered actions in FIFO order
	buffer.buffer_action("attack")
	buffer.buffer_action("dodge")

	result = buffer.consume_buffered_action()
	assert_equal(result, "attack", "Should consume first buffered action")
	assert_equal(buffer.get_buffer_size(), 1, "Should have 1 action remaining")

	result = buffer.consume_buffered_action()
	assert_equal(result, "dodge", "Should consume second buffered action")
	assert_equal(buffer.get_buffer_size(), 0, "Buffer should be empty")

	buffer.free()
	print("")

func test_peek_action() -> void:
	print("Test: peek_buffered_action()")
	var buffer = InputBuffer.new()

	# Test peeking when buffer is empty
	var result = buffer.peek_buffered_action()
	assert_equal(result, "", "Should return empty string when buffer is empty")

	# Test peeking doesn't consume the action
	buffer.buffer_action("attack")
	result = buffer.peek_buffered_action()
	assert_equal(result, "attack", "Should return buffered action")
	assert_equal(buffer.get_buffer_size(), 1, "Action should still be in buffer")

	buffer.free()
	print("")

func test_has_buffered_action() -> void:
	print("Test: has_buffered_action()")
	var buffer = InputBuffer.new()

	# Test when action is not buffered
	assert_equal(buffer.has_buffered_action("attack"), false, "Should return false for unbuffered action")

	# Test when action is buffered
	buffer.buffer_action("attack")
	assert_equal(buffer.has_buffered_action("attack"), true, "Should return true for buffered action")
	assert_equal(buffer.has_buffered_action("dodge"), false, "Should return false for different action")

	buffer.free()
	print("")

func test_clear_buffer() -> void:
	print("Test: clear_buffer()")
	var buffer = InputBuffer.new()

	# Test clearing empty buffer
	buffer.clear_buffer()
	assert_equal(buffer.get_buffer_size(), 0, "Empty buffer should remain empty")

	# Test clearing non-empty buffer
	buffer.buffer_action("attack")
	buffer.buffer_action("dodge")
	buffer.clear_buffer()
	assert_equal(buffer.get_buffer_size(), 0, "Buffer should be empty after clear")

	buffer.free()
	print("")

func test_expiration() -> void:
	print("Test: Action expiration")
	var buffer = InputBuffer.new()
	buffer.buffer_window = 0.05  # 50ms for faster testing

	# Buffer an action
	buffer.buffer_action("attack")
	assert_equal(buffer.get_buffer_size(), 1, "Should have 1 buffered action")

	# Wait for expiration (need to simulate time passing)
	# In headless mode, we can't rely on actual time passing
	# So we'll test the expiration logic by directly manipulating timestamps
	if buffer._buffered_actions.size() > 0:
		buffer._buffered_actions[0].timestamp = (Time.get_ticks_msec() / 1000.0) - 0.1  # Set to 100ms ago

	# This should clear the expired action
	var result = buffer.consume_buffered_action()
	assert_equal(result, "", "Expired action should not be consumed")
	assert_equal(buffer.get_buffer_size(), 0, "Buffer should be empty after expiration")

	buffer.free()
	print("")

func test_duplicate_prevention() -> void:
	print("Test: Duplicate action prevention")
	var buffer = InputBuffer.new()

	# Try to buffer the same action twice
	buffer.buffer_action("attack")
	buffer.buffer_action("attack")
	assert_equal(buffer.get_buffer_size(), 1, "Duplicate actions should not be buffered")

	buffer.free()
	print("")

func test_max_buffer_size() -> void:
	print("Test: Max buffer size enforcement")
	var buffer = InputBuffer.new()

	# Buffer more actions than MAX_BUFFER_SIZE
	for i in range(10):
		buffer.buffer_action("action_%d" % i)

	assert_equal(buffer.get_buffer_size() <= 5, true, "Buffer size should not exceed MAX_BUFFER_SIZE")

	# The oldest action should be removed
	var has_oldest = buffer.has_buffered_action("action_0")
	assert_equal(has_oldest, false, "Oldest action should be removed when buffer is full")

	buffer.free()
	print("")

func assert_equal(actual, expected, message: String) -> void:
	test_count += 1
	if actual == expected:
		print("  ✓ PASS: %s" % message)
		passed_count += 1
	else:
		print("  ✗ FAIL: %s" % message)
		print("    Expected: %s" % str(expected))
		print("    Got: %s" % str(actual))
		failed_count += 1
