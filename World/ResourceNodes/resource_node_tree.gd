class_name ResourceNodeTree extends ResourceNode

func _on_resource_depleted() -> void:
	print("Node ", structure_name, " has been depleted of its resources.")
	self.queue_free()
