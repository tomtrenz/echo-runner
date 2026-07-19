extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var loop_label: Label = %LoopLabel
@onready var echo_label: Label = %EchoLabel
@onready var status_label: Label = %StatusLabel
@onready var level_label: Label = %LevelLabel
@onready var health_label: Label = %HealthLabel


func set_time_left(seconds_left: float) -> void:
	timer_label.text = "%04.1f s" % maxf(seconds_left, 0.0)


func set_loop_number(loop_number: int) -> void:
	loop_label.text = "Kolo %d" % loop_number


func set_echo_count(echo_count: int) -> void:
	echo_label.text = "Echa: %d" % echo_count


func set_health(current_health: int) -> void:
	health_label.text = "Životy: %d" % current_health


func set_level(level_number: int, level_count: int, level_title: String) -> void:
	level_label.text = "Level %d/%d — %s" % [
		level_number,
		level_count,
		level_title,
	]


func show_level_completed() -> void:
	status_label.text = "CÍL SPLNĚN!"
	status_label.visible = true


func show_game_completed() -> void:
	status_label.text = "HRA DOKONČENA!"
	status_label.visible = true


func clear_status() -> void:
	status_label.visible = false
