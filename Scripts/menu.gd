extends Node2D

@onready var Game = get_tree().get_nodes_in_group("GameManager")[0]
@onready var network : Network = get_node("/root/Game/Network")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_lobby() -> void:
	network.startHost()
	Game.openLobby()

func join_lobby() -> void:
	network.startClient()
	Game.openLobby()

func _on_code_text_changed(new_text):
	network._on_code_text_changed(new_text)
