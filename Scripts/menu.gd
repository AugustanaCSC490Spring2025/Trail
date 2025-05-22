extends Node2D

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_lobby() -> void:
	Game.openLobby()
	Network.startHost()
	#Game.createMap()

func join_lobby() -> void:
	Game.openLobby()
	Network.startClient()
	#Game.createMap()

func _on_code_text_changed(new_text):
	Network._on_code_text_changed(new_text)
