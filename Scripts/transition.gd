extends ColorRect

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

@onready var wheel = $Wheel
@onready var day = $Day
var spinRate = 1

func _process(delta):
	wheel.rotate(spinRate * delta)

func setDay(newDay):
	day.text = str("Day ", newDay)
