extends Node3D


@export var grid_size: int = 200
@export var min_room_size: int = 15
@export var max_room_size: int = 70
@export var room_count: int = 20
@export var max_iterations: int = 10000
@export var hall_width: float = 6
@export var wall_thickness: float = 1

@export var base_room: PackedScene = null

var char_spawn_point: Vector3 = Vector3.ZERO
var rng = null

# Called when the node enters the scene tree for the first time.
func _ready():
	char_spawn_point = Vector3.ZERO
	var spawn_set = false
	
	var halls = {}
	
	print("Building rooms...")
	rng = RandomNumberGenerator.new()
	var rooms = []
	var iterations: int = 0
	while len(rooms) < room_count:
		var x: int = rng.randi_range(-grid_size, grid_size)
		var z: int = rng.randi_range(-grid_size, grid_size)
		#var dx: int = rng.randi_range(min_room_size, max_room_size)
		#var dz: int = rng.randi_range(min_room_size, max_room_size)
		var dx: float = max(min_room_size, rng.randfn(50, 15))
		var dz: float = max(min_room_size, rng.randfn(dx, 15))
		
		var candidate_room = base_room.instantiate()
		var room_position: Vector3 = Vector3(x, 0.0, z)
		var room_size: Vector3 = Vector3(dx, 1.0, dz)
		add_child(candidate_room)
		candidate_room.construct_room(room_position, room_size)
		
		# see if this room overlaps an existing room, and if so, free it
		var room_overlaps: bool = false
		for room in rooms:
			if room.overlaps_room(candidate_room, hall_width + wall_thickness):
				room_overlaps = true
				candidate_room.free()
				break
				
		if not room_overlaps:
			rooms.append(candidate_room)
		
		iterations += 1
		if iterations >= max_iterations:
			break
	
	print("Building MST graph...")
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
		for graph_node in room_graph:
			
			# compare this graph node to every candidate
			for candidate_node in rooms:
			
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
	
	print("Building halls from MST Graph...\n\n")
	for room in room_graph:
		var adjacent_rooms = room_graph[room]
		for target_room in adjacent_rooms:
			var target_room_above: bool = target_room.global_position.z > room.global_position.z
			var target_room_right: bool = target_room.global_position.x > room.global_position.x
			var room_x_diff: float = target_room.global_position.x - room.global_position.x
			var room_z_diff: float = target_room.global_position.z - room.global_position.z
			var more_horizontally_aligned: bool = abs(room_x_diff) > abs(room_z_diff)
			
			# figure out which face the door should be on for each room
			# face 0, 1, 2, 3 are +z, +x, -z, -x. clockwise starting with up (+z)
			var face_for_origin_door: int = 0
			if more_horizontally_aligned:
				face_for_origin_door = 3 # default left
				if target_room_right:
					face_for_origin_door = 1
			else:
				face_for_origin_door = 2 # default down
				if target_room_above:
					face_for_origin_door = 0
			# for now just get opposite face for other room
			var face_for_target_room: int = (face_for_origin_door + 2) % 4
			var corner_offset: int = int(hall_width / 2.0)
			
			var start_xz: Vector2 = Vector2(0, 0)
			start_xz = _calculate_door_position(
				room,
				face_for_origin_door,
				corner_offset,
				hall_width
			)
			
			var end_xz: Vector2 = Vector2(0, 0)
			end_xz = _calculate_door_position(
				target_room,
				face_for_target_room,
				corner_offset,
				hall_width
			)
			
			var hall_nodes = []
			
			if abs(room_x_diff) < hall_width:
				start_xz = Vector2(room.global_position.x, start_xz[1])
				end_xz = Vector2(start_xz[0], end_xz[1])
				hall_nodes = [start_xz, end_xz]
			elif abs(room_z_diff) < hall_width:
				start_xz = Vector2(start_xz[0], room.global_position.z)
				end_xz = Vector2(end_xz[0], start_xz[1])
				hall_nodes = [start_xz, end_xz]
			else:
				hall_nodes = _calculate_hall_nodes(
					start_xz, end_xz,
					rooms, halls
				)
			
			var N = hall_nodes.size()
			print("Got some hall nodes %d: " % N, hall_nodes)
			for i in range(1, N):
				print("Adding leg")
				var start_node = hall_nodes[i - 1]
				var end_node = hall_nodes[i]
				var center: Vector3 = Vector3(
					(start_node[0] + end_node[0]) / 2,
					0.0, 
					(start_node[1] + end_node[1]) / 2
				)
				var dx = max(1, abs(start_node[0] - end_node[0]))# + hall_width
				var dz = max(1, abs(start_node[1] - end_node[1]))# + hall_width
				print("dx %-5.2f dz %-5.2f" % [dx, dz])
				var size = Vector3(dx, 0.1, dz)
				var hall_leg = base_room.instantiate()
				add_child(hall_leg)
				hall_leg.construct_room(
					center, size
				)
	#
	print("Setting spawn point...")
	# add rooms as children
	for room in rooms:
		if not spawn_set:
			char_spawn_point = room.global_position + Vector3(0, 5, 0)
			spawn_set = true
		# Add the cube to the scene
		#add_child(room)
	
	var character = get_node("../../agents/players/character")
	character.ready.connect(_set_player_spawn)

