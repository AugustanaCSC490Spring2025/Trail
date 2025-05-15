extends CharacterBody2D

#NOTE TO SELF, EXTEND GENERIC ENEMY CLASS
@export var facing = ""
@export var attacking = false
@export var hunting = false
@export var target = 0
@onready var sprite = $AnimatedSprite2D
@onready var blast_hitbox = preload("res://Scenes/Enemies/blast.tscn")
@onready var attack = $Attack

@export var maxHP = 50
@export var HP = 50
@export var speed = 150
var accel = 2

@onready var player_detection_radius = $Area2D
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
		
		if global_position.distance_squared_to(target.global_position) < 60000:
			#pass
			blast(target)

func animate(velocity: Vector2):
	if -50 < velocity.x and velocity.x < 50:
		if velocity.y > 0:
			sprite.play("down_fly")
			facing = "down"
		else:
			sprite.play("up_fly")
			facing = "up"
	else:
		sprite.play("side_fly")
		if velocity.x > 0:
			sprite.flip_h = true
			facing = "right"
		else:
			sprite.flip_h = false
			facing = "left"

#fuck this code is straight slop lol
func blast(target: Node2D):
	attacking = true
	if facing == "up":
		sprite.play("up_attack")
	if facing == "down":
		sprite.play("down_attack")
	if facing == "right":
		sprite.flip_h = true
		sprite.play("side_attack")
	if facing == "left":
		sprite.flip_h = false
		sprite.play("side_attack")
	var attack_point = target.global_position
	await get_tree().create_timer(0.5).timeout
	var blast_attack = blast_hitbox.instantiate()
	attack.add_child(blast_attack, true)
	blast_attack.fire(self.global_position, target.global_position)
	attacking = false

@rpc("authority", "call_local", "reliable")
func wiz_die():
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		#print("began hunting")
		target = body
		hunting = true

func damageEnemy(damage):
	HP -= damage
	print(str(HP))
	if(HP <= 0):
		wiz_die.rpc()
