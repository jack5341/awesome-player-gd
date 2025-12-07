extends State
class_name PlayerSprint

@export var idle_state: State
@export var walk_state: State
@export var jump_state: State
@export var fall_state: State
@export var crouch_state: State

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	var input_dir := Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
	
	# Calculate direction relative to camera
	var direction := (player.camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Rotate player to face direction
	if direction:
		var target_rotation = atan2(-direction.x, -direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, player.rotation_speed * delta)
	
	# Update blend value with proper input direction for strafing
	player.update_blend_value(input_dir, 1.0, delta)
	
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if Input.is_action_just_pressed("awesome_player_move_jump"):
		state_machine.change_state(jump_state)
		return
		
	if not Input.is_action_pressed("awesome_player_move_sprint") or not player.can_sprint:
		state_machine.change_state(walk_state)
		return
	
	# If moving backward, switch to walk state (can't sprint backward)
	if input_dir.y > 0:
		state_machine.change_state(walk_state)
		return
		
	if Input.is_action_pressed("awesome_player_move_crouch"):
		state_machine.change_state(crouch_state)
		return
	
	# Handle Stamina - ONLY drain if sprint_requires_stamina is true AND stamina is enabled
	if player.sprint_requires_stamina and player.stats:
		var required = player.stats.stamina_drain_rate * delta
		if not player.stats.consume_stamina(required):
			# Transition to walk state so player keeps moving
			state_machine.change_state(walk_state)
			return

	# Check for no input AFTER stamina check
	if input_dir == Vector2.ZERO:
		state_machine.change_state(idle_state)
		return
	
	# Direction is already calculated above
	# var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.sprint_speed, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.sprint_speed, player.acceleration * delta)
	
	player.move_and_slide()
