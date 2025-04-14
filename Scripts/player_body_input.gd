extends MultiplayerSynchronizer

@export var vertical_input : float
@export var horizontal_input : float
@export var shoot_input : bool
@export var enable = true

func _ready():
	# disable the _physics_process function for all
	# who does not control this player
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_physics_process(false)
		enable = false

func _physics_process(delta):
	vertical_input = Input.get_axis("move up", "move down")
	horizontal_input = Input.get_axis("move left", "move right")
	shoot_input = Input.is_action_just_pressed("shoot")
