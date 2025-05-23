##Inventory_Slot.gd

extends Control

@onready var Game = get_node("/root/Game")
@onready var Network = get_node("/root/Game/Network")
@onready var Global = get_node("/root/Game/Global")

# Scene-Tree Node references
@onready var icon = $InnerBorder/ItemIcon
@onready var quantity_label =  $InnerBorder/ItemQuantity
@onready var details_panel = $DetailsPanel
@onready var item_name = $DetailsPanel/ItemName
@onready var item_type = $DetailsPanel/ItemType
@onready var item_effect = $DetailsPanel/ItemEffect
@onready var usage_panel = $UsagePanel
#@onready var assign_button = $UsagePanel/AssignButton

# Slot Item
var item = null
var slot_index = -1  # Default to an invalid index

# Setting slot index
func set_slot_index(new_index):
	slot_index = new_index
	
# Default empty slot
func set_empty():
	icon.texture = null  
	quantity_label.text = ""
	
# Set slot item with its values from the dictionary
func set_item(new_item):
	item = new_item
	icon.texture = item["texture"] 
	if item["type"] == "Weapon":
		icon.scale = Vector2(.3, .3)
	quantity_label.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_type.text = str(item["type"])
	if item["effect"] != "":
		item_effect.text = str("+ ", item["effect"])
	else: 
		item_effect.text = ""
	
# Show usage panel for player to use/remove item
func _on_button_pressed():
	if item != null:
		usage_panel.visible = !usage_panel.visible

# Show item details on hover enter
func _on_button_mouse_entered():
	if item != null:
		usage_panel.visible = false
		details_panel.visible = true

# Hide item details on hover exit
func _on_button_mouse_exited():
	details_panel.visible = false

# Remove item from inventory, use it, and apply its effect (if possible)
func _on_use_button_pressed():
	usage_panel.visible = false
	if item != null:
		if Global.player_node:
			Global.player_node.apply_item_effect(item)
			#Global.remove_item(item["type"], item["effect"])
			Global.remove_hotbar_item(item["type"], item["effect"])
		else:
			print("Player node not found")
		
# Remove item from inventory and drop it back into the world		
func _on_drop_button_pressed():
	if item != null:
		var drop_position = Global.player_node.global_position
		var drop_offset = Vector2(50, 0)
		drop_offset = drop_offset.rotated(Global.player_node.rotation)
		Global.drop_item(item, drop_position + drop_offset)
		#Global.remove_item(item["type"], item["effect"])
		Global.remove_hotbar_item(item["type"], item["effect"])
		usage_panel.visible = false
	
# Assigns item to hotbar
func _on_assign_button_pressed():
	pass
