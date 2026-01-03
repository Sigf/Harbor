class_name VillagerJobBuilder extends VillagerJobBase

var target_structure

func _init(in_owning_villager: VillagerCharacter) -> void:
	super (in_owning_villager)
	job_title = "Builder"


func do_work() -> void:
	super.do_work()
	print("Villager ", owning_villager.character_name, " did some building.")


# TODO: Adjust based on structure complexity and villager stats
func get_energy_cost() -> int:
	return 5
