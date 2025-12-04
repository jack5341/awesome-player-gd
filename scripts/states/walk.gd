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
	
	# Calculate direction relative to camera
	var direction := (player.camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Only rotate player when moving forward or strafing, NOT when moving backward
	# input_dir.y < 0 means moving forward, input_dir.y > 0 means moving backward
	if direction and input_dir.y <= 0:
		var target_rotation = atan2(-direction.x, -direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, player.rotation_speed * delta)
	
	# Update blend value with proper input direction for strafing
	player.update_blend_value(input_dir, 0.5, delta)
	
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
		# Only allow sprint when moving forward or strafing, NOT backward
		# input_dir.y > 0 means moving backward
		if input_dir.y > 0:
			pass # Don't allow sprint when moving backward, continue walking
		elif not player.sprint_requires_stamina or (player.is_stamina_enabled and player.current_stamina > 0):
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
