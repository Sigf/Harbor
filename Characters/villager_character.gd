class_name VillagerCharacter extends Node3D

var food_resource: WorldResource = preload("res://World/WorldResources/food_resource.tres")

@export var character_name: String
@export var max_health: int
@export var max_energy: int
@export var base_daily_food_consumption: int = 2

var current_health: int
var current_energy: int:
	set(value):
		current_energy = clamp(value, 0, max_energy)
		energy_changed.emit(self , current_energy)

signal job_queue_changed(villager: VillagerCharacter, job_queue: Array[VillagerJobBase])
signal energy_changed(villager: VillagerCharacter, new_energy: int)

var owning_world: IslandWorld
var job_queue: Array[VillagerJobBase]


func do_work() -> void:
	for job in job_queue:
		if is_instance_valid(job):
			job.do_work()


func _on_turn_ended(turn_number: int) -> void:
	do_work()
	if not try_eat_food():
		print("Villager ", character_name, " could not find anything to eat.")
	
	# Try re-queing jobs if energy allows
	var old_job_queue: Array[VillagerJobBase] = job_queue.duplicate()
	job_queue.clear()
	
	for job in old_job_queue:
		var job_copy: VillagerJobBase = job.try_copy_job()
		if is_instance_valid(job_copy):
			assign_work(job_copy)
	
	job_queue_changed.emit(self , job_queue)


func initialize_character(new_owning_world: IslandWorld, new_name: String, start_health: int, start_energy: int) -> void:
	assert(is_instance_valid(new_owning_world))
	assert(not new_name.is_empty())
	
	character_name = new_name
	max_health = start_health
	max_energy = start_energy
	current_health = max_health
	current_energy = max_energy
	owning_world = new_owning_world


func assign_work(new_job: VillagerJobBase) -> void:
	assert(is_instance_valid(new_job))

	# The energy cost should have already been verified by the job creation process
	assert(new_job.energy_cost <= current_energy)

	current_energy -= new_job.energy_cost
	job_queue.append(new_job)
	new_job.on_job_assigned()
	job_queue_changed.emit(self , job_queue)


func try_eat_food() -> bool:
	assert(is_instance_valid(owning_world))
	
	var ate_food: bool = owning_world.try_use_stockpile(food_resource, base_daily_food_consumption)
	if ate_food:
		current_energy = max_energy
	else:
		current_energy = ceil(max_energy / 2.0)
	
	return ate_food


func remove_job(target_job: VillagerJobBase) -> void:
	assert(is_instance_valid(target_job))
	
	if job_queue.has(target_job):
		current_energy += target_job.energy_cost # Refund energy cost
		job_queue.erase(target_job)
		job_queue_changed.emit(self , job_queue)