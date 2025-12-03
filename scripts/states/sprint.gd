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
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if Input.is_action_just_pressed("awesome_player_move_jump"):
		state_machine.change_state(jump_state)
		return
		
	if not Input.is_action_pressed("awesome_player_move_sprint") or not player.can_sprint:
		state_machine.change_state(walk_state)
		return
		
	if Input.is_action_pressed("awesome_player_move_crouch"):
		state_machine.change_state(crouch_state)
		return

	var input_dir := Input.get_vector("awesome_player_move_left", "awesome_player_move_right", "awesome_player_move_up", "awesome_player_move_down")
	if input_dir == Vector2.ZERO:
		state_machine.change_state(idle_state)
		return
	
	# Handle Stamina
	if player.is_stamina_enabled:
		player.current_stamina -= player.stamina_drain_rate * delta
		if player.current_stamina <= 0:
			player.current_stamina = 0
			state_machine.change_state(walk_state)
			return
	
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.sprint_speed, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.sprint_speed, player.acceleration * delta)
	
	player.move_and_slide()
