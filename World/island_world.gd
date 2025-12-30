class_name IslandWorld extends Node3D

signal turn_ended(turn_number: int)
signal villager_spawned(new_villager: VillagerCharacter)
signal villager_count_changed(new_villager_count: int)
signal villagers_changed(villagers_list: Array[VillagerCharacter])
signal stockpile_changed(new_stockpile: Dictionary[STOCKPILE, int])
signal current_selected_structure_changed(new_structure: WorldStructure)
signal world_loaded()

var current_turn: int
var characters: Array[VillagerCharacter]
var harbor_structure: StructureHarbor
var active_camera: Camera3D
var current_selected_structure: WorldStructure

const character_res = preload("res://Characters/villager_character.tscn")
const new_villager_name_set: CharacterNameSet = preload("res://Characters/character_names_english.tres")

enum STOCKPILE {FOOD, WOOD}
var stockpile: Dictionary[STOCKPILE, int] = {
	STOCKPILE.FOOD: 10,
	STOCKPILE.WOOD: 20
}

# Daily log variables
var resource_used: Dictionary[STOCKPILE, int]
var resource_gathered: Dictionary[STOCKPILE, int]
var new_villagers: Array[VillagerCharacter]


func _ready():
	current_turn = 0
	get_world_entities()
	active_camera = get_viewport().get_camera_3d()
	world_loaded.emit()


func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var origin = active_camera.global_position
	var collision_mask = 0b10 # Only target structures
	var end = origin + -active_camera.global_transform.basis.z * 10000.0
	var query = PhysicsRayQueryParameters3D.create(origin, end, collision_mask)
	var result = space_state.intersect_ray(query)
	
	# Deselect if we are not pointing at the structure anymore
	if result.is_empty() && is_instance_valid(current_selected_structure):
		current_selected_structure.selected = false
		current_selected_structure = null
		current_selected_structure_changed.emit(current_selected_structure)
	
	# Select if we are pointing at new structure, deselect old one
	if not result.is_empty():
		var collider = result.collider as StaticBody3D
		var owning_structure = collider.get_parent_node_3d() as WorldStructure
		
		if is_instance_valid(owning_structure) and owning_structure != current_selected_structure:
			if is_instance_valid(current_selected_structure):
				current_selected_structure.selected = false
				
			current_selected_structure = result.collider.get_parent_node_3d() as WorldStructure
			assert(is_instance_valid(current_selected_structure))
			
			current_selected_structure.selected = true
			current_selected_structure_changed.emit(current_selected_structure)


func end_turn() -> void:
	turn_ended.emit(current_turn)
	print_daily_log()
	_reset_daily_tracked_variables()
	current_turn += 1


func spawn_villager() -> void:
	assert(is_instance_valid(harbor_structure))
	assert(is_instance_valid(new_villager_name_set))
	
	var spawn_location = harbor_structure.get_villager_spawn_location()
	var new_character = character_res.instantiate() as VillagerCharacter
	assert(is_instance_valid(new_character))
	
	add_child(new_character)
	characters.append(new_character)
	new_villagers.append(new_character)
	new_character.position = spawn_location
	var new_character_name = new_villager_name_set.get_random_male_name()
	new_character.initialize_character(self, new_character_name, 10, 20)
	print("Character ", new_character.character_name, " was added to the world.")
	turn_ended.connect(new_character._on_turn_ended)
	villager_spawned.emit(new_character)
	villager_count_changed.emit(characters.size())
	villagers_changed.emit(characters)


func get_world_entities() -> void:
	for child in self.get_children():
		# Find one harbor structure
		if not is_instance_valid(harbor_structure) and child is StructureHarbor:
			harbor_structure = child as StructureHarbor
			
		# Get every already spawned characters
		if child is VillagerCharacter:
			var found_villager = child as VillagerCharacter
			
			# HACK: This will not be needed once worlds are saved and generated from code
			if not is_instance_valid(found_villager.owning_world):
				found_villager.owning_world = self
				
			turn_ended.connect(found_villager._on_turn_ended)
			characters.append(found_villager)
			
	assert(is_instance_valid(harbor_structure))


func try_use_stockpile(stockpile_type: STOCKPILE, ammount: int) -> bool:
	assert(stockpile.has(stockpile_type))
	assert(ammount > 0)
	
	if stockpile[stockpile_type] >= ammount:
		stockpile[stockpile_type] -= ammount
		
		if resource_used.has(stockpile_type):
			resource_used[stockpile_type] += ammount
		else:
			resource_used[stockpile_type] = ammount
			
		stockpile_changed.emit(stockpile)
		return true
		
	return false


func try_add_to_stockpile(stockpile_type: STOCKPILE, ammount: int) -> bool:
	assert(stockpile.has(stockpile_type))
	assert(ammount > 0)
	
	# TODO: Should probably add a limit to stockpile
	stockpile[stockpile_type] += ammount
	
	if resource_gathered.has(stockpile_type):
		resource_gathered[stockpile_type] += ammount
	else:
		resource_gathered[stockpile_type] = ammount
	
	stockpile_changed.emit(stockpile)
	return true


func get_current_villagers_count() -> int:
	return characters.size()


func print_world_stats() -> void:
	print("Current Turn: ", current_turn)
	print("Characters in world: ", characters.size())


func _reset_daily_tracked_variables() -> void:
	for resource in resource_used:
		resource_used[resource] = 0
	
	for resource in resource_gathered:
		resource_gathered[resource] = 0
	
	new_villagers.clear()


func print_daily_log() -> void:
	print("Turn ", current_turn, "ended.")
	print("Resource Gathered:")
	for resource in resource_gathered:
		print("  ", resource_gathered[resource], " ", str(resource))
