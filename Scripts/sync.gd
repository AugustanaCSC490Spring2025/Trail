extends Node

@onready var Game = get_tree().get_nodes_in_group("GameManager")[0]
@onready var Network = get_tree().get_nodes_in_group("GameManager")[1]

@export var mapSeeds = []

func _ready():
	if(Network.networkID == 1):
		for i in range(3):
			mapSeeds.append(randi_range(0, 1000000000))

func getMapSeed(index):
	return mapSeeds[index]
