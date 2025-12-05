extends State
class_name PlayerCrouch

@export var idle_state: State
@export var walk_state: State
@export var fall_state: State

func _ready() -> void:
	if true:
		animation_name = "bare_hand_crouch"
	player.play_animation(animation_name)

func enter() -> void:
	player.play_animation(animation_name)

func update(_delta: float) -> void:
	if animation_name and player.animation_player:
		if not player.animation_player.is_playing() or player.animation_player.current_animation != animation_name:
			player.play_animation(animation_name)

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if not Input.is_action_pressed("awesome_player_move_crouch"):
		# Check if can stand up (raycast up)
		state_machine.change_state(idle_state)
		return
	
	var input_dir := Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
	var direction := (player.camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Rotate player to face direction
	if direction:
		var target_rotation = atan2(-direction.x, -direction.z)
		player.rotation.y = lerp_angle(player.rotation.y, target_rotation, player.rotation_speed * delta)
	
	# Update animation based on movement
	if direction:
		if animation_name != "crouch_walk":
			animation_name = "crouch_walk"
			player.play_animation(animation_name)
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.crouch_speed, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.crouch_speed, player.acceleration * delta)
	else:
		if animation_name != "crouch":
			animation_name = "crouch"
			player.play_animation(animation_name)
		player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)
		player.velocity.z = move_toward(player.velocity.z, 0, player.friction * delta)
	
	player.move_and_slide()
