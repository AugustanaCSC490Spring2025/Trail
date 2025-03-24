extends Node

var scenes = [preload("res://Scenes/Menu.tscn"), preload("res://Scenes/Lobby.tscn"), preload("res://Scenes/Map.tscn")]
var currentScene = scenes[0].instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.add_child(preload("res://Scenes/Multiplayer.tscn").instantiate())
	changeScene(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func changeScene(index):
	currentScene.queue_free()
	currentScene = scenes[index].instantiate()
	add_child(currentScene)
