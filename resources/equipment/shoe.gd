class_name Shoe extends Equipment

## Equipment item for shoe slots (left and right).
## Supports separate meshes and transforms for each foot.

func _init() -> void:
	slot_type = SlotType.SHOE

## Legacy property aliases for backward compatibility
@export var left_mesh: Mesh
@export var left_position: Vector3
@export var left_rotation: Vector3
@export var left_scale: Vector3

@export var right_mesh: Mesh
@export var right_position: Vector3
@export var right_rotation: Vector3
@export var right_scale: Vector3
