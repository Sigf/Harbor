@abstract class_name WorldStructure extends Node3D
# Structures within the world. Those strucutures can optionally be selectable, where an indicator on them will toggle visibility when selected.

@export var owning_world: IslandWorld
@export var selection_indicator: Node3D
@export var selection_static_body: StaticBody3D
@export var is_selectable: bool = true
@export var structure_name: String


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
