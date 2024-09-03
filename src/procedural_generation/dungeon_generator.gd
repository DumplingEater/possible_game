extends Node3D


@export var grid_size: int = 200
@export var min_room_size: int = 15
@export var max_room_size: int = 70
@export var room_count: int = 20
@export var max_iterations: int = 10000
@export var hall_width: float = 6

@export var base_room: PackedScene = null

var char_spawn_point: Vector3 = Vector3.ZERO
var rng = null

# Called when the node enters the scene tree for the first time.
func _ready():
	char_spawn_point = Vector3.ZERO
	var spawn_set = false
	
	print("Building rooms...")
	rng = RandomNumberGenerator.new()
	var rooms = []
	var iterations: int = 0
	while len(rooms) < room_count:
		var x: int = rng.randi_range(-grid_size, grid_size)
		var z: int = rng.randi_range(-grid_size, grid_size)
		var dx: int = rng.randi_range(min_room_size, max_room_size)
		var dz: int = rng.randi_range(min_room_size, max_room_size)
		
		var candidate_room = base_room.instantiate()
		var room_position: Vector3 = Vector3(x, 0.0, z)
		var room_size: Vector3 = Vector3(dx, 1.0, dz)
		add_child(candidate_room)
		candidate_room.construct_room(room_position, room_size)
		
		# see if this room overlaps an existing room, and if so, free it
		var room_overlaps: bool = false
		for room in rooms:
			if room.overlaps_room(candidate_room, hall_width):
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
			
			var start_xz: Array[float] = [0, 0]
			start_xz = _calculate_door_position(
				room,
				face_for_origin_door,
				corner_offset,
				hall_width
			)
			
			var end_xz: Array[float] = [0, 0]
			end_xz = _calculate_door_position(
				target_room,
				face_for_target_room,
				corner_offset,
				hall_width
			)
			
			var door = base_room.instantiate()
			add_child(door)
			var p = Vector3(start_xz[0], 0.0, start_xz[1])
			door.height = 10.0
			door.construct_room(
				p,
				Vector3(hall_width, 10, hall_width),
			)
			var door2 = base_room.instantiate()
			add_child(door2)
			var p2 = Vector3(end_xz[0], 0.0, end_xz[1])
			door2.height = 10.0
			door2.construct_room(
				p2,
				Vector3(hall_width, 10, hall_width),
			)
			
			
	# i guess for conceptual sake i am picturing this top down +x to right +z 'up'
	#for room in room_graph:
		#var adjacent_rooms = room_graph[room]
		#for target_room in adjacent_rooms:
