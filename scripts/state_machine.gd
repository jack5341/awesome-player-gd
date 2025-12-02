class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State

func init(player: CharacterBody3D) -> void:
	var states = {}
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.player = player
	
	# Auto-wire transitions
	for child in get_children():
		if child is State:
			for property in child.get_script().get_script_property_list():
				if property.type == TYPE_OBJECT and property.class_name == "State":
					var target_name = property.name.replace("_state", "").to_lower()
					if states.has(target_name) and child.get(property.name) == null:
						child.set(property.name, states[target_name])

	if initial_state:
		change_state(initial_state)
	elif get_child_count() > 0:
		change_state(get_child(0))

func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
