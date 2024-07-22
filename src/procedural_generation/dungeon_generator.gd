extends Node3D


@export var grid_size: int = 200
@export var min_room_size: int = 15
@export var max_room_size: int = 70
@export var room_count: int = 20
@export var max_iterations: int = 100000
@export var hall_width: float = 5

var char_spawn_point: Vector3 = Vector3.ZERO

class RoomNode:
	var x: int = 0
	var z: int = 0
	var half_width: int = 5
	var half_depth: int = 5
	
	func _init(x: int, z: int, w: int, d: int):
		self.x = x
		self.z = z
		self.half_width = w
		self.half_depth = d
		
	func min_x() -> int:
		return self.x - self.half_width
	
	func max_x() -> int:
		return self.x + self.half_width
		
	func min_z() -> int:
		return self.z - self.half_depth
		
	func max_z() -> int:
		return self.z + self.half_depth
	
	func overlaps_room(other: RoomNode) -> bool:
		if other.max_x() < self.min_x():
			return false
		if other.min_x() > self.max_x():
			return false
		if other.max_z() < self.min_z():
			return false
		if other.min_z() > self.max_z():
			return false
		return true
		
	func in_plane_distance_from_room(other: RoomNode) -> float:
		var xdiff = self.x - other.x
		var zdiff = self.z - other.z
		return sqrt(xdiff * xdiff + zdiff * zdiff)

# Called when the node enters the scene tree for the first time.
func _ready():
	char_spawn_point = Vector3.ZERO
	var spawn_set = false
	
	var rng = RandomNumberGenerator.new()
	var rooms = []
	var iterations = 0
	while len(rooms) < room_count:
		var x: int = rng.randi_range(-grid_size, grid_size)
		var z: int = rng.randi_range(-grid_size, grid_size)
		var dx: int = rng.randi_range(min_room_size, max_room_size)
		var dz: int = rng.randi_range(min_room_size, max_room_size)
		
		var candidate_room: RoomNode = RoomNode.new(x, z, dx, dz)
		var room_overlaps: bool = false
		for room in rooms:
			if room.overlaps_room(candidate_room):
				room_overlaps = true
				break
		if not room_overlaps:
			rooms.append(candidate_room)
		
		iterations += 1
		if iterations >= max_iterations:
			break
	
	var room_graph = {}
	var rooms_added_to_graph = []
	
	var start_room = rooms[0]
	room_graph[start_room] = []
	rooms_added_to_graph.append(start_room)
	
	while len(rooms_added_to_graph) < len(rooms):
		var best_candidate_node = null
		var best_graph_node
		var best_distance = 1e9
		
		# iterate each node in the graph and each room in rooms and find the closest pair
		# then add that pair and keep looping. i think this is prim's algorithm idk
		for graph_node: RoomNode in room_graph:
			
			# compare this graph node to every candidate
			for candidate_node: RoomNode in rooms:
			
				# don't check nodes already in graph
				if candidate_node in rooms_added_to_graph:
					continue
				
				# if we find a candidate closesst to this node, cache it
				var distance_between_rooms = graph_node.in_plane_distance_from_room(candidate_node)
				if distance_between_rooms < best_distance:
					best_distance = distance_between_rooms
					best_candidate_node  = candidate_node
					best_graph_node = graph_node
		
		# add new room to graph
		room_graph[best_candidate_node] = []
		rooms_added_to_graph.append(best_candidate_node)
		
		# add link between rooms. though it's undirected, i think it'll help to keep
		# track of it as a directed graph so it's easier to know which edges i've added
		room_graph[best_graph_node].append(best_candidate_node)
	
	# i guess for conceptual sake i am picturing this top down +x to right +z 'up'
	for room in room_graph:
		var adjacent_rooms = room_graph[room]
		for target_room in adjacent_rooms:
			var x_overlap = !(room.max_x() < target_room.min_x() or room.min_x() > target_room.max_x())
			var z_overlap = !(room.max_z() < target_room.min_z() or room.min_z() > target_room.max_z())
			
			# if there's overlap we can just do a straight hall so check that first
			if x_overlap or z_overlap:
				
				# just line up our 4 x values and sort and our x bounds for hall
				# pos are the middle two. same for z actually for the bounds of
				# the hall
				var x_edges = [room.min_x(), room.max_x(), target_room.min_x(), target_room.max_x()]
				var z_edges = [room.min_z(), room.max_z(), target_room.min_z(), target_room.max_z()]
				
				x_edges.sort()
				z_edges.sort()
				
				var hall_x = (x_edges[1] + x_edges[2]) / 2
				var hall_z = (z_edges[1] + z_edges[2]) / 2
				
				var mesh_instance = MeshInstance3D.new()
				var mesh = BoxMesh.new()
				#mesh.size = Vector3(room.half_width, 1, room.half_depth)
				if x_overlap:
					var hall_length = abs(z_edges[1] - z_edges[2]) + 1
					mesh.size = Vector3(hall_width, 1, hall_length)
				elif z_overlap:
					var hall_length = abs(x_edges[1] - x_edges[2]) + 1
					mesh.size = Vector3(hall_length, 1, hall_width)
				mesh_instance.mesh = mesh
				mesh_instance.position = Vector3(hall_x, 0.0, hall_z)
				mesh_instance.create_convex_collision()
				add_child(mesh_instance)
				
				continue
			
			var x_diff = abs(room.x - target_room.x)
			var z_diff = abs(room.z - target_room.z)
			
			# if x_diff is less, they're probably vertically stacked
			if x_diff < z_diff:
				pass
			else:  # probably horizontally lined up
				pass
	
	for room in rooms:
		var mesh_instance = MeshInstance3D.new()
		var mesh = BoxMesh.new()

		# Set the size of the cube based on the room dimensions
		mesh.size = Vector3(room.half_width * 2, 1, room.half_depth * 2)
		mesh_instance.mesh = mesh

		# Set the position of the cube
		mesh_instance.position = Vector3(room.x, 0.0, room.z)
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
	
	var test_enemy = preload("res://scenes//test_enemy.tscn")
	var instance =  test_enemy.instantiate()
	instance.transform.origin = Vector3(char_spawn_point.x + 6, 5, char_spawn_point.z)
	var mobs = get_node("../../agents/mobs")
	mobs.add_child(instance)
	return
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
