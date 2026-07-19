class_name LoopManager
extends Node

signal loop_started(loop_number: int)
signal time_changed(seconds_left: float)
signal loop_finished(loop_number: int)

@export var runner_scene: PackedScene
@export_range(1.0, 300.0, 1.0, "or_greater")
var loop_duration_seconds: float = 10.0

var completed_recordings: Array[Array] = []
var current_recording: Array[RunnerInput] = []
var current_tick: int = 0
var max_ticks: int = 0

var _runner: Runner
var _echoes: Array[Runner] = []
var _empty_input := RunnerInput.new()
var _is_running: bool = false


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not _is_running:
		return

	if not is_instance_valid(_runner):
		_finish_loop()
		return

	var input_frame := _runner.read_human_input()
	current_recording.append(input_frame)
	_play_echoes(delta)
	_runner.apply_input(input_frame, delta)

	current_tick += 1
	time_changed.emit(get_time_left())

	if current_tick >= max_ticks:
		_finish_loop()


func start_loop(runner: Runner, echo_parent: Node) -> void:
	if not is_instance_valid(runner):
		push_error("LoopManager nemůže spustit kolo bez platného Runnera.")
		return
	if not is_instance_valid(echo_parent):
		push_error("LoopManager nemůže vytvořit echa bez platného rodiče.")
		return

	_runner = runner
	_runner.accepts_human_input = false
	current_recording = []
	current_tick = 0
	max_ticks = maxi(
		roundi(loop_duration_seconds * Engine.physics_ticks_per_second),
		1
	)
	_spawn_echoes(echo_parent, _runner.global_transform)
	_is_running = true
	set_physics_process(true)

	loop_started.emit(get_current_loop_number())
	time_changed.emit(get_time_left())


func stop_loop() -> void:
	_is_running = false
	set_physics_process(false)
	_runner = null
	_echoes.clear()


func reset_recordings() -> void:
	completed_recordings.clear()
	current_recording.clear()
	current_tick = 0


func get_time_left() -> float:
	var ticks_left := maxi(max_ticks - current_tick, 0)
	return float(ticks_left) / float(Engine.physics_ticks_per_second)


func get_current_loop_number() -> int:
	return completed_recordings.size() + 1


func _finish_loop() -> void:
	if not _is_running:
		return

	_is_running = false
	set_physics_process(false)
	completed_recordings.append(current_recording.duplicate())
	time_changed.emit(0.0)
	loop_finished.emit(completed_recordings.size())


func _spawn_echoes(echo_parent: Node, spawn_transform: Transform2D) -> void:
	_echoes.clear()

	if completed_recordings.is_empty():
		return
	if runner_scene == null:
		push_error("LoopManager nemá nastavenou runner_scene pro tvorbu ech.")
		return

	for recording_index in completed_recordings.size():
		var echo := runner_scene.instantiate() as Runner
		if echo == null:
			push_error("runner_scene nevytvořila uzel typu Runner.")
			return

		echo.name = "Echo_%02d" % (recording_index + 1)
		echo_parent.add_child(echo)
		echo.global_transform = spawn_transform
		echo.configure_as_echo(recording_index)
		_echoes.append(echo)


func _play_echoes(delta: float) -> void:
	for echo_index in _echoes.size():
		var echo := _echoes[echo_index]
		if not is_instance_valid(echo):
			continue

		var recording: Array = completed_recordings[echo_index]
		var echo_input: RunnerInput = _empty_input
		if current_tick < recording.size():
			var recorded_input := recording[current_tick] as RunnerInput
			if recorded_input != null:
				echo_input = recorded_input

		echo.apply_input(echo_input, delta)
