extends Area2D

@onready var timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Players")):
		body.damagePlayer(10)


#func _on_body_exited(body):
	#queue_free()

func _on_timer_timeout():
	queue_free()
