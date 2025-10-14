extends CharacterBody3D

@export var speed = 14 # m/s
@export var fall_acceleration = 75 # m/s^2
@export var jump_impulse = 20 # N*s, basically "instant" momentum

var target_velocity = Vector3.ZERO

# Currently, applied force is dependent on the speed of the player
# TODO: - add a "push" to apply on the ball
#       - fix jank when it comes to interacting with the ball

# _physics runs on every frame, dependent on the application
# _physics_process runs at a specified frame rate (default 60/s)
func _physics_process(delta):
	var direction = Vector3.ZERO # store input direction
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1 # absolute direction
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	# Scale according to multiple inputs
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
	
	# Ground velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	# Vertical velocity
	if not is_on_floor():
		# fall_acceleration is in m/s^2, delta is in s
		# final_v = initial_v + (-g * T)
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	velocity = target_velocity
	move_and_slide()
	
