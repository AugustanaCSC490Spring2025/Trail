extends Node

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

@export var mapSeeds = []
@export var gameStarted = false

func _ready():
	if(Network.networkID == 1):
		for i in range(3):
			mapSeeds.append(randi_range(0, 1000000000))

func getMapSeed(index):
	return mapSeeds[index]
