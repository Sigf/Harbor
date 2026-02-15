class_name WorldModeMenu extends Control

@export var owning_world_ui: WorldUI
@export var selected_color: Color

@export var villagers_button_panel: PanelContainer
@export var construction_button_panel: PanelContainer
@export var world_stats_button_panel: PanelContainer

func _ready() -> void:
	assert(is_instance_valid(owning_world_ui))
	assert(is_instance_valid(villagers_button_panel))
	assert(is_instance_valid(construction_button_panel))
	assert(is_instance_valid(world_stats_button_panel))


func on_world_ui_mode_changed(new_mode: IslandWorld.WORLD_GAMEPLAY_MODE) -> void:
	match new_mode:
		IslandWorld.WORLD_GAMEPLAY_MODE.WORLD_STATS:
			world_stats_button_panel.modulate = selected_color
			villagers_button_panel.modulate = Color(1, 1, 1)
			construction_button_panel.modulate = Color(1, 1, 1)
		IslandWorld.WORLD_GAMEPLAY_MODE.VILLAGERS_INFO:
			villagers_button_panel.modulate = selected_color
			world_stats_button_panel.modulate = Color(1, 1, 1)
			construction_button_panel.modulate = Color(1, 1, 1)
		IslandWorld.WORLD_GAMEPLAY_MODE.CONSTRUCTION:
			construction_button_panel.modulate = selected_color
			world_stats_button_panel.modulate = Color(1, 1, 1)
			villagers_button_panel.modulate = Color(1, 1, 1)
