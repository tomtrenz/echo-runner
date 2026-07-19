extends Label


func _on_runner_health_changed(current_health: int) -> void:
	text = str(current_health)
