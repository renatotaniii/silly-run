extends Node

## Format of Dictionary: [br] 
## [member "ITEM_NAME"] : [member preload("Path_To_Item_Scene")]
const ITEM_SCENES = {
	"BALL": preload("res://godot/items/ball.tscn"),
	"WET_FLOOR_SIGN": preload("res://godot/items/wet_floor_sign.tscn"),
	"ARROW": preload("res://godot/items/arrow.tscn"),
}

## Item sprite positions. Each sprite has a height and width of 50 pixels.
## [br]Positions are assigned as [Class Vector2]. 
## [br]e.g. Vector2(x_position: 0, y_position: 0)
const ITEM_SPRITE_POSITION = {
	WET_FLOOR_SIGN = Vector2(0,0),
	BALL = Vector2(50,0),
	ARROW = Vector2(100,0),
}

## Handles item spawning and activation.
func activate_item(player: CharacterBody3D, global_mouse_position: Vector3, item_name: String):
	var item = ITEM_SCENES[item_name].instantiate()
	get_tree().root.add_child(item)
	item.global_position = player.get_node("Pivot/ThrowOrigin").global_position
	item.throw_projectile(global_mouse_position)

## Helper function if you don't want to use the item spawn pad
func give_player_item(player: CharacterBody3D, item_name: String):
	player.pickup_item(item_name)
	
