extends CharacterBody3D

enum CameraModes {
	THIRD,
	FIRST,
	TOP_DOWN,
}

@export var sensitivity: int = 500
@export var camera_mode: CameraModes = CameraModes.THIRD

@onready var CameraPivot = $CameraPivot
@onready var Camera = $CameraPivot/Camera3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if camera_mode == CameraModes.THIRD:
		Camera.position = Vector3(0, 4, 2)
		Camera.rotation = Vector3(-20, 0, 0)
	elif  camera_mode == CameraModes.FIRST:
		Camera.position = Vector3(0, 0, 0)
		Camera.rotation = Vector3(0, 0, 0)
	elif camera_mode == CameraModes.TOP_DOWN:
		Camera.position = Vector3(0, 8, 0)
		Camera.rotation = Vector3(-PI/2, 0, 0)
	print("Camera Position: ", Camera.rotation)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += Vector3(0, -9.81, 0) * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (CameraPivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		CameraPivot.rotation.y -= event.relative.x / sensitivity
		CameraPivot.rotation.x -= event.relative.y / sensitivity
