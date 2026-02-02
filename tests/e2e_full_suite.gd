extends Node
## Headless E2E runner for UITester scenarios.

const TIMEOUT_SECONDS: float = 90.0

func _ready() -> void:
	await get_tree().process_frame

	if not is_instance_valid(UITester):
		push_error("E2E: UITester autoload not found")
		get_tree().quit()
		return

	UITester.run_all_tests()
	await _wait_for_completion()
	get_tree().quit()

func _wait_for_completion() -> void:
	var elapsed = 0.0
	while UITester.is_running() and elapsed < TIMEOUT_SECONDS:
		await get_tree().create_timer(0.5).timeout
		elapsed += 0.5

	if UITester.is_running():
		push_error("E2E: UITester timed out after %.1fs" % TIMEOUT_SECONDS)
		return

	var results = UITester.get_results()
	print("E2E: UITester completed - scenarios: %d" % results.size())
