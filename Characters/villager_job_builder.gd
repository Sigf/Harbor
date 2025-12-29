class_name VillagerJobBuilder extends VillagerJobBase

var TargetStructure

func _init(owning_villager: VillagerCharacter) -> void:
	super(owning_villager)
	job_title = "Builder"


func do_work() -> void:
	print("Villager ", villager_owner.character_name, " did some building.")
