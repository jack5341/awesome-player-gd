class_name InteractionComponent
extends Node

signal focused(object: Node)
signal unfocused()
signal interacted(object: Node)

@export var interaction_range: float = 3.0
@export var interaction_layer: int = 1
@export var interaction_raycast_path: NodePath
@export var camera_path: NodePath

var current_interactable: Node = null
var raycast: RayCast3D
var camera: Camera3D

func _ready() -> void:
	if not raycast and not interaction_raycast_path.is_empty():
		raycast = get_node_or_null(interaction_raycast_path)
	if not camera and not camera_path.is_empty():
		camera = get_node_or_null(camera_path)

func _physics_process(_delta: float) -> void:
	_check_interaction()

func _check_interaction() -> void:
	if not camera: return
	
	var space_state = camera.get_world_3d().direct_space_state
	var from = camera.global_position
	# Use forward vector
	var to = from - camera.global_transform.basis.z * interaction_range
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = interaction_layer
	
	# Exclude parent player if possible to avoid self-interaction
	if owner is CollisionObject3D:
		query.exclude = [owner.get_rid()]

	var result = space_state.intersect_ray(query)
	
	if result:
		if current_interactable != result.collider:
			current_interactable = result.collider
			focused.emit(current_interactable)
	elif current_interactable:
		current_interactable = null
		unfocused.emit()

func interact() -> void:
	if current_interactable:
		interacted.emit(current_interactable)
		if current_interactable.has_method("interact"):
			current_interactable.interact(owner) # Pass owner as interactor
