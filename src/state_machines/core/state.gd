# state.gd
extends Node

class_name State

var state_machine = null

func _ready():
	state_machine = get_parent()

func enter():
	pass

func exit():
	pass

func process_state(delta):
	pass
