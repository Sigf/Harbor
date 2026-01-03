class_name VillagerViewContainer extends PanelContainer

@export var villager_name_label: Label
@export var villager_health_label: Label
@export var villager_available_energy_label: Label
@export var job_queue_container: VBoxContainer

var job_queue_list_item_scene: PackedScene = preload("res://UI/WorldUI/job_queue_list_item.tscn")


func display_villager_info(villager: VillagerCharacter) -> void:
    assert(is_instance_valid(villager))
    assert(is_instance_valid(job_queue_container))

    # Disconnect previous signals to avoid multiple connections
    if villager.job_queue_changed.is_connected(_on_villager_job_queue_changed):
        villager.job_queue_changed.disconnect(_on_villager_job_queue_changed)

    if villager.energy_changed.is_connected(_on_villager_energy_changed):
        villager.energy_changed.disconnect(_on_villager_energy_changed)

    villager_name_label.text = villager.character_name
    villager_health_label.text = str(villager.current_health) + " / " + str(villager.max_health)
    villager_available_energy_label.text = str(villager.current_energy) + " / " + str(villager.max_energy)

    _update_job_queue_list(villager)

    # Connect signals
    villager.job_queue_changed.connect(_on_villager_job_queue_changed)
    villager.energy_changed.connect(_on_villager_energy_changed)

    
func _update_job_queue_list(target_villager: VillagerCharacter) -> void:
    assert(is_instance_valid(target_villager))

    # Clear current job queue list
    for child in job_queue_container.get_children():
        child.queue_free()

    for job in target_villager.job_queue:
        var job_list_item: JobQueueListItem = job_queue_list_item_scene.instantiate() as JobQueueListItem
        assert(is_instance_valid(job_list_item))

        job_list_item.initialize_ui(job_queue_container, job)
        job_queue_container.add_child(job_list_item)
    

func _on_villager_job_queue_changed(villager: VillagerCharacter, job_queue: Array[VillagerJobBase]) -> void:
    assert(is_instance_valid(villager))
    _update_job_queue_list(villager)


func _on_villager_energy_changed(villager: VillagerCharacter, new_energy: int) -> void:
    assert(is_instance_valid(villager))
    villager_available_energy_label.text = str(new_energy) + " / " + str(villager.max_energy)