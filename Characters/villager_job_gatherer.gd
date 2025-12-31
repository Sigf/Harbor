class_name VillagerJobGatherer extends VillagerJobBase

var gathering_node: ResourceNode


func _init(in_owning_villager: VillagerCharacter, in_node: ResourceNode) -> void:
	super (in_owning_villager)
	assert(is_instance_valid(in_node))
	
	job_title = "Gatherer"
	gathering_node = in_node
	in_node.resource_depleted.connect(_on_node_depleted)


func do_work() -> void:
	assert(is_instance_valid(gathering_node))
	
	if not gathering_node.try_extract_resources(owning_villager):
		print("Villager ", owning_villager.character_name, " tried to gather node but couldn't.")


func _on_node_depleted(node: ResourceNode) -> void:
	print("Villager ", owning_villager.character_name, "'s gathering node (", node.structure_name, ") has been depleted.")
	# Drop the job since the resource is gone.
	owning_villager.remove_job(self)
