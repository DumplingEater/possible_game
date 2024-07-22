extends State

class_name StateMachine

@export var initial_state: Node = null
var current_state = null
var states = {}
#var agent

# Called when the node enters the scene tree for the first time.
func _ready():
	get_states_from_children()
	if initial_state != null:
		change_state(initial_state.name)
	else:
		push_error("State machine on ", get_parent().name, " had no initial state.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if  current_state != null:
		current_state.process_state(delta)

func change_state(new_state_name: String):
	if current_state != null:
		current_state.exit()
	current_state = states[new_state_name]
	current_state.enter()

func get_states_from_children():
	for child in get_children():
		if child.has_method("get_script"):
			var script = child.get_script()
			states[child.name] = child
	
	# Print to verify
	print("States found on ", self.name)
	for state_name in states:
		var state = states[state_name]
		print("state_name: ", state_name, " value: ", state)


# methods on state.
#func enter():
#	pass

#func exit():
#	pass

#func update(delta):
#	pass
