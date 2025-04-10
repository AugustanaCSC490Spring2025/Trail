extends CharacterBody2D

@onready var player_sprite = $AnimatedSprite2D
@onready var player_facing = "down"
@onready var camera_2d = $Camera2D

const SPAWN_RADIUS: float = 100
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var username : String
@export var player_id : String

func _ready() -> void:
	_set_random_spawn_pos()
	player_sprite.play("idle_down")

func _set_random_spawn_pos() -> void:
	global_position = Vector2(-99,99
		#randf_range(-SPAWN_RADIUS, SPAWN_RADIUS),
		#randf_range(-SPAWN_RADIUS, SPAWN_RADIUS),
	)
	print(global_position)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("move up") && !Input.is_action_pressed("move down"):
		velocity.y = -1
		player_facing = "up"
	else:
		if Input.is_action_pressed("move down") && !Input.is_action_pressed("move up"):
			velocity.y = 1
			player_facing = "down"
		else:
			velocity.y = 0
	if Input.is_action_pressed("move left") && !Input.is_action_pressed("move right"):
		player_facing = "left"
		velocity.x = -1
	else:
		if Input.is_action_pressed("move right") && !Input.is_action_pressed("move left"):
			player_facing = "right"
			velocity.x = 1
		else:
			velocity.x = 0
	changeAnimation(player_facing)

func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x * 1.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x / 1.1
		if zoom_val == 0:
			zoom_val = camera_2d.zoom.x - 0.2
			
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	
func changeAnimation(facing: String):
	var idle = true
	if velocity.x == 0 && velocity.y == 0:
		idle = true
	else:
		idle = false
	if facing == "up":
		player_sprite.flip_h = false
		player_sprite.position.x = 0
		if idle:
			player_sprite.play("idle_up")
		else:
			player_sprite.play("walk_up")
	elif facing == "down":
		player_sprite.flip_h = false
		player_sprite.position.x = 0
		if idle:
			player_sprite.play("idle_down")
		else:
			player_sprite.play("walk_down")
	elif facing == "left":
		player_sprite.flip_h = true
		player_sprite.position.x = -2
		if idle:
			player_sprite.play("idle_right")
		else:
			player_sprite.play("walk_right")
	elif facing == "right":
		player_sprite.flip_h = false
		player_sprite.position.x = 0
		if idle:
			player_sprite.play("idle_right")
		else:
			player_sprite.play("walk_right")
			
	
	velocity = velocity.normalized()
	velocity.x *= SPEED
	velocity.y *= SPEED
	move_and_slide()
