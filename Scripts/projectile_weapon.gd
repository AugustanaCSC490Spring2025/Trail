extends Node2D

var mouse_position =  null
var side = true
@onready var weapon_tip = $RayCast2D/Tip
@onready var pointing_tip = $RayCast2D
@onready var pivot_point = $"."
@onready var sprite = $Sprite2D

func _physics_process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	pivot_point.look_at(mouse_position)
	if((pivot_point.global_position.x > mouse_position.x && side) || (pivot_point.global_position.x < mouse_position.x && !side)):
		side = !side
		flip()
		
	#weapon_tip.position = mouse_position
	#pointing_tip.target_position = mouse_position

func flip():
	sprite.scale.y *= -1
	sprite.position.y *= -1
