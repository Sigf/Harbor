@abstract class_name VillagerJobBase extends RefCounted

var job_title: String
var owning_villager: VillagerCharacter

func _init(in_owning_villager: VillagerCharacter) -> void:
	assert(is_instance_valid(in_owning_villager))
	
	owning_villager = in_owning_villager


@abstract func do_work() -> void
