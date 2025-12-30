class_name WorldUI extends Control

@export var owning_world: IslandWorld
@export var end_turn_button: Button
@export var spawn_villager_button: Button
@export var stockpile_food_value_label: Label
@export var stockpile_wood_value_label: Label
@export var current_turn_value_label: Label
@export var current_villagers_count_value_label: Label
@export var villagers_list: ItemList

var structure_menu: StructureMenu
var structure_menu_scene = preload("res://UI/structure_menu.tscn")


func _ready():
	owning_world.world_loaded.connect(_on_world_loaded)


func _input(event):
	if event.is_action_pressed("interact"):
		assert(is_instance_valid(owning_world))
		if is_instance_valid(owning_world.current_selected_structure) and not is_instance_valid(structure_menu):
			structure_menu = structure_menu_scene.instantiate() as StructureMenu
			structure_menu.initialize_ui(owning_world, owning_world.current_selected_structure)
			add_child(structure_menu)
			structure_menu.assign_villager_button.grab_focus.call_deferred()
			
	if event.is_action_pressed("cancel") and is_instance_valid(structure_menu):
		remove_child(structure_menu)
		structure_menu = null
	
	if event.is_action_pressed("add_villager"):
		assert(is_instance_valid(owning_world))
		owning_world.spawn_villager()
	
	if event.is_action_pressed("end_turn"):
		assert(is_instance_valid(owning_world))
		owning_world.end_turn()


func initialize_ui(in_owning_world: IslandWorld) -> void:
	assert(is_instance_valid(in_owning_world))
	owning_world = in_owning_world
	
	assert(is_instance_valid(end_turn_button))
	assert(is_instance_valid(spawn_villager_button))
	assert(is_instance_valid(stockpile_food_value_label))
	assert(is_instance_valid(stockpile_wood_value_label))
	assert(is_instance_valid(current_turn_value_label))
	assert(is_instance_valid(current_villagers_count_value_label))
	
	# Initialize values from current world
	_on_stockpile_changed(owning_world.stockpile)
	_on_turn_ended(owning_world.current_turn)
	_on_villager_count_changed(owning_world.get_current_villagers_count())
	_on_villagers_list_changed(owning_world.characters)
	
	# Connect UI to owning world state change events
	end_turn_button.pressed.connect(owning_world.end_turn)
	spawn_villager_button.pressed.connect(owning_world.spawn_villager)
	owning_world.stockpile_changed.connect(_on_stockpile_changed)
	owning_world.turn_ended.connect(_on_turn_ended)
	owning_world.villager_count_changed.connect(_on_villager_count_changed)
	owning_world.villagers_changed.connect(_on_villagers_list_changed)


func _on_stockpile_changed(new_stockpile: Dictionary[IslandWorld.STOCKPILE, int]) -> void:
	stockpile_food_value_label.text = str(new_stockpile[IslandWorld.STOCKPILE.FOOD])
	stockpile_wood_value_label.text = str(new_stockpile[IslandWorld.STOCKPILE.WOOD])


func _on_turn_ended(turn_number: int) -> void:
	current_turn_value_label.text = str(turn_number)


func _on_villager_count_changed(new_villager_count: int) -> void:
	current_villagers_count_value_label.text = str(new_villager_count)


func _on_villagers_list_changed(new_villagers_list: Array[VillagerCharacter]) -> void:
	villagers_list.clear()
	
	for villager in new_villagers_list:
		villagers_list.add_item(villager.character_name)


func _on_world_loaded() -> void:
	initialize_ui(owning_world)
