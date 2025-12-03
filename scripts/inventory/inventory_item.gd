class_name InventoryItem
extends RefCounted

var data: ItemData ## Reference to the item's static data
var quantity: int = 1 ## Current stack quantity
var durability: float = 100.0 ## Current durability percentage (0-100)
var grid_position: Vector2i = Vector2i(-1, -1) ## Position in grid inventory (-1 = not placed)
var is_rotated: bool = false ## Whether item is rotated 90 degrees in grid
var custom_data: Dictionary = {} ## Runtime custom data
func _init(p_data: ItemData = null, p_quantity: int = 1) -> void:
	data = p_data
	quantity = p_quantity

func get_total_weight() -> float:
	if not data:
		return 0.0
	return data.weight * quantity

func get_grid_size() -> Vector2i:
	if not data:
		return Vector2i(1, 1)
	if is_rotated:
		return Vector2i(data.grid_height, data.grid_width)
	return Vector2i(data.grid_width, data.grid_height)

func can_stack_with(other: InventoryItem) -> bool:
	if not data or not other or not other.data:
		return false
	return data.item_id == other.data.item_id and quantity < data.stack_size

func add_quantity(amount: int) -> int:
	var available_space = data.stack_size - quantity
	var amount_to_add = min(amount, available_space)
	quantity += amount_to_add
	return amount - amount_to_add # Returns overflow

func remove_quantity(amount: int) -> int:
	var amount_to_remove = min(amount, quantity)
	quantity -= amount_to_remove
	return amount_to_remove

func duplicate_item() -> InventoryItem:
	var new_item = InventoryItem.new(data, quantity)
	new_item.durability = durability
	new_item.is_rotated = is_rotated
	new_item.custom_data = custom_data.duplicate()
	return new_item
