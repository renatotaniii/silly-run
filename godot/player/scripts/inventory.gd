class_name Inventory
extends Resource

## The inventory will only story the item names (e.g. WET_FLOOR_SIGN)
var inventory = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
	6: null
}

## Add item will add the [param item_name] string to any available slot within the inventory
## [br]After adding the item, the inventory will emit a [signal changed] signal.
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

## Use item passes required data from player to global script ItemManager which will handle the spawning of
## the item and passing the data to the item instance.
func use_item(player: CharacterBody3D, global_mouse_position: Variant, slot: int):
	if inventory[slot] != null:
		ItemManager.activate_item(player, global_mouse_position, inventory[slot])
		remove_item(slot)

## Removes item from specified slot in inventory
## [br]emits a [signal changed] signal after removing.
func remove_item(slot: int):
	inventory[slot] = null
	emit_changed()
	
	
 
