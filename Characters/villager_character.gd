class_name VillagerCharacter extends Node3D

var character_name: String
var character_health: int
var character_energy: int
var owning_world: IslandWorld
var current_job: VillagerJobBase


func do_work() -> void:
	if is_instance_valid(current_job):
		current_job.do_work()
	else:
		print("No work assigned to ", character_name, ".")


func _on_turn_ended(turn_number: int):
	do_work()


func initialize_character(new_owning_world: IslandWorld, new_name: String, start_health: int, start_energy: int) -> void:
	assert(is_instance_valid(new_owning_world))
	assert(not new_name.is_empty())
	
	character_name = new_name
	character_health = start_health
	character_energy = start_energy
	owning_world = new_owning_world


func assign_work(job_class: VillagerJobBase) -> void:
	current_job = job_class.new()
