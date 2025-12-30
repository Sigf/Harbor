@abstract class_name WorldStructure extends Node3D

@export var owning_world: IslandWorld
@export var selection_indicator: Node3D
@export var selection_static_body: StaticBody3D
@export var is_selectable: bool = true

@abstract func make_job(in_villager: VillagerCharacter) -> VillagerJobBase

var selected: bool:
	set(value):
		if is_selectable:
			selection_indicator.visible = value


func _ready() -> void:
	assert(is_instance_valid(owning_world))
	
	if is_selectable:
		assert(is_instance_valid(selection_indicator))
		assert(is_instance_valid(selection_static_body))
		selected = false
