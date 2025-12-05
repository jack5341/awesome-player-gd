extends State
class_name PlayerReload

@export var idle_state: State
@export var walk_state: State

func enter() -> void:
	# Placeholder for reload logic
	# In a real game, you'd wait for a signal or timer
	# For now, we just wait a bit and return to idle
	await get_tree().create_timer(1.0).timeout
	
	if player.velocity.length() > 0.1:
		state_machine.change_state(walk_state)
	else:
		state_machine.change_state(idle_state)