func _calculate_door_position(
	room, face: int,
	corner_offset: int, hall_width: int
) -> Vector2:
	var start_door_x: float = 0
	var start_door_z: float = 0
	var half_width: float = (hall_width / 2)
	
	# top or bottom case
	if face == 0 or face == 2:
		start_door_z = room.min_z() - half_width
		if face == 0:
			start_door_z = room.max_z() + half_width
		start_door_x = rng.randi_range(
			room.min_x() + corner_offset,
			room.max_x() - corner_offset
		)
	else:  # left / right cases
		start_door_x = room.min_x() - half_width
		if face == 1:
			start_door_x = room.max_x() + half_width
		start_door_z = rng.randi_range(
			room.min_z() + corner_offset,
			room.max_z() - corner_offset
		)
	return Vector2(start_door_x, start_door_z)

func _calculate_hall_nodes(
	start_xz: Vector2,
	target_xz: Vector2,
	rooms,
	halls
):
	var walker_xz: Vector2 = Vector2(start_xz[0], start_xz[1])
	
	var move_option_deltas: Array[Vector2] = [
		Vector2(0, 1),
		Vector2(1, 0),
		Vector2(0, -1),
		Vector2(-1, 0)
	]
	
	var directions = ["up", "right", "down", "left"]
	
	# iterate until the node is within one step of the finish
	var current_direction: int = -1
	var hall_nodes = []
	print("Start Node: ", start_xz, " End Node: ", target_xz)
	var iterations = 0
	while not _is_near_end(walker_xz, target_xz):
		print("Walker position: ", walker_xz)
		var best_index: int = -1
		var best_weight: float = 1e9
		var best_delta: Vector2 = Vector2()
		var best_candidate: Vector2 = Vector2()
		
		# calculate the predicted weight of each option
		for delta_index in range(move_option_deltas.size()):
			var delta: Vector2 = move_option_deltas[int(delta_index)]
			var candidate_xz: Vector2 = walker_xz + delta
			var candidate_node_count = hall_nodes.size() + 1
			if delta_index != current_direction: candidate_node_count += 1
			var heuristic_weight: float = _heuristic_weight(
				candidate_xz, target_xz,
				rooms, halls, hall_width, candidate_node_count
			)
			var weight_from_start: float = start_xz.distance_to(candidate_xz)
			
			var predicted_weight: float = weight_from_start + heuristic_weight
			print("g(n): %10.5f + h(n): %10.5f = %10.5f at index %d with delta %5.1f, %5.1f, candidate: %5.1f, %5.1f, candidate node count %d" % \
			[weight_from_start, heuristic_weight, predicted_weight, delta_index,
			delta[0], delta[1], candidate_xz[0], candidate_xz[1], candidate_node_count])
			if predicted_weight <= best_weight:
				best_weight = predicted_weight
				best_index = int(delta_index)
				best_candidate = candidate_xz
				best_delta = delta
		iterations += 1
		if iterations == 1000:
			return []
		
		#print("went: ", directions[best_index], " 	Best weight: ", best_weight, " Best Index: ", best_index, " Best Candidate: ", best_candidate, " Best Delta: ", best_delta)
		
		# check if moving in this best direction would hit a hall,
		# and, if so, would that hall hit the room we actually want to go to
		# if both are true, we can just end. if it hits a hall but that hall
		# doesn't go where we want, basically just ignore that we hit the hall
		# and make a junction, still need to work through that probably
		
		# if the direction changed, mark a dir change
		if current_direction != best_index:
			current_direction = best_index
			hall_nodes += [best_candidate]
		
		# go ahead and move
		walker_xz = best_candidate
		
	hall_nodes += [target_xz]
	return hall_nodes

func _would_candidate_hit_room_buffer(
	candidate_xz: Vector2,
	rooms
):
	var half_hall = hall_width / 2.0
	var hall_buffer = half_hall + wall_thickness
	var candidate_minx = candidate_xz[0] - hall_buffer
	var candidate_maxx = candidate_xz[0] + hall_buffer
	var candidate_minz = candidate_xz[1] - hall_buffer
	var candidate_maxz = candidate_xz[1] + hall_buffer
	var room_buffer = wall_thickness
	
	for room in rooms:
		if candidate_minx > room.max_x() + room_buffer:
			continue
		if candidate_maxx < room.min_x() - room_buffer:
			continue
		if candidate_minz > room.max_z() + room_buffer:
			continue
		if candidate_maxz < room.min_z() - room_buffer:
			continue
		return true
			
	return false
		
func _heuristic_weight(
	candidate_xz: Vector2,
	target_xz: Vector2,
	rooms,
	halls,
	hall_width,
	node_count
) -> float:
	var dist = candidate_xz.distance_to(target_xz)
	var weight = dist * 2
	weight += node_count * 1.2
	#if _would_candidate_hit_room_buffer(candidate_xz, rooms):
		#if (candidate_xz[0] == target_xz[0] or candidate_xz[1] == target_xz[1]) and dist < 3:
			#print("hit a room but at a door so its ok")
		#else:
			#print("hit room : (")
			#weight *= 20
	return weight

func _is_near_end(
	candidate_xz: Vector2,
	target_xz: Vector2
) -> bool:
	var dist = candidate_xz.distance_to(target_xz)
	#print("distance to end: ", dist)
	return bool(dist <= 1.0)
	

func _set_player_spawn():
	var character = get_node("../../agents/players/character")
	character.transform = character.transform.translated(char_spawn_point)
	
	var test_enemy = preload("res://resources//scenes//test_enemy.tscn")
	var instance =  test_enemy.instantiate()
	instance.transform.origin = Vector3(char_spawn_point.x + 6, 5, char_spawn_point.z)
	var mobs = get_node("../../agents/mobs")
	mobs.add_child(instance)
	return
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
