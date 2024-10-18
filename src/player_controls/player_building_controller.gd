extends Node

signal build_menu_toggle

var building: bool = false
var current_buildable: Node3D = null
@export var buildable_node_target: Node = null
var cam_node: Node = null
@export var test_cube : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam_node = get_parent().get_node("body_3d/camera")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self._handle_inputs(delta)
	self._draw_current_buildable(delta)
	
	if self.building and Input.is_action_just_pressed("mouse_left_click"):
		self._build_object()

func _handle_inputs(delta: float) -> void:
	if Input.is_action_just_pressed("open_build_menu"):
		if not self.building:
			self.building = true
			self._enter_build_mode()
		else:
			self.building = false
			self._exit_build_mode()
		build_menu_toggle.emit(self.building)

func _get_mouse_build_pos() -> Vector3:
	var from = cam_node.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + cam_node.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	var result = get_parent().get_world_3d().direct_space_state.intersect_ray(query)

	if result:
		return result.position
	return Vector3(0, 0, 0)

func _enter_build_mode() -> void:
	self.current_buildable = test_cube.instantiate()
	add_child(self.current_buildable)
	var buildable_pos: Vector3 = self._get_mouse_build_pos()
	self.current_buildable.global_position = buildable_pos

func _exit_build_mode() -> void:
	self.current_buildable = null

func _draw_current_buildable(delta: float) -> void:
	if not self.building:
		return
	
	var pos: Vector3 = self._get_mouse_build_pos()
	if pos.length_squared() > 1:
		self.current_buildable.global_position = pos

func _build_object() -> void:
	if not self.buildable_node_target:
		var buildable_containers = get_tree().get_nodes_in_group("buildable_container")
		self.buildable_node_target = buildable_containers[0]
	var buildable: Node = self.current_buildable
	self.current_buildable = null
	remove_child(buildable)
	self.buildable_node_target.add_child(buildable)

	self.current_buildable = test_cube.instantiate()
	self.current_buildable.global_position = self._get_mouse_build_pos()
	add_child(self.current_buildable)
	
