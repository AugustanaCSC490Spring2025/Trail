extends Node

var scenes = [preload("res://scenes/menu.tscn"), preload("res://scenes/lobby.tscn")]
var currentScene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	changeScene(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func changeScene(index):
	currentScene.queue_free()
	currentScene = scenes[index].instantiate()
	add_child(currentScene)
