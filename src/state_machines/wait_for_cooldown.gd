extends State

class_name WaitForCooldown

func enter():
	print("Entering Wait For Cooldown")
	
func exit():
	print("Exiting Wait For Cooldown")
	
func process_state(delta: float):
	if state_machine.last_attack_time == null:
		state_machine.change_state("attack")
		return
		
	var now = Time.get_unix_time_from_system()
	var elapsed_since_attack = now - state_machine.last_attack_time
	if elapsed_since_attack >= state_machine.cooldown:
		state_machine.change_state("attack")
