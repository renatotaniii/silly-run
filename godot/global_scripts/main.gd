class_name Main
extends Node

static var instance: Main

func _ready():
	instance = self
	Hud.show()
	
