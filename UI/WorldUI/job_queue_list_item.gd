class_name JobQueueListItem extends PanelContainer

@export var job_type_label: Label
@export var job_description_label: Label
@export var cancel_job_button: Button

var target_job: VillagerJobBase
var owning_list_container: VBoxContainer


func initialize_ui(in_container: VBoxContainer, in_target_job: VillagerJobBase) -> void:
    assert(is_instance_valid(in_container))
    assert(is_instance_valid(in_target_job))
    assert(is_instance_valid(job_type_label))
    assert(is_instance_valid(job_description_label))
    assert(is_instance_valid(cancel_job_button))
    
    owning_list_container = in_container
    target_job = in_target_job
    job_type_label.text = target_job.job_title
    job_description_label.text = target_job.get_job_description()

    cancel_job_button.pressed.connect(_on_cancel_job_button_pressed)


func _on_cancel_job_button_pressed() -> void:
    assert(is_instance_valid(target_job))
    
    var owning_villager: VillagerCharacter = target_job.owning_villager
    assert(is_instance_valid(owning_villager))
    
    owning_villager.remove_job(target_job)
    queue_free()