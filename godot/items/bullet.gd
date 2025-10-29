class_name Bullet
extends BaseItem


# Set all property overrides here.
func _init() -> void:
	item_name = "Shootable"
	gravity_scale = 0
	point_click = true
	
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", Callable(self, "_on_body_entered"))


func _ready() -> void:
	# Define collision layer/mask here
	# NOTE: Everything is on layer=1 by default. We have to manually set them 
	# set_collision_layer_value(layer: int, value: bool)
	# set_collision_mask_value(layer: int, value: bool)
	pass


func _physics_process(delta: float) -> void:
	pass
