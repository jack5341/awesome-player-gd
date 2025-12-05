class_name Consumable extends StatModifierEffect

## Consumable item that applies temporary or permanent effects when used.
## Inherits stat modifier effects from StatModifierEffect.

func _init() -> void:
	stat_type = StatType.CURRENT_HEALTH
	operation = OperationType.ADD

@export var duration: float = 10.0 ## Duration of the consumable effect in seconds (0 = instant/permanent)
@export var amount: float = 10.0 ## Amount to apply (interpreted based on operation type)
