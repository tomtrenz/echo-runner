extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var loop_label: Label = %LoopLabel
@onready var echo_label: Label = %EchoLabel


func set_time_left(seconds_left: float) -> void:
	timer_label.text = "%04.1f s" % maxf(seconds_left, 0.0)


func set_loop_number(loop_number: int) -> void:
	loop_label.text = "Kolo %d" % loop_number
	echo_label.text = "Echa: %d" % maxi(loop_number - 1, 0)
