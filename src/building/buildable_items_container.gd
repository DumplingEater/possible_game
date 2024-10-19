extends Node

var buildable_scenes: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	find_buildable_scenes("res://resources/scenes/buildables")
	add_to_group("buildable_library")

# Function to recursively find all scenes in the buildables folder
func find_buildable_scenes(dir_path: String) -> void:
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()  # Skip hidden files
		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				# If the current file is a directory, recurse into it
				find_buildable_scenes(dir_path + "/" + file_name)
			elif file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
				# If the file is a scene, add its path to the buildable_scenes array
				var scene_path = dir_path + "/" + file_name
				var packed_scene = load(scene_path)
				buildable_scenes.append(packed_scene)
			file_name = dir.get_next()

		dir.list_dir_end()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
