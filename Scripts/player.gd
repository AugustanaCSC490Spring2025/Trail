extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("move up") && !Input.is_action_pressed("move down"):
		velocity.y = -1
	else:
		if Input.is_action_pressed("move down") && !Input.is_action_pressed("move up"):
			velocity.y = 1
		else:
			velocity.y = 0
	if Input.is_action_pressed("move left") && !Input.is_action_pressed("move right"):
		velocity.x = -1
	else:
		if Input.is_action_pressed("move right") && !Input.is_action_pressed("move left"):
			velocity.x = 1
		else:
			velocity.x = 0
	velocity = velocity.normalized()
	velocity.x *= SPEED
	velocity.y *= SPEED
	move_and_slide()
