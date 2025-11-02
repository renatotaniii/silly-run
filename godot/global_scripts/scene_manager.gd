extends Node

signal content_finished_loading(content: PackedScene)

var _load_progress_timer: Timer
var _stage_file_path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_stage(stage_file_path: String):
	_stage_file_path = stage_file_path
	ResourceLoader.load_threaded_request(_stage_file_path)
	
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(check_loading_progress)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()
	
func check_loading_progress():
	var load_progress = []
	var loading_status = ResourceLoader.load_threaded_get_status(_stage_file_path,load_progress)
	
	match loading_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("Error: THREAD_LOAD_INVALID_RESOURCE | Tried to load: %s" % [_stage_file_path])
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print("Loading.. %s", load_progress[0] * 100)
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Failed to load stage: %s" % _stage_file_path)
		ResourceLoader.THREAD_LOAD_LOADED:
			content_finished_loading.emit(ResourceLoader.load_threaded_get(_stage_file_path).instantiate())
	
	
	

func change_scene(new_scene: PackedScene):
	get_tree().change_scene_to_packed(new_scene)
