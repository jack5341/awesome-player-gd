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
