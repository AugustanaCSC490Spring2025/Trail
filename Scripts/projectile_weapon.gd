extends Node2D

var mouse_position =  null
var side = true
@onready var bullet = preload("res://Scenes/Weapons/Projectiles/bullet.tscn")
@onready var weapon_tip = $RayCast2D/Tip
@onready var pointing_tip = $RayCast2D
@onready var pivot_point = $"."
@onready var sprite = $Sprite2D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()
	mouse_position = get_global_mouse_position()
	pivot_point.look_at(mouse_position)
	if((pivot_point.global_position.x > mouse_position.x && side) || (pivot_point.global_position.x < mouse_position.x && !side)):
		side = !side
		flip()
		
	#weapon_tip.position = mouse_position
	#pointing_tip.target_position = mouse_position

func flip():
	sprite.scale.y *= -1
	sprite.position.y *= -1

func shoot():
	var shot = bullet.instantiate()
	owner.add_child(shot)
	shot.global_position = pivot_point.global_position
	shot.look_at(mouse_position)
