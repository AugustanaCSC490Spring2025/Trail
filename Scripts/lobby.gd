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
		var hbox = HBoxContainer.new()
		var margin = MarginContainer.new()
		margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var nameLabel = nameLabelScene.instantiate()
		var seperator = VSeparator.new()
		var readyBox = nameLabelScene.instantiate()
		seperator.custom_minimum_size.x = 12
		seperator.modulate = Color.TRANSPARENT
		#If player is ready condition
		#readyBox.text = "   X   "
		#readyBox.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#readyBox.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		#readyBox.offset_top = 10
		var label = nameLabel.get_node("Player")
		var label2 = readyBox.get_node("Player")
		var panel = readyBox.get_node("Panel")
		var stylebox = panel.get_theme_stylebox("normal")
		#stylebox = stylebox.duplicate()
		stylebox.border_color = Color.CRIMSON
		#stylebox.bg_color = Color.DARK_SLATE_BLUE
		label.text = playerName
		label2.text = "   X   "
		panel.add_theme_stylebox_override("normal", stylebox)
		names.add_child(hbox, true)
		hbox.add_child(margin, true)
		hbox.add_child(seperator, true)
		hbox.add_child(readyBox, true)
		margin.add_child(nameLabel, true)
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
		#if(Network.getPlayer(Network.networkID).gameStarted):
			#joinButton.text = "Join"
			#if start_clicked == false:
				#start_clicked = true
				#joinButton.connect("pressed", joinDuringGame)
		#else:
		if Game.gameReady:
			joinButton.text = "Unready"
		else:
			joinButton.text = "Ready Up"
		if start_clicked == false:
			start_clicked = true
			joinButton.connect("pressed", joinDuringGame)
	
func startGame():
	Game.startGame.rpc()

func joinDuringGame():
	#if(Network.getPlayer(Network.networkID).gameStarted):
		#Game.closeLobby()
		#print("joined lobby")
		#Game.joinDuringGame(Network.networkID)
	#else:
	Game.gameReady = not Game.gameReady
	#Network.readyPlayer.rpc(Network.NetworkID)
	Network.refreshLobby.rpc()
