extends CharacterBody2D

@export var speed: float = 60.0
@export var gravity: float = 900.0
@export var attack_delay: float = 0.3

@onready var directional: Node2D = $Directional
@onready var sprite: AnimatedSprite2D = $Directional/Sprite
@onready var floor_check: RayCast2D = $Directional/FloorCheck
@onready var damage_area: Area2D = $DamageArea

var direction: float = 1.0
var is_attacking: bool = false


func _ready() -> void:
	set_direction(direction)
	sprite.play("pohyb")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_attacking:
		velocity.x = 0.0
		move_and_slide()
		return

	if is_on_floor() and not floor_check.is_colliding():
		turn_around()

	velocity.x = speed * direction
	move_and_slide()

	if is_on_floor() and is_on_wall():
		turn_around()


func set_direction(new_direction: float) -> void:
	if is_zero_approx(new_direction):
		return

	direction = signf(new_direction)
	directional.scale.x = absf(directional.scale.x) * direction


func turn_around() -> void:
	set_direction(-direction)


func _on_damage_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("runner"):
		return

	attack(body)

func attack(player: Node2D) -> void:
	if is_attacking:
		return

	is_attacking = true
	velocity.x = 0.0

	var player_offset: float = (
		player.global_position.x - damage_area.global_position.x
	)

	set_direction(player_offset)

	print(
		"Player X: ",
		player.global_position.x,
		" | Enemy center X: ",
		damage_area.global_position.x,
		" | rozdíl: ",
		player_offset,
		" | směr: ",
		direction
	)

	sprite.play("utok")

	await get_tree().create_timer(attack_delay).timeout

	if not is_instance_valid(player):
		finish_attack()
		return

	if player in damage_area.get_overlapping_bodies():
		player.take_damage(1, damage_area.global_position)

	finish_attack()



func finish_attack() -> void:
	sprite.play("pohyb")
	is_attacking = false
