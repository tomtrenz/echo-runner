extends Node2D

signal completed


func _on_goal_reached() -> void:
	completed.emit()

