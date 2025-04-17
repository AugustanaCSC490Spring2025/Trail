extends Node2D

@onready var Game = get_tree().get_nodes_in_group("GameManager")[0]
@onready var Network = get_tree().get_nodes_in_group("GameManager")[1]
var characterProfiles = [preload("res://Sprites/Character Portraits/Girl1.png"), preload("res://Sprites/Character Portraits/Guy1.png")]
var characterIndex = 0
@onready var textureRect = $Control/VBoxContainer2/MarginContainer/TextureRect
var startButton
@onready var names = $Control/Names
var nameLabelScene = preload("res://Scenes/NameLabel.tscn")
var startScene = preload("res://Scenes/Start.tscn")
var map 
var start_clicked = false
# Called when the node enters the scene tree for the first time.
func _ready():
	changePortrait()
	updatePlayers.rpc()

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

@rpc("any_peer", "call_local", "reliable")
func updatePlayers():
	for node in names.get_children():
		node.queue_free()
	for player in Network.players:
		var nameLabel = nameLabelScene.instantiate()
		names.add_child(nameLabel, true)
		var label = nameLabel.get_node("Player")
		label.text = "Player" + str(player.playerID)
	print("Hello")
	startButton = startScene.instantiate()
	names.add_child(startButton)
	if start_clicked == false:
		start_clicked = true
		startButton.connect("pressed", startGame)
	
	if multiplayer.get_unique_id() != 1:
		startButton.visible = false
	
func startGame():
	Game.startGame.rpc()
	
