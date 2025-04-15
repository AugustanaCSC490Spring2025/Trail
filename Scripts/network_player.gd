class_name NetworkPlayer
extends Node

@onready var network : Network = get_node("/root/Game/Network")
@export var username : String
@export var player_id : int

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	username = network.localUsername
	player_id = name.to_int()
	network.add_player_to_list(self)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		network.remove_player_from_list(self)
