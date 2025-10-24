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
@export var item_name: String = "Unnamed Item"
@export var max_speed: float = 20.0
@export var max_range: float = 100.0

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") 
@export var has_gravity: bool = true
@export var air_drag_constant: float = 0.1
@export var friction_constant: float = 0.1   

@export var shoot_speed: float = 50.0
@export var throw_speed: float = 20.0
@export var cast_time: float = 1.0       # multiplier
@export var despawn_timer: float = 20.0

# Physics-related
var ground: Plane = Plane(Vector3.UP, 0)   # change to height map at some point
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
			state.apply_impulse(queued_direction * throw_speed)
		
	# Reset
	queued_action = ActionType.NONE
	queued_direction = Vector3.ZERO


func push(velocity: Vector3, strength_scalar: float = 1.0):
	queued_action = ActionType.PUSH
	queued_velocity = velocity * strength_scalar


func get_theoretical_throw_distance(origin: Vector3):
	var height = ground.distance_to(origin)
	
	# displacement = initial_v * time + 0.5 * (acceleration * time^2)
	# time = sqrt(2 * acceleration * distance + initial_u^2) - initial_u / acceleration
	var time_to_ground = (sqrt(2 * (gravity * gravity_scale) * height)) / (gravity * gravity_scale)   # u = 0
	var theoretical_distance = throw_speed * time_to_ground
	
	# Debugging
	print("Time: ", time_to_ground)
	print("Theoretical distance: ", theoretical_distance)
	
	return theoretical_distance


func calculate_throw_angle(xz_distance: Vector3, throw_origin: Vector3):
	
	
	pass


func use_throw(
	item_node: BaseItem, 
	throw_origin: Marker3D, 
	world: Node3D, 
	player_to_cursor: Vector3, 
	global_mouse_pos: Vector3
	):
	throw_speed = 20.0
		
	world.add_child(item_node)
	item_node.global_position = throw_origin.global_position
	item_node.name = "Yeet"
	
	# TODO: Fix either player_to_cursor or item_node.position. 
	#       Currently the ball is undershooting. 
	queued_action = ActionType.THROW
	queued_direction = player_to_cursor.normalized()
	
	var dx = player_to_cursor.x
	var dz = player_to_cursor.z
	var xz_distance = Vector3(dx, 0, dz).length()
	
	var theoretical_distance = get_theoretical_throw_distance(item_node.position)
	
	# Choose throw angle above or below XZ-plane
	if xz_distance < theoretical_distance:
		print("-- Near --")
		throw_speed = 25
		queued_direction = (global_mouse_pos - item_node.global_position).normalized()
	elif xz_distance <= max_range:
		print("-- Far --")
	else:
		print("Something is wrong...")

func shoot_projectile(direction: Vector3):
	pass
