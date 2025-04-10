extends Node

var playerName
var playerID
var playerBodyScene = preload("res://Scenes/PlayerBody.tscn")
var playerBody

func _ready():
	createBody()

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
