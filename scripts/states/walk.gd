extends State
class_name PlayerWalk

@export var idle_state: State
@export var sprint_state: State
@export var jump_state: State
@export var fall_state: State
@export var crouch_state: State

func enter() -> void:
	animation_name = "walk"
	player.play_animation(animation_name)

func update(_delta: float) -> void:
	if animation_name and player.animation_player:
		if not player.animation_player.is_playing() or player.animation_player.current_animation != animation_name:
			player.play_animation(animation_name)

func physics_update(delta: float) -> void:
	var input_dir := Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
	var horizontal_velocity = Vector2(player.velocity.x, player.velocity.z).length()
	
	# Calculate direction relative to camera
	var direction := (player.camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Rotate player to face direction
	if direction:
		var target_rotation = atan2(-direction.x, -direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, player.rotation_speed * delta)
	
	# Update blend value - force forward blend (0, -1) when moving
	var blend_input = Vector2(0, -1) if input_dir.length() > 0.1 else Vector2.ZERO
	player.update_blend_value(blend_input, horizontal_velocity, player.walk_speed, delta, "Walk")
	
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if Input.is_action_just_pressed("awesome_player_move_jump"):
		state_machine.change_state(jump_state)
		return
		
	if Input.is_action_pressed("awesome_player_move_crouch"):
		state_machine.change_state(crouch_state)
		return
	
	if Input.is_action_pressed("awesome_player_move_sprint") and player.can_sprint:
		# Allow sprint if stamina is not required, or if stamina is available
		if not player.sprint_requires_stamina or (player.is_stamina_enabled and player.current_stamina > 0):
			state_machine.change_state(sprint_state)
			return

	if input_dir == Vector2.ZERO:
		state_machine.change_state(idle_state)
		return
	
	# Direction is already calculated above
	# var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.walk_speed, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.walk_speed, player.acceleration * delta)
	
	player.move_and_slide()
