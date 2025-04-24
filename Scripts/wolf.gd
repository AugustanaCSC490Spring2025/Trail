extends CharacterBody2D

#https://www.youtube.com/watch?v=AGHtw8__oqw
#^^ nav agent tutorial based on to start with

var hunting = false
var target
@onready var sprite = $AnimatedSprite2D

@export var speed = 300
var accel = 7

@onready var wolf_detection_radius = $Area2D
@onready var nav_agent = $NavigationAgent2D

func _ready() -> void:
	global_position = Vector2(350, 350)

func _physics_process(delta: float) -> void:
	var direction = Vector2()
	if hunting:
		var target_location = target.global_position
		nav_agent.target_position = target_location
		#print(nav_agent.target_position)
		#global_position = nav_agent.get_next_path_position()
		#print(nav_agent.get_next_path_position())
		direction = nav_agent.get_next_path_position() - global_position
		##print(direction)
		direction = direction.normalized()
		#print(direction)
		##velocity = Vector2(speed, speed)
		velocity = velocity.lerp(direction * speed, accel * delta)
		#print(velocity)
		
		move_and_slide()
		animate(velocity)

func animate(velocity: Vector2):
	if -50 < velocity.x and velocity.x < 50:
		if velocity.y > 0:
			sprite.play("walk_down")
		else:
			sprite.play("walk_up")
	else:
		sprite.play("walk_side")
		if velocity.x > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func bite():
	pass

func die():
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		print("began hunting")
		target = body
		hunting = true
