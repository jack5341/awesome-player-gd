class_name Base extends Resource

## Base resource class for all game items.
## Provides common properties shared across all item types.

@export var name: String = "" ## Display name of the item
@export var description: String = "" ## Description text shown in UI/tooltips
@export var icon: Texture2D = null ## Icon texture displayed in inventory/UI
