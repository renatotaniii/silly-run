extends CharacterBody3D

enum CameraModes {
	## Player Camera
	TOP_DOWN,
	## Debug Camera
	DEBUG,
}

# Configurables
@export var jump_impulse = 5.0
@export var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") 

@export_category("Camera Settings")

@export var camera_mode: CameraModes = CameraModes.TOP_DOWN
## :D
@export var camera_sensitivity := 500

@export_category("Speed Modifiers")
## Max speed dictates the player's [member Speed] after fully accelerating. [br]
## Default max speed is 1.0 [i](100% movement speed)[/i]
@export var max_speed := 1.0

## Player's movement speed
@export var speed := 20.0

## Player's rotation speed. Rate is measured in radians per second. [br]
## Default is 2 PI per second
@export var turn_rate := 2 * PI

## Describes time until [member max_speed] is reached. [br]
## Default is 1.0 (1 second to reach max speed)
@export var time_to_max_speed := 1.0

## Describes time until 0 speed is reached. [br]
## Default is 1.0 (1 second to full stop)
@export var time_to_zero_speed := 1.0


@export_category("Misc")

# Ball reference (Set ball node path in the inspector)
@export var ball_node_path: NodePath
@onready var ball: RigidBody3D = get_node(ball_node_path)


# Player state
var speed_modifiers: Array[float] = [0.5]
var turn_rate_modifiers: Array[float] = []
var momentum = 0.0
var input_direction = Vector3.ZERO
var movement_direction = Vector2.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Set the camera mode in the inspector
	if camera_mode == CameraModes.TOP_DOWN:
		$CameraPivot/Camera3D.position = Vector3(0, 20, 0)
	elif camera_mode == CameraModes.DEBUG:
		$CameraPivot/Camera3D.position = Vector3(0, 8, 0)
	$CameraPivot/Camera3D.rotation = Vector3(-PI/2, 0, 0)
	
# Returns a direction for use with e.g. speed
func get_input_direction() -> Vector3:
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return Vector3(input_vector.x, 0, input_vector.y)

func _physics_process(delta: float) -> void:
	# Vertical velocity
	if not is_on_floor():
		# final_v = initial_v + (-gravity * time)
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_impulse
			
	# Testing application of speed modifiers
	if !speed_modifiers.is_empty():
		apply_speed_modifier(speed_modifiers.pop_back(), 5.0)

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
		momentum = min(momentum + time_to_max_speed * delta, max_speed)
		_player_orientation(input_direction, delta)
	else:
		momentum = max(momentum - time_to_zero_speed * delta, 0.0)
	
	movement_direction = ($Pivot.basis * Vector3(0, 0, -1)) * speed * momentum
	velocity.x = movement_direction.x
	velocity.z = movement_direction.z 

func _player_orientation(direction: Vector3, delta):
	# Get angle of input direction
	# I have to invert the input_direction because the input and world directions are the inverse of each other
	var target_angle = atan2(-direction.x, -direction.z)
	# wrapf gets the smallest angle distance to desired rotation
	var angle_diff = wrapf(target_angle - $Pivot.rotation.y, -PI, PI)
	$Pivot.rotation.y += sign(angle_diff) * min(abs(angle_diff), turn_rate * delta)

## Applies [i]modifier[/i] (speed multiplier) to [member max_speed] for [i]duration[/i] (seconds) of player.
## [br]E.g. Modifer: [param 0.2] Duration: [param 5.0] -> Speed is reduced to 20% for 5 seconds
func apply_speed_modifier(modifier: float, duration: float):
	max_speed = max_speed * modifier
	get_tree().create_timer(duration).timeout.connect(func(): max_speed = max_speed / modifier)

## Applies [i]modifier[/i] (speed multiplier) to [member turn_rate] for [i]duration[/i] (seconds) of player.
## [br]E.g. Modifer: [param 0.2] Duration: [param 5.0] -> Turn Rate is reduced to 20% for 5 seconds	
func apply_turn_rate_modifier(modifier: float, duration: float):
	turn_rate = turn_rate * modifier
	get_tree().create_timer(duration).timeout.connect(func(): turn_rate = turn_rate / modifier)
	

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
