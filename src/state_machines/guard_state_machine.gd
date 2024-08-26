# state_machine.gd
extends StateMachine

@export var max_chase_distance: float = 10
@export var range_of_regard: float = 15
@export var attack_range: float = 5

@export var speed: float = 3
var original_position: Vector3 = Vector3(0, 0, 0)
var target: CharacterBody3D = null
var agent_body: CharacterBody3D = null
var agent_data: Node = null

func _ready():
	super._ready()
	var start_pos = get_parent().global_transform.origin
	original_position = Vector3(start_pos.x, 0.0, start_pos.z)
	agent_body = get_parent().get_node("body_3d")
	agent_data = get_parent().get_node("data")

func _process(delta: float):
	self.process_current_state(delta)

func distance_to_target():
	var distance = agent_body.global_transform.origin.distance_to(target.global_transform.origin)
	return distance
