# moving.gd
extends State

class_name ReturnToOrigin

func enter():
	print("Entering ReturnToOrigin State")

func process_state(delta):
	
	var agent_pos: Vector3 = state_machine.agent_body.global_transform.origin
	var original_pos: Vector3 = state_machine.original_position
	
	var xdiff: float = agent_pos.x - original_pos.x
	var zdiff: float = agent_pos.z - original_pos.z
	var in_plane_dist = sqrt(xdiff * xdiff + zdiff * zdiff)
	
	if in_plane_dist <= 1:
		state_machine.change_state("idle")
		state_machine.agent_body.velocity = Vector3(0, 0, 0)
		return
	
	# otherwise just move
	var direction: Vector3 = state_machine.original_position - state_machine.agent_body.global_transform.origin
	direction = direction.normalized()
	state_machine.agent_body.set_velocity(direction * state_machine.speed)
	state_machine.agent_body.move_and_slide()
