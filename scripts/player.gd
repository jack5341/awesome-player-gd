extends CharacterBody3D

@export_subgroup("Health & Stats")
@export var max_health: float = 100.0  ## Maximum health points the player can have
@export var current_health: float = 100.0  ## Current health points of the player
@export var is_stamina_enabled: bool = true  ## Whether the stamina system is active
@export var max_stamina: float = 100.0  ## Maximum stamina points the player can have
@export var current_stamina: float = 100.0  ## Current stamina points of the player
@export var stamina_regen_rate: float = 10.0  ## Rate at which stamina regenerates per second
@export var stamina_drain_rate: float = 20.0  ## Rate at which stamina drains per second when used
@export var damage_multiplier: float = 1.0  ## Multiplier applied to all damage dealt by the player

@export_subgroup("Movement")
@export var walk_speed: float = 5.0  ## Base walking speed in units per second
@export var sprint_speed: float = 12.0  ## Sprinting speed when holding sprint key (consumes stamina)
@export var crouch_speed: float = 2.5  ## Movement speed while crouching
@export var acceleration: float = 10.0  ## How quickly the player reaches target speed
@export var friction: float = 10.0  ## How quickly the player decelerates when stopping
@export var air_control: float = 0.3  ## Movement control multiplier while in air (0.0 = no control, 1.0 = full control)
@export var jump_count: int = 1  ## Current number of jumps available (for double/triple jump)
@export var jump_velocity: float = 4.5  ## Current number of jumps available (for double/triple jump)
@export var max_jumps: int = 1  ## Maximum number of jumps the player can perform
@export var coyote_time: float = 0.2  ## Time window after leaving ground where jump is still allowed (in seconds)
@export var can_sprint: bool = true  ## Whether the player can sprint

@export_subgroup("Combat")
@export var attack_damage: float = 10.0  ## Base damage dealt by player attacks
@export var attack_range: float = 2.0  ## Maximum distance the player can attack from
@export var attack_cooldown: float = 0.5  ## Time in seconds between attacks
@export var attack_knockback: float = 5.0  ## Force applied to enemies when hit
@export var can_attack: bool = true  ## Whether the player is currently allowed to attack
var last_attack_time: float = 0.0

@export_subgroup("Interaction")
@export var interaction_range: float = 3.0  ## Maximum distance the player can interact with objects
@export var interaction_layer: int = 1  ## Physics layer mask for objects that can be interacted with
var current_interactable: Node = null

@export_subgroup("Camera")
enum CameraMode {
	FPS,  # First Person Shooter
	TPS   # Third Person Shooter
}
@export var camera_mode: CameraMode = CameraMode.FPS  ## Current camera mode: FPS (First Person) or TPS (Third Person)
@export var camera_sensitivity: float = 0.003  ## Mouse sensitivity for camera rotation
@export var camera_fov: float = 75.0  ## Field of view angle for the camera
@export var camera_bob_enabled: bool = true  ## Whether camera bobbing effect is enabled when moving
@export var camera_bob_amount: float = 0.05  ## Intensity of camera bobbing effect
@export var camera_bob_frequency: float = 2.0  ## Frequency of camera bobbing animation
@export var invert_y_axis: bool = false  ## Whether to invert vertical mouse look
@export var mouse_capture_enabled: bool = true  ## Whether mouse cursor is captured on start

@export_group("FPS Camera")
@export var fps_head_height: float = 1.6  ## Height of camera from ground in FPS mode
@export var fps_camera_offset: Vector3 = Vector3(0, 1.6, 0)  ## 3D offset position of camera relative to player head
@export var fps_weapon_bob_enabled: bool = true  ## Whether weapon bobbing effect is enabled in FPS mode
@export var fps_weapon_bob_amount: float = 0.02  ## Intensity of weapon bobbing effect

@export_group("TPS Camera")
@export var tps_camera_distance: float = 5.0  ## Distance from player in TPS mode
@export var tps_camera_height: float = 2.0  ## Height offset of camera pivot point
@export var tps_camera_offset: Vector3 = Vector3(0, 2.0, 0)  ## 3D offset position of camera pivot relative to player
@export var tps_collision_enabled: bool = true  ## Whether camera collides with walls and objects
@export var tps_collision_margin: float = 0.5  ## Safety margin for camera collision detection
@export var tps_min_distance: float = 1.0  ## Minimum zoom distance for TPS camera
@export var tps_max_distance: float = 10.0  ## Maximum zoom distance for TPS camera
@export var tps_rotation_smoothness: float = 10.0  ## Smoothness factor for camera rotation (higher = smoother)
@export var tps_position_smoothness: float = 10.0  ## Smoothness factor for camera position movement (higher = smoother)
@export var tps_auto_rotate: bool = false  ## Whether camera automatically rotates behind player when moving
@export var tps_auto_rotate_speed: float = 2.0  ## Speed of automatic camera rotation
@export var tps_follow_player_rotation: bool = true  ## Whether camera follows player's Y-axis rotation
@export var tps_vertical_angle_min: float = -80.0  ## Minimum vertical look angle in degrees
@export var tps_vertical_angle_max: float = 80.0  ## Maximum vertical look angle in degrees
@export var tps_shoulder_offset: Vector3 = Vector3(0.5, 0, 0)  ## Left/right shoulder offset for over-shoulder view
var camera: Camera3D = null
var camera_pivot: Node3D = null  # For TPS rotation
var camera_spring_arm: SpringArm3D = null  # Optional: for TPS collision handling
var head_bone: Node3D = null  # Optional: for FPS head tracking
var camera_rotation_horizontal: float = 0.0
var camera_rotation_vertical: float = 0.0
var current_camera_distance: float = 5.0
var camera_bob_time: float = 0.0

@export_subgroup("Networking")
@export var username: String = "Player"  ## Display name for this player in multiplayer
@export var is_local_player: bool = true  ## Whether this is the local player instance
@export var player_id: int = -1  ## Unique identifier for this player in multiplayer sessions
var is_multiplayer_authority: bool = false

@export_subgroup("Death & Respawn")
@export var respawn_time: float = 3.0  ## Time in seconds before player respawns after death
@export var respawn_position: Vector3 = Vector3.ZERO  ## World position where player respawns
var is_dead: bool = false
var death_count: int = 0

@export_subgroup("Progression")
@export var level: int = 1  ## Current player level
@export var experience: float = 0.0  ## Current experience points accumulated
@export var experience_to_next_level: float = 100.0  ## Experience points required to reach next level
@export var skill_points: int = 0  ## Available skill points that can be spent on upgrades

@export_subgroup("Audio")
@export var walk_sound: AudioStreamPlayer3D  ## Audio player for walking footstep sounds
@export var run_sound: AudioStreamPlayer3D  ## Audio player for running footstep sounds
@export var jump_sound: AudioStreamPlayer3D  ## Audio player for jump sound effects

@export_group("Audio Configuration")
@export var walk_volume: float = 1.0  ## Volume level for walking sounds (0.0 to 1.0)
@export var run_volume: float = 1.0  ## Volume level for running sounds (0.0 to 1.0)
@export var jump_volume: float = 1.0  ## Volume level for jump sounds (0.0 to 1.0)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

	move_and_slide()
