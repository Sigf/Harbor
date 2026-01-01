class_name VillagerViewContainer extends PanelContainer

@export var VillagerNameLabel: Label
@export var VillagerHealthLabel: Label
@export var VillagerAvailableEnergyLabel: Label


func display_villager_info(villager: VillagerCharacter) -> void:
    assert(is_instance_valid(villager))
    
    VillagerNameLabel.text = villager.character_name
    VillagerHealthLabel.text = str(villager.current_health)
    VillagerAvailableEnergyLabel.text = str(villager.current_energy)