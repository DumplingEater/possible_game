# moving.gd
extends State

class_name Moving

var speed = 0.1
var target = null

func enter():
	print("Entering Moving State")

func update(delta):
	if target == null:
		state_machine.change_state("idle")
		return 
	
	var character_node = state_machine.get_parent().get_node("body_3d")
	
	var distance = get_distance_to_target(target)
	if distance > 5:
		state_machine.change_state("idle")
		character_node.set_velocity(Vector3(0, 0, 0))
		return
		
	var direction = target.transform.origin - state_machine.get_parent().transform.origin
	direction = direction.normalized()
	character_node.set_velocity(direction * 1.0)
	character_node.move_and_slide()

func get_distance_to_target(target):
	var distance = state_machine.get_parent().transform.origin.distance_to(target.transform.origin)
	return distance
