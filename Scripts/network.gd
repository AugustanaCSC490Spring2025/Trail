class_name Network
extends Node
signal OnConnectedToServer
signal OnServerDisconnected

const MAX_CLIENTS = 4

var portInput = 8080
var IPinput = "localhost"
var localUsername = "Player"
@onready var spawnerNodes = $MultiplayerSpawner
var playerScene = preload("res://Scenes/NetworkPlayer.tscn")

var current_players : Array = []

func _ready():
	get_tree().set_auto_accept_quit(false) # Replace with function body.

func startHost():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(portInput, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	current_players = []
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	_on_player_connected(multiplayer.get_unique_id())
	_connected_to_server()

func startClient():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IPinput, portInput)
	multiplayer.multiplayer_peer = peer
	current_players = []
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	_on_player_connected(multiplayer.get_unique_id())

func _on_player_connected(id):
	var player = playerScene.instantiate()
	player.name = str(id)
	spawnerNodes.add_child(player, true)
	print("Player %s joined the game." % id)

func _on_player_disconnected(id):
	print("Player %s left the game." % id)

func _connected_to_server():
	print("Connected to server.")
	OnConnectedToServer.emit()

func _connection_failed():
	print("Connection failed!")
	OnServerDisconnected.emit()
func _server_disconnected():
	print("Server disconnected.")

func _on_code_text_changed(new_text):
	IPinput = new_text
	if(IPinput == ""):
		IPinput = "localhost"

func add_player_to_list(player: NetworkPlayer):
	current_players.append(player)
	
func remove_player_from_list(player: NetworkPlayer):
	current_players.erase(player)
