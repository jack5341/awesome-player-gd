extends State
class_name PlayerIdle

@export var walk_state: State
@export var jump_state: State
@export var fall_state: State
@export var crouch_state: State

func enter() -> void:
	# Decelerate to zero
	pass

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if Input.is_action_just_pressed("awesome_player_move_jump"):
		state_machine.change_state(jump_state)
		return
		
	if Input.is_action_pressed("awesome_player_move_crouch"):
		state_machine.change_state(crouch_state)
		return

	var input_dir := Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
	if input_dir != Vector2.ZERO:
		state_machine.change_state(walk_state)
	
	# Apply friction/deceleration
	player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta)
	player.move_and_slide()
