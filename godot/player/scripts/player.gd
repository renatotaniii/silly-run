class_name Player
extends CharacterBody3D

enum CameraModes {
	## Player Camera
	TOP_DOWN,
	## Debug Camera
	DEBUG,
}

enum Status {
	MOVE_SPEED,
	TURN_RATE,
	INPUT
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
@export var max_speed: float = 1.0

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

var inventory: Inventory = Inventory.new()
var status_effects: StatusEffects = StatusEffects.new()

# Default values to easily reset player status
var _default_max_speed = max_speed
var _default_turn_rate = turn_rate

# Player state
var speed_ratio = 0.0
var input_direction = Vector3.ZERO
var movement_direction = Vector2.ZERO


# Tentative variable name
var _boosting = false

signal update_status_display(current_status_effects: Array)

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
	
	Hud.get_node("Node").connect_player_inventory(inventory)
	Hud.get_node("Node").connect_player_status(update_status_display)
	
	status_effects.status_updated.connect(apply_status_effects)
	
# Returns a direction for use with e.g. speed
func _get_input_direction() -> Vector3:
	var input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return Vector3(input_vector.x, 0, input_vector.y)

func _physics_process(delta: float) -> void:	
	if !_boosting:
		if Input.is_action_just_pressed("dash"):
			apply_instant_boost(60,0.4)
		else:
			_player_movement(delta)

	_on_test_status_input()

	if Input.is_action_just_pressed("throw_object"): 
		var global_mouse_pos = get_mouse_pos()  # Vector3 (point on ground)
		ItemManager.activate_item(self, global_mouse_pos, "WET_FLOOR_SIGN")
		
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_impulse
			
	#if Input.is_action_just_pressed("throw_object"): 
		#var global_mouse_pos = get_mouse_pos()  # Vector3 (point on ground)
		#ItemManager.activate_item(self, global_mouse_pos, "BALL")
	_on_item_input()

	move_and_slide()


func _on_collide(body: Node3D) -> void:
	if body is BaseItem and velocity != Vector3.ZERO:
		body.push(velocity, 1) # velocity, strength_scalar
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

func _on_item_input():
	var global_mouse_pos = get_mouse_pos()  # Vector3 (point on ground)
	if Input.is_action_just_pressed("slot_1"):
		inventory.use_item(self, global_mouse_pos, 1)
	if Input.is_action_just_pressed("slot_2"):
		inventory.use_item(self, global_mouse_pos, 2)
	if Input.is_action_just_pressed("slot_3"):
		inventory.use_item(self, global_mouse_pos, 3)
	if Input.is_action_just_pressed("slot_4"):
		inventory.use_item(self, global_mouse_pos, 4)
	if Input.is_action_just_pressed("slot_5"):
		inventory.use_item(self, global_mouse_pos, 5)
	if Input.is_action_just_pressed("slot_6"):
		inventory.use_item(self, global_mouse_pos, 6)

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
	#		not being taken into account.
	var ground_plane = Plane(Vector3.UP, 0)	# XZ-plane at Y=0
	var mouse_pos = get_viewport().get_mouse_position()
	var cam_ray_origin = $CameraPivot/Camera3D.project_ray_origin(mouse_pos)	# point
	var cam_ray_direction = $CameraPivot/Camera3D.project_ray_normal(mouse_pos)	# ray
	mouse_pos = ground_plane.intersects_ray(cam_ray_origin, cam_ray_direction)	# point
	
	return mouse_pos

# Applies any effect for a given duration
# Parameter details:
#
#	effect_name: String -> This can be any name, it's just what is going to be displayed in the HUD
#	affected_stats: Dictionary[Status, Array[float, float]]:
#
#	I can't do deeply nested typing here so here is more details:
#		The Dictionary you will pass is going to include the following information:
#			Status(Key): This is the Status enum (speed/turnrate/input) it's defined in line 11
#			Data(Value): This is the modifier and duration in a size 2 array.
#				Index 0 corresponds to modifier
#				Index 1 coresponds to duration
	
'''
	Example:
		
	apply_status_effect("EffectName", {
		Player.Status.MOVE_SPEED: [0.5, 3.0]
	})
	
	This function call with apply a movement speed debuff, slowing the player by 50% for 3 seconds.
	
	Note: When applying a status which affects INPUT, you can leave the first index empty
	E.g. {
		Player.Status.MOVE_SPEED: [0.5, 3.0]
		Player.Status.INPUT: [3.0]
	}
	but I recommend to just keep it consistent with the rest of the status modifications 
'''
func apply_status_effect(effect_name: String, affected_stats: Dictionary[Status, Array]):
	# Will change this depending on kevin's code
	for stat in affected_stats.keys():	
		var modifier = affected_stats.get(stat)[0]
		var duration = affected_stats.get(stat)[-1]
		match stat:
			Status.MOVE_SPEED:
				status_effects.add_speed_modifier(modifier)
				get_tree().create_timer(duration).timeout.connect(func(): status_effects.remove_speed_modifier(modifier))
			Status.TURN_RATE:
				status_effects.add_turn_rate_modifier(modifier)
				get_tree().create_timer(duration).timeout.connect(func(): status_effects.remove_turn_rate_modifier(modifier))
			Status.INPUT:
				set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
				get_tree().create_timer(duration).timeout.connect(func(): set_deferred("process_mode", Node.PROCESS_MODE_ALWAYS))
			_:
				print("you got hit by nothing...")
				break
	status_effects.add_status_effect(effect_name)
	var max_duration = affected_stats.values().map(func(arr): return arr[-1]).max()
	get_tree().create_timer(max_duration).timeout.connect(func(): status_effects.remove_status_effect(effect_name))

func apply_status_effects():
	update_status_display.emit(status_effects.current_status_effects)
	max_speed = _default_max_speed * status_effects.get_speed_modifier()
	turn_rate = _default_turn_rate * status_effects.get_turn_rate_modifier()

func pickup_item(item_name: String):
	inventory.add_item(item_name)
	
func _on_test_status_input():
	if Input.is_action_just_pressed("status_slow"):
		apply_status_effect("Test (Slow)", {
			Status.MOVE_SPEED: [0.3, 5.0],
			Status.TURN_RATE: [0.5, 5.0]
		})
	if Input.is_action_just_pressed("status_freeze"):
		apply_status_effect("Test (Freeze)", {
			Status.MOVE_SPEED: [0.5, 7.0],
			Status.TURN_RATE: [0.7, 5.0],
			Status.INPUT: [0, 3.0]
		})
	if Input.is_action_just_pressed("status_ragdoll"):
		apply_status_effect("Test (Ragdoll)", {
			Status.INPUT: [3.0]
		})
	if Input.is_action_just_pressed("status_root"):
		apply_status_effect("Test (Root)", {
			Status.MOVE_SPEED: [0, 5.0]
		})
