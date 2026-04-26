extends Node2D

# Template stub: replace with game-specific state and systems.
const MetricsTracker = preload("res://metrics_tracker.gd")

var test_mode := false

var elapsed := 0.0
var done := false
var last_test_inputs: Dictionary = {}
var custom_metrics: Dictionary = {}

func _ready() -> void:
	_reset_game()

func _physics_process(delta: float) -> void:
	if test_mode:
		return
	_simulate_frame(delta)

func _simulate_frame(delta: float) -> void:
	if done:
		return
	elapsed += delta

func _reset_game() -> void:
	elapsed = 0.0
	done = false
	last_test_inputs.clear()
	custom_metrics = MetricsTracker.reset_custom_metrics()

# --- test hooks (interface stub for agents) ---
func enable_test_mode(enabled: bool) -> void:
	test_mode = enabled

func force_reset_for_test(test_seed: int) -> void:
	seed(test_seed)
	_reset_game()

func step_for_test(delta: float, inputs: Dictionary) -> void:
	last_test_inputs = inputs.duplicate(true)
	_simulate_frame(delta)

func get_metrics() -> Dictionary:
	return {
		"elapsed": elapsed,
		"done": done,
		"last_test_inputs": last_test_inputs.duplicate(true),
		"custom_metrics": custom_metrics.duplicate(true),
	}

func step_for_test_dict(delta: float, inputs: Dictionary) -> void:
	step_for_test(delta, inputs)

func get_test_input_channels() -> Array:
	return []
