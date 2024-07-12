# state_machine.gd
extends Node

var current_state = null
var states = {}

"""
Notes on this:
	I am starting to wonder if states should be nodes and then the state machine
	basically just links the nodes to each other.
	also state machines operate on a block so this thing should probably have a reference
	to the data class.
"""

func _ready():
	print('starting state machine')
	states["idle"] = preload("res://src/state_machines/idle_state.gd").new()
	states["chase"] = preload("res://src/state_machines/chase_state.gd").new()
	for state in states.values():
		state.state_machine = self
	change_state("idle")

func change_state(new_state_name):
	if current_state != null:
		current_state.exit()
	current_state = states[new_state_name]
	current_state.enter()

func _process(delta):
	if current_state != null:
		current_state.update(delta)
