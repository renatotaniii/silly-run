extends Node

## Format of Dictionary: [br] 
## [member "ITEM_NAME"] : [member preload("Path_To_Item_Scene")]
const ITEM_SCENES = {
	"BALL": preload("res://godot/items/ball.tscn"),
	"WET_FLOOR_SIGN": preload("res://godot/items/ball.tscn"),
	"ARROW": preload("res://godot/items/ball.tscn"),
}

const ITEM_SPRITE_POSITION = {
	WET_FLOOR_SIGN = Vector2(0,0),
	BALL = Vector2(50,0),
	ARROW = Vector2(100,0),
}


func activate_item(player: CharacterBody3D, global_mouse_position: Vector3, item_name: String):
	var item = ITEM_SCENES[item_name].instantiate()
	var player_to_cursor = global_mouse_position - player.global_position
	get_tree().root.add_child(item)
	item.global_position = player.get_node("Pivot/ThrowOrigin").global_position
	item.use_throw(player_to_cursor, global_mouse_position)

func give_player_item(player: CharacterBody3D, item_name: String):
	var ball = ITEM_SCENES[item_name].instantiate()
	player.get_item(ball)
	
