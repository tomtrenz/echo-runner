extends CharacterBody2D

var speed = 250
var gravity = 12
var jump = 250

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
