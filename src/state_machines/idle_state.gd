# idle.gd
extends State

class_name Idle

var chase_distance = 5

func enter():
	print("Entering Idle State")

func update(delta):
	var closest_character = get_closest_character()
	if closest_character != null:
		state_machine.change_state("chase")
		state_machine.current_state.target = closest_character.get_parent()

func get_closest_character():
	if not state_machine.is_inside_tree():
		get_node("/root").print_tree_pretty()
		return null
	var min_distance = INF
	var closest_character = null
	var characters = state_machine.get_tree().get_nodes_in_group("players")
	for character in characters:
		if character != self: # Avoid checking distance to itself
			var distance = state_machine.get_parent().transform.origin.distance_to(character.get_parent().transform.origin)
			if distance < min_distance and distance < chase_distance:
				min_distance = distance
				closest_character = character
	return closest_character
