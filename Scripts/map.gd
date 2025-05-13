extends Node2D

@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var timer = $"Wolf Timer"
@onready var wolf = preload("res://Scenes/Enemies/wolf.tscn")
@onready var campfire = preload("res://Scenes/Campfire.tscn")
@onready var wolf_spawn_locations = $"Wolf Spawns"
@onready var Game = get_tree().get_nodes_in_group("GameManager")[0]
@onready var network = get_tree().get_nodes_in_group("GameManager")[1]

@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D

var width : int = 160
var height : int = 160

var half_width = width / 2
var half_height = height / 2

const BUILDING_TILE_SIZE = 3

var noise : Noise
var tree_noise : Noise
var grass_positions

var house_atlas1 = [Vector2i(1,1), Vector2i(9,1), Vector2i(20,2), Vector2i(27,1), Vector2i(34,1), Vector2i(41,1), Vector2i(1,12), Vector2i(15,11), Vector2i(22,10)]
var house_atlas2 = Vector2i(9,1)
var tree_atlas = Vector2i(33,29)
var tree_atlas2 = Vector2i(15,6)
var barrier_atlas = [Vector2i(47,23), Vector2i(41,26), Vector2i(43,26), Vector2i(41,25), Vector2i(43,25), Vector2i(41,27), Vector2i(43,27)]

#TERRAIN ARR
var sand_arr = []
var grass_arr = []
var dirt_arr = []
var building_arr = []
var tree_noise_val_arr = []
var barrier_arr = []
var dirt_dict := {}


@onready var grass_tilemaplayer: TileMapLayer = $Grass
@onready var dirt_tilemaplayer: TileMapLayer = $Dirt
@onready var object_tilemaplayer: TileMapLayer = $Object

var random_grass_atlas_arr = [Vector2i(1,0),Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0)]
@onready var spawned_nodes = $SpawnerNodes
@export var cameraSet = false
var mapSeed = randi_range(0,100)
var rng := RandomNumberGenerator.new()
var building_rng := RandomNumberGenerator.new()
var house_atlas_rng := RandomNumberGenerator.new()
var player_spawn_rng := RandomNumberGenerator.new()
var town_width_rng := RandomNumberGenerator.new()
var town_height_rng := RandomNumberGenerator.new()
var town_size_rng := RandomNumberGenerator.new()
var road_dir_rng := RandomNumberGenerator.new()
var tree_rng := RandomNumberGenerator.new()
var towns = []
var campfire_tile_pos : Vector2i
var campfire_scene
var fire_pos = Vector2i(
	randi_range(int(-half_width) + 60, int(half_width) - 60),
	randi_range(int(-half_height) + 60, int(half_height) - 60)
)

func _ready():
	building_rng.seed = mapSeed
	house_atlas_rng.seed = mapSeed
	player_spawn_rng.seed = mapSeed
	town_width_rng.seed = mapSeed
	town_height_rng.seed = mapSeed
	town_size_rng.seed = mapSeed
	road_dir_rng.seed = mapSeed
	tree_rng.seed = mapSeed
	noise = noise_texture.noise
	noise.set_seed(mapSeed)
	tree_noise = tree_noise_texture.noise
	#print("YES")
	generate_world()
	spawn_test_wolf()
	#print("end")
	#spawn_test_wolf()
	#for player in network.players:
		#var player_body = player.getPlayerBody()
		#spawned_nodes.add_child(player_body, true)

func _process(delta):
	if not cameraSet:
		setCamera()
		cameraSet = true

func spawn_test_wolf():
	#multiplayer_spawner.add_spawnable_scene("res://Scenes/Enemies/wolf.tscn")
	var spawn_wolf = wolf.instantiate()
	
	#multiplayer_spawner.spawn()
	spawned_nodes.add_child(spawn_wolf, true)
	spawn_wolf.set_global_position(Vector2(500.0, 300.0))

#func spawn_wolves():
	#for marker in wolf_spawn_locations.get_children():
		#var random = rng.randi() % 2
		#if random == 1:
			##print(marker.name)
			#var spawn_wolf = wolf.instantiate()
			##marker.add_child(spawn_wolf, true)
	#timer.wait_time *= .9
	#if(timer.wait_time < 1):
		#timer.wait_time = 1

func generate_random_numbers(count, rand_min, rand_max):
	var numbers = []
	for i in range(count):
		var random_number = randi_range(rand_min, rand_max)
		numbers.append(random_number)
	return numbers
	
