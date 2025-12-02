class_name ItemData
extends Resource

@export var item_name: String = "" ## Display name of the item
@export var item_id: String = "" ## Unique identifier for this item type
@export_multiline var description: String = "" ## Item description
@export var icon: Texture2D ## Item icon for UI
@export var stack_size: int = 1 ## Maximum number of items in a single stack
@export var weight: float = 1.0 ## Weight of a single item
@export var value: int = 0 ## Base monetary value
@export var can_drop: bool = true ## Whether the item can be dropped
@export var can_use: bool = false ## Whether the item can be used/consumed
@export var is_equipable: bool = false ## Whether the item can be equipped

## Grid size (for grid-based inventory)
@export var grid_width: int = 1 ## Width in grid slots
@export var grid_height: int = 1 ## Height in grid slots

## Optional metadata for custom behavior
@export var metadata: Dictionary = {}

func _init(p_item_id: String = "", p_item_name: String = "") -> void:
	item_id = p_item_id
	item_name = p_item_name
