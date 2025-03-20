extends Node2D




@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D

var width : int = 120
var height : int =  120

var noise : Noise
var tree_noise : Noise

var water_tile_atlas = Vector2i(0,1)
var house_atlas1 = [Vector2i(1,1), Vector2i(9,1), Vector2i(20,2), Vector2i(27,1), Vector2i(34,1), Vector2i(41,1), Vector2i(1,12), Vector2i(15,11), Vector2i(22,10)]
var house_atlas2 = Vector2i(9,1)
var tree_atlas = Vector2i(12,2)
var tree_atlas2 = Vector2i(15,6)
var barrier_atlas = [Vector2i(47,23), Vector2i(41,26), Vector2i(43,26), Vector2i(41,25), Vector2i(43,25), Vector2i(41,27), Vector2i(43,27)]

#TERRAIN ARR
var sand_arr = []
var grass_arr = []
var dirt_arr = []
var building_arr = []
var tree_noise_val_arr = []
var barrier_arr = []
################################
#@onready var tile_map = $TileMap
#
##LAYERS
#var water_layer = 0
#var ground_1_layer = 1
#var ground_2_layer = 2
#var cliff_layer = 3
#var environment_layer =4
################################
@onready var grass_tilemaplayer: TileMapLayer = $Grass
@onready var dirt_tilemaplayer: TileMapLayer = $Dirt
@onready var object_tilemaplayer: TileMapLayer = $Object

var random_grass_atlas_arr = [Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0)]
@onready var camera_2d = $Player/Camera2D

func _ready():
	var rng: int = randi_range(0,100)
	noise = noise_texture.noise
	noise.set_seed(rng)
	#print("seed ", rng)
	tree_noise = tree_noise_texture.noise
	generate_world()
	
# lowest noise: -.6271
# highest noise: .4845
func generate_world():
	var noise_val
	var tree_noise_val 
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			tree_noise_val = tree_noise.get_noise_2d(x,y)
			generate_wall(x,y)
			if noise_val > -0.2:
				generate_buildings(x,y)
			grass_arr.append(Vector2(x,y))
			tree_noise_val_arr.append(tree_noise_val)
			
	#print("highest", tree_noise_val_arr.max())
	#print("lowest", tree_noise_val_arr.min())
	
	grass_tilemaplayer.set_cells_terrain_connect(grass_arr, 0,0)
	dirt_tilemaplayer.set_cells_terrain_connect(dirt_arr, 1,0)

func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x * 1.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x / 1.1
		if zoom_val == 0:
			zoom_val = camera_2d.zoom.x - 0.2
			
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
		#print(camera_2d.get_screen_center_position())
		
func generate_wall(x, y):
	var barrier_val: Vector2i
	if ((y >= -45 and y <= 45) and ((x == ((-width/2) + 15)) or (x == ((width/2) - 15)))):
		if x == -45 and y == -45:
			barrier_arr.append(Vector2(x,y))
			barrier_val = barrier_atlas[3]
		elif x == -45 and y == 45:
			barrier_arr.append(Vector2(x,y))
			barrier_val = barrier_atlas[5]
		elif x == 45 and y == -45:
			barrier_arr.append(Vector2(x,y))
			barrier_val = barrier_atlas[4]
		elif x == 45 and y == 45:
			barrier_arr.append(Vector2(x,y))
			barrier_val = barrier_atlas[6]
		elif x == 45:
			barrier_arr.append(Vector2(x,y))
			barrier_val = barrier_atlas[2]
		elif x == -45:
			barrier_arr.append(Vector2(x,y))
			barrier_val = barrier_atlas[1]
			#object_tilemaplayer.set_cell(Vector2(x,y), 0,barrier_atlas[1])
	if ((x > -45 and x < 45) and ((y == ((-height/2) + 15)) or (y == ((height/2) - 15)))):
		barrier_arr.append(Vector2(x,y))
		barrier_val = barrier_atlas[0]
		#object_tilemaplayer.set_cell(Vector2(x,y), 0,barrier_atlas[0])
	object_tilemaplayer.set_cell(Vector2(x,y), 0,barrier_val)

func generate_buildings(x,y):
	dirt_arr.append(Vector2(x,y))
	if len(building_arr) < 20: 
		var building_eligible: bool = true
		if len(building_arr) == 0:
			if ((x<-40 or x>40) or (y<-40 or y>40)):
				building_eligible = false
		else:
			for item in building_arr:
				if (item.distance_to(Vector2(x,y)) < 30 or ((x<-40 or x>40) or (y<-40 or y>40))):
					building_eligible = false
		if building_eligible == true and randi_range(1,10) == 1:
			#print("distance", Vector2(x,y))
			building_arr.append(Vector2(x,y))
			object_tilemaplayer.set_cell(Vector2(x,y), 0,house_atlas1.pick_random())
