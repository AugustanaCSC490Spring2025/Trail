extends Node2D

var mouse_position =  null
@onready var weapon_tip = $RayCast2D/Tip
@onready var pointing_tip = $RayCast2D
@onready var pivot_point = $"."

func _physics_process(delta: float) -> void:
	mouse_position = get_global_mouse_position()
	pivot_point.look_at(mouse_position)
	#weapon_tip.position = mouse_position
	#pointing_tip.target_position = mouse_position
