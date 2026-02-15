class_name IslandWorld extends Node3D
# The world where the game runs. Manages the turn system, world entities, and current world states such as stockpiles. Any entities in the world should be spawned by this class so they can reference their owning world.

@export var construction_grid: ConstructionGrid
@export var camera_controller: PlayerCameraController
@export var world_ui: WorldUI
@export var world_content_root: Node3D

var wood_resource: WorldResource = preload("res://World/WorldResources/wood_resource.tres")
var food_resource: WorldResource = preload("res://World/WorldResources/food_resource.tres")

signal turn_ended(turn_number: int)
signal villager_spawned(new_villager: VillagerCharacter)
signal villager_count_changed(new_villager_count: int)
signal villagers_changed(villagers_list: Array[VillagerCharacter])
signal stockpile_changed(new_stockpile: Dictionary[WorldResource, int])
signal current_selected_structure_changed(new_structure: WorldStructure)
signal world_loaded()
signal gameplay_mode_changed(previous_mode: WORLD_GAMEPLAY_MODE, new_mode: WORLD_GAMEPLAY_MODE)

var current_turn: int
var characters: Array[VillagerCharacter]
var harbor_structure: StructureHarbor
var active_camera: Camera3D
var current_selected_structure: WorldStructure

const character_res = preload("res://Characters/villager_character.tscn")
const new_villager_name_set: CharacterNameSet = preload("res://Characters/NameSets/character_names_english.tres")

# Resource stockpile
enum STOCKPILE {FOOD, WOOD}
var stockpile: Dictionary[WorldResource, int] = {
	food_resource: 10,
	wood_resource: 20
}

# Gameplay modes
enum WORLD_GAMEPLAY_MODE {WORLD_STATS, VILLAGERS_INFO, CONSTRUCTION}
var gameplay_modes_list: Array[WORLD_GAMEPLAY_MODE] = [
	WORLD_GAMEPLAY_MODE.VILLAGERS_INFO,
	WORLD_GAMEPLAY_MODE.CONSTRUCTION,
	WORLD_GAMEPLAY_MODE.WORLD_STATS
]
var current_gameplay_mode_index: int = 0

# Daily log variables
var resource_used: Dictionary[WorldResource, int]
var resource_gathered: Dictionary[WorldResource, int]
var new_villagers: Array[VillagerCharacter]


func _ready() -> void:
	assert(is_instance_valid(construction_grid))
	assert(is_instance_valid(camera_controller))
	assert(is_instance_valid(world_ui))

	current_turn = 0
	get_world_entities()
	active_camera = get_viewport().get_camera_3d()
	world_loaded.emit()

	# Gameplay mode change handling
	var current_mode: WORLD_GAMEPLAY_MODE = get_current_gameplay_mode()
	gameplay_mode_changed.connect(on_gameplay_mode_changed)
	gameplay_mode_changed.emit(current_mode, current_mode)


func _update_world_selection() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var origin: Vector3 = active_camera.global_position
	var collision_mask: int = 0b10 # Only target structures
	var end: Vector3 = origin + -active_camera.global_transform.basis.z * 10000.0
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end, collision_mask)
	var result: Dictionary = space_state.intersect_ray(query)
	
	# Deselect if we are not pointing at the structure anymore
	if result.is_empty() && is_instance_valid(current_selected_structure):
		current_selected_structure.selected = false
		current_selected_structure = null
		current_selected_structure_changed.emit(current_selected_structure)
	
	# Select if we are pointing at new structure, deselect old one
	if not result.is_empty():
		var collider: StaticBody3D = result.collider as StaticBody3D
		var owning_structure: WorldStructure = collider.get_parent_node_3d() as WorldStructure
		
		if is_instance_valid(owning_structure) and owning_structure != current_selected_structure:
			if is_instance_valid(current_selected_structure):
				current_selected_structure.selected = false
				
			current_selected_structure = result.collider.get_parent_node_3d() as WorldStructure
			assert(is_instance_valid(current_selected_structure))
			
			current_selected_structure.selected = true
			current_selected_structure_changed.emit(current_selected_structure)


func _physics_process(delta: float) -> void:
	match get_current_gameplay_mode():
		WORLD_GAMEPLAY_MODE.CONSTRUCTION:
			# Pass updated cursor position to construction grid
			construction_grid.cursor_position = camera_controller.target_position
		WORLD_GAMEPLAY_MODE.VILLAGERS_INFO:
			pass
		WORLD_GAMEPLAY_MODE.WORLD_STATS:
			_update_world_selection()


func _input(event: InputEvent) -> void:
	var current_mode: WORLD_GAMEPLAY_MODE = get_current_gameplay_mode()

	if event.is_action_pressed("gameplay_mode_change_next"):
		if (current_gameplay_mode_index + 1) >= gameplay_modes_list.size():
			current_gameplay_mode_index = 0
		else:
			current_gameplay_mode_index += 1
		gameplay_mode_changed.emit(current_mode, gameplay_modes_list[current_gameplay_mode_index])
	if event.is_action_pressed("gameplay_mode_change_previous"):
		if (current_gameplay_mode_index - 1) < 0:
			current_gameplay_mode_index = gameplay_modes_list.size() - 1
		else:
			current_gameplay_mode_index -= 1
		gameplay_mode_changed.emit(current_mode, gameplay_modes_list[current_gameplay_mode_index])
	
	# open structure menu when selecting a building
	if event.is_action_pressed("ui_accept") and current_mode == WORLD_GAMEPLAY_MODE.WORLD_STATS and is_instance_valid(current_selected_structure) and not world_ui.structure_menu.visible:
		world_ui.open_structure_menu(current_selected_structure)
		

