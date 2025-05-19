extends CharacterBody2D

#https://www.youtube.com/watch?v=AGHtw8__oqw
#^^ nav agent tutorial based on to start with

@export var dead = false
@export var facing = ""
@export var attacking = false
@export var hunting = false
@export var target = 0
@onready var sprite = $AnimatedSprite2D
@onready var bite_hitbox = preload("res://Scenes/Enemies/BiteHitbox.tscn")

@export var maxHP = 50
@export var HP = 50
@export var speed = 300
@export var attack_damage = 10
var accel = 2

@onready var wolf_detection_radius = $Area2D
@onready var nav_agent = $NavigationAgent2D

func _ready() -> void:
	randomize_stats()
	pass
	#global_position = Vector2(350, 350)

func randomize_stats() -> void:
	var detection_scale = randi_range(1, 2)
	wolf_detection_radius.scale = Vector2(detection_scale, detection_scale)
	speed = randi_range(200, 400)
	maxHP = randi_range(50, 150)
	HP = maxHP
	self.scale = Vector2(maxHP/50, maxHP/50)
	attack_damage = randi_range(10, 20)

func _physics_process(delta: float) -> void:
	if not dead:
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
	if not dead:
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
	if not dead:
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
		var bite_attack = bite_hitbox.instantiate()
		#add_child(bite_attack, true)
		#bite_attack.set_global_position(attack_point)
		#bite_attack.set_damage(attack_damage)
		attacking = false

@rpc("authority", "call_local", "reliable")
func wolf_die():
	#tech debt wet code
	dead = true
	if facing == "up":
		sprite.play("die_up")
	if facing == "down":
		sprite.play("die_down")
	if facing == "right":
		sprite.flip_h = true
		sprite.play("die_side")
	if facing == "left":
		sprite.flip_h = false
		sprite.play("die_side")
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not dead:
		if body.is_in_group("Players"):
			#print("began hunting")
			target = body
			hunting = true

func damageEnemy(damage):
	if not dead:
		HP -= damage
		if(HP <= 0):
			wolf_die.rpc()
