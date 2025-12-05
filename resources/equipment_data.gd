class_name EquipmentData
extends Resource

## Represents a piece of equipment.
## Defines visuals (Mesh) and logic (Effects).

@export_group("Identity")
@export var item_name: String = "Equipment"
@export_enum("Helmet", "Torso", "Pant", "Shoe") var slot_type: String = "Helmet"

@export_group("Visuals")
@export var mesh: Mesh ## The mesh to apply to the BoneAttachment3D's MeshInstance3D.
@export var position_offset: Vector3 = Vector3.ZERO
@export var rotation_offset: Vector3 = Vector3.ZERO ## In degrees
@export var scale: Vector3 = Vector3.ONE

@export_group("Gameplay Effects")
@export var effects: Array[StatModifierEffect] = [] ## List of effects to apply when equipped
