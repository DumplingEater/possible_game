# idle.gd
extends State

class_name EngageState

var engage_range = 5
var target = null

func enter():
	print("Entering engage State")

func process_state(delta):
	# really this is checking for transitions so i kinda need a better way to do that.
	if state_machine.distance_to_target() > state_machine.attack_range:
		state_machine.change_state("chase")
