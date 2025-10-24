class_name BaseItem
extends RigidBody3D
"""
Base class from which items are built upon on.
For each item, create an associated script that extends this class.

NOTE: In scripts that inherit this class (like ball.gd), you can
              access the parent variables directly as if it were declared 
              in your script, e.g, changing the weight without declaring it.

Methods:
- push(velocity: Vector3, strength_scalar: float = 1.0)
- use_throw(item_node: BaseItem, origin: Marker3D, xz_direction: Vector3, xz_distance: float)
- 

"""
enum ActionType { 
	NONE, 
	PUSH,
	THROW, 
	SHOOT, 
	PLACE,
}

# Item references
#@export var node_path: NodePath
#@onready var item_node: RigidBody3D = get_node(node_path) # not sure if this is needed

# Item properties
@export var max_speed: float = 20.0
@export var max_range: float = 100.0

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") # change using gravity_scale 
@export var has_gravity: bool = true
@export var air_drag_constant: float = 0.1
@export var friction_constant: float = 0.1   

@export var shoot_speed: float = 50.0
@export var throw_speed: float = 15.0
@export var cast_time: float = 1.0       # multiplier
@export var despawn_timer: float = 20.0

# Physics-related
var queued_action: ActionType = ActionType.NONE
var queued_velocity: Vector3 = Vector3.ZERO
var queued_direction: Vector3 = Vector3.ZERO
var max_check_distance: float = 100.0 

# DEBUG STUFF
var spawn_time = 0.0


func _ready() -> void:
	spawn_time = Time.get_ticks_msec() / 1000.0  # seconds
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# TODO: Write logic for despawning items
	var collision_time = Time.get_ticks_msec() / 1000.0
	var lifetime = collision_time - spawn_time
	print("Collided with: ", body.name)
	print("Lifetime: ", lifetime, "seconds\n")

	queue_free()  # delete node
	
# Real stuff
func _integrate_forces(state: PhysicsDirectBodyState3D):
	match queued_action:
		ActionType.PUSH:
			state.apply_impulse(queued_velocity)
		ActionType.THROW:
			var impulse = queued_direction * throw_speed
			state.apply_impulse(impulse)
		
	# Reset
	queued_action = ActionType.NONE
	queued_direction = Vector3.ZERO

func push(velocity: Vector3, strength_scalar: float = 1.0):
	queued_action = ActionType.PUSH
	queued_velocity = velocity * strength_scalar

func use_throw(item_node: BaseItem, origin: Marker3D, xz_direction: Vector3, xz_distance: float):
	origin.add_child(item_node)             # generate the node
	item_node.position = origin.position
	item_node.name = "Yeet"
	
	queued_action = ActionType.THROW
	queued_direction = xz_direction

	# displacement = initial_v * time + 0.5 * (acceleration * time^2)
	# time = 0.5 * (sqrt(2 * acceleration * displacement + initial_v^2) * initial_v) 
	var height = item_node.position.y                 # TODO: change to ground intercept
	var ground_velocity = xz_direction * throw_speed  # throw parallel to ground
	var time_to_ground = (sqrt(2 * (gravity * gravity_scale) * height)) / gravity # u = 0
	var theoretical_distance = (ground_velocity * time_to_ground).length()          # a = 0
	
	print("Ground speed: ", ground_velocity.length())
	print("Velocity vector: ", ground_velocity) 
	print("Time: ", time_to_ground)
	print("Theoretical distance: ", theoretical_distance)
	
	# Choose throw angle above or below XZ-plane
	if xz_distance < theoretical_distance:
		print("-- Near --")
	elif xz_distance >= theoretical_distance:
		print("-- Far --")
	else:
		print("Something is wrong...")

func shoot_projectile(direction: Vector3):
	pass
