extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var stage_buttons =	get_node("MarginContainer/Panel/MarginContainer/VBoxContainer/MarginContainer/StageList").get_children()
	for button in stage_buttons:
		button.on_press.connect(set_stage)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_stage(stage_name: String, stage_file_path: String):
	print("Stage Name: %s" % stage_name)
	print("Stage File Path: %s" % stage_file_path)
	pass
	
