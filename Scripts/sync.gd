extends Node

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

@export var mapSeeds = []
@export var gameStarted = false
@onready var mapTimer = $MapTimer
var hourLength = 5
var hour = 0

func _ready():
	if(Network.networkID == 1):
		for i in range(3):
			mapSeeds.append(randi_range(0, 1000000000))

func getMapSeed(index):
	return mapSeeds[index]

func startDay():
	mapTimer.wait_time = hourLength
	mapTimer.start()

func _on_map_timer_timeout():
	hour += 1
	if hour >= 24:
		mapTimer.stop()
	else:
		Network.localPlayer.playerBody.changeHour(hour)
	#Network.localPlayer.playerBody
