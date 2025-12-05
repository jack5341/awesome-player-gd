class_name Pant extends Equipment

## Equipment item for the pant slot.
## Inherits visual properties from Equipment.

func _init() -> void:
	slot_type = SlotType.PANT

## Legacy property aliases for backward compatibility
@export var mesh: Mesh
@export var position: Vector3
@export var rotation: Vector3
@export var scale: Vector3
