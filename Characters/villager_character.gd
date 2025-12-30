class_name VillagerCharacter extends Node3D

@export var character_name: String
@export var current_health: int
@export var current_energy: int
@export var max_health: int
@export var max_energy: int
var owning_world: IslandWorld
var current_job: VillagerJobBase


func do_work() -> void:
	if is_instance_valid(current_job):
		current_job.do_work()
	else:
		print("No work assigned to ", character_name, ".")


func _on_turn_ended(turn_number: int):
	do_work()
	if not try_eat_food():
		print("Villager ", character_name, " could not find anything to eat.")


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
	current_job = new_job


func try_eat_food() -> bool:
	assert(is_instance_valid(owning_world))
	
	var ate_food = owning_world.try_use_stockpile(IslandWorld.STOCKPILE.FOOD, 1)
	if ate_food:
		current_energy = max_energy
	else:
		current_energy = ceil(max_energy / 2.0)
	
	return ate_food
