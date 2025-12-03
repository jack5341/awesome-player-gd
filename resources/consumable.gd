class_name Consumable extends Base

enum EffectType {
	VISION,
	HEALTH,
	STAMINA,
	SPEED,
}

enum HealthType {
	REGENERATE,
	MAX,
}

enum StaminaType {
	REGENERATE,
	MAX,
}

enum SpeedType {
	BOOST,
	DEBUFF,
}

@export_category("Consumable Properties")
@export var effect_duration: float = 10.0 ## Duration of the consumable effect
@export var effect_type: EffectType = EffectType.HEALTH ## Type of the consumable to consume

@export_subgroup("Consumable Vision")
@export var vision_distance: float = 10.0 ## Distance of the consumable vision effect
@export var vision_fov: float = 10.0 ## FOV of the consumable vision effect
@export var vision_color: Color = Color.WHITE ## Color of the consumable vision effect
@export var vision_intensity: float = 1.0 ## Intensity of the consumable vision effect
@export var vision_frequency: float = 1.0 ## Frequency of the consumable vision effect
@export var vision_amplitude: float = 1.0 ## Amplitude of the consumable vision effect
@export var vision_phase: float = 0.0 ## Phase of the consumable vision effect
@export var vision_direction: Vector3 = Vector3.FORWARD ## Direction of the consumable vision effect
@export var vision_up_direction: Vector3 = Vector3.UP ## Up direction of the consumable vision effect
@export var vision_right_direction: Vector3 = Vector3.RIGHT ## Right direction of the consumable vision effect
@export var vision_left_direction: Vector3 = Vector3.LEFT ## Left direction of the consumable vision effect
@export var vision_forward_direction: Vector3 = Vector3.FORWARD ## Forward direction of the consumable vision effect

@export_subgroup("Consumable Health")
@export var health_amount: float = 10.0 ## Amount of health to restore
@export var health_type: HealthType = HealthType.REGENERATE ## Type of health to restore

@export_subgroup("Consumable Stamina")
@export var stamina_amount: float = 10.0 ## Amount of stamina to restore
@export var stamina_type: StaminaType = StaminaType.REGENERATE ## Type of stamina to restore

@export_subgroup("Consumable Speed")
@export var speed_amount_multiplier: float = 1.0 ## Amount of speed to multiplier
@export var speed_type: SpeedType = SpeedType.BOOST ## Type of speed to apply
