extends Node3D

var main_menu_scene = preload("res://UI/main_menu.tscn")
var main_menu_instance: MainMenu
var current_world: IslandWorld


func _ready():
	# Get current world, will need to change when loading worlds at runtime
	for child in get_children():
		if child is IslandWorld:
			current_world = child as IslandWorld

	assert(is_instance_valid(current_world))


func _input(event):
	if(event.is_action_pressed("open_menu")):
		if(is_instance_valid(main_menu_instance)):
			# Close main menu
			main_menu_instance.queue_free()
		else:
			# Open main menu
			main_menu_instance = main_menu_scene.instantiate() as MainMenu
			_set_menu_buttons()
			add_child(main_menu_instance)


func _set_menu_buttons() -> void:
	assert(is_instance_valid(main_menu_instance))
	
	assert(is_instance_valid(main_menu_instance.end_turn_button))
	assert(is_instance_valid(main_menu_instance.spawn_villager_button))
	assert(is_instance_valid(main_menu_instance.print_world_stats_button))
	
	main_menu_instance.end_turn_button.pressed.connect(current_world.end_turn)
	main_menu_instance.spawn_villager_button.pressed.connect(current_world.spawn_villager)
	main_menu_instance.print_world_stats_button.pressed.connect(current_world.print_world_stats)
