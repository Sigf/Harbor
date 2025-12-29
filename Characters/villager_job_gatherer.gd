class_name VillagerJobGatherer extends VillagerJobBase

var gathering_node

func _init(owning_villager: VillagerCharacter) -> void:
	super(owning_villager)
	job_title = "Gatherer"


func do_work() -> void:
	print("Villager ", villager_owner.character_name, " did some gathering.")
