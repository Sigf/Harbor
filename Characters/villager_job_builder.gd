class_name VillagerJobBuilder extends VillagerJobBase

var target_structure

func _init(in_owning_villager: VillagerCharacter) -> void:
	super(in_owning_villager)
	job_title = "Builder"


func do_work() -> void:
	print("Villager ", owning_villager.character_name, " did some building.")
