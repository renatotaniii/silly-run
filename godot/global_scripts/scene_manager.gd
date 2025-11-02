extends Node

# This signal is emitted with ResourceLoader finishes loading whatever content you pass into
# the "load_content" function. The "content" parameter is supposed to be a PackedScene
# which comes from ResourceLoader, you can check line 52 for an example.
signal content_finished_loading(content)

var _load_progress_timer: Timer
var _content_path: String

func _ready() -> void:
	content_finished_loading.connect(_on_finished_loading)

# General content loader. Just provide the scene path E.g. res://godot/main.tscn
# The loaded content is passed into the "_on_finished_loading" function
func load_content(content_path: String):
	print("Loading Content: %s" % content_path)
	_content_path = content_path
	ResourceLoader.load_threaded_request(_content_path)
	
	# Create timer node to track loading progress every 0.1 seconds
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	# Bind current content path and current timer
	# Bind memorizes the parameters passed to the function from this call, 
	# so if load_content is called again to load a different scene
	# the timer assigned to this load request is not overwritten or removed. 
	# Which means it can continue checking the loading progress until it is done.
	_load_progress_timer.timeout.connect(check_loading_progress.bind(_content_path, _load_progress_timer))
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()

## General content load progress checker
func check_loading_progress(content_path: String, timer: Timer):
	var load_progress = []
	var loading_status = ResourceLoader.load_threaded_get_status(content_path, load_progress)
	
	match loading_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("Error: THREAD_LOAD_INVALID_RESOURCE | Tried to load: %s" % [content_path])
			timer.stop()
			timer.queue_free()
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print("Loading.. %s", load_progress[0] * 100)
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Failed to load stage: %s" % content_path)
			timer.stop()
			timer.queue_free()
		ResourceLoader.THREAD_LOAD_LOADED:
			timer.stop()
			timer.queue_free()
			content_finished_loading.emit(ResourceLoader.load_threaded_get(content_path))

# Temporary function to enter main
func enter_game(initial_stage_path: String):
	load_content(initial_stage_path)
	
# Whatever scene you decide to load will pop up here as the param "loaded_scene"
func _on_finished_loading(loaded_scene):
	# Temporary logic to go to main
	get_tree().change_scene_to_file("res://godot/main.tscn")
	await get_tree().process_frame
	get_tree().current_scene.add_child(loaded_scene.instantiate())

#func change_scene(new_scene: PackedScene):
	#get_tree().change_scene_to_packed(new_scene)
