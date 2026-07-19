class_name Runner
extends CharacterBody2D

signal health_changed(current_health: int)

const ECHO_COLLISION_LAYER := 4
const RUNNER_COLLISION_MASK := 9

@export_category("Movement")
@export var accepts_human_input: bool = true
@export var speed: float = 250.0
@export var gravity: float = 720.0
@export var jump_velocity: float = -250.0

@export_category("Health")
@export var max_health: int = 3
@export var invulnerability_duration: float = 1.0
@export var knockback_duration: float = 0.15
@export var knockback_horizontal_speed: float = 250.0
@export var knockback_vertical_speed: float = -200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var health: int
var is_echo: bool = false
var invulnerability_time_left: float = 0.0
var knockback_time_left: float = 0.0


func _ready() -> void:
	health = max_health
	health_changed.emit(health)


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	if not accepts_human_input:
		return

	var input_frame := read_human_input()
	apply_input(input_frame, delta)


## Toto je jediná metoda, která čte fyzické ovládání. Echo ji později
## nahradí načtením RunnerInput ze záznamu.
func read_human_input() -> RunnerInput:
	var input_frame := RunnerInput.new()
	input_frame.direction = Input.get_axis("left", "right")
	input_frame.jump_pressed = Input.is_action_just_pressed("jump")
	input_frame.interact_pressed = Input.is_action_just_pressed("interact")
	return input_frame


## Provede jeden fyzikální snímek podle dodaného vstupu. Metoda sama
## nepoužívá Input, takže ji později může volat HumanController i echo.
func apply_input(input_frame: RunnerInput, delta: float) -> void:
	if knockback_time_left > 0.0:
		_apply_gravity(delta)
		_update_animation(0.0, delta)
		move_and_slide()
		return

	velocity.x = input_frame.direction * speed

	if input_frame.jump_pressed and is_on_floor():
		velocity.y = jump_velocity

	_apply_gravity(delta)
	_update_animation(input_frame.direction, delta)
	move_and_slide()


func take_damage(amount: int, enemy_position: Vector2) -> void:
	if amount <= 0 or invulnerability_time_left > 0.0:
		return

	health = maxi(health - amount, 0)
	health_changed.emit(health)

	var knockback_direction := signf(global_position.x - enemy_position.x)
	if is_zero_approx(knockback_direction):
		knockback_direction = 1.0

	velocity.x = knockback_horizontal_speed * knockback_direction
	velocity.y = knockback_vertical_speed
	knockback_time_left = knockback_duration
	invulnerability_time_left = invulnerability_duration

	if health == 0:
		die()


func die() -> void:
	queue_free()


func configure_as_echo(echo_index: int) -> void:
	is_echo = true
	accepts_human_input = false
	collision_layer = ECHO_COLLISION_LAYER
	collision_mask = RUNNER_COLLISION_MASK
	remove_from_group("player")
	add_to_group("echo")

	var echo_hue := fmod(0.52 + float(echo_index) * 0.11, 1.0)
	modulate = Color.from_hsv(echo_hue, 0.55, 1.0, 0.55)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func _update_timers(delta: float) -> void:
	invulnerability_time_left = maxf(invulnerability_time_left - delta, 0.0)
	knockback_time_left = maxf(knockback_time_left - delta, 0.0)


func _update_animation(direction: float, delta: float) -> void:
	if direction > 0.0:
		sprite.flip_h = false
	elif direction < 0.0:
		sprite.flip_h = true

	if not is_on_floor():
		_play_animation(&"jump")
		var target_rotation := clampf(velocity.y / 600.0 * 15.0, -15.0, 15.0)
		sprite.rotation_degrees = lerpf(
			sprite.rotation_degrees,
			target_rotation,
			minf(8.0 * delta, 1.0)
		)
	elif not is_zero_approx(direction):
		_play_animation(&"run")
		sprite.rotation_degrees = lerpf(
			sprite.rotation_degrees,
			0.0,
			minf(10.0 * delta, 1.0)
		)
	else:
		_play_animation(&"idle")
		sprite.rotation_degrees = lerpf(
			sprite.rotation_degrees,
			0.0,
			minf(10.0 * delta, 1.0)
		)


func _play_animation(animation_name: StringName) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)
