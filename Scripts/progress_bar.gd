extends Control

@onready var progress_bar = $ProgressBar
var duration = 2
func _ready():
	print(duration)
	# Start the loading simulation on ready
	await simulate_loading(duration)
	queue_free()

func simulate_loading(duration: float) -> void:
	progress_bar.value = 0
	progress_bar.max_value = 100
	var delay = duration/progress_bar.max_value

	for i in range(101):
		progress_bar.value = i
		await get_tree().process_frame  # Allow UI to update
		await get_tree().create_timer(delay).timeout  # Simulate delay

	print("Loading complete.")
