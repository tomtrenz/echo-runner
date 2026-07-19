extends Node

@export var starting_level: PackedScene

@onready var level_container: Node = $LevelContainer
@onready var loop_manager: LoopManager = $LoopManager
@onready var loop_hud: CanvasLayer = $LoopHUD

var _current_level: Node
var _is_resetting: bool = false


func _ready() -> void:
	loop_manager.loop_started.connect(loop_hud.set_loop_number)
	loop_manager.echo_count_changed.connect(loop_hud.set_echo_count)
	loop_manager.time_changed.connect(loop_hud.set_time_left)
	loop_manager.loop_finished.connect(_on_loop_finished)
	_load_level()


func _load_level() -> void:
	if starting_level == null:
		push_error("Game nemá nastavený starting_level.")
		return

	_current_level = starting_level.instantiate()
	level_container.add_child(_current_level)
	loop_hud.clear_status()

	if _current_level.has_signal("completed"):
		_current_level.connect("completed", _on_level_completed)

	var runner := _current_level.get_node_or_null("Runner") as Runner
	if runner == null:
		push_error("Level musí obsahovat uzel Runner v kořeni scény.")
		return

	loop_manager.start_loop(runner, _current_level)


func _on_loop_finished(_loop_number: int) -> void:
	if not _is_resetting:
		_reset_level.call_deferred()


func _on_level_completed() -> void:
	loop_manager.stop_loop()
	loop_hud.show_level_completed()


func _reset_level() -> void:
	if _is_resetting:
		return

	_is_resetting = true
	loop_manager.stop_loop()

	if is_instance_valid(_current_level):
		_current_level.queue_free()
		await _current_level.tree_exited

	_load_level()
	_is_resetting = false
