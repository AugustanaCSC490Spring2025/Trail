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

func closeLobby():
	get_node("Lobby").queue_free()

@rpc("authority", "call_local", "reliable")
func createMap():
	map = network.map
	#print("start %s" % map)
	scene.add_child(map, true)
	
@rpc("authority", "call_local", "reliable")
func startGame():
	if has_node("Lobby"):
		get_node("Lobby").queue_free()
	for player in network.players:
		map.addPlayer(player)
	print(multiplayer.get_unique_id())
	get_node("/root/Game/Scene/Map").cameraSet = false

func joinDuringGame(id):
	closeLobby()
	joinDuringGameServer.rpc(id)
	get_node("/root/Game/Scene/Map").cameraSet = false

@rpc("any_peer", "call_remote", "reliable", 1)
func joinDuringGameServer(id):
	#print("joining with map")
	for player in network.players:
		if(player.playerID == id):
			map.addPlayer(player)
	get_node("/root/Game/Scene/Map").cameraSet = false

func leaveGame():
	#get_node("/root/Game/Scene/Map").queue_free()
	menu = menuScene.instantiate()
	add_child(menu, true)
	
