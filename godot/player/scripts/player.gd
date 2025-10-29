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


# Player state
var speed_modifiers: Array[float] = [0.5]
var turn_rate_modifiers: Array[float] = []
var speed_ratio = 0.0
var input_direction = Vector3.ZERO
var movement_direction = Vector2.ZERO

# Tentative variable name
var _boosting = false

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
	
# Returns a direction for use with e.g. speed
func _get_input_direction() -> Vector3:
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
		
	if Input.is_action_just_pressed("dash"):
		apply_instant_boost(60, 0.4)
	
	if !_boosting:
		_player_movement(delta)
	move_and_slide()	
		
	if Input.is_action_just_pressed("throw_object"): 
		var global_mouse_pos = get_mouse_pos()  # Vector3 (point on ground)
		ItemManager.activate_item(self, global_mouse_pos, "Ball")

	move_and_slide()


func _on_collide(body: Node3D) -> void:
	if body is Ball and velocity != Vector3.ZERO:
		body.push(velocity, 2)
		# TODO:
		# Apply a baseline directional force on the situation that the player dashes
		# and the Velocity is detected as ZERO on collision

func _player_movement(delta):
	input_direction = _get_input_direction()
	if input_direction.length() > 0:
		# Player momentum
		speed_ratio = min(speed_ratio + time_to_max_speed * delta, max_speed)
		_player_orientation(input_direction, delta)
	else:
		speed_ratio = max(speed_ratio - time_to_zero_speed * delta, 0.0)
	
	movement_direction = ($Pivot.basis * Vector3(0, 0, -1)) * speed * speed_ratio
	velocity.x = movement_direction.x
	velocity.z = movement_direction.z 

func _player_orientation(direction: Vector3, delta):
	# Get angle of input direction
	# I have to invert the input_direction because the input and world directions are the inverse of each other
	var target_angle = atan2(-direction.x, -direction.z)
	# wrapf gets the smallest angle distance to desired rotation
	var angle_diff = wrapf(target_angle - $Pivot.rotation.y, -PI, PI)
	$Pivot.rotation.y += sign(angle_diff) * min(abs(angle_diff), turn_rate * delta)

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

## Applies [modifier] (speed multiplier) to [member max_speed] of player for [duration] seconds.
## [br]E.g. Modifer: [param 0.2] Duration: [param 5.0] -> Speed is reduced to 20% for 5 seconds
func apply_speed_modifier(modifier: float, duration: float):
	max_speed = max_speed * modifier
	get_tree().create_timer(duration).timeout.connect(func(): max_speed = max_speed / modifier)

## Applies [modifier] (speed multiplier) to [member turn_rate] of player for [duration] seconds.
## [br]E.g. Modifer: [param 0.2] Duration: [param 5.0] -> Turn Rate is reduced to 20% for 5 seconds	
func apply_turn_rate_modifier(modifier: float, duration: float):
	turn_rate = turn_rate * modifier
	get_tree().create_timer(duration).timeout.connect(func(): turn_rate = turn_rate / modifier)

## Applies [i]boost[/i] (flat movement speed) to [member velocity] for [i]duration[/i] (seconds).
## [br]E.g. Boost: [param 40.0] Duration: [param 0.4] -> Player moves forward with a speed of 40 for 0.4 seconds	
func apply_instant_boost(boost: float, duration: float):
	var boost_direction = ($Pivot.basis * Vector3(0, 0, -1)) * boost
	velocity.x = boost_direction.x
	velocity.z = boost_direction.z
	_boosting = true
	get_tree().create_timer(duration).timeout.connect(func(): _boosting = false)
	

func get_mouse_pos():
	# TODO: Use a height map? When clicking on an elevation, parallax is
	#       not being taken into account.
	var plane = Plane(Vector3.UP, 0)  # XZ-plane at Y=0
	var mouse_pos = get_viewport().get_mouse_position()
	var cam_ray_origin = $CameraPivot/Camera3D.project_ray_origin(mouse_pos)     # point
	var cam_ray_direction = $CameraPivot/Camera3D.project_ray_normal(mouse_pos)  # ray
	mouse_pos = plane.intersects_ray(cam_ray_origin, cam_ray_direction)          # point
	
	return mouse_pos
