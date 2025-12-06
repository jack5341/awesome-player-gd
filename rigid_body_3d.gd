extends Interactable

func _on_interacted(body: Node) -> void:
	print("Interacted with ", body.name)
