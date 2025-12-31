class_name VillagerJobCrafter extends VillagerJobBase

var target_recipe
var target_quantity

func _init(in_owning_villager: VillagerCharacter) -> void:
	super (in_owning_villager)
	job_title = "Crafter"


func do_work() -> void:
	print("Villager ", owning_villager.character_name, " did some crafting.")
