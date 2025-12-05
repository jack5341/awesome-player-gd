class_name Backpack extends Equipment

@export var mesh: Mesh
@export var position: Vector3
@export var rotation: Vector3
@export var scale: Vector3

func _init() -> void:
	slot_type = SlotType.BACKPACK
