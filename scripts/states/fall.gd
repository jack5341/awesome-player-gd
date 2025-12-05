extends State
class_name PlayerFall

@export var idle_state: State
@export var walk_state: State
@export var jump_state: State

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	if player.is_on_floor():
		var input_dir = Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
		if input_dir != Vector2.ZERO:
			state_machine.change_state(walk_state)
		else:
			state_machine.change_state(idle_state)
		return
	
	# Coyote time logic could go here or in Jump state checks
	
	# Air control
	var input_dir := Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
	var direction := (player.camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var target_rotation = atan2(-direction.x, -direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, player.rotation_speed * delta)
	
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.walk_speed, player.acceleration * player.air_control * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.walk_speed, player.acceleration * player.air_control * delta)
	
	player.velocity += player.get_gravity() * delta
	player.move_and_slide()
