class_name StructureHarbor extends WorldStructure

@export var villager_spawn_location: Node3D


# Not implemented at the moment. The Harbor will be where new research are unlocked, and counts as crafting time
func make_job(in_villager: VillagerCharacter) -> VillagerJobBase:
	return VillagerJobCrafter.new(in_villager)


func get_villager_spawn_location() -> Vector3:
	return villager_spawn_location.global_position
