@tool
extends CharacterBody3D
class_name Player

## Signals for external systems to connect to. These are also available via components.
signal health_changed(current_health: float, max_health: float) ## Emitted when health changes (also available via stats.health_changed)
signal stamina_changed(current_stamina: float, max_stamina: float) ## Emitted when stamina changes (also available via stats.stamina_changed)
signal dead() ## Emitted when player dies (also available via stats.died)
signal interacted(object: Node) ## Emitted when player interacts with an object (also available via interaction.interacted)
signal interaction_focused(object: Node) ## Emitted when player focuses on an interactable (also available via interaction.focused)
signal interaction_unfocused() ## Emitted when player unfocuses an interactable (also available via interaction.unfocused)

@export_group("Components")
# Components can be assigned in editor or created dynamically
@export var stats: StatsComponent
@export var combat: CombatComponent
@export var equipment: EquipmentManager
@export var interaction: InteractionComponent

@export_group("Inventory")
@export var weight_system_enabled: bool = false ## Enable weight-based inventory limits
@export var max_weight_limit: float = 50.0 ## Maximum weight capacity (0 = unlimited if weight_system_enabled is false)

@export_group("Movement")
@export var walk_speed: float = 5.0 ## Base walking speed in units per second
@export var sprint_speed: float = 12.0 ## Sprinting speed when holding sprint key (consumes stamina)
@export var crouch_speed: float = 2.5 ## Movement speed while crouching
@export var acceleration: float = 10.0 ## How quickly the player reaches target speed
@export var friction: float = 10.0 ## How quickly the player decelerates when stopping
@export var rotation_speed: float = 10.0 ## How quickly the player rotates to face movement direction
@export var air_control: float = 0.3 ## Movement control multiplier while in air (0.0 = no control, 1.0 = full control)
@export var jump_count: int = 1 ## Current number of jumps available (for double/triple jump)
@export var jump_velocity: float = 4.5 ## Vertical velocity applied when jumping
@export var max_jumps: int = 1 ## Maximum number of jumps the player can perform
@export var coyote_time: float = 0.2 ## Time window after leaving ground where jump is still allowed (in seconds)
@export var can_sprint: bool = true ## Whether the player can sprint
@export var sprint_requires_stamina: bool = true ## Whether sprinting requires stamina (if false, can sprint infinitely)


@export_group("Camera")
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

@export_group("Networking")
@export var username: String = "Player" ## Display name for this player in multiplayer
@export var is_local_player: bool = true ## Whether this is the local player instance
@export var player_id: int = -1 ## Unique identifier for this player in multiplayer sessions
var is_network_authority: bool = false # Renamed to avoid shadowing Node.is_multiplayer_authority()

@export_group("Death & Respawn")
@export var respawn_time: float = 3.0 ## Time in seconds before player respawns after death
@export var respawn_position: Vector3 = Vector3.ZERO ## World position where player respawns
var is_dead: bool = false
var death_count: int = 0

@export_group("Animation")
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


const BARE_HAND_LOCOMOTION_BLEND_PARAM = "parameters/bare_hand_locomotion/blend_position"
const BARE_HAND_JUMP = "parameters/bare_hand_jump"
const STATE_MACHINE_TRAVEL = "parameters/playback"

func _ready() -> void:
	if not Engine.is_editor_hint():
		if mouse_capture_enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		_setup_components()
		_setup_state_machine()
		# _setup_visuals()
	
	_setup_camera()
	
## Sets up all modular components. Components can be assigned in editor or will be auto-created.
func _setup_components() -> void:
	# 1. Stats Component - Handles health and stamina
	if not stats:
		stats = get_node_or_null("StatsComponent")
	if not stats:
		stats = StatsComponent.new()
		stats.name = "StatsComponent"
		add_child(stats)
	
	# 2. Combat Component - Handles weapon equipping
	if not combat:
		combat = get_node_or_null("CombatComponent")
	if not combat:
		combat = CombatComponent.new()
		combat.name = "CombatComponent"
		add_child(combat)
		
	# 3. Inventory Manager - Configure weight limits if enabled
	if inventory:
		if not inventory.get_script():
			inventory.set_script(load("res://scripts/inventory/inventory_manager.gd"))
		inventory.max_weight = max_weight_limit if weight_system_enabled else 0.0

	# 4. Equipment Manager - Manages visual equipment and stat modifiers
	if not equipment:
		equipment = get_node_or_null("EquipmentManager")
	if not equipment:
		equipment = EquipmentManager.new()
		equipment.name = "EquipmentManager"
		add_child(equipment)
		if equipment.owner == null: equipment.owner = self
	
	# 5. Interaction Component - Raycast-based interaction system
	if not interaction:
		interaction = get_node_or_null("InteractionComponent")
	if not interaction:
		interaction = InteractionComponent.new()
		interaction.name = "InteractionComponent"
		interaction.interaction_raycast_path = "CameraPivot/CameraSpringArm/PlayerCamera/InteractionRaycast"
		interaction.camera_path = "CameraPivot/CameraSpringArm/PlayerCamera"
		add_child(interaction)

## Sets up the state machine and auto-attaches scripts to state nodes.
func _setup_state_machine() -> void:
	if not state_machine.get_script():
		state_machine.set_script(load("res://scripts/state_machine.gd"))
	
	# Map state node names to their script paths for auto-attachment
	var states_map = {
		"Idle": "res://scripts/states/idle.gd",
		"Walk": "res://scripts/states/walk.gd",
		"Sprint": "res://scripts/states/sprint.gd",
		"Jump": "res://scripts/states/jump.gd",
		"Fall": "res://scripts/states/fall.gd",
		"Crouch": "res://scripts/states/crouch.gd",
		"Reload": "res://scripts/states/reload.gd"
	}
	
	# Auto-attach scripts to state nodes if they don't have one
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
	

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if state_machine:
		state_machine._process(delta)
	
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

	if Input.is_action_just_pressed("awesome_player_interact"):
		if interaction:
			interaction.interact()

## Called when an item is added to inventory. Override or connect signals for custom behavior.
func _on_item_added(_item: InventoryItem, _slot: int) -> void:
	pass

## Called when an item is removed from inventory. Override or connect signals for custom behavior.
func _on_item_removed(_item: InventoryItem, _slot: int) -> void:
	pass

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
