class_name Interactable
extends CollisionObject3D

signal interacted(body: Node) ## Emitted when this object is interacted with

@export var enabled: bool = true ## Whether this interactable is currently enabled
@export var prompt_message: String = "Interact" ## Message to display in the interaction prompt
@export var prompt_action: String = "awesome_player_interact" ## Input action name for interaction

func get_prompt() -> String:
	if not enabled:
		return ""

	var key_name := ""
	for event in InputMap.action_get_events(prompt_action):
		if event is InputEventKey:
			key_name = event.as_text_physical_keycode()
			break
		elif event is InputEventMouseButton:
			key_name = event.as_text()
	return prompt_message + "\n[" + key_name + "]"

## Called when the player interacts with this object.
func interact(body: Node) -> void:
	if not enabled:
		return
	
	interacted.emit(body)
	_on_interacted(body)

## Override this method in child classes to handle interaction logic.
func _on_interacted(_body: Node) -> void:
	pass
