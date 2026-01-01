class_name StructureMenu extends Control

@export var assign_villager_button: Button
@export var villager_list_container: VBoxContainer
var villager_assignment_button_scene: PackedScene = preload("res://UI/WorldUI/villager_assignment_button.tscn")

var current_world: IslandWorld
var current_structure: WorldStructure


func initialize_ui(owner_world: IslandWorld, target_structure: WorldStructure) -> void:
	current_structure = target_structure
	current_world = owner_world
	grab_focus.call_deferred()
	assign_villager_button.pressed.connect(_on_assign_villager_button_pressed)


func _process(delta: float) -> void:
	assert(is_instance_valid(current_structure))
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	var target_screen_position: Vector2 = camera.unproject_position(current_structure.global_position)
	set_position(target_screen_position)


func generate_villager_list() -> void:
	# Remove any existing items in the list
	for child in villager_list_container.get_children():
		child.queue_free()
		
	assert(is_instance_valid(current_world))
	assert(is_instance_valid(current_structure))
	
	# Generate new list
	var button_array: Array[VillagerAssignmentButton]
	for villager in current_world.characters:
		if not villager.current_job:
			var new_button: VillagerAssignmentButton = villager_assignment_button_scene.instantiate() as VillagerAssignmentButton
			new_button.initialize_ui(self, villager, current_structure.make_job(villager))
			villager_list_container.add_child(new_button)
			villager_list_container.reset_size()
			button_array.append(new_button)
	
	# switch focus to the first entry in the list
	if not button_array.is_empty():
		button_array[0].assign_villager_button.grab_focus.call_deferred()


func _on_assign_villager_button_pressed() -> void:
	generate_villager_list()


# Remove itself from the world UI scene
func close_window() -> void:
	var parent: WorldUI = get_parent() as WorldUI
	assert(is_instance_valid(parent))
	
	parent.structure_menu = null
	parent.remove_child(self)
