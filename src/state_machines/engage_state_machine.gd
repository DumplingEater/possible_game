# idle.gd
extends StateMachine

class_name EngageStateMachine

var engage_range = 5
var target = null
var last_attack_time = null
@export var cooldown = 1.5

func enter():
	print("Entering engage State") 
	self.change_state("wait_for_cooldown")

func process_state(delta):
	
	self.process_current_state(delta)
	
	# really this is checking for transitions so i kinda need a better way to do that.
	if state_machine.distance_to_target() > state_machine.attack_range:
		print("Need to chase!")
		state_machine.change_state("chase")
