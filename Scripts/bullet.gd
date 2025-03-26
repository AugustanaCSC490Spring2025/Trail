extends Area2D
const speed = 1
@onready var direction = null
var velocity = 1200
var x_speed
var y_speed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func fire(starting_location: Vector2) -> void:
	var direction = get_global_mouse_position()
	var x_dif = float(direction.x - starting_location.x)
	var y_dif = float(direction.y - starting_location.y)
	var distance = sqrt(pow(x_dif, 2.0) + pow(y_dif, 2.0))
	var unit_x = x_dif / distance
	var unit_y = y_dif / distance
	x_speed = unit_x * velocity
	y_speed = unit_y * velocity
	print("Starting Location: ", starting_location)
	print("Direction: ", direction)
	print("x_speed: ", x_speed)
	print("y_speed: ", y_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(x_speed, y_speed) * delta
