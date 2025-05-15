extends Node2D

@onready var players = $Players

func addPlayer(player):
	players.add_child(player.getPlayerBody(), true)