#func _process(_delta):
	#if not cameraSet:
		#setCamera()
		#cameraSet = true
# lowest noise: -.6271
# highest noise: .4845
func generate_world():
	var tree_noise_val
	var total = width * height
	grass_positions = PackedVector2Array()
	grass_positions.resize(total)
	var idx = 0
	for x in range(-half_width, half_width):
		for y in range(-half_height, half_height):
			generate_wall(x, y)
			grass_positions[idx] = Vector2(x, y)
			idx += 1
	grass_tilemaplayer.set_cells_terrain_connect(grass_positions, 0, 0)
	#for x in range(int(-half_width), int(half_width)):
		#for y in range(int(-half_height), int(half_height)):
			#tree_noise_val = tree_noise.get_noise_2d(x, y)
			#generate_wall(x, y)
			#grass_arr.append(Vector2(x, y))
			#tree_noise_val_arr.append(tree_noise_val)
	#grass_tilemaplayer.set_cells_terrain_connect(grass_arr, 0, 0)
	campfire_scene = campfire.instantiate()
	generate_campfire_location(fire_pos)
	# Add players near the campfire
	#var spawn_count = 0
	#for player in network.players:
		#addPlayer(player)
	# Generate a few random towns within bounds
	for i in range(4):
		var town_pos = Vector2i(town_width_rng.randi_range(int(-half_width) + 30, int(half_width) - 30), town_width_rng.randi_range(int(-half_height) + 30, int(half_height) - 30))
		var size = Vector2i(town_size_rng.randi_range(10, 40), town_size_rng.randi_range(10, 40))
		generate_city_blocks(town_pos, size)
		towns.append(town_pos)
	# After all towns are placed, connect each town to the campfire
	connect_towns_and_campfire()
	dirt_tilemaplayer.set_cells_terrain_connect(dirt_arr, 1, 0)
	generate_trees()
	grass_positions.clear()
	dirt_arr.clear()


func generate_campfire_location(center: Vector2i):
	# Clear a 6x7 dirt area
	for x in range(center.x - 6, center.x + 7):
		for y in range(center.y - 6, center.y + 7):
			var pos = Vector2i(x, y)
			if (x < center.x + 3 and x > center.x - 3) and (y < center.y + 4 and y > center.y - 3):
				dirt_arr.append(pos)
				dirt_dict[pos] = true
	
	var world_position = object_tilemaplayer.map_to_local(center)
	campfire_tile_pos = center
	campfire_scene.position = world_position
	campfire_scene.get_node("CampfireSprite").play("fire")
	object_tilemaplayer.add_child(campfire_scene, true)
	var spawn_arr = [Vector2i(world_position.x-1,world_position.y),
					Vector2i(world_position.x+1,world_position.y),
					Vector2i(world_position.x,world_position.y-1),
					Vector2i(world_position.x,world_position.y+1)]
	var player_count = 0
	for player in network.players:
		var player_body = player.getPlayerBody()
		player_body.position = (spawn_arr[player_count])
		player_count+=1

func generate_road_path(start: Vector2i, end: Vector2i, dir: int) -> Array:
	var path = []
	var current = start
	while current != end:
		if is_in_bounds(current) and not building_arr.has(current):
			path.append(current)
		# Adjust the movement direction if we are about to go out of bounds
		if dir == 0:
			if current.x != end.x:
				# If moving x would go out of bounds, adjust to y direction
				if current.x < int(-half_width) or current.x > int(half_width):
					current.y += sign(end.y - current.y)
				else:
					current.x += sign(end.x - current.x)
			elif current.y != end.y:
				current.y += sign(end.y - current.y)
		else:
			if current.y != end.y:
				# If moving y would go out of bounds, adjust to x direction
				if current.y < int(-half_height) or current.y > int(half_height):
					current.x += sign(end.x - current.x)
				else:
					current.y += sign(end.y - current.y)
			elif current.x != end.x:
				current.x += sign(end.x - current.x)

		# Break if we're stuck or if the position doesn't change
		if path.size() > 1 and current == path[path.size() - 1]:
			break
	if is_in_bounds(current) and not building_arr.has(current):
		path.append(current)
	return path

