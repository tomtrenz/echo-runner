class_name PressurePlate
extends Area2D

signal pressed_changed(is_pressed: bool)

@onready var inactive_sprite: Sprite2D = $InactiveSprite
@onready var active_sprite: Sprite2D = $ActiveSprite

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
	inactive_sprite.visible = not is_pressed
	active_sprite.visible = is_pressed
	pressed_changed.emit(is_pressed)
