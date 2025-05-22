extends Node2D

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_lobby_button_pressed():
	Game.closeWinScreen()
