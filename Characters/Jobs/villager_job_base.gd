@abstract class_name VillagerJobBase extends RefCounted
# A job is a task that a villager does on a turn. It should only encapsulate a single action on a turn. It doesn't represent the overal task, like building a structure over several turns.

signal job_completed(job: VillagerJobBase)
signal job_cancelled(job: VillagerJobBase)

var job_title: String
var owning_villager: VillagerCharacter
var energy_cost: int


# Function to create a copy of this job. This should check if the job can be re-assigned, and create a new copy of the job. Will return null if the job cannot be copied.
func try_copy_job() -> VillagerJobBase:
	return null


func _init(in_owning_villager: VillagerCharacter) -> void:
	assert(is_instance_valid(in_owning_villager))
	owning_villager = in_owning_villager


func on_job_assigned() -> void:
	pass


func do_work() -> void:
	job_completed.emit(self)


func cancel_job() -> void:
	job_cancelled.emit(self)


# Short description string of what the job does
func get_job_description() -> String:
	return "No description available."
