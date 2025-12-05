class_name EquipmentManagers
extends Node

## Manages equipment slots, visual attachment meshes, and effects for the Player.
## Expects the parent specific child nodes in the Skeleton3D matching slot names.

# Map of slot names (e.g. "Helmet") to the MeshInstance3D node inside that BoneAttachment3D
var mesh_instances: Dictionary = {}

# Dictionary to store currently equipped items: { "Helmet": EquipmentData, ... }
var equipped_items: Dictionary = {}

func _ready() -> void:
	# Defer initialization to ensure parent (Player) and its children (Skeleton3D) are ready
	call_deferred("_initialize_slots")

func _initialize_slots() -> void:
	var player = owner as Player
	if not player:
		# If owner is not set (e.g., initialized via script), try get_parent
		player = get_parent() as Player
	
	if not player:
		push_warning("EquipmentManager: Could not find Player parent.")
		return
		
	# Find Skeleton3D
	# The Player script usually exposes 'equipment.skeleton' but we can also search
	var skeleton = player.find_child("Skeleton3D", true, false)
	if not skeleton:
		push_warning("EquipmentManager: Skeleton3D not found.")
		return
		
	# We know the specific slots from player.tscn
	var slots = ["Helmet", "Torso", "Pant", "Shoe"]
	
	for slot_name in slots:
		var attachment = skeleton.find_child(slot_name, true, false)
		if attachment:
			var mesh_instance = attachment.find_child("MeshInstance3D", true, false)
			if mesh_instance and mesh_instance is MeshInstance3D:
				mesh_instances[slot_name] = mesh_instance
				# Ensure it starts empty/hidden if desired, or keep default
				# mesh_instance.mesh = null 
			else:
				push_warning("EquipmentManager: MeshInstance3D not found in " + slot_name)
		else:
			push_warning("EquipmentManager: Attachment node '" + slot_name + "' not found in Skeleton3D.")

## Equips an item. Finds the corresponding slot mesh and updates it.
func equip(item: EquipmentData) -> void:
	if not item:
		return
		
	var slot = item.slot_type
	if not mesh_instances.has(slot):
		push_warning("EquipmentManager: No mesh slot found for type " + slot)
		return
		
	# Unequip existing if any
	if equipped_items.has(slot):
		unequip(slot)
		
	# Store
	equipped_items[slot] = item
	var player = owner as Player
	if not player: player = get_parent() as Player
	
	# 1. Update Visuals
	var mesh_instance: MeshInstance3D = mesh_instances[slot]
	mesh_instance.mesh = item.mesh
	mesh_instance.position = item.position_offset
	mesh_instance.rotation_degrees = item.rotation_offset
	mesh_instance.scale = item.scale
	
	# 2. Apply Effects
	if player:
		for effect in item.effects:
			effect.apply(player)
			
	print("Equipped " + item.item_name + " to " + slot)

## Unequips item from slot.
func unequip(slot: String) -> void:
	if not equipped_items.has(slot):
		return
		
	var item = equipped_items[slot]
	var player = owner as Player
	if not player: player = get_parent() as Player
	
	# 1. Remove Effects
	if player:
		for effect in item.effects:
			effect.remove(player)
			
	# 2. Clear Visuals
	if mesh_instances.has(slot):
		var mesh_instance = mesh_instances[slot]
		mesh_instance.mesh = null
		# Reset transforms? Usually 0,0,0
		mesh_instance.position = Vector3.ZERO
		mesh_instance.rotation = Vector3.ZERO
		mesh_instance.scale = Vector3.ONE
		
	equipped_items.erase(slot)
	print("Unequipped " + slot)
