extends CharacterBody2D

#https://www.youtube.com/watch?v=AGHtw8__oqw
#^^ nav agent tutorial based on to start with

@export var facing = ""
@export var attacking = false
@export var hunting = false
@export var target = 0
@onready var sprite = $AnimatedSprite2D
@onready var bite_hitbox = preload("res://Scenes/Enemies/BiteHitbox.tscn")
@onready var attack = $Attack

@export var speed = 300
var accel = 2

@onready var wolf_detection_radius = $Area2D
@onready var nav_agent = $NavigationAgent2D

func _ready() -> void:
	pass
	#global_position = Vector2(350, 350)

func _physics_process(delta: float) -> void:
	var direction = Vector2()
	if hunting and not attacking:
		#print(str(global_position.distance_squared_to(target.global_position)))
		var target_location = target.global_position
		nav_agent.target_position = target_location
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		velocity = velocity.lerp(direction * speed, accel * delta)
			
		move_and_slide()
		animate(velocity)
		
		if global_position.distance_squared_to(target.global_position) < 1000:
			#pass
			bite(target)

func animate(velocity: Vector2):
	if -50 < velocity.x and velocity.x < 50:
		if velocity.y > 0:
			sprite.play("walk_down")
			facing = "down"
		else:
			sprite.play("walk_up")
			facing = "up"
	else:
		sprite.play("walk_side")
		if velocity.x > 0:
			sprite.flip_h = true
			facing = "right"
		else:
			sprite.flip_h = false
			facing = "left"

func bite(target: Node2D):
	attacking = true
	if facing == "up":
		sprite.play("attack_up")
	if facing == "down":
		sprite.play("attack_down")
	if facing == "right":
		sprite.flip_h = true
		sprite.play("attack_side")
	if facing == "left":
		sprite.flip_h = false
		sprite.play("attack_side")
	var attack_point = target.global_position
	await get_tree().create_timer(0.5).timeout
	for hitbox in attack.get_children():
		hitbox.queue_free()
	var bite_attack = bite_hitbox.instantiate()
	attack.add_child(bite_attack, true)
	bite_attack.set_global_position(attack_point)
	attacking = false

@rpc("authority", "call_local", "reliable")
func wolf_die():
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		#print("began hunting")
		target = body
		hunting = true
