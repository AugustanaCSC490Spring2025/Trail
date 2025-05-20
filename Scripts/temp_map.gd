extends Node2D

@onready var Game = get_tree().get_nodes_in_group("GameManager")[0]
@onready var Network = get_tree().get_nodes_in_group("GameManager")[1]
var radius = 30

func setPlayerValues():
	var numPlayers = Network.players.get_child_count()
	var count = 0
	for player in Network.players.get_children():
		player.playerBody.setPosition(sin(2 * PI * count / float(numPlayers)) * radius, cos(2 * PI * count / float(numPlayers)) * radius)
		count += 1	
	setPlayerCameras.rpc()

@rpc("authority", "call_local", "reliable")
func setPlayerCameras():
	print(Network.localPlayer.playerBody.playerID)
	Network.localPlayer.playerBody.setCamera()
