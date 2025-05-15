extends Node

var playerName = "Player"
var playerID
var playerBodyScene = preload("res://Scenes/PlayerBody.tscn")
@export var playerBody: CharacterBody2D
@export var gameStarted = false
@export var gameReady = false
@onready var body = $Body

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
	return body.get_child(0)
	
func createBody():
	playerBody = playerBodyScene.instantiate()
	playerBody.setPlayerID(playerID)
	body.add_child(playerBody, true)
