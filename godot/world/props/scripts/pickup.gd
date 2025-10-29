extends StaticBody3D

const available_items = [
	"BALL", "WET_FLOOR_SIGN", "ARROW"
]

func _on_pickup(body: Node3D) -> void:
	if body is CharacterBody3D:
		var random_item = available_items.pick_random()
		body.pickup_item(random_item)
		print("Picked up: ", random_item)
	
	
