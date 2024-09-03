extends Node3D
class_name BaseRoom


@export var building_block: PackedScene = null
var width: float = 0
var depth: float  = 0
var height: float = 3
var entry_points_list = null
#var walls: list = []

var half_width: float:
	get:
		return self.width / 2.0
	set(value):
		pass

var half_depth: float:
	get:
		return self.depth / 2.0
	set(value):
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _shape_room():
	pass

func min_x() -> float:
	return self.global_transform.origin.x - (self.width / 2.0)

func max_x() -> float:
	return self.global_transform.origin.x + (self.width / 2.0)
	
func min_z() -> float:
	return self.global_transform.origin.z - (self.depth / 2.0)
	
func max_z() -> float:
	return self.global_transform.origin.z + (self.depth / 2.0)

func overlaps_room(other: BaseRoom, padding: float = 0.0) -> bool:
	if other.max_x() < (self.min_x() - padding):
		return false
	if other.min_x() > (self.max_x() + padding):
		return false
	if other.max_z() < (self.min_z() - padding):
		return false
	if other.min_z() > (self.max_z() + padding):
		return false
	return true
	
func in_plane_distance_from_room(other: BaseRoom) -> float:
	var xdiff = self.global_transform.origin.x - other.global_transform.origin.x
	var zdiff = self.global_transform.origin.z - other.global_transform.origin.z
	return sqrt(xdiff * xdiff + zdiff * zdiff)
	
func construct_room(room_position: Vector3, room_scale: Vector3,
					build_x_walls: bool = true, build_z_walls: bool = true) -> void:
	self.global_position = room_position
	self.width = room_scale.x
	self.depth = room_scale.z
	
	build_floor(room_scale)
	#build_walls(build_x_walls, build_z_walls)
	
func build_floor(room_scale: Vector3):
	var floor = building_block.instantiate()
	add_child(floor)
	floor.set_scale(room_scale)
	floor.global_position = self.global_position

func build_walls(x_walls: bool, z_walls: bool) -> void:
	# looking top down with +z up, +x right
	var left_wall_origin = Vector3(self.min_x() - 0.5, self.height / 2.0, self.global_position.z)
	var right_wall_origin = Vector3(self.max_x() + 0.5, self.height / 2.0, self.global_position.z)
	var top_wall_origin = Vector3(self.global_position.x, self.height / 2.0, self.max_z() + 0.5)
	var bottom_wall_origin = Vector3(self.global_position.x, self.height / 2.0, self.min_z() - 0.5)
	
	var side_wall_scale = Vector3(1.0, self.height, self.depth)
	var top_wall_scale = Vector3(self.width, self.height, 1.0)
	
	if x_walls:
		var left_wall = self.building_block.instantiate()
		add_child(left_wall)
		left_wall.global_position = left_wall_origin
		left_wall.set_scale(side_wall_scale)

		var right_wall = self.building_block.instantiate()
		add_child(right_wall)
		right_wall.global_position = right_wall_origin
		right_wall.set_scale(side_wall_scale)
	if z_walls:
		var top_wall = self.building_block.instantiate()
		add_child(top_wall)
		top_wall.global_position = top_wall_origin
		top_wall.set_scale(top_wall_scale)
		
		
		var bottom_wall = self.building_block.instantiate()
		add_child(bottom_wall)
		bottom_wall.global_position = bottom_wall_origin
		bottom_wall.set_scale(top_wall_scale)
