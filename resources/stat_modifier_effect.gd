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

func apply(target: Node) -> void:
	_modify_stat(target, false)

func remove(target: Node) -> void:
	_modify_stat(target, true)

func _modify_stat(target: Node, is_removal: bool) -> void:
	var target_obj: Object = target
	var property_name: String = ""
	
	# Determine target object and property based on stat type
	# We assume 'target' is the Player node
	var stats = target.get_node_or_null("StatsComponent")
	
	match stat_type:
		StatType.MAX_HEALTH:
			target_obj = stats
			property_name = "max_health"
		StatType.CURRENT_HEALTH:
			target_obj = stats
			property_name = "current_health"
		StatType.MAX_STAMINA:
			target_obj = stats
			property_name = "max_stamina"
		StatType.STAMINA_REGEN_RATE:
			target_obj = stats
			property_name = "stamina_regen_rate"
		StatType.STAMINA_DRAIN_RATE:
			target_obj = stats
			property_name = "stamina_drain_rate"
		StatType.WALK_SPEED:
			property_name = "walk_speed"
		StatType.SPRINT_SPEED:
			property_name = "sprint_speed"
		StatType.JUMP_VELOCITY:
			property_name = "jump_velocity"
		StatType.COYOTE_TIME:
			property_name = "coyote_time"
		StatType.MAX_JUMPS:
			property_name = "max_jumps"
		StatType.DAMAGE_MULTIPLIER:
			property_name = "damage_multiplier"
			
	if not target_obj or property_name == "":
		return

	var current_val = target_obj.get(property_name)
	if current_val == null:
		return
		
	var final_val = current_val
	var op_val = value
	
	if is_removal:
		# Reverse operations logic
		match operation:
			OperationType.ADD:
				final_val -= op_val
			OperationType.MULTIPLY:
				if op_val != 0: final_val /= op_val
			OperationType.DIVIDE:
				final_val *= op_val
			OperationType.INCREMENT:
				final_val -= op_val
			OperationType.DECREMENT:
				final_val += op_val
			# SET implies we can't easily revert without storing old value. Use ADD/SUB for reversible stats.
	else:
		match operation:
			OperationType.ADD:
				final_val += op_val
			OperationType.MULTIPLY:
				final_val *= op_val
			OperationType.DIVIDE:
				if op_val != 0: final_val /= op_val
			OperationType.SET:
				final_val = op_val
			OperationType.INCREMENT:
				final_val += op_val
			OperationType.DECREMENT:
				final_val -= op_val
				
	target_obj.set(property_name, final_val)
