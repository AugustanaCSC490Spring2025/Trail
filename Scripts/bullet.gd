extends Area2D
const speed = 1
@onready var direction = null
@onready var sprite = $Sprite
@onready var shadow = $Shadow
var damage = 25
var velocity = 1200
var x_speed = 0
var y_speed = 0
var origin
var length = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.visible = false
	shadow.visible = false

func set_damage(bullet_damage):
	damage = bullet_damage

func set_speed(bullet_speed):
	velocity = bullet_speed

func fire(starting_location: Vector2, mouse_position: Vector2) -> void:
	origin = starting_location
	var direction = mouse_position
	var x_dif = float(direction.x - starting_location.x)
	var y_dif = float(direction.y - starting_location.y)
	var distance = sqrt(pow(x_dif, 2.0) + pow(y_dif, 2.0))
	var unit_x = x_dif / distance
	var unit_y = y_dif / distance
	x_speed = unit_x * velocity
	y_speed = unit_y * velocity
	#print("Starting Location: ", starting_location)
	#print("Direction: ", direction)
	#print("x_speed: ", x_speed)
	#print("y_speed: ", y_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(x_speed, y_speed) * delta
	var distance = sqrt(pow(position.x, 2.0) + pow(position.y, 2.0))
	if(!sprite.visible && distance > length):
		sprite.visible = true
		shadow.visible = true
	if(distance > 10000):
		queue_free()
	#print(position)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Hurtable") and not body.is_in_group("Players"):
		#body.rpc("wolf_die")
		#body.die()
		print("damage wizard")
		body.damageEnemy(damage)
		self.queue_free()
	else:
		if body.is_in_group("Players"):
			if(body.playerID != multiplayer.get_unique_id()):
				body.damagePlayer(damage / 2)
				self.queue_free()
