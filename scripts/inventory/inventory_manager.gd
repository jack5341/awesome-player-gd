class_name InventoryManager
extends Node

func _ready() -> void:
	_initialize_inventory()

signal inventory_changed()
signal item_added(item: InventoryItem, slot: int)
signal item_removed(item: InventoryItem, slot: int)
signal item_used(item: InventoryItem)

@export var inventory_type: InventoryType = InventoryType.GRID ## Type of inventory system
@export var grid_width: int = 6 ## Grid width for grid-based inventory
@export var grid_height: int = 6 ## Grid height for grid-based inventory
@export var slot_count: int = 20 ## Number of slots for slot-based inventory
@export var max_weight: float = 0.0 ## Maximum weight (0 = unlimited)

enum InventoryType {
	GRID, ## Grid-based (Tarkov-style)
	SLOT ## Slot-based (Minecraft-style)
}

var items: Array[InventoryItem] = [] ## All items in inventory
var grid: Array = [] ## 2D grid for grid-based inventory
var current_weight: float = 0.0

func _initialize_inventory() -> void:
	items.clear()
	current_weight = 0.0
	
	if inventory_type == InventoryType.GRID:
		grid.clear()
		grid.resize(grid_height)
		for y in range(grid_height):
			grid[y] = []
			grid[y].resize(grid_width)
			for x in range(grid_width):
				grid[y][x] = null
	else:
		items.resize(slot_count)
		for i in range(slot_count):
			items[i] = null

## Add item to inventory (auto-find position)
func add_item(item: InventoryItem) -> bool:
	if not item or not item.data:
		return false
	
	# Check weight limit
	if max_weight > 0 and current_weight + item.get_total_weight() > max_weight:
		return false
	
	if inventory_type == InventoryType.GRID:
		return _add_item_to_grid(item)
	else:
		return _add_item_to_slot(item)

## Add item to specific slot
func add_item_at(item: InventoryItem, slot: int) -> bool:
	if inventory_type == InventoryType.SLOT:
		if slot < 0 or slot >= slot_count:
			return false
		
		if items[slot] == null:
			items[slot] = item
			current_weight += item.get_total_weight()
			item_added.emit(item, slot)
			inventory_changed.emit()
			return true
		elif items[slot].can_stack_with(item):
			var overflow = items[slot].add_quantity(item.quantity)
			if overflow == 0:
				current_weight += item.get_total_weight()
				inventory_changed.emit()
				return true
	return false

## Add item to grid at specific position
func add_item_at_grid_position(item: InventoryItem, grid_pos: Vector2i, rotated: bool = false) -> bool:
	if inventory_type != InventoryType.GRID:
		return false
	
	item.is_rotated = rotated
	item.grid_position = grid_pos
	
	if _can_place_item_at_position(item, grid_pos):
		_place_item_in_grid(item, grid_pos)
		items.append(item)
		current_weight += item.get_total_weight()
		item_added.emit(item, -1)
		inventory_changed.emit()
		return true
	return false

## Remove item from inventory
func remove_item(item: InventoryItem) -> bool:
	if not item:
		return false
	
	var item_weight = item.get_total_weight()
	if inventory_type == InventoryType.GRID:
		_remove_item_from_grid(item)
		items.erase(item)
	else:
		var index = items.find(item)
		if index >= 0:
			items[index] = null
			item_removed.emit(item, index)
	
	current_weight -= item_weight
	inventory_changed.emit()
	return true

## Remove item at slot
func remove_item_at(slot: int) -> InventoryItem:
	if inventory_type != InventoryType.SLOT or slot < 0 or slot >= slot_count:
		return null
	
	var item = items[slot]
	if item:
		items[slot] = null
		current_weight -= item.get_total_weight()
		item_removed.emit(item, slot)
		inventory_changed.emit()
	return item

## Get item at slot
func get_item_at(slot: int) -> InventoryItem:
	if inventory_type != InventoryType.SLOT or slot < 0 or slot >= slot_count:
		return null
	return items[slot]

## Get item at grid position
func get_item_at_grid_position(grid_pos: Vector2i) -> InventoryItem:
	if inventory_type != InventoryType.GRID:
		return null
	if grid_pos.x < 0 or grid_pos.x >= grid_width or grid_pos.y < 0 or grid_pos.y >= grid_height:
		return null
	return grid[grid_pos.y][grid_pos.x]

## Use/consume item
func use_item(item: InventoryItem) -> bool:
	if not item or not item.data or not item.data.can_use:
		return false
	
	item_used.emit(item)
	
	# Handle consumable items
	if item.data.stack_size > 1:
		item.remove_quantity(1)
		if item.quantity <= 0:
			remove_item(item)
	else:
		remove_item(item)
	
	return true

