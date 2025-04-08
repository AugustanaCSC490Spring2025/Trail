class_name Game
extends Node

var scenes = [preload("res://Scenes/Menu.tscn"), preload("res://Scenes/Lobby.tscn"), preload("res://Scenes/Map.tscn")]
var currentScene = scenes[0].instantiate()

var menu_scene : PackedScene = preload("res://Scenes/Menu.tscn")
var map_scene : PackedScene = preload("res://Scenes/Map.tscn")

@onready var network : Network = get_node("/root/Game/Network")

var playerScene = preload("res://Scenes/Player.tscn")
@onready var spawner = $Network/MultiplayerSpawner

var current_characters : Array = []

var players_in_game : int = 0

var menu
var map

# Called when the node enters the scene tree for the first time.
func _ready():
	menu = menu_scene.instantiate()
	map = map_scene.instantiate()
	add_child(menu)
	#im_in_game.rpc(multiplayer.get_unique_id())
# Called every frame. 'delta' is the elapsed time since the previous frame.
@rpc("authority", "call_local", "reliable")
func load_menu_scene():
	remove_child(map)
	add_child(menu)

@rpc("authority", "call_local", "reliable")
func load_map_scene():
	remove_child(menu)
	add_child(map)
	im_in_game.rpc(multiplayer.get_unique_id())

func changeScene(index):
	currentScene.queue_free()
	currentScene = scenes[index].instantiate()
	add_child(currentScene)

@rpc("any_peer", "call_local", "reliable")
func im_in_game(id: int):
	if multiplayer.is_server():
		players_in_game += 1
		if players_in_game == len(network.current_players):
			_spawn_players()

func _spawn_players():
	print("Spawn players")
	for player in network.current_players:
		_spawn_player_character(player)

#func _ready():
	#im_in_game.rpc(multiplayer.get_unique_id())
	
func _spawn_player_character(player: NetworkPlayer):
	var char = playerScene.instantiate()
	char.name = player.name
	spawner.add_child(char, true)
	current_characters.append(char)
