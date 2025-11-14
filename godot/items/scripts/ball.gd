class_name Ball
extends BaseItem  


# Set all property overrides here.
func _init() -> void:
	item_name = "Ball"
	max_speed = 50.0
	
	# Define collision layer/mask here, or _ready (not sure yet)
	# NOTE: Everything is on layer=1 by default. We have to manually set them 
	# set_collision_layer_value(layer: int, value: bool)
	# set_collision_mask_value(layer: int, value: bool)


func _ready() -> void:
	pass


func _physics_process(_delta: float):
	var velocity = get_linear_velocity()
	
	# Limit horizontal speed
	if velocity.length() > max_speed:
		var horizontal_velocity = velocity.normalized() * max_speed
		linear_velocity.x = horizontal_velocity.x
		linear_velocity.z = horizontal_velocity.z
