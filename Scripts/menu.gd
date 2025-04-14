extends Node2D

@onready var Game = get_tree().get_nodes_in_group("GameManager")[0]
@onready var Network = get_tree().get_nodes_in_group("GameManager")[1]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_lobby() -> void:
	Network.startHost()
	Game.openLobby()

func join_lobby() -> void:
	Network.startClient()
	Game.openLobby()

func _on_code_text_changed(new_text):
	Network._on_code_text_changed(new_text)
