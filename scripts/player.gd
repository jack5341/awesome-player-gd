@tool
extends CharacterBody3D
class_name Player

signal health_changed(current_health: float, max_health: float)
signal stamina_changed(current_stamina: float, max_stamina: float)
signal dead()
signal interacted(object: Node)
signal interaction_focused(object: Node)
signal interaction_unfocused()

@export_subgroup("Health & Stats")
@export var max_health: float = 100.0 ## Maximum health points the player can have
@export var current_health: float = 100.0: ## Current health points of the player
	set(value):
		current_health = value
		if current_health <= 0:
			is_dead = true
			dead.emit()
			return
		health_changed.emit(current_health, max_health)
@export var is_stamina_enabled: bool = true ## Whether the stamina system is active
@export var max_stamina: float = 100.0 ## Maximum stamina points the player can have
@export var current_stamina: float = 100.0: ## Current stamina points of the player
	set(value):
		current_stamina = value
		stamina_changed.emit(current_stamina, max_stamina)
@export var stamina_regen_rate: float = 10.0 ## Rate at which stamina regenerates per second
@export var stamina_drain_rate: float = 20.0 ## Rate at which stamina drains per second when used
@export var damage_multiplier: float = 1.0 ## Multiplier applied to all damage dealt by the player

@export_subgroup("Movement")
@export var walk_speed: float = 5.0 ## Base walking speed in units per second
@export var sprint_speed: float = 12.0 ## Sprinting speed when holding sprint key (consumes stamina)
@export var crouch_speed: float = 2.5 ## Movement speed while crouching
@export var acceleration: float = 10.0 ## How quickly the player reaches target speed
@export var friction: float = 10.0 ## How quickly the player decelerates when stopping
@export var rotation_speed: float = 10.0 ## How quickly the player rotates to face movement direction
@export var air_control: float = 0.3 ## Movement control multiplier while in air (0.0 = no control, 1.0 = full control)
@export var jump_count: int = 1 ## Current number of jumps available (for double/triple jump)
@export var jump_velocity: float = 4.5 ## Current number of jumps available (for double/triple jump)
@export var max_jumps: int = 1 ## Maximum number of jumps the player can perform
@export var coyote_time: float = 0.2 ## Time window after leaving ground where jump is still allowed (in seconds)
@export var can_sprint: bool = true ## Whether the player can sprint
@export var sprint_requires_stamina: bool = true ## Whether sprinting requires stamina (if false, can sprint infinitely)

@export_subgroup("Combat")
@export var weapon: Weapon = null:
	set(value):
		weapon = value
var last_attack_time: float = 0.0

@export_subgroup("Interaction")
@export var interaction_range: float = 3.0 ## Maximum distance the player can interact with objects
@export var interaction_layer: int = 1 ## Physics layer mask for objects that can be interacted with
var current_interactable: Node = null

@export_subgroup("Camera")
@export var camera_sensitivity: float = 0.003 ## Mouse sensitivity for camera rotation
@export var camera_fov: float = 75.0: ## Field of view angle for the camera
	set(value):
		camera_fov = value
		if camera:
			camera.fov = camera_fov
@export var camera_bob_enabled: bool = true ## Whether camera bobbing effect is enabled when moving
@export var camera_bob_amount: float = 0.05 ## Intensity of camera bobbing effect
@export var camera_bob_frequency: float = 2.0 ## Frequency of camera bobbing animation
@export var invert_y_axis: bool = false ## Whether to invert vertical mouse look
@export var mouse_capture_enabled: bool = true ## Whether mouse cursor is captured on start
@export var head_height: float = 1.6: ## Height of camera from ground
	set(value):
		head_height = value
		camera_offset.y = head_height
		if camera_pivot:
			camera_pivot.position = camera_offset
@export var camera_offset: Vector3 = Vector3(0, 1.6, 0): ## 3D offset position of camera relative to player head
	set(value):
		camera_offset = value
		if camera_pivot:
			camera_pivot.position = camera_offset
@export var weapon_bob_enabled: bool = true ## Whether weapon bobbing effect is enabled
@export var weapon_bob_amount: float = 0.02 ## Intensity of weapon bobbing effect
var head_bone: Node3D = null # Optional: for FPS head tracking
var camera_rotation_horizontal: float = 0.0
var camera_rotation_vertical: float = 0.0
var camera_bob_time: float = 0.0

@export_subgroup("Networking")
@export var username: String = "Player" ## Display name for this player in multiplayer
@export var is_local_player: bool = true ## Whether this is the local player instance
@export var player_id: int = -1 ## Unique identifier for this player in multiplayer sessions
var is_network_authority: bool = false # Renamed to avoid shadowing Node.is_multiplayer_authority()

