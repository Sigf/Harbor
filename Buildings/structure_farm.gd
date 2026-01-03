class_name StructureFarm extends ResourceNode

@export var grown_representation: Node3D
@export var turns_to_grow: int
@export var resource_amount_when_grown: int
@export var base_gathering_amount: int = 15

var turns_until_grown: int = 0
var watered: bool = false


func _ready() -> void:
	super._ready()
	owning_world.turn_ended.connect(_on_turn_ended)
	resource_amount = 0
	turns_until_grown = turns_to_grow
	grown_representation.visible = false


# HACK: Move this class to another base class, as this is a buildable structure and has more complicated logic for gathering.
func try_extract_resources(amount_to_extract: int) -> bool:
	if resource_amount <= 0 && not watered:
		watered = true
		return false
	
	return super.try_extract_resources(amount_to_extract)


func calculate_gathering_amount(in_villager: VillagerCharacter) -> int:
	return base_gathering_amount


func _on_resource_depleted() -> void:
	print("A farm has been depleted of its resources and will regrow in ", turns_to_grow, " turns.")
	turns_until_grown = turns_to_grow
	grown_representation.visible = false


func _on_turn_ended(turn_number: int) -> void:
	if turns_until_grown == 1 && watered:
		resource_amount = resource_amount_when_grown
		turns_until_grown = 0
		grown_representation.visible = true
		print("A farm has finished growing and is ready to be harvested.")
	elif turns_until_grown > 1 && watered:
		turns_until_grown -= 1
