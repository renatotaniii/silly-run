class_name Banana
extends BaseItem


# Set all property overrides here.
func _init() -> void:
	item_name = "WET_FLOOR_SIGN"


func _ready() -> void:
	# Define collision layer/mask here
	# NOTE: Everything is on layer=1 by default. We have to manually set them 
	# set_collision_layer_value(layer: int, value: bool)
	# set_collision_mask_value(layer: int, value: bool)
	pass


func _physics_process(delta: float) -> void:
	pass
