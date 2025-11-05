class_name Main
extends Node

static var instance: Main

@export var enable_split_screen: bool = false

func _ready():
	instance = self
	Hud.show()
	
