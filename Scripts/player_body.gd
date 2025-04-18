extends CharacterBody2D

@onready var player_sprite = $AnimatedSprite2D

@onready var camera_2d = $Camera2D
@onready var input_synchronizer = $InputSynchronizer
@onready var weapon = $"Weapon Pivot"

const SPAWN_RADIUS: float = 100
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var username : String
@export var player_facing = "down"
@export var playerID : int = 1:
	set(id):
		playerID = id
		$InputSynchronizer.set_multiplayer_authority(id)
#func _enter_tree():
	#$InputSynchronizer.set_multiplayer_authority(playerID)

func _ready() -> void:
	#if not $InputSynchronizer.is_multiplayer_authority(): return
	
	_set_random_spawn_pos()
	#camera_2d.make_current()
	player_sprite.play("idle_down")

func _set_random_spawn_pos() -> void:
	position = Vector2(randf_range(-SPAWN_RADIUS, SPAWN_RADIUS), randf_range(-SPAWN_RADIUS, SPAWN_RADIUS))
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Collided with: ", collision.get_collider().name)
	#print(global_position)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if multiplayer.is_server():
		_move(delta)
		changeAnimation.rpc(player_facing)

func _move(delta):
	if input_synchronizer.vertical_input == -1:
		player_facing = "up"
	else:
		if input_synchronizer.vertical_input == 1:
			player_facing = "down"
	if input_synchronizer.horizontal_input == -1:
		player_facing = "left"
	else:
		if input_synchronizer.horizontal_input == 1:
			player_facing = "right"
	#if(playerID != 1):
		#print(str(input_synchronizer.horizontal_input) + " " + str(input_synchronizer.vertical_input) + " " + str(input_synchronizer.shoot_input) + " " + str(playerID))
	velocity = Vector2(input_synchronizer.horizontal_input, input_synchronizer.vertical_input).normalized()
	velocity *= Vector2(SPEED, SPEED)
	#print(str(playerID) + " : " + str(velocity))
	move_and_slide()

func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x * 1.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x / 1.1
		if zoom_val == 0:
			zoom_val = camera_2d.zoom.x - 0.2
			
		camera_2d.zoom = Vector2(zoom_val, zoom_val)

@rpc("authority", "call_local", "reliable")
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

func setPlayerID(id):
	playerID = id

func enableCamera():
	if playerID == multiplayer.get_unique_id():
		camera_2d.make_current()
