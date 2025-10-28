extends Node

## Format of Dictionary: [br] 
## [member "Item_Name"] : [member preload("Path_To_Item_Scene")]
const ITEM_SCENES = {
	"Ball": preload("res://godot/items/ball.tscn"),
	"Bullet": preload("res://godot/items/bullet.tscn"),
}


func activate_item(player: CharacterBody3D, global_mouse_position: Vector3, item_name: String):
	var item = ITEM_SCENES[item_name].instantiate()
	var player_to_cursor = global_mouse_position - player.global_position
	get_tree().root.add_child(item)
	item.global_position = player.get_node("Pivot/ThrowOrigin").global_position
	item.shoot_projectile(player_to_cursor)
