class_name InventoryModifierEffect
extends EquipmentEffect

@export var extra_columns: int = 0
@export var extra_rows: int = 0

func apply(player: Player) -> void:
	if player.inventory:
		player.inventory.add_capacity(extra_columns, extra_rows)

func remove(player: Player) -> void:
	if player.inventory:
		# To remove, we subtract the added capacity
		player.inventory.add_capacity(-extra_columns, -extra_rows)
