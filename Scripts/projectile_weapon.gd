extends Node2D

var swap = true
var right = true
@onready var bullet = preload("res://Scenes/Weapons/Projectiles/bullet.tscn")
@onready var weapon_tip = $Sprite2D/Tip
@onready var pivot_point = $"."
@onready var sprite = $Sprite2D
@onready var bullets = get_parent().get_node("Bullets")
@onready var input_synchronizer = get_parent().get_node("InputSynchronizer")
@onready var multiplayer_spawner = $"../BulletSpawner"
@onready var timer = $Timer
@onready var rate_of_fire_timer = $"../RateOfFire"
@export var rate_of_fire = .1
@export var can_fire = true
var can_move = true

func _ready() -> void:
	var ar15_dict = {
	"rate_of_fire": .1,
	"weapon_sprite_path": "res://Sprites/Weapons/firearm-ocal-scalable/scalable/assault_rifle/m16.svg",
	"weapon_scale": Vector2(0.1, 0.1),
	"weapon_rotation": 45,
	"weapon_position": Vector2(15, .4)
	}
	swap_weapon(ar15_dict)

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	if (input_synchronizer.enable):
		if input_synchronizer.shoot_input and can_fire:
			rpc("shoot")
	pointGun()#.rpc()
	
			
		#weapon_tip.position = mouse_position
		#pointing_tip.target_position = mouse_position

func swap_weapon(weapon_info: Dictionary):
	rate_of_fire = weapon_info["rate_of_fire"]
	sprite.texture = load(weapon_info["weapon_sprite_path"])
	sprite.scale = weapon_info["weapon_scale"]
	sprite.rotation_degrees = weapon_info["weapon_rotation"]
	sprite.position = weapon_info["weapon_position"]

func flip():
	sprite.rotation_degrees *= -1
	sprite.scale.y *= -1
	sprite.position.y *= -1
	right = !right

@rpc("any_peer", "call_local", "reliable")
func shoot():
	can_fire =  false
	rate_of_fire_timer.start(rate_of_fire)
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
	if(swap):
		swap = false
		timer.start()
	if(pivot_point.global_position.y > input_synchronizer.mouse_position.y):
		z_index = -1
	else:
		z_index = 1
	
func _on_timer_timeout():
	if((pivot_point.global_position.x > input_synchronizer.mouse_position.x && right) || (pivot_point.global_position.x < input_synchronizer.mouse_position.x && !right)):
		flip()
	swap = true

func _on_rate_of_fire_timeout() -> void:
	can_fire = true
