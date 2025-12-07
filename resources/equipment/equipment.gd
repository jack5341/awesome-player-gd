class_name Equipment
extends Base

## Base class for all equippable items.
## Handles stat modifications and visual representation when equipped.

enum SlotType {
	HELMET,
	TORSO,
	PANT,
	SHOE,
	BACKPACK
}

@export var slot_type: SlotType = SlotType.HELMET ## Equipment slot this item belongs to
@export var effects: Array[StatModifierEffect] = [] ## List of stat modifier effects to apply when equipped

@export_group("Visuals")
@export var mesh: Mesh ## Mesh to display when equipped
@export var position_offset: Vector3 ## Position offset relative to bone
@export var rotation_offset: Vector3 ## Rotation offset (in degrees)
@export var scale: Vector3 = Vector3.ONE ## Scale of the mesh
