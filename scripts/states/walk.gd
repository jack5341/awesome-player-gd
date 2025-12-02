extends State
class_name PlayerWalk

@export var idle_state: State
@export var sprint_state: State
@export var jump_state: State
@export var fall_state: State
@export var crouch_state: State

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if Input.is_action_just_pressed("ui_accept"):
		state_machine.change_state(jump_state)
		return
		
	if Input.is_action_pressed("sprint") and player.can_sprint: # Assuming 'sprint' action
		state_machine.change_state(sprint_state)
		return
		
	if Input.is_action_pressed("crouch"):
		state_machine.change_state(crouch_state)
		return

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir == Vector2.ZERO:
		state_machine.change_state(idle_state)
		return
	
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = move_toward(player.velocity.x, direction.x * player.walk_speed, player.acceleration * delta)
		player.velocity.z = move_toward(player.velocity.z, direction.z * player.walk_speed, player.acceleration * delta)
	
	player.move_and_slide()
