class_name IslandWorld extends Node3D

signal turn_ended(turn_number: int)
signal villager_spawned(new_villager: VillagerCharacter)
signal villager_count_changed(new_villager_count: int)
signal villagers_changed(villagers_list: Array[VillagerCharacter])
signal stockpile_changed(new_stockpile: Dictionary[STOCKPILE, int])

var current_turn: int
var characters: Array[VillagerCharacter]
var harbor_structure: StructureHarbor

const character_res = preload("res://Characters/villager_character.tscn")
const new_villager_name_set: CharacterNameSet = preload("res://Characters/character_names_english.tres")

enum STOCKPILE {FOOD, WOOD}
var stockpile: Dictionary[STOCKPILE, int] = {
	STOCKPILE.FOOD: 10,
	STOCKPILE.WOOD: 20
}


func _ready():
	current_turn = 0
	get_world_entities()


func end_turn() -> void:
	current_turn += 1
	turn_ended.emit(current_turn)


func spawn_villager() -> void:
	assert(is_instance_valid(harbor_structure))
	assert(is_instance_valid(new_villager_name_set))
	
	var spawn_location = harbor_structure.get_villager_spawn_location()
	var new_character = character_res.instantiate() as VillagerCharacter
	assert(is_instance_valid(new_character))
	
	add_child(new_character)
	characters.append(new_character)
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
		stockpile_changed.emit(stockpile)
		return true
		
	return false


func try_add_to_stockpile(stockpile_type: STOCKPILE, ammount: int) -> bool:
	assert(stockpile.has(stockpile_type))
	assert(ammount > 0)
	
	# TODO: Should probably add a limit to stockpile
	stockpile[stockpile_type] += ammount
	stockpile_changed.emit(stockpile)
	return true


func get_current_villagers_count() -> int:
	return characters.size()


func print_world_stats() -> void:
	print("Current Turn: ", current_turn)
	print("Characters in world: ", characters.size())
