extends TextureButton

@export var stage_name: String:
	set(value):
		$VBoxContainer/Label.text = value
		
@export var stage_file_path: String

signal on_press(stage_name: String, stage_file_path: String)

func _ready():
	self.pressed.connect(_on_pressed)
	$VBoxContainer/TextureRect/SelectedIndicator.hide()
	
func _on_pressed():
	on_press.emit(stage_name, stage_file_path)
	$VBoxContainer/TextureRect/SelectedIndicator.show()
