extends State
class_name PlayerJump

@export var fall_state: State
@export var idle_state: State
@export var walk_state: State

func enter() -> void:
	player.velocity.y = player.jump_velocity
	# Play jump sound?

func physics_update(delta: float) -> void:
	if player.velocity.y < 0:
		state_machine.change_state(fall_state)
		return
	
	# Air control
	var input_dir := Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.walk_speed, player.acceleration * player.air_control * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.walk_speed, player.acceleration * player.air_control * delta)
	
	player.velocity += player.get_gravity() * delta
	player.move_and_slide()
