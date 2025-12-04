extends State
class_name PlayerIdle

@export var walk_state: State
@export var jump_state: State
@export var fall_state: State
@export var crouch_state: State

func enter() -> void:
	animation_name = "idle"
	player.play_animation(animation_name)

func update(_delta: float) -> void:
	if animation_name and player.animation_player:
		if not player.animation_player.is_playing() or player.animation_player.current_animation != animation_name:
			player.play_animation(animation_name)

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
	
	# Instantly stop horizontal movement
	player.velocity.x = 0.0
	player.velocity.z = 0.0
	player.move_and_slide()
