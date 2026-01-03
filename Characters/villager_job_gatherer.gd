class_name VillagerJobGatherer extends VillagerJobBase

var gathering_node: ResourceNode
var amount_to_gather: int


static func can_make_job_from_node(in_villager: VillagerCharacter, in_node: ResourceNode) -> bool:
	assert(is_instance_valid(in_villager))
	assert(is_instance_valid(in_node))

	# Check the leftover resources after the previously assigned jobs
	var resources_left: int = in_node.resource_amount
	for job in in_node.jobs_assigned:
		if is_instance_valid(job):
			assert(job.amount_to_gather > 0)
			resources_left -= job.amount_to_gather
	
	if resources_left <= 0:
		return false
	
	# Check for villager energy
	var new_energy_cost: int = VillagerJobGatherer.calculate_energy_cost(in_villager, in_node)
	if in_villager.current_energy < new_energy_cost:
		return false
	
	return true


# Try to make a new gathering job from the given resource node. Returns null if the job cannot be made.
static func make_job_from_node(in_villager: VillagerCharacter, in_node: ResourceNode) -> VillagerJobGatherer:
	assert(is_instance_valid(in_villager))
	assert(is_instance_valid(in_node))

	return VillagerJobGatherer.new(in_villager, in_node) if VillagerJobGatherer.can_make_job_from_node(in_villager, in_node) else null


# Calculate the potential gathering amount given a villager and resource node.
# TODO: Consider villager stats, tools and node properties.
static func calculate_gathering_amount(in_villager: VillagerCharacter, in_node: ResourceNode) -> int:
	return 5


# Calculate the energy cost for gathering from the given node.
# TODO: Consider villager stats, tools and node properties.
static func calculate_energy_cost(in_villager: VillagerCharacter, in_node: ResourceNode) -> int:
	return in_node.base_energy_cost


func _init(in_owning_villager: VillagerCharacter, in_node: ResourceNode) -> void:
	assert(is_instance_valid(in_node))
	assert(VillagerJobGatherer.can_make_job_from_node(in_owning_villager, in_node))
	
	job_title = "Gatherer"
	gathering_node = in_node
	amount_to_gather = VillagerJobGatherer.calculate_gathering_amount(in_owning_villager, in_node)
	energy_cost = VillagerJobGatherer.calculate_energy_cost(in_owning_villager, in_node)
	in_node.resource_depleted.connect(_on_node_depleted)

	super (in_owning_villager)


func do_work() -> void:
	super.do_work()
	assert(is_instance_valid(gathering_node))
	
	if gathering_node.try_extract_resources(amount_to_gather):
		print("Villager ", owning_villager.character_name, " gathered ", amount_to_gather, " ", gathering_node.resource_type.world_resource_name, " from ", gathering_node.structure_name, ".")
	else:
		print("Villager ", owning_villager.character_name, " tried to gather node but couldn't.")
	
	# Remove this job from the node's assigned jobs
	if self in gathering_node.jobs_assigned:
		gathering_node.jobs_assigned.erase(self)


func _on_node_depleted(node: ResourceNode) -> void:
	print("Villager ", owning_villager.character_name, "'s gathering node (", node.structure_name, ") has been depleted.")


func try_copy_job() -> VillagerJobBase:
	if is_instance_valid(gathering_node) and VillagerJobGatherer.can_make_job_from_node(owning_villager, gathering_node):
		return VillagerJobGatherer.make_job_from_node(owning_villager, gathering_node)
	else:
		return null


func on_job_assigned() -> void:
	assert(is_instance_valid(gathering_node))
	gathering_node.jobs_assigned.append(self)


# TODO: Adjust based on resource type and villager stats and equipment
func get_energy_cost() -> int:
	assert(is_instance_valid(gathering_node))
	return gathering_node.base_energy_cost


func get_job_description() -> String:
	assert(is_instance_valid(gathering_node))
	return "Gathering " + gathering_node.resource_type.world_resource_name + " from " + gathering_node.structure_name + "."


func cancel_job() -> void:
	super.cancel_job()
	
	# Remove this job from the node's assigned jobs
	if is_instance_valid(gathering_node) and self in gathering_node.jobs_assigned:
		gathering_node.jobs_assigned.erase(self)