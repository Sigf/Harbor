class_name StructureMenu extends Control

@export var assign_villager_button: Button
@export var villager_list_container: VBoxContainer
var villager_assignment_button_scene: PackedScene = preload("res://UI/WorldUI/villager_assignment_button.tscn")

var current_world: IslandWorld
var current_structure: WorldStructure


func _ready() -> void:
	assert(is_instance_valid(assign_villager_button))
	assert(is_instance_valid(villager_list_container))

	assign_villager_button.pressed.connect(_on_assign_villager_button_pressed)


func initialize_ui(owner_world: IslandWorld, target_structure: WorldStructure) -> void:
	current_structure = target_structure
	current_world = owner_world

	# Set default focus when opening the menu
	assign_villager_button.grab_focus()


func _process(delta: float) -> void:
	if not visible:
		return

	# Update menu position to follow structure
	var camera: Camera3D = get_viewport().get_camera_3d()
	var target_screen_position: Vector2 = camera.unproject_position(current_structure.global_position)
	set_position(target_screen_position)


func generate_villager_list() -> void:
	# Remove any existing items in the list
	for child in villager_list_container.get_children():
		child.queue_free()
		
	assert(is_instance_valid(current_world))
	assert(is_instance_valid(current_structure))

	# HACK: Can only assign villagers to gathering nodees for now
	if current_structure is not ResourceNode:
		return
	
	# Generate new list
	var button_array: Array[VillagerAssignmentButton]
	for villager in current_world.characters:
		# Check if the structure can make a job for this villager
		if VillagerJobGatherer.can_make_job_from_node(villager, current_structure as ResourceNode):
			var new_button: VillagerAssignmentButton = villager_assignment_button_scene.instantiate() as VillagerAssignmentButton
			new_button.initialize_ui(self , villager)

			# Generate the new job only when the button is pressed
			new_button.assign_villager_button.pressed.connect(func() -> void:
				var new_job: VillagerJobGatherer = VillagerJobGatherer.make_job_from_node(villager, current_structure as ResourceNode)
				villager.assign_work(new_job)
				self.close_window())
			
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

	# clear generated villager list
	for child in villager_list_container.get_children():
		child.queue_free()

	parent.close_structure_menu()
