class_name IslandWorld extends Node3D

signal turn_ended(turn_number: int)
signal villager_spawned(new_villager: VillagerCharacter)

var current_turn: int
var characters: Array[VillagerCharacter]
var harbor_structure: StructureHarbor
var character_res = preload("res://Characters/villager_character.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	current_turn = 0
	get_world_entities()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	pass


func end_turn() -> void:
	current_turn += 1
	turn_ended.emit(current_turn)


func spawn_villager() -> void:
	assert(is_instance_valid(harbor_structure))
	
	var spawn_location = harbor_structure.get_villager_spawn_location()
	var new_character = character_res.instantiate() as VillagerCharacter
	assert(is_instance_valid(new_character))
	
	add_child(new_character)
	characters.append(new_character)
	new_character.position = spawn_location
	new_character.initialize_base_stats()
	print("Character ", new_character.character_name, " was added to the world.")
	turn_ended.connect(new_character._on_turn_ended)
	villager_spawned.emit(new_character)


func get_world_entities() -> void:
	for child in self.get_children():
		# Find one harbor structure
		if not is_instance_valid(harbor_structure) and child is StructureHarbor:
			harbor_structure = child as StructureHarbor
			
		# Get every already spawned characters
		if child is VillagerCharacter:
			var found_villager = child as VillagerCharacter
			turn_ended.connect(found_villager._on_turn_ended)
			characters.append(found_villager)
			
	assert(is_instance_valid(harbor_structure))


func print_world_stats() -> void:
	print("Current Turn: ", current_turn)
	print("Characters in world: ", characters.size())
