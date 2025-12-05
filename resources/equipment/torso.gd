class_name Torso extends Equipment

## Equipment item for the torso slot.
## Inherits visual properties from Equipment.

func _init() -> void:
	slot_type = SlotType.TORSO

## Legacy property aliases for backward compatibility
@export var mesh: Mesh
@export var position: Vector3
@export var rotation: Vector3
@export var scale: Vector3
