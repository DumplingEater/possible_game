extends State

class_name AttackState
@export var projectile : PackedScene

func enter():
	pass
	
func exit():
	pass
	
func process_state(delta: float):
	var proj = projectile.instantiate()
	add_child(proj)
	proj.transform = state_machine.state_machine.agent_body.global_transform.translated(state_machine.state_machine.agent_body.global_transform.basis.z * 1)
	proj.target = state_machine.target
	
	state_machine.last_attack_time = Time.get_unix_time_from_system()
	state_machine.change_state("wait_for_cooldown")
