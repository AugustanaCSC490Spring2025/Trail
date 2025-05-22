extends Node

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

@export var mapSeeds = []
@export var gameStarted = false
@export var day = 1
@onready var mapTimer = $MapTimer
var hourLength = 1
var hour = 0
var maxDays = 3

func _ready():
	if(Network.networkID == 1):
		for i in range(maxDays):
			mapSeeds.append(randi_range(0, 1000000000))

func getMapSeed(index):
	return mapSeeds[index]

func startDay():
	mapTimer.wait_time = hourLength
	mapTimer.start()
	Network.localPlayer.playerBody.changeHour(hour)

func _on_map_timer_timeout():
	hour += 1
	if hour >= 24:
		day += 1
		hour = 0
		mapTimer.stop()
		if day > maxDays:
			print("win")
			#Game.win()
		else:
			Game.closeMap()
			#Game.openMap()
	else:
		Network.localPlayer.playerBody.changeHour(hour)
		Game.map.setDayTexture(hour)
