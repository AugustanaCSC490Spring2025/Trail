extends Node

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
	if(multiplayer.get_unique_id() == 1):
		map = mapScene.instantiate()
		scene.add_child(map, true)
	
