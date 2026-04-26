extends RefCounted

# Template contract:
# - Keep the base metric helpers objective-neutral.
# - Add game-specific counters under `custom_metrics` in project code.
const CORE_METRIC_KEYS := {
	"elapsed": true,
	"done": true,
	"custom_metrics": true,
}

static func reset_custom_metrics() -> Dictionary:
	return {}

static func inc_custom_metric(custom_metrics: Dictionary, key: String, amount: int = 1) -> void:
	var metric_key := str(key)
	custom_metrics[metric_key] = int(custom_metrics.get(metric_key, 0)) + amount

static func set_custom_metric(custom_metrics: Dictionary, key: String, value: Variant) -> void:
	custom_metrics[str(key)] = value

static func append_custom_sample(custom_metrics: Dictionary, key: String, value: Variant) -> void:
	var metric_key := str(key)
	var samples: Array = custom_metrics.get(metric_key, [])
	samples.append(value)
	custom_metrics[metric_key] = samples

static func get_core_metric_keys() -> Dictionary:
	return CORE_METRIC_KEYS.duplicate(true)
