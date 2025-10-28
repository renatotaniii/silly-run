extends CharacterBody3D

@export var speed = 11
@export  var fall_accel = 50

var target_velocity = Vector3.ZERO

@export var inventory_dict = {"Pos1" : null, "Pos2" : null, "Pos3" : null, "Pos4" : null, "Pos5" : null, "Pos6" : null}

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
		
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_accel * delta)

	velocity = target_velocity
	move_and_slide()
