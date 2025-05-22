extends Node

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

@export var mapSeeds = []
@export var gameStarted = false
@export var day = 1
@onready var mapTimer = $MapTimer
var hourLength = 8
var hour = 0
var maxDays = 3

func _ready():
	if(Network.networkID == 1):
		#for i in range(maxDays):
			#mapSeeds.append(i)
			#mapSeeds.append(randi_range(0, 1000000000))
		mapSeeds = [248160797, 925007009, 1]
	#248160797 - Plains
	#925007009 - Desert
	#346121659 - Swamp
	#258572012 - Forest
	#1         - Snow
	print(mapSeeds)

func getMapSeed(index):
	return mapSeeds[index]

func startDay():
	mapTimer.stop()
	mapTimer.wait_time = hourLength
	mapTimer.start()
	Network.localPlayer.playerBody.changeHour(hour)

func _on_map_timer_timeout():
	hour += 1
	if hour >= 24:
		hour = 0
		day += 1
		mapTimer.stop()
		if day > maxDays:
			Game.finishGame()
		else:
			Game.closeMap()
	else:
		if (hour % 3 == 0):
			Game._new_hour_spawn()
		Network.localPlayer.playerBody.changeHour(hour)
		Game.map.setDayTexture(hour)

@rpc("any_peer", "call_local", "reliable")
func addDay():
	if(Network.networkID == 1):
		day += 1
