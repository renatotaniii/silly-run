class_name BaseItem
extends RigidBody3D
"""
Base class from which items are built upon on.
For each item, create an associated script that extends this class.

In scripts that inherit this class (like ball.gd), you can access the parent 
variables directly as if it were declared in your script. If they are to be
overwritten, set them in _init().
"""
enum ActionType { 
	NONE, 
	PUSH,
	THROW, 
	SHOOT, 
	PLACE,
}

@export_category("Item Properies")
@export var item_name: String = "Unnamed Item"
@export var max_speed: float = 20.0
@export var max_range: float = 100.0
@export var point_click: bool = false    # for shooting
@export var shoot_speed: float = 50.0    # horizontal speed
@export var throw_speed: float = 20.0    # horizontal speed
@export var cast_time: float = 1.0       # multiplier
@export var despawn_timer: float = 20.0

@export var status_effect: String = "NONE"
@export var affected_stats: Dictionary = {
	Player.Status.MOVE_SPEED: [1.0, 0.0],   # modifier, duration
	Player.Status.TURN_RATE: [1.0, 0.0],
	Player.Status.INPUT: [0.0]
	}

# NOTE: This might not be necessary, but we'll keep it
# @export var duration: float = 0.0
# @export var speed_modifier: float = 1.0
# @export var turn_rate_modifier: float = 1.0


@export_category("World Properties")
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") 
@export var air_drag_constant: float = 0.1
@export var friction_constant: float = 0.1   


# Physics-related
var ground: Plane = Plane(Vector3.UP, 0)         # NOTE: change to height map at some point
var queued_action: ActionType = ActionType.NONE
var queued_velocity: Vector3 = Vector3.ZERO
var queued_direction: Vector3 = Vector3.ZERO
var queued_position: Vector3 = Vector3.ZERO


# Item spawning translations
var height_translation: float = 0.0      
var forward_translation: float = 0.0   # -z forward
var side_translation: float = 0.0      # +x right


func _ready() -> void:
	if has_node("Area3D"):
		$Area3D.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.apply_status_effect(status_effect, affected_stats)
		queue_free()


# Real stuff
func _integrate_forces(state: PhysicsDirectBodyState3D):
	match queued_action:
		ActionType.PUSH:
			state.apply_central_impulse(queued_velocity)
		ActionType.THROW:
			state.apply_central_impulse(queued_direction * throw_speed * self.mass)
		ActionType.SHOOT:
			state.apply_central_impulse(queued_direction * shoot_speed)
		ActionType.PLACE:
			self.global_position = queued_position
		
	# Reset
	queued_action = ActionType.NONE
	queued_direction = Vector3.ZERO
	queued_velocity = Vector3.ZERO
	queued_position = Vector3.ZERO


func push(velocity: Vector3, strength_scalar: float = 1.0):
	queued_action = ActionType.PUSH
	queued_velocity = velocity * strength_scalar


# Calculates a throw direction using horizontal throw_speed and distance to the player
func throw_projectile(global_mouse_position: Vector3):
	queued_action = ActionType.THROW
	self.name = "Yeet"
	var player_to_cursor = global_mouse_position - self.global_position

	var xz_component = Vector3(player_to_cursor.x, 0, player_to_cursor.z)
	var xz_direction = xz_component.normalized()
	var xz_distance = xz_component.length()
	
	xz_distance = min(xz_distance, max_range)
	
	# Closed form: theta = arctan(gravity * total_range / 2 * horizontal_u^2 - height / total_range)
	var g = gravity * gravity_scale
	var height = self.position.y
	var first_term = (g * xz_distance) / (2 * (throw_speed**2))
	var second_term = height / xz_distance
	var angle = clamp(atan(first_term - second_term), -PI/2, PI/4)
	
	xz_direction.y = tan(angle)
	queued_direction = xz_direction
	
# TODO: ITEM TRANSLATIONS
func shoot_projectile(global_mouse_position: Vector3):
	queued_action = ActionType.SHOOT
	self.name = "Bang"
	var player_to_cursor = global_mouse_position - self.global_position
	
	# TODO: get point_click to work
	if self.point_click:
		queued_direction = player_to_cursor.normalized()
	else:
		var xz_component = Vector3(player_to_cursor.x, 0, player_to_cursor.z)
		queued_direction = xz_component.normalized()
	
	
# TODO: fix this shit so it works with max_range
func place_item(global_mouse_position: Vector3):
	queued_action = ActionType.PLACE
	self.name = "Park"
	#var player_to_cursor = global_mouse_position - self.global_position
	#queued_position = player_to_cursor.normalized() * max_range
	queued_position = global_mouse_position
	
	
func apply_translation():
	pass
