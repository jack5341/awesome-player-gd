extends State
class_name PlayerCrouch

@export var idle_state: State
@export var walk_state: State
@export var fall_state: State

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if not Input.is_action_pressed("awesome_player_move_crouch"):
		# Check if can stand up (raycast up)
		state_machine.change_state(idle_state)
		return
	
	var input_dir := Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.crouch_speed, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.crouch_speed, player.acceleration * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta)
	
	player.move_and_slide()
