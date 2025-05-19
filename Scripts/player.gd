extends Node

var playerName = "Player"
var playerID
var playerBodyScene = preload("res://Scenes/PlayerBody.tscn")
var playerBody
@export var gameStarted = false
@export var gameReady = false

func _ready():
	pass

func getName():
	return playerName

func setName(name):
	playerName = name

func getID():
	return playerID

func setID(ID):
	playerID = ID
	
func getPlayerBody():
	return playerBody
	
func createBody():
	playerBody = playerBodyScene.instantiate()
	#playerBody.set_multiplayer_authority(playerID)
	playerBody.setPlayerID(playerID)
