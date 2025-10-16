extends RigidBody3D

# Configurables for interaction
@export var move_force: float = 50.0       # force applied by player pushes
@export var max_speed: float = 50.0        
@export var drag: float = 0.1             

var velocity_approx = Vector3.ZERO

func _ready():
	sleeping = false
	can_sleep = false # prevent the ball from freezing when completely at rest

func _physics_process(_delta: float):
	velocity_approx = Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	# Drag to prevent infinite sliding
	"""
	if velocity_approx.length() > 0.01:  # only apply drag if significant
		var drag_force = -velocity_approx.normalized() * drag * mass
		apply_central_force(drag_force)
	"""
	
	# Limit horizontal speed
	if velocity_approx.length() > max_speed:
		var horizontal_velocity = velocity_approx.normalized() * max_speed
		linear_velocity.x = horizontal_velocity.x
		linear_velocity.z = horizontal_velocity.z

# Player interaction
func push(direction: Vector3, strength=1.0):
	if direction.length() == 0:
		return
	apply_central_impulse(direction * move_force * strength)
