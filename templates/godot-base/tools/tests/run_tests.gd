extends SceneTree

const TEST_JSON_PATH := "res://logs/test.json"
const DELTA := 1.0 / 60.0
const STEP_COUNT := 3

var _failures := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var game := _load_main_scene()
	if game == null:
		_finish()
		return

	_check_test_hooks(game)
	if _failures > 0:
		_finish()
		return

	game.enable_test_mode(true)
	game.force_reset_for_test(1001)

	var channels := _get_input_channels(game)
	var inputs := _empty_inputs(channels)
	for _i in range(STEP_COUNT):
		game.step_for_test(DELTA, inputs)

	var metrics: Variant = game.get_metrics()
	_assert_true(typeof(metrics) == TYPE_DICTIONARY, "get_metrics returns Dictionary")
	if typeof(metrics) == TYPE_DICTIONARY:
		var metrics_dict := metrics as Dictionary
		_assert_true(metrics_dict.has("elapsed"), "metrics include elapsed")
		_assert_true(float(metrics_dict.get("elapsed", 0.0)) > 0.0, "elapsed advances during test steps")
		_write_json(TEST_JSON_PATH, {
			"version": "1.0",
			"timestamp_utc": Time.get_datetime_string_from_system(true, true),
			"scene": "res://main.tscn",
			"step_count": STEP_COUNT,
			"input_channels": channels,
			"metrics": metrics_dict,
		})

	print("tests completed")
	_finish()

func _load_main_scene() -> Node:
	var scene := load("res://main.tscn") as PackedScene
	_assert_true(scene != null, "main.tscn loads as PackedScene")
	if scene == null:
		return null

	var game := scene.instantiate()
	_assert_true(game != null, "main.tscn instantiates")
	if game == null:
		return null

	root.add_child(game)
	return game

func _check_test_hooks(game: Node) -> void:
	var required := [
		"enable_test_mode",
		"force_reset_for_test",
		"step_for_test",
		"get_metrics",
	]
	for method_name in required:
		_assert_true(game.has_method(method_name), "test hook exists: %s" % method_name)

func _get_input_channels(game: Node) -> Array:
	if not game.has_method("get_test_input_channels"):
		return []
	var raw: Variant = game.get_test_input_channels()
	if typeof(raw) != TYPE_ARRAY:
		_fail("get_test_input_channels must return Array")
		return []
	return raw as Array

func _empty_inputs(channels: Array) -> Dictionary:
	var out := {}
	for entry in channels:
		if typeof(entry) == TYPE_DICTIONARY:
			var name := str((entry as Dictionary).get("name", "")).strip_edges()
			if name != "":
				out[name] = false
		elif typeof(entry) == TYPE_STRING:
			var name := str(entry).strip_edges()
			if name != "":
				out[name] = false
	return out

func _write_json(path: String, payload: Dictionary) -> void:
	var dir_path := path.get_base_dir()
	if dir_path != "":
		var dir_err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))
		if dir_err != OK:
			_fail("failed to create %s" % dir_path)
			return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_fail("failed to open %s for write" % path)
		return
	file.store_string(JSON.stringify(payload, "\t", false))

func _assert_true(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)

func _fail(message: String) -> void:
	_failures += 1
	printerr("assert failed: ", message)

func _finish() -> void:
	if _failures > 0:
		printerr("tests failed: ", _failures)
		quit(1)
		return
	print("tests passed")
	quit(0)
