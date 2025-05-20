extends Node

@onready var network : Network = get_node("/root/Game/Network")
var menuScene = preload("res://Scenes/Menu.tscn")
var menu
var lobbyScene = preload("res://Scenes/Lobby.tscn")
var lobby
var mapScene = preload("res://Scenes/Map.tscn")
var map
var syncScene = preload("res://Scenes/Sync.tscn")
var sync
var fullscreen = false

@onready var scene = $Scene
@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	menu = menuScene.instantiate()
	add_child(menu, true)
	setCamera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreen = false
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func openLobby():
	get_node("Menu").queue_free()
	lobby = lobbyScene.instantiate()
	add_child(lobby, true)

@rpc("authority", "call_local", "reliable")
func closeLobby():
	if has_node("Lobby"):
		get_node("Lobby").queue_free()

@rpc("authority", "call_local", "reliable")
func createMap():
	map = mapScene.instantiate()
	add_child(map, true)
	map.generate(getSync().getMapSeed(0))
	
func startGame():
	closeLobby.rpc()
	#createMap.rpc()
	if(network.networkID == 1):
		map.setPlayerValues()
		map.spawn_test_wolf()
	getSync().gameStarted = true
	#print(multiplayer.get_unique_id())
	#get_node("/root/Game/Scene/Map").playerSet = false
	#gameStarted = true

func joinDuringGame(id):
	closeLobby()
	joinDuringGameServer.rpc(id)
	get_node("/root/Game/Scene/Map").playerSet = false

@rpc("any_peer", "call_remote", "reliable", 1)
func joinDuringGameServer(id):
	#print("joining with map")
	for player in network.players:
		if(player.playerID == id):
			map.addPlayer(player)
	get_node("/root/Game/Scene/Map").playerSet = false

func leaveGame():
	#get_node("/root/Game/Scene/Map").queue_free()
	menu = menuScene.instantiate()
	add_child(menu, true)

func setCamera():
	camera.make_current()

func addGameSync():
	sync = syncScene.instantiate()
	scene.add_child(sync, true)

func getSync():
	return scene.get_node("Sync")

#@rpc("any_peer", "call_remote", "reliable", 1)
#func isGameStarted():
	#return gameStarted
	
