class_name ScoreCollectible
extends Area2D

signal collected(collectible_id: StringName, points: int)

@export var collectible_id: StringName = &""
@export_range(1, 100000, 1, "or_greater") var points: int = 10

var is_collected: bool = false


func _ready() -> void:
	if collectible_id == &"":
		collectible_id = StringName(name)


func set_collected(collected_state: bool) -> void:
	is_collected = collected_state
	visible = not collected_state
	set_deferred("monitoring", not collected_state)
	set_deferred("monitorable", not collected_state)


func _on_body_entered(body: Node2D) -> void:
	var runner := body as Runner
	if runner == null or runner.is_echo or is_collected:
		return

	set_collected(true)
	collected.emit(collectible_id, points)
