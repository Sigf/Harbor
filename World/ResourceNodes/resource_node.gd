@abstract class_name ResourceNode extends WorldStructure
# Base class for resource nodes in the world that villagers can gather from.

signal resources_extracted(node: ResourceNode, resource_type: WorldResource, amount: int)
signal resource_depleted(node: ResourceNode)

@export var resource_type: WorldResource
@export var resource_amount: int
@export var base_energy_cost: int

var jobs_assigned: Array[VillagerJobGatherer] = []


func try_extract_resources(amount_to_extract: int) -> bool:
	assert(is_instance_valid(owning_world))

	# Ensure we don't gather more than what's available
	if amount_to_extract > resource_amount:
		amount_to_extract = resource_amount
	
	# Remove resources from the node and add to the world's stockpile
	if owning_world.try_add_to_stockpile(resource_type, amount_to_extract):
		resource_amount -= amount_to_extract
		resources_extracted.emit(self, resource_type, amount_to_extract)
		_on_resource_extracted(amount_to_extract)
		
		if resource_amount <= 0:
			resource_depleted.emit(self)
			_on_resource_depleted()
		
		return true
	else:
		return false


func _on_resource_extracted(extracted_amount: int) -> void:
	print(extracted_amount, " ", resource_type.world_resource_name, " extracted from ", structure_name, ".")


func _on_resource_depleted() -> void:
	print("Node ", structure_name, " has been depleted of its resources.")


func _on_assigned_job_completed(job: VillagerJobBase) -> void:
	if job in jobs_assigned:
		jobs_assigned.erase(job)