func generate_trees():
	var noise_scale := .8  # Higher = less clumping
	var threshold := 0.45   # Higher = fewer trees
	var tree_positions = PackedVector2Array()
	# Pre-fill dirt lookup
	for pos in dirt_arr:
		dirt_dict[pos] = true

	# Place trees only on grass tiles not near dirt/road
	
	for pos in grass_positions:
		var center_pos = Vector2i(pos)
		var valid_pos = true
		if not dirt_dict.has(center_pos) and not building_arr.has(center_pos):
			for off_x in range (0,4):
				for off_y in range(0,6):
					var spaced_pos = Vector2i(center_pos.x + off_x, center_pos.y + off_y)
					if dirt_dict.has(spaced_pos) or building_arr.has(spaced_pos):
						valid_pos = false
		else:
			valid_pos = false
		if valid_pos == true:
			var noise_val := tree_noise.get_noise_2d(center_pos.x * noise_scale, center_pos.y * noise_scale)
			if noise_val > threshold and tree_rng.randf() < 0.5 and is_in_bounds(center_pos):  # Secondary randomness
				tree_positions.append(center_pos)
	for pos in tree_positions:
		object_tilemaplayer.set_cell(pos, 0, tree_atlas)

# Paint the road by filling the terrain
func paint_road(road_positions: Array):
	for pos in road_positions:
		if is_in_bounds(pos) and not dirt_arr.has(pos) and not building_arr.has(pos):
			dirt_arr.append(Vector2i(pos))
			dirt_dict[Vector2i(pos)] = true
			# Add road to dirt layer

func connect_towns_and_campfire():
	var road_positions = []
	# Connect each town to the campfire
	for town in towns:
		road_positions += generate_random_manhattan_road(town, campfire_tile_pos, campfire_tile_pos.x)
	# Connect each town to every other town
	for i in range(towns.size()):
		for j in range(i + 1, towns.size()):
			var town_a = towns[i]
			var town_b = towns[j]
			road_positions += generate_random_manhattan_road(town_a, town_b, town_a.x)
	# Paint the roads after generating them
	paint_road(road_positions)
func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= int(-half_width+30) and pos.x < int(half_width-30) and pos.y >= int(-half_height+30) and pos.y < int(half_height-30)
# Modified function to ensure roads stay within bounds by rerouting when necessary
func generate_random_manhattan_road(start: Vector2i, end: Vector2i, dir: int) -> Array:
	var path = []
	var current = start

	while current != end:
		if is_in_bounds(current) and not building_arr.has(current):
			path.append_array(get_3x3_area(current))

		if dir == 0:  # Prioritize horizontal movement
			if current.x != end.x:
				current.x += sign(end.x - current.x)
			elif current.y != end.y:
				current.y += sign(end.y - current.y)
		else:  # Prioritize vertical movement
			if current.y != end.y:
				current.y += sign(end.y - current.y)
			elif current.x != end.x:
				current.x += sign(end.x - current.x)

	if is_in_bounds(current) and not building_arr.has(current):
		path.append(end)

	return path


func get_3x3_area(center: Vector2i) -> Array:
	var area = []
	for dx in range(-1, 1):
		for dy in range(-1, 1):
			var pos = center + Vector2i(dx, dy)
			# Optional: Only add if within bounds
			if is_in_bounds(pos):
				area.append(pos)
	return area

