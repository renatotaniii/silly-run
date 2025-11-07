class_name WET_FLOOR_SIGN
extends BaseItem


# Set all property overrides here.
func _init() -> void:
	item_name = "WET_FLOOR_SIGN"
	max_speed = 20.0
	max_range = 25.0
	point_click = false    # for shooting
	shoot_speed = 50.0    # horizontal speed
	throw_speed = 20.0    # horizontal speed
	cast_time = 1.0       # multiplier
	despawn_timer = 20.0

	gravity = ProjectSettings.get_setting("physics/3d/default_gravity") 
	air_drag_constant = 0.1
	friction_constant = 0.1   
	
	duration = 3.0
	turn_rate_modifier = 1.0
	speed_modifier = 0.0
	
	status_effect = "FROZEN"
	affected_stats = {
		# Status.INPUT: [duration], 
		Player.Status.MOVE_SPEED: [speed_modifier, duration],
		# Status.TURN_RATE: [turn_rate_modifier, duration],
	} 


"""
func _ready() -> void:
	# Define collision layer/mask here
	# NOTE: Everything is on layer=1 by default. We have to manually set them 
	# set_collision_layer_value(layer: int, value: bool)
	# set_collision_mask_value(layer: int, value: bool)
	pass
"""
