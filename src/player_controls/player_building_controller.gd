extends Node

signal build_mode_toggled
signal build_menu_toggled

var building: bool = false
var ui_open: bool = false
var current_buildable_scene: PackedScene = null
var current_buildable: Node = null
@export var buildable_node_target: Node = null
var cam_node: Node = null
@export var test_cube : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam_node = get_parent().get_node("body_3d/camera")
	get_node("/root/main/ui/build_ui").connect("set_buildable", self._on_buildable_set)
	self.current_buildable_scene = self.test_cube
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self._handle_inputs(delta)
	self._draw_current_buildable(delta)
	
	if self.building and not self.ui_open and Input.is_action_just_pressed("mouse_left_click"):
		print("building object")
		self._build_object()

func _handle_inputs(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_build_mode"):
		self._toggle_build_mode()
		
	if Input.is_action_just_pressed("toggle_build_menu"):
		# enter build mode if we haven't already
		if not self.building:
			self._toggle_build_mode()
		self.ui_open = not self.ui_open
		build_menu_toggled.emit(self.ui_open)

	if Input.is_action_just_pressed("close_menu"):
		self.ui_open = false
		build_menu_toggled.emit(false)

func _toggle_build_mode():
	if not self.building:
		self.building = true
		self._enter_build_mode()
	else:
		self.building = false
		self._exit_build_mode()
	build_mode_toggled.emit(self.building)

func _get_mouse_build_pos() -> Vector3:
	var from = cam_node.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + cam_node.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	var position: Vector3 = Vector3(0, 0, 0)
	var result = get_parent().get_world_3d().direct_space_state.intersect_ray(query)
	if not result:
		return position
	
	position = result.position
	if Input.is_action_pressed("snap_to_grid"):
		var x: float = float(int(position.x))
		var z: float = float(int(position.z))
		position = Vector3(x, position.y, z)
	return position

func _enter_build_mode() -> void:
	self._set_buildable()
	
func _set_buildable():
	if self.current_buildable:
		remove_child(self.current_buildable)
	
	var buildable: PackedScene = self.current_buildable_scene
	self.current_buildable = buildable.instantiate()
	add_child(self.current_buildable)
	var buildable_pos: Vector3 = self._get_mouse_build_pos()
	self.current_buildable.global_position = buildable_pos

func _exit_build_mode() -> void:
	remove_child(self.current_buildable)
	self.current_buildable = null

func _draw_current_buildable(delta: float) -> void:
	if not self.building:
		return
	
	var pos: Vector3 = self._get_mouse_build_pos()
	if pos.length_squared() > 1:
		self.current_buildable.global_position = pos

func _build_object() -> void:
	if not self.buildable_node_target:
		var buildable_targets = get_tree().get_nodes_in_group("buildable_target")
		self.buildable_node_target = buildable_targets[0]
	var buildable: Node = self.current_buildable
	self.current_buildable = null
	remove_child(buildable)
	self.buildable_node_target.add_child(buildable)
	
	self._set_buildable()
	
func _on_buildable_set(buildable: PackedScene):
	self.current_buildable_scene = buildable
	self.ui_open = false
	self._set_buildable()
