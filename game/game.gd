extends Node

@export var runner_scene: PackedScene
@export var levels: Array[PackedScene] = []
@export var level_transition_delay: float = 0.8

@onready var level_container: Node = $LevelContainer
@onready var loop_manager: LoopManager = $LoopManager
@onready var score_manager: ScoreManager = $ScoreManager
@onready var loop_hud: CanvasLayer = $LoopHUD

var _current_level: BaseLevel
var _current_level_index: int = 0
var _is_resetting: bool = false
var _is_transitioning: bool = false


func _ready() -> void:
	loop_manager.loop_started.connect(loop_hud.set_loop_number)
	loop_manager.echo_count_changed.connect(loop_hud.set_echo_count)
	loop_manager.time_changed.connect(loop_hud.set_time_left)
	loop_manager.loop_finished.connect(_on_loop_finished)
	loop_manager.active_collectibles_changed.connect(
		_on_active_collectibles_changed
	)
	score_manager.score_changed.connect(loop_hud.set_score)
	score_manager.reset_campaign()
	_load_level(_current_level_index, true)


func _load_level(level_index: int, clear_recordings: bool) -> void:
	if levels.is_empty():
		push_error("Game nemá nastavený seznam levelů.")
		return
	if level_index < 0 or level_index >= levels.size():
		push_error("Požadovaný level je mimo rozsah seznamu.")
		return
	if runner_scene == null:
		push_error("Game nemá nastavenou runner_scene.")
		return

	_current_level_index = level_index
	_current_level = levels[_current_level_index].instantiate() as BaseLevel
	if _current_level == null:
		push_error("Level musí dědit z BaseLevel.")
		return

	level_container.add_child(_current_level)
	loop_hud.clear_status()
	_current_level.completed.connect(_on_level_completed)
	_current_level.collectible_collected.connect(_on_collectible_collected)

	loop_manager.stop_loop()
	if clear_recordings:
		loop_manager.reset_recordings()
	loop_manager.max_echoes = _current_level.max_echoes
	loop_manager.loop_duration_seconds = _current_level.loop_duration_seconds
	_current_level.apply_collectible_state(
		loop_manager.get_active_collectibles()
	)

	var runner := runner_scene.instantiate() as Runner
	if runner == null:
		push_error("runner_scene nevytvořila uzel typu Runner.")
		return

	runner.health_changed.connect(loop_hud.set_health)
	_current_level.actors.add_child(runner)
	runner.global_transform = _current_level.get_runner_spawn_transform()

	loop_hud.set_level(
		_current_level_index + 1,
		levels.size(),
		_current_level.level_title
	)
	loop_manager.start_loop(
		runner,
		_current_level.actors,
		_current_level.get_echo_spawn_transform()
	)


func _on_loop_finished(_loop_number: int) -> void:
	if not _is_resetting and not _is_transitioning:
		_reset_level.call_deferred()


func _on_collectible_collected(
	collectible_id: StringName,
	points: int
) -> void:
	if loop_manager.register_collectible(collectible_id, points):
		return

	# Odmítnutý duplicitní sběr vrátí scénu do autoritativního stavu fronty.
	_current_level.apply_collectible_state(
		loop_manager.get_active_collectibles()
	)


func _on_active_collectibles_changed(active_collectibles: Dictionary) -> void:
	score_manager.sync_active_collectibles(active_collectibles)
	if is_instance_valid(_current_level):
		_current_level.apply_collectible_state(active_collectibles)


func _on_level_completed() -> void:
	if _is_transitioning:
		return

	_is_transitioning = true
	score_manager.commit_level_score()
	loop_manager.stop_loop()
	loop_hud.show_level_completed()

	if _current_level_index >= levels.size() - 1:
		loop_hud.show_game_completed()
		return

	await get_tree().create_timer(level_transition_delay).timeout
	await _remove_current_level()
	_load_level(_current_level_index + 1, true)
	_is_transitioning = false


func _reset_level() -> void:
	if _is_resetting:
		return

	_is_resetting = true
	loop_manager.stop_loop()
	await _remove_current_level()
	_load_level(_current_level_index, false)
	_is_resetting = false


func _remove_current_level() -> void:
	if not is_instance_valid(_current_level):
		return

	_current_level.queue_free()
	await _current_level.tree_exited
