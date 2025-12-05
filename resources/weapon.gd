class_name Weapon extends Base

## Weapon resource defining combat properties, visual model, audio, and weapon sway behavior.

@export_subgroup("Combat Properties")
@export var attack_damage: float = 10.0 ## Base damage dealt by player attacks
@export var attack_range: float = 2.0 ## Maximum distance the player can attack from
@export var attack_cooldown: float = 0.5 ## Time in seconds between attacks
@export var attack_knockback: float = 5.0 ## Force applied to enemies when hit
@export var can_attack: bool = true ## Whether the player is currently allowed to attack

@export_subgroup("Visual Model")
@export var mesh: Mesh ## Mesh for the weapon model
@export var shadow: Mesh ## Mesh for the weapon shadow (optional)
@export var model_scale: Vector3 = Vector3.ONE ## Scale of the weapon model
@export var model_rotation: Vector3 = Vector3.ZERO ## Rotation of the weapon model (in degrees)
@export var model_position: Vector3 = Vector3.ZERO ## Position offset of the weapon model

@export_subgroup("Audio")
@export var audio: AudioStream ## Audio stream played when using the weapon
@export_range(0.0, 1.0, 0.01) var audio_volume: float = 1.0 ## Volume of the weapon audio (0.0 to 1.0)
@export_range(0.1, 2.0, 0.1) var audio_pitch: float = 1.0 ## Pitch multiplier for the weapon audio
@export var audio_loop: bool = true ## Whether the weapon audio should loop

@export_subgroup("Weapon Sway")
@export var sway_min: Vector2 = Vector2.ZERO ## Minimum sway bounds
@export var sway_max: Vector2 = Vector2.ZERO ## Maximum sway bounds
@export_range(0.0, 0.2, 0.01) var sway_speed_position: float = 0.7 ## Speed of positional sway interpolation
@export_range(0.0, 0.2, 0.01) var sway_speed_rotation: float = 0.1 ## Speed of rotational sway interpolation
@export_range(0.0, 0.25, 0.01) var sway_amount_position: float = 0.1 ## Amount of positional sway
@export_range(0.0, 50.0, 0.01) var sway_amount_rotation: float = 30.0 ## Amount of rotational sway (in degrees)
@export var idle_sway_adjustment: float = 10.0 ## Adjustment factor for idle sway
@export var idle_sway_rotation_strength: float = 300.0 ## Strength of idle rotation sway
@export_range(0.1, 10.0, 0.1) var random_sway_amount: float = 5.0 ## Random sway variation amount

@export_subgroup("Raycast Configuration")
@export var raycast_position: Vector3 = Vector3.ZERO ## Position offset for attack raycast origin
@export var raycast_rotation: Vector3 = Vector3.ZERO ## Rotation offset for attack raycast (in degrees)
@export var raycast_scale: Vector3 = Vector3.ONE ## Scale for raycast (usually Vector3.ONE)
