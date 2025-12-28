class_name StructureHarbor extends Node3D

@export var villager_spawn_location: Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_villager_spawn_location() -> Vector3:
	return villager_spawn_location.global_position
