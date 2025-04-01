extends Node

const MAX_CLIENTS = 4

var portInput = 8080
var IPinput = "localhost"
var localUsername = "Player"
@onready var spawnerNodes = $SpawnerNodes
var playerScene = preload("res://Scenes/Player.tscn")

func _ready():
	pass # Replace with function body.

func startHost():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(portInput, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	_on_player_connected(multiplayer.get_unique_id())

func startClient():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IPinput, portInput)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	_on_player_connected(multiplayer.get_unique_id())

func _on_player_connected(id):
	spawnerNodes.add_child(playerScene.instantiate())
	print("Player %s joined the game." % id)

func _on_player_disconnected(id):
	print("Player %s left the game." % id)

func _connected_to_server():
	print("Connected to server.")

func _connection_failed():
	print("Connection failed!")

func _server_disconnected():
	print("Server disconnected.")

func _on_code_text_changed(new_text):
	IPinput = new_text
	if(IPinput == ""):
		IPinput = "localhost"
