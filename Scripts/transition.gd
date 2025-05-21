extends ColorRect

@onready var wheel = $Wheel
@onready var day = $Day
var spinRate = 1

func _process(delta):
	wheel.rotate(spinRate * delta)

func setDay(newDay):
	day.text = str("Day ", newDay)
