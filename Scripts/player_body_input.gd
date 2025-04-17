extends MultiplayerSynchronizer

@export var vertical_input : int
@export var horizontal_input : int
@export var shoot_input : bool
@onready var enable = false

func _ready():
	# disable the _physics_process function for all
	# who does not control this player
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_physics_process(false)
	else:
		enable = true

func _physics_process(delta):
	vertical_input = Input.get_axis("move up", "move down")
	horizontal_input = Input.get_axis("move left", "move right")
	shoot_input = Input.is_action_just_pressed("shoot")
	#if(multiplayer.get_unique_id() != 1):
		#print(str(horizontal_input) + " " + str(vertical_input) + " " + str(shoot_input) + " " + str(multiplayer.get_unique_id()))
	#print(str(vertical_input) + " vertical " + str(multiplayer.get_unique_id()))
	#print(str(horizontal_input) + " horizontal " + str(multiplayer.get_unique_id()))
	#print(str(shoot_input) + " shooting " + str(multiplayer.get_unique_id()))
