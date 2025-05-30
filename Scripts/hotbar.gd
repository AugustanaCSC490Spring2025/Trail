### Inventory_Hotbar.gd


extends Control

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

# Scene-Tree Node references
@onready var hotbar_container = $HBoxContainer

func _ready():
	Global.inventory_updated.connect(_update_hotbar)
	_update_hotbar()

# Create the hotbar slots
func _update_hotbar():
	clear_hotbar_container()
	for i in range(Global.hotbar_size):
		#var item = Global.hotbar_inventory[i]
		var slot = Global.inventory_slot_scene.instantiate()
		#print(i)
		slot.set_slot_index(i)  # Set the index here
		hotbar_container.add_child(slot)
		if Global.hotbar_inventory[i] != null:
			slot.set_item(Global.hotbar_inventory[i])
		else:
			slot.set_empty()
		
# Clear hotbar slots
func clear_hotbar_container():
	while hotbar_container.get_child_count() > 0:
		var child = hotbar_container.get_child(0)
		hotbar_container.remove_child(child)
		child.queue_free()
