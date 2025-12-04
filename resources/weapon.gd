class_name Weapon extends Base

@export_subgroup("Weapon Properties")
@export var attack_damage: float = 10.0 ## Base damage dealt by player attacks
@export var attack_range: float = 2.0 ## Maximum distance the player can attack from
@export var attack_cooldown: float = 0.5 ## Time in seconds between attacks
@export var attack_knockback: float = 5.0 ## Force applied to enemies when hit
@export var can_attack: bool = true ## Whether the player is currently allowed to attack

@export_subgroup("Weapon Model")
@export var mesh: Mesh ## Mesh for the weapon model
@export var shadow: Mesh ## Mesh for the weapon shadow
@export var model_scale: Vector3 = Vector3.ONE ## Scale of the weapon model
@export var model_rotation: Vector3 = Vector3.ZERO ## Rotation of the weapon model
@export var model_position: Vector3 = Vector3.ZERO ## Position of the weapon model

@export_subgroup("Weapon Audio")
@export var audio: AudioStream ## Audio stream for the weapon
@export var audio_volume: float = 1.0 ## Volume of the weapon audio
@export var audio_pitch: float = 1.0 ## Pitch of the weapon audio
@export var audio_loop: bool = true ## Whether the weapon audio should loop

@export_subgroup("Weapon Sway")
@export var sway_min: Vector2 = Vector2.ZERO
@export var sway_max: Vector2 = Vector2.ZERO
@export_range(0,0.2,0.01) var sway_speed_position: float = 0.7
@export_range(0,0.2,0.01) var sway_speed_rotation: float = 0.1
@export_range(0,0.25,0.01) var sway_amount_position: float = 0.1
@export_range(0,50,0.01) var sway_amount_rotation: float = 30.0
@export var idle_sway_adjustment: float = 10.0
@export var idle_sway_rotation_strength: float = 300.0
@export_range(0.1,10.0,0.1) var random_sway_amount: float = 5.0

@export_subgroup("Weapon Raycast Position")
@export var raycast_position: Vector3 = Vector3.ZERO
@export var raycast_rotation: Vector3 = Vector3.ZERO
@export var raycast_scale: Vector3 = Vector3.ONE
