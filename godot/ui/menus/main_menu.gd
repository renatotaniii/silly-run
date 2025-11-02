extends Control

@export var debug_mode := true
var stage_buttons: Array[Node]
var _selected_stage: String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Hud.hide()
	if debug_mode:
		SceneManager.call_deferred("enter_game", "res://godot/world/test_stage.tscn")
	$StageSelectionPanel.hide()
	stage_buttons =	get_node("StageSelectionPanel/Panel/MarginContainer/VBoxContainer/MarginContainer/StageList").get_children()
	for button in stage_buttons:
		button.on_press.connect(set_stage)
		button.on_press.connect(visual_feedback)

func set_stage(stage_file_path: String, _unused):
	_selected_stage = stage_file_path
	
func visual_feedback(_unused, origin_button: Node):
	for button in stage_buttons:
		if button != origin_button:
			button.hide_indicator()
	origin_button.show_indicator()


func _on_select_stage_pressed() -> void:
	$StageSelectionPanel.show()

func _on_play_pressed():
	SceneManager.enter_game(_selected_stage)

func _on_back_pressed() -> void:
	$StageSelectionPanel.hide()
	for button in stage_buttons:
		button.hide_indicator()
		
func _on_confirm_pressed():
	$StageSelectionPanel.hide()
	for button in stage_buttons:
		button.hide_indicator()
