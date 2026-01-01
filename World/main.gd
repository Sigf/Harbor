extends Node3D

var current_world: IslandWorld


func _ready() -> void:
	# Get current world, will need to change when loading worlds at runtime
	for child in get_children():
		if child is IslandWorld:
			current_world = child as IslandWorld

	assert(is_instance_valid(current_world))