@export_subgroup("Death & Respawn")
@export var respawn_time: float = 3.0 ## Time in seconds before player respawns after death
@export var respawn_position: Vector3 = Vector3.ZERO ## World position where player respawns
var is_dead: bool = false
var death_count: int = 0

@export_subgroup("Audio")
@export var walk_sound: AudioStreamPlayer3D ## Audio player for walking footstep sounds
@export var run_sound: AudioStreamPlayer3D ## Audio player for running footstep sounds
@export var jump_sound: AudioStreamPlayer3D ## Audio player for jump sound effects
@export var die_sound: AudioStreamPlayer3D ## Audio player for die sound effects

@export_group("Audio Configuration")
@export var walk_volume: float = 1.0 ## Volume level for walking sounds (0.0 to 1.0)
@export var run_volume: float = 1.0 ## Volume level for running sounds (0.0 to 1.0)
@export var jump_volume: float = 1.0 ## Volume level for jump sounds (0.0 to 1.0)
@export var die_volume: float = 1.0 ## Volume level for die sounds (0.0 to 1.0)

@export_group("Animation")
@export var animation_player: AnimationPlayer ## Reference to the AnimationPlayer node
@export var blend_speed: float = 8.0 ## Speed at which blend values lerp between states
var current_blend_value: float = 0.0 ## Current blend value for BlendSpace2D Y-axis (forward/backward: -1 to 1)
var current_blend_x: float = 0.0 ## Current blend value for BlendSpace2D X-axis (strafe: -1=left, 1=right)

@onready var state_machine: StateMachine = $PlayerStateMachine
@onready var camera: Camera3D = $CameraPivot/CameraSpringArm/PlayerCamera
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_spring_arm: SpringArm3D = $CameraPivot/CameraSpringArm
@onready var inventory: InventoryManager = $InventoryManager
@onready var interaction_raycast: RayCast3D = $CameraPivot/CameraSpringArm/PlayerCamera/InteractionRaycast
@onready var animation_tree: AnimationTree = $AnimationTree

const BARE_HAND_LOCOMOTION_BLEND_PARAM = "parameters/BareHandLocomotion/blend_position"
const STATE_MACHINE_TRAVEL = "parameters/playback"

func _ready() -> void:
	if not Engine.is_editor_hint():
		if mouse_capture_enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		_setup_state_machine()
		_setup_inventory()
		#_setup_visuals()
	
	_setup_camera()
	
func _setup_inventory() -> void:
	# Auto-attach script if missing
	if not inventory.get_script():
		inventory.set_script(load("res://scripts/inventory/inventory_manager.gd"))
	
	inventory.item_added.connect(_on_item_added)
	inventory.item_removed.connect(_on_item_removed)
	inventory.item_used.connect(_on_item_used)

func _setup_state_machine() -> void:
	if not state_machine.get_script():
		state_machine.set_script(load("res://scripts/state_machine.gd"))
	
	var states_map = {
		"Idle": "res://scripts/states/idle.gd",
		"Walk": "res://scripts/states/walk.gd",
		"Sprint": "res://scripts/states/sprint.gd",
		"Jump": "res://scripts/states/jump.gd",
		"Fall": "res://scripts/states/fall.gd",
		"Crouch": "res://scripts/states/crouch.gd",
		"Reload": "res://scripts/states/reload.gd"
	}
	
	for child in state_machine.get_children():
		if states_map.has(child.name) and not child.get_script():
			child.set_script(load(states_map[child.name]))
			
	state_machine.init(self)

func _setup_camera() -> void:
	if camera_pivot:
		camera_pivot.position = camera_offset
	if camera_spring_arm:
		camera_spring_arm.spring_length = 0
	if camera:
		camera.position = Vector3.ZERO
		camera.fov = camera_fov

func _setup_visuals() -> void:
	if is_local_player:
		var skeleton = find_child("Skeleton3D")
		if skeleton:
			for child in skeleton.get_children():
				if child is MeshInstance3D:
					child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
		
	if event.is_action_pressed("ui_cancel"): # ESC key
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			if mouse_capture_enabled:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mouse_capture_enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	
	if event is InputEventMouseMotion and mouse_capture_enabled:
		_handle_camera_rotation(event)
	
	if state_machine:
		state_machine._unhandled_input(event)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if state_machine:
		state_machine._physics_process(delta)
	
	_handle_interaction()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if state_machine:
		state_machine._process(delta)
	
	_handle_stamina(delta)
	_update_camera(delta)

