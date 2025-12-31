class_name ResourceNodeBush extends ResourceNode

var food_resource: WorldResource = preload("res://World/WorldResources/food_resource.tres")


func make_job(in_villager: VillagerCharacter) -> VillagerJobBase:
	return VillagerJobGatherer.new(in_villager, self)


func try_extract_resources(in_villager: VillagerCharacter) -> bool:
	assert(is_instance_valid(in_villager))
	assert(is_instance_valid(owning_world))
	
	var ammount_gathered: int = 5
	
	if owning_world.try_add_to_stockpile(food_resource, ammount_gathered):
		print("Villager ", in_villager.character_name, " gathered ", ammount_gathered, " units of food from a bush.")
		return true
	
	return false
