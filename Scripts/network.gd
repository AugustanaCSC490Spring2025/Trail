class_name Network
extends Node
signal OnConnectedToServer
signal OnServerDisconnected

@onready var Game = get_tree().get_nodes_in_group("GameManager")[0]

const MAX_CLIENTS = 4

var portInput = 8080
var IPinput = "localhost"
var localUsername = "Player"
var playerScene = preload("res://Scenes/Player.tscn")
var players = []
var mapScene = preload("res://Scenes/Map.tscn")
var map
var networkID

var all_addresses = IP.get_local_addresses()
var lan_addresses = Array(all_addresses).filter(func(ip): 
	return ip.begins_with("192.") or ip.begins_with("10.") or ip.begins_with("172.")
)

func _ready():
	pass # Replace with function body.

func startHost():
	var peer = ENetMultiplayerPeer.new()
	map = mapScene.instantiate()
	var lan_ip = "0.0.0.0" if lan_addresses.is_empty() else lan_addresses[0]
	print(lan_ip)
	peer.set_bind_ip(lan_ip)
	peer.create_server(portInput, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	networkID = multiplayer.get_unique_id()
	_on_player_connected(networkID)

func startClient():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IPinput, portInput)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	networkID = multiplayer.get_unique_id()

func _on_player_connected(id):
	var player = playerScene.instantiate()
	player.setID(id)
	player.name = str(id)
	player.createBody()
	players.append(player)
	var playerNames = []
	for tempPlayer in players:
		playerNames.append(tempPlayer.playerName)
	updateLobbyPlayers.rpc(playerNames)
	print("Player %s joined the game." % id)
	#print("Players: %d" % players.size())

func _on_player_disconnected(id):
	for player in players:
		if player.getID() == id:
			players.erase(player)

	print("Player %s left the game." % id)

func _connected_to_server():
	print("Connected to server.")
	
	OnConnectedToServer.emit()

func _connection_failed():
	print("Connection failed!")
	OnServerDisconnected.emit()
func _server_disconnected():
	Game.leaveGame()
	print("Server disconnected.")

func _on_code_text_changed(new_text):
	IPinput = new_text
	if(IPinput == ""):
		IPinput = "localhost"

@rpc("authority", "call_local", "reliable")
func updateLobbyPlayers(playerNames):
	var lobby = Game.get_node_or_null("Lobby")
	#print(lobby)
	if(lobby != null):
		lobby.updatePlayers(playerNames)
	