func _handle_camera_rotation(event: InputEventMouseMotion) -> void:
	var vertical_mult = 1.0 if not invert_y_axis else -1.0
	
	camera_rotation_horizontal -= event.relative.x * camera_sensitivity
	camera_rotation_vertical -= event.relative.y * camera_sensitivity * vertical_mult
	
	camera_rotation_vertical = clamp(camera_rotation_vertical, deg_to_rad(-90), deg_to_rad(90))

	# Limit head horizontal movement to 180 degrees (+/- 90 degrees) relative to body
	var relative_horizontal = wrapf(camera_rotation_horizontal - rotation.y, -PI, PI)
	var clamped_relative = clamp(relative_horizontal, deg_to_rad(-90), deg_to_rad(90))
	if relative_horizontal != clamped_relative:
		camera_rotation_horizontal = rotation.y + clamped_relative

func _update_camera(delta: float) -> void:
	# Apply camera rotation
	if camera:
		camera.rotation.x = camera_rotation_vertical
	if camera_pivot:
		camera_pivot.rotation.y = camera_rotation_horizontal - rotation.y

	if camera_bob_enabled:
		if velocity.length() > 0.1 and is_on_floor():
			camera_bob_time += delta * camera_bob_frequency * (velocity.length() / walk_speed)
			# Bob around 0.0 since pivot is already at camera_offset
			camera.position.y = sin(camera_bob_time) * camera_bob_amount
		else:
			camera_bob_time = 0.0
			camera.position.y = move_toward(camera.position.y, 0.0, delta)

func _handle_stamina(delta: float) -> void:
	if is_stamina_enabled and current_stamina < max_stamina:
		current_stamina = min(current_stamina + stamina_regen_rate * delta, max_stamina)

func _handle_interaction() -> void:
	if not camera: return
	
	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from - camera.global_transform.basis.z * interaction_range
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = interaction_layer
	query.exclude = [self.get_rid()]
	
	var result = space_state.intersect_ray(query)
	
	if result:
		if current_interactable != result.collider:
			current_interactable = result.collider
			interaction_focused.emit(current_interactable)
	elif current_interactable:
		current_interactable = null
		interaction_unfocused.emit()
	
	# Handle interaction input
	if Input.is_action_just_pressed("awesome_player_interact") and current_interactable:
		_interact_with_object(current_interactable)

func _interact_with_object(object: Node) -> void:
	interacted.emit(object)
	if object.has_method("interact"):
		object.interact(self)

func _on_item_added(_item: InventoryItem, _slot: int) -> void:
	pass # Override or connect to this for UI updates

func _on_item_removed(_item: InventoryItem, _slot: int) -> void:
	pass # Override or connect to this for UI updates

func _on_item_used(item: InventoryItem) -> void:
	# Handle item usage effects
	if item.data.metadata.has("heal_amount"):
		current_health = min(current_health + float(item.data.metadata["heal_amount"]), max_health)
	if item.data.metadata.has("stamina_amount"):
		current_stamina = min(current_stamina + float(item.data.metadata["stamina_amount"]), max_stamina)

func play_animation(anim_name: String, custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false) -> void:
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name, custom_blend, custom_speed, from_end)
	elif animation_player:
		push_warning("Animation not found: " + anim_name)

func update_blend_value(input_dir: Vector2, speed_ratio: float, delta: float) -> void:
	"""
	Updates BlendSpace2D based on input direction and movement speed.
	
	input_dir: Input vector (x = strafe, y = forward/back)
	speed_ratio: Speed multiplier (0.5 = walk, 1.0 = run)
	delta: Delta time for smooth interpolation
	
	BlendSpace2D mapping:
	- X axis: -1 = left strafe run, -0.5 = left strafe walk, 0 = no strafe, 0.5 = right strafe walk, 1 = right strafe run
	- Y axis: -1 = backward run, -0.5 = backward walk, 0 = idle, 0.5 = forward walk, 1 = forward run
	"""
	
	# Target blend position based on input direction and speed ratio
	var target_blend = Vector2.ZERO
	if input_dir.length() > 0.1: # Dead zone
		# X-axis: left/right strafing scaled by speed_ratio
		# Negated so left input plays left animation and right input plays right animation
		target_blend.x = - input_dir.x * speed_ratio
		
		# Y-axis: forward/backward scaled by speed_ratio
		# input_dir.y: -1 = forward, 1 = backward
		# We negate it so forward becomes positive and backward becomes negative
		target_blend.y = - input_dir.y * speed_ratio
	
	# Smooth lerp to target blend position
	current_blend_value = lerpf(current_blend_value, target_blend.y, blend_speed * delta)
	current_blend_x = lerpf(current_blend_x, target_blend.x, blend_speed * delta)
	
	# Update AnimationTree BlendSpace2D
	if animation_tree:
		var blend_pos = Vector2(current_blend_x, current_blend_value)
		animation_tree.set(BARE_HAND_LOCOMOTION_BLEND_PARAM, blend_pos)
