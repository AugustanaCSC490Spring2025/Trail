extends Node

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

var playerBodyScene = preload("res://Scenes/PlayerBody.tscn")
@export var gameReady = false
@export var playerName = ""
@export var playerID = 0
@onready var playerBody = $PlayerBody

func _ready():
	pass

func getName():
	return playerName

@rpc("any_peer", "call_local", "reliable")
func setName(name):
	playerName = name
	playerBody.nameText.text = name

func getID():
	return playerID

func setID(ID):
	playerID = ID
	
@rpc("any_peer", "call_local", "reliable")
func setGameReady(ready):
	gameReady = ready
