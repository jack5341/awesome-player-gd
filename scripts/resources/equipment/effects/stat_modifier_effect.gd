class_name StatModifierEffect
extends EquipmentEffect

enum StatType {
	MAX_HEALTH,
	WALK_SPEED,
	SPRINT_SPEED,
	JUMP_VELOCITY,
	MAX_STAMINA,
	DAMAGE_MULTIPLIER
}

enum OperationType {
	ADD,
	MULTIPLY
}

@export var stat_type: StatType
@export var value: float = 0.0
@export var operation: OperationType = OperationType.ADD

func apply(player: Player) -> void:
	_modify_stat(player, value, operation)

func remove(player: Player) -> void:
	# To remove, we reverse the operation
	var reverse_op = OperationType.ADD
	var reverse_val = value
	
	if operation == OperationType.ADD:
		reverse_val = - value # Subtract to reverse addition
		reverse_op = OperationType.ADD
	elif operation == OperationType.MULTIPLY:
		if value != 0:
			reverse_val = 1.0 / value # Divide to reverse multiplication
			reverse_op = OperationType.MULTIPLY
		else:
			push_warning("Cannot reverse multiply by 0")
			return
			
	_modify_stat(player, reverse_val, reverse_op)

func _modify_stat(player: Player, val: float, op: OperationType) -> void:
	match stat_type:
		StatType.MAX_HEALTH:
			player.max_health = _calculate(player.max_health, val, op)
			if player.current_health > player.max_health:
				player.current_health = player.max_health
				
		StatType.WALK_SPEED:
			player.walk_speed = _calculate(player.walk_speed, val, op)
			
		StatType.SPRINT_SPEED:
			player.sprint_speed = _calculate(player.sprint_speed, val, op)
			
		StatType.JUMP_VELOCITY:
			player.jump_velocity = _calculate(player.jump_velocity, val, op)
			
		StatType.MAX_STAMINA:
			player.max_stamina = _calculate(player.max_stamina, val, op)
			if player.current_stamina > player.max_stamina:
				player.current_stamina = player.max_stamina
				
		StatType.DAMAGE_MULTIPLIER:
			player.damage_multiplier = _calculate(player.damage_multiplier, val, op)

func _calculate(current: float, mod: float, op: OperationType) -> float:
	if op == OperationType.ADD:
		return current + mod
	elif op == OperationType.MULTIPLY:
		return current * mod
	return current
