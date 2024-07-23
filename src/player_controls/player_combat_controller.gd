extends Node


var data_node: Node = null
var spellbook_node: Node = null
var body_node: Node = null
var cam_node: Node = null

var selected_target: Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	data_node = get_parent().get_node("data")
	spellbook_node = get_parent().get_node("data/spellbook")
	body_node = get_parent().get_node("body_3d")
	cam_node = body_node.get_node("camera")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected_target:
		if Input.is_action_just_pressed("action_1"):
			var proj = spellbook_node.projectile.instantiate()
			add_child(proj)
			var player_pos = body_node.global_transform
			var muzzle_pos = player_pos.translated(body_node.global_transform.basis.z * -1)
			print("Spawning projectile. Player Pos: ", player_pos.origin, " Proj Pos: ", muzzle_pos.origin)
			proj.transform = muzzle_pos
			proj.target = selected_target
		
	if Input.is_action_just_pressed("mouse_left_click"): # Define your mouse click action in the Input Map
		_select_target()
	
	if Input.is_action_just_pressed("escape"):
		selected_target = null

func _select_target():
	var from = cam_node.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + cam_node.project_ray_normal(get_viewport().get_mouse_position()) * 1000
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	var result = get_parent().get_world_3d().direct_space_state.intersect_ray(query)

	if result:
		var clicked_object = result.collider
		if clicked_object:
			selected_target = clicked_object
			print("Clicked on object: ", clicked_object.get_parent().name)
