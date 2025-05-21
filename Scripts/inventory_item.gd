extends Node2D

@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""
@export var item_duration = 0
@export var item_rate_of_fire = 0
@export var item_weapon_scale = 0
@export var item_weapon_rotation = 0
@export var item_weapon_position = 0

var scene_path: String = "res://Scenes/Inventory/Inventory_Item.tscn"

@onready var icon_sprite = $Sprite2D
@onready var collision_shape = $Area2D/CollisionShape2D
var player_in_range = false
var interacting_player_id: int = -1

func _ready():
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	collision_shape.scale *=3

func _process(_delta):
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture

	if player_in_range and Input.is_action_just_pressed("ui_add"):
		pickup_item()

#  Local client picks up item, informs server
func pickup_item():
	var item = {
		"quantity": 1,
		"type": item_type,
		"name": item_name,
		"effect": item_effect,
		"texture": item_texture,
		"duration": item_duration,
		"scene_path": scene_path,
		"rate_of_fire": item_rate_of_fire,
		"weapon_scale": item_weapon_scale,
		"weapon_position": item_weapon_position,
		"weapon_rotation": item_weapon_rotation
	}
	# Add item to local player's inventory only
	if Global.player_node:
		print("Add")
		Global.add_item(item, true)
	print(item)
	# Ask server to remove this item
	#request_item_removal()
	remove_item_local.rpc()
# Server receives pickup request and broadcasts removal

func request_item_removal():
	# Tell all clients to remove the item
	queue_free()
	#set_multiplayer_authority(1)
	#rpc("remove_item_local")
	

@rpc("authority", "call_local", "reliable")
func remove_item_local():
	queue_free()
	remove_item_everywhere.rpc()
# This runs on all clients and the server
@rpc("any_peer", "call_remote" ,"reliable")
func remove_item_everywhere():
	queue_free()

#  Player enters item pickup area
func _on_area_2d_body_entered(body):
	if body.is_in_group("Players"): 
	#and Global.player_node.playerID == multiplayer.get_unique_id():
		player_in_range = true
		interacting_player_id = body.playerID
		body.interact_ui.visible = true

#  Player exits item pickup area
func _on_area_2d_body_exited(body):
	if body.is_in_group("Players"):
		 #and Global.player_node.playerID == multiplayer.get_unique_id():
		player_in_range = false
		interacting_player_id = -1
		body.interact_ui.visible = false

		
# Set the items values for spawning
func initiate_items(type, name, effect, texture, duration):
	item_type = type
	item_name = name
	item_effect = effect
	item_texture = texture
	item_duration = duration
	
# Sets the item's dictionary data
func set_item_data(data):
	item_type = data["type"]
	item_name = data["name"]
	item_effect = data["effect"]
	item_texture = data["texture"]
	item_duration = data["duration"]
	item_rate_of_fire = data["rate_of_fire"]
	item_weapon_scale = data["weapon_scale"]
	item_weapon_rotation = data["weapon_rotation"]
	item_weapon_position = data["weapon_position"]
	
#"rate_of_fire": .8,
	#"weapon_scale": Vector2(0.1, 0.1),
	#"weapon_rotation": 45,
	#"weapon_position": Vector2(17, 3.5)