#
			#var rooms_overlap_on_x_axis = !(room.max_x() < target_room.min_x() or room.min_x() > target_room.max_x())
			#var rooms_overlap_on_z_axis = !(room.max_z() < target_room.min_z() or room.min_z() > target_room.max_z())
			#
			#var x_overlap_amount = abs(room.max_x() - target_room.min_x()) if rooms_overlap_on_x_axis else 0.0
			#var z_overlap_amount = abs(room.max_z() - target_room.min_z()) if rooms_overlap_on_z_axis else 0.0
			#
			## if the rooms overlap enough to fit a hall just do a straight hall
			#if x_overlap_amount > hall_width + 2 or z_overlap_amount > hall_width + 2:
				#
				## just line up our 4 x values and sort and our x bounds for hall
				## pos are the middle two. same for z actually for the bounds of
				## the hall
				#var x_edges = [room.min_x(), room.max_x(), target_room.min_x(), target_room.max_x()]
				#var z_edges = [room.min_z(), room.max_z(), target_room.min_z(), target_room.max_z()]
				#
				#x_edges.sort()
				#z_edges.sort()
				#
				#var hall_x = (x_edges[1] + x_edges[2]) / 2
				#var hall_z = (z_edges[1] + z_edges[2]) / 2
				#
				## calculate position and size of hall
				#var hall_size: Vector3 = Vector3(0, 0, 0)
				#if rooms_overlap_on_x_axis:
					#var hall_length = abs(z_edges[1] - z_edges[2])
					#hall_size = Vector3(hall_width, 1.0, hall_length)
				#elif rooms_overlap_on_z_axis:
					#var hall_length = abs(x_edges[1] - x_edges[2])
					#hall_size = Vector3(hall_length, 1.0, hall_width)
				#
				#var hall_position = Vector3(hall_x, 0.0, hall_z)	
				#var hall_room = base_room.instantiate()
				#add_child(hall_room)
				#hall_room.construct_room(hall_position, hall_size)
				#continue
			#
			#
			## the cases where rooms don't directly overlap correlate
			## to the target room being off of one of the four corners of this
			## room, so we need a bent hall
			#
			#var x_diff = abs(room.global_position.x - target_room.global_position.x)
			#var z_diff = abs(room.global_position.z - target_room.global_position.z)
			#
			## gets closest corner
			#var start_x = min(room.max_x(), target_room.global_position.x)
			#start_x = max(room.min_x(), start_x)
			#var start_z = min(room.max_z(), target_room.global_position.z)
			#start_z = max(room.min_z(), start_z)
			#
			#var should_go_right = bool(target_room.global_position.x > room.global_position.x)
			#var should_go_up = bool(target_room.global_position.z > room.global_position.z)
			#
			#var first_leg_start_position = Vector3()
			#var first_leg_end_position = Vector3()
			#var second_leg_start_position = Vector3()
			#var second_leg_end_position = Vector3()
			#var first_leg_scale = Vector3()
			#var second_leg_scale = Vector3()
			#var first_leg_along_z = false
			#var second_leg_along_z = false
			#if randf_range(0.0, 1.0) < 0.5:
				## moving in z first, snap x to center
				#first_leg_along_z = true
				#var target_z = target_room.global_position.z
				#start_x = room.global_position.x
				#
				#if should_go_up:
					#first_leg_end_position = Vector3(start_x, 0.0, target_z - hall_width / 2.0)
				#else:
					#first_leg_end_position = Vector3(start_x, 0.0, target_z + hall_width / 2.0)
				#
				#first_leg_start_position = Vector3(start_x, 0.0, start_z)
				#first_leg_scale = Vector3(hall_width, 1.0, abs(first_leg_end_position.z - start_z))
					#
				#var target_x = 0.0
				#if should_go_right:
					#target_x = target_room.min_x()
					#second_leg_start_position = Vector3(start_x + hall_width / 2.0, 0.0, target_z)
				#else:
					#target_x = target_room.max_x()
					#second_leg_start_position = Vector3(start_x - hall_width / 2.0, 0.0, target_z)
				#
				#second_leg_end_position = Vector3(target_x, 0.0, target_z)
				#second_leg_scale = Vector3(abs(second_leg_end_position.x - second_leg_start_position.x), 1.0, hall_width)
			#else:  # going horizontal first
				#second_leg_along_z = true
				#var target_x = target_room.global_position.x
				#start_z = room.global_position.z
				#
				#if should_go_right:
					#first_leg_end_position = Vector3(target_x - hall_width / 2.0, 0.0, start_z)
				#else:
					#first_leg_end_position = Vector3(target_x + hall_width / 2.0, 0.0, start_z)
				#
				#first_leg_start_position = Vector3(start_x, 0.0, start_z)
				#first_leg_scale = Vector3(abs(first_leg_end_position.x - first_leg_start_position.x), 1.0, hall_width)
				#
				#var target_z = 0.0	
				#if should_go_up:
					#target_z = target_room.min_z()
					#second_leg_start_position = Vector3(target_x, 0.0, start_z + hall_width / 2.0)
				#else:
					#target_z = target_room.max_z()
					#second_leg_start_position = Vector3(target_x, 0.0, start_z - hall_width / 2.0)
				#
				#second_leg_end_position = Vector3(target_x, 0.0, target_z)
				#second_leg_scale = Vector3(hall_width, 1.0, abs(second_leg_end_position.z - second_leg_start_position.z))	
			#
			#var first_hall_leg = base_room.instantiate()
			#add_child(first_hall_leg)
			#var first_leg_center = (first_leg_start_position + first_leg_end_position) / 2.0
			#first_hall_leg.height = 1.0
			#first_hall_leg.construct_room(
				#first_leg_center,
				#first_leg_scale,
				#first_leg_along_z,
				#not first_leg_along_z
			#)
			#
			#var second_hall_leg = base_room.instantiate()
			#add_child(second_hall_leg)
			#var second_leg_center = (second_leg_start_position + second_leg_end_position) / 2.0
			#second_hall_leg.construct_room(
				#second_leg_center,
				#second_leg_scale,
				#second_leg_along_z,
				#not second_leg_along_z
			#)
			#
			##var starting_point: Vector3(start_x, 0.0, start_z)
			##var elbow_point = Vector3
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

func _calculate_door_position(room, face: int,
corner_offset: int, hall_width: int) -> Array[float]:
	var start_door_x: float = 0
	var start_door_z: float = 0
	var half_width: float = hall_width / 2
	
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
	return [start_door_x, start_door_z]

func _calculate_hall_nodes(
	start_xz: Array[float],
	end_xz: Array[float],
	rooms
	):
	var weight_func = func _predict_weight(
		candidate_x: float, candidate_z: float,
		target_x: float, target_z: float,
		rooms,
		hall_width
		) -> float:
		var dx: float = candidate_x - target_x
		var dz: float = candidate_z - target_z
		var dist_squared: float = dx * dx + dz * dz
		var dist = sqrt(dist_squared)
		
		return dist
	return

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