func on_gameplay_mode_changed(previous_mode: WORLD_GAMEPLAY_MODE, new_mode: WORLD_GAMEPLAY_MODE) -> void:
	assert(is_instance_valid(construction_grid))

	match previous_mode:
		WORLD_GAMEPLAY_MODE.WORLD_STATS:
			# Clear current selection
			if is_instance_valid(current_selected_structure):
				current_selected_structure.selected = false
				current_selected_structure_changed.emit(null)
			
			world_ui.close_structure_menu()
		WORLD_GAMEPLAY_MODE.CONSTRUCTION:
			# Disable construction grid rendering
			construction_grid.grid_visible = false

	match new_mode:
		WORLD_GAMEPLAY_MODE.CONSTRUCTION:
			camera_controller.active = true
			# Enable construction grid rendering
			construction_grid.grid_visible = true
		WORLD_GAMEPLAY_MODE.VILLAGERS_INFO:
			camera_controller.active = false
		WORLD_GAMEPLAY_MODE.WORLD_STATS:
			camera_controller.active = true
			

# End the current turn, triggering any turn ended events and printing daily logs.
# At the end of the turn, all the villagers run their assigned tasks, and gathering nodes calculate their new resource ammounts for example.
func end_turn() -> void:
	turn_ended.emit(current_turn)
	print_daily_log()
	_reset_daily_tracked_variables()
	current_turn += 1


# Spawn a new villager at the harbor with a random name and default stats. Adds the new villager to the list of tracked characters in the world.
func spawn_villager() -> void:
	assert(is_instance_valid(harbor_structure))
	assert(is_instance_valid(new_villager_name_set))
	
	var spawn_location: Vector3 = harbor_structure.get_villager_spawn_location()
	var new_character: VillagerCharacter = character_res.instantiate() as VillagerCharacter
	assert(is_instance_valid(new_character))
	
	add_child(new_character)
	characters.append(new_character)
	new_villagers.append(new_character)
	new_character.position = spawn_location
	var new_character_name: String = new_villager_name_set.get_random_male_name()
	new_character.initialize_character(self , new_character_name, 10, 20)
	print("Character ", new_character.character_name, " was added to the world.")
	turn_ended.connect(new_character._on_turn_ended)
	villager_spawned.emit(new_character)
	villager_count_changed.emit(characters.size())
	villagers_changed.emit(characters)


# Gather all world entities such as structures and characters that are part of the world. This will be handled differently once the world is loaded from an existing save file.
func get_world_entities() -> void:
	assert(is_instance_valid(world_content_root))
	for child in world_content_root.get_children():
		# Find one harbor structure
		if not is_instance_valid(harbor_structure) and child is StructureHarbor:
			harbor_structure = child as StructureHarbor
			
		# Get every already spawned characters
		if child is VillagerCharacter:
			var found_villager: VillagerCharacter = child as VillagerCharacter
			assert(is_instance_valid(found_villager))
			
			# HACK: This will not be needed once worlds are saved and generated from code
			if not is_instance_valid(found_villager.owning_world):
				found_villager.owning_world = self
				
			turn_ended.connect(found_villager._on_turn_ended)
			characters.append(found_villager)
	
	# If no villagers exist, spawn one to start
	if characters.is_empty():
		spawn_villager()
			
	assert(is_instance_valid(harbor_structure))


func try_use_stockpile(stockpile_type: WorldResource, amount: int) -> bool:
	assert(stockpile.has(stockpile_type))
	assert(amount > 0)
	
	if stockpile[stockpile_type] >= amount:
		stockpile[stockpile_type] -= amount
		
		if resource_used.has(stockpile_type):
			resource_used[stockpile_type] += amount
		else:
			resource_used[stockpile_type] = amount
			
		stockpile_changed.emit(stockpile)
		return true
		
	return false


func try_add_to_stockpile(stockpile_type: WorldResource, amount: int) -> bool:
	assert(stockpile.has(stockpile_type))
	assert(amount > 0)
	
	# TODO: Should probably add a limit to stockpile
	stockpile[stockpile_type] += amount
	
	if resource_gathered.has(stockpile_type):
		resource_gathered[stockpile_type] += amount
	else:
		resource_gathered[stockpile_type] = amount
	
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
	print("Turn ", current_turn, " ended.")
	
	print("Resource Gathered:")
	for resource in resource_gathered:
		print("  ", resource_gathered[resource], " ", str(resource.world_resource_name))
	
	print("Resource Used:")
	for resource in resource_used:
		print("  ", resource_used[resource], " ", str(resource.world_resource_name))
	
	print("New Villagers:")
	for villager in new_villagers:
		print("  ", villager.character_name)


func get_current_gameplay_mode() -> WORLD_GAMEPLAY_MODE:
	return gameplay_modes_list[current_gameplay_mode_index]
