class_name VillagerInfoPanel extends PanelContainer

@export var villager_list_container: VBoxContainer
@export var villager_view_container: VillagerViewContainer
var villager_selection_button_scene: PackedScene = preload("res://UI/WorldUI/villager_selection_button.tscn")

var owning_ui: WorldUI
var selected_villager: VillagerCharacter
var villagers: Array[VillagerCharacter]


func _ready() -> void:
    if not is_instance_valid(selected_villager):
        villager_view_container.visible = false


func _generate_list_ui(villagers_list: Array[VillagerCharacter]) -> void:
    assert(is_instance_valid(owning_ui))
    assert(is_instance_valid(villager_list_container))
    
    # Clear current list
    for child in villager_list_container.get_children():
        child.queue_free()
    
    for villager in villagers_list:
        var villager_selection_button: VillagerSelectionButton = villager_selection_button_scene.instantiate() as VillagerSelectionButton
        assert(is_instance_valid(villager_selection_button))

        villager_selection_button.text = villager.character_name
        villager_selection_button.reset_size()
        villager_selection_button.pressed.connect(func() -> void:
            display_villager_info(villager))
        
        villager_list_container.add_child(villager_selection_button)


func initialize_ui(in_worldui: WorldUI) -> void:
    assert(is_instance_valid(in_worldui))
    assert(is_instance_valid(villager_list_container))
    assert(is_instance_valid(villager_view_container))
    
    owning_ui = in_worldui
    owning_ui.owning_world.villagers_changed.connect(_generate_list_ui)
    _generate_list_ui(owning_ui.owning_world.characters)


func display_villager_info(villager: VillagerCharacter) -> void:
    assert(is_instance_valid(villager))
    assert(is_instance_valid(villager_view_container))

    # close panel when selecting the already open villager
    if selected_villager == villager:
        villager_view_container.visible = false
        selected_villager = null
        return

    # Open panel if we didn't have a villager already selected
    if selected_villager == null:
        villager_view_container.visible = true

    selected_villager = villager
    villager_view_container.display_villager_info(villager)
