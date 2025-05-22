extends Node

@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")
var menuScene = preload("res://Scenes/Menu.tscn")
var menu
var lobbyScene = preload("res://Scenes/Lobby.tscn")
var lobby
var mapScene = preload("res://Scenes/Map.tscn")
var map
var syncScene = preload("res://Scenes/Sync.tscn")
var sync
var transitionScene = preload("res://Scenes/Transition.tscn")
var transition
var fullscreen = false

@onready var scene = $Scene
@onready var camera = $Camera2D
@onready var timer = $Timer

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
	timer.start(3)
	
func startGame():
	closeLobby.rpc()
	openMap()
	getSync().gameStarted = true
	#print(multiplayer.get_unique_id())
	#get_node("/root/Game/Scene/Map").playerSet = false
	#gameStarted = true

func joinDuringGame():
	closeLobby()
	createMap.rpc()
	map.addLatePlayer()
	getSync().gameStarted = true
	
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

@rpc("authority", "call_local", "reliable")
func openTransitionScreen():
	transition = transitionScene.instantiate()
	add_child(transition, true)
	transition.setDay(getSync().day)

@rpc("authority", "call_local", "reliable")
func closeTransitionScreen():
	transition.queue_free()

func openMap():
	openTransitionScreen.rpc()
	createMap.rpc()

func closeMap():
	map.queue_free()
	setCamera()
	for enemy in Network.enemies.get_children():
		enemy.queue_free()
	for item in Network.items.get_children():
		item.queue_free()
	for player in Network.players.get_children():
		player.playerBody.setVisible(false)
	if(Network.networkID == 1):
		openMap()
	
#@rpc("any_peer", "call_remote", "reliable", 1)
#func isGameStarted():
	#return gameStarted

func _on_timer_timeout():
	map.generate(getSync().getMapSeed(getSync().day - 1))
	closeTransitionScreen.rpc()
	getSync().startDay()
	if(Network.networkID == 1):
		map.setPlayerValues()
		map.spawn_test_wolf()
