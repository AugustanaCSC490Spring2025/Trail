extends Node2D

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

var characterProfiles = [preload("res://Sprites/Character Portraits/Girl1.png"), preload("res://Sprites/Character Portraits/Guy1.png")]
var characterIndex = 1
@onready var textureRect = $Control/VBoxContainer2/MarginContainer/TextureRect
@onready var nameEdit = $Control/VBoxContainer2/HBoxContainer/MarginContainer2/Username
#var startButton
#var joinButton
@onready var names = $Control/Names
var nameLabelScene = preload("res://Scenes/NameLabel.tscn")
var startScene = preload("res://Scenes/Start.tscn")
var joinScene = preload("res://Scenes/Join.tscn")
var map
var allReady = false
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
	Network.localPlayer.setName.rpc(nameEdit.text)
	Network.updateLobbyPlayers.rpc()

func changePortrait():
	textureRect.texture = characterProfiles[characterIndex]

func updatePlayers():
	for node in names.get_children():
		#print(node.name)
		if(node.name == "Start"):
			node.disconnect("pressed", startGame)
		if(node.name == "Join"):
			node.disconnect("pressed", joinDuringGame)
		node.queue_free()
	var numPlayer = 1
	allReady = true
	for player in Network.players.get_children():
		if(!player.gameReady):
			allReady = false
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
		var styleBox = panel.get("theme_override_styles/panel")
		styleBox = styleBox.duplicate()
		styleBox.border_color = Color.CRIMSON
		panel.add_theme_stylebox_override("normal", styleBox)
		if(player.playerName == ""):
			player.setName.rpc("Player " + str(numPlayer))
		label.text = player.playerName
		if(player.gameReady):
			label2.text = "   0   "
		else:
			label2.text = "   X   "
		names.add_child(hbox, true)
		hbox.add_child(margin, true)
		hbox.add_child(seperator, true)
		hbox.add_child(readyBox, true)
		margin.add_child(nameLabel, true)
		numPlayer += 1
	#print("Hello")
	if multiplayer.get_unique_id() == 1:
		#print("I Drive")
		var startButton = startScene.instantiate()
		names.add_child(startButton, true)
		if allReady:
			startButton.text = "Start"
		else:
			if Network.localPlayer.gameReady:
				startButton.text = "Unready"
			else:
				startButton.text = "Ready Up"
		startButton.connect("pressed", startGame)
	else:
		var joinButton = joinScene.instantiate()
		names.add_child(joinButton, true)
		if Network.localPlayer.gameReady:
			if(Game.getSync().gameStarted):
				joinButton.text = "Join"
			else:
				joinButton.text = "Unready"
		else:
			joinButton.text = "Ready Up"
		joinButton.connect("pressed", joinDuringGame)
	
func startGame():
	if allReady:
		Game.startGame()
	else:
		Network.localPlayer.setGameReady.rpc(!Network.localPlayer.gameReady)
		Network.updateLobbyPlayers.rpc()
func joinDuringGame():
	if(Network.localPlayer.gameReady && Game.getSync().gameStarted):
		Game.closeLobby()
		Game.joinDuringGame()
	else:
		Network.localPlayer.setGameReady.rpc(!Network.localPlayer.gameReady)
		Network.updateLobbyPlayers.rpc()
