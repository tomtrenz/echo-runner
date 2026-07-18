extends CharacterBody2D

var speed = 250

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("left","right")
	#print(direction)
	
	if direction:
		velocity.x = direction*speed
		$AnimatedSprite2D.play("run")
	else:
		velocity.x = 0
		$AnimatedSprite2D.play("idle")
	#print(velocity.x)
	
	if direction >0:
		$AnimatedSprite2D.flip_h = false
	elif direction <0:
		$AnimatedSprite2D.flip_h = true
	
	move_and_slide()
