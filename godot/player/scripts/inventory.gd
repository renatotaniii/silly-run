class_name Inventory
extends Resource

var inventory = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
	6: null
}

func add_item(item_name: String):
	print("Add Item Called. Item: ", item_name)
	for key in inventory:
		if inventory[key] == null:
			inventory[key] = item_name
			emit_changed()
			print("Inventory Changed:", inventory)
			break
		else:
			continue

func use_item(player: CharacterBody3D, global_mouse_position: Variant, slot: int):
	if inventory[slot] != null:
		ItemManager.activate_item(player, global_mouse_position, inventory[slot])
		remove_item(slot)

func remove_item(slot: int):
	inventory[slot] = null
	emit_changed()
	
	
 
