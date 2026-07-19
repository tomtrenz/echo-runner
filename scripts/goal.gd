class_name LevelGoal
extends Area2D

signal reached

var _was_reached: bool = false


func _on_body_entered(body: Node2D) -> void:
	if _was_reached or not body.is_in_group("player"):
		return

	_was_reached = true
	reached.emit()

