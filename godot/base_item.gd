"""
base_item.gd

This module contains the base class from which items are based on.
For each item, create an associated script that extends this class.

NOTE TO GERD: Add any general interaction methods here like pick_up, etc. 
              For now I will write physics-related methods like throw and kick.
                 - Kevin

GENERAL NOTE: In scripts that inherit this class (like ball.gd), you can
              access the parent variables directly as if it were declared 
              in your script, e.g, changing the weight without declaring it.

Methods:
- push(velocity: Vector3, strength_scalar: float = 1.0)
- 

"""
class_name BaseItem
extends RigidBody3D

# Item references
@export var node_path: NodePath
@onready var item_node: RigidBody3D = get_node(node_path) # not sure if this is needed


# Item configurables
@export var max_speed: float = 20.0        
@export var weight: float = 1.0
@export var fall_acceleration: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var drag: float = 0.1  
@export var shoot_force: float = 50.0
@export var throw_force: float = 50.0


# Cool shit
func push(velocity: Vector3, strength_scalar: float = 1.0):
	apply_impulse(velocity * strength_scalar)


func use_throw(node: RigidBody3D, direction: Vector3):
	pass


func shoot_projectile(node: RigidBody3D, direction: Vector3):
	pass
