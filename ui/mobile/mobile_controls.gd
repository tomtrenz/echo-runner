class_name MobileControls
extends CanvasLayer

const CONTROL_BAR_HEIGHT := 144.0

@export_category("Testing")
@export var show_on_desktop: bool = false

@export_category("Safe layout")
@export_range(20.0, 48.0, 1.0) var side_margin: float = 24.0
@export_range(20.0, 56.0, 1.0) var bottom_margin: float = 32.0
@export_range(96.0, 160.0, 1.0) var group_height: float = 112.0

@onready var layout_root: Control = $LayoutRoot
@onready var bottom_bar: ColorRect = $LayoutRoot/BottomBar
@onready var left_group: Control = $LayoutRoot/LeftGroup
@onready var right_group: Control = $LayoutRoot/RightGroup


func _ready() -> void:
	for button: TouchScreenButton in _get_buttons():
		button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS

	var touchscreen_available := DisplayServer.is_touchscreen_available()
	visible = touchscreen_available or show_on_desktop
	if show_on_desktop and not touchscreen_available:
		Input.emulate_touch_from_mouse = true

	layout_root.resized.connect(_update_layout)
	_update_layout.call_deferred()


func _update_layout() -> void:
	var logical_size := layout_root.size
	if logical_size.x <= 0.0 or logical_size.y <= 0.0:
		return

	var safe_insets := get_safe_insets(logical_size)
	var bottom := safe_insets.w + bottom_margin
	var left := safe_insets.x + side_margin
	var right := safe_insets.z + side_margin
	var bar_height := CONTROL_BAR_HEIGHT + safe_insets.w

	bottom_bar.position = Vector2(0.0, logical_size.y - bar_height)
	bottom_bar.size = Vector2(logical_size.x, bar_height)

	left_group.position = Vector2(
		left,
		logical_size.y - bottom - group_height
	)
	right_group.position = Vector2(
		logical_size.x - right - right_group.size.x,
		logical_size.y - bottom - group_height
	)


## Vrací safe-area insety v logických souřadnicích Controlu:
## left, top, right, bottom.
func get_safe_insets(logical_size: Vector2) -> Vector4:
	var window_size := Vector2(DisplayServer.window_get_size())
	var safe_area := DisplayServer.get_display_safe_area()
	if window_size.x <= 0.0 or window_size.y <= 0.0 or safe_area.size == Vector2i.ZERO:
		return Vector4.ZERO

	var scale_to_logical := Vector2(
		logical_size.x / window_size.x,
		logical_size.y / window_size.y
	)
	var safe_end := safe_area.position + safe_area.size
	return Vector4(
		maxf(float(safe_area.position.x) * scale_to_logical.x, 0.0),
		maxf(float(safe_area.position.y) * scale_to_logical.y, 0.0),
		maxf(float(window_size.x - safe_end.x) * scale_to_logical.x, 0.0),
		maxf(float(window_size.y - safe_end.y) * scale_to_logical.y, 0.0)
	)


func _get_buttons() -> Array[TouchScreenButton]:
	return [
		$LayoutRoot/LeftGroup/LeftButton,
		$LayoutRoot/LeftGroup/RightButton,
		$LayoutRoot/RightGroup/ActionButton,
		$LayoutRoot/RightGroup/JumpButton,
	]
