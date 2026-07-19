class_name LoopManager
extends Node

signal loop_started(loop_number: int)
signal time_changed(seconds_left: float)
signal loop_finished(loop_number: int)

@export_range(1.0, 300.0, 1.0, "or_greater")
var loop_duration_seconds: float = 10.0

var completed_recordings: Array[Array] = []
var current_recording: Array[RunnerInput] = []
var current_tick: int = 0
var max_ticks: int = 0

var _runner: Runner
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
	_runner.apply_input(input_frame, delta)

	current_tick += 1
	time_changed.emit(get_time_left())

	if current_tick >= max_ticks:
		_finish_loop()


func start_loop(runner: Runner) -> void:
	if not is_instance_valid(runner):
		push_error("LoopManager nemůže spustit kolo bez platného Runnera.")
		return

	_runner = runner
	_runner.accepts_human_input = false
	current_recording = []
	current_tick = 0
	max_ticks = maxi(
		roundi(loop_duration_seconds * Engine.physics_ticks_per_second),
		1
	)
	_is_running = true
	set_physics_process(true)

	loop_started.emit(get_current_loop_number())
	time_changed.emit(get_time_left())


func stop_loop() -> void:
	_is_running = false
	set_physics_process(false)
	_runner = null


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

