class_name ResourceNodeBush extends ResourceNode

@export var ripe_representation: Node3D
@export var turns_to_ripen: int
@export var resource_amount_when_ripe: int

var turns_until_ripe: int = 0

func _ready() -> void:
	super._ready()
	owning_world.turn_ended.connect(_on_turn_ended)
	resource_amount = resource_amount_when_ripe
	turns_until_ripe = 0
	ripe_representation.visible = true


func _on_resource_extracted(villager: VillagerCharacter, extracted_amount: int) -> void:
	print("Villager ", villager.character_name, " gathered ", extracted_amount, " of ", resource_type.world_resource_name, " from a bush.")


func _on_resource_depleted() -> void:
	print("A bush has been depleted of its resources and will regrow in ", turns_to_ripen, " turns.")
	turns_until_ripe = turns_to_ripen
	ripe_representation.visible = false


func _on_turn_ended(turn_number: int) -> void:
	if turns_until_ripe == 1:
		resource_amount = resource_amount_when_ripe
		turns_until_ripe = 0
		ripe_representation.visible = true
		print("A bush has regrown and is ready to be harvested again.")
	elif turns_until_ripe > 1:
		turns_until_ripe -= 1