class_name EchoDoor
extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var closed_visual: Node2D = $ClosedVisual
@onready var open_visual: Node2D = $OpenVisual

var is_open: bool = false


func set_open(new_value: bool) -> void:
	if is_open == new_value:
		return

	is_open = new_value
	collision_shape.set_deferred("disabled", is_open)
	closed_visual.visible = not is_open
	open_visual.visible = is_open
	open_visual.position.y = -10.0 if is_open else 0.0
