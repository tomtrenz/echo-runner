class_name BaseLevel
extends Node2D

signal completed
signal collectible_collected(collectible_id: StringName, points: int)

@export_category("Level")
@export var level_number: int = 1
@export var level_title: String = "Echo Runner"
@export var background_color := Color(0.08, 0.12, 0.18, 1.0)

@export_category("Loop")
@export_range(0, 10, 1, "or_greater") var max_echoes: int = 1
@export_range(1.0, 300.0, 1.0, "or_greater")
var loop_duration_seconds: float = 10.0

@onready var runner_spawn: Marker2D = $RunnerSpawn
@onready var echo_spawn: Marker2D = $EchoSpawn
@onready var actors: Node2D = $Actors
@onready var collectibles: Node2D = $Collectibles
@onready var goal: LevelGoal = $Goal


func _ready() -> void:
	$BackgroundColor.color = background_color
	goal.reached.connect(_on_goal_reached)
	for child: Node in collectibles.get_children():
		if child.has_signal(&"collected") and child.has_method(&"set_collected"):
			child.connect(&"collected", _on_collectible_collected)


func get_runner_spawn_transform() -> Transform2D:
	return runner_spawn.global_transform


func get_echo_spawn_transform() -> Transform2D:
	return echo_spawn.global_transform


func apply_collectible_state(active_collectibles: Dictionary) -> void:
	for child: Node in collectibles.get_children():
		if child.has_method(&"set_collected"):
			child.call(
				&"set_collected",
				active_collectibles.has(child.get(&"collectible_id"))
			)


func _on_collectible_collected(collectible_id: StringName, points: int) -> void:
	collectible_collected.emit(collectible_id, points)


func _on_goal_reached() -> void:
	completed.emit()
