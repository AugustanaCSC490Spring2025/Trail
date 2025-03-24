extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_lobby() -> void:
	Network.startHost()
	Game.changeScene(1)

func join_lobby() -> void:
	Network.startClient()
	Game.changeScene(1)

func _on_code_text_changed(new_text):
	Network._on_code_text_changed(new_text)
