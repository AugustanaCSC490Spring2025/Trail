extends Area2D
const speed = 1
@onready var direction = null
var velocity:Vector2
var x_speed
var y_speed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = get_global_mouse_position()
	velocity = direction * speed
	x_speed = direction.x / 10
	y_speed = direction.y / 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(x_speed, y_speed)
