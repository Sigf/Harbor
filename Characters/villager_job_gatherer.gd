class_name VillagerJobGatherer extends VillagerJobBase

var gathering_node: ResourceNode


func _init(in_owning_villager: VillagerCharacter, in_node: ResourceNode) -> void:
	super(in_owning_villager)
	assert(is_instance_valid(in_node))
	
	job_title = "Gatherer"
	gathering_node = in_node


func do_work() -> void:
	assert(is_instance_valid(gathering_node))
	
	if not gathering_node.try_extract_resources(owning_villager):
		print("Villager ", owning_villager.character_name, " tried to gather node but couldn't.")
