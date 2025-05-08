extends Node

@onready var network : Network = get_node("/root/Game/Network")
var menuScene = preload("res://Scenes/Menu.tscn")
var menu
var lobbyScene = preload("res://Scenes/Lobby.tscn")
var lobby
var mapScene = preload("res://Scenes/Map.tscn")
var map
@onready var scene = $Scene

# Called when the node enters the scene tree for the first time.
func _ready():
	menu = menuScene.instantiate()
	add_child(menu, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func openLobby():
	get_node("Menu").queue_free()
	lobby = lobbyScene.instantiate()
	add_child(lobby, true)

@rpc("authority", "call_local", "reliable")
func startGame():
	get_node("Lobby").queue_free()
	map = network.map
	print("start %s" % map)
	get_node("/root/Game/Scene").add_child(map)
	#scene.add_child(map, true)

func leaveGame():
	#get_node("/root/Game/Scene/Map").queue_free()
	menu = menuScene.instantiate()
	add_child(menu, true)
	
