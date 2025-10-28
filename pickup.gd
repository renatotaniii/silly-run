extends StaticBody3D

func _on_pickup(body: Node3D) -> void:
	if body is CharacterBody3D:
		for key in body.inventory_dict:
			var pos = body.inventory_dict[key]
			if pos == null:
				var rng = RandomNumberGenerator.new()
				body.inventory_dict[key] = rng.randf_range(0.0, 10.0)
				break
		print(body.inventory_dict)
	
	
