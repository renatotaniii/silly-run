extends CharacterBody3D

# Configurables
@export var move_speed = 10.0
@export var jump_impulse = 5.0
@export var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") 
@export var dash_force = 100.0
@export var dash_duration = 0.1
@export var momentum_increase_rate = 3.0
@export var momentum_decay_rate = 4.0
@export var max_momentum = 2.0

# Ball reference (Set ball node path in the inspector)
@export var ball_node_path: NodePath
@onready var ball: RigidBody3D = get_node(ball_node_path)


# Player state
var momentum = 1.0
var dash_timer = 0.0
var is_dashing = false


# Returns a direction for use with e.g. speed
func get_input_direction() -> Vector3:
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
		
	return direction

func _physics_process(delta: float) -> void:
	# Vertical velocity
	if not is_on_floor():
		# final_v = initial_v + (-gravity * time)
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_impulse

	# Player momentum
	var input_direction = get_input_direction()
	if input_direction.length() > 0:
		momentum = min(momentum + momentum_increase_rate * delta, max_momentum)
	else:
		momentum = max(momentum - momentum_decay_rate * delta, 1.0)

	# Dash
	if is_dashing:
		velocity = input_direction * dash_force
	# Stop walking velocity on dash
	else:
		# Apply movement
		var target_velocity = input_direction * move_speed * momentum
		velocity.x = target_velocity.x # can also use linear interpolation
		velocity.z = target_velocity.z

	if Input.is_action_just_pressed("dash"):
		is_dashing = true
		dash_timer = dash_duration

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	
	move_and_slide()
	
	# Ball interactions
	if ball and input_direction.length() > 0:
		var distance = (ball.global_position - global_position).length()
		if distance < 1.0:  # interaction range
			ball.push(input_direction, 1.0)  # strength can be adjusted

func _on_collide(body: Node3D) -> void:
	if body.name == "Ball" and velocity != Vector3.ZERO:
		body.push(2 * velocity)
		# TO DO:
		# Apply a baseline directional force on the situation that the player dashes
		# and the Velocity is detected as ZERO on collision
	
