extends Area2D

@onready var timer = $Timer
var attack_damage = 10

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Players")):
		body.damagePlayer(attack_damage)


func set_damage(damage: int) -> void:
	attack_damage = damage

#func _on_body_exited(body):
	#queue_free()

func _on_timer_timeout():
	queue_free()
