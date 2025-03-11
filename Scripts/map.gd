extends Node2D



@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D

var width : int = 100
var height : int =  100

var noise : Noise
var tree_noise : Noise

var water_tile_atlas = Vector2i(0,1)
var tree_atlas = Vector2i(12,2)
var tree_atlas2 = Vector2i(15,6)

#TERRAIN ARR
var sand_arr = []
var grass_arr = []
var dirt_arr = []
var cliff_arr = []

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
@onready var ground_tilemaplayer: TileMapLayer = $Ground



var random_grass_atlas_arr = [Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0)]
@onready var camera_2d = $Player/Camera2D


func _ready():
	noise = noise_texture.noise
	tree_noise = tree_noise_texture.noise
	generate_world()
	
func generate_world():
	var noise_val
	var tree_noise_val 
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			tree_noise_val = tree_noise.get_noise_2d(x,y)
			grass_arr.append(Vector2(x,y))
			ground_tilemaplayer.set_cell(Vector2(x,y), 0,random_grass_atlas_arr.pick_random())
	
	ground_tilemaplayer.set_cells_terrain_connect(grass_arr, 0,0)

func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val =camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val =camera_2d.zoom.x - 0.1
		if zoom_val == 0:
			zoom_val =camera_2d.zoom.x - 0.2
			
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
