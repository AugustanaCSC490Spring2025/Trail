extends Node2D

@onready var bullet = preload("res://Scenes/Weapons/Projectiles/bullet.tscn")
@onready var weapon_tip = $Sprite2D/Tip
@onready var pivot_point = $"."
@onready var sprite = $Weapon
@onready var bullets = get_parent().get_node("Bullets")
@onready var input_synchronizer = get_parent().get_node("InputSynchronizer")
@onready var flipTimer = $FlipTimer
@onready var multiplayer_spawner = $"../BulletSpawner"
@onready var rate_of_fire_timer = $Firerate
@export var rate_of_fire = .1
@export var can_fire = true
var swap = true
var right = true
var can_move = true
var weapons_dict
func _ready() -> void:
	var m16 = {
	"type": "Weapon", 
	"name": "m16", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/assault_rifle/m16.svg"),
	"rate_of_fire": .1,
	"weapon_scale": Vector2(0.1, 0.1),
	"weapon_rotation": 45,
	"weapon_position": Vector2(17, .4),
	"duration": 0
	}
	var taurus_raging_bull = {
	"type": "Weapon", 
	"name": "taurus_raging_bull", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/pistol/357_revolver.svg"),
	"rate_of_fire": 0.4,
	"weapon_scale": Vector2(0.1, 0.1),
	"weapon_rotation": 45,
	"weapon_position": Vector2(17, 3.5),
	"duration": 0
	}
	var mauser_C96 = {
	"type": "Weapon", 
	"name": "mauser_C96", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/machine_pistol/mauser_c96.svg"),
	"rate_of_fire": 0.25,
	"weapon_scale": Vector2(0.07, 0.07),
	"weapon_rotation": 25,
	"weapon_position": Vector2(15, 3.5),
	"duration": 0
	}
	var brown_bess_musket = {
	"type": "Weapon", 
	"name": "brown_bess_musket", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/rifle/musket.svg"),
	"rate_of_fire": 3,
	"weapon_scale": Vector2(0.17, 0.17),
	"weapon_rotation": 40,
	"weapon_position": Vector2(27, 2.8),
	"duration": 0
	}
	#the "double barrel shotgun" is the worst fucking pixel art gun I've seen in a while
	#YOU CANT JUST STAPLE 2 BARRELS ONTO A SINGLE BARREL SEMI AUTOMATIC SHOTGUN AND EXPECT IT TO WORK
	var double_barrel_shotgun = {
	"type": "Weapon", 
	"name": "brown_bess_musket", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/rifle/twin_barrel_shotgun.svg"),
	"rate_of_fire": 1.5,
	"weapon_scale": Vector2(0.15, 0.15),
	"weapon_rotation": 39,
	"weapon_position": Vector2(27, 4),
	"duration": 0
	}
	var winchester_1873 = {
	"type": "Weapon", 
	"name": "winchester_1873", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/rifle/lever_action_shotgun.svg"),
	"rate_of_fire": 0.5,
	"weapon_scale": Vector2(0.15, 0.15),
	"weapon_rotation": 37,
	"weapon_position": Vector2(27, 4),
	"duration": 0
	}
	var colt_peacemaker = {
	"type": "Weapon", 
	"name": "colt_peacemaker", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/pistol/colt_peacemaker.svg"),
	"rate_of_fire": 0.35,
	"weapon_scale": Vector2(0.1, 0.1),
	"weapon_rotation": 45,
	"weapon_position": Vector2(16.65, 3.4),
	"duration": 0
	}
	#Global.spawnable_items.append(m16)
	#Global.spawnable_items.append(taurus_raging_bull)
	#Global.spawnable_items.append(mauser_C96)
	#Global.spawnable_items.append(brown_bess_musket)
	#Global.spawnable_items.append(double_barrel_shotgun)
	#Global.spawnable_items.append(winchester_1873)
	weapons_dict = {
		"m16": m16,
		"taurus_raging_bull": taurus_raging_bull,
		"mauser_C96": mauser_C96,
		"brown_bess_musket": brown_bess_musket,
		"double_barrel_shotgun": double_barrel_shotgun,
		"winchester_1873": winchester_1873,
		"colt_peacemaker": colt_peacemaker
	}
	swap_weapon(colt_peacemaker)

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	if (input_synchronizer.enable):
		if input_synchronizer.shoot_input and can_fire:
			rpc("shoot")
	pointGun()
	
			
		#weapon_tip.position = mouse_position
		#pointing_tip.target_position = mouse_position

func swap_weapon(weapon_info: Dictionary):
	rate_of_fire = weapon_info["rate_of_fire"]
	sprite.texture = weapon_info["texture"]
	sprite.scale = weapon_info["weapon_scale"]
	sprite.rotation_degrees = weapon_info["weapon_rotation"]
	sprite.position = weapon_info["weapon_position"]
	if(!right):
		flip()

func flip():
	sprite.rotation_degrees *= -1
	sprite.scale.y *= -1
	sprite.position.y *= -1

@rpc("any_peer", "call_local", "reliable")
func shoot():
	can_fire = false
	rate_of_fire_timer.start(rate_of_fire)
	#print("shooting " + str(randi_range(1, 10)))
	var shot = bullet.instantiate()
	bullets.add_child(shot, true)
	shot.global_position = pivot_point.global_position
	shot.look_at(input_synchronizer.mouse_position)
	shot.fire(pivot_point.global_position, input_synchronizer.mouse_position)

func pointGun():
	#mouse_position = get_global_mouse_position()
	#print(str(multiplayer.get_unique_id()) + " " + str(input_synchronizer.get_multiplayer_authority()))
	pivot_point.look_at(input_synchronizer.mouse_position)
	if(swap):
		swap = false
		flipTimer.start()
	if(pivot_point.global_position.y > input_synchronizer.mouse_position.y):
		z_index = -1
	else:
		z_index = 1
	
func _on_timer_timeout():
	if((pivot_point.global_position.x > input_synchronizer.mouse_position.x && right) || (pivot_point.global_position.x < input_synchronizer.mouse_position.x && !right)):
		flip()
		right = !right
	swap = true

func _on_firerate_timeout():
	can_fire = true
