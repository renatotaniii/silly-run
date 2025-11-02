extends TextureButton

@export var stage_name: String:
	set(value):
		$VBoxContainer/Label.text = value
		
@export var stage_file_path: String

signal on_press(stage_file_path: String, origin_button: Node)

func _ready():
	self.pressed.connect(_on_pressed)
	$VBoxContainer/TextureRect/SelectedIndicator.hide()
	
func _on_pressed():
	on_press.emit(stage_file_path, self)

func show_indicator():
	$VBoxContainer/TextureRect/SelectedIndicator.show()
	
func hide_indicator():
	$VBoxContainer/TextureRect/SelectedIndicator.hide()
	
