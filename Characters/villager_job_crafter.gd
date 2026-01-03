class_name VillagerJobCrafter extends VillagerJobBase

var target_quantity: int

func _init(in_owning_villager: VillagerCharacter) -> void:
	super (in_owning_villager)
	job_title = "Crafter"


func do_work() -> void:
	super.do_work()
	print("Villager ", owning_villager.character_name, " did some crafting.")


# TODO: Adjust based on item complexity and villager stats
func get_energy_cost() -> int:
	return 5