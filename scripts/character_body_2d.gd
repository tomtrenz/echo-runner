extends CharacterBody2D

class_name Player

var speed = 250
var gravity = 12
var jump = 250
var health: int = 3
var can_take_damage: bool = true

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("left","right")
	#print(direction)
	
	if direction:
		velocity.x = direction*speed
		if is_on_floor():
			$AnimatedSprite2D.play("run")
	else:
		velocity.x = 0
		if is_on_floor():
			$AnimatedSprite2D.play("idle")
	#print(velocity.x)
	
	if direction >0:
		$AnimatedSprite2D.flip_h = false
	elif direction <0:
		$AnimatedSprite2D.flip_h = true
	
	# pokud je na podlozce, velocity se sama nastavi na 0 fyzikou	
	if not is_on_floor():
		velocity.y += gravity

		var target_rotation = clamp(
			velocity.y / 600.0 * 15.0,
			-15.0,
			15.0
		)

		$AnimatedSprite2D.rotation_degrees = lerp(
			$AnimatedSprite2D.rotation_degrees,
			target_rotation,
			8.0 * delta
		)
	else:
		$AnimatedSprite2D.rotation_degrees = lerp(
			$AnimatedSprite2D.rotation_degrees,
			0.0,
			10.0 * delta
		)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jump 
		$AnimatedSprite2D.play("jump")
	
	move_and_slide()
	
func take_damage(amount: int, enemy_position: Vector2) -> void:

	if not can_take_damage:
		return
	can_take_damage = false
	health -= amount
	print("Životy: ", health)
	emit_signal("update_score",health)
	var knockback_direction: float = signf(
		global_position.x - enemy_position.x
	)
	if knockback_direction == 0.0:
		knockback_direction = 1.0
	velocity.x = 250.0 * knockback_direction
	velocity.y = -200.0
	if health <= 0:
		die()
		return
	await get_tree().create_timer(1.0).timeout
	can_take_damage = true

func die() -> void:

	print("Hráč zemřel")
	queue_free()
	
	
#manualne signal
signal update_score(new_score)
