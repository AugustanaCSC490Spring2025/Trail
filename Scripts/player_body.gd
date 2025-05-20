extends CharacterBody2D

@onready var player_sprite = $AnimatedSprite2D

@onready var camera_2d = $Camera2D
@onready var input_synchronizer = $InputSynchronizer
@onready var weapon_position = $"Weapon Pivot/Sprite2D/Tip"

@onready var interact_ui = $InteractUI
@onready var inventory_hotbar = $InventoryHotbar

var can_move = true

const SPAWN_RADIUS: float = 100
@export var speed = 200.0
const JUMP_VELOCITY = -400.0

@export var username : String

@export var player_facing = "down"
@export var playerID : int = 1:
	set(id):
		playerID = id
		$InputSynchronizer.set_multiplayer_authority(id)
		$Name.text = "Player " + str(id)
@export var maxHP: float = 100
@export var HP: float = 100
@export var alive = true
@export var hpGradient: Gradient
@onready var hpBar = $PlayerHealth

var is_local_player := false

#func _enter_tree():
	#$InputSynchronizer.set_multiplayer_authority(playerID)

func _ready() -> void:
	#if not $InputSynchronizer.is_multiplayer_authority(): return
	Global.set_player_reference(self)
	#if multiplayer.get_unique_id() == get_multiplayer_authority():
		#is_local_player = true
	_set_random_spawn_pos()
	#camera_2d.make_current()
	player_sprite.play("idle_down")

func _set_random_spawn_pos() -> void:
	position = Vector2(randf_range(-SPAWN_RADIUS, SPAWN_RADIUS), randf_range(-SPAWN_RADIUS, SPAWN_RADIUS))
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("Collided with: ", collision.get_collider().name)
	#print(global_position)

func _process(delta):
	hpBar.max_value = maxHP
	hpBar.value = HP
	hpBar.get("theme_override_styles/fill").bg_color = hpGradient.sample(HP / maxHP)
	pass

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if not can_move:
		$"Weapon Pivot".can_move = false
		return
	if multiplayer.is_server():
		$"Weapon Pivot".can_move = true
		_move(delta)
		changeAnimation.rpc(player_facing)
		#print(camera_2d.zoom)

func _move(delta):
	if input_synchronizer.vertical_input == -1:
		player_facing = "up"
	else:
		if input_synchronizer.vertical_input == 1:
			player_facing = "down"
	if input_synchronizer.horizontal_input == -1:
		player_facing = "left"
	else:
		if input_synchronizer.horizontal_input == 1:
			player_facing = "right"
	#if(playerID != 1):
		#print(str(input_synchronizer.horizontal_input) + " " + str(input_synchronizer.vertical_input) + " " + str(input_synchronizer.shoot_input) + " " + str(playerID))
	velocity = Vector2(input_synchronizer.horizontal_input, input_synchronizer.vertical_input).normalized()
	velocity *= Vector2(speed, speed)
	#print(str(playerID) + " : " + str(position))
	move_and_slide()

func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x * 1.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
		#print(camera_2d.zoom.x)
	elif Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x / 1.1
		if zoom_val == 0:
			zoom_val = camera_2d.zoom.x - 0.2
			
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
		#print(camera_2d.zoom.x)

@rpc("authority", "call_local", "reliable")
func changeAnimation(facing: String):
	var idle = true
	if velocity.x == 0 && velocity.y == 0:
		idle = true
	else:
		idle = false
	if facing == "up":
		player_sprite.flip_h = false
		player_sprite.position.x = 0
		if idle:
			player_sprite.play("idle_up")
		else:
			player_sprite.play("walk_up")
	elif facing == "down":
		player_sprite.flip_h = false
		player_sprite.position.x = 0
		if idle:
			player_sprite.play("idle_down")
		else:
			player_sprite.play("walk_down")
	elif facing == "left":
		player_sprite.flip_h = true
		player_sprite.position.x = -2
		if idle:
			player_sprite.play("idle_right")
		else:
			player_sprite.play("walk_right")
	elif facing == "right":
		player_sprite.flip_h = false
		player_sprite.position.x = 0
		if idle:
			player_sprite.play("idle_right")
		else:
			player_sprite.play("walk_right")

func setPlayerID(id):
	playerID = id

func enableCamera():
	print(str(multiplayer.get_unique_id()) + " + " + str(playerID))
	if playerID == multiplayer.get_unique_id():
		camera_2d.make_current()

func damagePlayer(damage):
	HP -= damage
	if(HP <= 0):
		HP = 0
		alive = false

func _on_health_regeneration_timeout():
	HP += 1
	if HP >= maxHP:
		HP = maxHP
		
# Use hotbar items on key 1 - 5 press		
func use_hotbar_item(slot_index):
	if slot_index < Global.hotbar_inventory.size():
		var item = Global.hotbar_inventory[slot_index]
		if item != null:
			# Use item
			apply_item_effect(item)
			var progress_scene = preload("res://Scenes/ProgressBar.tscn")
			var progress_ui = progress_scene.instantiate()
			progress_ui.duration = item["duration"]
			add_child(progress_ui)
			can_move = false
			await progress_ui.simulate_loading(progress_ui.duration)
			can_move = true
			#remove_child(progress_ui)

			# Remove item
			item["quantity"] -= 1
			if item["quantity"] <= 0:
				Global.hotbar_inventory[slot_index] = null
				Global.remove_item(item["type"], item["effect"])
			Global.inventory_updated.emit()
			
# Use hotbar items on key 1 - 5 press		
func drop_hotbar_item(slot_index):
	if slot_index < Global.hotbar_inventory.size():
		var item = Global.hotbar_inventory[slot_index]
		if item != null:
			# Drop item
			apply_item_effect(item)
			print("drop")
			var drop_position = Global.player_node.global_position
			var drop_offset = Vector2(50, 0)
			drop_offset = drop_offset.rotated(Global.player_node.rotation)
			Global.drop_item(item, drop_position + drop_offset)
			Global.hotbar_inventory[slot_index] = null
			Global.remove_hotbar_item(item["type"], item["effect"])
			Global.inventory_updated.emit()
			
# Hotbar shortcuts
func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		# Then check for specific keys
		for i in range(Global.hotbar_size):
			# Assuming keys 1-5 are mapped to actions "hotbar_1" to "hotbar_5" in the Input Map
			if Input.is_action_just_pressed("hotbar_" + str(i + 1)):
				use_hotbar_item(i)
				break
			if Input.is_action_just_pressed("drop_hotbar_" + str(i + 1)):
				drop_hotbar_item(i)
				break
# Apply the effect of the item (if possible)
func apply_item_effect(item):
	match item["effect"]:
		"Stamina":
			speed += 50
			print(multiplayer.get_unique_id(), " speed increased to ", speed)
		"Armor":
			maxHP += 10
			print(multiplayer.get_unique_id(), " hp increased to ", maxHP)
		"Health":
			HP += 30
			print(multiplayer.get_unique_id(), " hp increased to ", HP)
			#Global.increase_inventory_size(5)
			#print("Inventory increased to ", Global.inventory.size())
		#_:
			#print("No effect for this item")
