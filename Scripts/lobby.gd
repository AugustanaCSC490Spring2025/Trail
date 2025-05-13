extends Node2D

@onready var Game = get_tree().get_nodes_in_group("GameManager")[0]
@onready var Network = get_tree().get_nodes_in_group("GameManager")[1]
var characterProfiles = [preload("res://Sprites/Character Portraits/Girl1.png"), preload("res://Sprites/Character Portraits/Guy1.png")]
var characterIndex = 0
@onready var textureRect = $Control/VBoxContainer2/MarginContainer/TextureRect
@onready var nameEdit = $Control/VBoxContainer2/HBoxContainer/MarginContainer2/Username
#var startButton
#var joinButton
@onready var names = $Control/Names
var nameLabelScene = preload("res://Scenes/NameLabel.tscn")
var startScene = preload("res://Scenes/Start.tscn")
var joinScene = preload("res://Scenes/Join.tscn")
var map 
var start_clicked = false
# Called when the node enters the scene tree for the first time.
func _ready():
	changePortrait()
	#updatePlayers()

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

func _on_change_pressed():
	pass

func changePortrait():
	textureRect.texture = characterProfiles[characterIndex]

func updatePlayers(playerNames):
	start_clicked = false
	for node in names.get_children():
		#print(node.name)
		if(node.name == "Start"):
			node.disconnect("pressed", startGame)
		if(node.name == "Join"):
			node.disconnect("pressed", joinDuringGame)
		node.queue_free()
	for playerName in playerNames:
		var nameLabel = nameLabelScene.instantiate()
		names.add_child(nameLabel, true)
		var label = nameLabel.get_node("Player")
		label.text = playerName
	#print("Hello")
	if multiplayer.get_unique_id() == 1:
		#print("I Drive")
		var startButton = startScene.instantiate()
		names.add_child(startButton, true)
		if start_clicked == false:
			start_clicked = true
			startButton.connect("pressed", startGame)
	else:
		var joinButton = joinScene.instantiate()
		names.add_child(joinButton, true)
		if start_clicked == false:
			start_clicked = true
			joinButton.connect("pressed", joinDuringGame)
	
func startGame():
	#print("SEX")
	Game.startGame.rpc()

func joinDuringGame():
	#Game.closeLobby()
	print("joined lobby")
	Game.joinDuringGame(Network.networkID)
