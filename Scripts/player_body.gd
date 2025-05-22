extends CharacterBody2D

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

@onready var player_sprite = $AnimatedSprite2D

@onready var camera_2d = $Camera2D
@onready var input_synchronizer = $InputSynchronizer
@onready var weapon_position = $"Weapon Pivot/Sprite2D/Tip"
@onready var weapon = $WeaponPivot

@onready var interact_ui = $InteractUI
@onready var inventory_hotbar = $InventoryHotbar

@onready var label = $StatChange/StatChangeLabel
@onready var timer = $HideLabelTimer
@onready var deathTimer = $DeathTimer
@onready var hour = $Hour

var can_move = true

const SPAWN_RADIUS: float = 100
var minSpeed = 50
@export var speed = 200.0
const JUMP_VELOCITY = -400.0

@export var username : String

@export var player_facing = "down"
@export var playerID : int:
	set(id):
		playerID = id
		$InputSynchronizer.set_multiplayer_authority(id)
		$InputSynchronizer.setInputSyncronizer()
var minHP: float = 25
@export var maxHP: float = 100
@export var HP: float = 100
@export var alive = true
@export var hpGradient: Gradient
@export var velocitySync: Vector2
@onready var hpBar = $PlayerHealth
@onready var nameText = $Name

var is_local_player := false
@export var respawnPoint = Vector2(0, 0)

#func _enter_tree():
	#$InputSynchronizer.set_multiplayer_authority(playerID)

func _ready() -> void:
	#if not $InputSynchronizer.is_multiplayer_authority(): return
	Global.set_player_reference(self)
	playerID = get_parent().getID()
	#camera_2d.make_current()
	player_sprite.play("idle_down")
	hpGradient = hpGradient.duplicate()
	visible = false
	label.visible = false

#func _set_random_spawn_pos() -> void:
	#position = Vector2(randf_range(-SPAWN_RADIUS, SPAWN_RADIUS), randf_range(-SPAWN_RADIUS, SPAWN_RADIUS))
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#print("Collided with: ", collision.get_collider().name)
	#print(global_position)

func _process(delta):
	hpBar.max_value = maxHP
	hpBar.value = HP
	hpBar.get("theme_override_styles/fill").bg_color = hpGradient.sample(HP / maxHP)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if not can_move:
		weapon.can_move = false
		return
	if multiplayer.is_server():
		weapon.can_move = true
		_move(delta)
		velocitySync = velocity
		changeAnimation.rpc(player_facing)
		#print(camera_2d.zoom)
	#print(position)

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
	pass
	#if Input.is_action_just_pressed("zoom_in"):
		#var zoom_val = camera_2d.zoom.x * 1.1
		#camera_2d.zoom = Vector2(zoom_val, zoom_val)
		#print(camera_2d.zoom.x)
	#elif Input.is_action_just_pressed("zoom_out"):
		#var zoom_val = camera_2d.zoom.x / 1.1
		#if zoom_val == 0:
			#zoom_val = camera_2d.zoom.x - 0.2
			
		#camera_2d.zoom = Vector2(zoom_val, zoom_val)
		#print(camera_2d.zoom.x)

@rpc("authority", "call_local", "reliable")
func changeAnimation(facing: String):
	var idle = true
	if Vector2(0, 0) == velocitySync:
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

func decreaseStats():
	maxHP *= 0.8
	if maxHP < minHP:
		maxHP = minHP
	HP = maxHP
	speed *= 0.8
	if speed < minSpeed:
		speed = minSpeed

@rpc("any_peer", "call_local", "reliable")
func die():
	if(Network.networkID == 1):
		alive = false
		visible = false
		deathTimer.start(5)

@rpc("any_peer", "call_local", "reliable")
func respawn():
	if(Network.networkID == 1):
		alive = true
		visible = true
		position = respawnPoint
		decreaseStats()

func setPlayerID(id):
	playerID = id

#@rpc("any_peer", "call_remote", "reliable", 1)
func setPosition(x, y):
	position = Vector2(x, y)
	respawnPoint = position

func setCamera():
	#print(str(multiplayer.get_unique_id()) + " + " + str(playerID))
	#if playerID == multiplayer.get_unique_id():
	camera_2d.make_current()

@rpc("any_peer", "call_local", "reliable")
func setVisible(v):
	visible = v
	if(playerID == Network.networkID):
		inventory_hotbar.visible = v
		hour.visible = v

@rpc("any_peer", "call_local", "reliable")
func damagePlayer(damage):
	if(Network.networkID == 1 && alive):
		HP -= damage
		if(HP <= 0):
			HP = 0
			die.rpc()

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
			if item["type"] == "Weapon":
				weapon.swap_weapon(item)
				show_stat_change(str(item["name"], " equipped"))
			else:
				var progress_scene = preload("res://Scenes/ProgressBar.tscn")
				var progress_ui = progress_scene.instantiate()
				progress_ui.duration = item["duration"]
				add_child(progress_ui)
				can_move = false
				await progress_ui.simulate_loading(progress_ui.duration)
				can_move = true
				apply_item_effect(item)

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
			#if Input.is_action_just_pressed("drop_hotbar_" + str(i + 1)):
				#drop_hotbar_item(i)
				#break
# Apply the effect of the item (if possible)

func show_stat_change(text: String, duration: float = 2.0):
	if(playerID == Network.networkID):
		label.text = text
		label.visible = true
		timer.wait_time = duration
		timer.start()

func apply_item_effect(item):
	var stat_change = ""
	match item["effect"]:
		"Stamina":
			speed += 50
			stat_change = str("Speed increased to ", speed)
		"Armor":
			maxHP += 10
			stat_change = str("Max HP increased to ", maxHP)
		"Health":
			HP += 30
			if HP > maxHP:
				HP = maxHP
			stat_change = str("HP increased to ", HP)
		"Brawn":
			weapon.rate_of_fire *= .8
			stat_change = str("Rate of fire decreased to ", weapon.rate_of_fire)
	show_stat_change(stat_change)
	
func _on_hide_label_timer_timeout() -> void:
	label.visible = false

func changeHour(h):
	var am = true
	if(h >= 12):
		am = false
	h = h % 12
	if h == 0:
		h = 12
	if am:
		hour.text = str(h, " AM")
	else:
		hour.text = str(h, " PM")


func _on_death_timer_timeout():
	respawn.rpc()