## Get all items matching criteria
func find_items(item_id: String) -> Array[InventoryItem]:
	var found: Array[InventoryItem] = []
	for item in items:
		if item and item.data and item.data.item_id == item_id:
			found.append(item)
	return found

## Get total quantity of specific item
func get_item_count(item_id: String) -> int:
	var count = 0
	for item in items:
		if item and item.data and item.data.item_id == item_id:
			count += item.quantity
	return count

## Check if inventory has space
func has_space(item: InventoryItem) -> bool:
	if max_weight > 0 and current_weight + item.get_total_weight() > max_weight:
		return false
	
	if inventory_type == InventoryType.GRID:
		return _find_grid_position_for_item(item) != Vector2i(-1, -1)
	else:
		for i in range(slot_count):
			if items[i] == null or (items[i].can_stack_with(item)):
				return true
	return false

## Private helper methods
func _add_item_to_slot(item: InventoryItem) -> bool:
	# Try to stack first
	for i in range(slot_count):
		if items[i] and items[i].can_stack_with(item):
			var overflow = items[i].add_quantity(item.quantity)
			if overflow == 0:
				current_weight += item.get_total_weight()
				inventory_changed.emit()
				return true
			else:
				item.quantity = overflow
	
	# Find empty slot
	for i in range(slot_count):
		if items[i] == null:
			items[i] = item
			current_weight += item.get_total_weight()
			item_added.emit(item, i)
			inventory_changed.emit()
			return true
	
	return false

func _add_item_to_grid(item: InventoryItem) -> bool:
	var pos = _find_grid_position_for_item(item)
	if pos != Vector2i(-1, -1):
		return add_item_at_grid_position(item, pos, false)
	
	# Try rotated
	item.is_rotated = true
	pos = _find_grid_position_for_item(item)
	if pos != Vector2i(-1, -1):
		return add_item_at_grid_position(item, pos, true)
	
	return false

func _find_grid_position_for_item(item: InventoryItem) -> Vector2i:
	var size = item.get_grid_size()
	for y in range(grid_height - size.y + 1):
		for x in range(grid_width - size.x + 1):
			var pos = Vector2i(x, y)
			if _can_place_item_at_position(item, pos):
				return pos
	return Vector2i(-1, -1)

func _can_place_item_at_position(item: InventoryItem, pos: Vector2i) -> bool:
	var size = item.get_grid_size()
	if pos.x + size.x > grid_width or pos.y + size.y > grid_height:
		return false
	
	for y in range(pos.y, pos.y + size.y):
		for x in range(pos.x, pos.x + size.x):
			if grid[y][x] != null:
				return false
	return true

func _place_item_in_grid(item: InventoryItem, pos: Vector2i) -> void:
	var size = item.get_grid_size()
	for y in range(pos.y, pos.y + size.y):
		for x in range(pos.x, pos.x + size.x):
			grid[y][x] = item

func _remove_item_from_grid(item: InventoryItem) -> void:
	for y in range(grid_height):
		for x in range(grid_width):
			if grid[y][x] == item:
				grid[y][x] = null

## Add capacity to inventory
func add_capacity(extra_w: int, extra_h: int) -> void:
	if inventory_type != InventoryType.GRID:
		return
	
	var old_width = grid_width
	var old_height = grid_height
	
	grid_width += extra_w
	grid_height += extra_h
	
	# Resize height (rows)
	grid.resize(grid_height)
	
	# For new rows, initialize
	for y in range(old_height, grid_height):
		grid[y] = []
		grid[y].resize(grid_width)
		for x in range(grid_width):
			grid[y][x] = null
			
	# For existing rows, resize width
	for y in range(old_height):
		grid[y].resize(grid_width)
		for x in range(old_width, grid_width):
			grid[y][x] = null
			
	print("Inventory resized to: ", grid_width, "x", grid_height)
	inventory_changed.emit()

## Debug
func print_inventory() -> void:
	print("=== Inventory ===")
	print("Weight: ", current_weight, "/", max_weight if max_weight > 0 else "∞")
	if inventory_type == InventoryType.GRID:
		print("Grid: ", grid_width, "x", grid_height)
		for item in items:
			if item and item.data:
				print("  - ", item.data.item_name, " x", item.quantity, " at ", item.grid_position)
	else:
		print("Slots: ", slot_count)
		for i in range(slot_count):
			if items[i] and items[i].data:
				print("  [", i, "] ", items[i].data.item_name, " x", items[i].quantity)
