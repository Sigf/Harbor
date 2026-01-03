class_name ResourceNodeTree extends ResourceNode


func _on_resource_depleted() -> void:
	super._on_resource_depleted()
	self.queue_free()
