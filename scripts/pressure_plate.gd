class_name PressurePlate
extends Area2D

signal pressed_changed(is_pressed: bool)

@export var inactive_color := Color(0.32, 0.36, 0.44, 1.0)
@export var active_color := Color(0.2, 0.9, 0.55, 1.0)

@onready var visual: Polygon2D = $Visual

var is_pressed: bool = false
var _runner_ids: Dictionary = {}


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("runner"):
		return

	_runner_ids[body.get_instance_id()] = true
	_set_pressed(true)


func _on_body_exited(body: Node2D) -> void:
	_runner_ids.erase(body.get_instance_id())
	_set_pressed(not _runner_ids.is_empty())


func _set_pressed(new_value: bool) -> void:
	if is_pressed == new_value:
		return

	is_pressed = new_value
	visual.color = active_color if is_pressed else inactive_color
	visual.position.y = 3.0 if is_pressed else 0.0
	pressed_changed.emit(is_pressed)

