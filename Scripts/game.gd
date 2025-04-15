class_name Game
extends Node

var menuScene = preload("res://Scenes/Menu.tscn")
var menu
var lobbyScene = preload("res://Scenes/Lobby.tscn")
var lobby
var mapScene = preload("res://Scenes/Map.tscn")
var map
@onready var scene = $Scene

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
	menu = menuScene.instantiate()
	add_child(menu, true)

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

func openLobby():
	get_node("Menu").queue_free()
	lobby = lobbyScene.instantiate()
	add_child(lobby, true)

func startGame():
	get_node("Lobby").queue_free()
	map = mapScene.instantiate()
	scene.add_child(map, true)