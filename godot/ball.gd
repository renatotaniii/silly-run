class_name Ball
extends BaseItem  

var velocity = get_linear_velocity()

func _physics_process(_delta: float):
	max_speed = 50.0
	# Drag to prevent infinite slid
	"""
	if velocity.length() > 0.01:  # only apply drag if significant
		var drag_force = -velocity.normalized() * drag * mass
		apply_central_force(drag_force)
	"""
	
	# Limit horizontal speed
	if velocity.length() > max_speed:
		var horizontal_velocity = velocity.normalized() * max_speed
		linear_velocity.x = horizontal_velocity.x
		linear_velocity.z = horizontal_velocity.z
