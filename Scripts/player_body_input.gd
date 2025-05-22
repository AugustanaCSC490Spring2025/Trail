extends MultiplayerSynchronizer

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

@export var vertical_input : int
@export var horizontal_input : int
@export var shoot_input : bool
@export var mouse_position : Vector2
@onready var enable = false

func setInputSyncronizer():
	# disable the _physics_process function for all
	# who does not control this player
	#print(get_multiplayer_authority())
	if get_multiplayer_authority() != Network.networkID:
		set_physics_process(false)
	else:
		set_physics_process(true)
		enable = true

func _physics_process(delta):
	var sync = Game.getSync()
	var alive = get_parent().alive
	if(sync != null && alive):
		if(sync.gameStarted):
			vertical_input = Input.get_axis("move up", "move down")
			horizontal_input = Input.get_axis("move left", "move right")
			shoot_input = Input.is_action_pressed("shoot")
			mouse_position = Game.get_global_mouse_position()
	else:
		shoot_input = false
	#if(multiplayer.get_unique_id() != 1):
		#print(str(horizontal_input) + " " + str(vertical_input) + " " + str(shoot_input) + " " + str(multiplayer.get_unique_id()))
	#print(str(vertical_input) + " vertical " + str(multiplayer.get_unique_id()))
	#print(str(horizontal_input) + " horizontal " + str(multiplayer.get_unique_id()))
	#print(str(shoot_input) + " shooting " + str(multiplayer.get_unique_id()))
