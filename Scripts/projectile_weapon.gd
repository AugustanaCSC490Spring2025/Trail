extends Node2D

var side = true
@onready var bullet = preload("res://Scenes/Weapons/Projectiles/bullet.tscn")
@onready var weapon_tip = $Sprite2D/Tip
@onready var pivot_point = $"."
@onready var sprite = $Sprite2D
@onready var bullets = get_parent().get_node("Bullets")
@onready var input_synchronizer = get_parent().get_node("InputSynchronizer")
@onready var multiplayer_spawner = $"../BulletSpawner"
@onready var timer = $Timer
var can_move = true

func _ready() -> void:
	pass
	#the sprite change code does not position the weapon right, needs some work
	#sprite.texture = preload("res://Sprites/Weapons/firearm-ocal-scalable/scalable/pistol/colt_peacemaker.svg")
	#sprite.scale = Vector2(0.1, 0.1)
	#sprite.rotation = 45.3
	#sprite.position = Vector2(16.675, 0.345)

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	if (input_synchronizer.enable):
		if input_synchronizer.shoot_input:
			rpc("shoot")
	pointGun()#.rpc()
	
			
		#weapon_tip.position = mouse_position
		#pointing_tip.target_position = mouse_position

func flip():
	sprite.scale.y *= -1
	sprite.position.y *= -1

@rpc("any_peer", "call_local", "reliable")
func shoot():
	#print("shooting " + str(randi_range(1, 10)))
	var shot = bullet.instantiate()
	bullets.add_child(shot, true)
	shot.global_position = pivot_point.global_position
	shot.look_at(input_synchronizer.mouse_position)
	shot.fire(pivot_point.global_position, input_synchronizer.mouse_position)

#@rpc("any_peer", "call_local", "reliable")
func pointGun():
	#mouse_position = get_global_mouse_position()
	#print(str(multiplayer.get_unique_id()) + " " + str(input_synchronizer.get_multiplayer_authority()))
	pivot_point.look_at(input_synchronizer.mouse_position)
	if((pivot_point.global_position.x > input_synchronizer.mouse_position.x && side) || (pivot_point.global_position.x < input_synchronizer.mouse_position.x && !side)):
		side = !side
		timer.start()
	if(pivot_point.global_position.y > input_synchronizer.mouse_position.y):
		z_index = -1
	else:
		z_index = 1
	
func _on_timer_timeout():
	flip()
