extends Node

@onready var player_inventory_slots = {
	1: $BottomHUD/ItemGrid/ItemSlot1,
	2: $BottomHUD/ItemGrid/ItemSlot2,	
	3: $BottomHUD/ItemGrid/ItemSlot3,	
	4: $BottomHUD/ItemGrid/ItemSlot4,	
	5: $BottomHUD/ItemGrid/ItemSlot5,	
	6: $BottomHUD/ItemGrid/ItemSlot6,
	}

var current_inventory: Inventory = null

func _ready():
	pass

func connect_player_inventory(inventory: Inventory):
	# Disconnect old inventory if exists
	if current_inventory and current_inventory.changed.is_connected(update_hud):
		current_inventory.changed.disconnect(update_hud)
	current_inventory = inventory
	current_inventory.changed.connect(update_hud)	
	update_hud()

func update_hud():
	for slot in current_inventory.inventory:
		if current_inventory.inventory[slot] != null:
			player_inventory_slots[slot].texture_normal.region.position = ItemManager.ITEM_SPRITE_POSITION[current_inventory.inventory[slot]]
		else:
			player_inventory_slots[slot].texture_normal.region.position = Vector2(150, 0)
			
