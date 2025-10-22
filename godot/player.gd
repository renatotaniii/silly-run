extends CharacterBody3D

enum CameraModes {
	TOP_DOWN,
	DEBUG,
}

# Configurables
@export var camera_mode: CameraModes = CameraModes.TOP_DOWN
@export var move_speed = 10.0
@export var turn_rate = 0.1
@export var jump_impulse = 5.0
@export var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") 
@export var dash_force = 100.0
@export var dash_duration = 0.1
@export var momentum_increase_rate = 3.0
@export var momentum_decay_rate = 4.0
@export var max_momentum = 2.0
@export var camera_sensitivity := 500

# Ball reference (Set ball node path in the inspector)
@export var ball_node_path: NodePath
@onready var ball: RigidBody3D = get_node(ball_node_path)


# Player state
var momentum = 1.0
var input_direction = Vector3.ZERO
var movement_direction = Vector2.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Set the camera mode in the inspector
	if camera_mode == CameraModes.TOP_DOWN:
		$CameraPivot/Camera3D.position = Vector3(0, 20, 0)
		$CameraPivot/Camera3D.rotation = Vector3(-PI/2, 0, 0)
	elif camera_mode == CameraModes.DEBUG:
		$CameraPivot/Camera3D.position = Vector3(0, 8, 0)
		$CameraPivot/Camera3D.rotation = Vector3(-PI/2, 0, 0)

# Returns a direction for use with e.g. speed
func get_input_direction() -> Vector3:
	var direction = Vector3.ZERO
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = Vector3(input_vector.x, 0, input_vector.y)
	return direction

func _physics_process(delta: float) -> void:
	# Vertical velocity
	if not is_on_floor():
		# final_v = initial_v + (-gravity * time)
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_impulse

	_player_movement(delta)
	move_and_slide()	

func _on_collide(body: Node3D) -> void:
	if body.name == "Ball" and velocity != Vector3.ZERO:
		body.push(2 * velocity)
		# TO DO:
		# Apply a baseline directional force on the situation that the player dashes
		# and the Velocity is detected as ZERO on collision

func _player_movement(delta):
	input_direction = get_input_direction()
	if input_direction.length() > 0:
		# Player momentum
		momentum = min(momentum + momentum_increase_rate * delta, max_momentum)
		_player_orientation(input_direction)
		movement_direction = ($Pivot.basis * Vector3(0, 0, -1)) * move_speed * momentum
		velocity.x = movement_direction.x
		velocity.z = movement_direction.z 
	else:
		momentum = max(momentum - momentum_decay_rate * delta, 1.0)
		velocity.x = 0
		velocity.z = 0

func _player_orientation(direction: Vector3):
	# Get angle of input direction
	# I have to invert the input_direction because the input and world directions are the inverse of each other
	var target_angle = atan2(-direction.x, -direction.z)
	# wrapf gets the smallest angle distance to desired rotation
	var angle_diff = wrapf(target_angle - $Pivot.rotation.y, -PI, PI)

	$Pivot.rotation.y += sign(angle_diff) * min(abs(angle_diff), turn_rate)


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
