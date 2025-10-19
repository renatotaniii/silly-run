"""
base_item.gd

This module contains the base class from which items are based on.
For each item, create an associated script that extends this class.

NOTE TO GERD: Add any general interaction methods here like pick_up, etc. 
              For now I will write physics-related methods like throw and kick.
                 - Kevin

NOTE TO ANYONE: In scripts that inherit this class (like ball.gd), you can
                access the parent variables directly as if it were declared 
                in your script, e.g, changing the weight without declaring it.

Methods:
- 
- 

"""
class_name BaseItem
extends RigidBody3D

@export var item_name: String = "Unnamed Item"
@export var weight: float = 1.0
@export var fall_acceleration: float = ProjectSettings.get_setting("physics/3d/default_gravity")