func generate_city_blocks(origin: Vector2i, size: Vector2i):
	var road_positions = PackedVector2Array()
	var tile_set = object_tilemaplayer.tile_set
	var atlas_source = tile_set.get_source(0) as TileSetAtlasSource
	var first_atlas_id = house_atlas1[6]
	var region = atlas_source.get_tile_texture_region(first_atlas_id)
	var tile_size_pixels = region.size
	var tile_size_cells = tile_size_pixels / tile_set.tile_size
	#print(tile_size_cells)
	var building_size = Vector2i(int(tile_size_cells.x), int(tile_size_cells.y + 1))
	var road_width = 3
	var spacing_x = building_size.x + road_width * 2
	var spacing_y = building_size.y + road_width * 2
	var dir_seed_x = road_dir_rng.randi_range(0, 2)
	var dir_seed_y = road_dir_rng.randi_range(0, 2)
	var atlas_list = house_atlas1
	var atlas_seed = house_atlas_rng.randi_range(0, 8)
	var atlas_list_size = atlas_list.size()
	# Generate vertical roads
	#print("x_roads")
	for x in range(origin.x, origin.x + size.x, spacing_x):
		for offset in range(road_width):
			var start = Vector2i(x + offset, origin.y)
			var end = Vector2i(x + offset, origin.y + size.y)
			road_positions.append_array(generate_road_path(start, end, dir_seed_x))
	# Generate horizontal roads
	#print("y_roads")
	for y in range(origin.y, origin.y + size.y, spacing_y):
		for offset in range(road_width):
			var start = Vector2i(origin.x, y + offset)
			var end = Vector2i(origin.x + size.x, y + offset)
			road_positions.append_array(generate_road_path(start, end, dir_seed_y))
	# Paint the roads
	paint_road(road_positions)
	
	#print("buildings")
	# Place buildings
	for x in range(origin.x, origin.x + size.x, spacing_x):
		for y in range(origin.y, origin.y + size.y, spacing_y):
			var valid := true
			atlas_seed = house_atlas_rng.randi_range(0, 8)
			var atlas = atlas_list[atlas_seed]
			region = atlas_source.get_tile_texture_region(atlas)
			tile_size_pixels = region.size
			tile_size_cells = tile_size_pixels / tile_set.tile_size
			building_size = Vector2i(int(tile_size_cells.x+.5), int(tile_size_cells.y+.5))
			var top_left = Vector2i(x + road_width + building_size.x/2, y + road_width + building_size.y/2)
			#print(building_size)
			# Check the full building footprint
			var tmp_building_arr = []
			for bx in range(building_size.x):
				for by in range(building_size.y):
					var check_pos = top_left + Vector2i(bx, by)
					tmp_building_arr.append(check_pos)
					if not is_in_bounds(check_pos) or dirt_dict.has(check_pos):
						#print(str(check_pos))
						valid = false
						break
				if not valid:
					break

			if valid:
				var center_pos = Vector2i(top_left)
				building_arr.append(center_pos)
				building_arr += tmp_building_arr
				#print("BUILDING: "+str(center_pos) + " building size: "+ str(building_size))
				object_tilemaplayer.set_cell(center_pos, 0, atlas)
				dirt_arr.append(center_pos)
				dirt_dict[center_pos] = true  
						
func generate_wall(x, y):
	var barrier_val: Vector2i
	if x == (-half_width+20) and y == (-half_height+20):
		barrier_arr.append(Vector2(x,y))
		barrier_val = barrier_atlas[3]
	elif x == (-half_width+20) and y == (half_height-20):
		barrier_arr.append(Vector2(x,y))
		barrier_val = barrier_atlas[5]
	elif x == (half_width-20) and y == (-half_height+20):
		barrier_arr.append(Vector2(x,y))
		barrier_val = barrier_atlas[4]
	elif x == (half_width-20) and y == (half_height-20):
		barrier_arr.append(Vector2(x,y))
		barrier_val = barrier_atlas[6]
	elif x == (half_width-20) and ((y > (-half_height+20)) and (y < (half_height-20))):
		barrier_arr.append(Vector2(x,y))
		barrier_val = barrier_atlas[2]
	elif x == (-half_width+20) and ((y > (-half_height+20)) and (y < (half_height-20))):
		barrier_arr.append(Vector2(x,y))
		barrier_val = barrier_atlas[1]
		#object_tilemaplayer.set_cell(Vector2(x,y), 0,barrier_atlas[1])
	if ((x > (-half_width+20) and x < (half_width-20)) and ((y == (-half_height+20)) or (y == (half_height-20)))):
		barrier_arr.append(Vector2(x,y))
		barrier_val = barrier_atlas[0]
		#object_tilemaplayer.set_cell(Vector2(x,y), 0,barrier_atlas[0])
	if barrier_val:
		object_tilemaplayer.set_cell(Vector2(x,y), 0,barrier_val)

func addPlayer(player):
	var player_body = player.getPlayerBody()
	spawned_nodes.add_child(player_body, true)
	# Position the player near the campfire
	var offset = Vector2(player_spawn_rng.randi_range(-2, 2), player_spawn_rng.randi_range(-2, 2)) * 16  # small random spread
	player_body.position = grass_tilemaplayer.map_to_local(fire_pos) + offset
	#spawn_count+=2
	player_body.enableCamera()

#@rpc("any_peer", "call_local", "reliable")
func setCamera():
	#print(multiplayer.get_unique_id())
	for playerBody in spawned_nodes.get_children():
		if playerBody.is_in_group("Players"):
			playerBody.enableCamera()
	
