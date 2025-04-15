extends Node2D

@onready var game: Game = get_node('/root/Game')
@onready var network: Network = get_node('/root/Game/Network')
var characterProfiles = [preload("res://Sprites/Character Portraits/Girl1.png"), preload("res://Sprites/Character Portraits/Guy1.png")]
var characterIndex = 0
@onready var textureRect = $Control/VBoxContainer2/MarginContainer/TextureRect
var startButton
@onready var names = $Control/Names
var nameLabelScene = preload("res://Scenes/NameLabel.tscn")
var startScene = preload("res://Scenes/Start.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	changePortrait()
	updatePlayers()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_left_pressed():
	characterIndex -= 1
	if characterIndex < 0:
		characterIndex = characterProfiles.size() - 1
	changePortrait()

func _on_right_pressed():
	characterIndex += 1
	if characterIndex >= characterProfiles.size():
		characterIndex = 0
	changePortrait()

func changePortrait():
	textureRect.texture = characterProfiles[characterIndex]

func updatePlayers():
	for node in names.get_children():
		node.queue_free()
	for player in Network.players:
		var nameLabel = nameLabelScene.instantiate()
		names.add_child(nameLabel, true)
		var label = nameLabel.get_node("Player")
		label.text = "Player" + str(player.playerID)
	startButton = startScene.instantiate()
	names.add_child(startButton)
	startButton.connect("pressed", startGame)
	#if multiplayer.get_unique_id() != 1:
		#startButton.visible = false
	
@rpc("authority", "call_local", "reliable")
func startGame():
	Game.startGame()