extends CharacterBody2D

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

# NOTE TO SELF, EXTEND GENERIC ENEMY CLASS
@export var facing = ""
@export var attacking = false
@export var hunting = false
@export var target: CharacterBody2D
@onready var sprite = $AnimatedSprite2D
@onready var blast_hitbox = preload("res://Scenes/Enemies/blast.tscn")
@onready var attack = $Attack

@export var maxHP = 50
@export var HP = 50
@export var speed = 150
@export var attack_damage = 10
@export var attack_speed = 0.5
var accel = 2
var dead = false  # Track the death state of the wizard

@onready var player_detection_radius = $Area2D
@onready var nav_agent = $NavigationAgent2D

func _ready() -> void:
	randomize_stats()
	# global_position = Vector2(350, 350)

func randomize_stats() -> void:
	var detection_scale = randi_range(1, 2)
	player_detection_radius.scale = Vector2(detection_scale, detection_scale)
	speed = randi_range(200, 400)
	maxHP = randi_range(50, 150)
	HP = maxHP
	self.scale = Vector2(maxHP/50, maxHP/50)
	attack_damage = randi_range(10, 20)
	attack_speed = randf_range(0.2, 0.5)

func _physics_process(delta: float) -> void:
	if not dead:  # Check if the wizard is dead before doing anything
		var direction = Vector2()
		if hunting and not attacking and target != null:
			var target_location = target.global_position
			nav_agent.target_position = target_location
			direction = nav_agent.get_next_path_position() - global_position
			direction = direction.normalized()
			velocity = velocity.lerp(direction * speed, accel * delta)
			
			move_and_slide()
			animate(velocity)
		
			if global_position.distance_squared_to(target.global_position) < 60000:
				blast(target)

func animate(velocity: Vector2):
	if not dead:  # Ensure the wizard doesn't animate if dead
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

# Handle the attack animation and logic
func blast(target: Node2D):
	if not dead:  # Only allow attacking if not dead
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
		await get_tree().create_timer(attack_speed).timeout
		var blast_attack = blast_hitbox.instantiate()
		attack.add_child(blast_attack, true)
		blast_attack.set_damage(attack_damage)
		blast_attack.fire(self.global_position, target.global_position)
		attacking = false

# Death function with animation
@rpc("authority", "call_local", "reliable")
func wiz_die():
	# Set dead flag and stop further actions
	dead = true
	
	# Play death animation based on facing direction
	if facing == "up":
		sprite.play("up_death")
	elif facing == "down":
		sprite.play("down_death")
	elif facing == "right":
		sprite.flip_h = true
		sprite.play("side_death")
	elif facing == "left":
		sprite.flip_h = false
		sprite.play("side_death")
	
	# Wait for the animation to finish before freeing the wizard
	await get_tree().create_timer(0.5).timeout
	queue_free()

# Trigger hunting when the player enters the detection area
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players") and not hunting and not dead:
		print("Wizard target: " + str(body) + str(body.playerID))
		target = body
		hunting = true

# Function to handle damage and call die when HP reaches 0
@rpc("any_peer", "call_local", "reliable")
func damageEnemy(damage):
	if(Network.networkID == 1):
		if not dead:
			HP -= damage
			print(str(HP))
			if HP <= 0:
				wiz_die.rpc()
