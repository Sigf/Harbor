class_name VillagerJobBase extends RefCounted

var job_title: String
var villager_owner: VillagerCharacter

func _init(owning_villager: VillagerCharacter) -> void:
	villager_owner = owning_villager


func do_work() -> void:
	pass
