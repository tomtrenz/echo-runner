extends CanvasLayer

const HUD_WIDTH := 225.0
const HUD_HEIGHT := 210.0
const BASE_TOP_MARGIN := 28.0
const BASE_RIGHT_MARGIN := 91.0
const MOBILE_RIGHT_MARGIN := 16.0

@onready var timer_label: Label = %TimerLabel
@onready var loop_label: Label = %LoopLabel
@onready var echo_label: Label = %EchoLabel
@onready var status_label: Label = %StatusLabel
@onready var level_label: Label = %LevelLabel
@onready var health_label: Label = %HealthLabel
@onready var score_label: Label = %ScoreLabel
@onready var finish_loop_hint: Label = %FinishLoopHint

var _mobile_layout_enabled: bool = false


func _ready() -> void:
	_mobile_layout_enabled = DisplayServer.is_touchscreen_available()
	_update_input_hint()
	get_viewport().size_changed.connect(_apply_safe_area)
	_apply_safe_area.call_deferred()


func set_mobile_layout_enabled(enabled: bool) -> void:
	_mobile_layout_enabled = enabled
	_update_input_hint()
	_apply_safe_area()


func set_time_left(seconds_left: float) -> void:
	timer_label.text = "%04.1f s" % maxf(seconds_left, 0.0)


func set_loop_number(loop_number: int) -> void:
	loop_label.text = "Kolo %d" % loop_number


func set_echo_count(echo_count: int) -> void:
	echo_label.text = "Echa: %d" % echo_count


func set_health(current_health: int) -> void:
	health_label.text = "Životy: %d" % current_health


func set_score(
	banked_score: int,
	active_score: int,
	_total_score: int
) -> void:
	if active_score > 0:
		score_label.text = "Skóre: %d (+%d)" % [banked_score, active_score]
	else:
		score_label.text = "Skóre: %d" % banked_score


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


func _apply_safe_area() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var window_size := Vector2(DisplayServer.window_get_size())
	var safe_area := DisplayServer.get_display_safe_area()
	var safe_top := 0.0
	var safe_right := 0.0

	if (
		window_size.x > 0.0
		and window_size.y > 0.0
		and safe_area.size != Vector2i.ZERO
	):
		var scale_to_viewport := Vector2(
			viewport_size.x / window_size.x,
			viewport_size.y / window_size.y
		)
		var safe_end := safe_area.position + safe_area.size
		safe_top = maxf(
			float(safe_area.position.y) * scale_to_viewport.y,
			0.0
		)
		safe_right = maxf(
			float(window_size.x - safe_end.x) * scale_to_viewport.x,
			0.0
		)

	var layout: Control = $Layout
	var right_margin := BASE_RIGHT_MARGIN
	if _mobile_layout_enabled:
		right_margin = MOBILE_RIGHT_MARGIN
	layout.offset_right = -(right_margin + safe_right)
	layout.offset_left = layout.offset_right - HUD_WIDTH
	layout.offset_top = BASE_TOP_MARGIN + safe_top
	layout.offset_bottom = layout.offset_top + HUD_HEIGHT


func _update_input_hint() -> void:
	if _mobile_layout_enabled:
		finish_loop_hint.text = "AKCE: vytvořit echo"
	else:
		finish_loop_hint.text = "E: vytvořit echo"
