extends Node2D

var characterProfiles = [preload("res://Sprites/Character Portraits/Girl1.png"), preload("res://Sprites/Character Portraits/Guy1.png")]
var characterIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	changePortrait()


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
	$Control/VBoxContainer2/MarginContainer/TextureRect.texture = characterProfiles[characterIndex]
