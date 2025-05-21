### Global.gd

extends Node

# Scene and node references
@onready var inventory_slot_scene = preload("res://Scenes/Inventory/Inventory_Slot.tscn")
var player_node: Node = null
# Inventory items
var inventory = []
var spawnable_items = [
	{"type": "Consumable",
	"name": "Berry",
	"effect": "Health",
	"texture": preload("res://Sprites/Icons/icon31.png"),
	"duration": 3},
	
	{"type": "Consumable",
	"name": "Water",
	"effect": "Stamina",
	"texture": preload("res://Sprites/Icons/icon9.png"),
	"duration": 2},
	
	{"type": "Consumable",
	"name": "Mushroom",
	"effect": "Armor",
	"texture": preload("res://Sprites/Icons/icon32.png"),
	"duration": 4},
	
	{"type": "Consumable",
	"name": "Roids",
	"effect": "Brawn",
	"texture": preload("res://Sprites/Icons/icon4.png"),
	"duration": 4},
	
	{"type": "Weapon", 
	"name": "m16", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/assault_rifle/m16.svg"),
	"rate_of_fire": 0.1,
	"weapon_scale": Vector2(0.1, 0.1),
	"weapon_rotation": 45,
	"weapon_position": Vector2(27, .4),
	"duration": 0},
	
	{"type": "Weapon", 
	"name": "taurus_raging_bull", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/pistol/357_revolver.svg"),
	"rate_of_fire": 0.4,
	"weapon_scale": Vector2(0.1, 0.1),
	"weapon_rotation": 45,
	"weapon_position": Vector2(17, 3.5),
	"duration": 0},
	
	{"type": "Weapon", 
	"name": "mauser_C96", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/machine_pistol/mauser_c96.svg"),
	"rate_of_fire": 0.25,
	"weapon_scale": Vector2(0.07, 0.07),
	"weapon_rotation": 25,
	"weapon_position": Vector2(15, 3.5),
	"duration": 0},
	
	{"type": "Weapon", 
	"name": "brown_bess_musket", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/rifle/musket.svg"),
	"rate_of_fire": 3,
	"weapon_scale": Vector2(0.17, 0.17),
	"weapon_rotation": 40,
	"weapon_position": Vector2(27, 2.8),
	"duration": 0},
	
	{"type": "Weapon", 
	"name": "brown_bess_musket", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/rifle/twin_barrel_shotgun.svg"),
	"rate_of_fire": 1.5,
	"weapon_scale": Vector2(0.15, 0.15),
	"weapon_rotation": 39,
	"weapon_position": Vector2(27, 4),
	"duration": 0},
	
	{"type": "Weapon", 
	"name": "winchester_1873", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/rifle/lever_action_shotgun.svg"),
	"rate_of_fire": 0.5,
	"weapon_scale": Vector2(0.15, 0.15),
	"weapon_rotation": 37,
	"weapon_position": Vector2(27, 4),
	"duration": 0},
	
	{"type": "Weapon", 
	"name": "colt_peacemaker", 
	"effect": "Gun", 
	"texture": load("res://Sprites/Weapons/firearm-ocal-scalable/scalable/pistol/colt_peacemaker.svg"),
	"rate_of_fire": 0.35,
	"weapon_scale": Vector2(0.1, 0.1),
	"weapon_rotation": 45,
	"weapon_position": Vector2(16.65, 3.4),
	"duration": 0}
]
# Custom signals
signal inventory_updated

# Hotbar items
var hotbar_size = 5 
var hotbar_inventory = []

func _ready(): 
	# Initializes the inventory with 30 slots (spread over 9 blocks per row)
	inventory.resize(30) 
	# Hotbar size
	hotbar_inventory.resize(hotbar_size) 
	
# Sets the player reference for inventory interactions
func set_player_reference(player):
	player_node = player
	
# Adds an item to the inventory, returns true if successful
func add_item(item, to_hotbar = true):
	add_hotbar_item(item)
	inventory_updated.emit()
		

# Removes an item from the inventory based on type and effect
func remove_item(item_type, item_effect):
	# Inventory removal
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item_type and inventory[i]["effect"] == item_effect:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false

# Increase inventory size dynamically
func increase_inventory_size(extra_slots):
	inventory.resize(inventory.size() + extra_slots)
	inventory_updated.emit()

# Drops an item at a specified position, adjusting for nearby items
func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	var texture = item_data["texture"].resource_path
	item_instance.set_item_data(item_data)
	drop_position = adjust_drop_position(drop_position)
	item_instance.global_position = Vector2i(drop_position)
	#get_tree().current_scene.add_child(item_instance)
	drop_item_local(item_data, drop_position, texture)
	
@rpc("authority", "call_local" ,"reliable")
func drop_item_local(item_data, drop_position, texture):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_data["texture"] = load(texture)
	item_instance.set_item_data(item_data)
	item_instance.global_position = Vector2i(drop_position)
	get_node("/root/Game/Scene/Items").add_child(item_instance)
	drop_item_everywhere.rpc(item_data, drop_position, texture)
	
@rpc("any_peer", "call_remote" ,"reliable")
func drop_item_everywhere(item_data, drop_position, texture):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_data["texture"] = load(texture)
	item_instance.set_item_data(item_data)
	item_instance.global_position = Vector2i(drop_position)
	get_node("/root/Game/Scene/Items").add_child(item_instance)

# Adjusts the drop position to avoid overlapping with nearby items
func adjust_drop_position(position):
	var radius = 100
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			position += random_offset
			break
	return position

# Try adding to hotbar
func add_hotbar_item(item):
	for i in range(inventory.size()):
			# Check if the item exists in the inventory and matches both type and effect
		if hotbar_inventory[i] != null and hotbar_inventory[i]["name"] == item["name"] and hotbar_inventory[i]["effect"] == item["effect"]:
			hotbar_inventory[i]["quantity"] += item["quantity"]
			inventory_updated.emit()
			print("Item added", hotbar_inventory)
			return true
		elif hotbar_inventory[i] == null:
			hotbar_inventory[i] = item
			inventory_updated.emit()
			print("Item added", hotbar_inventory)
			return true
	return false

# Removes an item from the hotbar
func remove_hotbar_item(item_type, item_effect):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null and hotbar_inventory[i]["type"] == item_type and hotbar_inventory[i]["effect"] == item_effect:
			if hotbar_inventory[i]["quantity"] <= 0:
				hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

# Unassigns an item from the hotbar
func unassign_hotbar_item(item_type, item_effect):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null and hotbar_inventory[i]["type"] == item_type and hotbar_inventory[i]["effect"] == item_effect:
			hotbar_inventory[i] = null
			inventory_updated.emit()
			return true
	return false

# Prevents duplicate item assignment
func is_item_assigned_to_hotbar(item_to_check):
	return item_to_check in hotbar_inventory
	
