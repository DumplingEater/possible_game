# state.gd
extends Node

class_name State

var state_machine = null
var started: bool = false

func _ready():
	state_machine = get_parent()
	
func start():
	pass

func enter():
	pass

func exit():
	pass

#func process_state(delta):
	#pass
