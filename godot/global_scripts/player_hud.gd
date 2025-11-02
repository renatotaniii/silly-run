extends Control

@onready var player_inventory_slots = {
	1: $BottomHUD/ItemGrid/ItemSlot1,
	2: $BottomHUD/ItemGrid/ItemSlot2,	
	3: $BottomHUD/ItemGrid/ItemSlot3,	
	4: $BottomHUD/ItemGrid/ItemSlot4,	
	5: $BottomHUD/ItemGrid/ItemSlot5,	
	6: $BottomHUD/ItemGrid/ItemSlot6,
	}

var status_indicator = preload("res://godot/ui/hud/status_indicator.tscn")
var test_status_key = preload("res://godot/ui/hud/test_status_key.tscn")
var current_inventory: Inventory = null

func _ready():
	show_debug_controls()

func connect_player_inventory(inventory: Inventory):
	# Disconnect old inventory if exists
	if current_inventory and current_inventory.changed.is_connected(update_hud):
		current_inventory.changed.disconnect(update_hud)
	current_inventory = inventory
	current_inventory.changed.connect(update_hud)	
	update_hud()

func connect_player_status(status_signal: Signal):
	status_signal.connect(update_status_effects)

func update_hud():
	for slot in current_inventory.inventory:
		if current_inventory.inventory[slot] != null:
			player_inventory_slots[slot].texture_normal.region.position = ItemManager.ITEM_SPRITE_POSITION[current_inventory.inventory[slot]]
		else:
			player_inventory_slots[slot].texture_normal.region.position = Vector2(150, 0)

func update_status_effects(player_status: Array):
	var children = $BottomHUD/StatusEffects.get_children()
	for child in children:
		child.queue_free()
	for status in player_status:
		var new_status_indicator = status_indicator.instantiate()
		new_status_indicator.get_node("Panel/Label").text = "%s" %status
		$BottomHUD/StatusEffects.add_child(new_status_indicator)


func show_debug_controls():
	var all_inputs = InputMap.get_actions()
	var status_inputs = all_inputs.filter(func(s): return s.begins_with("status_"))
	for action in status_inputs:
		var events = InputMap.action_get_events(action)
		for event in events:
			if event is InputEventKey:
				var status_key = test_status_key.instantiate()
				status_key.get_node("Status").text = action.split("_")[-1].capitalize()
				status_key.get_node("Key").text = event.as_text_physical_keycode()
				$DebugPanel.add_child(status_key)
				
