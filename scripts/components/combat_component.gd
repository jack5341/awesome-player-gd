class_name CombatComponent
extends Node

signal weapon_equipped(weapon: Node)
signal weapon_unequipped()
signal key_item_equipped(item_id: String)
signal key_item_unequipped(item_id: String)

@export var weapon_manager_path: NodePath
var weapon_manager: Node # Placeholder for actual weapon manager logic if complex

# Could hold references to ammo, current weapon instance, etc.
var active_weapon: Node = null

func equip_weapon(weapon_node: Node) -> void:
	if active_weapon:
		active_weapon.queue_free()
	
	active_weapon = weapon_node
	add_child(active_weapon)
	weapon_equipped.emit(active_weapon)

func unequip_weapon() -> void:
	if active_weapon:
		active_weapon.queue_free()
		active_weapon = null
		weapon_unequipped.emit()
