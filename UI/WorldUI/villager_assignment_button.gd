class_name VillagerAssignmentButton extends Control
# Button to assign a new job to a villager

@export var assign_villager_button: Button

var villager: VillagerCharacter
var owning_structure_menu: StructureMenu


func _ready() -> void:
	assert(is_instance_valid(villager))


func initialize_ui(in_structure_menu: StructureMenu, in_villager: VillagerCharacter) -> void:
	assert(is_instance_valid(in_structure_menu))
	assert(is_instance_valid(in_villager))
	assert(is_instance_valid(assign_villager_button))

	owning_structure_menu = in_structure_menu
	villager = in_villager
	
	assign_villager_button.text = villager.character_name
	reset_size()
