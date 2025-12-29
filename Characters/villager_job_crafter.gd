class_name VillagerJobCrafter extends VillagerJobBase

var target_recipe
var target_quantity

func _init(owning_villager: VillagerCharacter) -> void:
	super(owning_villager)
	job_title = "Crafter"


func do_work() -> void:
	print("Villager ", villager_owner.character_name, " did some crafting.")
