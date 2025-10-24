extends CharacterBody3D

enum CameraModes {
	TOP_DOWN,
	DEBUG,
}

# Player configurables
@export var camera_mode: CameraModes = CameraModes.TOP_DOWN
@export var move_speed = 10.0
@export var jump_impulse = 5.0
@export var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") 
@export var dash_force = 100.0
@export var dash_duration = 0.1
@export var momentum_increase_rate = 3.0
@export var momentum_decay_rate = 4.0
@export var max_momentum = 2.0
@export var camera_sensitivity := 500

# Player state
var momentum = 1.0
var dash_timer = 0.0
var is_dashing = false

# Node declarations
var Ball = preload("res://godot/items/ball.tscn")


func _init() -> void:
	pass


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # from _CAPTURED, _VISIBLE
	# Set the camera mode in the inspector
	if camera_mode == CameraModes.TOP_DOWN:
		$CameraPivot/Camera3D.position = Vector3(0, 30, 0)
		$CameraPivot/Camera3D.rotation = Vector3(-0.9*PI/2, 0, 0)
	elif camera_mode == CameraModes.DEBUG:
		$CameraPivot/Camera3D.position = Vector3(0, 8, 0)
		$CameraPivot/Camera3D.rotation = Vector3(-PI/2, 0, 0)


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
		momentum = max(momentum - (momentum_decay_rate * delta), 1.0)

	# Dash
	if is_dashing:
		print(input_direction)
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
		
	if Input.is_action_just_pressed("throw_object"): 
		var origin = self.get_node("Pivot/ThrowOrigin")
		var world_location = self.get_node("../ThrownInstances")
		
		var global_mouse_pos = get_mouse_pos()  # Vector3 (point on ground)
		var player_to_cursor = global_mouse_pos - self.global_position  # Vector3

		# TODO: Combine with inventory system. For now, we'll just use a ball.
		var item = Ball.instantiate()

		item.use_throw(item, origin, world_location, player_to_cursor, global_mouse_pos)

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	
	move_and_slide()


func _on_collide(body: Node3D) -> void:
	if body is Ball and velocity != Vector3.ZERO:
		body.push(velocity, 2)
		# TODO:
		# Apply a baseline directional force on the situation that the player dashes
		# and the Velocity is detected as ZERO on collision


func _input(event):
	# Camera is moveable in DEBUG mode
	if camera_mode == CameraModes.DEBUG:
		if event is InputEventMouseMotion:
			$CameraPivot.rotation.y -= event.relative.x / camera_sensitivity
			$CameraPivot.rotation.x -= event.relative.y / camera_sensitivity
		if event is InputEventMouseButton:
			if event.is_pressed():
				var wheel_input = 0.0
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					wheel_input += 1
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					wheel_input -= 1
				var mouse_dir = $CameraPivot.basis.y * wheel_input
				$CameraPivot/Camera3D.global_position -= mouse_dir


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
	
	# Original character pivoting is preserved in TOP_DOWN mode
	if direction.length() > 0:
		if camera_mode == CameraModes.TOP_DOWN:
			direction = direction.normalized()
		elif camera_mode == CameraModes.DEBUG:
			var camera_direction = ($CameraPivot.global_transform.basis * Vector3(direction.x, 0, direction.z))
			# For some reason multiplying the camera pivot basis y value to 0 doesn't remove it 
			# so I just did it manually below
			print(camera_direction)
			direction = Vector3(camera_direction.x, 0, camera_direction.z)
		
		$Pivot.basis = Basis.looking_at(direction)
	return direction


func get_mouse_pos():
	# TODO: Use a height map? When clicking on an elevation, parallax is
	#       not being taken into account.
	var plane = Plane(Vector3.UP, 0)  # XZ-plane at Y=0
	var mouse_pos = get_viewport().get_mouse_position()
	var cam_ray_origin = $CameraPivot/Camera3D.project_ray_origin(mouse_pos)     # point
	var cam_ray_direction = $CameraPivot/Camera3D.project_ray_normal(mouse_pos)  # ray
	mouse_pos = plane.intersects_ray(cam_ray_origin, cam_ray_direction)          # point
	
	return mouse_pos
