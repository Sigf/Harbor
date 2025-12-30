class_name SelectableStructure extends Node3D

@export var selection_indicator: Node3D
@export var static_body: StaticBody3D


var selected: bool:
	set(value):
		selection_indicator.visible = value


func _ready():
	selected = false;
