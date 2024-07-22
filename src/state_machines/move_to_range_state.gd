# moving.gd
extends State

class_name MoveToRangeState

func enter():
	print("Entering MoveToRange State")

func process_state(delta):
	if state_machine.target == null:
		push_warning("Null Target")
		state_machine.change_state("idle")
		return 
	
	var distance: float = state_machine.distance_to_target()
	
	var agent_pos = state_machine.agent_body.global_transform.origin
	var total_movement: Vector3 = agent_pos - state_machine.original_position
	var distance_from_origin: float = total_movement.length()
	
	if distance_from_origin > state_machine.max_chase_distance:
		state_machine.change_state("return_to_origin")
		return
	
	# check if we're  too far from the target now
	if distance > state_machine.range_of_regard:
		state_machine.change_state("return_to_origin")
		return
	
	# see if we're at attack range
	if distance <= state_machine.attack_range:
		state_machine.change_state("engage")
		state_machine.current_state.target = state_machine.target
		state_machine.agent_body.set_velocity(Vector3(0, 0, 0))
		return
	
	# otherwise just move
	var direction: Vector3 = state_machine.target.global_transform.origin - state_machine.agent_body.global_transform.origin
	direction = direction.normalized()
	state_machine.agent_body.set_velocity(direction * state_machine.speed)
	state_machine.agent_body.move_and_slide()

