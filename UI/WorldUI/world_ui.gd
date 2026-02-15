class_name WorldUI extends Control

var wood_resource: WorldResource = preload("res://World/WorldResources/wood_resource.tres")
var food_resource: WorldResource = preload("res://World/WorldResources/food_resource.tres")

@export var owning_world: IslandWorld
@export var end_turn_button: Button
@export var spawn_villager_button: Button
@export var stockpile_food_value_label: Label
@export var stockpile_wood_value_label: Label
@export var current_turn_value_label: Label
@export var current_villagers_count_value_label: Label
@export var villager_info_panel: VillagerInfoPanel
@export var gameplay_mode_menu: WorldModeMenu
@export var structure_menu: StructureMenu


func _ready() -> void:
	assert(is_instance_valid(owning_world))
	owning_world.world_loaded.connect(_on_world_loaded)
	owning_world.gameplay_mode_changed.connect(_on_gameplay_mode_changed)
	structure_menu.visible = false


func open_structure_menu(target_structure: WorldStructure) -> void:
	assert(is_instance_valid(structure_menu))
	assert(is_instance_valid(target_structure))

	structure_menu.visible = true
	structure_menu.initialize_ui(owning_world, target_structure)


func close_structure_menu() -> void:
	assert(is_instance_valid(structure_menu))

	structure_menu.visible = false
	structure_menu.release_focus()


func initialize_ui(in_owning_world: IslandWorld) -> void:
	assert(is_instance_valid(in_owning_world))
	owning_world = in_owning_world
	
	assert(is_instance_valid(end_turn_button))
	assert(is_instance_valid(spawn_villager_button))
	assert(is_instance_valid(stockpile_food_value_label))
	assert(is_instance_valid(stockpile_wood_value_label))
	assert(is_instance_valid(current_turn_value_label))
	assert(is_instance_valid(current_villagers_count_value_label))
	assert(is_instance_valid(villager_info_panel))
	
	# Initialize values from current world
	villager_info_panel.initialize_ui(self )
	_on_stockpile_changed(owning_world.stockpile)
	_on_turn_ended(owning_world.current_turn)
	_on_villager_count_changed(owning_world.get_current_villagers_count())
	
	# Connect UI to owning world state change events
	end_turn_button.pressed.connect(owning_world.end_turn)
	spawn_villager_button.pressed.connect(owning_world.spawn_villager)
	owning_world.stockpile_changed.connect(_on_stockpile_changed)
	owning_world.turn_ended.connect(_on_turn_ended)
	owning_world.villager_count_changed.connect(_on_villager_count_changed)


func _on_stockpile_changed(new_stockpile: Dictionary[WorldResource, int]) -> void:
	stockpile_food_value_label.text = str(new_stockpile[food_resource])
	stockpile_wood_value_label.text = str(new_stockpile[wood_resource])


func _on_turn_ended(turn_number: int) -> void:
	current_turn_value_label.text = str(turn_number)


func _on_villager_count_changed(new_villager_count: int) -> void:
	current_villagers_count_value_label.text = str(new_villager_count)


func _on_world_loaded() -> void:
	initialize_ui(owning_world)


func _on_gameplay_mode_changed(previous_mode: IslandWorld.WORLD_GAMEPLAY_MODE, new_mode: IslandWorld.WORLD_GAMEPLAY_MODE) -> void:
	assert(is_instance_valid(gameplay_mode_menu))
	gameplay_mode_menu.on_world_ui_mode_changed(new_mode)

	match previous_mode:
		IslandWorld.WORLD_GAMEPLAY_MODE.VILLAGERS_INFO:
			villager_info_panel.visible = false

	match new_mode:
		IslandWorld.WORLD_GAMEPLAY_MODE.VILLAGERS_INFO:
			villager_info_panel.visible = true
			villager_info_panel.grab_focus.call_deferred()
