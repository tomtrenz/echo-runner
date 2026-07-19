class_name EchoDoor
extends StaticBody2D

@export var closed_color := Color(0.16, 0.48, 0.78, 1.0)
@export var open_color := Color(0.35, 0.85, 1.0, 0.35)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Visual

var is_open: bool = false


func set_open(new_value: bool) -> void:
	if is_open == new_value:
		return

	is_open = new_value
	collision_shape.set_deferred("disabled", is_open)
	visual.color = open_color if is_open else closed_color
	visual.position.y = -88.0 if is_open else 0.0

