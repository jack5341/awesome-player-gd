class_name StatModifierEffect
extends Resource

## Stat modifier effect that can be applied to a Player.
## Used by equipment to modify player stats when equipped/unequipped.

enum StatType {
	MAX_HEALTH, ## Modifies maximum health#
	CURRENT_HEALTH, ## Modifies current health
	WALK_SPEED, ## Modifies walking speed
	SPRINT_SPEED, ## Modifies sprinting speed
	JUMP_VELOCITY, ## Modifies jump velocity
	MAX_STAMINA, ## Modifies maximum stamina
	DAMAGE_MULTIPLIER, ## Modifies damage multiplier
	STAMINA_REGEN_RATE, ## Modifies stamina regeneration rate
	STAMINA_DRAIN_RATE, ## Modifies stamina drain rate
	COYOTE_TIME, ## Modifies coyote time
	MAX_JUMPS, ## Modifies maximum number of jumps
	INVENTORY_SIZE, ## Modifies inventory size
	INVENTORY_SLOTS, ## Modifies inventory slots
}

enum OperationType {
	ADD, ## Add value to current stat
	MULTIPLY, ## Multiply current stat by value
	DIVIDE, ## Divide current stat by value
	SET, ## Set current stat to value
	INCREMENT, ## Increment current stat by value
	DECREMENT ## Decrement current stat by value
}

@export var stat_type: StatType ## Which player stat to modify
@export var value: float = 0.0 ## Value to apply (interpreted based on operation type)
@export var operation: OperationType = OperationType.ADD ## How to apply the value
