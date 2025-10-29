extends Node

@onready var player_inventory = {
	1: {
		"node": $BottomHUD/ItemGrid/ItemSlot1,
		"item": null,
		"button": null
	}, 	
	2: {
		"node": $BottomHUD/ItemGrid/ItemSlot2,
		"item": null,
		"button": null
	}, 	
	3: {
		"node": $BottomHUD/ItemGrid/ItemSlot3,
		"item": null,
		"button": null
	}, 
	4: {
		"node": $BottomHUD/ItemGrid/ItemSlot4,
		"item": null,
		"button": null
	}, 	
	5: {
		"node": $BottomHUD/ItemGrid/ItemSlot5,
		"item": null,
		"button": null
	}, 	
	6: {
		"node": $BottomHUD/ItemGrid/ItemSlot6,
		"item": null,
		"button": null
	}, 
	}
@export var inventory_dict = {"Pos1" : null, "Pos2" : null, "Pos3" : null, "Pos4" : null, "Pos5" : null, "Pos6" : null}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BottomHUD/ItemGrid/ItemSlot1.texture_normal.region.position += Vector2(50, 0)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_item(slot: int, item: BaseItem):
	player_inventory[slot]["item"] = item
	$BottomHUD/ItemGrid/ItemSlot5.texture_normal.region.position = ItemConstants.item_sprite_position[item.item_name]
	
func remove_item(slot: int):
	player_inventory[slot]["item"] = null
	
