extends Node3D


@export var grid_size: int = 50
@export var min_room_size: int = 10
@export var max_room_size: int = 40
@export var room_count: int = 15
@export var max_iterations: int = 100000

var char_spawn_point: Vector3 = Vector3.ZERO

class RoomNode:
	var x: int = 0
	var y: int = 0
	var width: int = 5
	var depth: int = 5
	
	func _init(x: int, y: int, w: int, d: int):
		self.x = x
		self.y = y
		self.width = w
		self.depth = d
		
	func min_x() -> int:
		return self.x - self.width
	
	func max_x() -> int:
		return self.x + self.width
		
	func min_y() -> int:
		return self.y - self.depth
		
	func max_y() -> int:
		return self.y + self.depth
	
	func overlaps_room(other: RoomNode) -> bool:
		if other.max_x() < self.min_x():
			return false
		if other.min_x() > self.max_x():
			return false
		if other.max_y() < self.min_y():
			return false
		if other.min_y() > self.max_y():
			return false
		return true

# Called when the node enters the scene tree for the first time.
func _ready():
	char_spawn_point = Vector3.ZERO
	var spawn_set = false
	
	var rng = RandomNumberGenerator.new()
	var rooms = []
	var iterations = 0
	while len(rooms) < room_count:
		var x: int = rng.randi_range(-grid_size, grid_size)
		var y: int = rng.randi_range(-grid_size, grid_size)
		var dx: int = rng.randi_range(min_room_size, max_room_size)
		var dy: int = rng.randi_range(min_room_size, max_room_size)
		
		var candidate_room: RoomNode = RoomNode.new(x, y, dx, dy)
		var room_overlaps: bool = false
		for room in rooms:
			if room.overlaps_room(candidate_room):
				room_overlaps = true
				break
		if not room_overlaps:
			rooms.append(candidate_room)
			var printer = "Adding room with x %d y %d dx %d dy %d"
			var formatted = printer % [candidate_room.x, candidate_room.y, candidate_room.width, candidate_room.depth]
		iterations += 1
		if iterations >= max_iterations:
			break
		
	for room in rooms:
		var mesh_instance = MeshInstance3D.new()
		var mesh = BoxMesh.new()

		# Set the size of the cube based on the room dimensions
		mesh.size = Vector3(room.width, 1, room.depth)
		mesh_instance.mesh = mesh

		# Set the position of the cube
		mesh_instance.position = Vector3(room.x, 0.0, room.y)
		mesh_instance.create_convex_collision()
		
		if not spawn_set:
			char_spawn_point = mesh_instance.position + Vector3(0, 5, 0)
			spawn_set = true
		
		# Add the cube to the scene
		add_child(mesh_instance)
	
	var character = get_node("../../agents/players/character")
	character.ready.connect(_set_player_spawn)

func _set_player_spawn():
	var character = get_node("../../agents/players/character")
	character.transform = character.transform.translated(char_spawn_point)
	
	var test_enemy = preload("res://test_enemy.tscn")
	var instance =  test_enemy.instantiate()
	instance.transform.origin = Vector3(char_spawn_point.x + 6, 5, char_spawn_point.z)
	get_node("/root").print_tree_pretty()
	var mobs = get_node("../../agents/mobs")
	mobs.add_child(instance)
	get_node("/root").print_tree_pretty()
	return
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
