@abstract class_name ResourceNode extends WorldStructure
# Base class for resource nodes in the world that villagers can gather from.

signal resources_extracted(node: ResourceNode, resource_type: WorldResource, amount: int)
signal resource_depleted(node: ResourceNode)

@export var resource_type: WorldResource
@export var resource_amount: int

func make_job(in_villager: VillagerCharacter) -> VillagerJobBase:
	return VillagerJobGatherer.new(in_villager, self)

# Function to figure out how much a villager can gather from this node. This can be overridden by subclasses for different behavior.
# TODO: Consider villager skills, tools, etc.
func calculate_gathering_amount(in_villager: VillagerCharacter) -> int:
	return 5


func try_extract_resources(in_villager: VillagerCharacter) -> bool:
	assert(is_instance_valid(in_villager))
	assert(is_instance_valid(owning_world))
	
	var amount_gathered: int = calculate_gathering_amount(in_villager)

	# Ensure we don't gather more than what's available
	if amount_gathered > resource_amount:
		amount_gathered = resource_amount
	
	# Remove resources from the node and add to the world's stockpile
	if owning_world.try_add_to_stockpile(resource_type, amount_gathered):
		resource_amount -= amount_gathered
		resources_extracted.emit(self, resource_type, amount_gathered)
		_on_resource_extracted(in_villager, amount_gathered)
		
		if resource_amount <= 0:
			resource_depleted.emit(self)
			_on_resource_depleted()
		
		return true
	else:
		return false


func _on_resource_extracted(villager: VillagerCharacter, extracted_amount: int) -> void:
	pass


func _on_resource_depleted() -> void:
	pass