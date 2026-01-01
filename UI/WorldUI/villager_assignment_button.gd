class_name VillagerAssignmentButton extends Control

@export var assign_villager_button: Button

var villager: VillagerCharacter
var job: VillagerJobBase
var owning_structure_menu: StructureMenu


func _ready() -> void:
	assert(is_instance_valid(villager))
	assert(is_instance_valid(job))


func initialize_ui(in_structure_menu: StructureMenu, in_villager: VillagerCharacter, in_job: VillagerJobBase) -> void:
	assert(is_instance_valid(in_structure_menu))
	assert(is_instance_valid(in_villager))
	assert(is_instance_valid(in_job))
	assert(is_instance_valid(assign_villager_button))

	owning_structure_menu = in_structure_menu
	villager = in_villager
	job = in_job
	
	assign_villager_button.text = villager.character_name
	assign_villager_button.pressed.connect(_on_button_pressed)
	reset_size()


func _on_button_pressed() -> void:
	villager.assign_work(job)
	owning_structure_menu.close_window()
