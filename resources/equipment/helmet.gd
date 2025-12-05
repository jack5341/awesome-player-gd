class_name Helmet extends Equipment

## Equipment item for the helmet slot.
## Inherits visual properties from Equipment.

func _init() -> void:
	slot_type = SlotType.HELMET

## Legacy property aliases for backward compatibility
@export var mesh: Mesh
@export var position: Vector3
@export var rotation: Vector3
@export var scale: Vector3
