extends Node

var playerBodyScene = preload("res://Scenes/PlayerBody.tscn")
@export var gameStarted = false
@export var gameReady = false
@export var playerName = "Player"
@export var playerID = 0
@onready var playerBody = $PlayerBody

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
